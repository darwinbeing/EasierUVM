# Mandatory settings
dut_top   = dut

# The rest of the settings in this file are optional
dut_source_path = dut  # Path to directory containing DUT files.         Default is dut
inc_path  = inc        # Path to directory containing include files.     Default is include
dut_pfile = dut_pfile  # Path to pinlist file.                           Default is pinlist
prefix    = toplevel   # Prefix used to construct top-level class names. Default is top
project   = project    # Directory containing generated files.           Default is generated_tb
dut_iname = dut_inst   # Instance name of generated DUT module.          Default is uut

# Text fields included in every generated file header
copyright = My copyright string
name      = My name
email     = my.email
tel       = My telephone
dept      = My department
company   = My company
year      = My year
version   = Version_string

#generate_file_header = no            # Suppress the generated file header that includes the above fields
#file_header_inc = file_header_inc.sv # Insert user-defined file header after the above generated file header

timeunit       = 1ns
timeprecision  = 1ns

backup         = no                   # Whether to keep a backup copy of the generated files (file extension .bak). Default is yes

#comments_at_include_locations = no   # Whether to generate comments showing where you can insert code and suppress generation of certain methods

#dual_top          = yes              # Has two top-level modules rather than instantiating test harness module from test bench module
#split_transactors = yes              # Expects driver & monitor to be partitioned into untimed and synthesizable parts

# Common packages, always the first two user-defined packages imported in the generated code
common_pkg     = common_pkg.sv        # Include package file from dut directory
common_env_pkg = common_env_pkg.sv    # Include package file from include directory

# Register model (alternative to using the deprecated reg.tpl)
regmodel_file      = regmodel.sv      # Path to file containing register model
top_reg_block_type = top_reg_block    # Top-level uvm_reg_block type in register model


# Enable or suppress automatic generation of code or methods. Default is yes in every case
#th_generate_clock_and_reset                  = no  # Clock and reset declarations and assignments in test harness <top>_th
#tb_generate_run_test                         = no  # initial block that calls run_test() in <top>_tb

#top_env_generate_methods_inside_class        = no  # build_phase, connect_phase, run_phase
#top_env_generate_methods_after_class         = no  # build_phase, connect_phase, run_phase
#top_env_generate_run_phase                   = no  # run_phase
#top_env_generate_end_of_elaboration          = no  # end_of_elaboration_phase printing topology and factory

#top_env_config_generate_methods_inside_class = no  # new
#top_env_config_generate_methods_after_class  = no  # new

#test_generate_methods_inside_class           = no  # build_phase
#test_generate_methods_after_class            = no  # build_phase


# Include files for inserting user-defined code within automatically generated code
# By default, generates one `include directive. If inline is specified, code is copied inline instead of using an `include

th_inc_inside_module             = th_inc_inside_module.sv              inline  # Insert code in test harness <top>_th before dut instantiation
tb_inc_inside_module             = tb_inc_inside_module.sv              inline  # Insert code in test bench <top>_tb before test harness instantiation

test_inc_before_class            = test_inc_before_class.sv             inline
test_inc_inside_class            = test_inc_inside_class.sv             inline
test_inc_after_class             = test_inc_after_class.sv              inline

# The following require test_generate_methods_after_class = yes (the default)
test_prepend_to_build_phase      = test_prepend_to_build_phase.sv       inline  # Insert code at start of build_phase method
test_append_to_build_phase       = test_append_to_build_phase.sv        inline  # Insert code at end of build_phase method

top_env_inc_before_class         = top_env_inc_before_class.sv          inline
top_env_inc_inside_class         = top_env_inc_inside_class.sv          inline
top_env_inc_after_class          = top_env_inc_after_class.sv           inline

# The following require top_env_generate_methods_after_class = yes (the default)
top_env_prepend_to_build_phase   = top_env_prepend_to_build_phase.sv    inline  # Insert code at start of build_phase method
top_env_append_to_build_phase    = top_env_append_to_build_phase.sv     inline  # Insert code at end of build_phase method
top_env_append_to_connect_phase  = top_env_append_to_connect_phase.sv   inline  # Insert code at end of connect_phase method
top_env_append_to_run_phase      = top_env_append_to_run_phase.sv       inline  # Insert code at end of run_phase method

# Includes for top-level configuration class
top_env_config_inc_before_class  = top_env_config_inc_before_class.sv   inline
top_env_config_inc_inside_class  = top_env_config_inc_inside_class.sv   inline
top_env_config_inc_after_class   = top_env_config_inc_after_class.sv    inline

# Includes for top-level sequence "library", i.e. the file <top>_seq_lib containing <top>_default_seq 
top_seq_inc                      = top_seq_inc.sv                       inline

# List of factory overrides. Generates calls to set_type_override in build_phase method of <top>_test
#top_factory_set                 = top_default_seq user_defined_sequence_class

nested_config_objects = yes      # Instantiates agent configuration objects from top-level config object. Default is no

# List of declarations added to the generated top-level configuration class <top>_config
# Note that semicolons are needed, and comments are allowed
config_var = // Extra configuration variables from common.tpl
config_var = int count = 0;

#top_env_config_append_to_new                 = filename inline                 # Insert code at end of new method

top_default_sequence_count = 10                         # Repeat count for the top-level default virtual sequence. Default is 1

uvm_cmdline = +UVM_VERBOSITY=HIGH +UVM_OBJECTION_TRACE  # Options passed to the UVM Command Line processor
uvm_cmdline = +UVM_PHASE_TRACE                          # Further command line arguments

# Settings to instantiate a reference model and Syosil scoreboard
#syosil_scoreboard_src_path  = ../../syosil/src                                 # Path to Syosil scoreboard installation
#ref_model_input             = refmodel m_myagent_env.m_myagent_agent           # Agent sending transactions to ref model
#ref_model_output            = refmodel m_myagent_env.m_myagent_agent           # Agent sending transactions for comparison
#ref_model_compare_method    = refmodel iop                                     # Compare method for the scoreboard
#ref_model_inc_before_class  = refmodel refmodel_inc_before_class.sv   inline   # Insert code in reference model
#ref_model_inc_inside_class  = refmodel refmodel_inc_inside_class.sv   inline
#ref_model_inc_after_class   = refmodel refmodel_inc_after_class.sv    inline
