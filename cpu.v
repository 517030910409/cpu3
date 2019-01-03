module cpu(
    input  wire         clk_in,			// system clock signal
    input  wire         rst_in,			// reset signal
    input  wire         rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]  mem_din,		// data input bus
    output wire [ 7:0]  mem_dout,		// data output bus
    output wire [31:0]  mem_a,			// address bus (only 17:0 is used)
    output wire         mem_wr,			// write/read signal (1 for write)

    output wire [31:0]	dbgreg_dout		// cpu register output (debugging demo)
);
    reg  [ 4:0] cnt;
    reg  [31:0] pc;
    wire [31:0] inst, IF_pc;
    reg  [31:0] regs [31:0];
    reg         IFe, IDe, EXe, MAe;
    wire [31:0] IF_mema, MA_mema;
    
    IF IF0(
        .clk(clk_in),
        .rst(rst_in),
        .rdy(rdy_in),
        .e_i(IFe),
        .memd_i(mem_din),
        .mema_o(IF_mema),
        .pc_i(pc),
        .pc_o(IF_pc),
        .inst_o(inst)
    );
    
    wire [ 4:0] ID_op, reg1a, reg2a, ID_regd;
    wire [ 2:0] ID_sel;
    wire [31:0] imm, ID_pc;
    wire [31:0] reg1d, reg2d;
    
    ID ID0(
        .clk(clk_in),
        .rst(rst_in),
        .rdy(rdy_in),
        .e_i(IDe),
        .inst_i(inst),
        .pc_i(IF_pc),
        .pc_o(ID_pc),
        .imm_o(imm),
        .op_o(ID_op),
        .sel_o(ID_sel),
        .reg1a_o(reg1a),
        .reg2a_o(reg2a),
        .regd_o(ID_regd)
    );
    
    wire [31:0] EX_res;
    wire [31:0] jump, EX_mema;
    wire [ 4:0] EX_op, EX_regd;
    wire [ 2:0] EX_sel;
    
    EX EX0(
        .clk(clk_in),
        .rst(rst_in),
        .rdy(rdy_in),
        .e_i(EXe),
        .op_i(ID_op),
        .sel_i(ID_sel),
        .reg1d_i(reg1d),
        .reg2d_i(reg2d),
        .pc_i(ID_pc),
        .imm_i(imm),
        .regd_i(ID_regd),
        .op_o(EX_op),
        .regd_o(EX_regd),
        .sel_o(EX_sel),
        .res_o(EX_res),
        .addr_o(EX_mema),
        .jump_o(jump)
    );
    
    wire [31:0] MA_res;
    wire [ 4:0] MA_regd;
    
    MA MA0(
        .clk(clk_in),
        .rst(rst_in),
        .rdy(rdy_in),
        .e_i(MAe),
        .res_i(EX_res),
        .addr_i(EX_mema),
        .regd_i(EX_regd),
        .sel_i(EX_sel),
        .memd_i(mem_din),
        .op_i(EX_op),
        .mema_o(MA_mema),
        .memd_o(mem_dout),
        .res_o(MA_res),
        .memwe_o(mem_wr),
        .regd_o(MA_regd)
    );
    
    integer i;
    initial begin
        for (i=0; i<32; i=i+1) begin
            regs[i] = 0;
        end
    end
    
    reg ma, jc;
    
    always @(posedge clk_in) begin
        if (rst_in) begin
            pc <= 1'b0;
            cnt <= 1'b0;
            regs[0] = 0;
            IFe <= 1'b0;
            IDe <= 1'b0;
            EXe <= 1'b0;
            MAe <= 1'b0;
            ma <= 1'b0;
            jc <= 1'b1;
        end else if (rdy_in) begin
            cnt <= cnt == 5'h0b ? (jc ? ma ? 5'h0c : 5'h06 : 5'h00) : cnt == 5'h13 ? 5'h08 : cnt + 1'b1;
            IFe <= cnt < 5'h0c || 5'h11 < cnt;
            if (cnt == 5'h05) pc <= pc + 3'h4;
            if (cnt == 5'h0b) pc <= pc + (jc ? 3'h4 : jump - 3'h4);
            IDe <= cnt == 5'h07 || cnt == 5'h13;
            if (cnt == 5'h09) ma <= ID_op == 5'b00000 || ID_op == 5'b01000;
            EXe <= cnt == 5'h08;
            if (cnt == 5'h0a) jc <= EX_res == 1'b0 || jump == 3'h4;
            if (cnt == 5'h0a && !ma && EX_regd) regs[EX_regd] <= EX_res;
            MAe <= 5'h0b < cnt && cnt < 5'h12;
            if (cnt == 5'h13 && MA_regd) regs[MA_regd] <= MA_res;
        end
    end
    
    assign mem_a = (IFe ? IF_mema : 1'b0) | (MAe? MA_mema : 1'b0);
    assign reg1d = regs[reg1a];
    assign reg2d = regs[reg2a];
    
endmodule
