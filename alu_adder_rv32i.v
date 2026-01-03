// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1 (Tugas Pendahuluan)
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : alu_adder_rv32i.v
// Deskripsi  : Subblok ALU untuk operasi Adder (Penjumlahan) dan Subtractor (Pengurangan)

module alu_adder_rv32i (
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire        type, // 0 untuk ADD, 1 untuk SUB
    output reg  [31:0] out
);

    always @(*) begin
        if (type == 1'b0) begin
            // Operasi Penjumlahan
            out = in1 + in2;
        end else begin
            // Operasi Pengurangan
            out = in1 - in2;
        end
    end

endmodule