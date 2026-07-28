class simultaneous_wr_rd_test #(DATA_WIDTH=8) extends base_test #(DATA_WIDTH);
    function new(virtual interf #(DATA_WIDTH) vif_i);
        super.new(vif_i);
    endfunction

    virtual task run_scenario();
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic [DATA_WIDTH-1:0] patterns[8] = '{
        8'hFF, 8'h00, 
        8'hAA, 8'h55, 
        8'hF0, 8'h0F, 
        8'hFF, 8'hAA  
    };
    $display("\n[%0t] [TEST_8] === SIMULTANEOUS WRITE & READ TEST ===", $time);
    for(int i = 0; i < 8; i = i + 1) begin
        wdata = patterns[i];
        write(wdata);
    end

    //Simultaneous Write & Read
    for(int i=0;i<8;i=i+1) begin
        wdata=$urandom;
        write_read_concurrent(wdata,rdata);
    end

    for(int i=0;i<8;i=i+1) begin
        read(rdata);
    end 

    $display("\n[%0t] [TEST_8] === END TEST ===", $time);
    endtask
endclass