module IF(
    input  wire        clk,
    input  wire        rst,
    input  wire        rdy,
    input  wire        e_i,
    input  wire [31:0] pc_i,
    input  wire [7:0]  memd_i,
    output reg  [31:0] mema_o,
    output reg  [31:0] pc_o,
    output reg  [31:0] inst_o
);

    reg [2:0] cnt;
    reg [7:0] inst0, inst1, inst2;
    reg [31:0] pc;
    
    always @(posedge clk) begin
        if (rst) begin
            cnt <= 1'b0;
            pc_o <= 1'b0;
            pc <= 1'b0;
            inst_o <= 32'hffffffff;
            mema_o <= 1'b0;
        end else if (e_i && rdy) begin
            mema_o <= pc_i + cnt[1:0];
            cnt <= cnt == 3'h5 ? 1'b0 : cnt + 1'b1;
            case (cnt)
                3'h2: begin
                    inst0 <= memd_i;
                    pc <= pc_i;
                end
                3'h3: inst1 <= memd_i;
                3'h4: inst2 <= memd_i;
                3'h5: begin
                    inst_o <= {memd_i, inst2, inst1, inst0};
                    pc_o <= pc;
                end
            endcase
        end
    end
    
endmodule