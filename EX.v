module EX(
    input  wire        clk,
    input  wire        rst,
    input  wire        rdy,
    input  wire        e_i,
    input  wire [ 4:0] op_i,
    input  wire [ 2:0] sel_i,
    input  wire [31:0] reg1d_i,
    input  wire [31:0] reg2d_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] imm_i,
    input  wire [ 4:0] regd_i,
    output reg  [ 4:0] op_o,
    output reg  [ 4:0] regd_o,
    output reg  [ 2:0] sel_o,
    output reg  [31:0] res_o,
    output reg  [31:0] addr_o,
    output reg  [31:0] jump_o
);

always @(posedge clk) begin
    if (rst) begin
        res_o <= 1'b0;
        addr_o <= 1'b0;
        jump_o <= 3'h4;
        sel_o <= 1'b0;
        regd_o <= 1'b0;
        op_o <= 1'b0;
    end else if (rdy && e_i) begin
        regd_o <= regd_i;
        sel_o <= sel_i;
        op_o <= op_i;
        jump_o <= op_i[4:2] == 3'b110 ? (op_i[0] ? (op_i[1] ? imm_i : reg1d_i + imm_i - pc_i) : imm_i) : 3'h4;
        addr_o <= (op_i[4] || op_i[2:0]) ? 1'b0 : reg1d_i + imm_i;  
        case (op_i)
        5'b01101: res_o <= imm_i;
        5'b00101: res_o <= pc_i + imm_i;
        5'b11011: res_o <= pc_i + 3'h4;
        5'b11001: res_o <= pc_i + 3'h4;
        5'b11000: begin
            case (sel_i)
                3'b000: res_o <= reg1d_i == reg2d_i;
                3'b001: res_o <= reg1d_i != reg2d_i;
                3'b100: res_o <= $signed(reg1d_i) < $signed(reg2d_i);
                3'b101: res_o <= $signed(reg1d_i) >= $signed(reg2d_i);
                3'b110: res_o <= reg1d_i < reg2d_i;
                3'b111: res_o <= reg1d_i >= reg2d_i;
            endcase  
        end
        5'b00000: res_o <= 1'b0;
        5'b01000: res_o <= reg2d_i;
        5'b00100: begin
            case (sel_i)
                3'b000: res_o <= reg1d_i + imm_i;
                3'b001: res_o <= reg1d_i << imm_i[4:0];
                3'b010: res_o <= $signed(reg1d_i) < $signed(imm_i);
                3'b011: res_o <= reg1d_i < imm_i;
                3'b100: res_o <= reg1d_i ^ imm_i;
                3'b101: res_o <= imm_i[10] ? reg1d_i >>> imm_i[4:0] : reg1d_i >> imm_i[4:0];
                3'b110: res_o <= reg1d_i | imm_i;
                3'b111: res_o <= reg1d_i & imm_i;
            endcase
        end
        5'b01100: begin
            case (sel_i)
                3'b000: res_o <= imm_i[10] ? reg1d_i - reg2d_i : reg1d_i + reg2d_i;
                3'b001: res_o <= reg1d_i << reg2d_i[4:0];
                3'b010: res_o <= $signed(reg1d_i) < $signed(reg2d_i);
                3'b011: res_o <= reg1d_i < reg2d_i;
                3'b100: res_o <= reg1d_i ^ reg2d_i;
                3'b101: res_o <= imm_i[10] ? reg1d_i >>> reg2d_i[4:0] : reg1d_i >> reg2d_i[4:0];
                3'b110: res_o <= reg1d_i | reg2d_i;
                3'b111: res_o <= reg1d_i & reg2d_i;
            endcase
        end
        endcase
    end
end

endmodule