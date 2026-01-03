// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : Tugas Pendahuluan No. 4
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : alu_slt_rv32i.v
// Deskripsi  : Subblok ALU untuk operasi Set Less Than (Signed & Unsigned)

module alu_slt_rv32i (
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire        type, // 0: SLT (Signed), 1: SLTU (Unsigned)
    output reg  [31:0] out
);

    always @(*) begin
        if (type == 1'b0) begin
            // SLT: Signed Comparison
            // Jika in1 < in2 (secara signed), output 1, else 0
            if ($signed(in1) < $signed(in2))
                out = 32'd1;
            else
                out = 32'd0;
        end 
        else begin
            // SLTU: Unsigned Comparison
            // Jika in1 < in2 (secara unsigned), output 1, else 0
            if (in1 < in2)
                out = 32'd1;
            else
                out = 32'd0;
        end
    end

endmodule