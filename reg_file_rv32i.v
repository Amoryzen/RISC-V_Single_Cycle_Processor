// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 1
// Percobaan  : 4 (Revisi)
// Nama File  : reg_file_rv32i.v
// Deskripsi  : Register File 32x32, 2 Port Read (Async), 1 Port Write (Sync)

`timescale 1ns/1ps

module reg_file_rv32i (
    input  wire        clock,
    input  wire        cu_rdwrite,  // Write Enable
    input  wire [4:0]  rs1_addr,    // Alamat Baca 1
    input  wire [4:0]  rs2_addr,    // Alamat Baca 2
    input  wire [4:0]  rd_addr,     // Alamat Tulis
    input  wire [31:0] rd_in,       // Data Tulis
    output wire [31:0] rs1,         // Data Baca 1
    output wire [31:0] rs2          // Data Baca 2
);

    // Array memori 32 register x 32 bit
    reg [31:0] rf [0:31];
    integer i;

    // Inisialisasi awal untuk simulasi (semua 0)
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'b0;
    end

    // Operasi Tulis (Synchronous @ Posedge Clock)
    // x0 selalu hardwired ke 0, jadi penulisan ke x0 diabaikan (atau ditimpa 0)
    always @(posedge clock) begin
        if (cu_rdwrite && (rd_addr != 5'd0)) begin
            rf[rd_addr] <= rd_in;
        end
        // Memastikan x0 tetap 0 (defensive coding)
        rf[0] <= 32'b0; 
    end

    // Operasi Baca (Asynchronous / Continuous Assignment)
    // Sesuai revisi Modul 1 Tugas 4: "Baca asinkron"
    assign rs1 = (rs1_addr == 5'd0) ? 32'b0 : rf[rs1_addr];
    assign rs2 = (rs2_addr == 5'd0) ? 32'b0 : rf[rs2_addr];

endmodule