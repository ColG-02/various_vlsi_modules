// 64 x 32 from four 64 x 8 "memory" blocks
module mem_4word (
    input         clk,
    input         rst_n,
    input         we,
    input  [5:0]  addr,      // still 64 locations
    input  [31:0] data,      // 32-bit word
    output [31:0] out
);
    wire [7:0] q0, q1, q2, q3;

    memory m_byte0 (.clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .data(data[7:0]),   .out(q0)); // lowest byte
    memory m_byte1 (.clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .data(data[15:8]),  .out(q1));
    memory m_byte2 (.clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .data(data[23:16]), .out(q2));
    memory m_byte3 (.clk(clk), .rst_n(rst_n), .we(we), .addr(addr), .data(data[31:24]), .out(q3)); // highest byte

    assign out = {q3, q2, q1, q0};
endmodule
