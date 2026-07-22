class generator;
    transaction trans_q[$];
    mailbox wr_mb;
    mailbox rd_mb;

    function new(mailbox wr_mb, mailbox rd_mb);
        this.wr_mb = wr_mb;
        this.rd_mb = rd_mb;
    endfunction

    task send_trans(transaction tr);
        trans_q.push_back(tr);
    endtask

    task run();
        transaction tr;
        forever begin 
            wait(trans_q.size() > 0);   
            tr = trans_q.pop_front();

            if (tr.w_en) begin
                wr_mb.put(tr);
                $display("[%0t] [Generator] Sent WRITE transaction to driver", $time);
            end

            if (tr.r_en) begin
                rd_mb.put(tr);
                $display("[%0t] [Generator] Sent READ transaction to driver", $time);
            end
        end
    endtask
endclass