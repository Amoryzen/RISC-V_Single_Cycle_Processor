// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : alu_rv32i.v
// Deskripsi  : ALU Top Level, mengintegrasikan Adder, Gate, Shifter, dan SLT

module alu_rv32i(
    input  wire [31:0] in1,        // Input operand 1 (rs1 / PC)
    input  wire [31:0] in2,        // Input operand 2 (rs2 / imm)
    input  wire [1:0]  cu_ALUtype, // Selector: 00=Adder, 01=Gate, 10=Shifter, 11=SLT
    input  wire        cu_adtype,  // Control untuk Adder (ADD/SUB)
    input  wire [1:0]  cu_gatype,  // Control untuk Gate (XOR/OR/AND)
    input  wire [1:0]  cu_shiftype,// Control untuk Shifter (SLL/SRL/SRA)
    input  wire        cu_sltype,  // Control untuk SLT (Signed/Unsigned)
    output reg  [31:0] out         // Output hasil ALU
);

    // Kawat internal untuk menampung hasil dari masing-masing subblok
    wire [31:0] adder_out, gate_out, shifter_out, slt_out;

    // 1. Instansiasi Subblok Adder
    alu_adder_rv32i subblok_adder (
        .in1  (in1),
        .in2  (in2),
        .type (cu_adtype),
        .out  (adder_out)
    );

    // 2. Instansiasi Subblok Gate
    alu_gate_rv32i subblok_gate (
        .in1  (in1),
        .in2  (in2),
        .type (cu_gatype),
        .out  (gate_out)
    );

    // 3. Instansiasi Subblok Shifter
    alu_shifter_rv32i subblok_shifter (
        .in   (in1),
        .shamt(in2),       // Perhatikan: in2 berfungsi sebagai shift amount
        .type (cu_shiftype),
        .out  (shifter_out)
    );

    // 4. Instansiasi Subblok SLT
    alu_slt_rv32i subblok_slt (
        .in1  (in1),
        .in2  (in2),
        .type (cu_sltype),
        .out  (slt_out)
    );

    // Multiplexer untuk memilih output akhir berdasarkan cu_ALUtype
    always @ (*) begin
        case (cu_ALUtype)
            2'b00: out = adder_out;   // Pilih hasil Adder
            2'b01: out = gate_out;    // Pilih hasil Gate Logika
            2'b10: out = shifter_out; // Pilih hasil Shifter
            2'b11: out = slt_out;     // Pilih hasil SLT
            default: out = 32'd0;     // Fail-safe
        endcase
    end

endmodule