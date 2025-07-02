`timescale 1ns / 1ps

module tb_axi_apb;

    logic clk = 0;
    logic rst_n;

    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;

    logic [31:0] wdata;
    logic        wvalid;
    logic        wready;

    logic        bvalid;
    logic        bready;

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;

    axi_to_apb_bridge dut (
        .clk(clk), .rst_n(rst_n),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wvalid(wvalid), .wready(wready),
        .bvalid(bvalid), .bready(bready),
        .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE),
        .PADDR(PADDR), .PWDATA(PWDATA)
    );

    always #5 clk = ~clk;

    // -------------------
    // Assertions
    // -------------------
    logic [31:0] last_paddr;
    logic burst_active = 0;

    always @(posedge clk) begin
        if (!rst_n) begin
            last_paddr <= 'x;
            burst_active <= 0;
        end else begin
            // 1. AWREADY only when AWVALID
            assert (!(awready && !awvalid))
                else $fatal("AWREADY high without AWVALID!");

            // 2. WREADY only when WVALID
            assert (!(wready && !wvalid))
                else $fatal("WREADY high without WVALID!");

            // 3. PENABLE high must mean PSEL and PWRITE are high
            assert (!(PENABLE && (!PSEL || !PWRITE)))
                else $fatal("PENABLE high without PSEL or PWRITE!");

            // 4. PADDR increments correctly during a burst
            if (PSEL && !PENABLE) begin
                if (!burst_active) begin
                    burst_active <= 1;
                    last_paddr <= PADDR;
                end else begin
                    assert (PADDR == last_paddr + 4)
                        else $fatal("PADDR not incremented correctly! Now: %h, Last: %h", PADDR, last_paddr);
                    last_paddr <= PADDR;
                end
                $display("[%0t] APB write: PADDR = %h, PWDATA = %h", $time, PADDR, PWDATA);
            end

            if (bvalid && bready) begin
                $display("[%0t] Write response received", $time);
                burst_active <= 0;
            end
        end
    end

    // -------------------
    // Stimulus
    // -------------------
    initial begin
        rst_n = 0; bready = 0;
        awvalid = 0; wvalid = 0;
        awaddr = 32'haabbccdd;
        wdata = 0;

        #20 rst_n = 1;

        $display("[%0t] Reset deasserted", $time);
        $display("[%0t] Starting Burst 1", $time);

        // ---------- Burst 1 ----------
        awvalid = 1;
        @(posedge clk); if (awready) begin
            awvalid = 0;
            $display("[%0t] AWVALID accepted: AWADDR = %h", $time, awaddr);
        end

        repeat (4) begin
            @(posedge clk);
            wvalid = 1;
            wdata += 32'h12345678;
            wait (wready);
            $display("[%0t] WVALID accepted: WDATA = %h", $time, wdata);
            @(posedge clk);
            wvalid = 0;
        end

        wait (bvalid); bready = 1;
        @(posedge clk); bready = 0;

        // ---------- Burst 2 ----------
        @(posedge clk);
        awaddr = 32'heeffaabb;
        awvalid = 1;
        $display("[%0t] Starting Burst 2", $time);
        @(posedge clk); if (awready) begin
            awvalid = 0;
            $display("[%0t] AWVALID accepted: AWADDR = %h", $time, awaddr);
        end

        repeat (4) begin
            @(posedge clk);
            wvalid = 1;
            wdata += 32'h11111111;
            wait (wready);
            $display("[%0t] WVALID accepted: WDATA = %h", $time, wdata);
            @(posedge clk);
            wvalid = 0;
        end

        wait (bvalid); bready = 1;
        @(posedge clk); bready = 0;

        $display("[%0t] Test completed successfully.", $time);
        $finish;
    end

endmodule
