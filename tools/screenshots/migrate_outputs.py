#!/usr/bin/env python3
"""Move legacy screenshot outputs into the shared OS/device hierarchy."""
import hashlib
from pathlib import Path
import shutil
from paths import ROOT, LOCATIONS


def legacy_locations(root):
    base = root / 'build/screenshots'
    mappings = [
        (root / 'build/app_store_screenshots', base / 'ios/iphone'),
        (root / 'build/app_store_watch_screenshots', base / 'watchos/apple-watch'),
        (root / 'build/screenshot_emulators', base / 'android/_emulators'),
    ]
    for profile in ('android-phone', 'android-tablet7', 'android-tablet10', 'ipad', 'duo-outer', 'duo-inner'):
        mappings.append((root / 'build/device_screenshots' / profile, base.joinpath(*LOCATIONS[profile])))
    store = root / 'docs/wear-os/store'
    if store.is_dir():
        for locale in sorted(store.iterdir()):
            if locale.is_dir():
                mappings.append((locale / 'images/wear-screenshots', base / 'wearos/watch/raw' / locale.name))
    return mappings


def digest(path):
    with path.open('rb') as file:
        return hashlib.file_digest(file, 'sha256').hexdigest()


def migrate(root=ROOT):
    mappings = [(src, dst) for src, dst in legacy_locations(root) if src.exists()]
    files = [(src / relative, dst / relative) for src, dst in mappings
             for relative in (p.relative_to(src) for p in src.rglob('*') if p.is_file())]
    # Check every collision before moving anything. Never overwrite a different
    # image/log; identical files can safely be deduplicated on a repeated run.
    for src, dst in mappings:
        if dst.exists() and not dst.is_dir():
            raise FileExistsError(f'Output directory conflicts with a file: {dst}')
    for src, dst in files:
        if dst.exists() and (not dst.is_file() or digest(src) != digest(dst)):
            raise FileExistsError(f'Conflicting output; no files moved: {dst}')
        parent = dst.parent
        while parent != root:
            if parent.exists() and not parent.is_dir():
                raise FileExistsError(f'Output parent conflicts with a file: {parent}')
            parent = parent.parent
    for src, dst in files:
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            src.unlink()  # Verified identical above.
        else:
            shutil.move(str(src), str(dst))
    for src, _ in mappings:
        for directory in sorted((p for p in src.rglob('*') if p.is_dir()), key=lambda p: len(p.parts), reverse=True):
            directory.rmdir()
        src.rmdir()
    old_devices = root / 'build/device_screenshots'
    if old_devices.is_dir() and not any(old_devices.iterdir()):
        old_devices.rmdir()
    return len(files)


if __name__ == '__main__':
    print(f'Migrated {migrate()} files to {ROOT / "build/screenshots"}')
