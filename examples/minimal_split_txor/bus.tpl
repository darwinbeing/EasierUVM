agent_name = bus
trans_item = bus_tx
trans_var  = rand bit  cmd;
trans_var  = rand byte addr;
trans_var  = rand byte data;

agent_has_env = no

trans_inc_before_class       = bus_trans_inc_before_class.sv    inline
driver_inc_inside_class      = bus_driver_inc_inside_class.sv   inline
driver_inc_after_class       = bus_driver_inc_after_class.sv    inline
monitor_inc_inside_class     = bus_monitor_inc_inside_class.sv  inline
monitor_inc_after_class      = bus_monitor_inc_after_class.sv   inline
agent_cover_inc_inside_class = bus_cover_inc_inside_class.sv    inline
agent_cover_inc_after_class  = bus_cover_inc_after_class.sv     inline
agent_inc_inside_bfm         = bus_inc_inside_bfm.sv            inline

agent_cover_generate_methods_inside_class = no
agent_cover_generate_methods_after_class  = no

if_port  = logic clk;
if_port  = bit  cmd;
if_port  = byte addr;
if_port  = byte data;
if_clock = clk

agent_has_env = yes
