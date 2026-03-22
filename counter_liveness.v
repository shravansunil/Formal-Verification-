module counter(input clk, input rst, output reg [1:0] count);

    // Standard counter logic
    always @(posedge clk) begin
        if (rst)
            count <= 2'b00;
        else
            count <= count + 1;
    end

    // --- Formal Verification Property Check ---
    `ifdef FORMAL
    
    // METHOD 1: The Standard SystemVerilog Way (Theory)
    // In advanced tools, you would use 's_eventually' (Strong Eventually).
    // assert property (@(posedge clk) s_eventually (count == 2'b00));

    // METHOD 2: The BMC / SAT Solver Way (Practical Bounded Liveness)
    // We add a tiny "watchdog" timer to count how long it has been since we saw 00.
    reg [2:0] cycles_since_zero = 0;
    
    always @(posedge clk) begin
        // Reset our timer if we see 00
        if (count == 2'b00)
            cycles_since_zero <= 0;
        else
            cycles_since_zero <= cycles_since_zero + 1;
            
        // Assert our bounded liveness rule: 
        // It must never take 4 or more cycles to return to 00!
        assert(cycles_since_zero < 4);
    end
    `endif

endmodule
