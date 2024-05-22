open Lang.Utf

let%test_unit "utf16 byte offsets" =
  let check_last s i = i < String.length s && next s i == String.length s in
  let testcases_x =
    [ ("aax", 2, true)
    ; ("  xoo", 2, true)
    ; ("0123", 4, false)
    ; ("  𝒞x", 4, true)
    ; ("  𝒞x𝒞", 4, true)
    ; ("  𝒞∫x", 5, true)
    ; ("  𝒞", 4, false)
    ; ("∫x.dy", 1, true)
    ]
  in
  List.iter
    (fun (s, i, b) ->
      let res = utf8_offset_of_utf16_offset ~line:s ~offset:i in
      if b then (
        let res = s.[res] in
        if res != 'x' then
          failwith
            (Printf.sprintf "Didn't find x in test %s : %d, instead: %c" s i res))
      else if not (check_last s res) then
        failwith
          (Printf.sprintf "Shouldn't find x in test %s / %d got %d" s i res))
    testcases_x

let%test_unit "utf16 unicode offsets" =
  let testcases =
    [ ("aax", 2, 2)
    ; ("  xoo", 2, 2)
    ; ("0123", 4, 3)
    ; ("  𝒞x", 4, 3)
    ; ("  𝒞x𝒞", 4, 3)
    ; ("  𝒞∫x", 5, 4)
    ; ("  𝒞", 4, 2)
    ; ("∫x.dy", 1, 1)
    ]
  in
  List.iter
    (fun (s, i, e) ->
      let res = char_of_utf16_offset ~line:s ~offset:i in
      if res != e then
        failwith
          (Printf.sprintf "Wrong result: got %d expected %d in test %s" res e s))
    testcases

let%test_unit "unicode utf16 offsets" =
  let testcases =
    [ ("aax", 2, 2)
    ; ("  xoo", 2, 2)
    ; ("0123", 3, 3)
    ; ("  𝒞x", 3, 4)
    ; ("  𝒞x𝒞", 3, 4)
    ; ("  𝒞∫x", 4, 5)
    ; ("  𝒞", 2, 2)
    ; ("∫x.dy", 1, 1)
    ]
  in
  List.iter
    (fun (line, char, e) ->
      let res = utf16_offset_of_char ~line ~char in
      if res != e then
        failwith
          (Printf.sprintf "Wrong result: got %d expected %d in test %s" res e
             line))
    testcases
