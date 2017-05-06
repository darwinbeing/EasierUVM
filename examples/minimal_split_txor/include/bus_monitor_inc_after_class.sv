task bus_monitor::run_phase(uvm_phase phase);
  vif.proxy_back_ptr = this;
  vif.run();
endtask

function void bus_monitor::write(bus_tx_s req_s);
  bus_tx tx;
  tx = bus_tx::type_id::create("tx");
  tx.cmd  = req_s.cmd;
  tx.addr = req_s.addr;
  tx.data = req_s.data;
  analysis_port.write(tx);
endfunction
