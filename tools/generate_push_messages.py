#!/usr/bin/env python3
"""Keep the push catalog aligned with the Flutter translation sources."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
keys = {
    'friend_request': 'friendRequest', 'friend_accepted': 'friendAccepted',
    'like': 'likedPost', 'comment': 'commentedPost',
    'achievement': 'achievementUnlocked', 'report_status': 'reportUpdated',
}
catalog = {}
for language in ('en', 'it'):
    social = json.loads((root / f'lib/i18n/{language}.i18n.json').read_text())['social']
    catalog[language] = {
        'events': {event: social[key] for event, key in keys.items()},
        'statuses': {key: social[key] for key in ('received', 'reviewing', 'resolved', 'dismissed')},
        'fallback': social['notifications'],
    }
(root / 'supabase/functions/push-delivery/catalog.json').write_text(
    json.dumps(catalog, ensure_ascii=False, indent=2) + '\n'
)
