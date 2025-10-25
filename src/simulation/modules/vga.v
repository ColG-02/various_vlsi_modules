// vga.v
// VGA 640x480@60Hz controller (pixel clock expected on clk)
// code[23:12] = left  half color, RGB444 (R[23:20], G[19:16], B[15:12])
// code[11:0]  = right half color, RGB444 (R[11:8],  G[7:4],   B[3:0])
// Outputs are 4-bit per channel.

module vga (
    input  wire        clk,     // pixel clock (25.175 MHz nominal for 640x480@60)
    input  wire        rst_n,   // async active-low reset
    input  wire [23:0] code,    // two RGB444 colors: {left[11:0], right[11:0]}
    output wire        hsync,   // active-low HSYNC
    output wire        vsync,   // active-low VSYNC
    output reg  [3:0]  red,
    output reg  [3:0]  green,
    output reg  [3:0]  blue
);

    // ----------------------------------------------------------------
    // 640x480 @ 60 Hz timing (VGA standard)
    // ----------------------------------------------------------------
    localparam integer H_VISIBLE = 640;
    localparam integer H_FP      = 16;
    localparam integer H_SYNC    = 96;   // active-low
    localparam integer H_BP      = 48;
    localparam integer H_TOTAL   = H_VISIBLE + H_FP + H_SYNC + H_BP; // = 800

    localparam integer V_VISIBLE = 480;
    localparam integer V_FP      = 10;
    localparam integer V_SYNC    = 2;    // active-low
    localparam integer V_BP      = 33;
    localparam integer V_TOTAL   = V_VISIBLE + V_FP + V_SYNC + V_BP; // = 525

    // ----------------------------------------------------------------
    // Horizontal & vertical pixel counters
    // ----------------------------------------------------------------
    reg [9:0] h_cnt;  // 0..799
    reg [9:0] v_cnt;  // 0..524

    wire line_end  = (h_cnt == H_TOTAL-1);
    wire frame_end = (v_cnt == V_TOTAL-1);

    // Async reset, sync advance
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
        end else begin
            if (line_end) begin
                h_cnt <= 10'd0;
                v_cnt <= frame_end ? 10'd0 : (v_cnt + 10'd1);
            end else begin
                h_cnt <= h_cnt + 10'd1;
            end
        end
    end

    // ----------------------------------------------------------------
    // Sync generation (active-low pulses during sync intervals)
    // ----------------------------------------------------------------
    wire hsync_active = (h_cnt >= (H_VISIBLE + H_FP)) &&
                        (h_cnt <  (H_VISIBLE + H_FP + H_SYNC));
    wire vsync_active = (v_cnt >= (V_VISIBLE + V_FP)) &&
                        (v_cnt <  (V_VISIBLE + V_FP + V_SYNC));

    assign hsync = ~hsync_active;
    assign vsync = ~vsync_active;

    // ----------------------------------------------------------------
    // Active video window & simple two-color split
    // ----------------------------------------------------------------
    wire active = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);
    wire left_half = (h_cnt < (H_VISIBLE>>1)); // 0..319 = left, 320..639 = right

    // Extract RGB444 colors from code
    wire [3:0] left_r  = code[23:20];
    wire [3:0] left_g  = code[19:16];
    wire [3:0] left_b  = code[15:12];

    wire [3:0] right_r = code[11:8];
    wire [3:0] right_g = code[7:4];
    wire [3:0] right_b = code[3:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red   <= 4'h0;
            green <= 4'h0;
            blue  <= 4'h0;
        end else begin
            if (active) begin
                if (left_half) begin
                    red   <= left_r;
                    green <= left_g;
                    blue  <= left_b;
                end else begin
                    red   <= right_r;
                    green <= right_g;
                    blue  <= right_b;
                end
            end else begin
                // Blanking
                red   <= 4'h0;
                green <= 4'h0;
                blue  <= 4'h0;
            end
        end
    end

endmodule
