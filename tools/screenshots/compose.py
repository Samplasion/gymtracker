#!/usr/bin/env python3
"""Deterministic App Store compositions from real simulator captures."""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

from paths import ROOT, output_for
MANIFEST = json.loads((Path(__file__).with_name('manifest.json')).read_text())
FONT = ROOT / 'assets/fonts/NotoSans-Bold.ttf'  # SIL OFL: assets/fonts/OFL.txt


def selected(locale, only, target="iphone"):
    locales = list(MANIFEST['locales']) if locale == 'all' else [locale]
    series = MANIFEST['watch_screenshots' if target == 'watch' else 'screenshots']
    ids = {s['id'] for s in series}
    wanted = ids if only == 'all' else set(only.split(','))
    if not wanted or wanted - ids:
        raise ValueError(f'Unknown screenshot IDs: {sorted(wanted - ids)}')
    if any(lang not in MANIFEST['locales'] for lang in locales):
        raise ValueError('locale must be it, en or all')
    return locales, [s for s in series if s['id'] in wanted]


def capture_path(output, lang, shot, watch=False):
    return output / 'raw' / lang / f'{shot["id"]}-{shot["name"]}{"-watch" if watch else ""}.png'


def watch_device(canvas, source, box):
    x, y, w, h = box
    padding, bezel, radius = 24, 12, 58
    source = source.convert('RGB').resize((w, h), Image.Resampling.LANCZOS)
    # Extend the display background outward before rounding. The complete native
    # capture stays inside the curve, so neither the clock nor controls are cut.
    screen = Image.new('RGB', (w+2*padding, h+2*padding))
    screen.paste(source, (padding, padding))
    for crop, size, at in [
        ((0, 0, w, 1), (w, padding), (padding, 0)),
        ((0, h-1, w, h), (w, padding), (padding, h+padding)),
        ((0, 0, 1, h), (padding, h), (0, padding)),
        ((w-1, 0, w, h), (padding, h), (w+padding, padding)),
    ]:
        screen.paste(source.crop(crop).resize(size), at)
    draw = ImageDraw.Draw(screen)
    for cx, cy, px, py in [(0, 0, 0, 0), (w+padding, 0, w-1, 0), (0, h+padding, 0, h-1), (w+padding, h+padding, w-1, h-1)]:
        draw.rectangle((cx, cy, cx+padding-1, cy+padding-1), fill=source.getpixel((px, py)))
    x, y = x-padding, y-padding
    sw, sh = screen.size
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((x-bezel, y-bezel, x+sw+bezel, y+sh+bezel), radius+bezel, fill='#090A0D', outline='#666974', width=3)
    mask = Image.new('L', screen.size)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw-1, sh-1), radius, fill=255)
    canvas.paste(screen, (x, y), mask)
    draw.rounded_rectangle((x+sw+bezel, y+134, x+sw+bezel+18, y+194), 8, fill='#555862')


def device(canvas, source, box, watch=False):
    if watch:
        watch_device(canvas, source, box)
        return
    x, y, w, h = box
    border, radius = 14, 90
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((x-border, y-border, x+w+border, y+h+border), radius+border, fill='#090A0D', outline='#666974', width=3)
    screen = source.convert('RGB').resize((w, h), Image.Resampling.LANCZOS)
    mask = Image.new('L', (w, h))
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w-1, h-1), radius, fill=255)
    canvas.paste(screen, (x, y), mask)


def export_watch(output, lang, shot=None):
    shot = shot or MANIFEST['watch_screenshots'][0]
    raw = capture_path(output, lang, shot)
    with Image.open(raw) as source:
        preset = MANIFEST['presets']['watch']
        expected = (preset['width'], preset['height'])
        if source.size != expected:
            raise ValueError(f'{raw}: expected {expected}, got {source.size}')
        image = source.convert('RGB')
    dest = output / 'final' / MANIFEST['locales'][lang] / f'{shot["id"]}-{shot["name"]}.png'
    dest.parent.mkdir(parents=True, exist_ok=True)
    image.save(dest)
    proof(output, lang)
    return dest


def compose(output, lang, shot):
    preset = MANIFEST['presets']['iphone']
    size = (preset['width'], preset['height'])
    raw = capture_path(output, lang, shot)
    with Image.open(raw) as opened:
        if opened.size != size:
            raise ValueError(f'{raw}: expected {size}, got {opened.size}')
        phone = opened.convert('RGB')
    canvas = Image.new('RGB', size, '#08090D')
    glow = Image.new('RGB', size)
    ImageDraw.Draw(glow).ellipse((-350, 500, 1650, 2700), fill=shot['color'])
    canvas = Image.blend(canvas, glow.filter(ImageFilter.GaussianBlur(240)), .16)
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((90, 126, 206, 138), 6, fill=shot['color'])
    title = shot['titles'][lang]
    font = ImageFont.truetype(str(FONT), 94)
    bounds = draw.multiline_textbbox((0, 0), title, font=font, spacing=18)
    if bounds[2] - bounds[0] > 1140 or bounds[3] - bounds[1] > 420:
        raise ValueError(f'Title does not fit: {lang}/{shot["id"]}')
    draw.multiline_text((90, 195), title, font=font, fill='#FAFAFC', spacing=18)
    if shot['id'] == '09':
        device(canvas, phone, (65, 720, 910, 1977))
        with Image.open(capture_path(output, lang, shot, watch=True)) as wrist:
            expected = MANIFEST['presets']['watch']
            if wrist.size != (expected['width'], expected['height']):
                raise ValueError(f'Unexpected Watch dimensions: {wrist.size}')
            wrist = wrist.convert('RGB')
            device(canvas, wrist, (825, 1740, 416, 496), watch=True)
    else:
        device(canvas, phone, (150, 600, 1020, 2216))
    dest = output / 'final' / MANIFEST['locales'][lang] / raw.name
    dest.parent.mkdir(parents=True, exist_ok=True)
    output_size = preset['output']
    # Preserve the existing layout and device proportions; fit the exact export
    # format with at most a thin background margin rather than stretching it.
    final = ImageOps.pad(canvas, (output_size['width'], output_size['height']), method=Image.Resampling.LANCZOS, color='#08090D')
    final.convert('RGB').save(dest)
    return dest


def profile_shots(profile, locale, only):
    if profile not in MANIFEST['device_profiles']:
        raise ValueError(f'Unknown device profile: {profile}')
    locales, shots = selected(locale, only)
    allowed = MANIFEST['device_profiles'][profile]['shots']
    if only != 'all' and any(s['id'] not in allowed for s in shots):
        raise ValueError(f'{profile} supports screenshot IDs {",".join(allowed)}')
    return locales, [s for s in shots if s['id'] in allowed]


def compose_profile(output, lang, shot, profile):
    preset = MANIFEST['device_profiles'][profile]
    raw = capture_path(output, lang, shot)
    with Image.open(raw) as image:
        if image.size != (preset['width'], preset['height']):
            raise ValueError(f'{raw}: expected native {preset["width"]}x{preset["height"]}, got {image.size}. Capture the actual device/pose; do not resize an iPhone capture.')
        screen = image.convert('RGB')
    w, h = preset['output']['width'], preset['output']['height']
    if preset['presentation'] == 'native':
        # Play large-screen export: real tablet UI, no promotional copy/frame.
        canvas = ImageOps.pad(screen, (w, h), method=Image.Resampling.LANCZOS, color='black')
    else:
        canvas = Image.new('RGB', (w, h), '#08090D')
        glow = Image.new('RGB', (w, h))
        ImageDraw.Draw(glow).ellipse((-w//3, h//5, w*4//3, h), fill=shot['color'])
        canvas = Image.blend(canvas, glow.filter(ImageFilter.GaussianBlur(w*.18)), .16)
        draw = ImageDraw.Draw(canvas)
        margin = round(w*.068)
        draw.rounded_rectangle((margin, round(h*.044), margin+round(w*.088), round(h*.049)), round(w*.004), fill=shot['color'])
        title = shot['titles'][lang]
        font_size = round(w*.071)
        # Shared copy, fit checked against this profile's title area.
        while font_size >= 24:
            font = ImageFont.truetype(str(FONT), font_size)
            bounds = draw.multiline_textbbox((0,0), title, font=font, spacing=round(font_size*.19))
            if bounds[2]-bounds[0] <= w-2*margin and bounds[3]-bounds[1] <= h*.15:
                break
            font_size -= 1
        else:
            raise ValueError(f'Title does not fit {profile}/{lang}/{shot["id"]}')
        draw.multiline_text((margin, round(h*.068)), title, font=font, fill='#FAFAFC', spacing=round(font_size*.19))
        top, bottom = round(h*.23), round(h*.96)
        scale = min((w-2*margin-32)/screen.width, (bottom-top)/screen.height)
        sw, sh = round(screen.width*scale), round(screen.height*scale)
        x, y = (w-sw)//2, top+(bottom-top-sh)//2
        if shot['id'] == '09' and preset.get('companion') == 'wear':
            x = margin
        device(canvas, screen, (x,y,sw,sh))
        if shot['id'] == '09' and preset.get('companion') == 'wear':
            path = capture_path(output, lang, shot, watch=True)
            with Image.open(path) as opened:
                expected = preset['companion_preset']
                if opened.size != (expected['width'], expected['height']):
                    raise ValueError(f'Unexpected Wear dimensions: {opened.size}')
                diameter = round(w*.29)
                wrist = opened.convert('RGB').resize((diameter,diameter), Image.Resampling.LANCZOS)
            wx, wy = w-margin-diameter, round(h*.64)
            draw.ellipse((wx-10,wy-10,wx+diameter+10,wy+diameter+10), fill='#090A0D', outline='#666974', width=3)
            mask = Image.new('L', wrist.size)
            ImageDraw.Draw(mask).ellipse((0,0,diameter-1,diameter-1),fill=255)
            canvas.paste(wrist,(wx,wy),mask)
    dest = output / 'final' / MANIFEST['locales'][lang] / raw.name
    dest.parent.mkdir(parents=True,exist_ok=True)
    canvas.convert('RGB').save(dest)
    return dest


def proof(output, lang):
    files = sorted((output / 'final' / MANIFEST['locales'][lang]).glob('*.png'))
    if not files:
        raise ValueError(f'No final screenshots for {lang}')
    with Image.open(files[0]) as first:
        cell_height = round(330 * first.height / first.width)
    columns = min(3, len(files))
    sheet = Image.new('RGB', (columns*330, ((len(files)+columns-1)//columns)*(cell_height+40)), '#17181C')
    draw = ImageDraw.Draw(sheet)
    for i, path in enumerate(files):
        x, y = (i % columns)*330, (i//columns)*(cell_height+40)
        with Image.open(path) as image:
            thumbnail = image.copy()
            thumbnail.thumbnail((330, cell_height), Image.Resampling.LANCZOS)
            sheet.paste(thumbnail, (x + (330-thumbnail.width)//2, y + (cell_height-thumbnail.height)//2))
        draw.text((x+12, y+cell_height+7), path.stem, fill='white')
    dest = output / 'proofs' / f'{lang}.jpg'
    dest.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(dest, quality=92)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--locale', default='all', choices=['it', 'en', 'all'])
    parser.add_argument('--only', default='all')
    parser.add_argument('--output', type=Path, default=output_for('iphone'))
    args = parser.parse_args()
    locales, shots = selected(args.locale, args.only)
    # Check the complete selection before overwriting any output.
    for lang in locales:
        for shot in shots:
            for watch in ([False, True] if shot['id'] == '09' else [False]):
                path = capture_path(args.output, lang, shot, watch)
                if not path.is_file():
                    raise FileNotFoundError(f'Missing capture: {path}; run stage:capture first')
    for lang in locales:
        for shot in shots:
            print(compose(args.output, lang, shot))
        proof(args.output, lang)


if __name__ == '__main__':
    main()
