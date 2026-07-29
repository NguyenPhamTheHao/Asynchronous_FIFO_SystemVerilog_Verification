class fifo_cov_model #(parameter DATA_WIDTH = 8);
    virtual interf #(DATA_WIDTH) vif;

    covergroup fifo_cg;
        option.per_instance = 1;

        CP_FULL: coverpoint vif.full {
            bins is_full        = {1'b1};
            bins not_full       = {1'b0};
            bins full_assert    = (1'b0 => 1'b1); 
            bins full_deassert  = (1'b1 => 1'b0);
        }

        CP_EMPTY: coverpoint vif.empty {
            bins is_empty       = {1'b1};
            bins not_empty      = {1'b0};
            bins empty_assert   = (1'b0 => 1'b1); 
            bins empty_deassert = (1'b1 => 1'b0);
        }

        CP_WEN: coverpoint vif.w_en {
            bins write_active = {1'b1};
            bins write_idle   = {1'b0};
        }

        CP_REN: coverpoint vif.r_en {
            bins read_active  = {1'b1};
            bins read_idle    = {1'b0};
        }

        CP_W_RSTN: coverpoint vif.w_rstn {
            bins reset_asserted   = {1'b0};
            bins reset_deasserted = {1'b1};
        }

        CP_R_RSTN: coverpoint vif.r_rstn {
            bins reset_asserted   = {1'b0};
            bins reset_deasserted = {1'b1};
        }

        CROSS_RESET_WHEN_DATA: cross CP_W_RSTN, CP_EMPTY {
            bins reset_at_empty  = binsof(CP_W_RSTN.reset_asserted) && binsof(CP_EMPTY.is_empty);
            bins reset_at_middle = binsof(CP_W_RSTN.reset_asserted) && binsof(CP_EMPTY.not_empty);
            ignore_bins others = binsof(CP_W_RSTN.reset_deasserted) 
                      || binsof(CP_EMPTY.empty_assert) 
                      || binsof(CP_EMPTY.empty_deassert);
        }

        CROSS_OVERFLOW: cross CP_WEN, CP_FULL {
            bins overflow_attempt = binsof(CP_WEN.write_active) && binsof(CP_FULL.is_full);
            ignore_bins others = !binsof(CP_WEN.write_active) || !binsof(CP_FULL.is_full);
        }

        CROSS_UNDERFLOW: cross CP_REN, CP_EMPTY {
            bins underflow_attempt = binsof(CP_REN.read_active) && binsof(CP_EMPTY.is_empty);
            ignore_bins others = !binsof(CP_REN.read_active) || !binsof(CP_EMPTY.is_empty);
        }

        CROSS_SIMULTANEOUS_STATES: cross CP_WEN, CP_REN, CP_FULL, CP_EMPTY {
            bins concurrent_wr_rd_normal = binsof(CP_WEN.write_active) && binsof(CP_REN.read_active) 
                                   && binsof(CP_FULL.not_full) && binsof(CP_EMPTY.not_empty);

   
            ignore_bins ignore_all_transitions = binsof(CP_FULL.full_assert)   || binsof(CP_FULL.full_deassert)
                                      || binsof(CP_EMPTY.empty_assert)  || binsof(CP_EMPTY.empty_deassert);
            ignore_bins invalid_full_and_empty = binsof(CP_FULL.is_full) && binsof(CP_EMPTY.is_empty);
            ignore_bins invalid_write_when_empty = binsof(CP_WEN.write_active)
                                        && binsof(CP_EMPTY.is_empty);
}
        CP_WR_DATA: coverpoint vif.wr_data iff (vif.w_en && vif.w_rstn) {
            bins all_zeros  = {'0};
            bins all_ones   = {'1};
            bins alt_10     = {8'hAA};
            bins alt_01     = {8'h55};
            bins walking_1s = {8'h01, 8'h02, 8'h04, 8 'h08, 8'h10, 8'h20, 8'h40, 8'h80};
            bins random     = default;
        }

    endgroup

    function new(virtual interf #(DATA_WIDTH) vif);
        this.vif = vif;
        fifo_cg  = new();
    endfunction

    task run();
        fork
            forever begin
                @(posedge vif.wclk);
                fifo_cg.sample();
            end
            forever begin
                @(posedge vif.rclk);
                fifo_cg.sample();
            end
        join_none
    endtask
endclass