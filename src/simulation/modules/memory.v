module memory(
    input clk, 
    input rst_n,
    input we,
    input [5:0] addr,
    input [7:0] data,
    output [7:0] out
);

    reg [7:0] out_reg, out_next;

    reg [7:0] mem [2**6 - 1:0];

    assign out = mem[addr];
    integer i;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            for (i = 0; i < 64; i = i + 1)
                mem[i] <= 8'd0;
        end
        else begin
            if(we) 
                 mem[addr] <= data;
        end
        
    end

   
    
endmodule