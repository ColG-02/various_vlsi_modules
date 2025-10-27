module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code
);
    localparam WAITING = 2'd0, READ = 2'd1, DONE = 2'd2;

    reg [1:0] state, state_next;
    reg [1:0] ps2_clk_reg, ps2_clk_next;
    reg [3:0] bit_count, bit_count_next;
    reg [8:0] shift_reg, shift_next;
    reg [15:0] code_reg, code_next;

    assign code = code_reg;
    wire ps2_clk_falling;
    assign ps2_clk_falling = (ps2_clk_reg[1] == 1'b1) && (ps2_clk_reg[0] == 1'b0);

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= WAITING;
            ps2_clk_reg <= 2'h0;
            bit_count <= 4'h0;
            shift_reg <= 9'h0;
            code_reg <= 16'h0;
        end else begin
            state <= state_next;
            ps2_clk_reg <= ps2_clk_next;
            bit_count <= bit_count_next;
            shift_reg <= shift_next;
            code_reg <= code_next;
        end
    end

    always @(*) begin
        state_next = state;
        ps2_clk_next = {ps2_clk_reg[0], ps2_clk};
        bit_count_next = bit_count;
        shift_next = shift_reg;
        code_next = code_reg;
        
        if (ps2_clk_falling) begin
            case (state)
                WAITING: begin
                    if (ps2_data == 1'b0) state_next = READ; 
                end 

                READ: begin
                    shift_next = {ps2_data, shift_reg[8:1]};
                    if (bit_count == 8) begin
                        state_next = DONE;
                    end else begin
                        bit_count_next = bit_count + 4'h1;
                    end
                end
                
                DONE: begin
                    if (^shift_reg[8:0]) begin
                        code_next = {code_reg[7:0], shift_reg[7:0]};
                    end else begin
                        code_next = 16'h0;
                    end
                    shift_next = 9'h0;
                    bit_count_next = 4'h0;
                    state_next = WAITING;
                end
            endcase
        end
    end



endmodule