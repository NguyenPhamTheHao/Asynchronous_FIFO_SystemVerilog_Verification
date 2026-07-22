class reset_test #(parameter DATA_WIDTH=8)  extends base_test#(DATA_WIDTH);
    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction
    virtual task run_scenario();
    $display("\n[%0t] [TEST_1] === RESET TEST ===", $time);
    //Initial state for stability
        vif.w_en    <= 1'b0;
        vif.r_en    <= 1'b0;
        vif.wr_data <= '0;
        vif.w_rstn  <= 1'b0;
        vif.r_rstn  <= 1'b0;

        repeat (5) @(posedge vif.wclk);

        vif.w_rstn  <= 1'b1;
        vif.r_rstn  <= 1'b1;

        repeat (5) @(posedge vif.wclk);

        $display("[%0t] [RESET_TEST] Reset completed successfully.", $time);
    endtask

endclass
