module testbench ();
  
  // Parameter
  localparam TB_WIDTH = 4;
  
  // Signals
  reg clk;
  reg rst_n;
  reg en;
  
  // Wires to connect the modules
  wire [TB_WIDTH-1:0] gray_cnt_out;
  wire [TB_WIDTH-1:0] g2b;
  wire [TB_WIDTH-1:0] b2g;
  
  // Golden Binary number
  reg [TB_WIDTH-1:0] expected_binary;
  
  integer i;
  integer error_count = 0;
  
  // Clock Generator
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Instantiation of DUTs
  bin2gray #(.WIDTH(TB_WIDTH)) u_bin2gray (
    .bin_in(expected_binary),
    .gray_out(b2g)
  );
  gray2bin #(.WIDTH(TB_WIDTH)) u_gray2bin(
    .gray_in(gray_cnt_out),
    .bin_out(g2b)
  );
    
  gray_cnt #(.WIDTH(TB_WIDTH)) u_gray_cnt(
    
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .gray_count(gray_cnt_out)
  );
  
  // Test Sequence
  initial begin
    en <= 0;
    rst_n <= 0;
    expected_binary <= 0;
    
    @(posedge clk);
    rst_n <= 1;
    @(posedge clk);
    
    // Main test loop
    en <= 1;
    for (i = 0; i < (2**TB_WIDTH)*2; i = i + 1) begin
      @(posedge clk);
      // Advance the golden Binary number
      expected_binary <= expected_binary + 1;
      #5
      
      // Test the counter and gray2bin
      if (g2b != expected_binary) begin
        $error("[Cycle %0d] gray2bin FAILED! GrayIn: %h, BinOut: %h, Expected: %h",i, gray_cnt_out, g2b, expected_binary);
        error_count = error_count + 1;
      end
      
      // Test the counter and bin2gray
      if (b2g != gray_cnt_out) begin
        $error("[Cycle %0d] bin2gray FAILED! BinIn: %h, GrayOut: %h, Expected: %h", i, expected_binary, b2g, gray_cnt_out);
        error_count = error_count + 1;
      end
    end
    
    // Stop counting and print results
    if (error_count == 0) begin
      $display("TEST PASSED");
    end
    else begin
      $display("TEST FAILED with %0d errors" ,error_count);
    end
    en = 0;
  $finish;
  end
endmodule