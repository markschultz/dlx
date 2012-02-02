/*************************************************************************
 * FILE:        dlx.v
 * Written By:  Michael J. Kelley
 * Written On:  December 18, 1995
 * Updated By:  Michael J. Kelley
 * Updated On:  March 4, 1996
 *
 * Description:
 *
 * This file contains the hardware description of the DLX architecture
 * as specified by Hennessy and Patterson in Computer Architecture a 
 * Quantitative Approach.
 *************************************************************************
 */

//`include "/l/users/mkelley/DLX/verilog/dlx.defines"
`include "./dlx.defines"
`timescale 1ns/1ps

module dlx (
	PHI1,                             // One-Phase clock for DLX 
	DAddr, DRead, DWrite, DOut, DIn,  // Data Cache interface
	IAddr, IRead, IIn,                // Instruction Cache interface
	MRST, TCE, TMS, TDI, TDO,          // Test Controls
	troout
);

/*************************************************************************
 * Parameter Declarations
 *************************************************************************
 */
					
input						PHI1;		// One-Phase clock signal used
output [`WordSize]	DAddr;          // Address for Data Cache read/write
output					DRead;          // Data Cache read enable
output					DWrite;         // Data Cache write enable
output [`WordSize]	DOut;           // Data Input to Data Cache (write)
input  [`WordSize]	DIn;            // Data Output from Data Cache (read)
output [`WordSize]	IAddr;          // Instruction Cache read address
output					IRead;          // Instruction Cache read enable
input  [`WordSize]	IIn;            // Instruction from Instruction Cache
input						MRST;           // Master Reset
input						TCE;            // Test Clock Enable
input						TMS;		// Test Mode Select
input						TDI;		// Test Data In
output					TDO;		// Test Data Out
input 					troout;
			
wire	[`WordSize]	DAddr;
wire					DRead, MemControl_DRead;
wire					DWrite, MemControl_DWrite;
wire	[`WordSize]	DOut, DataWriteReg_Q; // PCAddMux_Y,
wire	[`WordSize]	IAddr, IR2_Q; // PCInc_SUM,
wire					IRead;
wire					TDO;
//wire  [1:0]       IFControl_PCMuxSelect, IDControl_PCAddMuxSelect ;
wire  [`WordSize] RegFile_OUT1, SourceMux_IN1, TargetMux_IN1, PC2_Q, PC4_D; // RegFile_OUT2, EXControl_IR3,
wire  [`WordSize] PCMux_Y, PC2_D, PC1_Q, PC3_D, IDControl_IR2, PCAdd_A; // PCIncReg_Q,
//wire  [1:0] 		  EXControl_SourceMuxSelect, EXControl_TargetMuxSelect, EXControl_DestinationMuxSelect, EXControl_ALUorShiftMuxSelect, EXControl_CompareMux1Select ;
wire  [`WordSize] WBMux_Y, SourceReg_Q, DataWriteMux_IN0, IR3_Q, ALU_F ; // PC1_D,
wire  [`WordSize] TargetReg_Q, DataWriteMux_IN1, PCAdd_SUM; // IFControl_PCVector
//wire  [5:0] 		  EXControl_ALUSelect ;
//wire  [4:0] 	 	  EXControl_ShiftSelect ;
//wire  [`WordSize] ShiftLeft_Y, ShiftRight_Y, ShiftRightArith_Y, DataWriteReg_D ;
//wire  [1:0] 		  EXControl_CompareMux2Select, EXControl_CompareResultMuxSelect ;
//wire  [`WordSize] SourceMux_Y, TargetMux_Y, ALUorShiftMux_Y,CompareResultMux_Y ;
//wire  [`WordSize] SourceMux_IN2, DataWriteMux_Y, PC5_D, MemControl_IR4, PC3_Q; 
wire  [`WordSize] WBMux_IN0, WBMux_IN1, WBControl_IR5, PC4_Q, IR4_Q; // TargetReg_D, Shift_Y,
wire  [4:0] 		RegFile_W, DestinationReg_Q, DestinationMux_Y, WriteDestinationReg_Q; // DestinationReg_D, ShiftLeft_S, 
wire  [`WordSize] IR5_Q;
wire 					IFControl_Equal, WBControl_WriteEnable;

IF_stage part1_IF ( 
	PHI1, MRST, IFControl_Equal, 
	IIn, PCAdd_SUM, RegFile_OUT1, 
	IAddr, PC3_D, IDControl_IR2, PCAdd_A
);

ID_stage part2_ID ( 
	PHI1, MRST, WBControl_WriteEnable,
	IDControl_IR2, WBMux_Y, PCAdd_A, PC3_D,
	WriteDestinationReg_Q,
	RegFile_OUT1, PCAdd_SUM, SourceMux_IN1, TargetMux_IN1, PC4_D, IR3_Q,
	IFControl_Equal
);

EX_stage part3_EX (
	PHI1, MRST,
	IR3_Q, IR5_Q, WBMux_Y, SourceMux_IN1, TargetMux_IN1, PCAdd_A, PC4_D,
	IR4_Q, DAddr, DOut, PC4_Q,
	DestinationReg_Q
);

MEM_stage part4_MEM (
	PHI1, MRST,
	DIn, DAddr, IR4_Q, PC4_Q, 
	DestinationReg_Q,
	WBMux_IN0, WBMux_IN1, IR5_Q, 
	WriteDestinationReg_Q,
	DRead, DWrite
);

WB_stage part5_WB (
	WBMux_IN0, WBMux_IN1, IR5_Q,
	WBMux_Y,
	WBControl_WriteEnable,
	troout
);

endmodule

/*************************************************************************
 * Instruction Fetch (IF) Stage of DLX Pipeline
 *************************************************************************
 */
module IF_stage ( 
	PHI1, MRST, IFControl_Equal, 
	IIn, PCAdd_SUM, RegFile_OUT1, 
	IAddr, PC3_D, IDControl_IR2, PCAdd_A
);
input [`WordSize] IIn, PCAdd_SUM, RegFile_OUT1;
input PHI1, MRST, IFControl_Equal;
output [`WordSize] IAddr, PC3_D, IDControl_IR2, PCAdd_A;

wire [`WordSize] PC1_Q, PCInc_SUM, PC1_D, IFControl_PCVector; 
wire [1:0] IFControl_PCMuxSelect;

IFCtrl 

	IFControl (
		.IR2		(IDControl_IR2),
		.Equal		(IFControl_Equal),
		.MRST		(MRST),
		.PCMuxSelect	(IFControl_PCMuxSelect),
		.PCVector	(IFControl_PCVector)
	);

addhsv #(32, 1, "AUTO") 
	
	PCInc (
		.A	(PC1_Q),
		.B	(`PCInc),
		.CIN	(`LogicZero),
		.SUM	(PCInc_SUM),
		.COUT	(),
		.OVF	()
	);

newmux4 #(32, 1, "AUTO") 

	PCMux (
		.S0	(IFControl_PCMuxSelect[0]),
		.S1	(IFControl_PCMuxSelect[1]),
		.IN0	(PCInc_SUM),
		.IN1	(PCAdd_SUM),
		.IN2	(IFControl_PCVector),
		.IN3	(RegFile_OUT1),
		.Y	(PC1_D)
	);

dff_cq #(32, 1, "AUTO") 
	
	PC1 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PC1_D),
		.Q	(PC1_Q),
		.QBAR	()
	),

	PC2 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PC1_Q),
		.Q	(PC3_D),
		.QBAR	()
	);

assign IAddr = PC1_Q;

dff_cq #(32, 1, "AUTO")

	IR2 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(IIn),
		.Q	(IDControl_IR2),
		.QBAR	()
	),

	PCIncReg  (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PCInc_SUM),
		.Q	(PCAdd_A),
		.QBAR	()
	);

endmodule

/*************************************************************************
 * Instruction Decode (ID) Stage of DLX Pipeline
 *************************************************************************
 */
module ID_stage ( 
	PHI1, MRST, WBControl_WriteEnable,
	IDControl_IR2, WBMux_Y, PCAdd_A, PC3_D,
	WriteDestinationReg_Q,
	RegFile_OUT1, PCAdd_SUM, SourceMux_IN1, TargetMux_IN1, PC4_D, IR3_Q,
	IFControl_Equal
);

input PHI1, MRST, WBControl_WriteEnable;
input [`WordSize] IDControl_IR2, WBMux_Y, PCAdd_A, PC3_D; 
input [4:0] WriteDestinationReg_Q;
output [`WordSize] RegFile_OUT1, PCAdd_SUM, SourceMux_IN1, TargetMux_IN1, PC4_D, IR3_Q;
output IFControl_Equal;

wire [1:0] IDControl_PCAddMuxSelect;
wire [`WordSize] TargetReg_D, PCAddMux_Y;

IDCtrl 
	IDControl (
		.IR2		(IDControl_IR2),
		.PCAddMuxSelect	(IDControl_PCAddMuxSelect)
	);

regfile2r #(32, 32, 5, "AUTO")

	RegFile (
		.W	(WriteDestinationReg_Q),
		.IN0	(WBMux_Y),
		.R1	(IDControl_IR2[`RS]),
		.R2	(IDControl_IR2[`RT]),
		.RE1	(`LogicOne),
		.RE2	(`LogicOne),
		.WE	(WBControl_WriteEnable & ~PHI1),
		.OUT1	(RegFile_OUT1),
		.OUT2	(TargetReg_D)
	);

newmux3 #(32, 1, "AUTO")

	PCAddMux (
		.S0	(IDControl_PCAddMuxSelect[0]),
		.S1	(IDControl_PCAddMuxSelect[1]),
		.IN0	({{16{IDControl_IR2[15]}}, IDControl_IR2[`Immediate]}),
		.IN1	({{6{IDControl_IR2[25]}}, IDControl_IR2[`Target]}),
		.IN2	(RegFile_OUT1),
		.Y	(PCAddMux_Y)
	);

addhsv #(32, 1, "AUTO") 
	
	PCAdd (
		.A	(PCAdd_A),
		.B	(PCAddMux_Y),
		.CIN	(`LogicZero),
		.SUM	(PCAdd_SUM),
		.COUT	(),
		.OVF	()
	);

zero_compare #(1, "AUTO")

	Compare (
		.A				(RegFile_OUT1),
		.A_lessthan_zero		(),
		.A_lessthan_equal_zero		(),
		.A_greaterthan_equal_zero	(),
		.A_greaterthan_zero		(),
		.A_equal_zero			(IFControl_Equal),
		.A_not_equal_zero		()
	);

dff_cq #(32, 1, "AUTO")

	SourceReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(RegFile_OUT1),
		.Q	(SourceMux_IN1),
		.QBAR	()
	),

	TargetReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(TargetReg_D),
		.Q	(TargetMux_IN1),
		.QBAR	()
	),

	PC3 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PC3_D),
		.Q	(PC4_D),
		.QBAR	()
	);

dff_cq #(32, 1, "AUTO")	

	IR3 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(IDControl_IR2),
		.Q	(IR3_Q),
		.QBAR	()
	);

endmodule

/*************************************************************************
 * Execute (EX) Stage of DLX Pipeline
 *************************************************************************
 */
module EX_stage (
	PHI1, MRST,
	IR3_Q, IR5_Q, WBMux_Y, SourceMux_IN1, TargetMux_IN1, PCAdd_A, PC4_D,
	IR4_Q, DAddr, DOut, PC4_Q,
	DestinationReg_Q
);
input PHI1, MRST;
input [`WordSize] IR3_Q, IR5_Q, WBMux_Y, SourceMux_IN1, TargetMux_IN1, PCAdd_A, PC4_D;
output [`WordSize] IR4_Q, DAddr, DOut, PC4_Q;
output [4:0] DestinationReg_Q;

wire [`WordSize] SourceMux_Y, TargetMux_Y;
wire [1:0] EXControl_DestinationMuxSelect, EXControl_ALUorShiftMuxSelect, EXControl_SourceMuxSelect, EXControl_TargetMuxSelect;
wire [1:0] EXControl_CompareMux1Select, EXControl_CompareMux2Select, EXControl_CompareResultMuxSelect;
wire DataWriteMux_S0;
wire [5:0] EXControl_ALUSelect;
wire [4:0] ShiftLeft_S, DestinationReg_D;
wire [`WordSize] DataWriteReg_D, ALU_F, Shift_Y, ALUorShiftMux_Y, CompareResultMux_Y;
wire CompareMux1_IN0, CompareMux1_IN1, CompareMux1_IN2, CompareMux2_IN0, CompareMux2_IN1, CompareMux2_IN2;
wire CompareMux1_Y, CompareMux2_Y;

EXCtrl
	EXControl (
		.IR3			(IR3_Q),
		.IR4			(IR4_Q),
		.IR5			(IR5_Q),
		.ShiftAmount		(TargetMux_Y),
		.DestinationMuxSelect	(EXControl_DestinationMuxSelect),
		.DataWriteMuxSelect	(DataWriteMux_S0),
		.ALUSelect		(EXControl_ALUSelect),
		.ShiftSelect		(ShiftLeft_S),
		.ALUorShiftMuxSelect	(EXControl_ALUorShiftMuxSelect),
		.SourceMuxSelect	(EXControl_SourceMuxSelect),
		.TargetMuxSelect	(EXControl_TargetMuxSelect),
		.CompareMux1Select	(EXControl_CompareMux1Select),
		.CompareMux2Select	(EXControl_CompareMux2Select),
		.CompareResultMuxSelect	(EXControl_CompareResultMuxSelect)
	);

newmux4 #(32, 1, "AUTO") 

	SourceMux (
		.S0	(EXControl_SourceMuxSelect[0]),
		.S1	(EXControl_SourceMuxSelect[1]),
		.IN0	(WBMux_Y),
		.IN1	(SourceMux_IN1),
		.IN2	(DAddr),
		.IN3	(PCAdd_A),
		.Y	(SourceMux_Y)
	);


newmux4 #(32, 1, "AUTO")

	TargetMux (
		.S0	(EXControl_TargetMuxSelect[0]),
		.S1	(EXControl_TargetMuxSelect[1]),
		.IN0	(WBMux_Y),
		.IN1	(TargetMux_IN1),
		.IN2	({{16{IR3_Q[15]}},IR3_Q[`Immediate]}),
		.IN3	(DAddr),
		.Y	(TargetMux_Y)
	);

newmux3_5 #(5, 1, "AUTO")

	DestinationMux (
		.S0	(EXControl_DestinationMuxSelect[0]),
		.S1	(EXControl_DestinationMuxSelect[1]),
		.IN0	(IR3_Q[`RT]),
		.IN1	(IR3_Q[`RD]),
		.IN2	(5'b11111),
		.Y	(DestinationReg_D)
	);

newmux2 #(32, 1, "AUTO")

	DataWriteMux (
		.S0	(DataWriteMux_S0),
		.IN0	(SourceMux_Y),
		.IN1	(TargetMux_Y),
		.Y	(DataWriteReg_D)
	);

alu #(32, 1, "AUTO")

	ALU (
		.C0	(EXControl_ALUSelect[0]),
		.A	(SourceMux_Y),
		.B	(TargetMux_Y),
		.S0	(EXControl_ALUSelect[2]),
		.S1	(EXControl_ALUSelect[3]),
		.S2	(EXControl_ALUSelect[4]),
		.S3	(EXControl_ALUSelect[5]),
		.M	(EXControl_ALUSelect[1]),
		.F	(ALU_F),
		.COUT	()
	);

shifter 
        Shifter (
                .IN0    (SourceMux_Y),
                .S      (ShiftLeft_S),
                .S2     (EXControl_ALUorShiftMuxSelect),
                .Y      (Shift_Y) 
        );

newmux2 #(32, 1, "AUTO")

	ALUorShiftMux (
		.S0	(|EXControl_ALUorShiftMuxSelect),
		.IN0	(ALU_F),
		.IN1	(Shift_Y),
		.Y	(ALUorShiftMux_Y)
	);

zero_compare #(1, "AUTO")

	Compare2 (
		.A				(ALU_F),
		.A_lessthan_zero		(CompareMux1_IN0),
		.A_lessthan_equal_zero		(CompareMux1_IN1),
		.A_greaterthan_equal_zero	(CompareMux1_IN2),
		.A_greaterthan_zero		(CompareMux2_IN0),
		.A_equal_zero			(CompareMux2_IN1),
		.A_not_equal_zero		(CompareMux2_IN2)
	);

newmux3_1 #(1, 1, "AUTO")

	CompareMux1 (
		.S0	(EXControl_CompareMux1Select[0]),
		.S1	(EXControl_CompareMux1Select[1]),
		.IN0	(CompareMux1_IN0),
		.IN1	(CompareMux1_IN1),
		.IN2	(CompareMux1_IN2),
		.Y	(CompareMux1_Y)
	),

	CompareMux2 (
		.S0	(EXControl_CompareMux2Select[0]),
		.S1	(EXControl_CompareMux2Select[1]),
		.IN0	(CompareMux2_IN0),
		.IN1	(CompareMux2_IN1),
		.IN2	(CompareMux2_IN2),
		.Y	(CompareMux2_Y)
	);

newmux4 #(32, 1, "AUTO")

	CompareResultMux (
		.S0	(EXControl_CompareResultMuxSelect[0]),
		.S1	(EXControl_CompareResultMuxSelect[1]),
		.IN0	({31'b0, CompareMux1_Y}),
		.IN1	({31'b0, CompareMux2_Y}),
		.IN2	(ALUorShiftMux_Y),
		.IN3	({IR3_Q[15:0], 16'b0}),
		.Y	(CompareResultMux_Y)
	);

dff_cq #(32, 1, "AUTO")

	ALUReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(CompareResultMux_Y),
		.Q	(DAddr),
		.QBAR	()
	),

	DataWriteReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(DataWriteReg_D),
		.Q	(DOut),
		.QBAR	()
	),

	PC4 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PC4_D),
		.Q	(PC4_Q),
		.QBAR	()
	);

dff_cq #(32, 1, "AUTO")	

	IR4 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(IR3_Q),
		.Q	(IR4_Q),
		.QBAR	()
	);

dff_cq5 #(5, 1, "AUTO")

	DestinationReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(DestinationReg_D),
		.Q	(DestinationReg_Q),
		.QBAR	()
	);

endmodule

/*************************************************************************
 * Memory (MEM) Stage of DLX Pipeline
 *************************************************************************
 */
module MEM_stage (
	PHI1, MRST,
	DIn, DAddr, IR4_Q, PC4_Q, 
	DestinationReg_Q,
	WBMux_IN0, WBMux_IN1, IR5_Q, 
	WriteDestinationReg_Q,
	DRead, DWrite
);
input PHI1, MRST;
input [`WordSize] DIn, DAddr, IR4_Q, PC4_Q;
input [4:0] DestinationReg_Q;
output [`WordSize] WBMux_IN0, WBMux_IN1, IR5_Q;
output [4:0] WriteDestinationReg_Q;
output DRead, DWrite;

MemCtrl 
	MemControl (
		.IR4			(IR4_Q),
		.DRead			(DRead),
		.DWrite			(DWrite)
	);

dff_cq #(32, 1, "AUTO")

	MemDataReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(DIn),
		.Q	(WBMux_IN0),
		.QBAR	()
	),

	ALUDataReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(DAddr),
		.Q	(WBMux_IN1),
		.QBAR	()
	),

	PC5 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(PC4_Q),
		.Q	(),
		.QBAR	()
	);

dff_cq #(32, 1, "AUTO") 

	IR5 (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(IR4_Q),
		.Q	(IR5_Q),
		.QBAR	()
	);

dff_cq5 #(5, 1, "AUTO")

	WriteDestinationReg (
		.CLK	(PHI1),
		.CLR	(MRST),
		.D	(DestinationReg_Q),
		.Q	(WriteDestinationReg_Q),
		.QBAR	()
	);

endmodule

/*************************************************************************
 * Write Back (WB) Stage of DLX Pipeline
 *************************************************************************
 */
module WB_stage (
	WBMux_IN0, WBMux_IN1, IR5_Q,
	WBMux_Y,
	WBControl_WriteEnable,
	troout
);

input [`WordSize] WBMux_IN0, WBMux_IN1, IR5_Q;
output [`WordSize] WBMux_Y;
output WBControl_WriteEnable;
input troout;

wire WBMux_S0;
wire WBControl_WriteEnable1;

WBCtrl 
	WBControl (
		.IR5		(IR5_Q),
		.WBMuxSelect	(WBMux_S0),
		.WriteEnable	(WBControl_WriteEnable1)
	);
	
assign WBControl_WriteEnable = WBControl_WriteEnable1^troout;

newmux2 #(32, 1, "AUTO")
	WBMux (
		.S0	(WBMux_S0),
		.IN0	(WBMux_IN0),
		.IN1	(WBMux_IN1),
		.Y	(WBMux_Y)
	);

endmodule

