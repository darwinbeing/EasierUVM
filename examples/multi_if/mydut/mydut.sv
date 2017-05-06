module mydut (input logic clk, 
              input byte  data,
               
              input logic bus1_clk, 
              input bit   bus1_cmd, 
              input byte  bus1_data, 
              input byte  bus1_addr,

              input logic bus2_clk, 
              input bit   bus2_cmd, 
              input byte  bus2_data, 
              input byte  bus2_addr,
              
              input logic  serial_clk,
              input logic  serial_in,
              output logic serial_out);

always @(posedge clk)
  $display("mydut data = %8d", data);

always @(posedge bus1_clk)
  $display("@%4d mydut bus1_cmd = %s, bus1_addr = %h, bus1_data = %h", $time, (bus1_cmd ? "W" : "R"), bus1_addr, bus1_data);

always @(posedge bus2_clk)
  $display("@%4d mydut bus2_cmd = %s, bus2_addr = %h, bus2_data = %h", $time, (bus2_cmd ? "W" : "R"), bus2_addr, bus2_data);

always @(posedge serial_clk)
  $display("mydut serial_in = %b", serial_in);
  
endmodule
