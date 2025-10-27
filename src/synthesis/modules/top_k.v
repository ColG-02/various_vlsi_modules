module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input [1:0] kbd,
    input [2:0] btn,
    input [9:0] sw,
    input [13:0] mnt,
    output [9:0] led,
    output [27:0] hex
);

    wire rstn = sw[9];

    wire out_clk;
    wire we;
    wire [ADDR_WIDTH - 1:0] addr;
    wire [DATA_WIDTH - 1:0] data;
    wire [DATA_WIDTH - 1:0] mem_out;
    wire [ADDR_WIDTH - 1:0] pc;
    wire [ADDR_WIDTH - 1:0] sp;
    wire [DATA_WIDTH - 1:0] out_cpu;

    wire [3:0] ones1, tens1, ones2, tens2;

    assign led[4:0] = out_cpu[4:0];

    clk_div #(.DIVISOR(DIVISOR)) clk_div_inst (.clk(clk), .rst_n(rstn), .out(out_clk));

    memory #(.FILE_NAME(FILE_NAME), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) 
        memory_inst (.clk(out_clk), .we(we), .addr(addr), .data(data), .out(mem_out));

    cpu cpu_inst (.clk(out_clk), .rst_n(rstn), .mem(mem_out), .in({12'b0,sw[3:0]}), .control(sw[8]), .status(led[5]),
        .we(we), .addr(addr), .data(data), .out(out_cpu), .pc(pc), .sp(sp));

    

    bcd bcd_pc (.in(pc), .ones(ones1), .tens(tens1));

    bcd bcd_sp (.in(sp), .ones(ones2), .tens(tens2));

    ssd ssd1 (.in(ones1), .out(hex[6:0]));

    ssd ssd2 (.in(tens1), .out(hex[13:7]));
    
    ssd ssd3 (.in(ones2), .out(hex[20:14]));
    
    ssd ssd4 (.in(tens2), .out(hex[27:21]));
    
endmodule