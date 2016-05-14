(*
  The MIT License (MIT)
  
  Copyright (c) 2016 Maxime Ransan <maxime.ransan@gmail.com>
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*)

type alphabet = string 

exception Invalid_alphabet 

let make_alphabet s = 
  if String.length s <> 58
  then raise Invalid_alphabet 
  else s  

let bitcoin     = make_alphabet "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  
let zero        = Char.unsafe_chr 0

let encode alphabet bin  = 

  let bin_len = Bytes.length bin in 
  let bin_beg = 
    let rec aux = function 
      | i when i = bin_len             -> i 
      | i when Bytes.get bin i <> zero -> i
      | i -> aux (i + 1)
    in 
    aux 0 
  in 
  
  let buf_len = 1 + ((bin_len - bin_beg) * 138 / 100) in  
  let buf     = Bytes.make buf_len zero in 
  let buf_last_index = buf_len - 1 in 

  let carry          = ref 0 in
  let buf_end        = ref buf_last_index  in
    (* 
     * Buf end keeps track of the last written byte in 
     * the [buf] buffer. 
     *)

  for bin_i=bin_beg to bin_len - 1 do

    carry := Char.code (Bytes.get bin bin_i);

    let rec iter = function
      | buf_i when buf_i > !buf_end || !carry <> 0 -> (

        carry := !carry + (256 * (Bytes.get buf buf_i |> Char.code));
        Bytes.set buf buf_i (Char.unsafe_chr (!carry mod 58)); 
        carry := !carry / 58;
        iter (buf_i - 1)
      ) 
      | buf_end -> buf_end
    in  

    buf_end := iter (buf_len - 1)

  done; (* [bin] iteration *)
  
  let buf_written_len = buf_len - !buf_end - 1 in 
  let out_len         = bin_beg + buf_written_len in 

  let out     = Bytes.create out_len in 
  Bytes.fill out 0 bin_beg (String.unsafe_get alphabet 0); 
  Bytes.blit buf (!buf_end + 1) out bin_beg buf_written_len; 

  for out_i = bin_beg to out_len - 1 do
    Bytes.set out out_i (String.unsafe_get alphabet (Bytes.unsafe_get out out_i |> Char.code))
  done;
  out  
