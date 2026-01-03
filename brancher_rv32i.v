// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 2
// Percobaan  : 3 (Revisi)
// Nama File  : brancher_rv32i.v
// Deskripsi  : Brancher Logic

module brancher_rv32i (
    input  wire [31:0] PC_new,       // PC + 4
    input  wire [31:0] PC_branch,    // PC + Imm (Target dari ALU)
    input  wire signed [31:0] in1,   // rs1
    input  wire signed [31:0] in2,   // rs2
    input  wire        cu_branch,    // Enable Branch
    input  wire [2:0]  cu_branchtype,// Selector Tipe Branch
    output reg  [31:0] PC_in         // Next PC
);

    always @ (*) begin
        if (cu_branch) begin
            case (cu_branchtype)
                3'b000: // BEQ
                    PC_in <= (in1 == in2) ? PC_branch : PC_new;
                
                3'b001: // BNE (Sesuai Revisi: 001, bukan 101)
                    PC_in <= (in1 != in2) ? PC_branch : PC_new;
                
                3'b010: // BLT (Signed <)
                    PC_in <= (in1 < in2) ? PC_branch : PC_new;
                
                3'b011: // BGE (Signed >=)
                    PC_in <= (in1 >= in2) ? PC_branch : PC_new;
                
                3'b100: // BLTU (Unsigned <)
                    PC_in <= ($unsigned(in1) < $unsigned(in2)) ? PC_branch : PC_new;
                
                3'b101: // BGEU (Unsigned >=)
                    PC_in <= ($unsigned(in1) >= $unsigned(in2)) ? PC_branch : PC_new;
                
                default: PC_in <= PC_new;
            endcase
        end else begin
            PC_in <= PC_new;
        end
    end

endmodule