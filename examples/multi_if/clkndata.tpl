agent_name = clkndata
trans_item = data_tx
trans_var  = rand byte data;

#uvm_seqr_class   = yes
#agent_is_active  = UVM_PASSIVE
#agent_has_env    = yes
#additional_agent = serial

driver_inc = clkndata_do_drive.sv   inline
monitor_inc = clkndata_do_mon.sv    inline
agent_seq_inc = my_clkndata_seq.sv  inline

agent_factory_set = clkndata_default_seq my_clkndata_seq

if_port  = logic clk;
if_port  = byte data;
if_clock = clk
