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

Addition: For our addition, we decided that we should test at least two cases for both the carryout flag and overflow flag: Two 'Simple addition' which set neither flag. Two 'Carryout' tests which set the only the carryout-- which would happen when adding something to a negative number such that it would add to the most significant bit, but remain negative. Two 'Overflow' cases, which set only the overflow-- a case that resulted in adding two large positive number, such that the output would overflow into negative numbers. Finally, two 'Carryout and Overflow' cases, which set both carryout and overflow, by adding two largely negative numbers such that the result would have a carryout and overflow into positive numbers.
Subtraction: The subtraction tests were chosen to the same guidelines as the addition ones. Because subtraction is equivalent to addition, but with a negative second operand, the tests were basically the same as addition, but with the 'b' value set to a negative number on the same magnitude.
Xor:
Simple Less Than:
And:
Nand:
Nor:
Or:

We found a significant error due to our testing which had to do with the timing of our ALU. The always block (line 40) was only set to be activated when the selector changed, so it did not work when we tested multiple cases of the same function. When we added it to change when selector OR a OR b changed, we found that the always block would be activated before the results had a chance to be computed, and our results were offset one later than they should have been. In order to work around that, we had to implement a delay, of more than our longest possible operation, that would take effect whenever the always block was activated.

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
