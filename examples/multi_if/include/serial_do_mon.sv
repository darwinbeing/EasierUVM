task serial_monitor::do_mon;
  fork
    forever @(posedge vif.clk)
    begin
      serial_tx tx;
      tx = serial_tx::type_id::create("tx");
      while (vif.data_in == 0)
        @(posedge vif.clk);
      tx.dir = serial_tx::IN;
      for (int i = 7; i >= 0 ; i--)
      begin
        tx.data[i] = vif.data_in;
        @(posedge vif.clk);
      end
      analysis_port.write(tx);
    end
    
    forever @(posedge vif.clk)
    begin
      serial_tx tx;
      tx = serial_tx::type_id::create("tx");
      while (vif.data_out == 0)
        @(posedge vif.clk);
      tx.dir = serial_tx::OUT;
      for (int i = 7; i >= 0 ; i--)
      begin
        tx.data[i] = vif.data_out;
        @(posedge vif.clk);
      end
      analysis_port.write(tx);
    end
  join
endtask
