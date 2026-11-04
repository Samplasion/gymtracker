#!/usr/bin/env python3
"""Capture real Android/iPad/Duo devices, then export each independent profile."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import time
import uuid

from compose import ROOT, MANIFEST, capture_path, profile_shots, compose_profile, proof
from run import command, sim, boot, configure, shutdown_simulators

SDK = Path(os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME') or Path.home() / 'Library/Android/sdk')
from paths import AVD_HOME, output_for
ANDROID = [p for p, v in MANIFEST['device_profiles'].items() if v['platform'] == 'android']
APPLE = [p for p, v in MANIFEST['device_profiles'].items() if v['platform'] == 'ios']


def adb(serial, *args):
    return command(SDK / 'platform-tools/adb', '-s', serial, *args)



def validate(output, lang, shots, profile, require_companion=True):
    from PIL import Image
    config = MANIFEST['device_profiles'][profile]
    seen = set()
    for shot in shots:
        path = capture_path(output, lang, shot)
        if not path.is_file():
            raise FileNotFoundError(f'Missing {profile}/{lang}/{shot["id"]}: run stage:capture first')
        with Image.open(path) as image:
            if image.size != (config['width'], config['height']):
                raise ValueError(f'{path}: expected real capture {config["width"]}x{config["height"]}, got {image.size}; check device orientation/pose')
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest in seen:
            raise RuntimeError(f'Identical {profile} captures; a system dialog may cover the app')
        seen.add(digest)
        if require_companion and shot['id'] == '09' and not capture_path(output, lang, shot, True).is_file():
            raise FileNotFoundError(f'Missing native Wear OS capture: {profile}/{lang}/09')


def prepare(output, lang, shots):
    (output / 'raw' / lang).mkdir(parents=True, exist_ok=True)
    (output / 'logs').mkdir(parents=True, exist_ok=True)
    (output / 'proofs' / f'{lang}.jpg').unlink(missing_ok=True)
    for shot in shots:
        for path in [capture_path(output, lang, shot), capture_path(output, lang, shot, True), output / 'final' / MANIFEST['locales'][lang] / f'{shot["id"]}-{shot["name"]}.png']:
            path.unlink(missing_ok=True)


def flutter_capture(serial, profile, lang, shots, output):
    run_id = uuid.uuid4().hex
    log_path = output / 'logs' / f'{lang}-{run_id}.log'
    args = [ROOT / '.fvm/flutter_sdk/bin/flutter', 'drive', '--no-pub', '--driver=test_driver/screenshots.dart', '--target=integration_test/app_store_screenshots_test.dart', '-d', serial,
            f'--dart-define=SCREENSHOT_LOCALE={lang}', f'--dart-define=SCREENSHOT_ONLY={",".join(s["id"] for s in shots)}',
            f'--dart-define=SCREENSHOT_RUN_ID={run_id}', '--dart-define=SCREENSHOT_COMPANION=none',
            '--dart-define=SCREENSHOT_WATCH_SERIES=false', f'--dart-define=SCREENSHOT_MANIFEST={json.dumps(MANIFEST, ensure_ascii=False, separators=(",", ":"))}']
    env = dict(os.environ, SCREENSHOT_RAW_DIR=str(output / 'raw' / lang), SIMCTL_CHILD_GYMBRO_SCREENSHOTS='1')
    with log_path.open('w') as log:
        process = subprocess.Popen(list(map(str, args)), cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            deadline, last_report = time.monotonic()+1500, 0
            while process.poll() is None:
                text = log_path.read_text(errors='replace')
                if any(s in text for s in ['** BUILD FAILED **', 'Could not build the application', 'Application failed to start on attempt:', 'FAILURE: Build failed']):
                    raise RuntimeError(f'Build failed: {log_path}\n'+'\n'.join(text.splitlines()[-20:]))
                if time.monotonic() > deadline:
                    raise TimeoutError(f'{profile}/{lang}: Flutter exceeded 25 minutes; see {log_path}')
                if time.monotonic()-last_report > 30:
                    print(f'Capturing {profile}/{lang}; log: {log_path}', flush=True)
                    last_report = time.monotonic()
                time.sleep(1)
            if process.returncode:
                raise RuntimeError(f'{profile}/{lang} failed; see {log_path}\n'+'\n'.join(log_path.read_text(errors='replace').splitlines()[-30:]))
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try: process.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()


@contextmanager
def apple_device(profile, selected_id=None):
    config = MANIFEST['device_profiles'][profile]
    inventory = json.loads(sim('list', '--json'))
    runtime_version = lambda r: tuple(int(v) for v in r['version'].split('.'))
    minimum = tuple(int(v) for v in config.get('minimum_runtime', '0').split('.'))
    runtimes = sorted([r for r in inventory['runtimes'] if r.get('isAvailable') and r['name'].startswith('iOS') and runtime_version(r) >= minimum], key=runtime_version, reverse=True)
    if not runtimes:
        raise RuntimeError(f'{profile} requires iOS {config.get("minimum_runtime", "compatible")} in Xcode > Settings > Components. iPhone Duo requires Xcode 27.1; no resized iPhone substitute will be generated.')
    name = f'GymBro Screenshots {profile}'
    device_type = config.get('device_type')
    if not device_type:
        matches = [t for t in inventory['devicetypes'] if config['device_name_match'] in t['name']]
        if not matches:
            raise RuntimeError(f'{profile}: install Xcode 27.1 with iPhone Duo device support')
        device_type = matches[0]['identifier']
        if not selected_id:
            prepared = [d for r in runtimes for d in inventory['devices'].get(r['identifier'], []) if d['name'] == name and d.get('deviceTypeIdentifier') == device_type and d.get('isAvailable')]
            if prepared:
                selected_id = prepared[0]['udid']
            else:
                raise RuntimeError(f'{profile}: prepare a dedicated simulator named "{name}" in Device Hub, select the {config["pose"]} display/pose, then optionally pass simulator:UUID. The capture must be {config["width"]}x{config["height"]}.')
    if selected_id:
        matches = [d for rows in inventory['devices'].values() for d in rows if d['udid'] == selected_id and d['name'] == name and d.get('deviceTypeIdentifier') == device_type and d.get('isAvailable')]
        if not matches:
            raise RuntimeError(f'Refusing personal or mismatched simulator: use a dedicated device named "{name}"')
        serial = selected_id
    else:
        existing = [d for d in inventory['devices'].get(runtimes[0]['identifier'], []) if d['name'] == name and d.get('deviceTypeIdentifier') == device_type and d.get('isAvailable')]
        serial = existing[0]['udid'] if existing else sim('create', name, device_type, runtimes[0]['identifier'])
    try:
        boot(serial)
        yield serial
    finally:
        shutdown_simulators([serial])


@contextmanager
def android_device(profile, config, port):
    name = 'GymBroScreenshots_' + profile.replace('-', '_')
    env = dict(os.environ, ANDROID_AVD_HOME=str(AVD_HOME))
    image = config.get('system_image', MANIFEST['android_system_image'])
    image_dir = SDK / Path(*image.split(';'))
    if not (image_dir / 'system.img').exists():
        raise RuntimeError(f'Missing Android system image: {image}. Install it in Android Studio > SDK Manager (or sdkmanager "{image}")')
    AVD_HOME.mkdir(parents=True, exist_ok=True)
    directory = AVD_HOME / (name+'.avd')
    if not (AVD_HOME / (name+'.ini')).exists():
        result = subprocess.run([str(SDK/'cmdline-tools/latest/bin/avdmanager'), 'create', 'avd', '--name', name, '--package', image, '--device', config['hardware'], '--path', str(directory)], input='no\n', text=True, capture_output=True, env=env, timeout=120)
        if result.returncode:
            raise RuntimeError(f'Cannot create dedicated Android emulator: {result.stderr}')
    ini = directory / 'config.ini'
    existing = dict(line.split('=',1) for line in ini.read_text().splitlines() if '=' in line)
    existing.update({'hw.lcd.width':str(config['width']), 'hw.lcd.height':str(config['height']), 'hw.lcd.density':str(config['density']), 'hw.ramSize':'2048', 'hw.keyboard':'yes', 'hw.initialOrientation':'portrait', 'disk.dataPartition.size':'2048M', 'fastboot.forceColdBoot':'yes', 'showDeviceFrame':'no'})
    ini.write_text(''.join(f'{k}={v}\n' for k,v in existing.items()))
    serial = f'emulator-{port}'
    current = command(SDK/'platform-tools/adb', 'devices')
    if serial in current:
        raise RuntimeError(f'Port {port} already in use. Stop that emulator explicitly; it will not be touched by this lane.')
    log_path = AVD_HOME / (name+'.log')
    with log_path.open('w') as log:
        process = subprocess.Popen([str(SDK/'emulator/emulator'), '-avd', name, '-port', str(port), '-no-window', '-no-audio', '-no-boot-anim', '-no-snapshot', '-gpu', 'swiftshader_indirect'], env=env, stdout=log, stderr=subprocess.STDOUT)
        try:
            deadline = time.monotonic()+240
            while time.monotonic() < deadline:
                if process.poll() is not None:
                    raise RuntimeError(f'Android emulator failed: {log_path}\n'+log_path.read_text(errors='replace')[-2500:])
                result = subprocess.run([str(SDK/'platform-tools/adb'), '-s', serial, 'shell', 'getprop', 'sys.boot_completed'], text=True, capture_output=True, timeout=10)
                if result.stdout.strip() == '1': break
                time.sleep(2)
            else: raise TimeoutError(f'{profile} did not boot within 240 seconds; {log_path}')
            for args in [('settings','put','global','device_provisioned','1'), ('settings','put','secure','user_setup_complete','1'), ('settings','put','system','accelerometer_rotation','0'), ('settings','put','system','user_rotation','0'), ('settings','put','system','font_scale','1.0')]:
                adb(serial, 'shell', *args)
            yield serial
        finally:
            if process.poll() is None:
                try: adb(serial, 'emu', 'kill')
                except RuntimeError: process.terminate()
                try: process.wait(timeout=30)
                except subprocess.TimeoutExpired: process.kill(); process.wait()
            # These are solely the lane's generated AVDs inside build/. Retain
            # screenshots/logs, release disposable userdata between profiles.
            shutil.rmtree(directory, ignore_errors=True)
            (AVD_HOME / (name+'.ini')).unlink(missing_ok=True)


def wear_capture(serial, lang, output, shot):
    package = 'org.js.samplasion.gymtracker.debug'
    apk = ROOT / 'build/wear/outputs/apk/debug/wear-debug.apk'
    if not apk.is_file(): raise FileNotFoundError('Build the Wear demo first: cd android && ./gradlew :wear:assembleDebug')
    adb(serial, 'install', '-r', str(apk))
    adb(serial, 'shell', 'am', 'force-stop', package)
    adb(serial, 'shell', 'am', 'start', '-n', package+'/org.js.samplasion.gymtracker.wear.MainActivity', '--ez', 'screenshots', 'true', '--ez', 'app_store', 'true', '--ei', 'screenshot_rest_seconds', str(MANIFEST['workout_fixture']['rest_seconds']), '--es', 'scene', 'workout', '--es', 'locale', lang)
    rest_seconds = MANIFEST['workout_fixture']['rest_seconds']
    rest_label = f'{rest_seconds//60:02}:{rest_seconds%60:02}'
    deadline = time.monotonic()+45
    while time.monotonic() < deadline:
        try:
            adb(serial, 'shell', 'uiautomator', 'dump', '/sdcard/gymbro-screenshot.xml')
            ui = adb(serial, 'shell', 'cat', '/sdcard/gymbro-screenshot.xml')
            expected = ['Panca piana' if lang=='it' else 'Bench press', '24:00', '132', '164', rest_label]
            if all(value in ui for value in expected) and '72.5' in ui.replace(',','.'):
                break
        except RuntimeError: pass
        time.sleep(1)
    else: raise TimeoutError(f'Wear {lang}: localized workout/72.5 kg/24:00/rest {rest_label} not ready')
    path = capture_path(output, lang, shot, True)
    with path.open('wb') as dest:
        subprocess.run([str(SDK/'platform-tools/adb'), '-s', serial, 'exec-out', 'screencap', '-p'], stdout=dest, check=True, timeout=30)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', required=True, choices=list(MANIFEST['device_profiles'])+['android-all','ios-tablets'])
    parser.add_argument('--locale', default='all', choices=['it','en','all'])
    parser.add_argument('--only', default='all')
    parser.add_argument('--stage', default='all', choices=['capture','compose','all'])
    parser.add_argument('--simulator')
    args = parser.parse_args()
    profiles = ANDROID if args.profile=='android-all' else APPLE if args.profile=='ios-tablets' else [args.profile]
    if args.simulator and len(profiles)>1: raise ValueError('simulator:UUID requires one specific device profile')
    for profile in profiles:
        locales, shots = profile_shots(profile, args.locale, args.only)
        config, output = MANIFEST['device_profiles'][profile], output_for(profile)
        if args.stage != 'compose':
            if not (ROOT/'.fvm/flutter_sdk/bin/flutter').exists(): raise FileNotFoundError('Run fvm install and fvm flutter pub get')
            required_gib = 9 if config.get('companion') == 'wear' and any(s['id']=='09' for s in shots) else 4
            if shutil.disk_usage(ROOT).free < required_gib*1024**3:
                raise RuntimeError(f'At least {required_gib} GiB free space required before capture ({profile}); Wear OS reserves a large temporary partition.')
            if config['platform']=='android':
                # A prior release build filters dev plugins from the generated
                # registrant. Refresh tooling before --no-pub debug captures.
                command(ROOT/'.fvm/flutter_sdk/bin/flutter', 'pub', 'get', timeout=300)
                if any(s['id']=='09' for s in shots):
                    command(ROOT/'android/gradlew', '-p', ROOT/'android', ':wear:assembleDebug', timeout=900)
                context = android_device(profile, config, 5580+2*ANDROID.index(profile))
            else: context = apple_device(profile, args.simulator)
            with context as serial:
                for lang in locales:
                    prepare(output, lang, shots)
                    if config['platform']=='ios': configure(serial, lang)
                    flutter_capture(serial, profile, lang, shots, output)
                    validate(output, lang, shots, profile, require_companion=False)
            # Wear fixtures do not need a live paired phone. Close the phone AVD
            # first: API 30 Wear reserves a large userdata partition at startup.
            if any(s['id']=='09' for s in shots):
                with android_device('wear', config['companion_preset'], 5578) as wear:
                    for lang in locales:
                        wear_capture(wear, lang, output, next(s for s in shots if s['id']=='09'))
            for lang in locales: validate(output, lang, shots, profile)
        if args.stage != 'capture':
            for lang in locales: validate(output, lang, shots, profile)
            for lang in locales:
                for shot in shots: print(compose_profile(output, lang, shot, profile))
                proof(output, lang)


if __name__ == '__main__':
    signal.signal(signal.SIGTERM, lambda *_: (_ for _ in ()).throw(KeyboardInterrupt()))
    try: main()
    except KeyboardInterrupt:
        print('Capture interrupted; dedicated devices cleaned up.', file=sys.stderr); sys.exit(130)
    except (RuntimeError, ValueError, OSError, TimeoutError, subprocess.SubprocessError) as error:
        print(f'Device screenshot generation failed: {error}', file=sys.stderr); sys.exit(1)
