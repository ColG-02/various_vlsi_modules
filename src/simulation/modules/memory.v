module memory #(
	parameter FILE_NAME = "mem_init copy.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input we,
    input [ADDR_WIDTH - 1:0] addr,
    input [DATA_WIDTH - 1:0] data,
    output reg [DATA_WIDTH - 1:0] out
);

    (* ram_init_file = FILE_NAME *)
    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    //reg [ADDR_WIDTH-1:0] addr_r;

    initial begin
        if (FILE_NAME != "") $readmemh(FILE_NAME, mem);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
    //        addr_r <= {ADDR_WIDTH{1'b0}};
            out <= {DATA_WIDTH{1'b0}};
        end else begin
    //        addr_r <= addr;
            if (we) mem[addr] <= data;
            else if (!we) out <= mem[addr];
    //        else if (!we) out <= mem[addr_r];        
        end
    end
    
endmodule