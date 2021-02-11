# EXECUTABLES=divide

divide: divND_tb.v divideND.v
	iverilog -o divide divND_tb.v divideND.v
	
onePtX: divideND.v makeOnePtX_tb.v
	iverilog -o makeOnePtX divideND.v makeOnePtX_tb.v
	vvp makeOnePtX

waves_div: divide
	vvp divide
	gtkwave divide.vcd

test_div: divide divtest.py
	vvp divide > divdump.txt
	python3 divtest.py

clean:
	rm -f *.vcd $(EXECUTABLES)