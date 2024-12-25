open Fifth

let () =
  let program =
    [ DeFun ("square", [ Dup; Mul ]); Push 2; CallFun "square"; Dump; Halt ]
  in
  Fifth.simulate program 0
