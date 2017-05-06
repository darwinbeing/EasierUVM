task clkndata_monitor::do_mon;
  forever @(posedge vif.clk)
  begin
    m_trans = data_tx::type_id::create("tx");
    m_trans.data = vif.data;
    analysis_port.write(m_trans);
  end
endtask
