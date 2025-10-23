module test_bench;

    reg in, clk, rst_n;
    wire out;

    clk_div #(3) my_clk_div(.clk(clk), .rst_n(rst_n), .out(out));

    initial begin
        clk = 0;
        rst_n = 1;
        forever #5 clk = ~clk;
    end



    initial begin


        #50 $finish;
    end

	always @(clk)
		$display("Time = %0d, Output = %d", $time, out);


    
endmodule