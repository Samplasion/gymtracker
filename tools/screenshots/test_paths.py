import tempfile
import unittest
from pathlib import Path
from paths import SCREENSHOTS, LOCATIONS, AVD_HOME, output_for
from migrate_outputs import migrate


class OutputPathsTest(unittest.TestCase):
    def test_every_output_is_os_then_device(self):
        for profile, parts in LOCATIONS.items():
            self.assertEqual(output_for(profile), SCREENSHOTS.joinpath(*parts))
            self.assertEqual(len(output_for(profile).relative_to(SCREENSHOTS).parts), 2)
        self.assertEqual(output_for('iphone'), SCREENSHOTS / 'ios/iphone')
        self.assertEqual(output_for('watch'), SCREENSHOTS / 'watchos/apple-watch')
        self.assertEqual(output_for('android-tablet7'), SCREENSHOTS / 'android/tablet7')
        self.assertEqual(output_for('wear'), SCREENSHOTS / 'wearos/watch')
        self.assertEqual(AVD_HOME, SCREENSHOTS / 'android/_emulators')
        with self.assertRaises(ValueError): output_for('unknown')

    def test_migration_preserves_data_metadata_and_is_repeatable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            samples = {
                'build/app_store_screenshots/final/it/01-workout.png': 'ios/iphone/final/it/01-workout.png',
                'build/app_store_watch_screenshots/logs/old.log': 'watchos/apple-watch/logs/old.log',
                'build/device_screenshots/ipad/raw/en/02-routines.png': 'ios/ipad/raw/en/02-routines.png',
                'build/device_screenshots/android-phone/proofs/it.jpg': 'android/phone/proofs/it.jpg',
                'build/screenshot_emulators/test.log': 'android/_emulators/test.log',
                'docs/wear-os/store/it-IT/images/wear-screenshots/water.png': 'wearos/watch/raw/it-IT/water.png',
            }
            for source in samples:
                path = root/source
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(source.encode())
            metadata = root/'docs/wear-os/store/it-IT/full-description.txt'
            metadata.write_text('keep metadata')
            self.assertEqual(migrate(root), len(samples))
            for source, dest in samples.items():
                self.assertEqual((root/'build/screenshots'/dest).read_bytes(), source.encode())
                self.assertFalse((root/source).exists())
            self.assertEqual(metadata.read_text(), 'keep metadata')
            self.assertEqual(migrate(root), 0)
            self.assertFalse((root/'build/device_screenshots').exists())

    def test_conflict_stops_all_moves(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root/'build/app_store_screenshots/raw/it/a.png'
            source.parent.mkdir(parents=True)
            source.write_bytes(b'original')
            other = source.with_name('b.png')
            other.write_bytes(b'other')
            dest = root/'build/screenshots/ios/iphone/raw/it/b.png'
            dest.parent.mkdir(parents=True)
            dest.write_bytes(b'different')
            with self.assertRaises(FileExistsError): migrate(root)
            self.assertEqual(source.read_bytes(), b'original')
            self.assertEqual(other.read_bytes(), b'other')
            self.assertEqual(dest.read_bytes(), b'different')

    def test_identical_existing_files_are_deduplicated(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root/'build/app_store_screenshots/a.png'
            dest = root/'build/screenshots/ios/iphone/a.png'
            for p in [source, dest]:
                p.parent.mkdir(parents=True, exist_ok=True)
                p.write_bytes(b'same')
            self.assertEqual(migrate(root), 1)
            self.assertEqual(dest.read_bytes(), b'same')
            self.assertFalse(source.exists())
