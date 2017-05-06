
`ifndef BUS1_ENV_REG_SEQ_SV
`define BUS1_ENV_REG_SEQ_SV

class bus1_env_reg_seq extends bus1_env_default_seq;

  `uvm_object_utils(bus1_env_reg_seq)

  //bus_reg_block	regmodel;
  //rand  uvm_reg_data_t data;
  //uvm_status_e         status; 

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    repeat(4)
    begin
      regmodel.reg0.write(status, .value('hab), .parent(this));
      assert(status == UVM_IS_OK);

      regmodel.reg0.write(status, .value('hcd), .parent(this));
      assert(status == UVM_IS_OK);

      regmodel.reg0.write(status, .value('hef), .parent(this));
      assert(status == UVM_IS_OK);
     
      regmodel.reg0.read(status, .value(data), .parent(this));
      assert(status == UVM_IS_OK);
    end
  endtask: body

endclass : bus1_env_reg_seq

`endif
