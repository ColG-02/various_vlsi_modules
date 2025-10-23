module alu #(
    parameter DATA_WIDTH = 16
)(
    input [2:0]oc,
    input [DATA_WIDTH-1:0]a,
    input [DATA_WIDTH-1:0]b,
    output reg [DATA_WIDTH-1:0]f
);

    always @(*) begin
        casex (oc)
            3'b000 : begin f = a + b; end
            3'b001 : begin f = a - b; end
            3'b010 : begin f = a * b; end
            3'b011 : begin f = (b != 0) ? (a / b) : {DATA_WIDTH{1'b0}}; end
            3'b100 : begin f = ~a; end
            3'b101 : begin f = a ^ b; end
            3'b110 : begin f = a | b; end
            3'b111 : begin f = a & b; end
            default: begin f = {DATA_WIDTH{1'b0}}; end
        endcase
    end
endmodule