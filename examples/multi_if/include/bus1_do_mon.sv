task bus1_monitor::do_mon;
  forever @(posedge vif.clk)
  begin
    m_trans = bus_tx::type_id::create("m_trans");
    m_trans.cmd  = vif.cmd;
    m_trans.addr = vif.addr;
    m_trans.data = vif.data;
    analysis_port.write(m_trans);
  end
endtask
