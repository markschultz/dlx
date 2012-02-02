//------------------------------------------------------------
// Copyright 1992, 1993 Cascade Design Automation Corporation.
//------------------------------------------------------------
module dff_generic(CLK,CLR,D,HOLD,PRE,SCANIN,TEST,Q);
  parameter N = 8;
  input  CLK;
  input  CLR;
  input [(N - 1):0] D;
  input  HOLD;
  input  PRE;
  input  SCANIN;
  input  TEST;
  output [(N - 1):0] Q;
  reg [(N - 1):0] Q;
  reg [(N - 1):0] temp;
  always
    @(posedge CLK)
      begin
      if(((CLR == 1'b0) && (PRE == 1'b1)))
        begin
        Q = 128'b0;
        end
      else      if(((PRE == 1'b0) && (CLR == 1'b1)))
        begin
        Q = ( ~ 128'b0);
        end
//      else      if(((CLR !== 1'b1) || (PRE !== 1'b1)))
//        begin
//        Q = 128'bx;
//        end
//      end
//  always
//    @(posedge CLK)
//      begin
      else      if(((PRE == 1'b1) && (CLR == 1'b1)))
        begin
        if((TEST == 1'b0))
          begin
          case(HOLD)
          1'b0 :             begin
            Q = D;
            end
          1'b1 :             begin
            end
          default:
            Q = 128'bx;
          endcase
          end
        else        if((TEST == 1'b1))
          begin
          Q = (Q << 1);
          Q[0] = SCANIN;
          end
        else
          Q = 128'bx;
        end
      end
endmodule
