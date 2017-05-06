agent_name = myagent                     # Name of agent. Must be at the top of the file.
trans_item = mytrans                     # Name of transaction class

#number_of_instances = 1                 # Number of instances of this agent/interface. Default is 1

uvm_seqr_class   = yes                   # Generates a class that extends uvm_sequencer rather than a typedef. Default is no
#agent_is_active  = UVM_PASSIVE          # Default is UVM_ACTIVE
agent_has_env    = yes                   # Agent has its own env, even if there is no register model. Default is no
#additional_agent = another_agent_name   # Default is none.

agent_checks_enable = no                 # Sets checks_enable flag in config object. Default is yes
agent_coverage_enable = no               # Sets coverage_enable flag in config object. Default is yes

# List of declarations to be included in the transaction class
# Note that semicolons are needed, and comments are allowed
trans_var       = rand byte data;        # Transaction variable
trans_var       = typedef enum {up, down} dir_t;  # typedefs can be specified using trans_var or trans_meta
trans_enum_var  = rand dir_t dir;        # Transaction variable of enumeration type
trans_meta      = time timestamp;        # Transaction metadata is excluded from do_compare/pack/unpack methods
trans_enum_meta = dir_t mode;   

# List of declarations added to the generated configuration class <agent>_config
# Note that semicolons are needed, and comments are allowed
config_var = // Extra configuration variables from myagent.tpl
config_var = int count = 0;


# List of declarations to be include in the interface, which will be <agent_name>_if
if_port  = logic clk;
if_port  = byte data;

if_clock = clk    # Optional. Only used with driver_inc (below) and with th_generate_clock_and_reset = yes (common.tpl)
#if_reset = reset # Ditto


# Enable or suppress automatic generation of methods. Default is yes in every case
#trans_generate_methods_inside_class        = no         # do_copy, do_compare, do_print, do_record, convert2string
#trans_generate_methods_after_class         = no

#agent_generate_methods_inside_class        = no         # build_phase, connect_phase
#agent_generate_methods_after_class         = no

#agent_env_generate_methods_inside_class    = no         # build_phase, connect_phase
#agent_env_generate_methods_after_class     = no

#agent_cover_generate_methods_inside_class  = no         # new, write, report_phase, covergroup m_cov
#agent_cover_generate_methods_after_class   = no

#agent_config_generate_methods_inside_class = no         # new
#agent_config_generate_methods_after_class  = no 

#reg_cover_generate_methods_inside_class    = no         # new, write, report_phase, covergroup m_cov
#reg_cover_generate_methods_after_class     = no

#adapter_generate_methods_inside_class      = no         # reg2bus, bus2reg
#adapter_generate_methods_after_class       = no

# Convenience includes to help beginners get started
driver_inc                    = myagent_driver_inc.sv                 inline
monitor_inc                   = myagent_monitor_inc.sv                inline
agent_cover_inc               = myagent_cover_inc.sv                  inline
reg_cover_inc                 = myagent_env_cover_inc.sv              inline


# Include files for inserting user-defined code within automatically generated code
# Each setting does nothing except generate one include, so can be freely combined with other settings
# By default, generates one `include directive. If inline is specified, code is copied inline instead of using an `include

# Includes for interface
if_inc_inside_interface       = if_inc_inside_interface.sv            inline

# Includes for transaction class
trans_inc_before_class        = mytrans_inc_before_class.sv           inline
trans_inc_inside_class        = mytrans_inc_inside_class.sv           inline
trans_inc_after_class         = mytrans_inc_after_class.sv            inline

# Includes for agent class
agent_inc_before_class        = myagent_inc_before_class.sv           inline
agent_inc_inside_class        = myagent_inc_inside_class.sv           inline
agent_inc_after_class         = myagent_inc_after_class.sv            inline

# The following require agent_generate_methods_after_class = yes (the default)
agent_prepend_to_build_phase  = myagent_prepend_to_build_phase.sv     inline  # Insert code at start of build_phase method
agent_append_to_build_phase   = myagent_append_to_build_phase.sv      inline  # Insert code at end of build_phase method
agent_append_to_connect_phase = myagent_append_to_connect_phase.sv    inline  # Insert code at end of connect_phase method

# Includes for sequencer class, require uvm_seqr_class = yes
sequencer_inc_before_class    = myagent_sequencer_inc_before_class.sv inline
sequencer_inc_inside_class    = myagent_sequencer_inc_inside_class.sv inline
sequencer_inc_after_class     = myagent_sequencer_inc_after_class.sv  inline

# Includes for driver class
driver_inc_before_class       = myagent_driver_inc_before_class.sv    inline
driver_inc_inside_class       = myagent_driver_inc_inside_class.sv    inline
driver_inc_after_class        = myagent_driver_inc_after_class.sv     inline

# Includes for monitor class
monitor_inc_before_class      = myagent_monitor_inc_before_class.sv   inline
monitor_inc_inside_class      = myagent_monitor_inc_inside_class.sv   inline
monitor_inc_after_class       = myagent_monitor_inc_after_class.sv    inline

# Includes for agent coverage (subscriber) class
agent_cover_inc_before_class  = myagent_cover_inc_before_class.sv     inline
agent_cover_inc_inside_class  = myagent_cover_inc_inside_class.sv     inline
agent_cover_inc_after_class   = myagent_cover_inc_after_class.sv      inline

# Includes for agent configuration class
agent_config_inc_before_class = myagent_config_inc_before_class.sv    inline
agent_config_inc_inside_class = myagent_config_inc_inside_class.sv    inline
agent_config_inc_after_class  = myagent_config_inc_after_class.sv     inline

# Includes for agent env class (for the top-level env, see common.tpl)
# agent_env_inc_* only makes sense with uvm_seqr_class = yes or reg_access_name
agent_env_inc_before_class    = myagent_env_inc_before_class.sv       inline
agent_env_inc_inside_class    = myagent_env_inc_inside_class.sv       inline
agent_env_inc_after_class     = myagent_env_inc_after_class.sv        inline

# The following require agent_env_generate_methods_after_class = yes (the default)
agent_env_prepend_to_build_phase  = myagent_env_prepend_to_build_phase.sv   inline  # Insert code at start of build_phase method
agent_env_append_to_build_phase   = myagent_env_append_to_build_phase.sv    inline  # Insert code at end of build_phase method
agent_env_append_to_connect_phase = myagent_env_append_to_connect_phase.sv  inline  # Insert code at end of connect_phase method

# Includes for agent env coverage (subscriber) class
reg_cover_inc_before_class    = myagent_env_cover_inc_before_class.sv inline
reg_cover_inc_inside_class    = myagent_env_cover_inc_inside_class.sv inline
reg_cover_inc_after_class     = myagent_env_cover_inc_after_class.sv  inline

# Includes for reg adapter class
adapter_inc_before_class      = myagent_adapter/inc_before_class.sv  inline
adapter_inc_inside_class      = myagent_adapter/inc_inside_class.sv  inline
adapter_inc_after_class       = myagent_adapter/inc_after_class.sv   inline


# Includes for sequence "library", i.e. the file <agent>_seq_lib.sv containing <agent>_default_seq
agent_seq_inc                 = myagent_seq_inc.sv                    inline

# Includes for env sequence "library", i.e. the file <agent>_env_seq_lib.sv containing <agent>_env_default_seq
agent_env_seq_inc             = myagent_env_seq_inc.sv                inline


# List of factory overrides. Generates calls to set_type_override in build_phase method of <top>_test
#agent_factory_set             = myagent_default_seq user_defined_sequence_class


# Access to registers in the register model
reg_access_mode           = WR                 # WR, WR, or RO                   
reg_access_map            = myagent_map        # Variable name of map in top-level register block
reg_access_block_type     = bus_reg_block      # Type of register block for this agent
reg_access_block_instance = myagent            # Instance name of register block for this agent below regmodel (can be null)

uvm_reg_kind = data   # Transaction variable that indicates read/write
uvm_reg_addr = data   # Transaction variable that represents the address
uvm_reg_data = data   # Transaction variable that represents the data


