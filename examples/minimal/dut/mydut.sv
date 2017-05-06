module mydut (input clk, input byte data);

always @(posedge clk)
  $display("mydut data = %h", data);

endmodule
