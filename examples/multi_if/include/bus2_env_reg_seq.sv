
`ifndef BUS2_ENV_REG_SEQ_SV
`define BUS2_ENV_REG_SEQ_SV

class bus2_env_reg_seq extends bus2_env_default_seq;

  `uvm_object_utils(bus2_env_reg_seq)

  //bus_reg_block	regmodel;
  //rand  uvm_reg_data_t data;
  //uvm_status_e         status;

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    repeat(4)
    begin
      regmodel.reg0.write(status, .value('hba), .parent(this));
      assert(status == UVM_IS_OK);

      regmodel.reg0.write(status, .value('hdc), .parent(this));
      assert(status == UVM_IS_OK);

      regmodel.reg0.write(status, .value('hfe), .parent(this));
      assert(status == UVM_IS_OK);
     
      regmodel.reg0.read(status, .value(data), .parent(this));
      assert(status == UVM_IS_OK);
    end
  endtask: body

endclass : bus2_env_reg_seq

`endif
