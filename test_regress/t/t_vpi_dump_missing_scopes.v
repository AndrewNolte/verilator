// DESCRIPTION: Verilator: Verilog Test module
//
// Copyright 2010 by Wilson Snyder. This program is free software; you can
// redistribute it and/or modify it under the terms of either the GNU
// Lesser General Public License Version 3 or the Perl Artistic License
// Version 2.0.
// SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0


// using public_on causes one to be AstCellInline, and that one has correct scope
// without this, both are AstCellInline, and both are wrong

/* verilator public_on */

module t (  /*AUTOARG*/
    x,
    clk,
    a
);
   input clk;
   input [7:0] a;
   output reg [7:0] x;


   initial begin
      $write("*-* All Finished *-*\n");
      $finish();
   end


   gen_wrapper top_wrap_1 ();
   gen_wrapper top_wrap_2 ();

endmodule : t

module sub;
   reg subsig1;
endmodule : sub


module gen_wrapper #(
   parameter int LENGTH = 1
);
   genvar i;
   generate
      for (i = 0; i < LENGTH; i++) begin : gen_loop

         // This fixes the scope
         // localparam int x  = LENGTH;

         sub after_gen_loop ();
      end
   endgenerate
endmodule