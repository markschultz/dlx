//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module regfile2r(IN0,R1,R2,RE1,RE2,W,WE,OUT1,OUT2);
  parameter N = 32;
  parameter WORDS = 32;
  parameter M = 5;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_OUT1 = 1,
        d_OUT2 = 1;
  input [(N - 1):0] IN0;
  input [(M - 1):0] R1;
  input [(M - 1):0] R2;
  input  RE1;
  input  RE2;
  input [(M - 1):0] W;
  input  WE;
  output [(N - 1):0] OUT1;
  output [(N - 1):0] OUT2;
  reg [(N - 1):0] OUT1_temp;
  reg [(N - 1):0] OUT2_temp;
  reg  flag1;
  reg  flag2;
  reg  error_flag;
  reg [(M - 1):0] W_old;
  reg [(N - 1):0] mem_array[(WORDS - 1):0];
  integer i;


  assign #(d_OUT1) OUT1 = OUT1_temp;
  assign #(d_OUT2) OUT2 = OUT2_temp;


always @(WE or IN0 or W) 
    if (WE == 1'b1) mem_array[W] = IN0 ;

always @(RE1 or R1) 
        if (RE1 == 1'b1) OUT1_temp = mem_array[R1] ;

always @(RE2 or R2) 
        if (RE2 == 1'b1) OUT2_temp = mem_array[R2] ;

endmodule
