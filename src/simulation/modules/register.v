module register (out, clk, rst_n, cl, ld, in, inc, dec, sr, ir, sl, il);

    output [3:0]out;
    input clk, rst_n, cl, ld;
    input [3:0] in;
    input inc, dec, sr, ir, sl, il;

    reg [3:0] out_next, out_reg;
    assign out = out_reg;

    //sekvencijalni deo
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            out_reg <= 4'b0000;
        else
            out_reg <= out_next;
    end

    //kombinacioni deo
    always @(in, out, cl, ld, inc, dec, sr, sl) begin
        out_next = out_reg; // zadrzava staru vrednost
        if(cl) out_next = 4'b0000;
        else if(ld) out_next = in;
        else if(inc) out_next = out_reg + {{3{1'b0}}, 1'b1};
        else if(dec) out_next = out_reg - {{3{1'b0}}, 1'b1};
        else if(sr) begin
            out_next = out_reg >> 1;
            if(ir) out_next = out_next | 4'b1000;
            //else out_next = out_next && 4'b0111;
        end
        else if(sl) begin
            out_next = out_reg << 1;
            if(il) out_next = out_next | 4'b0001;
            //else out_next = out_next && 4'b1110;
        end
    end



endmodule