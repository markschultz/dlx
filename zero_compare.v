// File:        zero_compare
// Written By:  Michael J. Kelley
// Written On:  9/15/95
// Updated By:  Michael J. Kelley
// Updated On:  9/18/95
//
// Description:
//
// This module simply compares a 32-bit number against zero.  It will activate
// the appropriate output lines depending on the result.  The output values are
// the following:
// 	A < 0
// 	A <= 0
//	A > 0
//	A >= 0
// By testing these lines, one will be able to detect what A is with respect to
// zero.  

module zero_compare(
A, 				// 32-bit number to compare to zero
A_lessthan_zero, 		// output is one when A < 0
A_lessthan_equal_zero,		// output is one when A <= 0
A_greaterthan_equal_zero, 	// output is one when A >= 0
A_greaterthan_zero,		// output is one when A > 0
A_equal_zero,			// output is one when A == 0
A_not_equal_zero		// output is one when A != 0
);

// declaring parameters

parameter DPFLAG = 0;
parameter GROUP = "AUTO";

input [31:0] A;			
output A_lessthan_zero;			wire A_lessthan_zero;
output A_lessthan_equal_zero;		wire A_lessthan_equal_zero;
output A_greaterthan_equal_zero;	wire A_greaterthan_equal_zero;
output A_greaterthan_zero;		wire A_greaterthan_zero;
output A_equal_zero;			wire A_equal_zero;
output A_not_equal_zero;		wire A_not_equal_zero;

// A is less than zero if the most significant bit is 1.

assign A_lessthan_zero = A[31];

buff	#(1,DPFLAG,GROUP)
	buffer(.IN0(A[31]), .Y(A_lessthan_zero));

// A is less than or equal to zero if all the bits are zero or if the most
// significant bit is one.

assign A_lessthan_equal_zero = (!(A[0] | A[1] | A[2] | A[3] | A[4] | A[5] | A[6] | 
A[7] | A[8] | A[9] | A[10] | A[11] | A[12] | A[13] | A[14] | A[15] | A[16] |
A[17] | A[18] | A[19] | A[20] | A[21] | A[22] | A[23] | A[24] | A[25] | A[26] |
A[27] | A[28] | A[29] | A[30] | A[31]) | (A[31]));

// A is greater than or equal to zero whenever the most significant bit of A is
// zero.

assign A_greaterthan_equal_zero = !(A[31]);

// A is greater than zero if at least one of the bits is one (except for the most
// significant bit).

assign A_greaterthan_zero = ((A[0] | A[1] | A[2] | A[3] | A[4] | A[5] | A[6] | 
A[7] | A[8] | A[9] | A[10] | A[11] | A[12] | A[13] | A[14] | A[15] | A[16] |
A[17] | A[18] | A[19] | A[20] | A[21] | A[22] | A[23] | A[24] | A[25] | A[26] |
A[27] | A[28] | A[29] | A[30] | A[31]) & !(A[31]));

assign A_equal_zero = A_greaterthan_equal_zero && A_lessthan_equal_zero;

assign A_not_equal_zero = !A_equal_zero;

endmodule
