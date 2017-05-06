task bus_driver::run_phase(uvm_phase phase);
  forever
  begin
    bus_tx_s req_s;
    seq_item_port.get_next_item(req);

    // Copy fields to packed struct
    req_s.cmd  = req.cmd;
    req_s.addr = req.addr;
    req_s.data = req.data;
    
    // Call HDL-side transactor
    vif.drive(req_s);

    seq_item_port.item_done();
  end
endtask : run_phase 
