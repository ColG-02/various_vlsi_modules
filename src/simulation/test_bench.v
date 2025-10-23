module test_bench;

    reg in, clk, rst_n;
    wire out;

    debouncer my_deb(.in(in), .clk(clk), .rst_n(rst_n), .out(out));

    initial begin
        clk = 0;
        rst_n = 0;  // assert reset
        in = 0;
        forever #5 clk = ~clk;
    end

    always begin
        #22 in = ~in;
    end

    initial begin

        #4 rst_n = 1;

        #50 $finish;
    end

	always @(clk)
		$display("Time = %0d, Output = %d", $time, out);


    
endmodule