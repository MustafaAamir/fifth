# fifth
The sequel to Forth nobody wished for

# Preface

Fifth™ might not be the most practical language ever created, but it's certainly one of the most stack-based ones created in the last five minutes. Use it wisely, or at least use it in a way that produces interesting error messages. Divide by zero. Have fun.

- Instructions are stored in a list of opcodes.
- Some instructions are product types of opcodes.
- Hack away in the `bin/` directory.

# Installation
```
$ Copy and paste every file in in a new directory.
$ Especially the ones I forgot to add to my `.gitignore`.
$ bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
$ opam switch create .
$ opam install ocaml dune
$ dune build @fmt
$ open bin/main.ml in a notepad++
$ dune exec -w fifth
$ Write your own programs in bin/main.ml and inspect the output without having to recompile
```

# Overview

### Opcodes:
```
  Push of int -> Push 1
  Pop
  Add
  Sub
  Mul
  Div
  Equal
  Dump
  Dup
  Halt -> ends the program
  If of opcode list * opcode list -> If([then_block], [else_block])
  DeFun of string * opcode list -> Defun (<name>, [function_block])
  CallFun of string -> CallFun <name>
```
### Conditionals

#### Assertion:
```ocaml
[Push 42; Push 42; Equal]  (* stack: 1 *)
[Push 42; Push 41; Equal]  (* stack: 0 *)
```
#### Conditional execution:
```ocaml
let program = [Push 0; If([Push 100; Dump], [Push 200; Dump]); Halt]
```
The value at the top of the stack is evaluated as the condition for the subsequent `if` statement.
If the value is 1 (true), execute the `then_block`, which is prints 100. Otherwise, print 200.
In this example it prints 200, but if that upsets you, we can change the condition to 1.

```ocaml
let program = [Push 1; If([Push 100; Dump], [Push 200; Dump]); Halt] (* prints 100 *)
```

### Functions

Let's define a function to square a number.
```ocaml
[
  (* Define a function that squares a number *)
  DeFun ("square",
    [
      Dup;    (* Duplicate the input *)
      Mul     (* Multiply it by itself *)
    ]
  );

  Push 5;
  CallFun "square";  (* stack: 25 *)
  Dump
]
=> 25 (* 5 * 5 *)
```

# TODO

1. Explore arg for CLI
2. Menhir or Regex for parsing. I hate writing parsers.
