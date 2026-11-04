import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from PIL import Image
import devices
from compose import MANIFEST, profile_shots, compose_profile, capture_path


class DeviceProfilesTest(unittest.TestCase):
    def test_store_selections_and_formats(self):
        _, phone = profile_shots('android-phone', 'all', 'all')
        self.assertEqual([s['id'] for s in phone], ['01','02','04','05','06','07','08','09'])
        for profile in ('android-tablet7','android-tablet10','ipad','duo-outer','duo-inner'):
            self.assertEqual([s['id'] for s in profile_shots(profile, 'it', 'all')[1]], [f'{i:02}' for i in range(1,9)])
            with self.assertRaises(ValueError): profile_shots(profile, 'it', '09')
        self.assertEqual(MANIFEST['device_profiles']['duo-outer']['output'], {'width':1398,'height':2034})
        self.assertEqual(MANIFEST['device_profiles']['duo-inner']['output'], {'width':2007,'height':2853})

    def test_every_profile_composes_its_own_native_capture(self):
        with tempfile.TemporaryDirectory() as directory:
            for profile, config in MANIFEST['device_profiles'].items():
                output = Path(directory)/profile
                for lang in ('it','en'):
                    for shot in profile_shots(profile,lang,'all')[1]:
                        raw = capture_path(output,lang,shot)
                        raw.parent.mkdir(parents=True,exist_ok=True)
                        Image.new('RGB',(config['width'],config['height']),'#141414').save(raw)
                        if shot['id']=='09':
                            Image.new('RGB',(config['companion_preset']['width'],config['companion_preset']['height']),'#151515').save(capture_path(output,lang,shot,True))
                        result=compose_profile(output,lang,shot,profile)
                        with Image.open(result) as image:
                            self.assertEqual(image.size,tuple(config['output'].values()))
                            self.assertEqual(image.mode,'RGB')

    def test_phone_capture_cannot_be_reused_for_ipad(self):
        with tempfile.TemporaryDirectory() as directory:
            output=Path(directory)
            shot=MANIFEST['screenshots'][0]
            raw=capture_path(output,'it',shot)
            raw.parent.mkdir(parents=True)
            Image.new('RGB',(1320,2868)).save(raw)
            with self.assertRaisesRegex(ValueError,'actual device'):
                compose_profile(output,'it',shot,'ipad')

    def test_duo_missing_runtime_fails_before_booting(self):
        inventory={'runtimes':[{'name':'iOS 27.0','version':'27.0','isAvailable':True}],'devices':{},'devicetypes':[]}
        with patch.object(devices,'sim',return_value=devices.json.dumps(inventory)) as simulator:
            with self.assertRaisesRegex(RuntimeError,'Xcode 27.1'):
                with devices.apple_device('duo-inner'): pass
            self.assertEqual(simulator.call_count,1)

    def test_prepared_duo_is_reused_without_touching_personal_devices(self):
        inventory={'runtimes':[{'identifier':'ios271','name':'iOS 27.1','version':'27.1','isAvailable':True}],
                   'devicetypes':[{'name':'iPhone Duo','identifier':'duo-type'}],
                   'devices':{'ios271':[{'udid':'personal','name':'My Duo','deviceTypeIdentifier':'duo-type','isAvailable':True},
                                        {'udid':'dedicated','name':'GymBro Screenshots duo-inner','deviceTypeIdentifier':'duo-type','isAvailable':True}]}}
        with patch.object(devices,'sim',return_value=devices.json.dumps(inventory)), patch.object(devices,'boot') as boot, patch.object(devices,'shutdown_simulators') as stop:
            with devices.apple_device('duo-inner') as serial:
                self.assertEqual(serial,'dedicated')
            boot.assert_called_once_with('dedicated')
            stop.assert_called_once_with(['dedicated'])

    def test_unselected_files_survive_partial_prepare(self):
        with tempfile.TemporaryDirectory() as directory:
            output=Path(directory)
            untouched=output/'final/it/02-routines.png'
            untouched.parent.mkdir(parents=True)
            untouched.write_bytes(b'keep')
            stale=output/'final/it/01-workout.png'
            stale.write_bytes(b'remove')
            devices.prepare(output,'it',[MANIFEST['screenshots'][0]])
            self.assertFalse(stale.exists())
            self.assertEqual(untouched.read_bytes(),b'keep')
