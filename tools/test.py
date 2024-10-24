#! /usr/bin/env python3

# Integration Test Runner
# Pass an int as an argument to run a specific group of tests
# Usage: python tools/test.py 1
# By default, tests are divided into 3 groups alphabetically

import sys
import json
import os
import re

GROUP_COUNT = 3

cwd = os.getcwd()

with open(f'{cwd}/integration_test/app_test.dart', 'r') as f:
  text = f.read()
  lines = text.split('\n')
  regex = re.compile(r'^ {4}(?:testWidgets|group)\((?:\n\s+)?[\'\"]([\w\s]+)[\'\"]', flags=re.MULTILINE)
  tests = regex.findall(text)

groups = []

for i in range(GROUP_COUNT):
  groups.append([test for j, test in enumerate(tests) if j % GROUP_COUNT == i])

def run_group(group):
  print(f'Running {len(group)} tests')
  for test in group:
    print(f'Running {test}')
    os.system(f'flutter test integration_test -d macos --plain-name="{test}"')

def main():
  group = 0
  if len(sys.argv) > 1:
    group = int(sys.argv[1])
  if group == 0:
    for i in range(GROUP_COUNT):
      run_group(groups[i])
  else:
    run_group(groups[group - 1])

if __name__ == '__main__':
  main()