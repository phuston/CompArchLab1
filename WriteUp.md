#1 Lab 1 Results
##### Patrick Huston, Nur Shlapobersky, Kai Levy

### Implementation

In the process of implementing our ALU, we made several interesting design choices to improve efficiency, speed, and decrease the area of the unit.

- Our LUTcontrol module takes in a 3-bit selector value and outputs 3 wires: an inverse, carryin, and muxIndex.
- Our AND and NAND gates are defined by the same module. We use the 'inverse' input that is determined by our 'LUTcontrol' to control which of the two operations we perform.
- Our OR and NOR gates operate with the same structure.
- Our addition, subtraction, and part of simple-less-than operations are all implemented by a 'Math' module
	- Inverse is 1 for subtraction and simple-less-than
	- Carryin is 1 for subtraction
- Our simple-less-than takes the output of our math module and then checks whether the most significant bit is zero.
![A block diagram of our ALU's main components](ALUDiagram.png)

### Test Results

- AND, NAND Test Bench Results

- OR, NOR Test Bench Results

- ADD, SUB Test Bench Results

- SLT Test Bench Results


### Timing Analysis

- AND

- NAND

- OR

- NOR

- XOR

- ADD

- SUB

- SLT


### Work Plan Relection

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