module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);

    integer cnt = 0;
    reg out_reg;

    always @(posedge clk or negedge rst_n) begin
        out_reg <= 1'b0;
        if(!rst_n) begin
            out_reg <= 1'b0;
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
            if(cnt == DIVISOR) begin
                out_reg <= 1'b1;
                cnt <= 0;
            end
        end
    end

    assign out = out_reg;


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