module vga (
    input clk,      
    input rst_n,    
    input [23:0] code,     
    output hsync,
    output vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);

    reg [10:0] h_counter;
    reg [9:0] v_counter;

    assign {red, green, blue} = 
    (v_counter < 600 && h_counter < 400) ? code[23:12] : 
    ((v_counter < 600 && h_counter < 800) ? code[11:0] : 12'h0);

    assign hsync = h_counter > 11'd855 && h_counter < 11'd976;
    assign vsync = v_counter > 10'd636 && v_counter < 10'd643;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_counter <= 11'h0;
            v_counter <= 10'h0;
        end else begin 
            if (h_counter == 1039) begin
                h_counter <= 11'h0;
                if (v_counter == 665) v_counter <= 10'h0;
                else v_counter <= v_counter + 10'h1;
            end else h_counter <= h_counter + 11'h1;
        end
    end

endmodule
   