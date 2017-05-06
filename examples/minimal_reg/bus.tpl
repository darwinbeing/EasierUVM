agent_name = bus
trans_item = bus_tx
trans_var  = rand bit cmd;
trans_var  = rand byte addr;
trans_var  = rand byte data;

driver_inc = bus_do_drive.sv  inline

if_port    = logic clk;
if_port    = bit  cmd;
if_port    = byte addr;
if_port    = byte data;
if_clock   = clk

reg_access_mode       = WR
reg_access_block_type = bus_reg_block

uvm_reg_kind    = cmd
uvm_reg_addr    = addr
uvm_reg_data    = data

reg_seq_inc       = bus_env_reg_seq.sv   inline
agent_factory_set = bus_env_default_seq  bus_env_reg_seq
