`define AND and #20 //simulate physical gate delay
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #20
`define XNOR xnor #20

//TODO:
//define zero flag in top level module
//make mathControl (decoder? mux?)
//make top level ALU Module
module ALU(output[31:0] result,
           output carryout, overflow, zero,
           input[31:0] a, b,
           input[2:0] select);
  
  

endmodule

module not32(output[31:0] nRes,
             input[31:0] a
);
    generate
        genvar i;
        for (i=0; i<32; i=i+1) begin: notblock
            `NOT not32 (nRes[i], a[i]);
        end
    endgenerate
endmodule

module xOr32(output[31:0] xRes,
             input[31:0] a, b
);
    generate
        genvar j;
        for (j=0; j<32; j=j+1) begin: xorblock
            `XOR xor32 (xRes[j], a[j], b[j]);
        end
    endgenerate
endmodule

module and32(output[31:0] aRes,
             input[31:0] a, b
);
    generate
        genvar k;
        for (k=0; k<32; k=k+1) begin: andblock
            `AND and32 (aRes[k], a[k], b[k]);
        end
    endgenerate
endmodule

module nand32(output[31:0] naRes,
             input[31:0] a, b
);
    generate
        genvar l;
        for (l=0; l<32; l=l+1) begin: nandblock
            `NAND nand32 (naRes[l], a[l], b[l]);
        end
    endgenerate
endmodule

module or32(output[31:0] oRes,
             input[31:0] a, b
);
    generate
        genvar m;
        for (m=0; m<32; m=m+1) begin: orblock
            `OR or32 (oRes[m], a[m], b[m]);
        end
    endgenerate
endmodule

module nor32(output[31:0] noRes,
             input[31:0] a, b
);
    generate
        genvar n;
        for (n=0; n<32; n=n+1) begin: norblock
            `NOR nor32 (noRes[n], a[n], b[n]);
        end
    endgenerate
endmodule

module doMath(output[31:0] res,
              output carryout, overflow,
              input[31:0] a, b,
              input sub, carryin
);

    wire[31:0] paddedSub;

    generate
        genvar index;
        for (index=0; index<32; index=index+1) begin: subpad
            assign paddedSub[index] = sub;
        end
    endgenerate
    
    wire[31:0] bmod;
    xOr32 xor32 (bmod, b, paddedSub);

    loopfullAdder32bit fadder32 (res, carryout, overflow, a, bmod, carryin);
endmodule

module loopfullAdder32bit(output[31:0] sum,  // 2's complement sum of a and b
                      output carryout, overflow,
                      input[31:0] a, b,     // First operand in 2's complement format
                      input carryin
);

    wire [32:0] carry;
    assign carry[0] = carryin;

    generate
        genvar o;
        for (o=0; o<32; o=o+1) begin: addblock
            structuralFullAdder fadder (sum[o], carry[o+1], a[o], b[o], carry[o]);
        end
    endgenerate

    assign carryout = carry[32];
    `XOR overflowcalc (overflow, carryout, carry[31]);
endmodule

// module fullAdder32bit(output[31:0] sum,  // 2's complement sum of a and b
//                       output carryout, overflow,
//                       input[31:0] a, b,     // First operand in 2's complement format
//                       input carryin
// );
//     wire carry0;

//     fullAdder16bit adder0 (sum[15:0], carry0, a[15:0], b[15:0], carryin);
//     fullAdder16bit adder1 (sum[31:16], carryout, a[31:16], b[31:16], carry0);

//     wire AxnB, BxS; //declare wires for overflow checking
//     `XNOR Xnor (AxnB, a[31], b[31]); //Overflow: A == B and S !== B
//     `XOR Xor (BxS, b[31], sum[31]);
//     `AND And (overflow, AxnB, BxS);
// endmodule

// module fullAdder16bit(output[15:0] sum,  // 2's complement sum of a and b
//                       output carryout,  // Carry out of the summation of a and b
//                       input[15:0] a,     // First operand in 2's complement format
//                       input[15:0] b,      // Second operand in 2's complement format);
//                       input carryin
// );
//     wire carry0, carry1, carry2; //declare carryout bits

//     FullAdder4bit adder0 (sum[3:0], carry0, a[3:0], b[3:0], carryin);
//     FullAdder4bit adder1 (sum[7:4], carry1, a[7:4], b[7:4], carry0);
//     FullAdder4bit adder2 (sum[11:8], carry2, a[11:8], b[11:8], carry1);
//     FullAdder4bit adder3 (sum[15:12], carryout, a[15:12], b[15:12], carry2);
// endmodule

// module FullAdder4bit(output[3:0] sum,  // 2's complement sum of a and b
//                      output carryout,  // Carry out of the summation of a and b
//                      input[3:0] a,     // First operand in 2's complement format
//                      input[3:0] b,      // Second operand in 2's complement format
//                      input carryin
// );

//     wire carry0, carry1, carry2; //declare carryout bits

//     structuralFullAdder adder0 (sum[0], carry0, a[0], b[0], carryin); //declare 4 adders we use
//     structuralFullAdder adder1 (sum[1], carry1, a[1], b[1], carry0);
//     structuralFullAdder adder2 (sum[2], carry2, a[2], b[2], carry1);
//     structuralFullAdder adder3 (sum[3], carryout, a[3], b[3], carry2);
// endmodule

module structuralFullAdder(out, carryout, a, b, carryin);
    output out, carryout; //declare vars
    input a, b, carryin;
    wire AxorB, fullAnd, AandB;

    `XOR AxB (AxorB, a, b); //first level gates
    `AND ABand (AandB, a, b);
    `AND Alland (fullAnd, carryin, AxorB);

    `XOR Sout (out, AxorB, carryin); //final gates
    `XOR Cout (carryout, AandB, fullAnd);
endmodule

module testALU;
    reg [31:0] a, b;
    wire[31:0] sum;
    wire carryout, overflow;

    // fullAdder32bit fadder32 (sum, carryout, overflow, a, b);
    doMath mather (sum, carryout, overflow, a, b, 1'b0, 1'b0);

    initial begin
        $dumpfile("testALU.vcd"); //dump info to create wave propagation later
        $dumpvars(0, mather);

        a = 32'b00000000000000000000000000000001; b = 32'd1; #1500
        $display("%b, %b, %b", sum, carryout, overflow);

    end
endmodule