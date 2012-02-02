/*************************************************************************
 * FILE:        dlx_modules.v
 * Written By:  Michael J. Kelley
 * Written On:  December 18, 1995
 * Updated By:  Michael J. Kelley
 * Updated On:  March 4, 1996
 *
 * Description:
 *
 * This file contains the hardware description of the control logic 
 * for each of the 5 stages of the DLX pipeline
 *************************************************************************
 */

//`include "/l/users/mkelley/DLX/verilog/dlx.defines"
`include "./dlx.defines"
//*************************************************************************
//ADD THE IFCtrl AND IDCtrl MODULES HERE..............

module IFCtrl (

        IR2,                          // Instruction that is being decoded in Stage II
        Equal,                        // Result from the equal comparator in Stage II
        MRST,                         // Reset signal for CPU
        PCMuxSelect,                  // Select Signals for the PCMux in Stage I 
        PCVector                      // Exception Vectors
);

/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */

input  [`WordSize]     IR2;
input                  Equal;
input                  MRST;
output [1:0]           PCMuxSelect;
output [`WordSize]     PCVector;

reg    [1:0]           PCMuxSelect;
reg                    ifBranch;

always @(IR2 or Equal or MRST)
begin
       casex({ IR2[`OP], IR2[`OPx], Equal, MRST})
             {       `J, 6'bxxxxxx,  1'bx, 1'b1}: PCMuxSelect <= 2'b01;
             {     `JAL, 6'bxxxxxx,  1'bx, 1'b1}: PCMuxSelect <= 2'b01;
             {    `BEQZ, 6'bxxxxxx,  1'b1, 1'b1}: PCMuxSelect <= 2'b01;
             {    `BNEZ, 6'bxxxxxx,  1'b0, 1'b1}: PCMuxSelect <= 2'b01;
             {     `RFE, 6'bxxxxxx,  1'bx, 1'bx}: PCMuxSelect <= 2'b10;
             {    `TRAP, 6'bxxxxxx,  1'bx, 1'bx}: PCMuxSelect <= 2'b10;
             {      `JR, 6'bxxxxxx,  1'bx, 1'b1}: PCMuxSelect <= 2'b11;
             {    `JALR, 6'bxxxxxx,  1'bx, 1'b1}: PCMuxSelect <= 2'b11;
             {6'bxxxxxx,    `TRAP2,  1'bx, 1'bx}: PCMuxSelect <= 2'b10;
             {6'bxxxxxx, 6'bxxxxxx,  1'bx, 1'b0}: PCMuxSelect <= 2'b10;
                                         default: PCMuxSelect <= 2'b00;                            
       endcase                   
end

assign PCVector[`WordSize] = 32'h00000000;

endmodule


module IDCtrl (
        IR2,                           // Instruction that is being decoded in Stage II
        PCAddMuxSelect                 // Select Signals for the PCAddMux in Stage II
);

/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */

input  [`WordSize]      IR2;
output [1:0]            PCAddMuxSelect;

reg    [1:0]            PCAddMuxSelect;

always @(IR2)
begin
       case(IR2[`OP])
           `BEQZ     : PCAddMuxSelect <= 2'b00;
           `BNEZ     : PCAddMuxSelect <= 2'b00;
              `J     : PCAddMuxSelect <= 2'b01;
            `JAL     : PCAddMuxSelect <= 2'b01;
             `JR     : PCAddMuxSelect <= 2'b10;
           `JALR     : PCAddMuxSelect <= 2'b10;
       endcase
end

endmodule


//**********************************************************************
					
//**********************************************************************
module EXCtrl (
	IR3,				// Instruction that is being decoded in stage II
	IR4,
	IR5,
	ShiftAmount,
 	DestinationMuxSelect,
	DataWriteMuxSelect,
	ALUSelect,
	ShiftSelect,
	ALUorShiftMuxSelect,
	SourceMuxSelect,
	TargetMuxSelect,
	CompareMux1Select,
	CompareMux2Select,
	CompareResultMuxSelect
);
					
/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */
					
input  [`WordSize]	IR3;	
input  [`WordSize]	IR4;
input  [`WordSize]	IR5;
input  [`WordSize]	ShiftAmount;
output [1:0]			DestinationMuxSelect;
output					DataWriteMuxSelect;
output [5:0]			ALUSelect;
output [4:0]			ShiftSelect;
output [1:0]			ALUorShiftMuxSelect;
output [1:0]			SourceMuxSelect;
output [1:0]			TargetMuxSelect;
output [1:0]			CompareMux1Select;
output [1:0]			CompareMux2Select;
output [1:0]			CompareResultMuxSelect;	

reg    [1:0]		DestinationMuxSelect;
reg					DataWriteMuxSelect;
reg    [5:0]		ALUSelect;
reg    [4:0]		ShiftSelect;
reg    [1:0]		ALUorShiftMuxSelect;
reg    [1:0]		SourceMuxSelect;
reg    [1:0]		TargetMuxSelect;
reg    [1:0]		CompareMux1Select;
reg    [1:0]		CompareMux2Select;
reg    [1:0]		CompareResultMuxSelect;

reg    [4:0]		SourceReg;
reg    [4:0]		TargetReg;
reg    [4:0]		IR4WriteReg;
reg    [4:0]		IR5WriteReg;
reg    [1:0]		Immediate;

always @(IR3[`OP] or IR3[`OPx] or IR3[`RS] or IR3[`RT] or ShiftAmount[4:0])
begin
	casex({IR3[`OP], IR3[`OPx]})
		{`SPECIAL, `ADD}:	
		begin
			ALUSelect = 6'b100110;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `ADDU}:
		begin
			ALUSelect = 6'b100110;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SUB}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SUBU}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `AND}:
		begin
			ALUSelect = 6'b111000;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `OR}:
		begin
			ALUSelect = 6'b101100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `XOR}:
		begin
			ALUSelect = 6'b100100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SLL}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b01;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SRL}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b10;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SRA}: 
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b11;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `TRAP}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SEQ}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b01;
			CompareResultMuxSelect = 2'b01;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SNE}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b10;
			CompareResultMuxSelect = 2'b01;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SLT}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = 2'b00;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SGT}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b00;
			CompareResultMuxSelect = 2'b01;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SLE}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = 2'b01;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;
			Immediate = 2'b01;
		end
		{`SPECIAL, `SGE}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b01;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = 2'b10;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;
			Immediate = 2'b01;
		end
		{`J,       `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`JAL,     `DC6}:
		begin
			ALUSelect = 6'b111100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b10;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`BEQZ,	   `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`BNEZ,    `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`ADDI,    `DC6}:
		begin
			ALUSelect = 6'b100110;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`ADDUI,   `DC6}:
		begin
			ALUSelect = 6'b100110;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SUBI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SUBUI,   `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`ANDI,    `DC6}:
		begin
			ALUSelect = 6'b111000;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`ORI,     `DC6}:
		begin
			ALUSelect = 6'b101100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`XORI,    `DC6}:
		begin
			ALUSelect = 6'b100100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LHI,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b11;
			Immediate = 2'b10;
		end
		{`RFE,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`TRAP,    `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`JR,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b01;
		end
		{`JALR,	   `DC6}:
		begin
			ALUSelect = 6'b111100;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b10;
			SourceReg = `R0;
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SEQI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b01;
			CompareResultMuxSelect = 2'b01;
			Immediate = 2'b10;
		end
		{`SNEI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b10;
			CompareResultMuxSelect = 2'b01;		
			Immediate = 2'b10;
		end
		{`SLTI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = 2'b00;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;		
			Immediate = 2'b10;
		end
		{`SGTI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = 2'b00;
			CompareResultMuxSelect = 2'b01;
			Immediate = 2'b10;
		end
		{`SLEI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = 2'b01;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;
			Immediate = 2'b10;
		end
		{`SGEI,    `DC6}:
		begin
			ALUSelect = 6'b011011;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = 2'b00;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = 2'b10;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b00;
			Immediate = 2'b10;
		end
		{`SLLI,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b01;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SRLI,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b10;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SRAI,	    `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = ShiftAmount[4:0];
			ALUorShiftMuxSelect = 2'b11;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LB,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LH,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LW,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LBU,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`LHU,     `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = `DC1;
			DestinationMuxSelect = 2'b00;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SB,	   `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = 1'b0;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SH,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = 1'b0;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		{`SW,      `DC6}:
		begin
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = 1'b0;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = `R0;
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
		default:
		begin			
			ALUSelect = `DC6;
			ShiftSelect = `DC5;
			ALUorShiftMuxSelect = `DC2;
			DataWriteMuxSelect = 1'b1;
			DestinationMuxSelect = `DC2;
			SourceReg = IR3[`RS];
			TargetReg = IR3[`RT];
			CompareMux1Select = `DC2;
			CompareMux2Select = `DC2;
			CompareResultMuxSelect = 2'b10;
			Immediate = 2'b10;
		end
	endcase
end

always @(IR4[`OP] or IR4[`OPx] or IR4[`RD] or IR4[`RT])
begin
	casex({IR4[`OP], IR4[`OPx]})
		{`SPECIAL, `ADD}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `ADDU}:	IR4WriteReg = IR4[`RD];	
		{`SPECIAL, `SUB}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SUBU}:	IR4WriteReg = IR4[`RD];
		{`SPECIAL, `AND}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `OR}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `XOR}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SLL}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SRL}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SRA}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SEQ}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SNE}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SLT}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SGT}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SLE}:		IR4WriteReg = IR4[`RD];
		{`SPECIAL, `SGE}:		IR4WriteReg = IR4[`RD];
		{`ADDI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`ADDUI,   `DC6}:		IR4WriteReg = IR4[`RT];
		{`SUBI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SUBUI,   `DC6}:		IR4WriteReg = IR4[`RT];
		{`ANDI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`ORI,     `DC6}:		IR4WriteReg = IR4[`RT];
		{`XORI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`LHI,     `DC6}:		IR4WriteReg = IR4[`RT];
		{`JALR,	  `DC6}:		IR4WriteReg = IR4[`RD];
		{`SEQI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SNEI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SLTI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SGTI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SLEI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SGEI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SLLI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SRLI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`SRAI,    `DC6}:		IR4WriteReg = IR4[`RT];
		{`LB,      `DC6}:		IR4WriteReg = IR4[`RT];
		{`LH,      `DC6}:		IR4WriteReg = IR4[`RT];
		{`LW,      `DC6}:		IR4WriteReg = IR4[`RT];
		{`LBU,     `DC6}:		IR4WriteReg = IR4[`RT];
		{`LHU,     `DC6}:		IR4WriteReg = IR4[`RT];
					default:		IR4WriteReg = `R0;
	endcase
end

always @(IR5[`OP] or IR5[`OPx] or IR5[`RD] or IR5[`RT])
begin
	casex({IR5[`OP], IR5[`OPx]})
		{`SPECIAL, `ADD}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `ADDU}:	IR5WriteReg = IR5[`RD];	
		{`SPECIAL, `SUB}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SUBU}:	IR5WriteReg = IR5[`RD];
		{`SPECIAL, `AND}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `OR}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `XOR}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SLL}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SRL}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SRA}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SEQ}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SNE}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SLT}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SGT}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SLE}:		IR5WriteReg = IR5[`RD];
		{`SPECIAL, `SGE}:		IR5WriteReg = IR5[`RD];
		{`ADDI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`ADDUI,   `DC6}:		IR5WriteReg = IR5[`RT];
		{`SUBI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SUBUI,   `DC6}:		IR5WriteReg = IR5[`RT];
		{`ANDI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`ORI,     `DC6}:		IR5WriteReg = IR5[`RT];
		{`XORI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`LHI,     `DC6}:		IR5WriteReg = IR5[`RT];
		{`JALR,	  `DC6}:		IR5WriteReg = IR5[`RD];
		{`SEQI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SNEI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SLTI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SGTI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SLEI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SGEI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SLLI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SRLI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`SRAI,    `DC6}:		IR5WriteReg = IR5[`RT];
		{`LB,      `DC6}:		IR5WriteReg = IR5[`RT];
		{`LH,      `DC6}:		IR5WriteReg = IR5[`RT];
		{`LW,      `DC6}:		IR5WriteReg = IR5[`RT];
		{`LBU,     `DC6}:		IR5WriteReg = IR5[`RT];
		{`LHU,     `DC6}:		IR5WriteReg = IR5[`RT];
					default:		IR5WriteReg = `R0;
	endcase
end

always @(SourceReg or TargetReg or IR4WriteReg or IR5WriteReg or Immediate)
begin
	casex({SourceReg, IR4WriteReg, IR5WriteReg})
		{`R0,			`DC5,			`DC5}:	SourceMuxSelect = 2'b11;
		{SourceReg,	SourceReg,	`DC5}:	SourceMuxSelect = 2'b10;
		{SourceReg,	`DC5,	 SourceReg}:   SourceMuxSelect = 2'b00;
									 default:   SourceMuxSelect = 2'b01;
	endcase

	casex({TargetReg, IR4WriteReg, IR5WriteReg})
		{`R0,			`DC5,			`DC5}:	TargetMuxSelect = Immediate;
		{TargetReg,	TargetReg,	`DC5}:   TargetMuxSelect = 2'b11;
		{TargetReg,	`DC5,	 TargetReg}:   TargetMuxSelect = 2'b00;
									 default:   TargetMuxSelect = Immediate;
	endcase
end

endmodule

module MemCtrl (
	IR4,
	DRead,
	DWrite
);
					
/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */
					
input  [`WordSize]	IR4;
output					DRead;
output					DWrite;

reg			DRead;
reg			DWrite;

always @(IR4[`OP] or IR4[`OPx])
begin
	casex({IR4[`OP], IR4[`OPx]})
		{`LB, `DC6}:
		begin
			DRead = `LogicOne;
			DWrite = `LogicZero;
		end
		{`LBU, `DC6}:
		begin
			DRead = `LogicOne;
			DWrite = `LogicZero;
		end
		{`LH, `DC6}:
		begin
			DRead = `LogicOne;
			DWrite = `LogicZero;
		end
		{`LHU, `DC6}:
		begin
			DRead = `LogicOne;
			DWrite = `LogicZero;
		end
		{`LW,  `DC6}:
		begin
			DRead = `LogicOne;
			DWrite = `LogicZero;
		end
		{`SB,  `DC6}:
		begin
			DRead = `LogicZero;
			DWrite = `LogicOne;
		end
		{`SH,  `DC6}:
		begin
			DRead = `LogicZero;
			DWrite = `LogicOne;
		end
		{`SW,  `DC6}:
		begin
			DRead = `LogicZero;
			DWrite = `LogicOne;
		end
		default:
		begin
			DRead = `LogicZero;
			DWrite = `LogicZero;
		end
	endcase
end

endmodule

module WBCtrl (
	IR5,
	WBMuxSelect,
	WriteEnable
);
					
/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */
					
input  [`WordSize]	IR5;
output			WBMuxSelect;
output			WriteEnable;

reg			WBMuxSelect;
reg			WriteEnable;

always @(IR5[`OP] or IR5[`OPx])
begin
	casex({IR5[`OP], IR5[`OPx]})
		{`LB,      `DC6}:	WBMuxSelect = 1'b0;
		{`LH,      `DC6}:	WBMuxSelect = 1'b0;
		{`LW,      `DC6}:	WBMuxSelect = 1'b0;
		{`LBU,     `DC6}:	WBMuxSelect = 1'b0;
		{`LHU,     `DC6}:	WBMuxSelect = 1'b0;
		default:		WBMuxSelect = 1'b1;
	endcase

	casex({IR5[`OP], IR5[`OPx]})
		{`SPECIAL, `ADD}:		WriteEnable = 1'b1;
		{`SPECIAL, `ADDU}:	WriteEnable = 1'b1;
		{`SPECIAL, `SUB}:		WriteEnable = 1'b1;
		{`SPECIAL, `SUBU}:	WriteEnable = 1'b1;
		{`SPECIAL, `AND}:		WriteEnable = 1'b1;
		{`SPECIAL, `OR}:		WriteEnable = 1'b1;
		{`SPECIAL, `XOR}:		WriteEnable = 1'b1;
		{`SPECIAL, `SLL}:		WriteEnable = 1'b1;
		{`SPECIAL, `SRL}:		WriteEnable = 1'b1;
		{`SPECIAL, `SRA}:		WriteEnable = 1'b1;
		{`SPECIAL, `SEQ}:		WriteEnable = 1'b1;
		{`SPECIAL, `SNE}:		WriteEnable = 1'b1;
		{`SPECIAL, `SLT}:		WriteEnable = 1'b1;
		{`SPECIAL, `SGT}:		WriteEnable = 1'b1;
		{`SPECIAL, `SLE}:		WriteEnable = 1'b1;
		{`SPECIAL, `SGE}:		WriteEnable = 1'b1;
		{`ADDI,    `DC6}:		WriteEnable = 1'b1;
		{`ADDUI,   `DC6}:		WriteEnable = 1'b1;
		{`SUBI,    `DC6}:		WriteEnable = 1'b1;
		{`SUBUI,   `DC6}:		WriteEnable = 1'b1;
		{`ANDI,    `DC6}:		WriteEnable = 1'b1;
		{`ORI,     `DC6}:		WriteEnable = 1'b1;
		{`XORI,    `DC6}:		WriteEnable = 1'b1;
		{`LHI,     `DC6}:		WriteEnable = 1'b1;
		{`JAL,	  `DC6}:		WriteEnable = 1'b1;
		{`JALR,	  `DC6}:		WriteEnable = 1'b1;
		{`SEQI,    `DC6}:		WriteEnable = 1'b1;
		{`SNEI,    `DC6}:		WriteEnable = 1'b1;
		{`SLTI,    `DC6}:		WriteEnable = 1'b1;
		{`SGTI,    `DC6}:		WriteEnable = 1'b1;
		{`SLEI,    `DC6}:		WriteEnable = 1'b1;
		{`SGEI,    `DC6}:		WriteEnable = 1'b1;
		{`SLLI,    `DC6}:		WriteEnable = 1'b1;
		{`SRLI,    `DC6}: 	WriteEnable = 1'b1;
		{`SRAI,    `DC6}:		WriteEnable = 1'b1;
		{`LB,      `DC6}:		WriteEnable = 1'b1;
		{`LH,      `DC6}:		WriteEnable = 1'b1;
		{`LW,      `DC6}:		WriteEnable = 1'b1;
		{`LBU,     `DC6}:		WriteEnable = 1'b1;
		{`LHU,     `DC6}:		WriteEnable = 1'b1;
					default:		WriteEnable = 1'b0;
	endcase
end

endmodule
