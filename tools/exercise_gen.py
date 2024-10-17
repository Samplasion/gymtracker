#! /usr/bin/env python3

import sys
import os
import re

cwd = os.getcwd()

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

    for exercise in categories[category]:
      klass += f"""
      /// {exercise}
      String get {exercise} => 'library.{category}.exercises.{exercise}';
      """
    
    klass += """
    }
    """
  
    classes.append(klass)
  
  file = """
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

if __name__ == "__main__":
  main()