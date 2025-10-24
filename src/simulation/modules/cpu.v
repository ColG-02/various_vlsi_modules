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
    reg [2:0] fetch_step, fetch_step_next;  // 0..7
    reg [4:0] addr_step,  addr_step_next;   // 0..31

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


    // X
    reg x_cl, x_ld;
    reg  [DATA_WIDTH-1:0] x_in;
    wire [DATA_WIDTH-1:0] x_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) X (
        .clk(clk),.rst_n(rst_n),.cl(x_cl),.ld(x_ld),.in(x_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(x_out)
    );

    // Y
    reg y_cl, y_ld;
    reg  [DATA_WIDTH-1:0] y_in;
    wire [DATA_WIDTH-1:0] y_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) Y (
        .clk(clk),.rst_n(rst_n),.cl(y_cl),.ld(y_ld),.in(y_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(y_out)
    );

    // Z
    reg z_cl, z_ld;
    reg  [DATA_WIDTH-1:0] z_in;
    wire [DATA_WIDTH-1:0] z_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) Z (
        .clk(clk),.rst_n(rst_n),.cl(z_cl),.ld(z_ld),.in(z_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(z_out)
    );

    assign data = data_reg;
    assign addr = addr_reg;
    assign we = we_reg;
    assign out = out_reg;

    wire [3:0] opc = ir_out[15:12];
    wire [3:0] opx = ir_out[11:8];
    wire [3:0] opy = ir_out[7:4];
    wire [3:0] opz = ir_out[3:0];

    wire indx = opx[3];
    wire indy = opy[3];
    wire indz = opz[3];
    wire [2:0] rx = opx[2:0];
    wire [2:0] ry = opy[2:0];
    wire [2:0] rz = opz[2:0];

    wire [DATA_WIDTH-1:0] imm16 = ir_out[31:16];

    reg [DATA_WIDTH-1:0]  valx, valy, valz;      
    reg [ADDR_WIDTH-1:0]  dest_addrx, dest_addry, dest_addrz;

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
            fetch_step <= fetch_step_next; 
            addr_step <= addr_step_next;
            booted <= 1'b1;  
            
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

    // opcode names
    localparam [3:0]
        OP_MOV  = 4'h0,
        OP_ADD  = 4'h1, OP_SUB  = 4'h2, OP_MUL  = 4'h3, OP_DIV  = 4'h4,
        OP_IN   = 4'h7,
        OP_OUT  = 4'h8,
        OP_STOP = 4'hF;
    
    // Helper: which opcodes need a second word? (example list)
    function automatic logic needs_ext (input logic [3:0] op);
        case (op)
            //OP_JMPA, OP_LDI, OP_CALL: needs_ext = 1'b1;  
            default:                  needs_ext = 1'b0;  
        endcase
    endfunction

    // mask = {uses_x, uses_y, uses_z_addr}
    function automatic logic [2:0] op_mask (input logic [3:0] op);
    case (op)
        OP_MOV:                         op_mask = 3'b101;
        OP_ADD, OP_SUB, OP_MUL, OP_DIV: op_mask = 3'b111;
        OP_OUT:                         op_mask = 3'b100;
        OP_IN:                          op_mask = 3'b001;
        OP_STOP:                        op_mask = 3'b000;
        default:                        op_mask = 3'b000;
    endcase
    endfunction

    wire [2:0] mask = op_mask(opc);
    wire uses_x      = mask[2];
    wire uses_y      = mask[1];
    wire uses_z      = mask[0];
    
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
                    // ---- WORD0 ----
                    3'd0: begin // MAR <- PC
                        mar_in  = pc_out;
                        mar_ld  = 1'b1;
                        fetch_step_next = 3'd1;
                    end
                    3'd1: begin // Issue memory read at MAR
                        addr_next = mar_out;   // drive CPU->MEM address bus
                        we_next = 1'b0;      // read
                        fetch_step_next = 3'd2;
                    end
                    3'd2: begin
                        // Capture memory word into MDR
                        mdr_in  = mem;
                        mdr_ld  = 1'b1;
                        fetch_step_next = 3'd3;
                    end
                    3'd3: begin // IR {WORD1, WORD0}
                        // IR[15:0] <- MDR ; PC++
                        ir_ld = 1'b1;
                        ir_in_next = { ir_out[31:16], mdr_out };
                        pc_inc = 1'b1;

                        // Need a second word?
                        if (needs_ext(mdr_out[15:12])) begin
                            fetch_step_next = 3'd4;   // go fetch WORD1
                        end else begin
                            fetch_step_next = 3'd0;
                            next_state = S_ADDR; // done fetching
                        end
                    end
                    // ---- WORD1 (only if needed) ----
                    3'd4: begin
                        // MAR <- PC
                        mar_in = pc_out;
                        mar_ld = 1'b1;
                        fetch_step_next = 3'd5;
                    end
                    3'd5: begin
                        // Issue memory read at MAR
                        addr_next = mar_out;
                        we_next = 1'b0;
                        fetch_step_next = 3'd6;
                    end
                    3'd6: begin
                        // Capture memory word into MDR
                        mdr_in  = mem;
                        mdr_ld  = 1'b1;
                        fetch_step_next = 3'd7;
                    end
                    3'd7: begin
                        // IR[31:16] <- MDR ; PC++
                        ir_ld = 1'b1;
                        ir_in_next = { mdr_out, ir_out[15:0] };
                        pc_inc = 1'b1;
                        fetch_step_next = 3'd0;
                        next_state = S_ADDR;
                    end
                endcase
            end
            // ---------------- ADDR -----------------
            S_ADDR: begin
                case (addr_step)
                    // ===== X (steps 0..5) =====
                    5'd0: begin
                    if (uses_x) begin
                            mar_ld         = 1'b1;
                            mar_in         = {{(ADDR_WIDTH-3){1'b0}}, rx};  // base addr = rx
                            addr_step_next = 5'd1;
                        end else begin
                            addr_step_next = 5'd6; // skip to Y
                        end
                    end
                    5'd1: begin // ISSUE base(X)
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd2;
                    end
                    5'd2: begin // CAPTURE base(X)
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        addr_step_next  = 5'd3;
                    end
                    5'd3: begin // decide direct/indirect
                    if (indx) begin
                            mar_ld         = 1'b1;  mar_in   = mdr_out;       // pointer
                            addr_step_next = 5'd4;
                        end else begin
                            valx           = mdr_out;                          // direct value
                            dest_addrx     = {{(ADDR_WIDTH-3){1'b0}}, rx};     // base as EA
                            addr_step_next = 5'd6;                             // go to Y
                        end
                    end
                    5'd4: begin // ISSUE X pointer target
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd5;
                    end
                    5'd5: begin // CAPTURE X pointer target
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        valx            = mdr_out;
                        dest_addrx      = mar_out;                            // EA = pointer
                        addr_step_next  = 5'd6;
                        // ===== Y (steps 6..11) =====
                    end 
                    5'd6: begin
                    if (uses_y) begin
                            mar_ld         = 1'b1;
                            mar_in         = {{(ADDR_WIDTH-3){1'b0}}, ry};
                            addr_step_next = 5'd7;
                        end else begin
                            addr_step_next = 5'd12; // skip to Z
                        end
                    end
                    5'd7: begin // ISSUE base(Y)
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd8;
                    end
                    5'd8: begin // CAPTURE base(Y)
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        addr_step_next  = 5'd9;
                    end
                    5'd9: begin // decide direct/indirect
                    if (indy) begin
                            mar_ld         = 1'b1;  mar_in   = mdr_out;
                            addr_step_next = 5'd10;
                        end else begin
                            valy           = mdr_out;
                            dest_addry     = {{(ADDR_WIDTH-3){1'b0}}, ry};
                            addr_step_next = 5'd12;
                        end
                    end
                    5'd10: begin // ISSUE Y pointer target
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd11;
                    end
                    5'd11: begin // CAPTURE Y pointer target
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        valy            = mdr_out;
                        dest_addry      = mar_out;
                        addr_step_next  = 5'd12;
                    // ===== Z (steps 12..17) — same as X/Y =====
                    end 
                    5'd12: begin
                    if (uses_z) begin
                            mar_ld         = 1'b1;
                            mar_in         = {{(ADDR_WIDTH-3){1'b0}}, rz};
                            addr_step_next = 5'd13;
                        end else begin
                            addr_step_next = 5'd18; // done
                        end
                    end
                    5'd13: begin // ISSUE base(Z)
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd14;
                    end
                    5'd14: begin // CAPTURE base(Z)
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        addr_step_next  = 5'd15;
                    end
                    5'd15: begin // decide direct/indirect
                    if (indz) begin
                        mar_ld         = 1'b1;  mar_in   = mdr_out;
                        addr_step_next = 5'd16;
                    end else begin
                        valz           = mdr_out;                          // symmetry
                        dest_addrz     = {{(ADDR_WIDTH-3){1'b0}}, rz};     // EA for Z
                        addr_step_next = 5'd18;
                    end
                    end
                    5'd16: begin // ISSUE Z pointer target
                        addr_next       = mar_out; we_next = 1'b0;
                        addr_step_next  = 5'd17;
                    end
                    5'd17: begin // CAPTURE Z pointer target
                        mdr_ld          = 1'b1;   mdr_in   = mem;
                        valz            = mdr_out;             // symmetry (value at EA)
                        dest_addrz      = mar_out;             // EA for Z
                        addr_step_next  = 5'd18;
                    // ===== done =====
                    end 5'd18: begin
                        addr_step_next  = 5'd0;
                        next_state      = S_EXEC;
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