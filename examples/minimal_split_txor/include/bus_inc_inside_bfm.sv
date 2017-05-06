// HDL-side synthesizable transactors

task drive(bus_tx_s req_s);
  if_port.cmd  <= req_s.cmd;
  if_port.addr <= req_s.addr;
  if_port.data <= req_s.data;
  @(posedge if_port.clk);
endtask

import bus_pkg::bus_monitor;
bus_monitor proxy_back_ptr;

task run;
  forever
  begin
    bus_tx_s req_s;
    @(posedge if_port.clk);
    req_s.cmd  = if_port.cmd;
    req_s.addr = if_port.addr;
    req_s.data = if_port.data;
    proxy_back_ptr.write(req_s);
  end
endtask
