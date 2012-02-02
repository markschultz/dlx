#TOOL INPUT
SRC = files.txt
TESTBENCH = clkgen.v
#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
#TOOL OUTPUT
COUTPUT = compiler.out
TBOUTPUT = waves.lxt
CFLAGS = -v
SFLAGS = -v

check : $(SRC)
	$(COMPILER) $(CFLAGS) -o$(COUTPUT) -c$(SRC)

simulate : check
	$(SIMULATOR) $(SFLAGS) $(COUTPUT)

display : simulate
	$(VIEWER) $(TBOUTPUT) &

.PHONY : clean
clean :
	-rm -f $(COUTPUT) $(TBOUTPUT)
