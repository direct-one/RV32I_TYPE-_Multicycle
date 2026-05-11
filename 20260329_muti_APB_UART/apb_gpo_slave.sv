//`timescale 1ns / 1ps
//
//module apb_gpo_slave(
//        //General 
//        input                 PCLK,
//        input                 PRESET,
//        //Input 
//        input   logic  [31:0] addr,
//        input   logic  [31:0] Wdata,       
//        input   logic  [31:0] paddr,  //need register
//        input   logic  [31:0] PWDATA, //need register
//        input   logic         penable,
//        input   logic         pwrite,
//        input   logic         psel,  
//        //Ouput 
//        output  logic         ready,
//        //GPO 
//        output  logic         GPO0,
//        output  logic         GPO1,
//        output  logic         GPO2,
//        output  logic         GPO3,
//        output  logic         GPO4,
//        output  logic         GPO5,
//        output  logic         GPO6,
//        output  logic         GPO7  
//    );
//
//
//
//
//
//
//
//
//
///// gpo_O_register U_GPO_SLAV (
/////    .PCLK(),
/////    .PRESET(),
/////    .we(),
/////    .Wdata(),
/////    .GPO()
/////
/////);
//
//
//endmodule
//
//
//module gpo_o_data_reg (
//    input               PCLK,
//    input               PRESET,
//    input               we,
//    input        [15:0]  Wdata,
//    output logic [15:0] gpo_data
//
//);
//
//    logic [15:0] reg_file;
//
//    
//    always_ff @( posedge PCLK, posedge PRESET  ) begin : blockName
//        if(PRESET)begin
//            reg_file <= 16'h0;
//        end else 
//            reg_file <= Wdata;
//    end
//
//
//    assign GPO = reg_file; 
//
//    
//endmodule
//
//
//
//module gpo_ctl_reg (
//    input  logic        control,  //buffer sel???
//    input  logic [15:0] gpo_data,
//    output logic        out_port   //LED의 값을 open,close를 하기 위한 출력값
//);
//
//    //control logic
//    //control IO
//    //0--> off output = X
//    //1--> on  output = o
//
//    always_comb begin 
//        if(control)begin
//            
//        
//    end
//    
//endmodule


















//logic [7:0] GPO[0:7];
//assign pready = (penable & psel) ? 1'b1 : 1'b0;
//    always_ff @(posedge PCLK) begin
//        if (psel & penable & pwrite) begin
//                bmem[paddr[11:2]] <= PWDATA;
//             
//        end 
//    end 
//    assign prdata = bmem[paddr[11:2]];
