agent_name = clkndata
trans_item = data_tx
trans_var  = rand byte data;

driver_inc = clkndata_do_drive.sv  inline

if_port    = logic clk;
if_port    = byte data;
if_clock   = clk
