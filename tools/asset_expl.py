#! /usr/bin/env python3

import sys
import os
import re

cwd = os.getcwd()

langs = [file.replace('.json', '') for file in os.listdir(f'{cwd}/assets/i18n')]

def generate_category_list():
  categories = set()
  with open(f'{cwd}/lib/data/exercises.dart', 'r') as f:
    text = f.read()
    lines = text.split('\n')
    regex = re.compile(r'id: \"library\.(\w+)\.exercises\.(\w+)\"')
    for line in lines:
      match = regex.search(line)
      if match:
        categories.add((match.group(1), match.group(2)))
  return categories

def main():
  with open('pubspec.yaml', 'r') as f:
    text = f.read()
    lines = text.split('\n')

  starting_idx = -1
  ending_idx = -1

  for idx, line in enumerate(lines):
    if '#tool begin exercise-explanations' in line:
      starting_idx = idx
    if '#tool end exercise-explanations' in line:
      ending_idx = idx
  
  if starting_idx == -1 or ending_idx == -1:
    print('Could not find the tool begin or end comments in pubspec.yaml')
    sys.exit(1)

  indentation = lines[starting_idx].index('#')

  categories = generate_category_list()
  directories = [
    f"assets/exercises/{category}/{exercise}"
    for (category, exercise) in categories
  ]

  for dir in directories:
    os.makedirs(f'{cwd}/{dir}', exist_ok=True)

  new_lines = [
    f'{indentation * " "}- {dir}/'
    for dir in directories
  ]

  lines[starting_idx + 1:ending_idx] = list(sorted(new_lines))

  with open('pubspec.yaml', 'w') as f:
    f.write('\n'.join(lines))

if __name__ == "__main__":
  main()