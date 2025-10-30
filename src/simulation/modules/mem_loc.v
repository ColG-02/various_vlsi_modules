// 128 x 8 made from two 64 x 8 memory blocks
module mem_loc (
    input        clk,
    input        rst_n,
    input        we,
    input  [6:0] addr,   // 7-bit address => 128 locations
    input  [7:0] data,
    output [7:0] out
);
    wire bank_sel       = addr[6];    // 0 -> low bank, 1 -> high bank
    wire [5:0] idx      = addr[5:0];  // index within each 64x8 memory

    // Write-enable only the selected bank
    wire we_lo = we & ~bank_sel;
    wire we_hi = we &  bank_sel;

    wire [7:0] out_lo, out_hi;

    memory mem_lo (
        .clk(clk), .rst_n(rst_n),
        .we(we_lo),
        .addr(idx),
        .data(data),
        .out(out_lo)
    );

    memory mem_hi (
        .clk(clk), .rst_n(rst_n),
        .we(we_hi),
        .addr(idx),
        .data(data),
        .out(out_hi)
    );

    // Read mux
    assign out = bank_sel ? out_hi : out_lo;

endmodule
