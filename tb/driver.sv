class driver #(parameter DATA_WIDTH=8);
    virtual interf #(DATA_WIDTH) vif;
    mailbox wr_mb; 
    mailbox rd_mb; 
    event read_done, write_done;

    function new(virtual interf #(DATA_WIDTH) vif, mailbox wr_mb, mailbox rd_mb);
        this.vif   = vif;
        this.wr_mb = wr_mb;
        this.rd_mb = rd_mb;
    endfunction

    task drive_write();
        transaction tr;
        forever begin
            wr_mb.get(tr);
            @(posedge vif.wclk);
            vif.w_en    <= 1'b1;
            vif.wr_data <= tr.data;
            
            @(posedge vif.wclk);
            vif.w_en    <= 1'b0;
            vif.wr_data <= '0;
            -> write_done; 
        end
    endtask

    task drive_read();
        transaction tr;
        forever begin
            rd_mb.get(tr);
            @(posedge vif.rclk);
            vif.r_en <= 1'b1;
            
            @(posedge vif.rclk);
            vif.r_en <= 1'b0;
            -> read_done; 
        end
    endtask

    task run();
        fork
            drive_write();
            drive_read();
        join
    endtask
endclass