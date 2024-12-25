type opcode =
  | Push of int | Pop
  | Add | Sub | Mul
  | Div | Equal | Dump
  | Halt | If of opcode list * opcode list
  | Dup | DeFun of string * opcode list | CallFun of string

type program = opcode list

exception StackUnderflow of string

let function_table = Hashtbl.create 100
let stack = Stack.create ()
let raise_so msg acc = StackUnderflow (Printf.sprintf msg acc) |> raise

let rec simulate program acc =
  let arith_bin_op op stack =
    match Stack.pop_opt stack with
    | Some a -> (
        match Stack.pop_opt stack with
        | Some b -> Stack.push (op b a) stack
        | None -> "Second operand isn't present in the stack" |> failwith)
    | None -> "Binary operation being performed on empty stack" |> failwith
  in
  let logical_bin_op op stack =
    match Stack.pop_opt stack with
    | Some a -> (
        match Stack.pop_opt stack with
        | Some b -> (
            match op b a with
            | true -> Stack.push 1 stack
            | false -> Stack.push 0 stack)
        | None -> "Second operand isn't present in the stack" |> failwith)
    | None -> "Binary operation being performed on empty stack" |> failwith
  in

  match program with
  | [] -> ()
  | x :: xs -> (
      match x with
      | Push n -> Stack.push n stack; simulate xs (acc + 1)
      | Pop -> ( match Stack.pop_opt stack with | Some _ -> simulate xs (acc + 1) | None -> "Pop operation being performed on empty stack" |> failwith)
      | Dup -> (match Stack.top_opt stack with | Some v -> Stack.push v stack | None -> "Empty stack. Can't do Dup, Dupbass." |> failwith); simulate xs (acc + 1)
      | Add -> arith_bin_op ( + ) stack; simulate xs (acc + 1)
      | Mul -> arith_bin_op ( * ) stack; simulate xs (acc + 1)
      | Sub -> arith_bin_op ( - ) stack; simulate xs (acc + 1)
      | Equal -> logical_bin_op ( = ) stack; simulate xs (acc + 1)
      | Dump -> (
          match Stack.top_opt stack with
          | Some v -> Printf.printf "%d\n" v; simulate xs (acc + 1)
          | None -> "Dump operation can't be performed on an empty stack" |> failwith)
      | Div ->
          (match Stack.pop_opt stack with
          | Some a when a <> 0 -> (
              match Stack.pop_opt stack with
              | Some b -> Stack.push (b / a) stack
              | None -> "Second operand isn't present in the stack" |> failwith)
          | None -> "Binary operation being performed on empty stack" |> failwith
          | _ -> "Numerator cannot be zero" |> failwith);
          simulate xs (acc + 1)
      | If (then_branch, else_branch) -> (
          match Stack.pop_opt stack with
          | Some v -> if v <> 0 then simulate then_branch acc else simulate else_branch acc
          | None -> raise_so "If condition on line %d with empty stack" acc)
      | DeFun (name, body) -> Hashtbl.add function_table name body; simulate xs (acc + 1)
      | CallFun name -> (
          match Hashtbl.find_opt function_table name with
          | Some body -> simulate body acc; simulate xs (acc + 1)
          | None -> "Undefined function " ^ name |> failwith)
      | Halt -> ())
