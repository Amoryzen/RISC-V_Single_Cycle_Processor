// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul: 2
// Nama (NIM) 1: Rafi Ananta Alden (13222087)
// Nama (NIM) 2: Mikhael Anacta Jogi Sinaga (13223108)
// Nama File: pc_4_adder_rv32i.v
// Deskripsi: Menghitung PC + 4 untuk RISC-V

module pc_4_adder_rv32i (
    input  wire [31:0] PCold,
    output wire [31:0] PC_4_inc
);

    // Logika kombinasional: PC_4_inc = PCold + 4
    assign PC_4_inc = PCold + 32'd4;

endmodule