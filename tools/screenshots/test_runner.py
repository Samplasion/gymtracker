import unittest
import tempfile
from pathlib import Path
from unittest.mock import patch
import run


class SimulatorTest(unittest.TestCase):
    def test_rejects_identical_captures_hidden_by_system_dialog(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            shots = run.MANIFEST['screenshots'][:2]
            for shot in shots:
                path = run.capture_path(output, 'it', shot)
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'identical system dialog image')
            with self.assertRaisesRegex(RuntimeError, 'system dialog'):
                run.validate_captures(output, 'it', shots)

    def test_missing_watch_capture_cannot_be_exported(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            shot = run.MANIFEST['screenshots'][-1]
            path = run.capture_path(output, 'it', shot)
            path.parent.mkdir(parents=True)
            path.write_bytes(b'phone only')
            with self.assertRaisesRegex(FileNotFoundError, 'Missing Watch'):
                run.validate_captures(output, 'it', [shot])

    def test_watch_scene_times_out_instead_of_reusing_old_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            data = Path(directory)
            receipt = data / 'Documents/screenshot-ready.json'
            receipt.parent.mkdir()
            receipt.write_text('{"run":"old","scene":"workout","locale":"it_IT"}')
            with patch.object(run, 'sim', return_value=str(data)) as simulator, patch.object(run.time, 'monotonic', side_effect=[0, 91]):
                with self.assertRaisesRegex(TimeoutError, 'within 90 seconds'):
                    run.capture_watch_scenes('watch', 'it', 'new-run', [run.MANIFEST['watch_screenshots'][0]])
            self.assertFalse(receipt.exists())
            simulator.assert_any_call('launch', '--terminate-running-process', 'watch', run.WATCH_BUNDLE, '-AppleLanguages', '(it)', '-AppleLocale', 'it_IT', '--screenshots', '--screenshot-scene', 'workout', '--screenshot-run', 'new-run', '--screenshot-reference', run.MANIFEST['reference_time'])

    def test_watch_shutdown_survives_unsupported_status_bar(self):
        def response(*args):
            if args[0] == 'status_bar':
                raise RuntimeError('Operation not supported on watchOS')
            return ''
        with patch.object(run, 'sim', side_effect=response) as sim:
            run.shutdown_simulators(['watch'])
            sim.assert_any_call('shutdown', 'watch')

    def test_missing_runtime_explains_how_to_fix_it(self):
        inventory = {'devicetypes': [{'identifier': run.MANIFEST['presets']['iphone']['device_type']}], 'runtimes': [], 'devices': {}}
        with patch.object(run, 'sim', return_value=run.json.dumps(inventory)):
            with self.assertRaisesRegex(RuntimeError, 'Xcode Settings'):
                run.simulator('iphone')

    def test_reuses_only_dedicated_matching_device(self):
        device_type = run.MANIFEST['presets']['iphone']['device_type']
        inventory = {'devicetypes': [{'identifier': device_type}], 'runtimes': [{'identifier': 'runtime', 'name': 'iOS 27.0', 'version': '27.0', 'isAvailable': True}], 'devices': {'runtime': [
            {'udid': 'personal', 'name': 'My iPhone', 'deviceTypeIdentifier': device_type, 'isAvailable': True},
            {'udid': 'dedicated', 'name': 'GymBro Screenshots iphone', 'deviceTypeIdentifier': device_type, 'isAvailable': True},
        ]}}
        with patch.object(run, 'sim', return_value=run.json.dumps(inventory)) as sim:
            self.assertEqual(run.simulator('iphone'), 'dedicated')
            self.assertEqual(sim.call_count, 1)


if __name__ == '__main__':
    unittest.main()
