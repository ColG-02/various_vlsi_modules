module dff(clk, rst_n, d, q);
    input clk, rst_n, d;
    output reg q;
    always @(posedge clk, negedge rst_n)
    if (!rst_n)
    q <= 0;
    else
    q <= d;
endmodule