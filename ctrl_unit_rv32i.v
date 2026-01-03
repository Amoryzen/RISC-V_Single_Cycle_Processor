// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      : 2
// Percobaan  : 1 (Revisi)
// Nama File  : ctrl_unit_rv32i.v
// Deskripsi  : Control Unit Single-Cycle RISC-V (RV32I)

module ctrl_unit_rv32i (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    // Output Sinyal Kontrol
    output reg        cu_ALU1src,    // 0: rs1, 1: PC
    output reg        cu_ALU2src,    // 0: rs2, 1: Imm
    output reg [2:0]  cu_immtype,    // 000: I, 001: S, 010: B, 011: U, 100: J
    output reg [1:0]  cu_ALUtype,    // 00: Add, 01: Gate, 10: Shift, 11: SLT
    output reg        cu_adtype,     // 0: Add, 1: Sub
    output reg [1:0]  cu_gatype,     // 00: XOR, 01: OR, 10: AND
    output reg [1:0]  cu_shiftype,   // 00: SLL, 01: SRL, 10: SRA
    output reg        cu_sltype,     // 0: Signed (SLT), 1: Unsigned (SLTU)
    output reg [1:0]  cu_rdtype,     // 00: ALU, 01: Load, 10: PC+4, 11: Imm
    output reg        cu_rdwrite,    // Enable Write Register
    output reg [2:0]  cu_loadtype,   // 000: LB, 001: LH, 010: LW, 011: LBU, 100: LHU
    output reg        cu_store,      // Enable Write Mem
    output reg [1:0]  cu_storetype,  // 00: SB, 01: SH, 10: SW
    output reg        cu_branch,     // Enable Branch
    output reg [2:0]  cu_branchtype, // 000: BEQ, 001: BNE, 010: BLT, 011: BGE, 100: BLTU, 101: BGEU
    output reg        cu_jump        // Enable Jump (JAL/JALR)
);

    always @ (*) begin
        // --- Default Values (untuk mencegah latch & memudahkan debug) ---
        cu_ALU1src    = 1'b0;    // rs1
        cu_ALU2src    = 1'b0;    // rs2
        cu_immtype    = 3'b000;  // I-type
        cu_ALUtype    = 2'b00;   // ADD
        cu_adtype     = 1'b0;    // Add
        cu_gatype     = 2'b00;   // XOR (Default)
        cu_shiftype   = 2'b00;   // SLL
        cu_sltype     = 1'b0;    // Signed
        cu_rdtype     = 2'b00;   // ALU Result
        cu_rdwrite    = 1'b0;    // Disable
        cu_loadtype   = 3'b000;  // LB (Default)
        cu_store      = 1'b0;    // Disable
        cu_storetype  = 2'b00;   // SB (Default)
        cu_branch     = 1'b0;    // Disable
        cu_branchtype = 3'b000;  // BEQ
        cu_jump       = 1'b0;    // Disable

        case (opcode)
            // ---------------- R-Type ----------------
            7'h33: begin
                cu_rdwrite = 1'b1;
                case (funct3)
                    3'h0: begin // ADD/SUB
                        if (funct7 == 7'h20) cu_adtype = 1'b1; // SUB
                    end
                    3'h1: cu_ALUtype = 2'b10; // SLL
                    3'h2: cu_ALUtype = 2'b11; // SLT
                    3'h3: begin // SLTU
                        cu_ALUtype = 2'b11;
                        cu_sltype  = 1'b1;
                    end
                    3'h4: begin // XOR
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b00; // Sesuai tabel PDF: XOR = 00
                    end
                    3'h5: begin // SRL/SRA
                        cu_ALUtype = 2'b10;
                        if (funct7 == 7'h20) cu_shiftype = 2'b10; // SRA
                        else                 cu_shiftype = 2'b01; // SRL
                    end
                    3'h6: begin // OR
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b01; // OR
                    end
                    3'h7: begin // AND
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b10; // AND
                    end
                endcase
            end

            // ---------------- I-Type (Arithmetic) ----------------
            7'h13: begin
                cu_ALU2src = 1'b1; // Imm
                cu_rdwrite = 1'b1;
                case (funct3)
                    3'h0: ; // ADDI (Default ALUtype 00)
                    3'h1: begin // SLLI
                        cu_ALUtype  = 2'b10;
                        cu_shiftype = 2'b00;
                    end
                    3'h2: begin // SLTI
                        cu_ALUtype = 2'b11;
                        cu_sltype  = 1'b0;
                    end
                    3'h3: begin // SLTIU
                        cu_ALUtype = 2'b11;
                        cu_sltype  = 1'b1;
                    end
                    3'h4: begin // XORI
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b00; // XOR
                    end
                    3'h5: begin // SRLI/SRAI
                        cu_ALUtype = 2'b10;
                        if (funct7 == 7'h20) cu_shiftype = 2'b10; // SRAI
                        else                 cu_shiftype = 2'b01; // SRLI
                    end
                    3'h6: begin // ORI
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b01;
                    end
                    3'h7: begin // ANDI
                        cu_ALUtype = 2'b01;
                        cu_gatype  = 2'b10;
                    end
                endcase
            end

            // ---------------- Load (I-Type) ----------------
            7'h03: begin
                cu_ALU2src  = 1'b1;   // Imm
                cu_rdtype   = 2'b01;  // Load
                cu_rdwrite  = 1'b1;
                // cu_loadtype mapping
                case (funct3)
                    3'b000: cu_loadtype = 3'b000; // LB
                    3'b001: cu_loadtype = 3'b001; // LH
                    3'b010: cu_loadtype = 3'b010; // LW
                    3'b100: cu_loadtype = 3'b011; // LBU
                    3'b101: cu_loadtype = 3'b100; // LHU
                    default: cu_loadtype = 3'b010;
                endcase
            end

            // ---------------- Store (S-Type) ----------------
            7'h23: begin
                cu_ALU2src   = 1'b1;
                cu_immtype   = 3'b001; // S-Type
                cu_store     = 1'b1;
                case (funct3)
                    3'b000: cu_storetype = 2'b00; // SB
                    3'b001: cu_storetype = 2'b01; // SH
                    3'b010: cu_storetype = 2'b10; // SW
                    default: cu_storetype = 2'b10;
                endcase
            end

            // ---------------- Branch (B-Type) ----------------
            7'h63: begin
                cu_ALU1src    = 1'b1;   // PC (ALU menghitung PC+Imm)
                cu_ALU2src    = 1'b1;   // Imm
                cu_immtype    = 3'b010; // B-Type
                cu_branch     = 1'b1;
                // Sesuai Tabel Revisi:
                case (funct3)
                    3'b000: cu_branchtype = 3'b000; // BEQ
                    3'b001: cu_branchtype = 3'b001; // BNE
                    3'b100: cu_branchtype = 3'b010; // BLT
                    3'b101: cu_branchtype = 3'b011; // BGE
                    3'b110: cu_branchtype = 3'b100; // BLTU
                    3'b111: cu_branchtype = 3'b101; // BGEU
                    default: cu_branchtype = 3'b000;
                endcase
            end

            // ---------------- LUI (U-Type) ----------------
            7'h37: begin
                cu_ALU2src  = 1'b1;
                cu_immtype  = 3'b011; // U-Type
                cu_rdtype   = 2'b11;  // Imm
                cu_rdwrite  = 1'b1;
            end

            // ---------------- AUIPC (U-Type) ----------------
            7'h17: begin
                cu_ALU1src  = 1'b1;   // PC
                cu_ALU2src  = 1'b1;   // Imm
                cu_immtype  = 3'b011; // U-Type
                cu_rdtype   = 2'b00;  // ALU Result (PC+Imm)
                cu_rdwrite  = 1'b1;
            end

            // ---------------- JAL (J-Type) ----------------
            7'h6F: begin
                cu_ALU1src  = 1'b1;   // PC
                cu_ALU2src  = 1'b1;   // Imm
                cu_immtype  = 3'b100; // J-Type
                cu_rdtype   = 2'b10;  // PC+4
                cu_rdwrite  = 1'b1;
                cu_jump     = 1'b1;
            end

            // ---------------- JALR (I-Type) ----------------
            7'h67: begin
                cu_ALU1src  = 1'b0;   // rs1 (Target = rs1 + imm)
                cu_ALU2src  = 1'b1;
                cu_immtype  = 3'b000; // I-Type
                cu_rdtype   = 2'b10;  // PC+4
                cu_rdwrite  = 1'b1;
                cu_jump     = 1'b1;
            end
        endcase
    end
endmodule