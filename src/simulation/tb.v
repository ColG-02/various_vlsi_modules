module tb;

   reg  dut_clk;
   reg dut_rst_n;
   reg dut_we;
   reg [5:0] dut_addr;
   reg [15:0] dut_data;
   wire [15:0] dut_out;


    dut DUT(
        .clk(dut_clk),
        .rst_n(dut_rst_n),
        .we(dut_we),
        .addr(dut_addr),
        .data(dut_data),
        .out(dut_out)
    );
    integer i;
    integer rand_addr;
    initial begin

        dut_clk = 0;
        dut_rst_n = 0;
        dut_we = 0;
        dut_addr = 0;
        dut_data = 0;

        #15 dut_rst_n = 1'b1;

        for(i=0 ; i< 32 ; i =i+1) begin
          @(posedge dut_clk);
            //#3;
            dut_we = 1'b1;
            dut_addr = i *2;
            dut_data = $random; 
            $display("Time: %0d, we: %d , addr: %d, data: %d ", $time, dut_we, dut_addr, dut_data);
        end

        # 10 $stop;

        repeat(100) begin
            //#5;
            @(posedge dut_clk)
            dut_we = 1'b0;
            rand_addr = $urandom % 32;
            dut_addr = rand_addr * 2;
            @(posedge dut_clk);
            $display("Time: %0d, we: %d , addr: %d,out: %d", $time, dut_we, dut_addr,dut_out);
        end
        #10 $finish;

    end
     

    always 
        #5 dut_clk = ~dut_clk;
        
   
endmodule