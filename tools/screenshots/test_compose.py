import tempfile
import unittest
from pathlib import Path
from PIL import Image, ImageChops
from compose import MANIFEST, capture_path, compose, proof, selected, device, export_watch


class CompositionTest(unittest.TestCase):
    def test_localized_series_and_watch(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            for lang in MANIFEST['locales']:
                for shot in MANIFEST['screenshots']:
                    raw = capture_path(output, lang, shot)
                    raw.parent.mkdir(parents=True, exist_ok=True)
                    Image.new('RGB', (1320, 2868), '#151515').save(raw)
                    if shot['id'] == '09':
                        Image.new('RGB', (416, 496), '#151515').save(capture_path(output, lang, shot, True))
                    result = compose(output, lang, shot)
                    with Image.open(result) as image:
                        self.assertEqual(image.size, (1206, 2622))
                        self.assertEqual(image.mode, 'RGB')
                proof(output, lang)
                self.assertTrue((output / 'proofs' / f'{lang}.jpg').is_file())
                self.assertEqual(len(list((output / 'final' / MANIFEST['locales'][lang]).glob('*.png'))), 9)

    def test_native_watch_export_preserves_dimensions_and_raw(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            shot = MANIFEST['watch_screenshots'][0]
            path = capture_path(output, 'it', shot)
            path.parent.mkdir(parents=True)
            source = Image.new('RGB', (416, 496), '#151515')
            source.putpixel((310, 40), (255, 0, 255))
            source.save(path)
            original = path.read_bytes()
            result = export_watch(output, 'it')
            with Image.open(result) as image:
                self.assertEqual(image.size, (416, 496))
                self.assertEqual(image.mode, 'RGB')
                self.assertIsNone(ImageChops.difference(image, source).getbbox())
            self.assertEqual(path.read_bytes(), original)
            self.assertTrue((output / 'proofs/it.jpg').exists())

    def test_complete_watch_series(self):
        self.assertEqual([s['id'] for s in selected('all', 'all', 'watch')[1]], [f'{i:02}' for i in range(1, 8)])
        self.assertEqual([s['name'] for s in selected('it', '03,07', 'watch')[1]], ['edit-set', 'water'])
        with self.assertRaises(ValueError):
            selected('all', '09', 'watch')
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            for lang in MANIFEST['locales']:
                for shot in MANIFEST['watch_screenshots']:
                    raw = capture_path(output, lang, shot)
                    raw.parent.mkdir(parents=True, exist_ok=True)
                    Image.new('RGB', (416, 496), '#151515').save(raw)
                    export_watch(output, lang, shot)
                self.assertEqual(len(list((output / 'final' / MANIFEST['locales'][lang]).glob('*.png'))), 7)
    def test_phone_frame_preserves_status_area_without_overlays(self):
        source = Image.new('RGB', (1320, 2868), 'cyan')
        source.putpixel((660, 40), (255, 0, 255))
        canvas = Image.new('RGB', (1420, 2968), 'black')
        device(canvas, source, (50, 50, 1320, 2868))
        # Both the former clock and Dynamic Island areas remain source pixels.
        for point in [(100, 60), (660, 40), (660, 70), (1200, 60)]:
            self.assertEqual(canvas.getpixel((point[0]+50, point[1]+50)), source.getpixel(point))

    def test_watch_frame_preserves_the_entire_capture(self):
        canvas = Image.new('RGB', (600, 700), 'black')
        source = Image.new('RGB', (416, 496), 'cyan')
        device(canvas, source, (50, 50, 416, 496), watch=True)
        for point in [(50, 50), (465, 50), (50, 545), (465, 545)]:
            self.assertEqual(canvas.getpixel(point), (0, 255, 255))
        self.assertEqual(canvas.getpixel((26, 26)), (0, 0, 0))
        self.assertEqual(canvas.getpixel((200, 26)), (0, 255, 255))

    def test_selection_and_invalid_dimensions(self):
        locales, shots = selected('en', '02,09')
        self.assertEqual(locales, ['en'])
        self.assertEqual([s['id'] for s in shots], ['02', '09'])
        with self.assertRaises(ValueError):
            selected('all', '00')
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            path = capture_path(output, 'en', shots[0])
            path.parent.mkdir(parents=True)
            Image.new('RGB', (100, 100)).save(path)
            with self.assertRaisesRegex(ValueError, 'expected'):
                compose(output, 'en', shots[0])


if __name__ == '__main__':
    unittest.main()
