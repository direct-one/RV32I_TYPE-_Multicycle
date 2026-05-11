`timescale 1ns / 1ps


module BRAM(
      //BUS Global signal 
        input                 PCLK,               
        //APB interface signal 
        input  logic  [31:0] paddr,  
        input  logic  [31:0] PWDATA, 
        input  logic         penable,
        input  logic         pwrite,
        input  logic         psel,       // RAM 
        
        output   logic  [31:0] prdata,      // RAM 
        output   logic         pready      // RAM 
    );



        logic [31:0] bmem[0:1024];  // 1024 * 4byte : 4K 

        assign pready = (penable & psel) ? 1'b1 : 1'b0;

        always_ff @(posedge PCLK) begin
            if (psel & penable & pwrite) begin
                    bmem[paddr[11:2]] <= PWDATA;
                 
            end 
        end 

        assign prdata = bmem[paddr[11:2]];


endmodule
