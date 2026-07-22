module testbench;
    import Asyn_Pkg::*;
    import test_pkg::*;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    logic wclk = 0;
    logic rclk = 0;

    interf #(DATA_WIDTH) u_interf(
        .wclk (wclk),
        .rclk (rclk)
    );

    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;

    AsynFF #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_AsynFF (
        .wclk    (u_interf.wclk),
        .w_rstn  (u_interf.w_rstn),
        .w_en    (u_interf.w_en),
        .wr_data (u_interf.wr_data),
        .rclk    (u_interf.rclk),
        .r_rstn  (u_interf.r_rstn),
        .r_en    (u_interf.r_en),
        .rd_data (u_interf.rd_data),
        .full    (u_interf.full),
        .empty   (u_interf.empty)
    );

    initial begin
        u_interf.w_rstn = 0;
        u_interf.r_rstn = 0;
        #8;
        u_interf.w_rstn = 1;
        u_interf.r_rstn = 1;
    end

    initial begin
        #500us;
        $display("\n[%0t] [TESTBENCH] ERROR: Time out! Simulation hung or ran too long.", $time);
        $finish;
    end

    base_test #(DATA_WIDTH)                       base;

    reset_test #(DATA_WIDTH)                      rst_obj          = new(u_interf);
    single_wr_rd_test #(DATA_WIDTH)               single_obj       = new(u_interf);
    test_multiple_write_read_test #(DATA_WIDTH)   multi_obj        = new(u_interf);
    overflow_test #(DATA_WIDTH)                   overflow_obj     = new(u_interf);
    underflow_test #(DATA_WIDTH)                  underflow_obj    = new(u_interf);
    wrap_around_test #(DATA_WIDTH)                wrap_around_obj  = new(u_interf);
    reset_at_middle #(DATA_WIDTH)                 rst_middle_obj   = new(u_interf);
    simultaneous_wr_rd_test #(DATA_WIDTH)         simultaneous_obj = new(u_interf);

    initial begin
        if ($test$plusargs("reset_test")) begin
            base = rst_obj;
        end else if ($test$plusargs("single_wr_rd_test")) begin
            base = single_obj;
        end else if ($test$plusargs("multiple_wr_rd_test")) begin
            base = multi_obj;
        end else if ($test$plusargs("overflow_test")) begin
            base = overflow_obj;
        end else if ($test$plusargs("underflow_test")) begin
            base = underflow_obj;
        end else if ($test$plusargs("wrap_around_test")) begin
            base = wrap_around_obj;
        end else if ($test$plusargs("reset_at_middle_test")) begin
            base = rst_middle_obj;
        end else if ($test$plusargs("simultaneous_wr_rd_test")) begin
            base = simultaneous_obj;
        end else begin
            $display("\n[TESTBENCH] WARNING: No +TESTNAME specified! Defaulting to single_wr_rd_test.\n");
            base = single_obj;
        end

        base.vif = u_interf;
        base.run_test();
    end

endmodule