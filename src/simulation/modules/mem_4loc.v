// 256 x 8 from four 64 x 8 "memory" blocks
module mem4_loc (
    input        clk,
    input        rst_n,
    input        we,
    input  [7:0] addr,   // 8-bit addr => 256 locations
    input  [7:0] data,
    output [7:0] out
);
    wire [1:0] bank = addr[7:6];  // which 64x8 block
    wire [5:0] idx  = addr[5:0];  // index within block

    // one-hot write enables
    wire we_b0 = we & (bank == 2'b00);
    wire we_b1 = we & (bank == 2'b01);
    wire we_b2 = we & (bank == 2'b10);
    wire we_b3 = we & (bank == 2'b11);

    wire [7:0] out_b0, out_b1, out_b2, out_b3;

    memory m0 (.clk(clk), .rst_n(rst_n), .we(we_b0), .addr(idx), .data(data), .out(out_b0));
    memory m1 (.clk(clk), .rst_n(rst_n), .we(we_b1), .addr(idx), .data(data), .out(out_b1));
    memory m2 (.clk(clk), .rst_n(rst_n), .we(we_b2), .addr(idx), .data(data), .out(out_b2));
    memory m3 (.clk(clk), .rst_n(rst_n), .we(we_b3), .addr(idx), .data(data), .out(out_b3));

    // read mux (combinational, matching your base memory behavior)
    reg [7:0] out_r;
    always @* begin
        case (bank)
            2'b00: out_r = out_b0;
            2'b01: out_r = out_b1;
            2'b10: out_r = out_b2;
            default: out_r = out_b3;
        endcase
    end

    assign out = out_r;
endmodule
