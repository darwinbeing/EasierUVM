Example with four interfaces/agents, two of which use the register layer
  clkndata
  serial
  bus1 - uses register layer
  bus2 - uses register layer

Allows you to experiment with
  uvm_seqr_class   = yes or no (default no)
  agent_is_active  = UVM_ACTIVE or UVM_PASSIVE (default UVM_ACTIVE)
  agent_has_env    = yes or no (default no)
  additional_agent = <agent> (only with agent_has_env = yes)

Each interface template file has these 4 parameters set to their default values,
but you are encouraged to experiment with their values.
