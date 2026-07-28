class environment #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 4
);
    
    generator                       gen;
    driver #(DATA_WIDTH)            drv;
    monitor #(DATA_WIDTH)           mon;
    scoreboard #(ADDR_WIDTH)        sb; 
    fifo_cov_model #(DATA_WIDTH)    cov;
    // Khai báo Mailbox
    mailbox wr_mb;
    mailbox rd_mb;
    mailbox mon2scb;

    // Interface
    virtual interf #(DATA_WIDTH) vif;

    function new(virtual interf #(DATA_WIDTH) vif);
        this.vif = vif;
    endfunction

    function void build();
        $display("[%0t] [ENVIRONMENT] Building components...", $time);

        wr_mb   = new();
        rd_mb   = new();
        mon2scb = new();

        gen = new(wr_mb, rd_mb);
        drv = new(vif, wr_mb, rd_mb);
        mon = new(vif, mon2scb);
        sb  = new(mon2scb);
         cov = new(vif);
        if (wr_mb == null || rd_mb == null || mon2scb == null || 
            gen == null   || drv == null   || mon == null || sb == null || cov == null) begin
            $fatal(1, "[ENVIRONMENT] Build failed: some handle is NULL");
        end
    endfunction

    task run();
        fork
            begin : GEN_T if (gen == null) $fatal(1, "Generator NULL"); gen.run(); end
            begin : DRV_T if (drv == null) $fatal(1, "Driver NULL");    drv.run(); end
            begin : MON_T if (mon == null) $fatal(1, "Monitor NULL");   mon.run(); end
            begin : SCB_T if (sb  == null) $fatal(1, "Scoreboard NULL");sb.run();  end
            begin : COV_T if (cov == null) $fatal(1, "Coverage NULL");  cov.run(); end
        join_none
    endtask
    function void report();
        if (sb != null) begin
            sb.report();
        end
    endfunction
endclass