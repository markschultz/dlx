//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module alu_generic(a,b,cin,m,s,cout,out,overflow);
  parameter n = 32;
  input [(n - 1):0] a;
  input [(n - 1):0] b;
  input  cin;
  input  m;
  input [3:0] s;
  output  cout;
  output [(n - 1):0] out;
  output  overflow;
  reg  cout;
  reg [(n - 1):0] out;
  reg  overflow;
  reg [(n - 1):0] logic;
  reg [(n - 1):0] pr;
  reg [(n - 1):0] pr1;
  reg [n:0] arith;
  reg [n:0] aa;
  reg  cinbar;
  always
    @(a or b or cin or s or m)
      begin
      overflow = 1'b0;
      cinbar = ( ~ cin);
      if((s == 4'd0))
        begin
        logic = ( ~ a);
        aa = ( ~ 128'b0);
        aa[n] = 1'b0;
        arith = ({1'b0,a} + aa);
        if((cin == 1'b1))
          arith = (arith + 1'b1);
        if(((1'b0 == arith[(n - 1)]) && (a[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else      if((s == 4'd1))
        begin
        logic = ( ~ (a & b));
        pr = (a & b);
        aa = ( ~ 128'b0);
        aa[n] = 1'b0;
        arith = ({1'b0,pr} + aa);
        if((cin == 1'b1))
          arith = (arith + 1'b1);
        if(((arith[(n - 1)] == 1'b0) && (pr[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else      if((s == 4'd2))
        begin
        logic = (( ~ a) | b);
        pr = ( ~ logic);
        aa = ( ~ 128'b0);
        aa[n] = 1'b0;
        arith = ({1'b0,pr} + aa);
        if((cin == 1'b1))
          arith = (arith + 1'b1);
        if(((arith[(n - 1)] == 1'b0) && (pr[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else      if((s == 4'd3))
        begin
        logic = ( ~ 128'b0);
        arith = ({1'b0,logic} + cin);
        end
      else      if((s == 4'd4))
        begin
        logic = ( ~ (a | b));
        pr = (a | ( ~ b));
        arith = (a + ({1'b0,pr} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd5))
        begin
        logic = ( ~ b);
        pr = (a & b);
        pr1 = (a | ( ~ b));
        arith = (pr + ({1'b0,pr1} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ pr1[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ pr1[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd6))
        begin
        logic = ( ~ (a ^ b));
        pr = (( ~ (b + cinbar)) + 1'b1);
        arith = ({1'b0,a} + pr);
        //if((((a[(n - 1)] ^ b[(n - 1)]) == 1'b1) && (a[(n - 1)] !== arith[(n - 1)])))
        if((((a[(n - 1)] ^ b[(n - 1)]) == 1'b1) && (a[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd7))
        begin
        logic = (a | ( ~ b));
        arith = ({1'b0,logic} + cin);
        if(((logic[(n - 1)] == 1'b0) && (arith[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else      if((s == 4'd8))
        begin
        logic = (( ~ a) & b);
        pr = (a | b);
        arith = (a + ({1'b0,pr} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd9))
        begin
        logic = (a ^ b);
        arith = (a + ({1'b0,b} + cin));
        //if(((1'b0 == (a[(n - 1)] ^ b[(n - 1)])) && (a[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (a[(n - 1)] ^ b[(n - 1)])) && (a[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd10))
        begin
        logic = b;
        pr = (a & ( ~ b));
        pr1 = (a | b);
        arith = (pr + ({1'b0,pr1} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ b[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ b[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd11))
        begin
        logic = (a | b);
        arith = ({1'b0,logic} + cin);
        if(((logic[(n - 1)] == 1'b0) && (arith[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else      if((s == 4'd12))
        begin
        logic = 128'b0;
        arith = (a + ({1'b0,a} + cin));
        //if((a[(n - 1)] !== arith[(n - 1)]))
        if((a[(n - 1)] != arith[(n - 1)]))
          overflow = 1'b1;
        end
      else      if((s == 4'd13))
        begin
        logic = (a & ( ~ b));
        pr = (a & b);
        arith = (pr + ({1'b0,a} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd14))
        begin
        logic = (a & b);
        pr = (a & ( ~ b));
        arith = (pr + ({1'b0,a} + cin));
        //if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] !== arith[(n - 1)])))
        if(((1'b0 == (pr[(n - 1)] ^ a[(n - 1)])) && (pr[(n - 1)] != arith[(n - 1)])))
          overflow = 1'b1;
        end
      else      if((s == 4'd15))
        begin
        logic = a;
        arith = ({1'b0,a} + cin);
        if(((logic[(n - 1)] == 1'b0) && (arith[(n - 1)] == 1'b1)))
          overflow = 1'b1;
        end
      else
        begin
        logic = 128'bX;
        arith = 128'bX;
        end
      if((m == 1'b0))
        begin
        cout = 1'b0;
        out = logic;
        overflow = 1'b0;
        end
      else      if((m == 1'b1))
        begin
        cout = arith[n];
        out = arith[(n - 1):0];
        //if((arith[(n - 1)] === 1'bx))
        if((arith[(n - 1)] == 1'bx))
          begin
          overflow = 1'bx;
          cout = 1'bx;
          end
        //else        if(( ! ((( & out) === 1'b0) || (( | out) === 1'b1))))
        else        if(( ! ((( & out) == 1'b0) || (( | out) == 1'b1))))
          begin
          overflow = 1'bx;
          cout = 1'bx;
          end
        end
      else
        begin
        cout = 1'bX;
        out = 128'bX;
        end
      end
endmodule
