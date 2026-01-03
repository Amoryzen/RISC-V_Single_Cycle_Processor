// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul: 2
// Nama (NIM) 1: Rafi Ananta Alden (13222087)
// Nama (NIM) 2: Mikhael Anacta Jogi Sinaga (13223108)
// Nama File: mux_2to1_32bit.v
// Deskripsi: Multiplexer 2-to-1 32-bit generik

module mux_2to1_32bit (
    input  wire [31:0] A,   // Input 0
    input  wire [31:0] B,   // Input 1
    input  wire        sel, // Sinyal selektor
    output wire [31:0] Y    // Output
);

    // Logika kombinasional:
    // Jika sel = 1, pilih B. Jika sel = 0, pilih A.
    assign Y = sel ? B : A;

endmodule