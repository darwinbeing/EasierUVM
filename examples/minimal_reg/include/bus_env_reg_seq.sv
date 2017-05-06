
`ifndef BUS_ENV_REG_SEQ_SV
`define BUS_ENV_REG_SEQ_SV

class bus_env_reg_seq extends bus_env_default_seq;

  `uvm_object_utils(bus_env_reg_seq)

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
     regmodel.reg0.write(status, .value('hab), .parent(this));
     assert(status == UVM_IS_OK);

     regmodel.reg0.write(status, .value('hcd), .parent(this));
     assert(status == UVM_IS_OK);

     regmodel.reg0.write(status, .value('hef), .parent(this));
     assert(status == UVM_IS_OK);
     
     regmodel.reg0.read(status, .value(data), .parent(this));
     assert(status == UVM_IS_OK);
  endtask: body

endclass : bus_env_reg_seq

`endif
