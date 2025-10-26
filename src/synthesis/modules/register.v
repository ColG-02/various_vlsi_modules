module register #(
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [DATA_WIDTH-1:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [DATA_WIDTH-1:0] out
);

    reg [DATA_WIDTH-1:0] out_next, out_reg;
    assign out = out_reg;

    //sekvencijalni deo
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            out_reg <= {DATA_WIDTH{1'b0}};
        else
            out_reg <= out_next;
    end

    //kombinacioni deo
    always @(in, out, cl, ld, inc, dec, sr, sl) begin
        out_next = out_reg; // zadrzava staru vrednost
        if(cl) out_next = {DATA_WIDTH{1'b0}};
        else if(ld) out_next = in;
        else if(inc) out_next = out_reg + {{DATA_WIDTH-1{1'b0}}, 1'b1};
        else if(dec) out_next = out_reg - {{DATA_WIDTH-1{1'b0}}, 1'b1};
        else if(sr) begin
            out_next = out_reg >> 1;
            if(ir) out_next = out_next | {1'b1, {DATA_WIDTH-1{1'b0}}};
        end
        else if(sl) begin
            out_next = out_reg << 1;
            if(il) out_next = out_next | {{DATA_WIDTH-1{1'b0}}, 1'b1};
        end
    end



endmodule