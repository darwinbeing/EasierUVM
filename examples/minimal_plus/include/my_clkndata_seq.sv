
`ifndef MY_CLKNDATA_SEQ_SV
`define MY_CLKNDATA_SEQ_SV


class my_clkndata_seq extends clkndata_default_seq;

  `uvm_object_utils(my_clkndata_seq)

  rand byte data;

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    `uvm_info(get_type_name(), "my_clkndata_seq sequence starting", UVM_HIGH)
    super.body();
    for (int i = 0; i < 16; i++)
    begin
      req = data_tx::type_id::create("req");
      start_item(req); 
      if ( !req.randomize() with { data == i; })
        `uvm_warning(get_type_name(), "randomization failed!")
      finish_item(req); 
    end
    `uvm_info(get_type_name(), "my_clkndata_seq sequence completed", UVM_HIGH)
  endtask : body

endclass : my_clkndata_seq


`endif // CLKNDATA_SEQ_LIB_SV

