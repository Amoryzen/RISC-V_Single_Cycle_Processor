// Praktikum EL3011 Arsitektur Sistem Komputer
// Modul      	: 3
// Percobaan  	: 2 (Integrasi Top Level)
// Tanggal    	: 2 Desember 2025
// Nama 1 (NIM) : Rafi Ananta Alden (13222087)
// Nama 2 (NIM)	: Didan Attaric (13222105)
// Nama File  	: toplevel_rv32i.v
// Deskripsi  	: Top Level Design Single-Cycle RISC-V Processor (RV32I)

module toplevel_rv32i(
    input  wire        clock,
    input  wire        reset,
    
    // --- Sinyal Debugging (Output ke Waveform) ---
    output wire [31:0] PC,          // Program Counter saat ini
    output wire [31:0] PC_in,       // Next Program Counter
    output wire [31:0] instr,       // Instruksi yang sedang dijalankan
    output wire [31:0] ALU_in1,     // Operan A ALU
    output wire [31:0] ALU_in2,     // Operan B ALU
    output wire [31:0] ALU_output,  // Hasil eksekusi ALU
    output wire [31:0] dmem_addr,   // Alamat akses Data Memory
    output wire [31:0] dmem_out,    // Output mentah Data Memory
    output wire [31:0] load_out,    // Output Data Memory setelah Load Selector
    output wire [31:0] rd_in,       // Data yang ditulis balik ke Register (Write Back)
    
    // Pecahan Instruksi untuk Debugging
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr
);

    // ==========================================
    // 1. DEKLARASI WIRE INTERNAL
    // ==========================================

    // Wires: Instruction Fetch & PC Logic
    wire [31:0] PC_out_wire;
    wire [31:0] PC_4;           // PC + 4
    wire [31:0] PC_branch;      // Target Branch (PC + Imm)
    wire [31:0] PC_jump;        // Target Jump (PC + Imm atau rs1 + Imm)
    wire [31:0] imm_out;        // Output Immediate Generator
    wire        branch_taken;   // Sinyal keputusan Branch

    // Wires: Register File Outputs
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    // Wires: Control Unit Signals
    wire        cu_branch;      // Sinyal Branch (Instruction is Branch type)
    wire        cu_jump;        // Sinyal Jump (JAL/JALR)
    wire        cu_memread;     // Enable Read Memory
    wire        cu_memwrite;    // Enable Write Memory
    wire        cu_regwrite;    // Enable Write Register
    wire [1:0]  cu_memtoreg;    // Selector WB (00=ALU, 01=Load, 10=PC+4)
    wire        cu_alusrc;      // Selector ALU B (0=Reg, 1=Imm)
    wire        cu_auipc;       // Selector ALU A (0=Reg, 1=PC) -> Opsional
    
    // Sinyal Kontrol Spesifik ALU (Dari Control Unit)
    wire [1:0]  cu_ALUtype;     // 00:Add, 01:Gate, 10:Shift, 11:SLT
    wire        cu_adtype;      // Add/Sub
    wire [1:0]  cu_gatype;      // And/Or/Xor
    wire [1:0]  cu_shiftype;    // SLL/SRL/SRA
    wire        cu_sltype;      // SLT/SLTU
    
    // Sinyal Kontrol Load Selector
    wire [2:0]  cu_loadtype;    // LB, LH, LW, LBU, LHU

    // ==========================================
    // 2. ASSIGNMENT OUTPUT DEBUGGING
    // ==========================================
    assign PC           = PC_out_wire;
    assign opcode       = instr[6:0];
    assign rd_addr      = instr[11:7];
    assign funct3       = instr[14:12];
    assign rs1_addr     = instr[19:15];
    assign rs2_addr     = instr[24:20];
    assign funct7       = instr[31:25];
    
    assign ALU_output   = dmem_addr; // ALU Output biasanya jadi alamat memori

    // ==========================================
    // 3. TAHAP: INSTRUCTION FETCH (IF)
    // ==========================================

    // MUX Next PC (Logic Branching & Jumping)
    // Prioritas: Reset -> Jump/Branch -> PC+4
    // Logika sederhana: Jika Branch Taken atau Jump, pindah ke Target. Jika tidak, PC+4.
    assign PC_in = (cu_jump || (cu_branch && branch_taken)) ? 
                   ((cu_jump && opcode == 7'b1100111) ? (rs1_data + imm_out) : (PC_out_wire + imm_out)) : // Handle JALR vs JAL/Branch
                   PC_4;

    // Modul Program Counter
    pc_rv32i Blok_PC (
        .clock  (clock),
        .reset  (reset),
        .PCin   (PC_in),
        .PCout  (PC_out_wire)
    );

    // Instruction Memory
    instr_rom_rv32i Blok_IMEM (
        .clock  (clock),
        .PC     (PC_out_wire),
        .INSTR  (instr)
    );

    // Adder PC + 4
    assign PC_4 = PC_out_wire + 32'd4;

    // ==========================================
    // 4. TAHAP: INSTRUCTION DECODE (ID)
    // ==========================================

    // Control Unit (Main Controller + ALU Decoder)
    ctrl_unit_rv32i Blok_CU (
        .opcode        (opcode),
        .funct3        (funct3),
        .funct7        (funct7),
        // Output Control Signals
        .cu_ALU1src    (cu_auipc),      // PC selector for ALU input 1
        .cu_ALU2src    (cu_alusrc),     // Imm selector for ALU input 2
        .cu_immtype    (),              // Not used in toplevel; passed directly to ImmGen
        .cu_ALUtype    (cu_ALUtype),
        .cu_adtype     (cu_adtype),
        .cu_gatype     (cu_gatype),
        .cu_shiftype   (cu_shiftype),
        .cu_sltype     (cu_sltype),
        .cu_rdtype     (cu_memtoreg),   // Write Back selector (00: ALU, 01: Load, 10: PC+4, 11: Imm)
        .cu_rdwrite    (cu_regwrite),
        .cu_loadtype   (cu_loadtype),
        .cu_store      (cu_memwrite),   // Write Memory enable
        .cu_storetype  (),              // Not directly used; embedded in data_mem
        .cu_branch     (cu_branch),
        .cu_branchtype (),              // Not used; funct3 used directly in brancher
        .cu_jump       (cu_jump)
    );

    // Register File
    reg_file_rv32i Blok_RegFile (
        .clock      (clock),
        .cu_rdwrite (cu_regwrite),
        .rs1_addr   (rs1_addr),
        .rs2_addr   (rs2_addr),
        .rd_addr    (rd_addr),
        .rd_in      (rd_in),     // Data Write Back
        .rs1        (rs1_data),
        .rs2        (rs2_data)
    );

    // Immediate Generator
    imm_select_rv32i Blok_ImmGen (
        .trimmed_instr (instr[31:7]),
        .cu_immtype    (funct3),  // Use funct3 or add separate immediate type signal from CU
        .imm           (imm_out)
    );

    // ==========================================
    // 5. TAHAP: EXECUTE (EX)
    // ==========================================

    // Mux ALU Operand A (Support AUIPC: PC vs rs1)
    // Jika opcode AUIPC (0010111), gunakan PC. Default rs1.
    assign ALU_in1 = (opcode == 7'b0010111) ? PC_out_wire : rs1_data;

    // Mux ALU Operand B (ALUSrc: Imm vs rs2)
    assign ALU_in2 = (cu_alusrc) ? imm_out : rs2_data;

    // Branch Comparator (Menentukan Branch Taken/Not)
    // Bandingkan rs1 dan rs2 berdasarkan funct3 (BEQ, BNE, BLT, dll)
    brancher_rv32i Blok_BranchComp (
        .PC_new         (PC_4),
        .PC_branch      (PC_out_wire + imm_out),
        .in1            (rs1_data),
        .in2            (rs2_data),
        .cu_branch      (cu_branch),
        .cu_branchtype  (funct3),
        .PC_in          () // Output not used here; PC_in logic is in PC MUX
    );

    // ALU UNIT (Tugas 1)
    alu_rv32i Blok_ALU (
        .in1        (ALU_in1),
        .in2        (ALU_in2),
        .cu_ALUtype (cu_ALUtype),
        .cu_adtype  (cu_adtype),
        .cu_gatype  (cu_gatype),
        .cu_shiftype(cu_shiftype),
        .cu_sltype  (cu_sltype),
        .out        (dmem_addr) // Output ALU digunakan sbg alamat memori
    );

    // ==========================================
    // 6. TAHAP: MEMORY ACCESS (MEM)
    // ==========================================

    // Data Memory
    data_mem_rv32i Blok_DMEM (
        .clock        (clock),
        .cu_store     (cu_memwrite),
        .cu_storetype (cu_gatype[1:0]),  // Reuse cu_gatype or add separate control signal
        .dmem_addr    (dmem_addr),       // Alamat dari ALU Result
        .rs2          (rs2_data),        // Data store diambil dari rs2 (bukan ALU in2)
        .dmem_out     (dmem_out)
    );

    // Load Selector (TP 6)
    loadselect_rv32i Blok_LoadSelect (
        .in         (dmem_out),
        .type       (cu_loadtype),
        .out        (load_out)
    );

    // ==========================================
    // 7. TAHAP: WRITE BACK (WB)
    // ==========================================

    // Mux Write Back (Menggunakan Mux 4-to-1 TP 1)
    // 00: ALU Result
    // 01: Load Memory
    // 10: PC + 4 (Untuk JAL/JALR menyimpan return address)
    // 11: (Unused / Zero)
    
    mux_4to1_32bit Blok_WBMux (
        .W          (dmem_addr),  // 00: ALU Result
        .X          (load_out),   // 01: Mem Load
        .Y          (PC_4),       // 10: PC + 4
        .Z          (32'b0),      // 11: Default
        .selector   (cu_memtoreg),
        .D          (rd_in)       // Output ke Register File
    );

endmodule