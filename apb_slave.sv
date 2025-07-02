`timescale 1ns / 1ps

module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA
);

    logic [31:0] mem [0:15];

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 0;
        end else if (PSEL && PENABLE && PWRITE) begin
            mem[PADDR[5:2]] <= PWDATA;
        end else if (PSEL && PENABLE && !PWRITE) begin
            PRDATA <= mem[PADDR[5:2]];
        end
    end

endmodule
