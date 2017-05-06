module mydut (
  input logic bus_clk, 
  input bit   bus_cmd, 
  input byte  bus_data, 
  input byte  bus_addr
);

always @(posedge bus_clk)
  $display("@%4d mydut bus_cmd = %s, bus_addr = %h, bus_data = %h", $time, (bus_cmd ? "W" : "R"), bus_addr, bus_data);

endmodule
