(* A helper function to convert a token to a string *)
let toString tok =
  match tok with
  | NAME x -> "NAME(\"" ^ x ^ "\")"
  | LAMBDA -> "LAMBDA"
  | DOT -> "DOT"
  | LPAR -> "LPAR"
  | RPAR -> "RPAR"
  | ERROR c -> "ERROR('" ^ (charToString c) ^ "')"
  | EOF -> "EOF"

(* consume: token -> token list -> token list
   Enforces that the given token list's head is the given token;
   returns the tail.
*)
let consume tok tokens =
  match tokens with
  | [] -> failwith ("I was expecting to see a " ^ (toString tok))
  | t::rest when t = tok -> rest
  | t::rest -> failwith ("I was expecting a " ^ (toString tok) ^
                         ", but I found a " ^ toString(t))

(* parseExp: token list -> (exp, token list) 
   Parses an exp out of the given token list,
   returns that exp together with the unconsumed tokens.
 *)
let rec parseExp tokens =
  parseLevel1ExpOrOther parseLevel2Exp tokens

and parseLevel1ExpOrOther otherParseFun tokens =
  match tokens with
  | LAMBDA::rest -> let (e, tokens2) = parseLambda tokens
                    in (e, tokens2)
  | _         -> let (e, tokens2) = otherParseFun tokens
                 in (e, tokens2)

and parseLambda tokens =
  match tokens with
  | LAMBDA::NAME(x)::DOT::rest ->
     let (e1, tokens1) = parseExp rest in
     (Lambda(x, e1), tokens1)
  | _ -> failwith "Badly formed lambda expression"  

and parseLevel2Exp tokens =
  let rightHandSideExists token =
    match token with
    (* tokens that are the beginning of an atom *)
    | NAME _ | LPAR -> true
    (* other tokens that may start the right-hand-side exp *)
    | LAMBDA -> true
    | _ -> false
  in
  let rec helper tokens e1 =
    match tokens with
    | tok::rest when rightHandSideExists(tok) ->
       let (e2, tokens2) = parseLevel1ExpOrOther parseAtomExp tokens
       in helper tokens2 (App(e1, e2))
    | _ ->
       (e1, tokens)
  in let (e1, tokens1) = parseAtomExp tokens in
     helper tokens1 e1

and parseAtomExp tokens =
  match tokens with
  | NAME x :: rest -> (Var x, rest)
  | LPAR::rest ->
     let (e1, tokens1) = parseExp rest in
     let rest1 = consume RPAR tokens1 in
     (e1, rest1)
  | t::rest -> failwith ("Unsupported token: " ^ toString(t))
  | [] -> failwith "No more tokens???"

(* parseMain: token list -> exp *)
let parseMain tokens =
  let (e, tokens1) = parseExp tokens in
  let tokens2 = consume EOF tokens1 in
  if tokens2 = [] then e
  else failwith "Oops."

let encodings = [
    ("0", "(lambda f. lambda x.x)");
    ("1", "(lambda f. lambda x.f x)");
    ("2", "(lambda f. lambda x.f(f x))");
    ("3", "(lambda f. lambda x.f(f(f x)))");
    ("succ", "(lambda n. lambda f. lambda x.f(n f x))");
    ("pred", "(lambda n.lambda f. lambda x.n(lambda g.lambda h.h(g f))(lambda u.x)(lambda u.u))"); (* This is hard. It's normal if your brain hurts. Mine does. *)
    ("add", "(lambda m. lambda n. lambda f. lambda x. m f (n f x))");
    ("mult", "(lambda m. lambda n. lambda f. lambda x. m (n f) x)");
    ("true", "(lambda a. lambda b. a)");
    ("false", "(lambda a. lambda b. b)");
    ("if", "(lambda c. lambda t. lambda e. c t e)");
    ("isZero", "(lambda n. n (lambda x.(lambda a. lambda b. b)) (lambda a. lambda b. a))");
    ("Y", "(lambda h.(lambda x.(lambda a. h(x x)a)) (lambda x.(lambda a.h(x x)a)))"); (* See PLC page 85 *)
  ];;

(* parse: string -> exp *)
let rec parse s =
  let purify s =
    List.fold_left (fun acc (r, enc) -> Str.global_replace (Str.regexp r) enc acc) s encodings
  in parseMain (scan (purify s))
