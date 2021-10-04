EOS
===

EScheme Object System

## Introduction

EOS is a Dylan inspired object system for escheme employing classes and generic 
functions. EOS uses multi-dispatch to select the generic function implemenation
for dispatch. 

In brief:

+ Classes define types consisting of slots.
+ Generic functions define function patterns.
+ Methods define implementations of generic functions.
+ Generic functions are called with varying argument lists
    and the closest conforming method is chosen.
+ The chosen method is called with the supplied arguments.

In many object-systems, which are class-based, dispatch is based on the 
first argument alone. In EOS all arguments, not just the first, participate 
in selecting the generic function implementation. 

Multi-dispatch is expensive, but in practice the number of candidate methods
is small. All the candidates must be ranked and the best matchinging candidate
is chosen.  The next ranking candidate method can be called using the 
support function "next-function". This is not quite the same as "send-super" 
but may under certain circumstances behave similarly.

Slots are typically accessed via accessor methods that are automatically
generated:
```
getter = (<slot-name> <object>) returns <value> stored in slot
setter = ((setter <slotname>) <object> <value>) returns <value>
```

Two non-method functions are also provided for accessing slots:
```
(slot-ref <object> <slot-name>)
(slot-set! <object> <slot-name> <value>)
```

The advantage of using a setter method is that, if a value guard function is defined, 
it will be called to check the assigned value.

## Grammar

```
   (define-class <name> <base-type> <slots>)  -> <name>      (macro)  
   (define-method <name> <formals> <body>)    -> <function>  (macro)
   (make <type> {<value>)}*)                  -> <instance>  (macro)   
   (next-function {<sexpr>}* )                -> <sexpr>     (method)
   (slot-ref <slot-name> <instance>)          -> <value>     (macro)
   (slot-set! <slot-name> <instance> <value>) -> <value>     (macro)

   Where:
      <name> := <symbol>
      <base-type> := <type> 
      <sexpr> := escheme symbolic expression
      <value> := <sexpr>
      <slot> := ( <slot-name> <type> [<value-guard>]) | <slot-name>
      <slots> := {<slot>}*
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
 
