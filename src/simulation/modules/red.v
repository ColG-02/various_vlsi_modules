module red (
    input clk,
    input rst_n,
    input in,
    output out
);

    reg d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) d <= 1'b0;
        else        d <= in;
    end

    assign out = in & ~d; // high for 1 clk when in_sig goes 0->1
    //assign out = rst_n & (in & ~d);
    
endmodule