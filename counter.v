module counter(input clk, input rst, output reg [1:0] count);

    // Standard counter logic from the assignment
    always @(posedge clk) begin
        if (rst)
            count <= 2'b00;
        else
            count <= count + 1;
    end

    // --- Formal Verification Property Check ---
    // The formal tool will define the "FORMAL" macro automatically
    `ifdef FORMAL
    always @(posedge clk) begin
        // Safety property: G!(count = 2'b11)
        // This tells the solver: "Assert that count is NOT equal to 3"
        assert(count != 2'b11);
    end
    `endif

endmodule
