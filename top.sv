`timescale 1ns / 1ps

module top (
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] awaddr, wdata, PADDR, PWDATA,
    output logic awvalid, awready, wvalid, wready,
    output logic bvalid, bready,
    output logic PSEL, PENABLE, PWRITE,
    output logic [31:0] PRDATA
);

    logic [31:0] awaddr_internal, wdata_internal, PADDR_internal, PWDATA_internal;
    logic awvalid_internal, awready_internal, wvalid_internal, wready_internal;
    logic bvalid_internal, bready_internal;
    logic PSEL_internal, PENABLE_internal, PWRITE_internal;
    logic [31:0] PRDATA_internal;

    // AXI Master
    axi_master axi_master_inst (
        .clk(clk),
        .rst_n(rst_n),
        .awaddr(awaddr_internal),
        .awvalid(awvalid_internal),
        .awready(awready_internal),
        .wdata(wdata_internal),
        .wvalid(wvalid_internal),
        .wready(wready_internal),
        .bvalid(bvalid_internal),
        .bready(bready_internal)
    );

    // AXI to APB Bridge
    axi_to_apb_bridge bridge_inst (
        .clk(clk),
        .rst_n(rst_n),
        .awaddr(awaddr_internal),
        .awvalid(awvalid_internal),
        .awready(awready_internal),
        .wdata(wdata_internal),
        .wvalid(wvalid_internal),
        .wready(wready_internal),
        .bvalid(bvalid_internal),
        .bready(bready_internal),
        .PSEL(PSEL_internal),
        .PENABLE(PENABLE_internal),
        .PWRITE(PWRITE_internal),
        .PADDR(PADDR_internal),
        .PWDATA(PWDATA_internal)
    );

    // APB Slave
    apb_slave apb_slave_inst (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL_internal),
        .PENABLE(PENABLE_internal),
        .PWRITE(PWRITE_internal),
        .PADDR(PADDR_internal),
        .PWDATA(PWDATA_internal),
        .PRDATA(PRDATA_internal)
    );

    // Output connections for observation
    assign awaddr  = awaddr_internal;
    assign wdata   = wdata_internal;
    assign PADDR   = PADDR_internal;
    assign PWDATA  = PWDATA_internal;
    assign awvalid = awvalid_internal;
    assign awready = awready_internal;
    assign wvalid  = wvalid_internal;
    assign wready  = wready_internal;
    assign bvalid  = bvalid_internal;
    assign bready  = bready_internal;
    assign PSEL    = PSEL_internal;
    assign PENABLE = PENABLE_internal;
    assign PWRITE  = PWRITE_internal;
    assign PRDATA  = PRDATA_internal;

endmodule

