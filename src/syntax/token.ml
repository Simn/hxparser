open Parser

let s_token tk = match tk with
	| COLON -> ":"
	| SEMICOLON -> ";"
	| COMMA -> ","
	| DOT -> "."
	| PACKAGE -> "package"
	| IDENT s -> s
	| DOLLAR_IDENT s -> "$" ^ s
	| DOT_IDENT s -> "." ^ s
	| STRING s -> "\"" ^ s ^ "\""
	| STRING2 s -> "'" ^ s ^ "'"
	| COMMENT s -> "/*" ^ s ^ "*/"
	| REGEX(s1,s2) -> "~/" ^ s1 ^ "/" ^ s2
	| COMMENTLINE s -> "//" ^ s
	| METADATA s -> "@" ^ s
	| METADATA_OPEN s -> "@" ^ s ^ "("
	| INT s -> s
	| FLOAT s -> s
	| SHARPIF -> "#if"
	| SHARPELSE -> "#else"
	| SHARPELSEIF -> "#elseif"
	| SHARPEND -> "#end"
	| SHARPERROR -> "#error"
	| SHARPLINE -> "#line"
	| BRCLOSE -> "}"
	| BROPEN -> "{"
	| POPEN -> "("
	| PCLOSE -> ")"
	| BKOPEN -> "["
	| BKCLOSE -> "]"
	| QUESTIONMARK -> "?"
	| ASSIGN -> "="
	| PLUS -> "+"
	| LT -> "<"
	| GT -> ">"
	| ASSIGNMOD -> "%="
	| ASSIGNAND -> "&="
	| ASSIGNOR -> "|="
	| ASSIGNXOR -> "^="
	| ASSIGNPLUS -> "+="
	| ASSIGNMINUS -> "-="
	| ASSIGNSTAR -> "*="
	| ASSIGNSLASH -> "/="
	| ASSIGNSHL -> "<<="
	| ASSIGNBOOLOR -> "||="
	| ASSIGNBOOLAND -> "&&="
	| INCREMENT -> "++"
	| DECREMENT -> "--"
	| TILDE -> "~"
	| XOR -> "^"
	| STAR -> "*"
	| SLASH -> "/"
	| SHL -> "<<"
	| PERCENT -> "%"
	| OR -> "|"
	| NOTEQUALS -> "!="
	| MINUS -> "-"
	| LTE -> "<="
	| INTERVAL -> "..."
	| EXCLAMATION -> "!"
	| EQUALS -> "=="
	| DOUBLEARROW -> "=>"
	| BOOLOR -> "||"
	| BOOLAND -> "&&"
	| ARROW -> "->"
	| AND -> "&"
	| FUNCTION -> "function"
	| CLASS -> "class"
	| INTERFACE -> "interface"
	| EXTENDS -> "extends"
	| IMPLEMENTS -> "implements"
	| VAR -> "var"
	| WHILE -> "while"
	| USING -> "using"
	| UNTYPED -> "untyped"
	| TYPEDEF -> "typedef"
	| TRY -> "try"
	| TRUE -> "true"
	| THROW -> "throw"
	| THIS -> "this"
	| SWITCH -> "switch"
	| STATIC -> "static"
	| RETURN -> "return"
	| PUBLIC -> "public"
	| PRIVATE -> "private"
	| OVERRIDE -> "override"
	| NULL -> "null"
	| NEW -> "new"
	| MACRO -> "macro"
	| INLINE -> "inline"
	| IN -> "in"
	| IMPORT -> "import"
	| IF -> "if"
	| FOR -> "for"
	| FALSE -> "false"
	| EXTERN -> "extern"
	| ENUM -> "enum"
	| ELSE -> "else"
	| DYNAMIC -> "dynamic"
	| DOTSTAR -> ".*"
	| DO -> "do"
	| DEFAULT -> "default"
	| CONTINUE -> "continue"
	| CATCH -> "catch"
	| CAST -> "cast"
	| CASE -> "case"
	| BREAK -> "break"
	| ABSTRACT -> "abstract"
	| FROM -> "from"
	| TO -> "to"
	| AS -> "as"
	| IS -> "is"
	| EOF -> "<eof>"
	| WHITESPACE s -> s
	| NEWLINE s -> s

let s_xsymbol x =
	let open MenhirInterpreter in
	match x with
	| X (T x) ->
		begin match x with
		| T_COLON -> ":"
		| T_SEMICOLON -> ";"
		| T_COMMA -> ","
		| T_DOT -> "."
		| T_PACKAGE -> "package"
		| T_IDENT -> "IDENT"
		| T_DOT_IDENT -> "DOT_IDENT"
		| T_DOLLAR_IDENT -> "DOLLAR_IDENT"
		| T_STRING -> "STRING"
		| T_STRING2 -> "STRING2"
		| T_METADATA -> "METADATA"
		| T_METADATA_OPEN -> "METADATA_OPEN"
		| T_INT -> "INT"
		| T_FLOAT -> "FLOAT"
		| T_SHARPIF -> "#if"
		| T_SHARPELSE -> "#else"
		| T_SHARPELSEIF -> "#elseif"
		| T_SHARPEND -> "#end"
		| T_SHARPERROR -> "#error"
		| T_SHARPLINE -> "#line"
		| T_BRCLOSE -> "}"
		| T_BROPEN -> "{"
		| T_POPEN -> "("
		| T_PCLOSE -> ")"
		| T_BKOPEN -> "["
		| T_BKCLOSE -> "]"
		| T_QUESTIONMARK -> "?"
		| T_ASSIGN -> "="
		| T_PLUS -> "+"
		| T_LT -> "<"
		| T_GT -> ">"
		| T_ASSIGNMOD -> "%="
		| T_ASSIGNAND -> "&="
		| T_ASSIGNOR -> "|="
		| T_ASSIGNXOR -> "^="
		| T_ASSIGNPLUS -> "+="
		| T_ASSIGNMINUS -> "-="
		| T_ASSIGNSTAR -> "*="
		| T_ASSIGNSLASH -> "/="
		| T_ASSIGNSHL -> "<<="
		| T_ASSIGNBOOLOR -> "||="
		| T_ASSIGNBOOLAND -> "&&="
		| T_INCREMENT -> "++"
		| T_DECREMENT -> "--"
		| T_TILDE -> "~"
		| T_XOR -> "^"
		| T_STAR -> "*"
		| T_SLASH -> "/"
		| T_SHL -> "<<"
		| T_PERCENT -> "%"
		| T_OR -> "|"
		| T_NOTEQUALS -> "!="
		| T_MINUS -> "-"
		| T_LTE -> "<="
		| T_INTERVAL -> "..."
		| T_EXCLAMATION -> "!"
		| T_EQUALS -> "=="
		| T_DOUBLEARROW -> "=>"
		| T_BOOLOR -> "||"
		| T_BOOLAND -> "&&"
		| T_ARROW -> "->"
		| T_AND -> "&"
		| T_FUNCTION -> "function"
		| T_CLASS -> "class"
		| T_INTERFACE -> "interface"
		| T_EXTENDS -> "extends"
		| T_IMPLEMENTS -> "implements"
		| T_VAR -> "var"
		| T_EOF -> "#eof"
		| T_WHITESPACE -> "#whitespace"
		| T_NEWLINE -> "#newline"
		| T_COMMENT -> "#comment"
		| T_REGEX -> "#regex"
		| T_COMMENTLINE -> "#commentline"
		| T_WHILE -> "while"
		| T_USING -> "using"
		| T_UNTYPED -> "untyped"
		| T_TYPEDEF -> "typedef"
		| T_TRY -> "try"
		| T_TRUE -> "true"
		| T_THROW -> "throw"
		| T_THIS -> "this"
		| T_SWITCH -> "switch"
		| T_STATIC -> "static"
		| T_RETURN -> "return"
		| T_PUBLIC -> "public"
		| T_PRIVATE -> "private"
		| T_OVERRIDE -> "override"
		| T_NULL -> "null"
		| T_NEW -> "new"
		| T_MACRO -> "macro"
		| T_INLINE -> "inline"
		| T_IN -> "in"
		| T_IMPORT -> "import"
		| T_IF -> "if"
		| T_FOR -> "for"
		| T_FALSE -> "false"
		| T_EXTERN -> "extern"
		| T_ENUM -> "enum"
		| T_ELSE -> "else"
		| T_DYNAMIC -> "dynamic"
		| T_DOTSTAR -> ".*"
		| T_DO -> "do"
		| T_DEFAULT -> "default"
		| T_CONTINUE -> "continue"
		| T_CATCH -> "catch"
		| T_CAST -> "cast"
		| T_CASE -> "case"
		| T_BREAK -> "break"
		| T_ABSTRACT -> "abstract"
		| T_FROM -> "from"
		| T_TO -> "to"
		| T_AS -> "as"
		| T_IS -> "is"
		| T_error -> "#error"
		end
	| X (N x) ->
		begin match x with
		| N_file -> "file"
		| N_package -> "package"
		| N_decl -> "decl"
		| N_class_field -> "class_field"
		| N_ident -> "ident"
		| N_const -> "const"
		| N_class_decl -> "class_decl"
		| N_expr_open -> "expr"
		| N_expr_closed -> "expr"
		| N_block_element -> "block_element"
		| N_object_field -> "object_field"
		| N_string -> "string"
		| N_expr_only -> "expr_only"
		| N_sharp_condition -> "sharp_condition"
		| N_sharp_condition_any -> "sharp_condition"
		| N_sharp_condition_both -> "sharp_condition"
		| N_sharp_error_message -> "sharp_error_message"
		| N_sharp_line_number -> "sharp_line_number"
		| N_documentation -> "documentation"
		| N_annotations -> "annotations"
		| N_path -> "path"
		| N_type_path_parameters -> "type_path_parameters"
		| N_type_path_parameter -> "type_path_parameter"
		| N_type_path -> "type_path"
		| N_class_relations -> "class_relations"
		| N_call_args -> "call_args"
		| N_type_hint -> "type_hint"
		| N_dollar_ident -> "dollar_ident"
		| N_complex_type -> "complex_type"
		| N_anonymous_type_field -> "anonymous_type_field"
		| N_var_declaration -> "var_declaration"
		| N_assignment -> "assignment"
		| N_structural_extension -> "structural_extension"
		| N_underlying_type -> "underlying_type"
		| N_type_decl_parameters -> "type_decl_parameters"
		| N_type_decl_parameter -> "type_decl_parameter"
		| N_property_ident -> "property_ident"
		| N_modifier -> "modifier"
		| N_import_mode -> "import_mode"
		| N_import -> "import"
		| N_guard -> "guard"
		| N_function_name -> "function_name"
		| N_function_argument -> "function_argument"
		| N_function_arguments -> "function_arguments"
		| N_constraints -> "constraints"
		| N_common_flags -> "common_flags"
		| N_keyword_ident -> "keyword_ident"
		| N_catch -> "catch"
		| N_case -> "case"
		| N_anonymous_type_fields -> "anonymous_type_fields"
		| N_abstract_relations -> "abstract relations"
		| N_func -> "function"
		| N_enum_field_args -> "enum_field_args"
		| N_enum_field_arg -> "enum_field_arg"
		| N_enum_field -> "enum_field"
		| N_macro_expr -> "macro_expr"
		| N_class_or_interface -> "class_or_interface"
		| N_literal -> "literal"
		| N_object_field_name -> "object_field_name"
		| N_else_expr -> "else_expr"
		| N_field_expr -> "field_expr"
		| N_block_expr -> "block_expr"
		| N_metadata -> "metadata"
		| N_expr -> "expr"
		| N_dot_ident -> "dot_ident"
		(* options *)
		| N_option_package_ -> ""
		| N_option_type_hint_ -> ""
		| N_option_assignment_ -> ""
		| N_option_underlying_type_ -> ""
		| N_option_guard_ -> ""
		| N_option_QUESTIONMARK_ -> ""
		| N_option_dollar_ident_ -> ""
		| N_option_SEMICOLON_ -> ""
		| N_option_pos_dollar_ident__ -> ""
		| N_lpoption_type_hint_ -> ""
		| N_lpoption_assignment_ -> ""
		| N_lpoption_else_expr_ -> ""
		| N_loption_path_ -> ""
		| N_loption_separated_nonempty_list_COMMA_expr__ -> ""
		| N_loption_separated_nonempty_list_COMMA_function_argument__ -> ""
		(* lists *)
		| N_path_with_pos -> "path"
		| N_array_elements -> "elements"
		| N_array_elements_next -> "elements"
		| N_anonymous_type_field_next -> "fields"
		| N_object_fields -> "fields"
		| N_object_fields_next -> "fields"
		| N_var_declarations -> "vars"
		| N_var_declarations_next -> "vars"
		| N_lplist_pos_dot_ident__ -> "path"
		| N_lplist_dot_ident_ -> "path"
		| N_lplist_catch_ -> "catches"
		| N_list_modifier_ -> "modifiers"
		| N_list_common_flags_ -> "flags"
		| N_list_case_ -> "cases"
		| N_list_block_element_ -> "elements"
		| N_list_abstract_relations_ -> "relations"
		| N_list_decl_ -> "decls"
		| N_list_class_field_ -> "fields"
		| N_list_metadata_ -> "metadata"
		| N_list_class_relations_ -> "relations"
		| N_nonempty_list_structural_extension_ -> "extensions"
		| N_nonempty_list_block_element_ -> "elements"
		| N_nonempty_list_class_field_ -> "fields"
		| N_separated_nonempty_list_COMMA_expr_ -> "exprs"
		| N_separated_nonempty_list_COMMA_type_path_parameter_ -> "params"
		| N_separated_nonempty_list_COMMA_type_decl_parameter_ -> "params"
		| N_separated_nonempty_list_COMMA_function_argument_ -> "args"
		| N_separated_nonempty_list_COMMA_complex_type_ -> "types"
		| N_separated_nonempty_list_COMMA_enum_field_arg_ -> "args"
		| N_loption_separated_nonempty_list_COMMA_enum_field_arg__ -> "args"
		| N_list_enum_field_ -> "fields"
		end
