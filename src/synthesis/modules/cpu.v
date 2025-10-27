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
    output reg  we,
    output  [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data,
    output  [DATA_WIDTH-1:0] out,
    output  [ADDR_WIDTH-1:0] pc,
    output  [ADDR_WIDTH-1:0] sp
);

    localparam ADDR_HIGH = ADDR_WIDTH - 1;
    localparam DATA_HIGH = DATA_WIDTH - 1;
    localparam IR_WIDTH = 32;

    localparam [ADDR_HIGH:0] PROG_START = 6'd8;
    localparam [ADDR_HIGH:0] STACK_INIT = 6'd63;

    localparam S_FETCH = 2'd0, S_ADDR  = 2'd1, S_EXEC  = 2'd2, S_BOOT = 2'd3;

    // ---------- outer state ----------
    reg [1:0] state, next_state;

    // ---------- micro-steps ----------
    reg [3:0] fetch_step, fetch_step_next;  // 0..7
    reg [4:0] addr_step,  addr_step_next;   // 0..31
    reg [3:0] exec_step, exec_step_next;


    reg halted;           // latched “we are halted”
    reg halt_set;         // 1-cycle pulse from comb -> seq

    //assign status = halted;  // expose halt state if you want

    // ---------- DJUBRE ----------
    // reg                    we_reg,    we_next;
    // reg [ADDR_WIDTH-1:0]   addr_reg,  addr_next;
    // reg [DATA_WIDTH-1:0]   data_reg,  data_next;
    // reg [DATA_WIDTH-1:0]   out_reg,   out_next;
    // reg                    status_reg, status_next;

    // assign we     = we_reg;
    // assign addr   = addr_reg;
    // assign data   = data_reg;
    // assign out    = out_reg;
    // assign status = status_reg;


    // PC
    reg pc_cl, pc_ld, pc_inc;
    reg  [ADDR_WIDTH-1:0] pc_in;
    //reg [ADDR_HIGH:0] pc_in_next, pc_in_reg;
    //wire [ADDR_WIDTH-1:0] pc_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) PC (
        .clk(clk), .rst_n(rst_n), .cl(pc_cl), .ld(pc_ld), .in(pc_in), .inc(pc_inc),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(pc)
    );

    // assign pc_in = pc_in_reg;
    // assign pc = pc_out;
    

    // SP
    reg sp_cl, sp_ld, sp_inc, sp_dec;
    reg  [ADDR_WIDTH-1:0] sp_in;
    //reg [ADDR_HIGH:0] sp_in_reg, sp_in_next;
    //wire [ADDR_WIDTH-1:0] sp_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) SP (
        .clk(clk),.rst_n(rst_n),.cl(sp_cl),.ld(sp_ld),.in(sp_in),.inc(sp_inc),.dec(sp_dec),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(sp)
    );

    // assign sp_in = sp_in_reg;
    // assign sp = sp_out;


    // IR
    reg ir_cl, ir_ld;
    reg [IR_WIDTH-1:0] ir_in;
    //reg  [IR_WIDTH-1:0] ir_in_reg, ir_in_next;
    wire [IR_WIDTH-1:0] ir_out;

    register #(.DATA_WIDTH(IR_WIDTH)) IR (
        .clk(clk),.rst_n(rst_n),.cl(ir_cl),.ld(ir_ld),.in(ir_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(ir_out)
    );
    //assign ir_in = ir_in_reg;

    // MAR
    reg mar_cl, mar_ld;
    reg  [ADDR_WIDTH-1:0] mar_in;
    //wire [ADDR_WIDTH-1:0] mar_out;

    register #(.DATA_WIDTH(ADDR_WIDTH)) MAR (
        .clk(clk),.rst_n(rst_n),.cl(mar_cl),.ld(mar_ld),.in(mar_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(addr)
    );

    // MDR
    reg mdr_cl, mdr_ld;
    //reg  [DATA_WIDTH-1:0] mdr_in;
    wire [DATA_WIDTH-1:0] mdr_out;

    register #(.DATA_WIDTH(DATA_WIDTH)) MDR (
        .clk(clk),.rst_n(rst_n),.cl(mdr_cl),.ld(mdr_ld),.in(mem),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(mdr_out)
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
        .clk(clk),.rst_n(rst_n),.cl(r_cl),.ld(r_ld),.in(r_in),.inc(1'b0),.dec(1'b0),.sr(1'b0),.ir(1'b0),.sl(1'b0),.il(1'b0),.out(out)
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

    // assign data = data_reg;
    // assign addr = addr_reg;
    // assign we = we_reg;
    // assign out = out_reg;

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

    // reg [DATA_WIDTH-1:0]  valx, valy, valz;

    reg [ADDR_WIDTH-1:0]  dest_addrx_reg, dest_addry_reg, dest_addrz_reg;
    reg [ADDR_WIDTH-1:0]  dest_addrx_next, dest_addry_next, dest_addrz_next;

    //reg booted;

    // 1) State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_BOOT;
            fetch_step  <= 4'd0;
            addr_step   <= 5'd0;
            exec_step <= 4'd0;
            halted    <= 1'b0;

            // we_reg <= 1'b0;
            // data_reg <= {DATA_WIDTH{1'b0}};
            // addr_reg <= {ADDR_WIDTH{1'b0}};
            // out_reg <= {DATA_WIDTH{1'b0}};
            // status_reg <= 1'b0;

            //pc_in_reg <= PROG_START;
            //sp_in_reg <= STACK_INIT;
            //ir_in_reg   <= {IR_WIDTH{1'b0}};

            dest_addrx_reg <= {ADDR_WIDTH{1'b0}};
            dest_addry_reg <= {ADDR_WIDTH{1'b0}};
            dest_addrz_reg <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            state <= next_state;
            fetch_step <= fetch_step_next; 
            addr_step <= addr_step_next;
            exec_step <= exec_step_next;
            
            if (halt_set) halted <= 1'b1;
            
            // we_reg <= we_next;
            // addr_reg <= addr_next;
            // data_reg <= data_next;
            // out_reg <= out_next;
            // status_reg <= status_next;

            //pc_in_reg <= pc_in_next;
            //sp_in_reg <= sp_in_next;
            //ir_in_reg   <= ir_in_next;

            dest_addrx_reg <= dest_addrx_next;
            dest_addry_reg <= dest_addry_next;
            dest_addrz_reg <= dest_addrz_next;
        end
    end

    task deassert_all;
        begin
            // default registered outputs hold
            // we_next     = we_reg;
            // addr_next   = addr_reg;
            // data_next   = data_reg;
            // out_next    = out_reg;
            // status_next = status_reg;
            halt_set = 1'b0;
            // default micro-steps hold
            fetch_step_next= fetch_step;
            addr_step_next = addr_step;
            exec_step_next = exec_step;

            // default register controls deasserted
            pc_cl=0; pc_ld=0; pc_inc=0; 
            //pc_in_next = pc_in_reg;
            sp_cl=0; sp_ld=0; sp_inc=0; sp_dec=0;
            //  sp_in_next = sp_in_reg;
            ir_cl=0; ir_ld=0; 
            //ir_in_next = ir_in_reg;

            mar_ld=1'b0;  mdr_ld=1'b0;
            x_ld =1'b0;   y_ld =1'b0;   z_ld =1'b0;
            a_ld =1'b0;
            r_ld = 1'b0;
            r_in = {DATA_WIDTH{1'b0}};

            // mar/mdr/a/r controls later...
            mar_in  = {ADDR_WIDTH{1'b0}};
            //mdr_in  = {DATA_WIDTH{1'b0}};

            we   = 1'b0;                     // <= important
            data = {DATA_WIDTH{1'b0}};       // default, set when writing
            //out  = out;  

            dest_addrx_next = dest_addrx_reg;
            dest_addry_next = dest_addry_reg;
            dest_addrz_next = dest_addrz_reg;
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
    function needs_ext;
        input [3:0] op;
        begin
            case (op)
            // OP_JMPA, OP_LDI, OP_CALL: needs_ext = 1'b1;
            default: needs_ext = 1'b0;
            endcase
        end
    endfunction

    function [2:0] op_mask;
        input [3:0] op;
        begin
            case (op)
            OP_MOV:                         op_mask = 3'b110;
            OP_ADD, OP_SUB, OP_MUL, OP_DIV: op_mask = 3'b111;
            OP_OUT:                         op_mask = 3'b100;
            OP_IN:                          op_mask = 3'b100;
            OP_STOP:                        op_mask = 3'b111;
            default:                        op_mask = 3'b000;
            endcase
        end
    endfunction

    wire [2:0] mask = op_mask(opc);
    wire uses_x      = mask[2];
    wire uses_y      = mask[1];
    wire uses_z      = mask[0];

    wire [DATA_WIDTH-1:0] alu_f;
    wire [2:0] alu_oc = (opc >= OP_ADD && opc <= OP_DIV) ? (opc[2:0] - 3'b001) : 3'b000;

    alu #(.DATA_WIDTH(DATA_WIDTH)) U_ALU (
    .oc(alu_oc),
    .a(y_out),
    .b(z_out),
    .f(alu_f)
    );

    wire do_write =
    (opc==OP_MOV) | (opc==OP_ADD) | (opc==OP_SUB) |
    (opc==OP_MUL) | (opc==OP_DIV) | (opc==OP_IN);

    wire stop = (opc==OP_STOP);
    wire x_nz = |x_out;
    wire y_nz = |y_out;
    wire z_nz = |z_out;

    
    // 2) Next-state + outputs (combinational)
    always @* begin
        deassert_all();
        if (halted) begin
            next_state     = S_EXEC;
            exec_step_next = 4'd15;   // stay in HALT
        end
        next_state = state;
        // if (!booted) begin
        //     next_state = S_BOOT;
        // end
        case (state)
            S_BOOT: begin
                pc_ld = 1'b1; pc_in = PROG_START;  // 6'd8
                sp_ld = 1'b1; sp_in = STACK_INIT;  // 6'd63
                next_state = S_FETCH;
            end
            // ---------------- FETCH ----------------
            S_FETCH: begin
                case (fetch_step)
                    // ---- WORD0 ----
                    4'd0: begin // MAR <- PC "N"
                        mar_in  = pc;
                        mar_ld  = 1'b1;
                        fetch_step_next = 4'd1;
                    end
                    4'd1: begin // Issue memory read at MAR
                        //addr = mar_out;   MAR_OUT direktno povezan na ADDR
                        we = 1'b0;      // read
                        fetch_step_next = 4'd2;
                    end
                    4'd2: begin // *** wait/bubble *** (nothing but hold)
                        fetch_step_next = 4'd3;   // data becomes valid on next clock
                    end
                    4'd3: begin
                        // Capture memory word into MDR
                        //mdr_in  = mem; direkt
                        mdr_ld  = 1'b1;
                        fetch_step_next = 4'd4;
                    end
                    4'd4: begin // IR {WORD1, WORD0}
                        // IR[15:0] <- MDR ; PC++
                        // sp_ld = 1'b1;
                        // sp_in = mdr_out[15:12];
                        ir_ld = 1'b1;
                        ir_in = { ir_out[31:16], mdr_out };
                        pc_inc = 1'b1;
                        // Need a second word?
                        fetch_step_next = 4'd5;
                    end
                    4'd5: begin
                        if (needs_ext(mdr_out[15:12])) begin
                            fetch_step_next = 4'd6;   // go fetch WORD1
                        end else begin
                            fetch_step_next = 4'd0;
                            next_state = S_ADDR; // done fetching
                        end
                    end
                    // ---- WORD1 (only if needed) ----
                    4'd6: begin
                        // MAR <- PC
                        mar_in = pc;
                        mar_ld = 1'b1;
                        fetch_step_next = 4'd7;
                    end
                    4'd7: begin
                        // Issue memory read at MAR
                        //addr_next = mar_out;
                        we = 1'b0;
                        fetch_step_next = 4'd8;
                    end
                    4'd8: begin // *** wait/bubble *** (nothing but hold)
                        fetch_step_next = 4'd9;   // data becomes valid on next clock
                    end
                    4'd9: begin
                        // Capture memory word into MDR
                        //mdr_in  = mem; direkt
                        mdr_ld  = 1'b1;
                        fetch_step_next = 4'd10;
                    end
                    4'd10: begin
                        // IR[31:16] <- MDR ; PC++
                        ir_ld = 1'b1;
                        ir_in = { mdr_out, ir_out[15:0] };
                        pc_inc = 1'b1;
                        fetch_step_next = 4'd11;
                    end
                    4'd11: begin
                        fetch_step_next = 4'd0;
                        next_state = S_ADDR;         // leave fetch with IR stable
                    end
                endcase
            end
            // ---------------- ADDR -----------------
            S_ADDR: begin
                case (addr_step)
                    // ===== X (0..8) =====
                    5'd0: begin // MAR <= rx (base)
                        if (uses_x) begin
                            mar_ld = 1'b1;
                            mar_in = {{(ADDR_WIDTH-3){1'b0}}, rx};
                            addr_step_next = 5'd1;
                        end else begin
                            addr_step_next = 5'd9; // skip to Y
                        end
                    end
                    5'd1: begin // ISSUE base(X)
                        //addr_next = mar_out;
                        we   = 1'b0;
                        addr_step_next = 5'd2;
                    end
                    5'd2: begin // BUBBLE (sync BRAM)
                        addr_step_next = 5'd3;
                    end
                    5'd3: begin // CAPTURE base(X)
                        mdr_ld = 1'b1;
                        //mdr_in = mem; direkt
                        addr_step_next = 5'd4;
                    end
                    5'd4: begin // direct / indirect?
                        if (indx) begin
                            mar_ld = 1'b1;
                            mar_in = mdr_out[ADDR_WIDTH-1:0];    // pointer
                            dest_addrx_next = mdr_out[ADDR_WIDTH-1:0];
                            addr_step_next = 5'd5;
                        end else begin
                            x_ld = 1'b1;
                            x_in = mdr_out;                      // direct value
                            dest_addrx_next = {{(ADDR_WIDTH-3){1'b0}}, rx};
                            addr_step_next = 5'd9;               // go to Y
                        end
                    end
                    5'd5: begin // ISSUE X pointer target
                        //addr_next = mar_out;
                        we   = 1'b0;
                        addr_step_next = 5'd6;
                    end
                    5'd6: begin // BUBBLE
                        addr_step_next = 5'd7;
                    end
                    5'd7: begin // CAPTURE X pointer target
                        mdr_ld = 1'b1;
                        //mdr_in = mem; direkt
                        addr_step_next = 5'd8;
                    end
                    5'd8: begin // LOAD X (indirect)
                        x_ld = 1'b1;
                        x_in = mdr_out;
                        addr_step_next = 5'd9;                 // go to Y
                    end
                    // ===== Y (9..17) =====
                    5'd9: begin // MAR <= ry
                        if (uses_y) begin
                            mar_ld = 1'b1;
                            mar_in = {{(ADDR_WIDTH-3){1'b0}}, ry};
                            addr_step_next = 5'd10;
                        end else begin
                            addr_step_next = 5'd18;              // skip to Z
                        end
                    end
                    5'd10: begin // ISSUE base(Y)
                        //addr_next = mar_out;
                        we  = 1'b0;
                        addr_step_next = 5'd11;
                    end
                    5'd11: begin // BUBBLE
                        addr_step_next = 5'd12;
                    end
                    5'd12: begin // CAPTURE base(Y)
                        mdr_ld = 1'b1;
                        //mdr_in = mem;
                        addr_step_next = 5'd13;
                    end
                    5'd13: begin // direct / indirect?
                        if (indy) begin
                            mar_ld = 1'b1;
                            mar_in = mdr_out[ADDR_WIDTH-1:0];
                            dest_addry_next = mdr_out[ADDR_WIDTH-1:0];
                            addr_step_next = 5'd14;
                        end else begin
                            y_ld = 1'b1;
                            y_in = mdr_out;
                            dest_addry_next = {{(ADDR_WIDTH-3){1'b0}}, ry};
                            addr_step_next = 5'd18;              // go to Z
                        end
                    end
                    5'd14: begin // ISSUE Y pointer target
                        //addr_next = mar_out;
                        we   = 1'b0;
                        addr_step_next = 5'd15;
                    end
                    5'd15: begin // BUBBLE
                        addr_step_next = 5'd16;
                    end
                    5'd16: begin // CAPTURE Y pointer target
                        mdr_ld = 1'b1;
                        //mdr_in = mem;
                        addr_step_next = 5'd17;
                    end
                    5'd17: begin // LOAD Y (indirect)
                        y_ld = 1'b1;
                        y_in = mdr_out;
                        addr_step_next = 5'd18;                // go to Z
                    end
                    // ===== Z (18..26) =====
                    5'd18: begin // MAR <= rz
                        if (uses_z) begin
                            mar_ld = 1'b1;
                            mar_in = {{(ADDR_WIDTH-3){1'b0}}, rz};
                            addr_step_next = 5'd19;
                        end else begin
                            addr_step_next = 5'd27;              // done
                        end
                    end
                    5'd19: begin // ISSUE base(Z)
                        //addr_next = mar_out;
                        we  = 1'b0;
                        addr_step_next = 5'd20;
                    end
                    5'd20: begin // BUBBLE
                        addr_step_next = 5'd21;
                    end
                    5'd21: begin // CAPTURE base(Z)
                        mdr_ld = 1'b1;
                        //mdr_in = mem;
                        addr_step_next = 5'd22;
                    end
                    5'd22: begin // direct / indirect?
                        if (indz) begin
                            mar_ld = 1'b1;
                            mar_in = mdr_out[ADDR_WIDTH-1:0];
                            dest_addrz_next = mdr_out[ADDR_WIDTH-1:0];
                            addr_step_next = 5'd23;
                        end else begin
                            z_ld = 1'b1;
                            z_in = mdr_out;
                            dest_addrz_next = {{(ADDR_WIDTH-3){1'b0}}, rz};
                            addr_step_next = 5'd27;              // done
                        end
                    end
                    5'd23: begin // ISSUE Z pointer target
                        //addr_next = mar_out;
                        we  = 1'b0;
                        addr_step_next = 5'd24;
                    end
                    5'd24: begin // BUBBLE
                        addr_step_next = 5'd25;
                    end
                    5'd25: begin // CAPTURE Z pointer target
                        mdr_ld = 1'b1;
                        //mdr_in = mem;
                        addr_step_next = 5'd26;
                    end
                    5'd26: begin // LOAD Z (indirect)
                        z_ld = 1'b1;
                        z_in = mdr_out;
                        addr_step_next = 5'd27;                // done
                    end
                    // ===== done =====
                    5'd27: begin
                        addr_step_next = 5'd0;
                        next_state     = S_EXEC;
                    end
                endcase
            end
            // ---------------- EXEC -----------------
            S_EXEC: begin
                case (exec_step)
                    4'd0: begin
                    case (opc)
                        // -------- separate cases --------
                        OP_MOV: begin
                        mar_in = dest_addrx_reg;  
                        mar_ld = 1'b1;
                        a_ld   = 1'b1;            
                        a_in   = y_out;
                        exec_step_next = 4'd1;
                        end

                        OP_IN: begin
                        mar_in = dest_addrx_reg;  
                        mar_ld = 1'b1;
                        a_ld   = 1'b1;            
                        a_in   = in;
                        exec_step_next = 4'd1;
                        end

                        // -------- ALU group --------
                        OP_ADD, OP_SUB, OP_MUL, OP_DIV: begin
                        mar_in = dest_addrx_reg;  
                        mar_ld = 1'b1;
                        a_ld   = 1'b1;            
                        a_in   = alu_f;
                        exec_step_next = 4'd1;
                        end

                        // -------- OUT --------
                        OP_OUT: begin
                        r_ld = 1'b1; 
                        r_in = x_out;
                        exec_step_next = 4'd1;
                        end

                        // -------- STOP (print up to three non-zero: X -> Y -> Z) --------
                        OP_STOP: begin
                        if (rx != 3'b000) begin r_ld = 1'b1; r_in = x_out; end
                        exec_step_next = 4'd8;
                        end

                        default: exec_step_next = 4'd1;
                    endcase
                    end

                    // normal memory writeback (skipped for STOP/OUT)
                    4'd1: begin
                    if (!stop && (opc==OP_MOV || opc==OP_IN
                                    || opc==OP_ADD || opc==OP_SUB || opc==OP_MUL || opc==OP_DIV)) begin
                        we   = 1'b1;
                        data = a_out;
                    end
                    exec_step_next = 4'd2;
                    end

                    4'd2: begin
                    if (!stop) begin
                        we = 1'b0;
                        exec_step_next = 4'd3;   // write bubble
                    end else begin
                        exec_step_next = 4'd2;   // not used for STOP
                    end
                    end

                    4'd3: begin
                    next_state = S_FETCH;
                    exec_step_next = 4'd0;
                    end

                    // -------- STOP continuation Y--------
                    4'd8: begin
                    if (ry != 3'b000) begin r_ld = 1'b1; r_in = y_out;end
                    exec_step_next = 4'd9;
                    end

                    // -------- STOP continuation Y--------
                    4'd9: begin
                    if (rz != 3'b000) begin r_ld = 1'b1; r_in = z_out; end
                    exec_step_next = 4'd10;
                    end

                    4'd10: begin
                    exec_step_next = 4'd15;
                    end

                    // HALT state (park here)
                    4'd15: begin
                    next_state     = S_EXEC;
                    exec_step_next = 4'd15;
                    end
                endcase
                end
        endcase
    end

endmodule