EMS
===

escheme Module System

## Introduction

EMS is an approximate implemenation of the module
system provided by STklos. Please see document STklosModuleSystem.txt
for a fuller description of the service interfaces and semantics.


## Services
```
   (module <name> <exp1> <exp2> ...)
   (export <sym1> <sym2> ...)
   (import <module-name1> <module-name2> ...)

   (all-modules)                     returns <list-of-name-module-pairs>
   (find-module <module-name>)       returns <module>
   (current-module)                  returns <module>
   (module-name <module>)            returns <symbol>
   (module-imports <module>)         returns <list-of-module-names>
   (module-exports <module>)         returns <list-of-symbols>
   (module-symbols <module>)         returns <list-of-symbols>
   (imported-symbol? <sym> <module>) returns <boolean>

   (symbol-value <sym> <module> [<default>])  returns <value>
   (symbol-value* <sym> <module> [<default>]) returns <value>
   (in-module <module-name> <sym-name>)       returns <value>

   (select-module <module-name>)
```
## Implemenation

EMS is implemented in escheme and makes notable use of escheme extensions for environments. Consequently,
EMS may not easily port to other scheme implementations.

### Files

| File | Description |
| ---- | ----------- |
| ems.scm              | EMS Implementation | 
| ems_1st_look.scm     | Demonstrates basic EMS use | 
| STklosModuleSystem.txt | A Summary of STklos Module System |
