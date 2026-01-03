// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1 (Tugas Pendahuluan)
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : alu_gate_rv32i.v
// Deskripsi  : Subblok ALU untuk operasi logika (XOR, OR, AND)

module alu_gate_rv32i (
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire [1:0]  type, // 00: XOR, 01: OR, 10: AND
    output reg  [31:0] out
);

    always @(*) begin
        case (type)
            2'b00: out = in1 ^ in2; // Operasi XOR
            2'b01: out = in1 | in2; // Operasi OR
            2'b10: out = in1 & in2; // Operasi AND
            default: out = 32'b0;   // Default case (misal type = 11)
        endcase
    end

endmodule