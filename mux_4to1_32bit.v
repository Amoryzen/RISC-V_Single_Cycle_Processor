// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1 (Tugas Pendahuluan)
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : mux_4to1_32bit.v
// Deskripsi  : Multiplexer 4-to-1 dengan lebar data 32-bit

module mux_4to1_32bit (
    input  wire [31:0] W, // Input 00
    input  wire [31:0] X, // Input 01
    input  wire [31:0] Y, // Input 10
    input  wire [31:0] Z, // Input 11
    input  wire [1:0]  selector,
    output reg  [31:0] D
);

    always @(*) begin
        case (selector)
            2'b00: D = W;
            2'b01: D = X;
            2'b10: D = Y;
            2'b11: D = Z;
            default: D = 32'b0; // Fail-safe
        endcase
    end

endmodule