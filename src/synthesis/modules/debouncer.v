module debouncer (
    input clk,
    input rst_n,
    input in,
    output out
);

    // wire q0;
    // wire q1;
    // wire q2;

    // dff d0 (.clk(clk), .rst_n(rst_n), .d(in), .q(q0));
    // dff d1 (.clk(clk), .rst_n(rst_n), .d(q0), .q(q1));
    // dff d2 (.clk(clk), .rst_n(rst_n), .d(q1), .q(q2));

    // assign out = q0 & q1 & !q2;

    reg s0, s1, s2;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s0 <= 0; s1 <= 0; s2 <= 0;
        end else begin
            s2 <= s1;
            s1 <= s0;
            s0 <= in;
        end
    end

    assign out = s0 & s1 & ~s2;   // uses current registered values

endmodule