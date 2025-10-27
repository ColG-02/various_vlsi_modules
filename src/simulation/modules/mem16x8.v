module mem16x8(clk, rst_n, we, addr, data, out);

    input clk;
    input rst_n;
    input we;
    input [3:0] addr;
    input [7:0] data;
    output [7:0] out;

    reg [3:0] addr_next, addr_reg;
    reg [7:0] mem_next [15:0], mem_reg [15:0];
    
    assign out = mem_reg[addr_reg];

    integer i;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            addr_reg <= 4'h0;
            for (i = 0; i < 16; i = i + 1)
                mem_reg[i] <= 8'h00;
        end else begin
            addr_reg <= addr_next;
            for (i = 0; i < 16; i = i + 1)
                mem_reg[i] <= mem_next[i];
        end
    end
    
    always @(*) begin
        for (i = 0; i < 16; i = i + 1)
            mem_next[i] = mem_reg[i];
        if (we)
            mem_next[addr] = data;
        addr_next = addr;
    end

endmodule
