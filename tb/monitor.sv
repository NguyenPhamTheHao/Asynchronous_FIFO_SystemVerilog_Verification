class monitor #(parameter DATA_WIDTH=8);
    virtual interf #(DATA_WIDTH) vif;
    mailbox mon2scb;

    function new(virtual interf #(DATA_WIDTH) vif, mailbox mon2scb);
        this.vif     = vif;
        this.mon2scb = mon2scb;
    endfunction

    task monitor_write();
        transaction tr;
        forever begin
            @(posedge vif.wclk);
            if (vif.w_en && vif.w_rstn) begin
                tr       = new();
                tr.w_en  = 1'b1;
                tr.data  = vif.wr_data;
                tr.full  = vif.full;   
                tr.empty = vif.empty;

                mon2scb.put(tr);
                $display("[%0t] [MON_WR] Captured WRITE attempt: data = 0x%0h | full=%0b, empty=%0b", 
                         $time, tr.data, tr.full, tr.empty);
            end
        end
    endtask

    // 2. Bắt giao dịch READ
    task monitor_read();
        forever begin
            @(posedge vif.rclk);
            if (vif.r_en && vif.r_rstn) begin
                fork
                    begin
                        transaction tr = new();
                        tr.r_en  = 1'b1;
                        tr.full  = vif.full;
                        tr.empty = vif.empty;

                        @(posedge vif.rclk); 
                        #1ns; 
                        
                        tr.data = vif.rd_data;
                        mon2scb.put(tr);
                        $display("[%0t] [MON_RD] Captured READ attempt: data = 0x%0h | full=%0b, empty=%0b", 
                                 $time, tr.data, tr.full, tr.empty);
                    end
                join_none 
            end
        end
    endtask

    task run();
        fork
            monitor_write();
            monitor_read();
        join
    endtask
endclass