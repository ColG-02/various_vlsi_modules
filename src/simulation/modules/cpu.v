module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16   
) (
    input  clk,
    input  rst_n,
    input  [DATA_WIDTH-1:0] mem,
    input  [DATA_WIDTH-1:0] in,
    input  control,
    output  status,
    output  we,
    output  [ADDR_WIDTH-1:0] addr,
    output  [DATA_WIDTH-1:0] data,
    output  [DATA_WIDTH-1:0] out,
    output  [ADDR_WIDTH-1:0] pc,
    output  [ADDR_WIDTH-1:0] sp
);

    localparam ADDR_HIGH = ADDR_WIDTH - 1;
    localparam DATA_HIGH = DATA_WIDTH - 1;
    localparam IR_WIDTH = 32;

    localparam [ADDR_HIGH:0] PROG_START = 6'd8;
    localparam [ADDR_HIGH:0] STACK_INIT = 6'd63;

    localparam S_FETCH = 2'd0, S_ADDR  = 2'd1, S_EXEC  = 2'd2;

    // ---------- outer state ----------
    reg [1:0] state, next_state;

    // ---------- micro-steps ----------
    reg [1:0] fetch_step, fetch_step_next;  // 0..3
    reg [2:0] addr_step,  addr_step_next;   // 0..7

    wire fetch_done = (fetch_step == 2'd1); // placeholder: 2 beats total
    wire addr_done  = (addr_step  == 3'd1); // placeholder: 2 beats total

    // ---------- registered outputs ----------
    reg                    we_reg,    we_next;
    reg [ADDR_WIDTH-1:0]   addr_reg,  addr_next;
    reg [DATA_WIDTH-1:0]   data_reg,  data_next;
    reg [DATA_WIDTH-1:0]   out_reg,   out_next;
    reg                    status_reg, status_next;

    assign we     = we_reg;
    assign addr   = addr_reg;
    assign data   = data_reg;
    assign out    = out_reg;
    assign status = status_reg;


    // PC
    reg pc_cl, pc_ld, pc_inc;
    wire  [ADDR_WIDTH-1:0] pc_in;
    reg [ADDR_HIGH:0] pc_in_next, pc_in_reg;
    wire [ADDR_WIDTH-1:0] pc_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) PC (
        .clk(clk), .rst_n(rst_n), .cl(pc_cl), .ld(pc_ld), .in(pc_in), .inc(pc_inc),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(pc_out)
    );

    assign pc_in = pc_in_reg;
    assign pc = pc_out;
    

    // SP
    reg sp_cl, sp_ld, sp_inc, sp_dec;
    wire  [ADDR_WIDTH-1:0] sp_in;
    reg [ADDR_HIGH:0] sp_in_reg, sp_in_next;
    wire [ADDR_WIDTH-1:0] sp_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) SP (
        .clk(clk),.rst_n(rst_n),.cl(sp_cl),.ld(sp_ld),.in(sp_in),.inc(sp_inc),.dec(sp_dec),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(sp_out)
    );

    assign sp_in = sp_in_reg;
    assign sp = sp_out;


    // IR
    reg ir_cl, ir_ld;
    wire [IR_WIDTH-1:0] ir_in;
    reg  [IR_WIDTH-1:0] ir_in_reg, ir_in_next;
    wire [IR_WIDTH-1:0] ir_out;

    register #(.DATA_WIDTH(IR_WIDTH)) IR (
        .clk(clk),.rst_n(rst_n),.cl(ir_cl),.ld(ir_ld),.in(ir_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(ir_out)
    );
    assign ir_in = ir_in_reg;

    // MAR
    reg mar_cl, mar_ld;
    reg  [ADDR_WIDTH-1:0] mar_in;
    wire [ADDR_WIDTH-1:0] mar_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) MAR (
        .clk(clk),.rst_n(rst_n),.cl(mar_cl),.ld(mar_ld),.in(mar_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(mar_out)
    );

    // MDR
    reg mdr_cl, mdr_ld;
    reg  [DATA_WIDTH-1:0] mdr_in;
    wire [DATA_WIDTH-1:0] mdr_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) MDR (
        .clk(clk),.rst_n(rst_n),.cl(mdr_cl),.ld(mdr_ld),.in(mdr_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(mdr_out)
    );

    // A
    reg a_cl, a_ld;
    reg  [DATA_WIDTH-1:0] a_in;
    wire [DATA_WIDTH-1:0] a_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) A (
        .clk(clk),.rst_n(rst_n),.cl(a_cl),.ld(a_ld),.in(a_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(a_out)
    );


    // R
    reg r_cl, r_ld;
    reg  [DATA_WIDTH-1:0] r_in;
    wire [DATA_WIDTH-1:0] r_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) R (
        .clk(clk),.rst_n(rst_n),.cl(r_cl),.ld(r_ld),.in(r_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(r_out)
    );

    assign data = data_reg;
    assign addr = addr_reg;
    assign we = we_reg;
    assign out = out_reg;

    wire [3:0]  opc = ir_out[15:12];
    wire [3:0]  op2 = ir_out[11:8];
    wire [3:0]  op1 = ir_out[7:4];
    wire [3:0]  op0 = ir_out[3:0];

    wire ind2  = op2[3];
    wire ind1  = op1[3];
    wire ind0  = op0[3];
    wire [2:0]  r2 = op2[2:0];
    wire [2:0]  r1 = op1[2:0];
    wire [2:0]  r0 = op0[2:0];

    wire [DATA_WIDTH-1:0] imm16 = ir_out[31:16];

    reg [DATA_WIDTH-1:0]  val1, val2;      
    reg [ADDR_WIDTH-1:0]  dest_addr0, dest_addr1, dest_addr2;

    reg booted;

    // 1) State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_FETCH;
            fetch_step  <= 2'd0;
            addr_step   <= 3'd0;
            booted     <= 1'b0;

            we_reg <= 1'b0;
            data_reg <= {DATA_WIDTH{1'b0}};
            addr_reg <= {ADDR_WIDTH{1'b0}};
            out_reg <= {DATA_WIDTH{1'b0}};
            status_reg <= 1'b0;

            pc_in_reg <= PROG_START;
            sp_in_reg <= STACK_INIT;
            ir_in_reg   <= {IR_WIDTH{1'b0}};
        end
        else begin
            state <= next_state;
            fetch_step     <= fetch_step_next; 
            addr_step      <= addr_step_next;
            booted     <= 1'b1;  
            
            we_reg <= we_next;
            addr_reg <= addr_next;
            data_reg <= data_next;
            out_reg <= out_next;
            status_reg <= status_next;

            pc_in_reg <= pc_in_next;
            sp_in_reg <= sp_in_next;
            ir_in_reg   <= ir_in_next;
        end
    end

    task deassert_all;
        begin
            // default registered outputs hold
            we_next     = we_reg;
            addr_next   = addr_reg;
            data_next   = data_reg;
            out_next    = out_reg;
            status_next = status_reg;

            // default micro-steps hold
            fetch_step_next= fetch_step;
            addr_step_next = addr_step;

            // default register controls deasserted
            pc_cl=0; pc_ld=0; pc_inc=0; pc_in_next = pc_in_reg;
            sp_cl=0; sp_ld=0; sp_inc=0; sp_dec=0;  sp_in_next = sp_in_reg;
            ir_cl=0; ir_ld=0; ir_in_next = ir_in_reg;
            // mar/mdr/a/r controls later...
        end 
    endtask

    
    // 2) Next-state + outputs (combinational)
    always @* begin
        deassert_all();
        next_state = state;
        if (!booted) begin
            pc_ld = 1'b1; pc_in_next = PROG_START;  // 6'd8
            sp_ld = 1'b1; sp_in_next = STACK_INIT;  // 6'd63
        end

        case (state)
            // ---------------- FETCH ----------------
            S_FETCH: begin
                case (fetch_step)
                    2'd0: begin
                        // Issue read at PC: mar <= pc_out
                        mar_in = pc_out;
                        mar_ld = 1'b1;
                        pc_inc = 1'b1;
                        fetch_step_next = 2'd1;
                    end
                    2'd1: begin
                        addr_next = mar_out;
                        fetch_step_next = 2'd2;
                    end
                    2'd2: begin
                        // Latch word0 into IR[15:0]; PC++
                        ir_ld        = 1'b1;
                        ir_in_next   = { ir_out[31:16], mem };
                        pc_inc       = 1'b1;

                        // (If some opcodes need word1, add steps 2/3 here.)
                        fetch_step_next = 2'd0;
                        next_state   = S_ADDR;
                    end

                endcase
            end

            // ---------------- ADDR -----------------
            S_ADDR: begin
                case (addr_step)
                    3'd0: begin
                        // (later) read operand GPRs / follow indirection
                        addr_step_next = 3'd1;
                    end
                    3'd1: begin
                        next_state   = S_EXEC;
                        addr_step_next  = 3'd0;
                    end
                endcase
            end

            // ---------------- EXEC -----------------
            S_EXEC: begin
                // (do ALU/writeback/pc updates)
                next_state = S_FETCH;
            end
        endcase
    end

    
endmodule