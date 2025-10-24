`timescale 1ns/1ps

module cpu_tb;

  reg  clk;
  reg  rst_n;

  // handy probes
  wire        we;
  wire [5:0]  addr;
  wire [15:0] data;
  wire [15:0] mem_out;
  wire [15:0] out;
  wire [5:0]  pc;
  wire [5:0]  sp;
  wire        status;

  // input “in” to the CPU
  wire [15:0] in;
  assign in = 16'd8;

  // optional control (tie off if unused in CPU)
  wire control = 1'b0;

  // DUT
  cpu cpu_inst (
    .clk(clk),
    .rst_n(rst_n),
    .mem(mem_out),
    .in(in),
    .control(control),
    .status(status),
    .we(we),
    .addr(addr),
    .data(data),
    .out(out),
    .pc(pc),
    .sp(sp)
  );

  // RAM (adjust params to your memory.sv)
  memory #(
    .FILE_NAME("mem_init copy.mif"),   // avoid spaces
    .ADDR_WIDTH(6),
    .DATA_WIDTH(16)
  ) mem_inst (
    .clk(clk),
    .rst_n(rst_n),   // <— add this
    .we(we),
    .addr(addr),
    .data(data),
    .out(mem_out)
  );

  // clock
  initial clk = 1'b0;
  always #10 clk = ~clk;

  // reset
  initial begin
    rst_n = 1'b0;
    #50;
    rst_n = 1'b1;
  end

  // stop when CPU asserts status (your STOP)
  initial begin
    wait (status === 1'b1);
    $display("[%0t] STATUS=1 (halt). Finishing.", $time);
    #20 $finish;
  end

  // timeout guard
  initial begin
    #100_000;
    $display("[%0t] Timeout. Finishing.", $time);
    $finish;
  end

  // change tracking
  reg [1:0]  prev_state;
  reg [15:0] prev_out;

  initial begin
    prev_state = 2'd0;
    prev_out   = 16'd0;
  end

  // event logging: state/steps + writes
  always @(posedge clk) begin
    // log writes
    if (we) begin
      $display("[%0t] WE=1  WRITE  addr=%0d data=0x%04h", $time, addr, data);
    end

    // log state/step transitions or OUT changes
    if (cpu_inst.state !== prev_state || out !== prev_out) begin
      $display("[%0t] PC=%0d  STATE=%0d  F=%0d A=%0d E=%0d  IR=0x%04h  MAR=%0d  MDR=0x%04h  MEM=0x%04h  OPC=%0h  ALU_OC=%0b  OUT=0x%04h",
               $time,
               pc,
               cpu_inst.state,
               cpu_inst.fetch_step, cpu_inst.addr_step, cpu_inst.exec_step,
               cpu_inst.ir_out,
               cpu_inst.mar_out,
               cpu_inst.mdr_out,
               mem_out,
               cpu_inst.opc,
               cpu_inst.alu_oc,
               out);
      prev_state <= cpu_inst.state;
      prev_out   <= out;
    end
  end

  // waves (optional)
//   initial begin
//     $dumpfile("cpu_tb.vcd");
//     $dumpvars(0, cpu_tb);
//   end

endmodule
