EOS
===

EScheme Object System

## Introduction

EOS is a Dylan inspired object system for escheme employing classes and generic 
functions. EOS uses multi-dispatch to select the generic function implemenation
for dispatch. 

In brief:

+ Classes define types.
+ Generic functions define function patterns.
+ Functions define implementations of generic functions.
+ Generic functions are called with varying argument lists
    and the closest conforming implementation is chosen.
+ The chosen function is called with the supplied arguments.

In many object-systems, which are class-based, dispatch is based on the 
first argument alone. In EOS all arguments, not just the first, participate 
in selecting the function implementation. 

Multi-dispatch is expensive, but in practice the number of candidate functions
is small. All the candidates must be ranked and the best matchinging candidate
is chosen.  The next ranking candidate function can be called using the 
support function "next-function". This is not quite the same as "send-super" 
but may under certain circumstances behave similarly.

## Grammar

```
   (define-class <name> <base-type> <slots>)  -> <name>      (macro)  
   (define-generic-function <name> <formals>) -> <gfunction> (macro)
   (define-function <name> <formals> <body>)  -> <function>  (macro)
   (function <formals> <body>)                -> <function>  (macro) 
   (make <type> {(<slot-name> <value>)}*)     -> <instance>  (macro)   
   (slot-ref <slot-name> <instance>)          -> <value>     (macro)
   (slot-set! <slot-name> <instance> <value>) -> <value>     (macro)
   (next-function)                            -> <sexpr>     (function)

   Where:
      <name> := <symbol>
      <base-type> := <class-name> 
      <sexpr> := escheme symbolic expression
      <value> := <sexpr>
      <slot> := ( <slot-name> <type> [<value-guard>]) | <slot-name>
      <slots> := {<slot>}*
      <gfunction> := <closure>
      <function> := <closure>
      <type> := name of eos class type
      <slot-name> := <symbol>
      <value-guard> := predicate function
      <formals> := (<formal> ...)
      <formal> := (<name> <type>) | <name>
      <body> := {<sexpr>*}
      <instance> := eos class type instance
    
```

CAUTION

Generic function "dispatchers" are implemented as closures and assigned to the
genric function name at global scope. Choosing a name holding an essential 
scheme function as a generic function name will break the system.

## Implemenation

EOS is implemented in escheme and makes notable use of escheme extensions 
for environments. Consequently, EOS may not easily port to other scheme
implementations.

### Files

| File | Description |
| ---- | ----------- |
| eos.scm              | EOS Implementation | 
| eos_1st_look.scm     | Demonstrates basic EOS use | 
| eos_stacks.scm       | stack and stack-of-integer classes | 
| eos_cards.scm        | card and deck classes | 
 
