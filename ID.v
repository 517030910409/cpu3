module ID(
    input  wire        clk,
    input  wire        rst,
    input  wire        rdy,
    input  wire        e_i,
    input  wire [31:0] inst_i,
    input  wire [31:0] pc_i,
    output reg  [31:0] pc_o,
    output reg  [31:0] imm_o,
    output reg  [ 4:0] op_o,
    output reg  [ 2:0] sel_o,
    output reg  [ 4:0] reg1a_o,
    output reg  [ 4:0] reg2a_o,
    output reg  [ 4:0] regd_o
);
    
wire lui, jal, b, jalr, l, s;
wire i11, i12, i20;

always @(posedge clk) begin
    if (rst) begin
        imm_o <= 1'b0;
        op_o <= 4'hf;
        sel_o <= 1'b0;
        reg1a_o <= 1'b0;
        reg2a_o <= 1'b0;
        regd_o <= 1'b0;
        pc_o <= 1'b0;
    end else if (rdy && e_i) begin
        pc_o <= pc_i;
        op_o <= inst_i[6:2];
        sel_o <= inst_i[14:12];
        reg1a_o <= inst_i[19:15];
        reg2a_o <= inst_i[24:20];
        regd_o <= (inst_i[6:2] == 5'b11000 || inst_i[6:2] == 5'b01000) ? 1'b0 : inst_i[11:7];
        imm_o[31:21] <= lui ? inst_i[31:21] : (i20 ? 11'h7ff : 11'h0);
        imm_o[20] <= i20;
        imm_o[19:13] <= (lui || jal) ? inst_i[19:13] : (i12 ? 7'h7f : 7'h0);
        imm_o[12] <= i12;
        imm_o[11] <= i11;
        imm_o[10:5] <= (~lui) ? inst_i[30:25] : 6'b0;
        imm_o[4:1] <= (b || s) ? inst_i[11:8] : ((l || jal) ? inst_i[24:21] : 4'b0);
        imm_o[0] <= (jalr || l) ? inst_i[20] : (s ? inst_i[7] : 1'b0);
    end
end

assign i11 = ((~lui) && (~jal)) ? (b ? inst_i[7] : inst_i[31]) : (jal ? inst_i[20] : 1'b0);
assign i12 = b ? inst_i[31] : ((lui || jal) ? inst_i[12] : i11);
assign i20 = jal ? inst_i[31] : (lui ? inst_i[20] : ((lui || jal) ? inst_i[19] : (i12 ? 1'b1 : 1'b0)));
assign lui  = inst_i[6:2] == 5'b01101 || inst_i[6:2] == 5'b00101;
assign jal  = inst_i[6:2] == 5'b11011;
assign jalr = inst_i[6:2] == 5'b11001;
assign b    = inst_i[6:2] == 5'b11000;
assign l    = inst_i[6:2] == 5'b00000 || inst_i[6:2] == 5'b00100 || inst_i[6:2] == 5'b01100;
assign s    = inst_i[6:2] == 5'b01000 || inst_i[6:2] == 5'b01100;

endmodule
