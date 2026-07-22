class scoreboard #(parameter ADDR_WIDTH = 4);
    mailbox mon2scb;
    byte unsigned ref_queue[$]; 
    int max_depth = 1 << ADDR_WIDTH;
    int num   = 0; 
    int error = 0;

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task run();
        transaction tr;
        byte unsigned expected_data;

        forever begin
            mon2scb.get(tr);
            num = num + 1;
        
            if (ref_queue.size() == 0 && tr.empty !== 1'b1) begin
                $display("[%0t] [SCB-FLAG] [FAIL] Ref Queue is EMPTY, but DUT EMPTY flag is %0b (Expected: 1)!", $time, tr.empty);
                error = error + 1;
            end
            
            // Check Cờ Full
            if (ref_queue.size() == max_depth && tr.full !== 1'b1) begin
                $display("[%0t] [SCB-FLAG] [FAIL] Ref Queue is FULL (%0d), but DUT FULL flag is %0b (Expected: 1)!", $time, max_depth, tr.full);
                error = error + 1;
            end
            
            
            if (tr.w_en) begin
                if (ref_queue.size() < max_depth) begin
                    ref_queue.push_back(tr.data);
                    $display("[%0t] [SCB-DATA] [PASS] Pushed 0x%0h into Ref Queue (Size: %0d)", $time, tr.data, ref_queue.size());
                    $display("\n=======FINISHED VERIFIED NO %0d=============\n", num);
                end else begin
                   
                    $display("[%0t] [SCB-INFO] Write attempt while FULL. Data 0x%0h correctly ignored by Golden Model.", $time, tr.data);
                    $display("\n=======FINISHED VERIFIED NO %0d=============\n", num);
                end
            end

            
            if (tr.r_en) begin
                if (ref_queue.size() > 0) begin
                    expected_data = ref_queue.pop_front();
                    if (expected_data !== tr.data) begin
                        $error("[%0t] [SCB-DATA] [FAIL] Read Mismatch! Expected: 0x%0h, Actual: 0x%0h", $time, expected_data, tr.data);
                        $display("\n=======FINISHED VERIFIED NO %0d=============\n", num);
                        error = error + 1;
                    end else begin
                        $display("[%0t] [SCB-DATA] [PASS] Read Match: 0x%0h", $time, tr.data);
                        $display("\n=======FINISHED VERIFIED NO %0d=============\n", num);
                    end
                end else begin
                    
                    $display("[%0t] [SCB-INFO] Read attempt while EMPTY. Correctly ignored by Golden Model.", $time);
                    $display("\n=======FINISHED VERIFIED NO %0d=============\n", num);
                end
            end
        end 
    endtask

    function void report();
        $display("\n==========================================================");
        $display("                   SCOREBOARD SUMMARY                     ");
        $display("==========================================================");
        $display(" Total Transactions Checked : %0d", num);
        $display(" Total Errors Detected      : %0d", error);
        $display("----------------------------------------------------------");
        
        if (error == 0) begin
            $display(" >>> TESTCASE RESULT : [ PASSED ] <<<");
        end else begin
            $display(" >>> TESTCASE RESULT : [ FAILED ] (With %0d errors) <<<", error);
        end
        $display("==========================================================\n");
    endfunction
endclass