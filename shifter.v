

module shifter(IN0,S,S2,Y);

  input [31:0] IN0;
  input [4:0] S;
  input [1:0] S2;
  output [31:0] Y;

  reg [31:0] Y;
  reg [31:0] mask;

  always @(IN0 or S or S2) begin

    mask = 32'hFFFFFFFF ;
    if((IN0[31] == 1) && (S2 == 2'b11)) mask = (mask >> S) ;

    case(S2)
           2'b01: Y = (IN0 << S);              // SLL, SLLI
           2'b10: Y = (IN0 >> S);              // SRL, SRLI
           2'b11: Y = ((IN0 >> S) | (~mask));  // SRA, SRAI
         default: Y = IN0 ;                    // don't care
    endcase
  end
endmodule
