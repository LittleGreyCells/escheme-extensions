EMS
===

escheme Module System

## Introduction

EMS is an approximate implemenation of the module
system provided by STklos. Please see document STklosModuleSystem.txt
for a fuller description of the service interfaces and semantics.


## Services
```
   (module <module-name> {<sexpr>}* )   -> <module-name>      (macro)
   (export {<symbol>*})                 -> nil                (macro)
   (import {<module-name>}*)            -> nil                (macro)
   (all-modules)                        -> <assoc-list>       (function)
   (find-module <module-name>)          -> <module>           (function)
   (current-module)                     -> <module>           (function)
   (module-name <module>)               -> <symbol>           (function)
   (module-imports <module>)            -> <module-name-list> (function)
   (module-exports <module>)            -> <symbol-list>      (function)
   (module-symbols <module>)            -> <symbol-list>      (function)
   (imported-symbol? <symbol> <module>) -> <boolean>          (function)
   (symbol-value <symbol> <module> [<default>])  -> <sexpr>   (function)
   (symbol-value* <symbol> <module> [<default>]) -> <sexpr>   (function)
   (in-module <module-name> <symbol>)            -> <sexpr>   (function)
   (select-module <module-name>)                              (macro)

   Where:
      <module-name> := <symbol>
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
