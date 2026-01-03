// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 1
// Percobaan  : 3 (Revisi)
// Nama File  : data_mem_rv32i.v
// Deskripsi  : Data Memory 256 x 32-bit (RV32I) via ALTSYNCRAM

`timescale 1ns/1ps

module data_mem_rv32i (
    input  wire        clock,
    input  wire        cu_store,      // Write Enable dari CU
    input  wire [1:0]  cu_storetype,  // 00: SB, 01: SH, 10: SW
    input  wire [31:0] dmem_addr,     // Byte address dari ALU
    input  wire [31:0] rs2,           // Data yang akan ditulis (Store Data)
    output wire [31:0] dmem_out       // Data yang dibaca (Load Data)
);

    // Kapasitas 256 word, membutuhkan 8 bit alamat (2^8 = 256)
    // Mengambil bit [9:2] karena address bersifat byte-aligned
    wire [7:0] waddr = dmem_addr[9:2];

    reg [3:0]  be;              // Byte Enable
    reg [31:0] wr_data_aligned; // Data yang sudah di-align posisinya

    // Logika Byte Enable (Menentukan byte mana yang ditulis)
    always @(*) begin
        case (cu_storetype)
            2'b00: // Store Byte (SB)
                case (dmem_addr[1:0])
                    2'b00: be = 4'b0001;
                    2'b01: be = 4'b0010;
                    2'b10: be = 4'b0100;
                    default: be = 4'b1000;
                endcase
            2'b01: // Store Half (SH)
                be = (dmem_addr[1]) ? 4'b1100 : 4'b0011;
            2'b10: // Store Word (SW)
                be = 4'b1111;
            default: // Default / Tidak store
                be = 4'b0000;
        endcase
    end

    // Logika Data Alignment (Menggeser data ke posisi byte yang sesuai)
    always @(*) begin
        case (cu_storetype)
            2'b00: // Store Byte (SB) - Copy LSB rs2 ke posisi byte tujuan
                case (dmem_addr[1:0])
                    2'b00: wr_data_aligned = {24'b0, rs2[7:0]};
                    2'b01: wr_data_aligned = {16'b0, rs2[7:0], 8'b0};
                    2'b10: wr_data_aligned = {8'b0,  rs2[7:0], 16'b0};
                    default: wr_data_aligned = {rs2[7:0], 24'b0};
                endcase
            2'b01: // Store Half (SH)
                wr_data_aligned = (dmem_addr[1]) ? {rs2[15:0], 16'b0} : {16'b0, rs2[15:0]};
            2'b10: // Store Word (SW)
                wr_data_aligned = rs2;
            default:
                wr_data_aligned = 32'b0;
        endcase
    end

    // Clock terinversi untuk memory access agar sinkron dengan timing single-cycle
    // (Menulis di falling edge, membaca address yang stabil setelah ALU execute)
    wire inv_clock = ~clock;

    altsyncram #(
        .operation_mode  ("SINGLE_PORT"),
        .width_a         (32),
        .widthad_a       (8),              // 256 word
        .outdata_reg_a   ("UNREGISTERED"), // Read async (setelah clock edge)
        .init_file       ("dmemory.mif"),  // File inisialisasi data memory
        .width_byteena_a (4)               // Lebar byte enable (4 bit)
    ) ram (
        .clock0     (inv_clock),
        .wren_a     (cu_store),
        .address_a  (waddr),
        .data_a     (wr_data_aligned),
        .q_a        (dmem_out),
        .byteena_a  (be)
    );

endmodule