// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1 (Tugas Pendahuluan)
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : alu_shifter_rv32i.v
// Deskripsi  : Subblok ALU untuk operasi Shifter (SLL, SRL, SRA)

module alu_shifter_rv32i (
    input  wire [31:0] in,
    input  wire [31:0] shamt, // Shift Amount
    input  wire [1:0]  type,  // 00: SLL, 01: SRL, 10: SRA
    output reg  [31:0] out
);

    // Mengambil 5 bit terbawah dari shamt karena pergeseran maks 31 bit
    wire [4:0] shift_amount = shamt[4:0];

    always @(*) begin
        case (type)
            2'b00: out = in << shift_amount;          // SLL: Shift Left Logical
            2'b01: out = in >> shift_amount;          // SRL: Shift Right Logical
            2'b10: out = $signed(in) >>> shift_amount; // SRA: Shift Right Arithmetic
            default: out = 32'b0;
        endcase
    end

endmodule