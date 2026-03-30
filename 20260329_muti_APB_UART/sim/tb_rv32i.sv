`timescale 1ns / 1ps


module tb_rv32i();

    logic clk,rst;
    logic [ 7:0] GPI; 
    wire  [ 7:0] GPO; 
    wire  [15:0] GPIO;
    
    //logic [15:0] led;
    //logic [15:0] sw;

 rv32i_mcu dut (
        .clk(clk),
        .rst(rst),
        .GPIO(GPIO), //sw, led를 통합한 inout 포트(contraints에서 변경만 하면 되므로 )
        .GPI(GPI),
        .GPO(GPO)
        
    );


    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst = 1;
        GPI = 8'h00;
        //GPO = 16'h0000;
        //GPIO = 16'h0000;

        @(negedge clk);
        @(negedge clk);
        rst =0;
        GPI = 8'haa;


        repeat(2000)
        @(negedge clk);
        $stop;
    end
endmodule