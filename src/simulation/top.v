module top;

    reg [3:0]a, b;
    reg [2:0]oc;
    wire [3:0]f;
    integer index;

    alu alu_unit (.f(f), .oc(oc), .a(a), .b(b));

    wire [3:0]out;
    reg clk, rst_n, cl, ld;
    reg [3:0] in;
    reg inc, dec, sr, ir, sl, il;

    register reg_unit (out, clk, rst_n, cl, ld, in, inc, dec, sr, ir, sl, il);

    initial begin
        //$monitor ("Vreme = %4d, oc = %3b, a = %4b, b = %4b, f = %4b", $time, oc, a, b, f);
        //# time =     0, oc = 000, a = 0000, b = 0000, f = 0000
        //$monitor ("time = %5d, oc = %3b, a = %4b, b = %4b, f = %4b", $time, oc, a, b, f);
        for (index = 0; index < 2048; index = index + 1) begin
            //{a, b, oc} = index;
            {oc, a, b} = index;
            #2;
        end
        $stop;


        rst_n = 1'b0; clk = 1'b0; cl = 1'b0; ld = 1'b0; inc = 1'b0; dec = 1'b0;
        sr = 1'b0; ir = 1'b0; sl = 1'b0; il = 1'b0; in = 4'h0;
        #2 rst_n = 1'b1;
        repeat (1000) begin
            #5; 
            cl = {$random} % 2;
            ld = {$random} % 2;
            inc = {$random} % 2;
            dec = {$random} % 2;
            sr = {$random} % 2;
            ir = {$random} % 2;
            sl = {$random} % 2;
            il = {$random} % 2;
            in = $urandom_range(15);
        end
        #10 $finish;
    end

    // always @(out)
    //     $display ("Vreme = %4d, in = %4b, out = %4b, cl = %1b, ld = %1b, inc = %1b,dec = %1b, sr = %1b, sl = %1b, ir = %1b, il = %1b",
    //     $time, in, out, cl, ld, inc, dec, sr, sl, ir, il);

    always #5 clk = ~clk;



    
endmodule