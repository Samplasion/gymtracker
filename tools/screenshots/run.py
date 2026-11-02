#!/usr/bin/env python3
"""Capture and compose the Gym Bro App Store series without store credentials."""
import argparse
import hashlib
import json
import os
import plistlib
import shutil
import signal
import subprocess
import sys
import time
import uuid
from pathlib import Path
from compose import ROOT, MANIFEST, selected, capture_path, export_watch

OUTPUT = ROOT / 'build/app_store_screenshots'
PHONE_BUNDLE = 'org.js.samplasion.gymbro'
WATCH_BUNDLE = PHONE_BUNDLE + '.watchkitapp'


def command(*args, timeout=60):
    result = subprocess.run(list(map(str, args)), text=True, capture_output=True, timeout=timeout)
    if result.returncode:
        raise RuntimeError(f'{args[0]} failed: {result.stderr.strip() or result.stdout.strip()}')
    return result.stdout.strip()


def sim(*args, **kwargs):
    return command('xcrun', 'simctl', *args, **kwargs)


def simulator(kind):
    preset = MANIFEST['presets'][kind]
    inventory = json.loads(sim('list', '--json'))
    if not any(t['identifier'] == preset['device_type'] for t in inventory['devicetypes']):
        raise RuntimeError(f'Missing device type: {preset["device_type"]}. Install a compatible Xcode.')
    platform = 'iOS' if kind == 'iphone' else 'watchOS'
    runtimes = sorted((r for r in inventory['runtimes'] if r.get('isAvailable') and r['name'].startswith(platform)), key=lambda r: tuple(int(x) for x in r['version'].split('.')), reverse=True)
    if not runtimes:
        raise RuntimeError(f'No available {platform} runtime. Install one in Xcode Settings > Components.')
    runtime = runtimes[0]['identifier']
    name = f'GymBro Screenshots {kind}'
    existing = [d for d in inventory['devices'].get(runtime, []) if d['name'] == name and d.get('deviceTypeIdentifier') == preset['device_type'] and d.get('isAvailable')]
    return existing[0]['udid'] if existing else sim('create', name, preset['device_type'], runtime)


def boot(device):
    devices = json.loads(sim('list', 'devices', '--json'))['devices']
    state = next(d['state'] for rows in devices.values() for d in rows if d['udid'] == device)
    if state != 'Booted':
        sim('boot', device)
    print(f'Waiting for screenshot simulator {device} to boot…', flush=True)
    sim('bootstatus', device, '-b', timeout=300)


def configure(device, lang):
    for key, value in [('AppleLanguages', f'({lang})'), ('AppleLocale', 'it_IT' if lang == 'it' else 'en_US')]:
        sim('spawn', device, 'defaults', 'write', 'NSGlobalDomain', key, value)
    sim('status_bar', device, 'override', '--time', '9:41', '--dataNetwork', 'wifi', '--wifiMode', 'active', '--wifiBars', '3', '--batteryState', 'charged', '--batteryLevel', '100')


def capture(lang, shots, phone, watch, watch_shots=None):
    raw = OUTPUT / 'raw' / lang
    raw.mkdir(parents=True, exist_ok=True)
    (OUTPUT / 'proofs' / f'{lang}.jpg').unlink(missing_ok=True)
    for shot in watch_shots or []:
        capture_path(OUTPUT, lang, shot).unlink(missing_ok=True)
        (OUTPUT / 'final' / MANIFEST['locales'][lang] / f'{shot["id"]}-{shot["name"]}.png').unlink(missing_ok=True)
    # Remove selected previous captures and finals before starting a fresh run.
    for shot in shots:
        for path in [capture_path(OUTPUT, lang, shot), capture_path(OUTPUT, lang, shot, True), OUTPUT / 'final' / MANIFEST['locales'][lang] / f'{shot["id"]}-{shot["name"]}.png']:
            path.unlink(missing_ok=True)
    run_id = uuid.uuid4().hex
    log_path = OUTPUT / 'logs' / f'{lang}-{run_id}.log'
    log_path.parent.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, SCREENSHOT_RAW_DIR=str(raw), SIMCTL_CHILD_GYMBRO_SCREENSHOTS='1')
    args = [str(ROOT / '.fvm/flutter_sdk/bin/flutter'), 'drive', '--no-pub', '--driver=test_driver/screenshots.dart', '--target=integration_test/app_store_screenshots_test.dart', '-d', phone,
            f'--dart-define=SCREENSHOT_LOCALE={lang}', f'--dart-define=SCREENSHOT_WATCH_SERIES={str(bool(watch_shots)).lower()}', f'--dart-define=SCREENSHOT_ONLY={",".join(s["id"] for s in shots)}',
            f'--dart-define=SCREENSHOT_RUN_ID={run_id}', f'--dart-define=SCREENSHOT_MANIFEST={json.dumps(MANIFEST, ensure_ascii=False, separators=(",", ":"))}']
    watch_done = watch is None
    with log_path.open('w') as log:
        process = subprocess.Popen(args, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        try:
            deadline = time.monotonic() + 1200
            last_update = 0
            while process.poll() is None:
                build_log = log_path.read_text(errors='replace')
                if '** BUILD FAILED **' in build_log or 'Could not build the application' in build_log or 'Application failed to start on attempt:' in build_log:
                    raise RuntimeError(f'Build failed; see {log_path}. No previous app captures will be used.')
                if time.monotonic() > deadline:
                    raise TimeoutError(f'Flutter capture exceeded 20 minutes; see {log_path}')
                if time.monotonic() - last_update > 30:
                    print(f'Capturing {lang}; log: {log_path}', flush=True)
                    last_update = time.monotonic()
                if not watch_done:
                    try:
                        data = Path(sim('get_app_container', phone, PHONE_BUNDLE, 'data'))
                    except RuntimeError:
                        time.sleep(1)
                        continue
                    marker = data / 'Documents' / f'screenshots-{run_id}'
                    if (marker / 'ready').exists():
                        app = ROOT / 'build/ios/Debug-watchsimulator/GymBroWatch Watch App.app'
                        if not app.is_dir():
                            raise FileNotFoundError(f'Watch build missing: {app}')
                        stop_watch(watch)
                        sim('install', watch, app)
                        if watch_shots:
                            capture_watch_scenes(watch, lang, run_id, watch_shots)
                        else:
                            sim('launch', watch, WATCH_BUNDLE, '-AppleLanguages', f'({lang})', '-AppleLocale', 'it_IT' if lang == 'it' else 'en_US', '--screenshots')
                            cache = Path(sim('get_app_container', watch, WATCH_BUNDLE, 'data')) / 'Library/Preferences' / f'{WATCH_BUNDLE}.plist'
                            receipt_deadline = time.monotonic() + 90
                            while time.monotonic() < receipt_deadline:
                                try:
                                    snapshot = plistlib.loads(cache.read_bytes()).get('watch.receivedSnapshot.v2', {})
                                except (OSError, plistlib.InvalidFileException):
                                    snapshot = {}
                                workout = snapshot.get('workout', {})
                                if workout.get('id') == f'screenshot-{run_id}' and workout.get('parameters', {}).get('exerciseColor') == 0xff00bcd4:
                                    break
                                time.sleep(.5)
                            else:
                                raise TimeoutError('Watch did not receive the current cyan workout snapshot')
                            time.sleep(3)
                            shot = next(s for s in shots if s['id'] == '09')
                            sim('io', watch, 'screenshot', capture_path(OUTPUT, lang, shot, True))
                        (marker / 'watch-captured').touch()
                        watch_done = True
                time.sleep(.5)
            if process.returncode:
                tail = '\n'.join(log_path.read_text(errors='replace').splitlines()[-35:])
                raise RuntimeError(f'Flutter capture failed; see {log_path}\n{tail}')
            if not watch_done:
                raise RuntimeError('Watch capture was not completed')
            if not watch_shots:
                validate_captures(OUTPUT, lang, shots)
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()
            if watch:
                try:
                    sim('terminate', watch, WATCH_BUNDLE)
                except RuntimeError:
                    pass


def capture_watch_scenes(watch, lang, run_id, shots):
    data = Path(sim('get_app_container', watch, WATCH_BUNDLE, 'data'))
    receipt = data / 'Documents/screenshot-ready.json'
    for shot in shots:
        receipt.unlink(missing_ok=True)
        sim('launch', '--terminate-running-process', watch, WATCH_BUNDLE, '-AppleLanguages', f'({lang})',
            '-AppleLocale', 'it_IT' if lang == 'it' else 'en_US', '--screenshots',
            '--screenshot-scene', shot['name'], '--screenshot-run', run_id,
            '--screenshot-reference', MANIFEST['reference_time'])
        deadline = time.monotonic() + 90
        while time.monotonic() < deadline:
            try:
                ready = json.loads(receipt.read_text())
            except (OSError, ValueError):
                ready = {}
            if ready.get('run') == run_id and ready.get('scene') == shot['name'] and ready.get('locale', '').startswith(lang):
                break
            time.sleep(.5)
        else:
            raise TimeoutError(f'Watch {lang}/{shot["id"]}-{shot["name"]}: current workout, catalog, food or scene was not ready within 90 seconds')
        sim('io', watch, 'screenshot', capture_path(OUTPUT, lang, shot))
        print(f'WATCH_CAPTURED {lang}/{shot["id"]}-{shot["name"]}', flush=True)
    validate_watch_captures(OUTPUT, lang, shots)


def validate_watch_captures(output, lang, shots):
    from PIL import Image
    seen = set()
    preset = MANIFEST['presets']['watch']
    for shot in shots:
        path = capture_path(output, lang, shot)
        if not path.is_file():
            raise FileNotFoundError(f'Missing Watch screenshot {lang}/{shot["id"]}-{shot["name"]}')
        with Image.open(path) as image:
            if image.size != (preset['width'], preset['height']):
                raise ValueError(f'Unexpected Watch dimensions: {path}: {image.size}')
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest in seen:
            raise RuntimeError(f'Identical Watch captures in {lang}; a system dialog may be covering the app')
        seen.add(digest)


def validate_captures(output, lang, shots):
    seen = {}
    for shot in shots:
        path = capture_path(output, lang, shot)
        if not path.is_file():
            raise FileNotFoundError(f'Missing screenshot {lang}/{shot["id"]}')
        if shot['id'] == '09' and not capture_path(output, lang, shot, True).is_file():
            raise FileNotFoundError(f'Missing Watch screenshot {lang}/09')
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest in seen:
            raise RuntimeError(f'Screenshots {seen[digest]} and {shot["id"]} are identical; a system dialog may be covering the app.')
        seen[digest] = shot['id']


def stop_watch(device):
    # terminate is harmless for our dedicated simulator, but reports an error if absent.
    try:
        sim('terminate', device, WATCH_BUNDLE)
    except RuntimeError:
        pass


def shutdown_simulators(devices):
    for device in devices:
        # watchOS rejects status-bar overrides; that must not skip shutdown.
        for operation in [('status_bar', device, 'clear'), ('shutdown', device)]:
            try:
                sim(*operation)
            except RuntimeError:
                pass


def main():
    global OUTPUT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', default='iphone', choices=['iphone', 'watch'])
    parser.add_argument('--locale', default='all', choices=['it', 'en', 'all'])
    parser.add_argument('--only', default='all')
    parser.add_argument('--stage', default='all', choices=['capture', 'compose', 'all'])
    args = parser.parse_args()
    if args.target == 'watch':
        OUTPUT = ROOT / 'build/app_store_watch_screenshots'
    locales, shots = selected(args.locale, args.only, args.target)
    if args.stage != 'compose':
        if not (ROOT / '.fvm/flutter_sdk/bin/flutter').exists():
            raise RuntimeError('Flutter SDK missing. Run fvm install and fvm flutter pub get first.')
        if shutil.disk_usage(ROOT).free < 2 * 1024**3:
            raise RuntimeError('At least 2 GiB of free disk space is required before starting screenshot capture.')
        if not shutil.which('xcrun'):
            raise RuntimeError('Xcode command line tools missing')
        phone = simulator('iphone')
        watch = simulator('watch') if args.target == 'watch' or any(s['id'] == '09' for s in shots) else None
        devices = [phone] + ([watch] if watch else [])
        try:
            if watch:
                pairs = json.loads(sim('list', 'pairs', '--json')).get('pairs', {})
                if not any(p['phone']['udid'] == phone and p['watch']['udid'] == watch for p in pairs.values()):
                    sim('pair', watch, phone)
            for device in devices:
                boot(device)
            for lang in locales:
                configure(phone, lang)
                capture(lang, [MANIFEST['screenshots'][-1]] if args.target == 'watch' else shots, phone, watch, watch_shots=shots if args.target == 'watch' else None)
        finally:
            shutdown_simulators(devices)
    if args.stage != 'capture':
        if args.target == 'watch':
            for lang in locales:
                validate_watch_captures(OUTPUT, lang, shots)
            for lang in locales:
                for shot in shots:
                    print(export_watch(OUTPUT, lang, shot))
            return
        for lang in locales:
            validate_captures(OUTPUT, lang, shots)
        subprocess.run([sys.executable, str(Path(__file__).with_name('compose.py')), '--locale', args.locale, '--only', args.only], cwd=ROOT, check=True)


def interrupted(signum, frame):
    raise KeyboardInterrupt


if __name__ == '__main__':
    signal.signal(signal.SIGTERM, interrupted)
    try:
        main()
    except KeyboardInterrupt:
        print('Screenshot generation interrupted; simulator cleanup completed.', file=sys.stderr)
        sys.exit(130)
    except (RuntimeError, ValueError, FileNotFoundError, TimeoutError, subprocess.SubprocessError) as error:
        print(f'Screenshot generation failed: {error}', file=sys.stderr)
        sys.exit(1)
