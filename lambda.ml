
(*
    ATALLA Salim - 191350P
    NISO Aram    - 184256D
*)

(*
    Le type lambda_expr qui représente une expression du lambda-calcul.
    Il contient trois constructeurs de données :
        • Var qui représente une variable
        • Abs qui représente une abstraction
        • App qui représente l'application d'une expression à une autre
*)
(* Type pour représenter une expression lambda *)
type lambda_expr =
    | Var of string
    | Abs of string * lambda_expr
    | App of lambda_expr * lambda_expr
;;



(*
    Le zéro de Church (zero)
    La fonction successeur (succ)
    La fonction d'addition (addi)
    Les valeurs booléennes vrai et faux (true_val et false_val)
    Les opérations booléennes not_op, and_op et or_op
*)
(* Définition des nombres de Church *) 
let zero = Abs ("f", Abs ("x", Var "x"));;
let succ = Abs ("n", Abs ("f", Abs ("x", App (Var "f", App (App (Var "n", Var "f"), Var "x")))));;
let addi = Abs ("m", Abs ("n", Abs ("f", Abs ("x", App (App (Var "m", Var "f"), App (App (Var "n", Var "f"), Var "x"))))));;

(* Définition des valeurs booléennes et des opérations booléennes *)
let true_val = Abs ("x", Abs ("y", Var "x"));;
let false_val = Abs ("x", Abs ("y", Var "y"));;
let not_op = Abs ("b", App (App (Var "b", false_val), true_val));;
let and_op = Abs ("b", Abs ("c", App (App (Var "b", Var "c"), false_val)));;
let or_op = Abs ("b", Abs ("c", App (App (Var "b", true_val), Var "c")));;



(*
    La fonction alpha_conversion prend en entrée une expression expr, une variable old_var 
    à remplacer par une variable new_var et retourne l'expression obtenue.
    Cette fonction parcourt récursivement l'expression et remplace toutes les occurrences de old_var par new_var.
*)
let rec alpha_conversion expr old_var new_var =
    match expr with
    | Var v ->
        if v = old_var then Var new_var else Var v
    | Abs (v, e) ->
        if v = old_var then Abs (new_var, alpha_conversion e old_var new_var)
        else Abs (v, alpha_conversion e old_var new_var)
    | App (e1, e2) ->
        App (alpha_conversion e1 old_var new_var, alpha_conversion e2 old_var new_var)
;;       



(*
    La fonction free_vars prend en entrée une expression expr 
    et retourne la liste de toutes les variables libres de l'expression. 
    Cette fonction utilise la récursion pour parcourir l'expression et ajouter les variables libres à une liste.
*)
let rec free_vars expr =
    match expr with
    | Var v -> [v]
    | Abs (v, e) -> List.filter (fun x -> x <> v) (free_vars e)
    | App (e1, e2) -> List.sort_uniq compare (free_vars e1 @ free_vars e2)
;;



(*
    La fonction fresh_var retourne une nouvelle variable fraîche,
    qui n'est pas encore utilisée dans l'expression.
    Cette fonction utilise un compteur pour générer des noms de variables uniques.
*)
let fresh_var =
    let c = ref 0 in
    fun () ->
        let v = "x" ^ string_of_int !c in
        incr c;
        v
;;



(*
    La fonction substitute prend en entrée une expression expr, une variable var et une nouvelle expression new_expr, 
    et retourne l'expression obtenue en substituant toutes les occurrences de var dans expr par new_expr. 
    Cette fonction utilise la récursion pour parcourir l'expression et effectuer la substitution.
*)
let rec substitute expr var new_expr =
    match expr with
    | Var v ->
        if v = var then new_expr else Var v
    | App (e1, e2) ->
        App (substitute e1 var new_expr, substitute e2 var new_expr)
    | Abs (v, e) ->
        if v = var then Abs (v, e)
        else if not (free_vars new_expr |> List.mem v) then Abs (v, substitute e var new_expr)
        else let v' = fresh_var () in
            let e' = alpha_conversion e v v' in
            let new_e = substitute e' var new_expr in
            Abs (v', new_e) 
;;



(*
    La fonction beta_reduction prend en entrée une expression expr
    et effectue une réduction β. Elle parcourt récursivement l'expression
    et applique les règles de réduction β pour transformer l'expression en une forme normale.
*)
let rec beta_reduction expr =
    match expr with
    | App (Abs (v, e1), e2) -> substitute e1 v e2
    | App (e1, e2) ->
        let e1' = beta_reduction e1 in
        let e2' = beta_reduction e2 in
        App (e1', e2')
    | Abs (v, e) ->
        let e' = beta_reduction e in
        Abs (v, e')
    | Var _ -> expr
;;





(*******************************************)
(********** Fonctions d'afficahge **********)
(*******************************************)

(*
    La fonction 'print_expression' prend en paramètre une expression lambda et l'affiche sous forme de chaîne de caractères.
    L'affichage suit la syntaxe usuelle des expressions lambda, avec des parenthèses autour des sous-expressions
    et le charactère '\' pour représenter la lambda-abstraction.
*)
let rec print_expression expr =
    match expr with
    | Var v -> print_string v
    | Abs (v, e) ->
        print_char '\\';
        print_string v;
        print_string " . ";
        print_expression e
    | App (e1, e2) ->
        print_char '(';
        print_expression e1;
        print_char ' ';
        print_expression e2;
        print_char ')'
;;



(*
    La fonction 'print_expression_pair' est une fonction qui prend en entrée deux expressions lambda et les affiche côte à côte,
    la première expression étant la version initiale et la deuxième expression étant la version transformée.
*)
let print_expression_pair expr1 expr2 =
    print_string "Avant : ";
    print_expression expr1;
    print_newline ();
    print_string "Après : ";
    print_expression expr2;
    print_newline ();
    print_newline ()
;;





(*******************************************)
(****************** Tests ******************)
(*******************************************)

(* Tests pour alpha_conversion *)
print_newline ();;
print_newline ();;
print_string "======================================= ";;
print_newline ();;
print_string "===== Tests pour alpha_conversion ===== ";;
print_newline ();;
print_string "======================================= ";;
print_newline ();;
print_newline ();;


let expr = Abs ("x", App (Var "x", Var "y"));;
let new_expr = alpha_conversion expr "y" "z";;
(* 
    Output attendu :
        Abs ("x", App (Var "x", Var "z")) 
        \x . (x z)
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = Abs ("x", App (Var "y", Var "x"));;
let new_expr = alpha_conversion expr "y" "z";;
(* 
    Output attendu : 
        Abs ("x", App (Var "z", Var "x")) 
        \x . (z x)
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = Abs ("y", App (Abs ("x", Var "y"), Var "y"));;
let new_expr = alpha_conversion expr "y" "z";;
(* 
    Output attendu : 
        Abs ("x", App (Var "z", Var "z")) 
        \z . (\x . z z)
*)
new_expr;;
print_expression_pair expr new_expr;;


(************************************************)


(* Tests pour beta_reduction *)
print_newline ();;
print_newline ();;
print_string "===================================== ";;
print_newline ();;
print_string "===== Tests pour beta_reduction ===== ";;
print_newline ();;
print_string "===================================== ";;
print_newline ();;
print_newline ();;


let expr = App (Abs ("x", Var "x"), Var "y");;
let new_expr = beta_reduction expr;;
(* 
    Output attendu : 
        Var "y" 
        y
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = App (Abs ("x", App (Var "x", Var "y")), Var "z");;
let new_expr = beta_reduction expr;;
(* 
    Output attendu : 
        App (Var "z", Var "y") 
        (z y)
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = App (Abs ("x", App (Var "y", Var "x")), Var "z");;
let new_expr = beta_reduction expr;;
(* 
    Output attendu : 
        App (Var "y", Var "z")
        (y z)
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = App (Abs ("x", App (Var "y", Var "x")), Abs ("z", Var "z"));;
let new_expr = beta_reduction expr;;

(* 
    Output attendu : 
        App (Var "y", Abs ("z", Var "z")) 
        (y \z . z)
*)
new_expr;;
print_expression_pair expr new_expr;;


let expr = App (Abs ("x", App (Var "x", Var "x")), Abs ("y", Var "y"));;
let new_expr = beta_reduction expr;;
(* 
    Output attendu :
        App (Abs ("y", Var "y"), Abs ("y", Var "y")) 
        (\y . y \y . y)
*)
new_expr;;
print_expression_pair expr new_expr;;

