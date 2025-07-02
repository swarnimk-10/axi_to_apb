`timescale 1ns / 1ps

module axi_master (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] awaddr,
    output logic        awvalid,
    input  logic        awready,
    output logic [31:0] wdata,
    output logic        wvalid,
    input  logic        wready,
    input  logic        bvalid,
    output logic        bready
);

    typedef enum logic [1:0] {IDLE, ADDR, WRITE, RESP} state_t;
    state_t state;

    int burst_len = 4;   // Number of writes per burst
    int burst_cnt;
    logic [31:0] base_addr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            awaddr     <= 0;
            awvalid    <= 0;
            wdata      <= 0;
            wvalid     <= 0;
            bready     <= 0;
            burst_cnt  <= 0;
            base_addr  <= 32'haabbccdd;
        end else begin
            case (state)
                IDLE: begin
                    awaddr   <= base_addr;
                    awvalid  <= 1;
                    burst_cnt <= 0;
                    if (awready) begin
                        awvalid <= 0;
                        state <= ADDR;
                    end
                end

                ADDR: begin
                    wdata  <= 32'h10000000 + burst_cnt;  // some identifiable data
                    wvalid <= 1;
                    if (wready) begin
                        burst_cnt <= burst_cnt + 1;
                        if (burst_cnt == burst_len - 1) begin
                            wvalid <= 0;
                            state <= WRITE;
                        end
                    end
                end

                WRITE: begin
                    bready <= 1;
                    if (bvalid) begin
                        bready <= 0;
                        state <= RESP;
                    end
                end

                RESP: begin
                    // Prepare for next burst
                    base_addr <= base_addr + (burst_len * 4);  // increment by burst size
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
