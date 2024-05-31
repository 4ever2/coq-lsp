(************************************************************************)
(* Flèche => document manager: Document                                 *)
(* Copyright 2019 MINES ParisTech -- Dual License LGPL 2.1 / GPL3+      *)
(* Copyright 2019-2024 Inria      -- Dual License LGPL 2.1 / GPL3+      *)
(* Written by: Emilio J. Gallego Arias & coq-lsp contributors           *)
(************************************************************************)

open Cmdliner

val coqlib : String.t Term.t
val coqcorelib : String.t Term.t
val ocamlpath : String.t option Term.t
val rload_paths : Loadpath.vo_path List.t Term.t
val qload_paths : Loadpath.vo_path List.t Term.t
val debug : Bool.t Term.t
val bt : Bool.t Term.t
val ml_include_path : string list Term.t
val ri_from : (string option * string) list Term.t
val int_backend : Limits.backend option Term.t
val roots : string list Term.t
val coq_diags_level : int Term.t
