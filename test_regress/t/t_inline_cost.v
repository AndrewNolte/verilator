// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// verilog_format: off
`define stop $stop
`define checkh(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got='h%x exp='h%x\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

module leaf (
    input logic clk,
    input logic [30:0] data,
    output logic [30:0] result
);
  logic [30:0] words[31];
  for (genvar i = 0; i < 31; i++) begin : g
    always_ff @(posedge clk) words[i] <= data + 31'(i);
  end
  always_comb begin
    result = '0;
    foreach (words[i]) result ^= words[i];
  end
endmodule

module group #(
    parameter int WORDS = 7
) (
    input logic clk,
    input logic [30:0] data,
    output logic [30:0] result
);
`ifdef FORCE_INLINE
  /*verilator inline_module*/
`endif
`ifdef KEEP_GROUP
  /*verilator no_inline_module*/
`endif
  logic [30:0] child;
  leaf u_child (.clk, .data, .result(child));
  logic [30:0] words[WORDS];
  for (genvar i = 0; i < WORDS; i++) begin : g
    always_ff @(posedge clk) words[i] <= data + 31'(i);
  end
  always_comb begin
    result = child;
    foreach (words[i]) result ^= words[i];
  end
endmodule

module small_logic (
    input logic clk,
    input logic [30:0] data,
    output logic [30:0] result
);
  logic [30:0] words[6];
  for (genvar i = 0; i < 6; i++) begin : g
    always_ff @(posedge clk) words[i] <= data + 31'(i);
  end
  always_comb begin
    result = '0;
    foreach (words[i]) result ^= words[i];
  end
endmodule

module wrapper (
    input logic clk,
    input logic [30:0] data,
    output logic [30:0] result
);
  small_logic u_child (.clk, .data, .result);
endmodule

module t #(
    parameter int PADDING = 7,
    parameter int GROUP_WORDS = 7
) (
    input logic clk
);
  logic [30:0] cycles = 0;
  logic [30:0] a;
  logic [30:0] b;
  logic [30:0] c;
  logic [30:0] d;
  group #(.WORDS(GROUP_WORDS)) u_a (.clk, .data(cycles), .result(a));
  group #(.WORDS(GROUP_WORDS)) u_b (.clk, .data(cycles + 31'd71), .result(b));
  wrapper u_c (.clk, .data(cycles), .result(c));
  wrapper u_d (.clk, .data(cycles + 31'd43), .result(d));

  // Unrelated logic must not change the inlining decisions in the shared hierarchy.
  logic [30:0] words[PADDING];
  logic [30:0] result;
  for (genvar i = 0; i < PADDING; i++) begin : g
    always_ff @(posedge clk) words[i] <= cycles + 31'(i);
  end
  always_comb begin
    result = '0;
    foreach (words[i]) result ^= words[i];
  end

  function automatic logic [30:0] prefix_xor(input logic [30:0] value);
    case (value[1:0])
      0: return value;
      1: return 1;
      2: return value + 1;
      default: return 0;
    endcase
  endfunction

  function automatic logic [30:0] expected(input logic [30:0] value);
    return prefix_xor(value + 30) ^ prefix_xor(value + 31'(GROUP_WORDS - 1));
  endfunction

  always @(posedge clk) cycles <= cycles + 31'd1;
  always @(negedge clk) begin
    if (cycles > 0) begin
      `checkh(a, expected(cycles - 31'd1));
      `checkh(b, expected(cycles + 31'd70));
      `checkh(c, prefix_xor(cycles + 31'd4) ^ prefix_xor(cycles - 31'd2));
      `checkh(d, prefix_xor(cycles + 31'd47) ^ prefix_xor(cycles + 31'd41));
      `checkh(result, prefix_xor(cycles + 31'(PADDING - 2)) ^ prefix_xor(cycles - 31'd2));
    end
    if (cycles == 40) begin
      $write("*-* All Finished *-*\n");
      $finish;
    end
  end
endmodule
