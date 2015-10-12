`define AND and #50 //simulate physical gate delay
`define OR or #50
`define NOT not #50
`define NOR nor #50
`define NAND nand #50
`define XOR xor #50

module behavioralMultiplexer(out, address0, address1, in0,in1,in2,in3);
	output out;
	input address0, address1;
	input in0, in1, in2, in3;
	wire[3:0] inputs = {in3, in2, in1, in0};
	wire[1:0] address = {address1, address0};
	assign out = inputs[address];
endmodule

module structuralMultiplexer(out, address0,address1, in0,in1,in2,in3);
	output out; //declare vars
	input address0, address1;
	input in0, in1, in2, in3;
	wire nA0, nA1, and0, and1, and2, and3;

	`NOT nadd0 (nA0, address0); //NOTs
	`NOT nadd1 (nA1, address1);

	`AND an0 (and0, nA0,nA1,in0); //selector gates
	`AND an1 (and1, address0,nA1,in1);
	`AND an2 (and2, nA0,address1,in2);
	`AND an3 (and3, address0,address1,in3);

	`OR orOut (out, and0,and1,and2,and3); //final gate
endmodule


module testMultiplexer;
	reg address0, address1;
	reg in0, in1, in2, in3;
	wire out;

	//behavioralMultiplexer multiplex (out, address0, address1, in0, in1, in2, in3);
	structuralMultiplexer multiplex (out, address0, address1, in0, in1, in2, in3);

	 initial begin
	 	$dumpfile("mux.vcd"); //dump info to create wave propagation later
        $dumpvars(0, testMultiplexer);

		$display("in0 in1 in2 in3 | ad0 ad1 | out | Expected "); //test bench
		in0=1;in1=0;in2=0;in3=0;address0=0;address1=0; #1000
		$display("%b   %b   %b   %b   |   %b  %b  |  %b  |  1", in0, in1, in2, in3, address0, address1, out);
		in0=1;in1=0;in2=1;in3=1;address0=1;address1=0; #1000
		$display("%b   %b   %b   %b   |   %b  %b  |  %b  |  0", in0, in1, in2, in3, address0, address1, out);
		in0=0;in1=0;in2=1;in3=0;address0=0;address1=1; #1000
		$display("%b   %b   %b   %b   |   %b  %b  |  %b  |  1", in0, in1, in2, in3, address0, address1, out);
		in0=1;in1=1;in2=1;in3=0;address0=1;address1=1; #1000
		$display("%b   %b   %b   %b   |   %b  %b  |  %b  |  0", in0, in1, in2, in3, address0, address1, out);
	end
endmodule
