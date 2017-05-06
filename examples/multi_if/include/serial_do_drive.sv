task serial_driver::do_drive();
  @(posedge vif.clk);
  if (req.dir == serial_tx::IN)
  begin
    vif.data_in <= 1; // Start bit
    @(posedge vif.clk);
    for (int i = 7; i >= 0 ; i--)
    begin
      vif.data_in <= req.data[i];
      @(posedge vif.clk);
    end
    vif.data_in <= 0; // Stop bit
  end
  else
  begin
    int countdown = 16;
    while (vif.data_out == 0 && countdown--)
      @(posedge vif.clk);
    for (int i = 7; i >= 0 ; i--)
    begin
      req.data[i] = vif.data_out;
      @(posedge vif.clk);
    end
 end
endtask
