#!/usr/bin/python2

import re
import sys

MAJOR_VERSION_PATTERN = re.compile(r"#define\s+MAJOR_VERSION\s+(.*)")
MINOR_VERSION_PATTERN = re.compile(r"#define\s+MINOR_VERSION\s+(.*)")
BUILD_NUMBER_PATTERN = re.compile(r"#define\s+BUILD_NUMBER\s+(.*)")
PATCH_LEVEL_PATTERN = re.compile(r"#define\s+PATCH_LEVEL\s+(.*)")

patterns = [MAJOR_VERSION_PATTERN,
            MINOR_VERSION_PATTERN,
            BUILD_NUMBER_PATTERN,
            PATCH_LEVEL_PATTERN]

source = open(sys.argv[1]).read()
version_components = []
for pattern in patterns:
  version_components.append(pattern.search(source).group(1).strip())

if version_components[len(version_components) - 1] == '0':
  version_components.pop()

print  '.'.join(version_components)
