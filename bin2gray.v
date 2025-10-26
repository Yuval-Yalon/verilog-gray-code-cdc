module bin2gray #(parameter WIDTH = 8) (
  input [WIDTH-1:0] bin_in,
  output [WIDTH-1:0] gray_out
);
  // The standard vector-based logic for bin-to-gray
  assign gray_out = (bin_in >> 1) ^ bin_in;
    
endmodule