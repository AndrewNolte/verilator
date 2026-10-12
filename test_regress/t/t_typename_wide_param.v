// DESCRIPTION: Verilator: Wide decimal parameter formatting
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

module item #(parameter bit [16383:0] VALUE = 16384'b1 << 16383) ();
  typedef struct packed { bit valid; bit [7:0] data; } record_t;
  record_t record;
endmodule

module t;
  item i();
endmodule
