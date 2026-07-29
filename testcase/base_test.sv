class base_test #(DATA_WIDTH=8);
    environment env;
    virtual interf #(DATA_WIDTH) vif;

    function new(virtual interf #(DATA_WIDTH) vif_i);
        this.vif = vif_i;
    endfunction 

    function void build();
        env=new(vif);
        env.build();
    endfunction
    
    task write(logic [DATA_WIDTH-1:0] data);
    transaction tr=new();
    tr.data=data;
    tr.w_en=1;
    tr.r_en=0;
    env.gen.send_trans(tr);
    @(env.drv.write_done);
    endtask

    task read(output logic [DATA_WIDTH-1:0] data);
    transaction tr=new();
    tr.w_en=0;
    tr.r_en=1;
    env.gen.send_trans(tr);
    @(env.drv.read_done);
    data=tr.data;
    endtask
    task write_read_concurrent(logic [DATA_WIDTH-1:0] wdata, output logic [DATA_WIDTH-1:0] rdata);
        fork
            write(wdata);  // Luồng ghi
            read(rdata);   // Luồng đọc
        join
    endtask
    virtual task run_scenario();
  endtask

  task run_test();
    build();
    fork
      env.run();
      run_scenario();
    join_any
      //env.sb.report(error_cnt);
      #1000ns;
      env.report();
      $display("%0t: [base_test] End simulation",$time);
      $finish;
  endtask
endclass
