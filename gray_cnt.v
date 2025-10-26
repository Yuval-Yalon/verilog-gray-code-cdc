module gray_cnt #(parameter WIDTH = 8) (
  input clk,
  input rst_n,
  input en,
  output reg[WIDTH-1:0] gray_count
);
  
  // Internal binary counter
  reg [WIDTH-1:0] internal_bin;
  
  // Calculate the next binary value & handling wrap-around
  wire [WIDTH-1:0] next_bin;
  assign next_bin = internal_bin + 1;
  
  // Main synchronous logic
  always @(posedge clk or negedge rst_n) begin
    // Reset state
    if (!rst_n) begin
      internal_bin <= 0;
      gray_count <= 0;
    end
    else if (en) begin
      // Advance the internal binary counter
      internal_bin <= next_bin;
      // Output the Gray code equivalent of the next binary value
      gray_count <=  (next_bin >> 1) ^ next_bin;
    end   
  end
  
endmodule