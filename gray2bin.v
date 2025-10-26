module gray2bin #(parameter WIDTH = 8)(
  input [WIDTH-1:0] gray_in,
  output [WIDTH-1:0] bin_out  
);
  
  // The MSB is always the same in binary and Gray
  assign bin_out[WIDTH-1] = gray_in[WIDTH-1];  
  
  
  genvar i;
  // B[i] = G[i] ^ B[i+1]
  generate
    for (i = WIDTH-2; i >= 0; i = i - 1) begin
      assign bin_out[i] = gray_in[i] ^ bin_out[i+1];
    end
  endgenerate
  
endmodule