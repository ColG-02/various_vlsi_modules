module mem_word (
    input clk,
    input rst_n,
    input we, 
    input [5:0] addr,
    input [15:0] data,
    output [15:0] out
);

    wire [7:0] out_low;
    wire [7:0] out_high;
    assign out = {out_high, out_low};

    memory mem_low(.clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .data(data[7:0]), .out(out_low));
    memory mem_high(.clk(clk), .rst_n(rst_n), .we(we), .addr(addr + 1'b1), .data(data[15:8]), .out(out_high));

    

endmodule