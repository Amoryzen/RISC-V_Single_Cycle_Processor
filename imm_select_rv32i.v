// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 2
// Percobaan  : 2 (Revisi)
// Nama File  : imm_select_rv32i.v
// Deskripsi  : Immediate Selector

module imm_select_rv32i (
    input  wire [24:0] trimmed_instr, // trimmed_instr[24:0] = instr[31:7]
    input  wire [2:0]  cu_immtype,
    output reg  [31:0] imm
);

    /* Mapping Bit:
       trimmed_instr[24]    = instr[31] (Sign bit)
       trimmed_instr[23:18] = instr[30:25]
       trimmed_instr[17:14] = instr[24:21]
       trimmed_instr[13]    = instr[20]
       trimmed_instr[12:5]  = instr[19:12]
       trimmed_instr[4:1]   = instr[11:8]
       trimmed_instr[0]     = instr[7]
    */

    always @ (*) begin
        case (cu_immtype)
            3'b000: // I-Type: instr[31:20]
                imm <= { {20{trimmed_instr[24]}}, trimmed_instr[24:13] };

            3'b001: // S-Type: instr[31:25] (imm[11:5]) + instr[11:7] (imm[4:0])
                imm <= { {20{trimmed_instr[24]}}, trimmed_instr[24:18], trimmed_instr[4:0] };

            3'b010: // B-Type: instr[31], instr[7], instr[30:25], instr[11:8], 0
                imm <= { {20{trimmed_instr[24]}}, // Sign extend
                         trimmed_instr[24],       // imm[12] (bit 31)
                         trimmed_instr[0],        // imm[11] (bit 7) -- PERBAIKAN UTAMA
                         trimmed_instr[23:18],    // imm[10:5] (bit 30:25)
                         trimmed_instr[4:1],      // imm[4:1] (bit 11:8)
                         1'b0 };

            3'b011: // U-Type: instr[31:12] << 12
                imm <= { trimmed_instr[24:5], 12'b0 };

            3'b100: // J-Type: instr[31], instr[19:12], instr[20], instr[30:21], 0
                imm <= { {12{trimmed_instr[24]}}, // Sign extend
                         trimmed_instr[12:5],     // imm[19:12]
                         trimmed_instr[13],       // imm[11] (bit 20)
                         trimmed_instr[23:18],    // imm[10:5] (bit 30:25)
                         trimmed_instr[17:14],    // imm[4:1]  (bit 24:21)
                         1'b0 };
                         
            default: imm <= 32'b0;
        endcase
    end
endmodule