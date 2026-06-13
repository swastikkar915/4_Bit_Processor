`timescale 1ns / 1ps

module tb_processor();

    reg clk;
    reg rst;
    wire [3:0] out_R0;
    wire [3:0] out_R1;
    wire [3:0] pc_out;

    processor uut (
        .clk(clk), 
        .rst(rst), 
        .out_R0(out_R0), 
        .out_R1(out_R1),
        .pc_out(pc_out)
    );

    // Clock Generation
    always #10 clk = ~clk;

    initial begin
        clk = 0; rst = 1;
        #20;
        rst = 0;
        
        // Let it run for 180ns to capture the new RAM sequence
        #180; 
        
        $finish;
    end
endmodule