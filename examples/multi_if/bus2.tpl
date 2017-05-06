agent_name = bus2
trans_item = bus_tx
trans_var  = rand bit cmd;
trans_var  = rand byte addr;
trans_var  = rand byte data;

#uvm_seqr_class   = yes
#agent_is_active  = UVM_PASSIVE
#agent_has_env    = yes
#additional_agent = clkndata

driver_inc  = bus2_do_drive.sv  inline
monitor_inc = bus2_do_mon.sv    inline

if_port  = logic clk;
if_port  = bit  cmd;
if_port  = byte addr;
if_port  = byte data;
if_clock = clk

agent_has_env = yes

reg_access_mode       = WR
reg_access_block_type = bus2_reg_block

uvm_reg_kind    = cmd
uvm_reg_addr    = addr
uvm_reg_data    = data

reg_seq_inc       = bus2_env_reg_seq.sv  inline
agent_factory_set = bus2_env_default_seq  bus2_env_reg_seq
