agent_name = serial
trans_item = serial_tx

trans_var      = typedef enum {IN, OUT} dir_t;
trans_enum_var = rand dir_t dir;
trans_var      = rand byte data;

#uvm_seqr_class   = yes
#agent_is_active  = UVM_PASSIVE
#agent_has_env    = yes
#additional_agent = clkndata

driver_inc    = serial_do_drive.sv  inline
monitor_inc   = serial_do_mon.sv    inline
agent_seq_inc = my_serial_seq.sv    inline

agent_factory_set = serial_default_seq my_serial_seq

if_port  = logic clk;
if_port  = logic data_in;
if_port  = logic data_out;
if_clock = clk
