#!/usr/bin/env python3
"""Capture explicit debug fixtures on an already-running Wear OS emulator."""
import argparse
import os
import subprocess
import time
from paths import output_for

parser = argparse.ArgumentParser()
parser.add_argument('--serial', required=True)
parser.add_argument('--package', default='org.js.samplasion.gymtracker.debug')
parser.add_argument('--adb', default=os.environ.get('ADB', 'adb'))
args = parser.parse_args()
app = args.package

def adb(*arguments, **kwargs):
    return subprocess.run([args.adb, '-s', args.serial, *arguments], check=True, timeout=30, **kwargs)

for locale, language in [('en-US', 'en'), ('it-IT', 'it')]:
    destination = output_for('wear') / 'raw' / locale
    destination.mkdir(parents=True, exist_ok=True)
    for scene in ['workout', 'routines', 'food', 'calories', 'nutrients', 'water', 'custom-water', 'diary', 'notes', 'actions', 'edit-set', 'summary']:
        adb('shell', 'am', 'force-stop', app, capture_output=True)
        adb('shell', 'am', 'start', '-n', app + '/org.js.samplasion.gymtracker.wear.MainActivity',
            '--ez', 'screenshots', 'true', '--es', 'scene', scene, '--es', 'locale', language, capture_output=True)
        time.sleep(2)
        with (destination / (scene + '.png')).open('wb') as image:
            adb('exec-out', 'screencap', '-p', stdout=image)
print(f'Captured Wear OS screens in English and Italian: {output_for("wear")}')
