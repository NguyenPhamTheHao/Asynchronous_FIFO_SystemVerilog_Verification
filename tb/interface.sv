interface interf #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)( 
    input logic wclk,
    input logic rclk
);
    // DUT input = TB output
    logic w_en;
    logic w_rstn;
    logic [DATA_WIDTH-1:0] wr_data;
    logic r_en;
    logic r_rstn;

    // DUT output = TB input
    logic empty;
    logic full;
    logic [DATA_WIDTH-1:0] rd_data;

    // Modport Declaration
    modport tb(
        input empty, full, rd_data, wclk, rclk,
        output w_en, w_rstn, r_en, r_rstn, wr_data
    );

    // SYSTEMVERILOG ASSERTIONS 
    `ifndef SYNTHESIS
    // VP-1A: Write Domain Reset Check (Full Flag & Write Pointers)
    property p_write_reset;
        @(posedge wclk) $rose(w_rstn) |-> 
        (full == 1'b0) &&
        (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr == '0) &&
        (testbench.u_AsynFF.u_Write_Pointer_Handler.g_wptr == '0);
    endproperty
    
    chk_write_reset: assert property(p_write_reset)
        else $error("[SVA ERROR @%0t] Write Reset Fail: full flag or write pointers (b_wptr/g_wptr) not reset to 0!", $time);

    // VP-1B: Read Domain Reset Check (Empty Flag & Read Pointers)
    property p_read_reset;
        @(posedge rclk) $rose(r_rstn) |-> 
        (empty == 1'b1) &&
        (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr == '0) &&
        (testbench.u_AsynFF.u_Read_Pointer_Handler.g_rptr == '0);
    endproperty
    
    chk_read_reset: assert property(p_read_reset)
        else $error("[SVA ERROR @%0t] Read Reset Fail: empty flag or read pointers (b_rptr/g_rptr) not reset to 0!", $time);
    // VP-2: Full Overflow Protection
    property p_no_write_when_full;
        @(posedge wclk) disable iff (!w_rstn)
        (full && w_en) |=> ($stable(testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr));
    endproperty
    
    chk_no_write_when_full: assert property(p_no_write_when_full)
        else $error("[SVA ERROR @%0t] Overflow Error: b_wptr incremented when FIFO was FULL!", $time);

    // VP-3: Empty Underflow Protection
    property p_no_read_when_empty;
        @(posedge rclk) disable iff (!r_rstn)
        (empty && r_en) |=> ($stable(testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr));
    endproperty
    
    chk_no_read_when_empty: assert property(p_no_read_when_empty)
        else $error("[SVA ERROR @%0t] Underflow Error: b_rptr incremented when FIFO was EMPTY!", $time);

    // VP-4A: Write Pointer Increment & Gray Code Check
    property p_wptr_inc_and_gray;
        logic [ADDR_WIDTH:0] expected_b_wptr;
        @(posedge wclk) disable iff (!w_rstn)
        (w_en && !full, expected_b_wptr = testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr + 1'b1) |=> 
        (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr == expected_b_wptr) &&
        (testbench.u_AsynFF.u_Write_Pointer_Handler.g_wptr == (expected_b_wptr ^ (expected_b_wptr >> 1)));
    endproperty
    
    chk_wptr_inc_and_gray: assert property(p_wptr_inc_and_gray)
        else $error("[SVA ERROR @%0t] Write Pointer or Gray Code Mismatch!", $time);

    // VP-4B: Read Pointer Increment & Gray Code Check
    property p_rptr_inc_and_gray;
        logic [ADDR_WIDTH:0] expected_b_rptr;
        @(posedge rclk) disable iff (!r_rstn)
        (r_en && !empty, expected_b_rptr = testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr + 1'b1) |=> 
        (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr == expected_b_rptr) &&
        (testbench.u_AsynFF.u_Read_Pointer_Handler.g_rptr == (expected_b_rptr ^ (expected_b_rptr >> 1)));
    endproperty
    
    chk_rptr_inc_and_gray: assert property(p_rptr_inc_and_gray)
        else $error("[SVA ERROR @%0t] Read Pointer or Gray Code Mismatch!", $time);

    // VP-5: Multi-Clock Assertion (Write to Empty -> Empty Deasserts on rclk)
    property p_multiclk_empty_deassert;
        @(posedge wclk) disable iff (!w_rstn || !r_rstn)
        (w_en && !full && empty) |-> ##1 @(posedge rclk) ##[0:3] !empty;
    endproperty
    
    chk_multiclk_empty_deassert: assert property(p_multiclk_empty_deassert)
        else $error("[SVA ERROR @%0t] Multi-Clock Timeout: Empty flag did not drop on rclk after Write!", $time);

    `endif
endinterface