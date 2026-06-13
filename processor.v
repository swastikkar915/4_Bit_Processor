// ==========================================
// 1. ARITHMETIC LOGIC UNIT (ALU)
// ==========================================
module alu(
    input [3:0] A,
    input [3:0] B,
    input alu_op, // 0: ADD, 1: SUB
    output reg [3:0] alu_out
);
    always @(*) begin
        if (!alu_op)
            alu_out = A + B;
        else
            alu_out = A - B;
    end
endmodule

// ==========================================
// 2. REGISTER FILE
// ==========================================
module register_file(
    input clk,
    input rst,
    input reg_write,
    input reg_sel,       
    input [3:0] w_data,
    output [3:0] r0_val,
    output [3:0] r1_val
);
    reg [3:0] R0, R1;

    assign r0_val = R0;
    assign r1_val = R1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R0 <= 4'b0000;
            R1 <= 4'b0000;
        end else if (reg_write) begin
            if (reg_sel == 1'b0)
                R0 <= w_data;
            else
                R1 <= w_data;
        end
    end
endmodule

// ==========================================
// 3. DATA MEMORY (RAM) - NEW!
// ==========================================
module data_memory(
    input clk,
    input mem_write,
    input [3:0] addr,
    input [3:0] w_data,
    output [3:0] r_data
);
    reg [3:0] ram [0:15]; // 16 memory addresses, each 4-bits wide
    
    // Read is always active
    assign r_data = ram[addr];

    // Write happens only on clock edge when mem_write is high
    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr] <= w_data;
        end
    end
endmodule

// ==========================================
// 4. TOP LEVEL PROCESSOR
// ==========================================
module processor(
    input clk,
    input rst,
    output [3:0] out_R0, 
    output [3:0] out_R1,
    output [3:0] pc_out
);
    reg [3:0] PC;
    assign pc_out = PC;

    // Hardcoded Instruction Memory (ROM)
    wire [7:0] instruction;
    reg [7:0] rom [0:15];
    
    initial begin
        // NEW PROGRAM TO TEST RAM:
        rom[0] = 8'b0001_0111; // 1. LOAD R0, 7 (Put 7 in R0)
        rom[1] = 8'b0110_0010; // 2. STORE R0, RAM[2] (Save 7 into RAM address 2)
        rom[2] = 8'b0001_0000; // 3. LOAD R0, 0 (Wipe R0 back to 0 to prove RAM works)
        rom[3] = 8'b0101_0010; // 4. LOAD_RAM R0, RAM[2] (Fetch the 7 back from RAM into R0)
        rom[4] = 8'b0000_0000; // 5. NOP / Halt
    end
    
    assign instruction = rom[PC];

    wire [3:0] opcode = instruction[7:4];
    wire [3:0] immediate = instruction[3:0]; // Acts as immediate value OR RAM address
    
    // Control Signals
    reg reg_write;
    reg reg_sel;
    reg alu_op;
    reg mem_write;     // RAM Write Enable
    reg [1:0] wb_sel;  // Write-Back Mux: 00=ALU, 01=Immediate, 10=RAM

    // Control Unit Decoder
    always @(*) begin
        // Default safe assignments
        reg_write = 0; reg_sel = 0; alu_op = 0; mem_write = 0; wb_sel = 2'b00;
        
        case(opcode)
            4'b0001: begin // LOAD IMM R0
                reg_write = 1; reg_sel = 0; wb_sel = 2'b01;
            end
            4'b0010: begin // LOAD IMM R1
                reg_write = 1; reg_sel = 1; wb_sel = 2'b01;
            end
            4'b0011: begin // ADD
                reg_write = 1; reg_sel = 0; alu_op = 0; wb_sel = 2'b00;
            end
            4'b0100: begin // SUB
                reg_write = 1; reg_sel = 0; alu_op = 1; wb_sel = 2'b00;
            end
            4'b0101: begin // LOAD_RAM R0
                reg_write = 1; reg_sel = 0; wb_sel = 2'b10; // Take data from RAM
            end
            4'b0110: begin // STORE_RAM R0
                mem_write = 1; // Tell RAM to save R0's data
            end
        endcase
    end

    // Internal Wires
    wire [3:0] r0_val, r1_val, alu_out, ram_out;
    reg [3:0] write_back_data;

    // Write-Back Multiplexer (Chooses what goes into the Register)
    always @(*) begin
        case(wb_sel)
            2'b00: write_back_data = alu_out;
            2'b01: write_back_data = immediate;
            2'b10: write_back_data = ram_out;
            default: write_back_data = 4'b0000;
        endcase
    end

    // Instantiate Modules
    register_file reg_file_inst (
        .clk(clk), .rst(rst), .reg_write(reg_write), .reg_sel(reg_sel),
        .w_data(write_back_data), .r0_val(r0_val), .r1_val(r1_val)
    );

    alu alu_inst (
        .A(r0_val), .B(r1_val), .alu_op(alu_op), .alu_out(alu_out)
    );

    data_memory ram_inst (
        .clk(clk), .mem_write(mem_write), .addr(immediate),
        .w_data(r0_val), .r_data(ram_out)
    );

    // Outputs
    assign out_R0 = r0_val;
    assign out_R1 = r1_val;

    // PC Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 4'b0000;
        end else if (opcode != 4'b0000) begin
            PC <= PC + 1;
        end
    end

endmodule