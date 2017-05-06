task myagent_monitor::do_mon;
  forever @(posedge vif.clk)
  begin
    m_trans.data = vif.data;
    analysis_port.write(m_trans);
  end
endtask
