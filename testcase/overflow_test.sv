class overflow_test #(DATA_WIDTH=8) extends base_test #(DATA_WIDTH);
    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction

    virtual task run_scenario();
        logic [DATA_WIDTH-1:0] wdata;
        logic [DATA_WIDTH-1:0] rdata;

         $display("\n[%0t] [TEST_5] === OVERFLOW TEST ===", $time);
         
         for(int i=0;i<20;i=i+1) begin
            wdata=$urandom;
            write(wdata);
         end

         repeat(2) @(posedge vif.wclk);

         $display("[%0t] [TEST_5] === END TEST ===\n", $time);
    endtask
endclass
