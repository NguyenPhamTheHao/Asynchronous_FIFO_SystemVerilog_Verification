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
         
         for(int i=0;i<10;i=i+1) begin
            wdata=$urandom;
            write(wdata);
         end
         repeat(2) @(posedge vif.wclk);
         //Simultaneous Write & Read
         for(int i=0;i<8;i=i+1) begin
            wdata=$urandom;
            write_read_concurrent(wdata,rdata);
         end
         repeat(2) @(posedge vif.wclk);
         for(int i=0;i<16;i=i+1) begin
            read(rdata);
         end
         $display("[%0t] [TEST_5] === END TEST ===\n", $time);
    endtask
endclass
