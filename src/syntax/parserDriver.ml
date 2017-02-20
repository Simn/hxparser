open Ast
open Sedlex_menhir
open Printf
open Parser
open Token

module I = MenhirInterpreter
module M = MenhirLib.General

module Config = struct
	type debug_kind =
		| DStart
		| DShift
		| DReduce
		| DOffer
		| DInsert
		| DAccept
		| DReject

	type t = {
		mutable debug_flags : debug_kind list;
		mutable build_parse_tree : bool;
	}

	let default_config () = {
		debug_flags = [];
		build_parse_tree = false;
	}
end

type placed_token = (token * Lexing.position * Lexing.position)

type token_info = placed_token * tree list

and tree =
	| Node of string * tree list
	| Leaf of token_info
	| Flag of string

module State = struct
	type 'a t = {
		tree : tree list;
		recover_state : 'a t;
		checkpoint : 'a I.checkpoint;
		last_offer : token_info;
		last_shift : token_info;
	}

	let create checkpoint =
		let dummy_token = ((EOF,Lexing.dummy_pos,Lexing.dummy_pos),[]) in
		let rec state = {
			tree = [];
			checkpoint = checkpoint;
			last_offer = dummy_token;
			last_shift = dummy_token;
			recover_state = state;
		} in
		state

end

type 'a result =
	| Accept of 'a * tree list
	| Reject of string list * tree list

module TokenProvider = struct
	type t = {
		lexbuf: lexbuf;
		mutable inserted_tokens: token_info list;
		mutable leading: tree list;
		mutable trailing: token_info list;
		mutable branches : ((expr * bool) * bool) list;
	}

	let create lexbuf = {
		lexbuf = lexbuf;
		inserted_tokens = [];
		leading = [];
		trailing = [];
		branches = [];
	}

	let consume_token tp =
		tp.inserted_tokens <- List.tl tp.inserted_tokens

	let rec fetch_token tp in_dead_branch =
		let p1 = tp.lexbuf.pos in
		let tk = (if in_dead_branch then Lexer.preprocessor else Lexer.token) tp.lexbuf in
		let p2 = tp.lexbuf.pos in
		process_token tp in_dead_branch (tk,p1,p2)

	and process_token tp in_dead_branch (tk,p1,p2) =
		let add_leading trivia =
			tp.leading <- (Leaf (trivia,[])) :: tp.leading
		in
		let merge_leading tree =
			tp.leading <- tp.leading @ tree
		in
		let provide () =
			let token,trivia = fetch_token tp false in
			merge_leading trivia;
			token
		in
		let not_expr e = EUnop(Not,Prefix,e),snd e in
		match tk with
		| (WHITESPACE _ | NEWLINE _ | COMMENTLINE _ | COMMENT _) ->
			add_leading (tk,p1,p2);
			fetch_token tp in_dead_branch
		| SHARPERROR ->
			add_leading (tk,p1,p2);
			let message_checkpoint = Parser.Incremental.sharp_error_message tp.lexbuf.pos in
			let _ = I.loop provide message_checkpoint in
			fetch_token tp in_dead_branch;
		| SHARPLINE ->
			add_leading (tk,p1,p2);
			let line_number_checkpoint = Parser.Incremental.sharp_line_number tp.lexbuf.pos in
			let _ = I.loop provide line_number_checkpoint in
			fetch_token tp in_dead_branch;
		| SHARPIF ->
			add_leading (tk,p1,p2);
			let cond_checkpoint = Parser.Incremental.sharp_condition tp.lexbuf.pos in
			let cond = I.loop provide cond_checkpoint in
			tp.branches <- ((cond,in_dead_branch),in_dead_branch) :: tp.branches;
			fetch_token tp in_dead_branch;
		| SHARPELSEIF ->
			add_leading (tk,p1,p2);
			let cond_checkpoint = Parser.Incremental.sharp_condition tp.lexbuf.pos in
			let cond = I.loop provide cond_checkpoint in
			begin match tp.branches with
			| ((cond2,dead_branch),dead) :: branches ->
				tp.branches <- ((cond,false),dead) :: branches;
				fetch_token tp (dead || not dead_branch)
			| [] -> assert false
			end
		| SHARPELSE ->
			begin match tp.branches with
			| ((cond,dead_branch),dead) :: branches ->
				tp.branches <- ((not_expr cond,not dead_branch),dead) :: branches;
				fetch_token tp (dead || not dead_branch)
			| [] -> assert false
			end
		| SHARPEND ->
			begin match tp.branches with
			| (_,dead) :: branches ->
				tp.branches <- branches;
				fetch_token tp dead
			| [] -> assert false
			end
		| _ ->
			let leading = List.rev tp.leading in
			tp.leading <- [];
			let token,leading = match tk with
				| SEMICOLON ->
					begin match peek_token tp in_dead_branch with
						| ((ELSE,_,_) as token),leading2 ->
							let leading = (Leaf ((tk,p1,p2),((Flag "skipped" :: leading)))) :: leading2 in
							consume_token tp;
							token,leading
						| _ -> (tk,p1,p2),leading
					end
				| _ -> (tk,p1,p2),leading
			in
			token,leading

	and peek_token tp in_dead_branch =
		let token,trivia = fetch_token tp in_dead_branch in
		tp.inserted_tokens <- (token,trivia) :: tp.inserted_tokens;
		token,trivia

	let insert_token tp token =
		tp.inserted_tokens <- token :: tp.inserted_tokens

	let next_token tp in_dead_branch = match tp.inserted_tokens with
		| (token,trivia) :: tokens when not in_dead_branch ->
			tp.inserted_tokens <- tokens;
			token,trivia
		| _ ->
			fetch_token tp in_dead_branch
end

module Context = struct
	type t = {
		token_provider : TokenProvider.t;
		config : Config.t;
	}

	let create config lexbuf = {
		token_provider = TokenProvider.create lexbuf;
		config = config;
	}
end

open State
open Context
open Config

let has_debug ctx flag = List.mem flag ctx.config.debug_flags

let print_position = Pos.Position.print

let print_token (token,p1,p2) =
	 Printf.sprintf "%s (%s - %s)" (s_token token) (print_position p1) (print_position p2)

let rec print_tree tabs t = match t with
	| Leaf(token,trivia) -> print_token token
	| Node(_,[]) -> ""
	| Node(name,[t1]) -> (match name with "" -> "" | _ -> name ^ ": ") ^ (print_tree tabs t1)
	| Node(name,tl) ->
		begin match List.rev tl with
			| Node(name2, tl2) :: tl when name = name2 -> print_tree tabs (Node(name,(List.rev tl) @ tl2))
			| _ -> Printf.sprintf "%s%s" (match name with "" -> "" | _ -> name ^ ":") (String.concat "" (List.map (fun t -> match print_tree (tabs ^ "  ") t with "" -> "" | s -> "\n" ^ tabs ^ s) tl))
		end
	| Flag name -> name

let print_tree_list tree =
	String.concat "\n" (List.map (fun t -> print_tree "" t) tree)

let offer ctx state token trivia =
	if has_debug ctx DOffer then begin
		print_endline (Printf.sprintf "[OFFER ] %s" (print_token token));
	end;
	let checkpoint = I.offer state.checkpoint token in
	let state = {state with last_offer = (token,trivia); checkpoint = checkpoint; recover_state = state} in
	state

let rec input_needed : 'a . Context.t -> 'a State.t -> 'a result = fun ctx state ->
	let token,trivia = TokenProvider.next_token ctx.token_provider false in
	let state = offer ctx state token trivia in
	loop ctx state

and loop : 'a . Context.t -> 'a State.t -> 'a result =
	fun ctx state -> match state.checkpoint with
	| I.Accepted v ->
		if has_debug ctx DAccept then begin
			if ctx.config.build_parse_tree then
				print_endline (Printf.sprintf "[ACCEPT] %s" (print_tree_list state.tree))
			else
				print_endline "[ACCEPT]"
		end;
		Accept(v,state.tree)
	| I.InputNeeded _ ->
		input_needed ctx state
	| I.Shifting _ ->
		let token = state.last_offer in
		if has_debug ctx DShift then begin
			let ((tk,_,_),_) = token in print_endline (Printf.sprintf "[SHIFT ] %s" (s_token tk));
		end;
		let state = {state with checkpoint = I.resume state.checkpoint; last_shift = token} in
		let state =
			if ctx.config.build_parse_tree then {state with tree = Leaf token :: state.tree}
			else state
		in
		loop ctx state
	| I.AboutToReduce(_,production) ->
		if has_debug ctx DReduce then begin match I.rhs production with
			| [] -> ()
			| rhs -> print_endline (Printf.sprintf "[REDUCE] %s <- %s" (s_xsymbol (I.lhs production)) (String.concat " " (List.map s_xsymbol rhs)));
		end;
		let state = if ctx.config.build_parse_tree then begin
			let l = List.length (I.rhs production) in
			let _,nodes1,nodes2 = List.fold_left (fun (i,l1,l2) x -> if i < l then (i + 1,x :: l1,l2) else (i + 1,l1,x :: l2)) (0,[],[]) state.tree in
			let nodes2 = List.rev nodes2 in
			{state with tree = ((Node(s_xsymbol (I.lhs production),nodes1)) :: nodes2)}
		end else
			state
		in
		let state = {state with checkpoint = I.resume state.checkpoint} in
		loop ctx state
	| I.HandlingError env ->
		(*print_endline (Printf.sprintf "[ERROR ] Token: %s, Last shift: %s" (print_token (fst state.last_offer)) (print_token (fst state.last_shift)));*)
		let insert token p =
			if has_debug ctx DInsert then begin
				print_endline (Printf.sprintf "[INSERT] %s" (s_token token));
			end;
			let last_offer = state.last_offer in
			let state = offer ctx state.recover_state (token,p,p) [Flag "implicit"] in
			TokenProvider.insert_token ctx.token_provider last_offer;
			loop ctx state
		in
		begin match state.last_shift with
			| ((BRCLOSE,p1,_),_) when I.acceptable state.recover_state.checkpoint SEMICOLON p1 -> insert SEMICOLON p1
			| _ ->
				(*let so = match Lazy.force (I.stack env) with
					| M.Cons(I.Element(lrstate,_,_,_),_) -> (try Some (SyntaxErrors.message (I.number lrstate)) with Not_found -> None)
					| _ -> None
				in
				begin match so with
					| Some s -> print_endline s;
					| None -> ()
				end;*)
				loop ctx {state with checkpoint = I.resume state.checkpoint};
		end;
	| I.Rejected ->
		let messages = ref [] in
		if has_debug ctx DReject then begin
			if ctx.config.build_parse_tree then begin
				messages := (Printf.sprintf "[REJECT] %s" (print_tree_list state.tree)) :: !messages;
		end;
			messages := (Printf.sprintf "[REJECT] %s" (print_token (fst state.last_offer))) :: !messages;
		end else
			messages := "[REJECT]" :: !messages;
		Reject(!messages,state.tree)

and start : 'a . Context.t -> 'a I.checkpoint -> 'a result = fun ctx checkpoint ->
	if has_debug ctx DStart then begin
		print_endline "[START ]"
	end;
	let state = State.create checkpoint in
	loop ctx state

and run : 'a . Context.t -> 'a I.checkpoint -> 'a result = fun ctx checkpoint ->
	start ctx checkpoint