//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module newmux4(IN0,IN1,IN2,IN3,S0,S1,Y);
  parameter N = 32;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_Y = 1;
  input [(N - 1):0] IN0;
  input [(N - 1):0] IN1;
  input [(N - 1):0] IN2;
  input [(N - 1):0] IN3;
  input  S0;
  input  S1;
  output [(N - 1):0] Y;
  wire [(N - 1):0] IN0_temp;
  wire [(N - 1):0] IN1_temp;
  wire [(N - 1):0] IN2_temp;
  wire [(N - 1):0] IN3_temp;
  reg [(N - 1):0] Y_temp;
  reg [(N - 1):0] XX;
  assign IN0_temp = IN0|IN0;
  assign IN1_temp = IN1|IN1;
  assign IN2_temp = IN2|IN2;
  assign IN3_temp = IN3|IN3;
  assign #(d_Y) Y = Y_temp;
  /*
  initial
    XX = 128'bx;
  */
  always
    @(IN0_temp or IN1_temp or IN2_temp or IN3_temp or S0 or S1)
      begin
      if(((S1 == 1'b0) && (S0 == 1'b0)))
        Y_temp = IN0_temp;
      else      if(((S1 == 1'b0) && (S0 == 1'b1)))
        Y_temp = IN1_temp;
      else      if(((S1 == 1'b1) && (S0 == 1'b0)))
        Y_temp = IN2_temp;
      else      if(((S1 == 1'b1) && (S0 == 1'b1)))
        Y_temp = IN3_temp;
      else
        Y_temp = ((((((IN0_temp | IN1_temp) | IN2_temp) | IN3_temp) ^ (((IN0_temp & IN1_temp) & IN2_temp) & IN3_temp)) & XX) ^ IN0_temp);
      end
endmodule
