function bus_coverage::new(string name, uvm_component parent);
  super.new(name, parent);
  m_is_covered = 0;
endfunction : new


function void bus_coverage::write(input bus_tx t);
  `uvm_info(get_type_name(), t.convert2string(), UVM_MEDIUM)
endfunction : write


function void bus_coverage::build_phase(uvm_phase phase);
  if (!uvm_config_db #(bus_config)::get(this, "", "config", m_config))
    `uvm_error(get_type_name(), "bus config not found")
endfunction : build_phase
