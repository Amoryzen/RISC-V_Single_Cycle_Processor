// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 3
// Percobaan  : 1 (Tugas Pendahuluan)
// Tanggal    : 2 Desember 2025
// Nama (NIM) : Rafi Ananta Alden (13222087)
// Nama File  : loadselect_rv32i.v
// Deskripsi  : Load Selector untuk menangani instruksi LB, LH, LW, LBU, LHU

module loadselect_rv32i (
    input  wire [31:0] in,   // dmem_out
    input  wire [2:0]  type, // Selector signal
    output reg  [31:0] out   // load_out
);

    always @(*) begin
        case (type)
            3'b000: begin // LB (Load Byte - Sign Extend)
                // Ambil 8 bit, replikasi bit ke-7 sebanyak 24 kali ke depan
                out = {{24{in[7]}}, in[7:0]};
            end
            3'b001: begin // LH (Load Half - Sign Extend)
                // Ambil 16 bit, replikasi bit ke-15 sebanyak 16 kali ke depan
                out = {{16{in[15]}}, in[15:0]};
            end
            3'b010: begin // LW (Load Word)
                // Pass-through
                out = in;
            end
            3'b011: begin // LBU (Load Byte Unsigned - Zero Extend)
                // Ambil 8 bit, isi depannya dengan 0
                out = {24'b0, in[7:0]};
            end
            3'b100: begin // LHU (Load Half Unsigned - Zero Extend)
                // Ambil 16 bit, isi depannya dengan 0
                out = {16'b0, in[15:0]};
            end
            default: out = 32'b0;
        endcase
    end

endmodule