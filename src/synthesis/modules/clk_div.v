module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);

       reg out_reg, out_next;
    integer counter_next, counter_reg;
    assign out = (DIVISOR == 1) ? clk : out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
             out_reg <= 1'b0;
             counter_reg <= 0;
        end else begin
            out_reg <= out_next;
            counter_reg <= counter_next;
        end
    end    

    always @(*) begin
        {out_next, counter_next} = {out_reg, counter_reg};
        if (DIVISOR > 1) begin
            out_next = (counter_reg < DIVISOR/2) ? 1'b1 : 1'b0;
            counter_next = (counter_reg == DIVISOR - 1)? 0 : counter_reg + 1;
        end 
    end


    /*
    reg [31:0] counter; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            out <= 1'b0;
        end else begin
            if (counter == (DIVISOR/2 - 1)) begin 
                out <= !out;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
    */

    
endmodule