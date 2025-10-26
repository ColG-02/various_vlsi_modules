// ps2.v
// Last two successfully read PS/2 bytes:
//   - newest byte in code[7:0]
//   - previous byte in code[15:8]
module ps2 (
    input  wire       clk,        // system clock
    input  wire       rst_n,      // async active-low reset
    input  wire       ps2_clk,    // raw PS/2 clock from keyboard
    input  wire       ps2_data,   // raw PS/2 data from keyboard
    output reg [15:0] code        // {prev, last}
);
    // ============================================================
    // Bring ps2_clk / ps2_data safely into clk domain (2FF sync)
    // ============================================================
    reg c0, c1, d0, d1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            c0 <= 1'b1; c1 <= 1'b1;   // idle ps2_clk is high
            d0 <= 1'b1; d1 <= 1'b1;   // idle ps2_data is high
        end else begin
            c0 <= ps2_clk; c1 <= c0;
            d0 <= ps2_data; d1 <= d0;
        end
    end

    // One-cycle pulse in clk domain on PS/2 falling edge
    wire ps2_fall = (c1 & ~c0);

    // ============================================================
    // Simple PS/2 frame receiver (start, 8 data bits LSB-first,
    // odd parity, stop)
    // ============================================================
    localparam WAIT_START = 2'd0,
               READ_BITS  = 2'd1,
               READ_PAR   = 2'd2,
               READ_STOP  = 2'd3;

    reg [1:0] state;
    reg [3:0] bit_cnt;      // counts 0..7 for 8 data bits
    reg [7:0] shift;        // assembled data byte (LSB first)
    reg       parity_bit;   // received parity

    // Synchronous FSM driven only when a ps2_fall occurs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= WAIT_START;
            bit_cnt    <= 4'd0;
            shift      <= 8'h00;
            parity_bit <= 1'b0;
            code       <= 16'h0000;
        end else if (ps2_fall) begin
            case (state)
                WAIT_START: begin
                    // Start bit must be 0
                    if (d1 == 1'b0) begin
                        bit_cnt <= 4'd0;
                        state   <= READ_BITS;
                    end
                end

                READ_BITS: begin
                    // Sample 8 data bits, LSB first
                    shift[bit_cnt] <= d1;
                    if (bit_cnt == 4'd7)
                        state <= READ_PAR;
                    else
                        bit_cnt <= bit_cnt + 4'd1;
                end

                READ_PAR: begin
                    parity_bit <= d1;     // capture parity
                    state      <= READ_STOP;
                end

                READ_STOP: begin
                    // Stop bit must be 1, and parity must be odd
                    if (d1 == 1'b1 && ((^shift) == ~parity_bit)) begin
                        // Push newest byte into low 8 bits
                        code <= {code[7:0], shift};
                    end
                    // In any case, get ready for next frame
                    state <= WAIT_START;
                end
            endcase
        end
    end
endmodule
