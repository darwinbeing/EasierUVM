agent_name = clkndata
trans_item = data_tx
trans_var  = rand byte data;

driver_inc      = clkndata_do_drive.sv   inline
monitor_inc     = clkndata_do_mon.sv     inline
agent_cover_inc = clkndata_cover_inc.sv  inline

#agent_cover_inc_inside_class = clkndata_cover_inc_inside.sv  inline
#agent_cover_inc_after_class  = clkndata_cover_inc_after.sv   inline
#agent_cover_generate_methods_inside_class = no
#agent_cover_generate_methods_after_class  = no

agent_seq_inc   = my_clkndata_seq.sv

agent_factory_set = clkndata_default_seq my_clkndata_seq

if_port  = logic clk;
if_port  = byte data;
if_clock = clk
