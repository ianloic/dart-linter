// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.package_prefixed_library_names;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:linter/src/io.dart';
import 'package:linter/src/linter.dart';
import 'package:linter/src/util.dart';

const desc =
    r'Prefix library names with the package name and a dot-separated path.';

const details = r'''
**DO** prefix library names with the package name and a dot-separated path.

This guideline helps avoid the warnings you get when two libraries have the 
same name. Here are the rules we recommend:

* Prefix all library names with the package name.
* Make the entry library have the same name as the package.
* For all other libraries in a package, after the package name add the dot-separated path to the library's Dart file. 
* For libraries under `lib`, omit the top directory name.

For example, say the package name is `my_package`. Here are the library names 
for various files in the package:

**GOOD:**

```
// In lib/my_package.dart
library my_package;

// In lib/other.dart
library my_package.other;

// In lib/foo/bar.dart
library my_package.foo.bar;

// In example/foo/bar.dart
library my_package.example.foo.bar;

// In lib/src/private.dart
library my_package.src.private;
```
''';

bool matchesOrIsPrefixedBy(String name, String prefix) =>
    name == prefix || name.startsWith('$prefix.');

class PackagePrefixedLibraryNames extends LintRule {
  PackagePrefixedLibraryNames() : super(
          name: 'package_prefixed_library_names',
          description: desc,
          details: details,
          group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  LintRule rule;
  Visitor(this.rule);

  @override
  visitLibraryDirective(LibraryDirective node) {
    Source source = node.element.source;
    var prefix = createLibraryNamePrefix(
        libraryPath: source.fullName,
        projectRoot: getProjectRoot(source.fullName),
        packageName: getProjectPackageName(source.fullName));

    var libraryName = node.element.name;
    if (!matchesOrIsPrefixedBy(libraryName, prefix)) {
      rule.reportLint(node.name);
    }
  }
}
