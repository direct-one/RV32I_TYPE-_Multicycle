`timescale 1ns / 1ps


module rv32i_top(
        input         clk,
        input         rst
    );


    //logic dwe;
    logic [2:0] o_funct3;
    logic [31:0] instr_addr, instr_data, bus_addr, bus_wdata, bus_rdata;
    logic [3:0] alu_control;
    logic bus_w_req, bus_r_req,bus_ready;
    

    //assign test_alu_out = daddr;
    //assign test_mem_wdata = dwdata;

    instruction_mem U_INSTRUCTION_MEM(
    .*
    );

    rv32i_cpu U_RV32I_CPU(
    .*,
    .o_funct3(o_funct3)
    );

 apb_master U_ABP_MASTER(
         
        .PCLK(clk),
        .PRESET(rst),
        .addr(bus_addr),
        .Wdata(bus_wdata),
        .w_req(bus_w_req), // from cpu, write request, signal cpu : dwe
        .r_req(bus_r_req), // from cpu, read request, signal cpu : dre 
        .rdata(bus_rdata),   // RAM  
        .ready(bus_ready)


    );




//    data_mem U_DATA_MEM(
//        .*, 
//        .i_funct3(o_funct3)
//    );


    






//    PC U_PC (
//    .clk(clk),
//    .rst(rst),
//    .outpc(outpc),
//    .instr_addr(instr_addr)
//);    
//
//    add_alu U_ADD_ALU(
//        .pc(instr_addr),
//        .outpc(outpc)
//    );


    

endmodule

//module PC (
//    input clk,
//    input rst,
//    input  logic [31:0] outpc,
//    output logic [31:0] instr_addr
//);
//
//    always_ff @( posedge clk, posedge rst ) begin 
//        if (rst) begin
//            instr_addr <= 32'd0;
//
//        end else begin
//            instr_addr <= outpc;
//        end       
//    end
//
//endmodule
//
//    module add_alu(
//        input [31:0] pc,
//        output [31:0] outpc
//    );
//
//    assign outpc = pc + 4;     
//
//
//        
//    endmodule