//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module adder_generic(a,b,cin,cout,ovf,y);
  parameter n = 32;
  input [(n - 1):0] a;
  input [(n - 1):0] b;
  input  cin;
  output  cout;
  output  ovf;
  output [(n - 1):0] y;
  reg  cout;
  reg  ovf;
  reg [(n - 1):0] y;
  reg [n:0] temp;
  always
    @(a or b or cin)
      begin
      temp = ((cin + {1'b0,a}) + b);
      cout = temp[n];
      y = temp[(n - 1):0];
      ovf = (((a[(n - 1)] & b[(n - 1)]) & ( ~ temp[(n - 1)])) | ((( ~ a[(n - 1)]) & ( ~ b[(n - 1)])) & temp[(n - 1)]));
      end
endmodule
