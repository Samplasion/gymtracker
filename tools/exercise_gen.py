#! /usr/bin/env python3

import sys
import json
import os
import re

cwd = os.getcwd()

with open(f'{cwd}/assets/i18n/en.json', 'r') as f:
  localizedNames = json.load(f)

def generate_exercises():
  categories = {}
  with open(f'{cwd}/lib/data/exercises.dart', 'r') as f:
    text = f.read()
    lines = text.split('\n')
    regex = re.compile(r'id: \"library\.(\w+)\.exercises\.(\w+)\"')
    for line in lines:
      match = regex.search(line)
      if match:
        if not categories.get(match.group(1)):
          categories[match.group(1)] = set()
        categories[match.group(1)].add(match.group(2))
  return categories

def main():
  categories = generate_exercises()

  classNames = []
  classes = []

  for category in categories:
    klass = f"""
    class $GTStandardLibrary{category.capitalize()}Exercises {{
      const $GTStandardLibrary{category.capitalize()}Exercises._();
    """
    
    classNames.append((category, f"$GTStandardLibrary{category.capitalize()}Exercises"))

    sort = sorted(categories[category], key=lambda x: x.lower())
    for exercise in sort:
      localizedName = localizedNames['library'][category]['exercises'][exercise]
      klass += f"""
      /// {localizedName}
      String get {exercise} => 'library.{category}.exercises.{exercise}';
      """
    
    klass += f"""
      List<String> get values => [{', '.join(sort)}];

    }}
    """
  
    classes.append(klass)
  
  file = """// GENERATED CODE - DO NOT EDIT BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

class GTStandardLibrary {
  """

  for name, t in classNames:
    file += f"static const {name} = {t}._();\n"
  
  file += "}\n\n"
  file += "\n\n".join(classes)

  with open(f'{cwd}/lib/gen/exercises.gen.dart', 'w') as f:
    f.write(file)
  
  # Format file using dart format
  os.system("dart format lib/gen/exercises.gen.dart")

  print("Exercises generated successfully!")

if __name__ == "__main__":
  main()