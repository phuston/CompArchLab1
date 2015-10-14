## Lab 1 Results
##### Patrick Huston, Nur Shlapobersky, Kai Levy

1. Implementation

	In the process of implementing our ALU, we made several interesting design choices to improve efficiency, speed, and decrease the area of the unit.

	- Our LUTcontrol module takes in a 3-bit selector value and outputs 3 wires: an inverse, carryin, and muxIndex (which controls our large multiplexor's output).
		> The inverse output controls the 'Math' module's switching between addition, subtraction, and slt, as well as our bitwise nand and nor gates to and and or gates
	- Constructing a 'Math' module to implement both addition and subtraction, as well part of the 'Simple-Less-Than' module
	- Handling and

	![A block diagram of our ALU's main components](ALUDiagram.png)
	- Block diagrams of all ALU components.

2. Test Results

	- AND, NAND Test Bench Results

	- OR, NOR Test Bench Results

	- ADD, SUB Test Bench Results

	- SLT Test Bench Results


3. Timing Analysis

	- AND

	- NAND

	- OR

	- NOR

	- XOR

	- ADD

	- SUB

	- SLT


4. Work Plan Relection

	- Include our work_plan.txt probably, and how that turned out, what took longer than expected, what took shorter than expected



TODO:

	- Write test benches
		> AND, NAND
		> OR, NOR, XOR
		> ADD, SUB
		> SLT
	- Analyze propagation delays
		> AND, NAND
		> OR, NOR, XOR
		> SLT
	- Create block diagram of ALU