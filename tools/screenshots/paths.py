"""Shared output locations: operating system, then device."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCREENSHOTS = ROOT / 'build/screenshots'
LOCATIONS = {
    'iphone': ('ios', 'iphone'),
    'ipad': ('ios', 'ipad'),
    'duo-outer': ('ios', 'duo-outer'),
    'duo-inner': ('ios', 'duo-inner'),
    'watch': ('watchos', 'apple-watch'),
    'android-phone': ('android', 'phone'),
    'android-tablet7': ('android', 'tablet7'),
    'android-tablet10': ('android', 'tablet10'),
    'wear': ('wearos', 'watch'),
}
AVD_HOME = SCREENSHOTS / 'android/_emulators'


def output_for(profile):
    try:
        return SCREENSHOTS.joinpath(*LOCATIONS[profile])
    except KeyError:
        raise ValueError(f'Unknown screenshot output profile: {profile}') from None
