function clkndata_coverage::new (string name, uvm_component parent);
  super.new(name, parent);
  m_cov = new;
endfunction
 
function void clkndata_coverage::write(input data_tx t);
  m_item = t;
  m_cov.sample();
endfunction : write
