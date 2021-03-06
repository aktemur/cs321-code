(* A helper function to convert a token to a string *)
let toString tok =
  match tok with
  | INT i -> "INT(" ^ string_of_int i ^ ")"
  | BOOL b -> "BOOL(" ^ string_of_bool b ^ ")"
  | NAME x -> "NAME(\"" ^ x ^ "\")"
  | PLUS -> "PLUS"
  | STAR -> "STAR"
  | MINUS -> "MINUS"
  | SLASH -> "SLASH"
  | LET -> "LET"
  | REC -> "REC"
  | EQUALS -> "EQUALS"
  | IN -> "IN"
  | IF -> "IF"
  | THEN -> "THEN"
  | ELSE -> "ELSE"
  | ERROR c -> "ERROR('" ^ (charToString c) ^ "')"
  | EOF -> "EOF"
  | LESS -> "LESS"
  | LESSEQ -> "LESSEQ"
  | GREATEREQ -> "GREATEREQ"
  | LPAR -> "LPAR"
  | RPAR -> "RPAR"
  | COMMA -> "COMMA"
  | FST -> "FST"
  | SND -> "SND"
  | MATCH -> "MATCH"
  | WITH -> "WITH"
  | ARROW -> "ARROW"
  | NOT -> "NOT"
  | END -> "END"

(* consume: token -> token list -> token list
   Enforces that the given token list's head is the given token;
   returns the tail.
*)
let consume tok tokens =
  match tokens with
  | t::rest when t = tok -> rest
  | t::rest -> failwith ("I was expecting a " ^ (toString tok) ^
                         ", but I found a " ^ toString(t))

(* parseExp: token list -> (exp, token list) 
   Parses an exp out of the given token list,
   returns that exp together with the unconsumed tokens.
 *)
let rec parseExp tokens =
  parseLevel1Exp tokens

and parseLevel1Exp tokens =
  match tokens with
  | LET::rest -> parseLetIn tokens
  | IF::rest -> parseIfThenElse tokens
  | _ -> parseLevel1_5Exp tokens

and parseLetIn tokens =
  match tokens with
  | LET::NAME(x)::EQUALS::rest ->
     let (e1, tokens1) = parseExp rest in
     let tokens2 = consume IN tokens1 in
     let (e2, tokens3) = parseExp tokens2 in
     (LetIn(x, e1, e2), tokens3)
  | LET::REC::NAME(f)::rest ->
     let (params, tokens1) = parseParams rest in
     let tokens2 = consume EQUALS tokens1 in
     let (e1, tokens3) = parseExp tokens2 in
     let tokens4 = consume IN tokens3 in
     let (e2, tokens5) = parseExp tokens4 in
     (LetRec(f, params, e1, e2), tokens5)
  | _ -> failwith "Should not be possible."

and parseParams tokens =
  match tokens with
  | NAME(x)::rest ->
     let (ps, tokens1) = parseParams rest in
     (x::ps, tokens1)
  | _ -> ([], tokens)

and parseIfThenElse tokens =
  let rest = consume IF tokens in
  let (e1, tokens1) = parseExp rest in
  let tokens2 = consume THEN tokens1 in
  let (e2, tokens3) = parseExp tokens2 in
  let tokens4 = consume ELSE tokens3 in
  let (e3, tokens5) = parseExp tokens4 in
  (If(e1, e2, e3), tokens5)
  
and parseLevel1_5Exp tokens =
  let rec helper tokens e1 =
    match tokens with
    | LESS::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("<", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("<", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel2Exp (tok::rest)
                 in helper tokens2 (Binary("<", e1, e2))
       )
    | LESSEQ::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("<=", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("<=", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel2Exp (tok::rest)
                 in helper tokens2 (Binary("<=", e1, e2))
       )
    | GREATEREQ::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Unary("not", Binary("<", e1, e2)), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Unary("not", Binary("<", e1, e2)), tokens2)
        | t   -> let (e2, tokens2) = parseLevel2Exp (tok::rest)
                 in helper tokens2 (Unary("not", Binary("<", e1, e2)))
       )
    | _ -> (e1, tokens)
  in let (e1, tokens1) = parseLevel2Exp tokens in
     helper tokens1 e1

and parseLevel2Exp tokens =
  let rec helper tokens e1 =
    match tokens with
    | PLUS::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("+", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("+", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel3Exp (tok::rest)
                 in helper tokens2 (Binary("+", e1, e2))
       )
    | MINUS::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("-", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("-", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel3Exp (tok::rest)
                 in helper tokens2 (Binary("-", e1, e2))
       )
    | _ -> (e1, tokens)
  in let (e1, tokens1) = parseLevel3Exp tokens in
     helper tokens1 e1

and parseLevel3Exp tokens =
  let rec helper tokens e1 =
    match tokens with
    | STAR::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("*", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("*", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel4Exp (tok::rest)
                 in helper tokens2 (Binary("*", e1, e2))
       )
    | SLASH::tok::rest ->
       (match tok with
        | LET -> let (e2, tokens2) = parseLetIn (tok::rest)
                 in (Binary("/", e1, e2), tokens2)
        | IF  -> let (e2, tokens2) = parseIfThenElse (tok::rest)
                 in (Binary("/", e1, e2), tokens2)
        | t   -> let (e2, tokens2) = parseLevel4Exp (tok::rest)
                 in helper tokens2 (Binary("/", e1, e2))
       )
    | _ -> (e1, tokens)
  in let (e1, tokens1) = parseLevel4Exp tokens in
     helper tokens1 e1

and parseLevel4Exp tokens =
  match tokens with
  | INT i :: rest -> (CstI i, rest)
  | NAME x :: rest -> (Var x, rest)
  | BOOL b :: rest -> (CstB b, rest)
  | LPAR::rest ->
     let (e1, tokens1) = parseExp rest in
     (match tokens1 with
      | RPAR::rest1 -> (e1, rest1)
      | COMMA::rest1 ->
         let (e2, tokens2) = parseExp rest1 in
         let rest2 = consume RPAR tokens2 in
         (Binary(",", e1, e2), rest2)
     )
  | FST::LPAR::rest ->
     let (e, tokens1) = parseExp rest in
     let rest1 = consume RPAR tokens1 in
     (Unary("fst", e), rest1)     
  | SND::LPAR::rest ->
     let (e, tokens1) = parseExp rest in
     let rest1 = consume RPAR tokens1 in
     (Unary("snd", e), rest1)     
  | NOT::LPAR::rest ->
     let (e, tokens1) = parseExp rest in
     let rest1 = consume RPAR tokens1 in
     (Unary("not", e), rest1)
  | MATCH::rest ->
     let (e1, tokens1) = parseExp rest in
     (match tokens1 with
      | WITH::LPAR::NAME(x)::COMMA::NAME(y)::RPAR::ARROW::rest1 ->
         let (e2, tokens2) = parseExp rest1 in
         let rest2 = consume END tokens2 in
         (MatchPair(e1, x, y, e2), rest2)
      | _ -> failwith "Badly formed match expression."
     )
  | t::rest -> failwith ("Unsupported token: " ^ toString(t))

(* parseMain: token list -> exp *)
let parseMain tokens =
  let (e, tokens1) = parseExp tokens in
  let tokens2 = consume EOF tokens1 in
  if tokens2 = [] then e
  else failwith "Oops."

(* parse: string -> exp *)
let rec parse s =
  parseMain (scan s)
