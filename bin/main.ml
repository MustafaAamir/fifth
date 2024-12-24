open Fifth

let () =
    let program = [ Push 10; Push 0; Div; Dump; Halt] in
    Fifth.simulate program 0
