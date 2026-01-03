// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul: 2
// Nama (NIM) 1: Rafi Ananta Alden (13222087)
// Nama (NIM) 2: Mikhael Anacta Jogi Sinaga (13223108)
// Nama File: pc_rv32i.v
// Deskripsi: Program Counter 32-bit (Register)

module pc_rv32i (
    input  wire        clock, // Sinyal clock
    input  wire        reset, // Sinyal reset (active-low)
    input  wire [31:0] PCin,  // Nilai PC berikutnya
    output reg  [31:0] PCout  // Nilai PC saat ini
);

    // Logika sekuensial: Register dengan reset asinkron
    always @(posedge clock or negedge reset) begin
        if (!reset) begin // Jika reset aktif (low)
            PCout <= 32'h00000000;
        end
        else begin // Jika clock naik dan reset tidak aktif
            PCout <= PCin;
        end
    end

endmodule