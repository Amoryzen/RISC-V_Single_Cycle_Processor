// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 1
// Percobaan  : 2 (Revisi)
// Nama File  : instr_rom_rv32i.v
// Deskripsi  : Instruction ROM 32x32 (RV32I) via ALTSYNCRAM + .mif

`timescale 1ns/1ps

module instr_rom_rv32i (
    input  wire        clock,
    input  wire [31:0] PC,      // byte address
    output wire [31:0] INSTR
);

    // Word index untuk 32 word (mengambil bit [6:2] dari PC)
    wire [4:0] waddr = PC[6:2];

    // Sesuai revisi modul: Menggunakan clock terinversi untuk ROM
    // agar pembacaan terjadi di awal siklus (efektif saat falling edge dari clock utama)
    wire inv_clock = ~clock;

    altsyncram #(
        .operation_mode ("ROM"),
        .width_a        (32),
        .widthad_a      (5),                  // 32 word address width
        .init_file      ("imemory_rv32i.mif"), // Pastikan file .mif ada di project
        .outdata_reg_a  ("UNREGISTERED")      // Output tidak di-register agar langsung keluar
    ) rom (
        .clock0     (inv_clock),
        .address_a  (waddr),
        .q_a        (INSTR),
        .wren_a     (1'b0),     // ROM tidak bisa ditulis
        .data_a     (32'b0)
    );

endmodule