#! /usr/bin/env python3

import re

start = "// tool-start:generate"
end = "// tool-end:generate"

with open('lib/icons/gymtracker_icons.dart', 'r') as f:
  text = f.read()
  lines = text.split('\n')

icons = [];

lines = text.split('\n')
regex = re.compile(r'static const IconData ([\w_]+)')
for line in lines:
  match = regex.search(line)
  if match and match.group(1) not in icons and match.group(1)[0] != '_':
    icons.append(match.group(1))

with open('lib/icons/gymtracker_icons.dart', 'w') as f:
  # Replace the existing generated code
  starting_index = text.index(start)
  ending_index = text.index(end) + len(end)

  f.write(text[:starting_index + len(start) + 1])
  for icon in icons:
    f.write(f"    '{icon}': {icon},\n")
  f.write('    ' + end)
  f.write(text[ending_index:])