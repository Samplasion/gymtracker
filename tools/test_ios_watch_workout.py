#!/usr/bin/env python3
"""Verify consecutive workouts and food coexistence over real simulator WatchConnectivity."""
import argparse
import json
import plistlib
import subprocess
import time
import uuid
from pathlib import Path

BUNDLE = 'org.js.samplasion.gymbro.watchkitapp'


def simctl(*args):
    return subprocess.check_output(['xcrun', 'simctl', *args], text=True, timeout=60).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phone', required=True)
    parser.add_argument('--watch', required=True)
    parser.add_argument('--log', default='/tmp/gymtracker-ios-watch-workout.log')
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    token = uuid.uuid4().hex
    log_path = Path(args.log)
    seen = set()
    revisions = []
    cache = None
    acknowledgements = None
    last_observation = None
    with log_path.open('w') as log:
        process = subprocess.Popen([
            str(root / '.fvm/flutter_sdk/bin/flutter'), 'test', '--no-pub',
            'integration_test/apple_watch_workout_sync_test.dart', '-d', args.phone,
            f'--dart-define=WATCH_SYNC_RUN_ID={token}',
        ], cwd=root, stdout=log, stderr=subprocess.STDOUT)
        try:
            deadline = time.monotonic() + 600
            while process.poll() is None and time.monotonic() < deadline:
                output = log_path.read_text()
                if cache is None and 'two consecutive workouts preserve the shared Watch snapshot' in output:
                    simctl('install', args.watch, str(root / 'build/ios/Debug-watchsimulator/GymBroWatch Watch App.app'))
                    print(simctl('launch', args.watch, BUNDLE), flush=True)
                    data = Path(simctl('get_app_container', args.watch, BUNDLE, 'data'))
                    cache = data / 'Library/Preferences' / f'{BUNDLE}.plist'
                    phone_data = Path(simctl('get_app_container', args.phone, 'org.js.samplasion.gymbro', 'data'))
                    acknowledgements = phone_data / 'Documents' / f'watch-sync-{token}'
                    acknowledgements.mkdir(parents=True, exist_ok=True)
                    (acknowledgements / 'ready').touch()
                if cache and cache.exists():
                    try:
                        snapshot = plistlib.loads(cache.read_bytes()).get('watch.receivedSnapshot.v2', {})
                    except (plistlib.InvalidFileException, OSError):
                        continue
                    workout = snapshot.get('workout', {})
                    observation = (snapshot.get('revision'), workout.get('id'), workout.get('active'),
                                   workout.get('parameters', {}).get('exerciseName'))
                    if observation != last_observation:
                        last_observation = observation
                        print(f'Observed Watch snapshot: revision={observation[0]}, '
                              f'this_run={str(workout.get("id", "")).startswith(token)}, '
                              f'active={observation[2]}, parameters_present={bool(workout.get("parameters"))}', flush=True)
                    if (workout.get('id') in (f'{token}-A', f'{token}-B')
                            and (not workout.get('active') or workout.get('parameters', {}).get('exerciseName') == f'Workout {workout["id"][-1]}')):
                        food = snapshot['food']
                        assert food['calorieIntake'] == 525 and food['categories'][0]['name'] == token, snapshot
                        stage = (workout['id'][-1], workout['active'], workout['save'])
                        if stage not in seen:
                            seen.add(stage)
                            revisions.append(snapshot['revision'])
                            stage_name = f'{stage[0]}-running' if stage[1] else ('A-ended' if stage[0] == 'A' else 'B-cancelled')
                            (acknowledgements / stage_name).touch()
                            print(f'Watch received {stage}, revision {snapshot["revision"]}; food retained', flush=True)
                            if stage[1]:
                                simctl('io', args.watch, 'screenshot', f'/tmp/gymtracker-watch-workout-{stage[0]}.png')
                time.sleep(0.25)
            if process.poll() is None:
                raise TimeoutError('Integration test exceeded ten minutes')
            if process.returncode:
                raise RuntimeError(f'Flutter test failed ({process.returncode}); see {log_path}')
            expected = {('A', True, True), ('A', False, True), ('B', True, True), ('B', False, False)}
            assert expected <= seen, f'Missing Watch stages: {expected - seen}; see {log_path}'
            assert revisions == sorted(set(revisions)), revisions
            print(f'PASS: four Watch workout stages, monotonically increasing revisions and food coexistence; log {log_path}', flush=True)
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()


if __name__ == '__main__':
    main()
