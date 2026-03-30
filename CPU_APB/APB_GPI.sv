`timescale 1ns / 1ps



module APB_GPI(

    input                PCLK,               
    input                PRESET, 
    input  logic  [31:0] paddr,  
    input  logic  [31:0] PWDATA, // No work  
    input  logic         penable,
    input  logic         pwrite,
    input  logic         psel,        
    input logic   [15:0] GPI_IN, // work like PWDATA
    output logic         pready,     
    output logic  [31:0] prdata      

    );


//GPO에서 가져온 Logic(GPO-> GPI)
localparam [11:0] GPI_CTL_ADDR = 12'h000;
localparam [11:0] GPI_IDATA_ADDR = 12'h004;
logic [15:0] GPI_IDATA_REG, GPI_CTL_REG;
//logic [15:0] GPI_OUT;

assign pready = (penable & psel) ? 1'b1 : 1'b0;


assign prdata = (paddr[11:0] == GPI_CTL_ADDR) ?  {16'h0000,GPI_CTL_REG} :
                (paddr[11:0] == GPI_IDATA_ADDR) ? {16'h0000,GPI_IDATA_REG}: 32'hxxxx_xxxx;


always_ff @( posedge PCLK, posedge PRESET ) begin 
        if (PRESET) begin
            GPI_CTL_REG   <= 16'h0000;
            //GPI_IDATA_REG <= 16'h0000;
        end else begin 
            if (pready & pwrite ) begin
                case (paddr[11:0])
                GPI_CTL_ADDR :  GPI_CTL_REG   <=  PWDATA[15:0]; 
                //GPI_IDATA_ADDR: GPI_IDATA_REG <=  PWDATA[15:0]; 
                endcase
            end        
        end 
    end
    

     //generate for GPO_OUT  ///control;
    genvar i;
    generate
    for(i=0;i<16;i++)begin

        assign GPI_IDATA_REG[i] = (GPI_CTL_REG[i]) ? GPI_IN[i] : 1'bz;
    
    end 

    endgenerate


endmodule
