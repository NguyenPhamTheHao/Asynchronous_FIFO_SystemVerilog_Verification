class underflow_test #(DATA_WIDTH=8) extends base_test #(DATA_WIDTH);
    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction

    virtual task run_scenario();
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

    $display("\n[%0t] [TEST_6] === UNDEFLOW TEST ===", $time);
    wdata=$urandom;
    write(wdata);

    repeat (2) @(posedge vif.rclk);
    for(int i=0;i<5;i=i+1) begin
        read(rdata);
    end

    $display("[%0t] [TEST_6] === END TEST ===\n", $time);
    endtask
endclass