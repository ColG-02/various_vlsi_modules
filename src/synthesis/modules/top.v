module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif", 
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input [2:0] btn,
    input [9:0] sw,
    input [1:0] kbd,
    output [13:0] mnt, 
    output [9:0] led,
    output [27:0] ssd
);
    
    wire rst_n = sw[9];
    
    wire clk_div;
    wire mem_we;
    wire[ADDR_WIDTH - 1:0] mem_addr;
    wire[DATA_WIDTH - 1:0] mem_out;
    wire[DATA_WIDTH - 1:0] mem_in;

    wire [ADDR_WIDTH - 1:0] pc_out;
    wire [ADDR_WIDTH - 1:0] sp_out;
    wire [DATA_WIDTH - 1:0] cpu_out;
    wire [DATA_WIDTH - 1:0] cpu_in;

    wire [3:0] sp_ones;
    wire [3:0] sp_tens;
    wire [3:0] pc_ones;
    wire [3:0] pc_tens;
    
    clk_div #(
        .DIVISOR(DIVISOR)
    )clk_div_inst(
        .clk(clk), 
        .rst_n(rst_n), 
        .out(clk_div)
    );

    memory #(
        .FILE_NAME(FILE_NAME),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH) 
    ) memory_inst (
        .clk(clk_div),
        .we(mem_we),
        .addr(mem_addr),
        .data(mem_in),
        .out(mem_out)
    );
    
    

    cpu #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) cpu_inst (
        .clk(clk_div),
        .rst_n(rst_n),
        .mem(mem_out),
        .in(cpu_in),
        .we(mem_we),
        .status(cpu_status),
        .control(cpu_control),
        .addr(mem_addr),
        .data(mem_in),
        .out(cpu_out),
        .pc(pc_out),
        .sp(sp_out)
    );

    assign led[4:0] = cpu_out[4:0];
    assign led[5] = cpu_status;
    //assign led[9:6] = color_code [11:8];
    
    bcd bcd_pc (
        .in(pc_out),
        .ones(pc_ones),
        .tens(pc_tens)
    );

    bcd bcd_sp (
        .in(sp_out),
        .ones(sp_ones),
        .tens(sp_tens)
    );

    ssd ssd_pc_ones (
        .in(pc_ones),
        .out(ssd[6:0])
    );

    ssd ssd_pc_tens (
        .in(pc_tens),
        .out(ssd[13:7])
    );

    ssd ssd_sp_ones (
        .in(sp_ones),
        .out(ssd[20:14])
    );

    ssd ssd_sp_tens (
        .in(sp_tens),
        .out(ssd[27:21])
    );


    wire [23:0] color_code;
    wire [3:0] red, green, blue;
    wire hsync, vsync;

    color_codes color_codes_inst (
        .num(cpu_out[5:0]),
        .code(color_code)
    );

    vga vga_inst (
        .clk(clk),
        .rst_n(rst_n),
        .code(color_code),
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync)
    );

    assign mnt = {hsync, vsync, red, green, blue};

    wire [15:0] ps2_code;

    ps2 ps2_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(kbd[0]),
        .ps2_data(kbd[1]),
        .code(ps2_code)
    );

    wire ps2_status;
    wire ps2_control;
    wire [3:0] ps2_num;
    scan_codes scan_codes_inst (
        .clk(clk),
        .rst_n(rst_n),
        .code(ps2_code),
        .status(ps2_status),
        .control(ps2_control),
        .num(ps2_num)
    );
    assign cpu_in = {12'b0, ps2_num};
    assign cpu_status = ps2_status;
    assign cpu_control = ps2_control;
endmodule