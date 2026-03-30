`timescale 1ns / 1ps


module APB_GPO(
    
        input                PCLK,               
        input                PRESET, 
        input  logic  [31:0] paddr,  
        input  logic  [31:0] PWDATA, 
        input  logic         penable,
        input  logic         pwrite,
        input  logic         psel,        
        output logic  [31:0] prdata,      
        output logic         pready,      
        output logic  [7:0] GPO_OUT

    );
    
localparam [11:0] GPO_CTL_ADDR = 12'h000;
localparam [11:0] GPO_ODATA_ADDR = 12'h004;
logic [ 7:0] GPO_ODATA_REG;
logic [ 7:0] GPO_CTL_REG;

    assign pready = (penable & psel) ? 1'b1 : 1'b0;

    assign prdata = (paddr[11:0] == GPO_CTL_ADDR) ?  {16'h0000,GPO_CTL_REG} :
                    (paddr[11:0] == GPO_ODATA_ADDR) ? {16'h0000,GPO_ODATA_REG}: 32'hxxxx_xxxx;

    always_ff @( posedge PCLK, posedge PRESET ) begin 
        if (PRESET) begin
            GPO_CTL_REG   <= 16'h0000;
            GPO_ODATA_REG <= 16'h0000;
        end else begin 
            if (pready & pwrite ) begin
                case (paddr[11:0])
                GPO_CTL_ADDR :  GPO_CTL_REG   <=  PWDATA[15:0]; 
                GPO_ODATA_ADDR: GPO_ODATA_REG <=  PWDATA[15:0]; 
                endcase
            end        
        end 
    end
    
    //generate for GPO_OUT
    genvar i;
    generate
    for(i=0;i<8;i++)begin

        assign GPO_OUT[i] = (GPO_CTL_REG[i]) ? GPO_ODATA_REG[i] : 1'bz;
    
    end 

    endgenerate
    


endmodule
