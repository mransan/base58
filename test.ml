
let assert_string_eq got exp = 
  if got <> exp 
  then failwith (Printf.sprintf "Error: got:%s, exp:%s" got exp)
  else ()

let () =
  let test_cases = [
    ("", "");
    ("\000","1");
    ("\000\000","11");
    ("\001", "2");
    ("\000\001","12");
    ("\000\001\002", "15T");
    ("\001\002\003", "Ldp");
    ("\255", "5Q");
    ("\255\255", "LUv"); 
    ("\255\255\000", "2UzCw"); 
    ("\255\255\000\000", "7YXVfM"); 
    ("This is a test string", "6C3QbYGU2SHs7TronoE7Fb6fH2mgz"); 
    ("gjkdsfh837459028354upo"
    ^"j0-29[23 i9c2hjg b,kbf,"
    ^"dsbfg kljhp2i4-019=o=-9"
    ^"w90382490u3'l'0 i39r83 "
    ^"flkskfsjfg,sdjfhgjksdjt"
    ^"04it093274u;lamv,sd[\\]"
    ^"[g[osdfbksm ksjoift8r7t", 
     "iJyantJWqZNsVD9FM465t7Q"
    ^"fzCHf1TLGaQMBXXFQM8UUzi"
    ^"AeRNMCfeMztFdPXjENS9pgp"
    ^"4CJ3j8M8GhWt6LBVN6e3BBM"
    ^"gBw3yoymvnB7HyGD6qSchZi"
    ^"K9jM437daWVWWVeg5UDD2Ac"
    ^"dhMnZyxCh7jF5VRNw5GBBXB"
    ^"AtHL4DcZGL1UHvzFMt2MGtW"
    ^"YtiLABjNiofWp92s21K2Div"
    ^"CTwRXKPJHZ");
  ] in 
  
  let all_encodings = [
    ("bitcoin"    , B58.bitcoin);
  ] in

  List.iter (fun (bin, exp)  -> 
    let bin    = Bytes.of_string bin in 
    List.iter (fun (name, alphabet) -> 
      let got = Bytes.to_string @@ B58.encode alphabet bin in 
      assert_string_eq got exp
    ) all_encodings; 
  ) test_cases; 
  ()
