`define AND and #20 //simulate physical gate delay
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #20
`define XNOR xnor #20



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

module testes;
  reg [31:0] a, b;
  wire[31:0] sum;
  wire carryout, overflow;

  doMath math(sum, carryout, overflow, a, b, 1'b1, 1'b0);

  initial begin
      a = 32'd1; b = 32'd3;  #1500
      $display("%b, %b, %b", sum, carryout, overflow);
  end
endmodule