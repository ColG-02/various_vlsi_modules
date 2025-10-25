module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init copy.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [2:0] btn,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);

    wire out_clk;
    wire we;
    wire [ADDR_WIDTH - 1:0] addr;
    wire [DATA_WIDTH - 1:0] data;
    wire [DATA_WIDTH - 1:0] mem_out;
    wire [ADDR_WIDTH - 1:0] pc;
    wire [ADDR_WIDTH - 1:0] sp;
    wire [DATA_WIDTH - 1:0] out_cpu;

    clk_div #(.DIVISOR(50000000)) clk_div_inst (.clk(clk), .rst_n(sw[9]), .out(out_clk));

    memory #(.FILE_NAME("mem_init.mif"), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) 
        memory_inst (.clk(out_clk), .we(we), .addr(addr), .data(data), .out(mem_out));

    cpu cpu_inst (.clk(out_clk), .rst_n(sw[9]), .mem(mem_out), .in({12'b0,sw[3:0]}), .control(out_control), .status(out_status),
        .we(we), .addr(addr), .data(data), .out(out_cpu), .pc(pc), .sp(sp));


    
endmodule