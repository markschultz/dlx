//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module addhsv(A,B,CIN,COUT,OVF,SUM);
  parameter N = 32;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_COUT_r = 1,
        d_COUT_f = 1,
        d_OVF_r = 1,
        d_OVF_f = 1,
        d_SUM = 1;
  input [(N - 1):0] A;
  input [(N - 1):0] B;
  input  CIN;
  output  COUT;
  output  OVF;
  output [(N - 1):0] SUM;
  wire  COUT_temp;
  wire  OVF_temp;
  wire [(N - 1):0] SUM_temp;
  assign #(d_COUT_r,d_COUT_f) COUT = COUT_temp;
  assign #(d_OVF_r,d_OVF_f) OVF = OVF_temp;
  assign #(d_SUM) SUM = SUM_temp;
  adder_generic #(N) inst1 (A,B,CIN,COUT_temp,OVF_temp,SUM_temp);
endmodule
