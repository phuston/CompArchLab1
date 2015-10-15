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

###### AND and NAND
Bitwise AND and NAND have the same delay since they are outputted from the same module:
- First there are 32 NAND gates for a delay of 32*10 = 320
- Then there are 32 XOR gates for a delay of 32*10 = 320, for a total delay of __640__.

###### OR and NOR
Bitwise OR and NOR have the same delay since they are outputted from the same module:
- First there are 32 NOR gates for a delay of 32*10 = 320
- Then there are 32 XOR gates for a delay of 32*10 = 320, for a total delay of __640__.

###### XOR
Bitwise Xor is simply 32 XOR gates for a total delay of 32*10 = __320__.

###### ADD, SUB, SLT
These three gates have the same delay since they are outputted from the same module:
- First we XOR our B input with our sign-extended inverse input, for a delay of 32*10 = 320
- A single-bit adder's maximum delay is through a XOR, AND, and OR gate, for a delay of (10+20+20)*32 = 1600
- The overflow check is one XOR gate for a delay of 10, bringing the total to __1930__

###### Zero Flag
The zero flag check is a 32-bitwise NOR gate, for a total delay of 32*10 = __320__.

Thus the largest delay of our ALU is an addition, subtraction, or simple-less than, which then passes through the zero flag,for a total delay of **2250**.


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