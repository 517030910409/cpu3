module MA(
    input  wire        clk,
    input  wire        rst,
    input  wire        rdy,
    input  wire        e_i,
    input  wire [31:0] res_i,
    input  wire [31:0] addr_i,
    input  wire [ 4:0] regd_i,
    input  wire [ 2:0] sel_i,
    input  wire [ 7:0] memd_i,
    input  wire [ 4:0] op_i,
    output reg  [31:0] mema_o,
    output reg  [ 7:0] memd_o,
    output reg  [31:0] res_o,
    output reg         memwe_o,
    output reg  [ 4:0] regd_o
);

reg [7:0] memd0, memd1, memd2;
reg [2:0] cnt;

always @(posedge clk) begin
    if (rst) begin
        cnt <= 1'b0;
        res_o <= 1'b0;
        regd_o <= 1'b0;
        memd_o <= 1'b0;
        mema_o <= 1'b0;
        memwe_o <= 1'b0;
    end else if (rdy && e_i) begin
        cnt <= cnt == 3'h5 ? 1'b0 : cnt + 1'b1;
        mema_o <= addr_i + cnt[1:0];
        if (cnt == 3'h5) regd_o <= regd_i;
        if (op_i == 5'b01000) begin
            case (cnt)
                3'h0: begin
                    memd_o <= res_i[7:0];
                    memwe_o <= 1'b1;
                end
                3'h1: begin
                    memd_o <= res_i[15:8];
                    memwe_o <= sel_i[1] | sel_i[0];
                end
                3'h2: begin
                    memd_o <= res_i[23:16];
                    memwe_o <= sel_i[1];
                end
                3'h3: begin
                    memd_o <= res_i[31:24];
                    memwe_o <= sel_i[1];
                end
                default: memwe_o <= 1'b0;
            endcase
        end else if (op_i == 5'b00000) begin
            memwe_o <= 1'b0;
            case (cnt)
            3'h2: memd0 <= memd_i;
            3'h3: memd1 <= memd_i;
            3'h4: memd2 <= memd_i;
            3'h5: begin
                case (sel_i)
                    3'b000: res_o <= {memd0[7] ? 24'hffffff : 24'b0, memd0};
                    3'b001: res_o <= {memd1[7] ? 16'hffff : 16'b0, memd1, memd0};
                    3'b010: res_o <= {memd_i, memd2, memd1, memd0};
                    3'b100: res_o <= {24'b0, memd0};
                    3'b101: res_o <= {16'b0, memd0};
                endcase
            end
            endcase
        end else if (cnt == 3'h5) begin
            res_o <= res_i;
            memwe_o <= 1'b0;
        end
    end else if (rdy && !e_i) begin
        mema_o <= 1'b0;
        memwe_o <= 1'b0;
    end
end

endmodule