#!/usr/bin/env python3
"""Run the iOS food channel test and verify its latest snapshot on a paired Watch.

Flutter removes the companion when deploying/tearing down the iPhone test app.
Install it after deployment and inspect its cache while the test is still alive.
"""
import argparse
import json
from pathlib import Path
import plistlib
import subprocess
import time
import uuid


def simctl(*args):
    return subprocess.check_output(['xcrun', 'simctl', *args], text=True).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phone', required=True)
    parser.add_argument('--watch', required=True)
    parser.add_argument('--log', default='/tmp/gymtracker-ios-watch-food.log')
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    token = uuid.uuid4().hex
    command = [
        str(root / '.fvm/flutter_sdk/bin/flutter'), 'test', '--no-pub',
        'integration_test/apple_watch_food_sync_test.dart', '-d', args.phone,
        f'--dart-define=WATCH_SYNC_RUN_ID={token}',
    ]
    log_path = Path(args.log)
    installed = False
    received = False
    cache = None
    with log_path.open('w') as log:
        process = subprocess.Popen(command, cwd=root, stdout=log, stderr=subprocess.STDOUT)
        try:
            deadline = time.monotonic() + 600
            while process.poll() is None and time.monotonic() < deadline:
                output = log_path.read_text()
                if not installed and 'send updated nutrition snapshots to the paired Apple Watch' in output:
                    app = root / 'build/ios/Debug-watchsimulator/GymBroWatch Watch App.app'
                    print('Installing companion after iPhone deployment', flush=True)
                    simctl('install', args.watch, str(app))
                    print(simctl('launch', args.watch, 'org.js.samplasion.gymbro.watchkitapp'), flush=True)
                    group = simctl('get_app_container', args.watch,
                                   'org.js.samplasion.gymbro.watchkitapp',
                                   'group.samplasion.gymtracker')
                    cache = Path(group) / 'Library/Preferences/group.samplasion.gymtracker.plist'
                    installed = True
                if cache and cache.exists() and not received:
                    values = plistlib.loads(cache.read_bytes())
                    payload = json.loads(values.get('foodParameters', '{}'))
                    categories = payload.get('categories', [])
                    if (categories and categories[0].get('name') == f'Simulator sync verification {token}'
                            and payload.get('calorieIntake') == 525):
                        assert payload['calorieIntake'] == 525, payload
                        assert payload['calorieGoal'] == 2400, payload
                        split = payload['totalNutritionSplit']
                        assert (split['protein'], split['carbs'], split['fats']) == (25, 60, 15), payload
                        assert (split['proteinGoal'], split['carbsGoal'], split['fatsGoal']) == (120, 300, 80), payload
                        assert categories[0]['nutritionSplit'] == split, payload
                        assert categories[0]['emoji'] == '🍴', payload
                        received = True
                        print(f'Watch received and persisted the latest snapshot: {json.dumps(payload, ensure_ascii=False)}', flush=True)
                time.sleep(0.5)
            if process.poll() is None:
                raise TimeoutError('iOS integration test exceeded ten minutes')
            if process.returncode:
                raise RuntimeError(f'iOS test failed with exit code {process.returncode}; see {log_path}')
            if not received:
                raise RuntimeError(f'Native channel completed but Watch receipt was NOT verified; see {log_path}')
            print(f'PASS: iOS native channel and actual Watch receipt. Flutter log: {log_path}', flush=True)
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
