`timescale 1ns / 1ps


module tb_muticycle();

logic clk, rst;

rv32i_top dut(
        .clk(clk),
        .rst(rst),
        .test_alu_out(test_alu_out),
        .test_mem_wdata(test_mem_wdata)
    );


    always #5 clk = ~clk;


    initial begin
        clk=0;
        rst=1;
        #25;
        rst=10;
        #500;
        $finish;
    end
endmodule
