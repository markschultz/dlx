###############################################################################
#
# ICARUS VERILOG & GTKWAVE MAKEFILE
# MADE BY WILLIAM GIBB FOR HACDC
# williamgibb@gmail.com
# 
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make simulate" - compiles your design+TB & simulates your design
#	"make display" - compiles, simulates and displays waveforms
# 
###############################################################################
#
# CHANGE THESE THREE LINES FOR YOUR DESIGN
#
#TOOL INPUT
SRC = sources.txt
TOP = top
TESTBENCH = alu_tb.v
TBOUTPUT = waves.lxt	#THIS NEEDS TO MATCH THE OUTPUT FILE
			#FROM YOUR TESTBENCH
###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v
#SOUTPUT = -lxt		#SIMULATOR OUTPUT TYPE
SOUTPUT = -lxt2
#TOOL OUTPUT
COUTPUT = compiler.out			#COMPILER OUTPUT
###############################################################################
#MAKE DIRECTIVES
check : $(SRC)
	$(COMPILER) -v -c$(SRC) -s$(TOP) -o$(COUTPUT)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

display: simulate
	$(VIEWER) $(TBOUTPUT) &

clean :
	rm $(COUTPUT) $(TBOUTPUT)
