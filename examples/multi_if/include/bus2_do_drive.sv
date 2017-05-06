task bus2_driver::do_drive();
  vif.cmd  = req.cmd;
  vif.addr = req.addr;
  vif.data = req.data;
  @(posedge vif.clk);
endtask
