type opcode = Push of int | Pop | Add | Sub | Mul | Div | Dump | Halt
type program = opcode list
exception StackUnderflow of string
exception DivisionByZero
exception InvalidOpCode
exception InvalidOperand
let stack = Stack.create ()
let raise_so msg acc = StackUnderflow(Printf.sprintf msg acc) |> raise
let rec simulate program acc =
    let bin_op op stack =
        if Stack.length stack < 2 then raise_so "Binary op on line %d being done on empty stack" acc
        else let a = Stack.pop stack in let b = Stack.pop stack in Stack.push (op b a) stack;
    in
    match program with
    | [] -> ()
    | x :: xs -> begin
        match x with
        | Push n -> Stack.push n stack; simulate xs (acc + 1)
        | Pop -> if Stack.is_empty stack then raise_so "Pop on line %d" acc
        else ignore(Stack.pop stack); simulate xs (acc + 1)
        | Add -> bin_op ( + ) stack; simulate xs (acc + 1)
        | Mul -> bin_op ( * ) stack; simulate xs (acc + 1)
        | Sub -> bin_op ( - ) stack; simulate xs (acc + 1)
        | Dump -> if Stack.is_empty stack then raise_so "Dump on line %d" acc else
                  Printf.printf "%d\n" (Stack.top stack);
                  simulate xs (acc + 1)
        | Div -> if Stack.length stack < 2 then raise_so "Binary op on line %d being done on empty stack" acc
        else let a = Stack.pop stack in if a = 0 then raise DivisionByZero else let b = Stack.pop stack in Stack.push (b / a) stack; simulate xs (acc + 1)
        | Halt -> ()
    end


