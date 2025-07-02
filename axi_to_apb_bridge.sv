`timescale 1ns / 1ps

module axi_to_apb_bridge (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] awaddr,
    input  logic        awvalid,
    output logic        awready,
    input  logic [31:0] wdata,
    input  logic        wvalid,
    output logic        wready,
    output logic        bvalid,
    input  logic        bready,
    output logic        PSEL,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA
);

    typedef enum logic [2:0] {IDLE, SETUP, ACCESS, WAIT_DONE} state_t;
    state_t state;

    logic [31:0] addr_reg;
    int burst_cnt;
    int burst_len = 4;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            awready   <= 0;
            wready    <= 0;
            bvalid    <= 0;
            PSEL      <= 0;
            PENABLE   <= 0;
            PWRITE    <= 0;
            PADDR     <= 0;
            PWDATA    <= 0;
            addr_reg  <= 0;
            burst_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (awvalid) begin
                        awready <= 1;
                    end
                
                    if (awvalid && awready) begin
                        addr_reg  <= awaddr;
                        burst_cnt <= 0;
                        awready   <= 0;
                        state     <= SETUP;
                    end
                end

                SETUP: begin
                    if (wvalid) begin
                        wready  <= 1;
                        PADDR   <= addr_reg;
                        PWDATA  <= wdata;
                        PWRITE  <= 1;
                        PSEL    <= 1;
                        state   <= ACCESS;
                    end
                end

                ACCESS: begin
                    wready  <= 0;
                    PENABLE <= 1;
                    state   <= WAIT_DONE;
                end

                WAIT_DONE: begin
                    PENABLE <= 0;
                    PSEL    <= 0;
                    PWRITE  <= 0;

                    burst_cnt <= burst_cnt + 1;
                    addr_reg  <= addr_reg + 4;

                    if (burst_cnt == burst_len - 1) begin
                        bvalid <= 1;
                        state  <= IDLE;
                    end else begin
                        state <= SETUP;
                    end
                end
            endcase

            if (bvalid && bready) begin
                bvalid <= 0;
                awready <= 1;
                burst_cnt  <= 0;
            end
        end
    end
endmodule
