class test_multiple_write_read_test #(parameter DATA_WIDTH = 8) extends base_test #(DATA_WIDTH);

    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction

    
    virtual task run_scenario();
        logic [DATA_WIDTH-1:0] wdata;
        logic [DATA_WIDTH-1:0] rdata;

        $display("\n[%0t] [TEST_4] === START MULTIPLE WRITE FOLLOWED BY READ TEST ===", $time);

       
        for (int i = 0; i < 4; i++) begin
            write(wdata);
            wdata=~wdata;
            
        end

        
        repeat (2) @(posedge vif.rclk);

        for (int i = 0; i < 4; i++) begin
            read(rdata);
           
        end

        $display("[%0t] [TEST_4] === END TEST ===\n", $time);
    endtask

endclass