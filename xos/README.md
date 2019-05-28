XOS
===

"X" Object System

## Introduction

XOS is a metaclass-based object system for escheme. For those familiar 
with Smalltalk or Python it should feel familiar -- classes, methods, 
(single) inheritance -- but with an s-expression syntax. 

XOS classes are instances of the core class ::metaclass, which defines
structure (variables) and behavior (methods) for all its instances. 
Adding new methods to ::metaclass extends this behavior to all classes.

See the introduction in the XOS implementation file (xos.scm) for a more
detailed discussion about metaclasses and inheritance.

## Genesis

XOS is inspired by the object system implemented originally in David
Betz' XScheme (and XLisp). XOS and Betz' object system ("X" for short) 
are very similar, but there are some differences:

+ Access to XOS ivars/cvars is achieved through slot access functions.
    * Contrast with "X" where
       - "X" objects are integral as a primitive type
       - "X" object ivars/cvars are made accessible in method scope
+ XOS selectors 'method and 'init replace "X" 'answer and 'isnew
+ XOS send-super is a macro, not a function

## Grammar

1. Class Creation

     ```
     (class 'new '<ivars> ['<cvars> [<super>]])
     ```
     ```
       returns <class>
       <ivars> := list of symbols
       <cvars> := list of symbols
       <super> := a class
       <class> := a class
     ```

2. Instance Creation

     ```
     (<class> 'new [<arg>...])
     ```
     ```
        returns an instance of <class>
     ```

3. Method Creation

     ```
     (<class> 'method '<selector> '<params> '<body>)
     ```
     ```
       <selector> := symbol
       <params> := list of symbols
       <body> := list of s-expressions
     ```

4. Method Invocation

     ```
     (<instance> '<selector> [<arg>...])
     ```

5. Var Access

     ```
     (slot-ref <instance> '<var>)
     (slot-set! <instance> '<var> <value>)
     ```

6. Instance Initialization

     ```
     (<class> 'method 'init '<params> '<body>)
     ```

7. Invoking Overridden Methods

     ```
     (send-super '<selector> [<arg>...])
     ```

## Implementation

Less than 200 lines of code!

### Escheme Dependencies

XOS relies on escheme environment primitives.

### Files

| File | Description |
| ---- | ----------- |
| xos.scm           | XOS implementation |
| xos_grammar.txt   | Amplified XOS grammar |
| xos_1st_look.scm  | Demonstrates basic XOS use |
| xos_objectp.scm   | object? predicate implementation |
| xos_metaclass.scm | Demonstrates extending ::metaclass |
| xos_cards.scm     | card and deck classes with a few methods |

