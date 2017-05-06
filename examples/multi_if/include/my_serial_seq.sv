
`ifndef MY_SERIAL_SEQ_SV
`define MY_SERIAL_SEQ_SV


class my_serial_seq extends serial_default_seq;

  `uvm_object_utils(my_serial_seq)

  rand byte data;

  function new(string name = "");
    super.new(name);
  endfunction : new

  task body();
    `uvm_info(get_type_name(), "my_serial_seq sequence starting", UVM_HIGH)

    req = serial_tx::type_id::create("req");
    start_item(req); 
    if ( !req.randomize() with { dir == serial_tx::IN; })
      `uvm_warning(get_type_name(), "randomization failed!")
    finish_item(req); 

    `uvm_info(get_type_name(), "my_serial_seq sequence completed", UVM_HIGH)
  endtask : body

endclass : my_serial_seq


`endif // SERIAL_SEQ_LIB_SV

