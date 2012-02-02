`include "./dlx.defines"
`define MEMSIZE 58
`timescale 1ns/1ps

module test;
   
   reg [`WordSize]	IIn;
   reg 			MRST;
   reg [4:0] 		i;
   reg [31:0] 		memory[`MEMSIZE - 1:0];	
   reg [3:0] 		l;
   wire [`WordSize] 	IAddr;
	reg clk;
	wire troout;
	
   always @(negedge(DLX.PHI1)) 
      begin 
	 $display($time,"The outputs are %b",DLX.DOut);
	 $display($time,"The program counter reads", DLX.IAddr);
	 if (IAddr>= 4)
	    if (IAddr >232)
	       begin
		  IIn={`SPECIAL, 5'b0, 5'b0, 5'b0, 5'b0, `NOP};	//   NOP
	       end // if (IAddr >28)
	 else
	    begin
	       #2 IIn=memory[IAddr/4];
	    end
      end
   always forever #5 clk = ~clk;
   initial
      begin
		clk <= 1'b0;
	 $readmemb("test1.dat", memory);
//	 force DLX.RegFile.WE = 0 ;
//	 for (i = 0; i < 24; i = i+1) 
//	    begin
//	       force DLX.RegFile.W = i ;
//	       force DLX.RegFile.IN0 = 0 ;
//	       #2 force DLX.RegFile.WE = 1 ;  
//	       #2 force DLX.RegFile.WE = 0 ;  
//	       
//	    end
//	 
//	 #4 release DLX.RegFile.W;
//	 release DLX.RegFile.IN0;
//	 release DLX.RegFile.WE;
	 $display("Starting simulation.");
	 MRST = `LogicZero;
	 MRST = #20 `LogicOne;

	 // reading from mem

	 #2 IIn=memory[0];

	 // #20 IIn=memory[1];
	 // #20 IIn=memory[2];
	 // #20 IIn=memory[3];
	 // $display("memory 4=%b", memory[4]);
	 // #20 IIn=memory[4];
	 
	 // for(l = 1 ; l < 5 ; l = l + 1)
	 //  begin 
	 //   #20 IIn=memory[l];
	 // end
	 
	 	 
	// IIn = #2  {`ADDI, `R1, `R1, 16'b0000000000000001};	//  ADDI R1, R1, 0001
	// IIn = #20 {`SPECIAL, `R1, `R1, `R2, 5'b0, `ADD};        //   ADD R2, R1, R1
	// IIn = #20 {`SPECIAL, `R2, `R2, `R3, 5'b0, `ADDU};	//  ADDU R3, R2, R2
	// IIn = #20 {`J, 26'b0000000000000000000010000};		//     J 10
	// IIn = #20 {`BEQZ, `R6, 5'b0, 16'b1111111100000000};	//  BEQZ R6, FF00
	// IIn = #20 {`SPECIAL, 5'b0, 5'b0, 5'b0, 5'b0, `NOP};	//   NOP
	// IIn = #20 {`SPECIAL, 5'b0, 5'b0, 5'b0, 5'b0, `NOP};	//   NOP
	 
      end
   
//clkgen CLKGEN(
//	.clk  (DLX.PHI1)
//);
  
dlx DLX(
	.PHI1	(clk),
	.DIn	(),
	.IIn	(IIn),
	.MRST	(MRST),
	.TCE	(`LogicZero),
	.TMS	(`LogicZero),
	.TDI	(`LogicZero),
	.DAddr	(),
	.DRead	(),
	.DWrite	(),
	.DOut	(),
	.IAddr	(IAddr),
	.IRead	(),
	.TDO	(), 
	.troout(troout)
);

assign troout = 1'b0;

endmodule













