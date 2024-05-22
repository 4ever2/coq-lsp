(************************************************************************)
(* Flèche => document manager: Language Support                         *)
(* Copyright 2019-2024 Inria      -- Dual License LGPL 2.1 / GPL3+      *)
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)

(** This module provides facilities for translating language-based locations to
    protocol-based locations.

    After a long discussion (thanks Léo !), we have decided that the best is to
    have `Lang.Point` to store columns offset in the values that are native to
    the protocol under consideration, set by the upper layers.

    This scheme kind of follows what we have done since the start with coq-lsp. *)

module Encoding : sig
  (* Used for char offsets *)
  type t =
    | Utf8
    | Utf16
    | Utf32
end

(* Future work: support multiple encondings *)
(* val set_protocol_encoding : *)

(* utf8 utils, both Coq and Camomile have similar implementations, at some point
   we should remove this but for now we keep it internal. For now we use the
   Camomille functions *)

(** Unicode terminology refresher:
    - character, code point: The real unicode character
    - byte or 16bit offset / code unit: The encoded version *)

type utf8_string = string
type char = int
type utf8_index = int
type utf16_index = int

(** To unicode chars *)

(** Byte index to character position [also called a codepoint], line is enconded
    in UTF-8 *)
val char_of_utf8_offset : line:utf8_string -> offset:utf8_index -> char option

(** Get the unicode position of a code point indexed in UTF-16 code units in a
    utf-8 encoded utf8_string. Returns the position of the last character if the
    utf-16 position was out of bounds. *)
val char_of_utf16_offset : line:utf8_string -> offset:utf16_index -> char

(** To UTF-8 offsets *)

(** UTF-8 Char to byte index position; line is enconded in UTF-8 *)
val utf8_offset_of_char : line:utf8_string -> char:char -> utf8_index option

(** Get the byte position of a code point indexed in UTF-16 code units in a
    UTF-8 encoded utf8_string. Returns the position of the last character if the
    UTF-16 position was out of bounds. *)
val utf8_offset_of_utf16_offset :
  line:utf8_string -> offset:utf16_index -> utf8_index

(** To UTF-16 offsets *)

(** Get the utf16 position of a code point indexed in unicode code points in a
    UTF-8 encoded utf8_string. The position must be in bounds. *)
val utf16_offset_of_char : line:utf8_string -> char:int -> utf16_index

(** Number of characters in th utf-8-encoded utf8_string *)
val length : utf8_string -> char

(** Translate a Fleche position into an UTF-16 LSP position. *)
val utf16_point_of_char_point : lines:utf8_string array -> Point.t -> Point.t

(** Translate a Fleche range into an UTF-16 LSP range. *)
val utf16_range_of_char_range : lines:utf8_string array -> Range.t -> Range.t
