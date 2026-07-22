class reset_at_middle #(DATA_WIDTH=8) extends base_test #(DATA_WIDTH);
    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction

    virtual task run_scenario();
    logic [DATA_WIDTH-1:0] rdata;

    $display("\n[%0t] [TEST_2] === RESET AT THE MIDDLE TEST ===", $time);
    for(int i=0;i<5;i=i+1) begin
        write(8'h00+1);
    end
    //Apply reset
    repeat(3) @(posedge vif.wclk);
    vif.w_rstn=0;
    vif.r_rstn=0;
    repeat(2) @(posedge vif.wclk);
    vif.w_rstn=1;
    vif.r_rstn=1;
    
    $display("\n[%0t] [TEST_2] === END TEST ===", $time);
    endtask
endclass

