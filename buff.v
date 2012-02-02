//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module buff(IN0,Y);
  parameter N = 32;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_Y = 1;
  input [(N - 1):0] IN0;
  output [(N - 1):0] Y;
  wire [(N - 1):0] IN0_temp;
  reg [(N - 1):0] Y_temp;
  assign IN0_temp = IN0|IN0;
  assign #(d_Y) Y = Y_temp;
  always
    @(IN0_temp)
      Y_temp = IN0_temp;
endmodule
