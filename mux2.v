//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module newmux2(IN0,IN1,S0,Y);
  parameter N = 32;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_Y = 1;
  input [(N - 1):0] IN0;
  input [(N - 1):0] IN1;
  input  S0;
  output [(N - 1):0] Y;
  wire [(N - 1):0] IN0_temp;
  wire [(N - 1):0] IN1_temp;
  reg [(N - 1):0] Y_temp;
  reg [(N - 1):0] XX;
  assign IN0_temp = IN0|IN0;
  assign IN1_temp = IN1|IN1;
  assign #(d_Y) Y = Y_temp;
  /*
  initial
    XX = 128'bx;
  */
  always
    @(IN0_temp or IN1_temp or S0)
      begin
      if((S0 == 1'b0))
        Y_temp = IN0_temp;
      else      if((S0 == 1'b1))
        Y_temp = IN1_temp;
      else
        Y_temp = (((IN0_temp ^ IN1_temp) & XX) | IN0_temp);
      end
endmodule
