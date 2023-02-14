(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(************************************************************************)
(* Coq Language Server Protocol                                         *)
(* Copyright 2019 MINES ParisTech -- LGPL 2.1+                          *)
(* Copyright 2019-2023 Inria -- LGPL 2.1+                               *)
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)

open Lsp.JFleche

let mk_completion ~label ?insertText ?labelDetails ?textEdit ?commitCharacters
    () =
  CompletionData.(
    to_yojson { label; insertText; labelDetails; textEdit; commitCharacters })

let build_doc_idents ~doc : Yojson.Safe.t list =
  let f _loc id = mk_completion ~label:Names.Id.(to_string id) () in
  let ast = Fleche.Doc.asts doc in
  let clist = Coq.Ast.grab_definitions f ast in
  clist

let mk_completion_list ~incomplete ~items : Yojson.Safe.t =
  `Assoc [ ("isIncomplete", `Bool incomplete); ("items", `List items) ]

let mk_edit (line, character) newText =
  let open Lang in
  let insert =
    Range.
      { start = { Point.line; character = character - 1; offset = -1 }
      ; end_ = { Point.line; character; offset = -1 }
      }
  in
  let replace = insert in
  TextEditReplace.{ insert; replace; newText }

let unicode_commit_chars =
  [ " "; "("; ")"; ","; "."; "-" ]
  @ [ "0"; "1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9" ]

let mk_unicode_completion_item point (label, newText) =
  let labelDetails = LabelDetails.{ detail = " ← " ^ newText } in
  let textEdit = mk_edit point newText in
  let commitCharacters = unicode_commit_chars in
  mk_completion ~label ~labelDetails ~textEdit ~commitCharacters ()

let unicode_list point : Yojson.Safe.t list =
  let ulist =
    match !Fleche.Config.v.unicode_completion with
    | Off -> []
    | Internal_small -> Unicode_bindings.small
    | Normal -> Unicode_bindings.normal
    | Extended -> Unicode_bindings.extended
  in
  (* Coq's CList.map is tail-recursive *)
  CList.map (mk_unicode_completion_item point) ulist

let validate_line ~(doc : Fleche.Doc.t) ~line =
  if Array.length doc.contents.lines > line then
    Some (Array.get doc.contents.lines line)
  else None

(* This returns a byte-based char offset for the line *)
let validate_position ~doc ~point =
  let line, char = point in
  Option.bind (validate_line ~doc ~line) (fun line ->
      Option.bind (Fleche.Utf8.index_of_char ~line ~char) (fun index ->
          Some (String.get line index)))

let get_char_at_point ~(doc : Fleche.Doc.t) ~point =
  let line, char = point in
  if char >= 1 then
    let point = (line, char - 1) in
    validate_position ~doc ~point
  else (* Can't get previous char *)
    None

(* point is a utf char! *)
let completion ~doc ~point : Yojson.Safe.t =
  (* Instead of get_char_at_point we should have a CompletionContext.t, to be
     addressed in further completion PRs *)
  match get_char_at_point ~doc ~point with
  | None ->
    let incomplete = true in
    let items = [] in
    mk_completion_list ~incomplete ~items
  | Some c ->
    let incomplete, items =
      if c = '\\' then (false, unicode_list point)
      else (true, build_doc_idents ~doc)
    in
    let res = mk_completion_list ~incomplete ~items in
    res
