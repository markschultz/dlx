//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module dff_cq(CLK,CLR,D,Q,QBAR);
  parameter N = 32;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_Q = 1,
        d_QBAR = 1;
  input  CLK;
  input  CLR;
  input [(N - 1):0] D;
  output [(N - 1):0] Q;
  output [(N - 1):0] QBAR;
  wire [(N - 1):0] D_temp;
  wire [(N - 1):0] Q_temp;
  reg [(N - 1):0] QBAR_temp;
  supply0  GND;
  supply1  VDD;
  assign D_temp = D|D;
  assign #(d_Q) Q = Q_temp;
  assign #(d_QBAR) QBAR = QBAR_temp;
  always
    @(Q_temp)
      QBAR_temp = ( ~ Q_temp);
  dff_generic #(N) inst1 (CLK,CLR,D_temp,GND,VDD,VDD,GND,Q_temp);
  wire [127:0] D_tcheck = D;
  specify
    specparam
      t_hold_D = 0,
      t_setup_D = 0,
      t_width_CLK = 0,
      t_width_CLR = 0;
    $hold(posedge CLK , D_tcheck , t_hold_D);
    $setup(D_tcheck , posedge CLK , t_setup_D);
    $width(posedge CLK , t_width_CLK);
    $width(negedge CLR , t_width_CLR);
  endspecify
endmodule


//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module dff_cq5(CLK,CLR,D,Q,QBAR);
  parameter N = 5;
  parameter DPFLAG = 1;
  parameter GROUP = "dpath1";
  parameter BUFFER_SIZE = "DEFAULT";
  parameter
        d_Q = 1,
        d_QBAR = 1;
  input  CLK;
  input  CLR;
  input [(N - 1):0] D;
  output [(N - 1):0] Q;
  output [(N - 1):0] QBAR;
  wire [(N - 1):0] D_temp;
  wire [(N - 1):0] Q_temp;
  reg [(N - 1):0] QBAR_temp;
  supply0  GND;
  supply1  VDD;
  assign D_temp = D|D;
  assign #(d_Q) Q = Q_temp;
  assign #(d_QBAR) QBAR = QBAR_temp;
  always
    @(Q_temp)
      QBAR_temp = ( ~ Q_temp);
  dff_generic #(N) inst1 (CLK,CLR,D_temp,GND,VDD,VDD,GND,Q_temp);
  wire [127:0] D_tcheck = D;
  specify
    specparam
      t_hold_D = 0,
      t_setup_D = 0,
      t_width_CLK = 0,
      t_width_CLR = 0;
    $hold(posedge CLK , D_tcheck , t_hold_D);
    $setup(D_tcheck , posedge CLK , t_setup_D);
    $width(posedge CLK , t_width_CLK);
    $width(negedge CLR , t_width_CLR);
  endspecify
endmodule
