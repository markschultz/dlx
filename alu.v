//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module alu(A,B,C0,M,S0,S1,S2,S3,COUT,F);
  parameter N = 32;
  parameter FAST = 0;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_COUT_r = 1,
        d_COUT_f = 1,
        d_F = 1;
  input [(N - 1):0] A;
  input [(N - 1):0] B;
  input  C0;
  input  M;
  input  S0;
  input  S1;
  input  S2;
  input  S3;
  output  COUT;
  output [(N - 1):0] F;
  wire [(N - 1):0] A_temp;
  wire [(N - 1):0] B_temp;
  wire  COUT_temp;
  wire [(N - 1):0] F_temp;
  reg [3:0] s;
  wire  overflow;
  assign A_temp = A|A;
  assign B_temp = B|B;
  assign #(d_COUT_r,d_COUT_f) COUT = COUT_temp;
  assign #(d_F) F = F_temp;
  /*
  initial
    begin
    if((DPFLAG == 0))
      $display("(WARNING) The instance %m of type alu can't be implemented as a standard cell.");
    end
  */
  always
    @(S0 or S1 or S2 or S3)
      begin
      s[3] = S3;
      s[2] = S2;
      s[1] = S1;
      s[0] = S0;
      end
  alu_generic #(N) inst1 (A_temp,B_temp,C0,M,s,COUT_temp,F_temp,overflow);
endmodule
