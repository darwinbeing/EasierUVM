#!/usr/bin/perl
##
##----------------------------------------------------------------------
## Copyright (c) 2013-2016 by Doulos Ltd.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------

## Based on the juvb11.pl script v1.09 by Jim McGrath, Cadence which was uploaded as UVMWorld contribution on 16 September 2011
## 19/02/2014  Author Christoph Suehnel, Doulos
## 24/02/2014  David Long, Doulos - DUT port list, auto instantiation in top
## 12/03/2014  David Long, Doulos - Support for multiple IFs/register sub-blocks
## 04/04/2014  David Long, Doulos - Naming conventions and use of config_db updated
## 11/04/2014  David Long, Doulos - Constraints added to seq_item
## 20/05/2014  David Long, Doulos - Support for multiple agents within envs. Simplified directory structure,
## 05/06/2014  David Long, Doulos - Revised template file format and options. Preliminary version for public release
## 01/09/2014  David Long, Doulos - DUT now in test harness module. Removed unnecessary child environments. Improvements to code formatting
## 21/09/2014  David Long, Doulos - trans_var allows typedef. item replaced by req. Added checks/coverage_enable.
## 08/10/2014  David Long, Doulos - fixed some naming conventions. Check "is_active"
## 13/10/2014  David Long, Doulos - fixed bug with "uvm_seqr_class" switch in template file
## 13/10/2014  David Long, Doulos - default_sequence class now derived directly from uvm_sequence
## 17/10/2014  David Long, Doulos - removed unnecessary base class for test. Configuration for top env now set in TB module
## 22/10/2014  David Long, Doulos - Top-level sequence now started by env (default test run_phase does nothing). Removed unnecessary task wait_end_test.
##                                  Added checking for critical warnings re include files (can be ignored by adding -c ("continue") flag to command line
## 06/11/2014  David Long, Doulos - Option to add common package for parameters, etc that can be accessed in all generated files (including test harness)
## 05/11/2014  David Long, Doulos - Generated packages now include files directly (removed .svh files). Removed unused *_common.sv files
## 07/11/2014  David Long, Doulos - Removed <test>_common_pkg include file - these items are now written to test common package directly.
##                                  Test common package file is not regenerated if it has been modified since it was created (i.e. user changes are preserved).
## 07/11/2014  David Long, Doulos - Top-level sequence uses UVM 1.2 API to raise/drop objections in pre/post-start.
## 17/11/2014  David Long, Doulos - Corrected minor formatting issues.
## 16/12/2014  John Aynsley, Doulos - Tidied up positioning of blank lines.
## 19/12/2014  John Aynsley, Doulos - Add m_ prefix to member variables. Add some pretty-printing
## 05/01/2015  John Aynsley, Doulos - Fix bug with properties leaking between agents
## 16/01/2015  John Aynsley, Doulos - Tweak formatting
## 20/01/2015  John Aynsley, Doulos - Tweak formatting
## 28/01/2015  John Aynsley, Doulos - Add a parameter regmodel_file to reg.tpl to replace the hardwired "regmodel.sv"
## 28/01/2015  John Aynsley, Doulos - Allow regmodel_ as well as rm_ in reg.tpl file
## 29/01/2015  John Aynsley, Doulos - Call `uvm_error if randomize fails
## 04/02/2015  John Aynsley, Doulos - Fix bug so that common package gets included in agent interfaces, rationalize package imports
## 04/02/2015  John Aynsley, Doulos - Allow named constraints as trans_var = values
## 19/02/2015  John Aynsley, Doulos - Label coverpoints using field name rather than number
## 19/02/2015  John Aynsley, Doulos - Add new include files inside/after classes
## 07/04/2015  John Aynsley, Doulos - Add new include file inside th module
## 21/04/2015  John Aynsley, Doulos - Generate get/set_starting_phase methods for all sequences
## 05/05/2015  John Aynsley, Doulos - Add several new include files and independent flags to suppress the generation of default members and methods
## 06/05/2015  John Aynsley, Doulos - Add ability to inline all user-defined include files
## 11/05/2015  John Aynsley, Doulos - Restructure <top>_common_pkg as per common_pkg (not backward-compatible)
## 12/05/2015  John Aynsley, Doulos - Add _prepend_to_ and _append_to_ include files for build_phase, connect_phase, run_phase methods
## 12/05/2015  John Aynsley, Doulos - Don't generate end_of_elaboration_phase, start_of_simulation_phase, check_phase (allows it to be user-defined more conveniently)
## 12/05/2015  John Aynsley, Doulos - Don't generate empty run_phase for test (allows it to be user-defined more conveniently)
## 19/05/2015  John Aynsley, Doulos - Support multiple instances of each interface (with _N suffix in pinlist file)
## 20/05/2015  John Aynsley, Doulos - Refactor all the pretty-print code
## 26/05/2015  John Aynsley, Doulos - Generate comments showing possible include locations
## 30/05/2015  John Aynsley, Doulos - Permit trans_item name clashes across agents by distinguishing the filenames
## 05/06/2015  John Aynsley, Doulos - Add agent_copy_config_vars
## 16/06/2015  John Aynsley, Doulos - Add -m command line argument to specify path to common template file. Interface template files may have any name (not just *.tpl)
## 16/06/2015  John Aynsley, Doulos - Add prefix = setting to common template file as alternative to -p switch
## 17/06/2015  John Aynsley, Doulos - Refactor by adding warning_prompt
## 20/06/2015  John Aynsley, Doulos - Add reg_access_mode, reg_access_map, reg_access_block_type, reg_access_block_instance, top_reg_block_type, regmodel_file
## 20/06/2015  John Aynsley, Doulos - Make reg.tpl optional
## 21/06/2015  John Aynsley, Doulos - Add top_env_generate_end_of_elaboration (default yes)
## 21/06/2015  John Aynsley, Doulos - Revamp messages printed from script
## 21/06/2015  John Aynsley, Doulos - Fix bug in gen_env which was repeating additional agent declaration in number_of_instances loop
## 21/06/2015  John Aynsley, Doulos - Add compile/run script for Riviera
## 30/09/2015  John Aynsley, Doulos - Add command line flag -x to output dut_source_path, inc_path, and project without generating any code
## 01/10/2015  John Aynsley, Doulos - Adjust compile_vcs.do and compile_ius.do scripts to use built-in versions of UVM-1.2
## 01/10/2015  John Aynsley, Doulos - Replace factory with uvm_factory::get().
## 20/10/2015  John Aynsley, Doulos - Make the -r switch optional: instantiation of the register model will be forced in the presence of top_reg_block_type
## 20/10/2015  John Aynsley, Doulos - Extend command line flag -x to output regmodel_file without generating any code
## 22/10/2015  John Aynsley, Doulos - Make files.f optional. If absent, create a files.f that lists just the *.sv files in the DUT directory (alphabetical order)
## 23/10/2015  John Aynsley, Doulos - Allow dut_source_path to default to dut, inc_path to default to include, dut_pfile to default to pinlist
## 23/10/2015  John Aynsley, Doulos - Add common template setting uvm_cmdline = , and remove +UVM_VERBOSITY=FULL from sim scripts, using $uvm_cmdline instead
## 26/10/2015  John Aynsley, Doulos - With -x regmodel_file, force the script to read reg.tpl if the file exists
## 03/11/2015  John Aynsley, Doulos - Moved _N suffix to before standard suffix for consistency, e.g. changed m_${agent}_agent${suffix} to m_${agent}${suffix}_agent
## 09/11/2015  John Aynsley, Doulos - Call comparer.compare_field in overridden do_compare method of uvm_sequence_item (to keep Syosil scoreboard happy)
## 16/11/2015  John Aynsley, Doulos - Add top_default_seq_count in common template
## 17/11/2015  John Aynsley, Doulos - Rewrite the pretty-printing code
## 17/11/2015  John Aynsley, Doulos - Add support for the Syosil Versatile Scoreboard: syosil_scoreboard_src_path, ref_model_input, ref_model_output
##                                                                                     ref_model_compare_method, ref_model_inc_before/inside/after_class
## 26/11/2015  John Aynsley, Doulos - Generate pack and unpack methods in uvm_sequence_item class unless cmdline flag -nopack is present for backward compatibility
## 26/11/2015  John Aynsley, Doulos - Add trans_enum_var setting to distinguish enum variables in do_pack, do_unpack, and convert2string - mandatory for enums in pack!
## 26/11/2015  John Aynsley, Doulos - Add trans_meta setting to distinguish transaction metadata and thus exclude it from do_compare, do_pack, and do_unpack methods
## 26/11/2015  John Aynsley, Doulos - Add trans_enum_meta for metadata that happens to be of enum type
## 27/11/2015  John Aynsley, Doulos - Allow single unpacked array dimension in trans_var declaration
## 17/12/2015  John Aynsley, Doulos - Minor cosmetic surgery on the source code
## 18/12/2015  John Aynsley, Doulos - Eliminated the <agent>_env directory and the <agent>_env_pkg. There is now only an <agent>_pkg.
##                                    Now only 1 pkg per UVC. Also scrapped subs gen_regmodel_pkg and gen_regmodel_env
## 19/12/2015  John Aynsley, Doulos - Made coverage object available to both coverage subscribers (agent and register), which also now contain a build_phase method
## 19/12/2015  John Aynsley, Doulos - Use coverage_enable to condition the calling of sample(), not the instantiation of a subscriber for an agent
## 19/12/2015  John Aynsley, Doulos - Move code executed after parsing control files to separate subs
## 20/12/2015  John Aynsley, Doulos - Removed the unused dut_inc_path and inc_file code
## 23/12/2015  John Aynsley, Doulos - Permit / in include filenames so that ./include can be structured into subdirectories
## 11/01/2016  John Aynsley, Doulos - Permit trans_var/trans_meta = // SystemVerilog comment
## 20/01/2016  John Aynsley, Doulos - Insert agent_copy_config_vars inc file only once if number_of_instances > 1, which can thus copy vars for multiple config objects
## 21/01/2016  John Aynsley, Doulos - Add dual_top and split_transactors to support acceleration/emulation-ready environments
## 01/02/2016  John Aynsley, Doulos - Add timeunit and timeprecision to interfaces (was previously only inserted in modules)
## 15/02/2016  John Aynsley, Doulos - Fix bug related to print_structure - %env_agents needs to store a copy of @additional_agents, not a \reference
## 15/02/2016  John Aynsley, Doulos - Add top_env_generate_run_phase (default yes)
## 15/02/2016  John Aynsley, Doulos - Add generate_file_header and file_header_inc
## 15/02/2016  John Aynsley, Doulos - Clean up auto-generated file header to only write out lines that are defined
## 17/02/2016  John Aynsley, Doulos - Add adapter_generate_methods_inside/after_class and adapter_inc_before/inside/after class
## 18/02/2016  John Aynsley, Doulos - Add nested_config_objects
## 18/02/2016  John Aynsley, Doulos - Add top_env_config_append_to_new
## 18/02/2016  John Aynsley, Doulos - Add top_env_config_generate_methods_inside/after_class
## 18/02/2016  John Aynsley, Doulos - Add agent_config_generate_methods_inside/after_class
## 18/02/2016  John Aynsley, Doulos - Add tb_generate_run_test
## 08/03/2016  John Aynsley, Doulos - Add -s command line switch to override syosil_scoreboard_src_path setting in common template
## 31/03/2016  John Aynsley, Doulos - Permit end-of-line comment with DEC in pinlist file
## 31/03/2016  John Aynsley, Doulos - Fix bug with trailing comments after last port connection in pinlist file
## 31/03/2016  John Aynsley, Doulos - Add calls to .set_item_context() before randomizing sequence objects to ensure random stability
## 05/04/2016  John Aynsley, Doulos - Replace -f with -F in Riviera script
## 06/04/2016  John Aynsley, Doulos - Modify compile_riviera.do script to compile everything UVM with a single call to alog
## 15/04/2016  John Aynsley, Doulos - Add tb_prepend_to_initial and tb_inc_before_run_test
## 15/04/2016  John Aynsley, Doulos - Add generate_interface_instance = no (interface instance not generated and vif not assigned)
## 15/04/2016  John Aynsley, Doulos - Add byo_interface
## 15/04/2016  John Aynsley, Doulos - Allow user-defined interface instance names in the pinlist file
## 15/04/2016  John Aynsley, Doulos - Changed "virtual interface is not set!" report from FATAL to WARNING - because might have a parameterized interface
## 12/05/2016  John Aynsley, Doulos - Allow multiple +uvm_cmdline settings to apply additively
## 27/05/2016  John Aynsley, Doulos - Don't generate empty build_phase method for monitor
## 27/05/2016  John Aynsley, Doulos - Modify compile_riviera.do script to use the UVM 1.2 library supplied with Riviera
## 11/08/2016  John Aynsley, Doulos - Fix serious bug - the default env sequence was not being started for an agent that accessed a register model
## 05/10/2016  John Aynsley, Doulos - Don't use the monitor's analysis port outside of the agent. Use the agent's analysis port instead.
## 07/10/2016  John Aynsley, Doulos - Move assignment to m_item in function <agent>_coverage::write
## 07/10/2016  John Aynsley, Doulos - Move lines around in generated code for top_default_sequence 
## 07/10/2016  John Aynsley, Doulos - Add an m_config member to every ${agent_name}_env_default_seq register sequence and assign before start
## 10/10/2016  John Aynsley, Doulos - Add an m_config member to every ${agent_name}_default_seq and assign before start
## 10/10/2016  John Aynsley, Doulos - Add an m_config member to every driver and monitor and assign in agent::connect


## Easier UVM Generator

use strict;
use warnings;
require 5.8.0;

use File::Copy::Recursive qw(dircopy);
use File::Copy "cp";
use File::stat;

my $VERNUM = "2017-01-19";

# Subroutine prototypes:
sub  parse_cmdline;
sub  usage;
sub  parse_common;
sub  after_parse_common;
sub  parse_reg_template;
sub  parse_template;
sub  after_parse_template;
sub  check_file;
sub  check_inc_file;
sub  check_common_pkg;
sub  check_common_env_pkg;
sub  gen_bfm;
sub  gen_if;
sub  gen_seq_item;
sub  gen_driver;
sub  gen_monitor;
sub  gen_sequencer;
sub  gen_config;
sub  gen_cov;
sub  gen_agent;
sub  gen_env;
sub  gen_seq_lib;
sub  gen_env_seq_lib;
sub  gen_agent_pkg;
sub  gen_top_pkg;
sub  gen_dut_inst;
sub  gen_top;
sub  gen_port_converter;
sub  gen_ref_model;
sub  gen_top_env;
sub  gen_top_config;
sub  gen_top_seq_lib;
sub  gen_top_test;
sub  gen_regmodel_adapter;
sub  gen_regmodel_coverage;
sub  gen_regmodel_seq_lib;
sub  gen_questa_script;
sub  gen_vcs_script;
sub  gen_ius_script;
sub  gen_riviera_script;
sub  gen_compile_file_list;
sub  get_pkg_name;
sub  write_file_header;


# Scalar Variables:
my $agent_has_env;
my $agent_if;
my $agent_item;
my $agent_name;
my $agent_reset;
my $agent_seqr_class;
my $aname;
my $argnum;
my $author;
my $backup;
my $common_pkg;
my $common_pkg_fname;
my $common_env_pkg;
my $common_env_pkg_fname;
my $common_tpl_fname;
my $company;
my $continue_on_warning;
my $copyright;
my $date;
my $dept;
my $dir1;
my $dir2;
my $dir;
my $dual_top;
my $dut_iname;
my $dut_path;
my $dut_pfile;
my $dut_tb_dir;
my $dut_tb_path;
my $dut_top;
my $ele;
my $email;
my $env_clock_list;
my $env_reset_list;
my $field;
my $file_header_inc;
my $flag_dut_source_path;
my $flag_inc_path;
my $flag_project;
my $flag_regmodel_file;
my $flag_x;
my $flag_nopack;
my $comments_at_include_locations;
my $generate_file_header;
my $nested_config_objects;
my $i;
my $inc_file;
my $inc_path;
my $incdir;
my $name;
my $pf;
my $port_decl;
my $project;
my $reg_template;
my $regmodel;
my $regmodel_file;
my $split_transactors;
my $syosil_scoreboard_src_path;
my $top_reg_block_type;
my $tbname;
my $tb_inc_before_run_test;
my $tb_inc_before_run_test_inline;
my $tb_inc_inside_module;
my $tb_inc_inside_inline;
my $tb_generate_run_test;
my $tb_module_name;
my $tb_prepend_to_initial;
my $tb_prepend_to_initial_inline;
my $th_module_name;
my $tel;
my $template_list;
my $template_name;
my $th_generate_clock_and_reset;
my $th_inc_inside_module;
my $th_inc_inside_inline;
my $timeunit;
my $timeprecision;
my $test_generate_methods_inside_class;
my $test_generate_methods_after_class;
my $test_inc_before_class;
my $test_inc_before_inline;
my $test_inc_inside_class;
my $test_inc_inside_inline;
my $test_inc_after_class;
my $test_inc_after_inline;
my $test_prepend_to_build_phase;
my $test_prepend_to_build_phase_inline;
my $test_append_to_build_phase;
my $test_append_to_build_phase_inline;
my $top_env_config_append_to_new;
my $top_env_config_append_to_new_inline;
my $top_env_config_generate_methods_inside_class;
my $top_env_config_generate_methods_after_class;
my $top_default_seq_count;
my $top_env_config_inc_before_class;
my $top_env_config_inc_before_inline;
my $top_env_config_inc_inside_class;
my $top_env_config_inc_inside_inline;
my $top_env_config_inc_after_class;
my $top_env_config_inc_after_inline;
my $top_env_generate_methods_inside_class;
my $top_env_generate_methods_after_class;
my $top_env_generate_end_of_elaboration;
my $top_env_generate_run_phase;
my $top_env_inc_before_class;
my $top_env_inc_before_inline;
my $top_env_inc_inside_class;
my $top_env_inc_inside_inline;
my $top_env_inc_after_class;
my $top_env_inc_after_inline;
my $top_env_prepend_to_build_phase;
my $top_env_prepend_to_build_phase_inline;
my $top_env_append_to_build_phase;
my $top_env_append_to_build_phase_inline;
my $top_env_append_to_connect_phase;
my $top_env_append_to_connect_phase_inline;
my $top_env_append_to_run_phase;
my $top_env_append_to_run_phase_inline;
my $top_seq_inc;
my $top_seq_inc_inline;
my $uvm_cmdline;
my $uvm_reg_addr;
my $uvm_reg_data;
my $uvm_reg_kind;
my $var_decl;
my $year;
my $version;

# Hash Variables
my %agent_adapter_generate_methods_inside_class;
my %agent_adapter_generate_methods_after_class;
my %agent_adapter_inc_before_class;
my %agent_adapter_inc_before_inline;
my %agent_adapter_inc_inside_class;
my %agent_adapter_inc_inside_inline;
my %agent_adapter_inc_after_class;
my %agent_adapter_inc_after_inline;
my %agent_append_to_build_phase;
my %agent_append_to_build_phase_inline;
my %agent_append_to_connect_phase;
my %agent_append_to_connect_phase_inline;
my %agent_checks_enable;
my %agent_config_generate_methods_inside_class;
my %agent_config_generate_methods_after_class;
my %agent_config_inc_before_class;
my %agent_config_inc_before_inline;
my %agent_config_inc_inside_class;
my %agent_config_inc_inside_inline;
my %agent_config_inc_after_class;
my %agent_config_inc_after_inline;
my %agent_copy_config_vars;
my %agent_copy_config_vars_inline;
my %agent_cover_generate_methods_inside_class;
my %agent_cover_generate_methods_after_class;
my %agent_cover_inc;
my %agent_cover_inc_inline;
my %agent_cover_inc_before_class;
my %agent_cover_inc_before_inline;
my %agent_cover_inc_inside_class;
my %agent_cover_inc_inside_inline;
my %agent_cover_inc_after_class;
my %agent_cover_inc_after_inline;
my %agent_coverage_enable;
my %agent_driv_inc;
my %agent_driv_inc_inline;
my %agent_driv_inc_before_class;
my %agent_driv_inc_before_inline;
my %agent_driv_inc_inside_class;
my %agent_driv_inc_inside_inline;
my %agent_driv_inc_after_class;
my %agent_driv_inc_after_inline;
my %agent_env_prepend_to_build_phase;
my %agent_env_prepend_to_build_phase_inline;
my %agent_env_append_to_build_phase;
my %agent_env_append_to_build_phase_inline;
my %agent_env_append_to_connect_phase;
my %agent_env_append_to_connect_phase_inline;
my %agent_env_generate_methods_inside_class;
my %agent_env_generate_methods_after_class;
my %agent_env_inc_before_class;
my %agent_env_inc_before_inline;
my %agent_env_inc_inside_class;
my %agent_env_inc_inside_inline;
my %agent_env_inc_after_class;
my %agent_env_inc_after_inline;
my %agent_env_seq_inc;
my %agent_env_seq_inc_inline;
my %agent_factory_set;
my %agent_generate_methods_inside_class;
my %agent_generate_methods_after_class;
my %agent_is_active;
my %agent_inc_before_class;
my %agent_inc_before_inline;
my %agent_inc_inside_class;
my %agent_inc_inside_inline;
my %agent_inc_after_class;
my %agent_inc_after_inline;
my %agent_inc_inside_bfm;
my %agent_inc_inside_bfm_inline;
my %agent_mon_inc;
my %agent_mon_inc_inline;
my %agent_mon_inc_before_class;
my %agent_mon_inc_before_inline;
my %agent_mon_inc_inside_class;
my %agent_mon_inc_inside_inline;
my %agent_mon_inc_after_class;
my %agent_mon_inc_after_inline;
my %agent_parent;
my %agent_prepend_to_build_phase;
my %agent_prepend_to_build_phase_inline;
my %agent_seq_inc;
my %agent_seq_inc_inline;
my %agent_seqr_inc_before_class;
my %agent_seqr_inc_before_inline;
my %agent_seqr_inc_inside_class;
my %agent_seqr_inc_inside_inline;
my %agent_seqr_inc_after_class;
my %agent_seqr_inc_after_inline;
my %agent_item_types;
my %agent_trans_generate_methods_inside_class;
my %agent_trans_generate_methods_after_class;
my %agent_trans_inc_before_class;
my %agent_trans_inc_before_inline;
my %agent_trans_inc_inside_class;
my %agent_trans_inc_inside_inline;
my %agent_trans_inc_after_class;
my %agent_trans_inc_after_inline;
my %agent_type_by_inst;
my %bus2reg_map;
my %byo_interface;
my %enum_var_types;
my %env_agents;
my %generate_interface_instance;
my %if_inc_inside_interface;
my %if_inc_inside_inline;
my %if_instance_names;    # Used to identify instances in the dut_pfile (the pinlist)
my %number_of_instances;  # Number of instances required of each agent/interface
my %reg_access_block_type;      # Type of uvm_reg_block class containing registers
my %reg_access_instance;  # Object path of uvm_reg_block class containing registers, appended to regmodel. Should be an empty string or start with a dot
my %reg_access_map;       # Instance of map within uvm_reg_block
my %reg_access_mode;      # Register access mode WR WO RO
my %reg_cover_generate_methods_inside_class;
my %reg_cover_generate_methods_after_class;
my %reg_cover_inc;
my %reg_cover_inc_inline;
my %reg_cover_inc_before_class;
my %reg_cover_inc_before_inline;
my %reg_cover_inc_inside_class;
my %reg_cover_inc_inside_inline;
my %reg_cover_inc_after_class;
my %reg_cover_inc_after_inline;
my %ref_model;
my %ref_model_inputs;
my %ref_model_outputs;
my %ref_model_compare_method;
my %ref_model_inc_before_class;
my %ref_model_inc_before_inline;
my %ref_model_inc_inside_class;
my %ref_model_inc_inside_inline;
my %ref_model_inc_after_class;
my %ref_model_inc_after_inline;
my %top_factory_set;
my %tpl_fname;
my %unpacked_bound;

# Array Variables
my @additional_agents;
my @agent_clock_array;
my @agent_instance_names;
my @agent_list;      # Array of all agent names
my @agent_port_array;
my @agent_reset_array;
my @agent_var_array;
my @agent_enum_array;
my @agent_meta_array;
my @agent_var_cnstr_array;
my @all_agent_ifs;   # Array of all interface names, including the _if suffix (not the interface instance names)
my @clist;
my @common_config_var_array;
my @config_var_array;
my @elist;
my @env_list;
my @fields;
my @inc_path_list;
my @list;
my @all_tx_vars;
my @non_local_tx_vars;
my @non_meta_tx_vars;
my @non_reg_env;
my @reg_env;
my @rlist;
my @stand_alone_agents;
my @top_env_agents;


open( LOGFILE, ">easier_uvm_gen.log" );
print LOGFILE "\nEasier UVM Code Generator version ${VERNUM}"
  . " (Send feedback to info\@doulos.com)\n";

set_default_values();
parse_cmdline();
parse_common();
after_parse_common();
deal_with_deprecated_reg_template();
handle_minus_x_flag();

#Only print this message after calling handle_minus_x_flag() in case handle_minus_x_flag() prints out one of the paths and exits the script
print "Easier UVM Code Generator version ${VERNUM}\n";

check_common_pkg($common_pkg_fname) if $common_pkg_fname;
check_common_env_pkg($common_env_pkg_fname) if $common_env_pkg_fname;

create_directories_and_copy_files();

# Process the agent templates (@list created by parse_cmdline)
print LOGFILE "\nParsing Templates ...\n\n";
foreach my $i ( 0 .. @list - 1) {
    if ( $list[$i] ne "" ) {
        $template_name = $list[$i];
        printf LOGFILE "Reading[$i]: $list[$i]\n";

        parse_template();
        after_parse_template();

        # Make the per-agent directories
        $dir = "${project}/tb/${agent_name}";
        printf LOGFILE "dir: $dir\n";
        mkdir( $dir,         0755 );
        mkdir( $dir . "/sv", 0755 );
        print LOGFILE "Writing code to files\n";

        # Create the agent files
        gen_if();
        if ( $split_transactors eq "YES") {
          gen_bfm();
        }
        gen_seq_item();
        gen_config();
        gen_driver();
        gen_monitor();
        gen_sequencer();
        gen_cov();
        gen_agent();
        gen_seq_lib();

        # Do not generate env or env_seq_lib if regmodel used or $agent_has_env = no
        do {
            gen_env();
            gen_env_seq_lib();
        } unless ( exists $reg_access_mode{$agent_name} ) or $agent_has_env eq "NO";

        gen_agent_pkg();
    }
}
if ( $regmodel eq 1 ) {
    gen_regmodel_pkg();

    foreach my $agent ( keys(%reg_access_mode) ) {
        $agent_name = $agent;
        gen_env();
        gen_regmodel_adapter();
        gen_regmodel_coverage();
        gen_regmodel_seq_lib();
    }
}

extra_checking_for_additional_agents();

print LOGFILE "top env agents = @top_env_agents\n";
print LOGFILE "Generating testbench in ${project}/tb\n";
print "Generating testbench in         ${project}/tb\n";

gen_top_config();
gen_port_converter();

foreach my $ref_model_name ( keys(%ref_model) ) {
    gen_ref_model($ref_model_name);
}

gen_top_env();
gen_top_seq_lib();
gen_top_pkg();
gen_top_test();
gen_top();

print "Generating simulator scripts in ${project}/sim\n";
print LOGFILE "Generating simulator scripts in ${project}/sim\n";

deal_with_files_f();

gen_questa_script();
gen_vcs_script();
gen_ius_script();
gen_riviera_script();

print_structure();

print LOGFILE "Code Generation complete\n";


# ---------- Subroutines -------------------------------------------------

sub set_default_values {

    $date       = localtime;
    $project    = "generated_tb";
    $backup     = "yes";
    $version    = "1.0";
    $inc_path   = "include";
    $inc_file   = "";
    $dut_path   = "dut";
    $common_pkg = "";
    $common_pkg_fname     = "";
    $common_env_pkg       = "";
    $common_env_pkg_fname = "";
    $common_tpl_fname     = "common.tpl";

    $agent_name     = "";
    $agent_if       = "";
    $agent_item     = "";
    $dut_iname      = "uut";    #instance name of dut in tb
    $timeunit       = "1ns";
    $timeprecision  = "1ps";
    $regmodel       = 0;
    $dut_top        = "";          #top level dut module
    $dut_pfile      = "pinlist";   #dut port list file
    $uvm_cmdline    = "";
    $top_default_seq_count = undef;

    $env_reset_list = "";
    $env_clock_list = "";
    $tbname         = undef;

    $regmodel_file  = "regmodel.sv";
    $top_reg_block_type  = undef;

    $syosil_scoreboard_src_path = undef;

    $template_name  = "example.tpl";    #default template name
    $template_list  = "";               #default template list
    $reg_template   = undef;
    
    $dual_top          = "NO";
    $split_transactors = "NO";
}

sub parse_cmdline {
    print LOGFILE "\nParsing cmdline ...\n\n";
    print LOGFILE "num args is " . $#ARGV . "\n";
    if ( $#ARGV == -1 ) { usage(); }    ### no arguments, print help and exit
    ###if ($ARGV[$argnum] =~ m/\s*help/i)
    if ( $ARGV[0] =~ m/\s*(-help|-hel|-he|-h)/i ) {
        usage();
    }
    my $pnum_c = -2;
    my $pnum_r = -2;
    my $pnum_p = -2;
    my $pnum_m = -2;
    my $pnum_s = -2;
    my $pnum_n = -2;
    $continue_on_warning = 0;

    # Searching for -x dut_source_path, -x inc_path, and -x project flag
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-x)/i ) {
            if ( $ARGV[ $argnum + 1 ] eq "dut_source_path" ) {
                $flag_x = 1;
                $flag_dut_source_path = 1;
            }
            if ( $ARGV[ $argnum + 1 ] eq "inc_path" ) {
                $flag_x = 1;
                $flag_inc_path = 1;
            }
            if ( $ARGV[ $argnum + 1 ] eq "project" ) {
                $flag_x = 1;
                $flag_project = 1;
            }
            if ( $ARGV[ $argnum + 1 ] eq "regmodel_file" ) {
                $flag_x = 1;
                $flag_regmodel_file = 1;
            }
        }
    }

    # Searching for "continue on critical warnings" flag
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-c)/i ) {
            $pnum_c = $argnum;
            $continue_on_warning = 1;
            printf LOGFILE "Code generation will continue if critical warnings are issued\n";
            printf LOGFILE "pnum_c: $pnum_c\n";
        }
    }

    # Searching for register flag
    printf LOGFILE "Searching for regmodel flag\n";
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-r)/i ) {
            $regmodel = 1;
            $pnum_r   = $argnum;
            printf LOGFILE
              "regmodel: $regmodel, Register layer will be included\n";
            printf LOGFILE "pnum_r: $pnum_r\n";
        }
    }

    # Searching for project name
    printf LOGFILE "Searching for prefix\n";
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-p)/i ) {
            $tbname = $ARGV[ $argnum + 1 ];
            $pnum_p = $argnum;
            printf LOGFILE "prefix: $tbname\n";
            printf LOGFILE "pnum_p: $pnum_p\n";
        }
    }

    # Searching for common template filename
    printf LOGFILE "Searching for common template\n";
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-m)/i ) {
            $common_tpl_fname = $ARGV[ $argnum + 1 ];
            $pnum_m  = $argnum;
            printf LOGFILE "common_tpl_fname: $common_tpl_fname\n";
            printf LOGFILE "pnum_m: $pnum_m\n";
        }

    }

    # Searching for Syosil scoreboard path
    printf LOGFILE "Searching for Syosil scoreboard path\n";
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-s)/i ) {
            $syosil_scoreboard_src_path = $ARGV[ $argnum + 1 ];
            $pnum_s = $argnum;
            printf LOGFILE "syosil_scoreboard_src_path: $syosil_scoreboard_src_path\n";
            printf LOGFILE "pnum_s: $pnum_s\n";
        }
    }

    # Searching for -nopack flag
    foreach $argnum ( 0 .. $#ARGV) {
        if ( $ARGV[$argnum] =~ m/\s*(-nopack)/i ) {
            $flag_nopack = 1;
            $pnum_n = $argnum;
        }
    }

    # searching for template (agent) names
    printf LOGFILE "Searching for templates\n";
    foreach $argnum ( 0 .. $#ARGV) {

        if ( $argnum != $pnum_c &&
             $argnum != $pnum_r &&
             $argnum != $pnum_p && $argnum != $pnum_p + 1 &&
             $argnum != $pnum_m && $argnum != $pnum_m + 1 &&
             $argnum != $pnum_s && $argnum != $pnum_s + 1 &&
             $argnum != $pnum_n ) {

            #check for template name
            if ( $ARGV[$argnum] =~
                m/\s*(-template|-templat|-templa|-templ|-tem|-te|-t)/i )
            {
                print LOGFILE "template: $ARGV[$argnum]\n";
            }
            else {
                if ( $ARGV[$argnum] ne "reg.tpl" ) {
                    $template_list = "$template_list $ARGV[$argnum]";

                    #print LOGFILE "T_List: $template_list\n";
                }
                else {
                    $reg_template = $ARGV[$argnum];
                }
            }

            print LOGFILE "T_List: $template_list\n";
            if ( $ARGV[$argnum] =~ m/\s*(-help|-hel|-he|-h)/i ) {
                usage();
            }
        }
        @list = split /\s+/, $template_list;
        foreach $i ( 0 .. @list-1 ) {
            if ( $list[$i] ne "" ) {
                printf LOGFILE "List: $list[$i]\n";
            }
        }
    }
    @list or die "ERROR! You must specify at least 1 template file)\n";
}

sub usage {
    print "\n";
    print "USAGE: perl easier_uvm_gen.pl [-t] <filename> <filename> ...     list of template file names\n";
    print "\n";
    print "       -p <top>            Prefix used to construct names associated with top-level env, default is top\n";
    print "       -m <filename>       Path to common template file, default is common.tpl\n";
    print "       -s <path>           Path to source files for Syosil scoreboard (overrides syosil_scoreboard_src_path in common template)\n";
    print "       -c                  The code generator will continue after warnings\n";
    print "       -r                  Causes a register model to be instantiated in the generated code (switch is no longer necessary}\n";
    print "       -x dut_source_path  Returns the value of the dut_source_path setting\n";
    print "       -x inc_path         Returns the value of the inc_path setting\n";
    print "       -x project          Returns the value of the project setting\n";
    print "       -x regmodel_file    Returns the value of the regmodel_file setting\n";
    print "       -nopack             Suppresses generation of do_pack & do_unpack methods for backward compatibility\n";
    print "\n";
    exit;
}    # end sub usage

sub parse_common {
    my $template_name = $common_tpl_fname;
    @common_config_var_array   = ();

    open( TH, $template_name )
      || die "Exiting due to Error: can't open template: ${template_name}\n";
    print LOGFILE "Parsing common : $template_name ...\n\n";

    for ( ; ; ) {
        my $line;
        undef $!;
        unless ( defined( $line = <TH> ) ) {
            die $! if $!;
            last;    # reached EOF
        }

        next if ( $line =~ m/^\s*#/ );    #comment line starts with "#"
        next if ( $line =~ m/^\s+$/ );    #blank line

        $line =~ s/(^.*?)#.*/$1/;         #delete trailing comments

        $line =~ /^\s*(\w+)\s*=\s*(.+?)\s*$/
          or die "Exiting due to Error: bad entry in line $. of ${common_tpl_fname}: $line\n";
        my $param_name  = $1;
        my $param_value = $2;

        #check for dut path
        if ( $param_name =~ /dut_source_path/i ) {
            $dut_path = $param_value;
            print LOGFILE "dut_path: $dut_path\n";
        }

        #check for include paths
        if ( $param_name =~ /^\s*inc_path/i ) {
            $inc_path = $param_value;
        }

        #check for project
        if ( $param_name =~ /project/i ) {
            $project = $param_value;
            print LOGFILE "Project: $project\n";
        }

        #check for regmodel file
        if ( $param_name =~ /regmodel_file/i) {
            unless (defined($flag_x)) {
                    check_file($param_value);
            }
            $regmodel_file = $param_value;
            print LOGFILE "regmodel_file: $regmodel_file\n";
        }

        #check for top-level regmodel type
        if ( $param_name =~ /top_reg_block_type/i) {
            $top_reg_block_type = $param_value;
            print LOGFILE "top_reg_block_type: $top_reg_block_type\n";
        }

        # Don't parse the rest of the settings if called with the -x switch
        unless (defined($flag_x)) {

        if ( $param_name =~ /prefix/i ) {
            unless ( defined $tbname ) {
                $tbname = $param_value;
                print LOGFILE "Prefix: $tbname\n";
            }
        }

        if ( $param_name =~ /backup/i ) {
            $backup = uc $param_value;
            print LOGFILE "Backup: $backup\n";
        }

        if ( $param_name =~ /comments_at_include_locations/i ) {
            $comments_at_include_locations = uc $param_value;
            print LOGFILE "comments_at_include_locations = $comments_at_include_locations\n";
        }

        if ( $param_name =~ /copyright/i ) {
            $copyright = $param_value;
            print LOGFILE "$copyright\n";
        }

        if ( $param_name =~ /^\s*name/i ) {
            $author = $param_value;
            print LOGFILE "Name: $author\n";
        }

        if ( $param_name =~ /email/i ) {
            $email = $param_value;
            print LOGFILE "email: $email\n";
        }

        if ( $param_name =~ /tel/i ) {
            $tel = $param_value;
            print LOGFILE "Tel: $tel\n";
        }

        if ( $param_name =~ /dept/i ) {
            $dept = $param_value;
            print LOGFILE "dept: $dept\n";
        }

        if ( $param_name =~ /company/i ) {
            $company = $param_value;
            print LOGFILE "company: $dept\n";
        }

        if ( $param_name =~ /year/i ) {
            $year = $param_value;
            print LOGFILE "year: $year\n";
        }

        if ( $param_name =~ /version/i ) {
            $version = $param_value;
            print LOGFILE "version : $version\n";
        }

        if ( $param_name =~ /dut_top/i ) {
            $dut_top = $param_value;
            print LOGFILE "dut_top: $dut_top\n";
        }

        if ( $param_name =~ /dut_iname/i ) {
            $dut_iname = $param_value;
            print LOGFILE "dut instance name: $dut_iname\n";
        }

        if ( $param_name =~ /dut_pfile/i ) {
            $dut_pfile = $param_value;
            print LOGFILE "dut_pfile: $dut_pfile\n";
        }

        if ( $param_name =~ /timeunit/i ) {
            $timeunit = $param_value;
            print LOGFILE "timeunit: $timeunit\n";
        }

        if ( $param_name =~ /timeprecision/i ) {
            $timeprecision = $param_value;
            print LOGFILE "timeprecision: $timeprecision\n";
        }

        if ( $param_name =~ /uvm_cmdline/i ) {
            $uvm_cmdline = $uvm_cmdline ? "$uvm_cmdline $param_value" : $param_value;
            print LOGFILE "uvm_cmdline: $uvm_cmdline\n";
        }

        if ( $param_name =~ /nested_config_objects/i ) {
            $nested_config_objects = uc $param_value;
            print LOGFILE "nested_config_objects = $param_value\n";
        }

        if ( $param_name =~ /common_pkg/i ) {
            $common_pkg_fname = $param_value;
            print LOGFILE "common package file name: $common_pkg_fname\n";
        }

        if ( $param_name =~ /common_env_pkg/i ) {
            $common_env_pkg_fname = $param_value;
            print LOGFILE "common env package file name: $common_env_pkg_fname\n";
        }

        if ( $param_name =~ /tb_inc_inside_module/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $tb_inc_inside_module = $1;
            $tb_inc_inside_inline = $3 if ($3);
            print LOGFILE "tb_inc_inside_module = $param_value\n";
        }

        if ( $param_name =~ /tb_inc_before_run_test/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $tb_inc_before_run_test = $1;
            $tb_inc_before_run_test_inline = $3 if ($3);
            print LOGFILE "tb_inc_before_run_test = $param_value\n";
        }

        if ( $param_name =~ /tb_prepend_to_initial/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $tb_prepend_to_initial        = $1;
            $tb_prepend_to_initial_inline = $3 if ($3);
            print LOGFILE "tb_prepend_to_initial = $param_value\n";
        }

        if ( $param_name =~ /tb_generate_run_test/i ) {
            $tb_generate_run_test = uc $param_value;
            print LOGFILE "tb_generate_run_test = $param_value\n";
        }

        if ( $param_name =~ /th_generate_clock_and_reset/i ) {
            $th_generate_clock_and_reset = uc $param_value;
            print LOGFILE "th_generate_clock_and_reset = $param_value\n";
        }

        if ( $param_name =~ /th_inc_inside_module/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $th_inc_inside_module = $1;
            $th_inc_inside_inline = $3 if ($3);
            print LOGFILE "th_inc_inside_module = $param_value\n";
        }

        if ( $param_name =~ /generate_file_header/i ) {
            $generate_file_header = uc $param_value;
            print LOGFILE "generate_file_header = $param_value\n";
        }

        if ( $param_name =~ /file_header_inc/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $file_header_inc = $1;
            print LOGFILE "file_header_inc = $param_value\n";
        }

        if ( $param_name =~ /test_generate_methods_inside_class/i ) {
            $test_generate_methods_inside_class = uc $param_value;
            print LOGFILE "test_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /test_generate_methods_after_class/i ) {
            $test_generate_methods_after_class = uc $param_value;
            print LOGFILE "test_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /test_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $test_inc_before_class = $1;
            $test_inc_before_inline = $3 if ($3);
            print LOGFILE "test_inc_before_class = $param_value\n";
        }
        if ( $param_name =~ /test_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $test_inc_inside_class = $1;
            $test_inc_inside_inline = $3 if ($3);
            print LOGFILE "test_inc_inside_class = $param_value\n";
        }
        if ( $param_name =~ /test_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $test_inc_after_class = $1;
            $test_inc_after_inline = $3 if ($3);
            print LOGFILE "test_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /test_prepend_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $test_prepend_to_build_phase = $1;
            $test_prepend_to_build_phase_inline = $3 if ($3);
            print LOGFILE "test_prepend_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /test_append_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $test_append_to_build_phase = $1;
            $test_append_to_build_phase_inline = $3 if ($3);
            print LOGFILE "test_append_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_generate_methods_inside_class/i ) {
            $top_env_generate_methods_inside_class = uc $param_value;
            print LOGFILE "top_env_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /top_env_generate_methods_after_class/i ) {
            $top_env_generate_methods_after_class = uc $param_value;
            print LOGFILE "top_env_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /top_env_generate_end_of_elaboration/i ) {
            $top_env_generate_end_of_elaboration = uc $param_value;
            print LOGFILE "top_env_generate_end_of_elaboration = $param_value\n";
        }

        if ( $param_name =~ /top_env_generate_run_phase/i ) {
            $top_env_generate_run_phase = uc $param_value;
            print LOGFILE "top_env_generate_run_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_inc_before_class = $1;
            $top_env_inc_before_inline = $3 if ($3);
            print LOGFILE "top_env_inc_before_class = $param_value\n";
        }
        if ( $param_name =~ /top_env_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_inc_inside_class = $1;
            $top_env_inc_inside_inline = $3 if ($3);
            print LOGFILE "top_env_inc_inside_class = $param_value\n";
        }
        if ( $param_name =~ /top_env_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_inc_after_class = $1;
            $top_env_inc_after_inline = $3 if ($3);
            print LOGFILE "top_env_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /top_env_prepend_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_prepend_to_build_phase = $1;
            $top_env_prepend_to_build_phase_inline = $3 if ($3);
            print LOGFILE "top_env_prepend_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_append_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_append_to_build_phase = $1;
            $top_env_append_to_build_phase_inline = $3 if ($3);
            print LOGFILE "top_env_append_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_append_to_connect_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_append_to_connect_phase = $1;
            $top_env_append_to_connect_phase_inline = $3 if ($3);
            print LOGFILE "top_env_append_to_connect_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_append_to_run_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_append_to_run_phase = $1;
            $top_env_append_to_run_phase_inline = $3 if ($3);
            print LOGFILE "top_env_append_to_run_phase = $param_value\n";
        }

        if ( $param_name =~ /top_env_config_append_to_new/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_config_append_to_new = $1;
            $top_env_config_append_to_new_inline = $3 if ($3);
            print LOGFILE "top_env_config_append_to_new = $param_value\n";
        }

        if ( $param_name =~ /top_env_config_generate_methods_inside_class/i ) {
            $top_env_config_generate_methods_inside_class = uc $param_value;
            print LOGFILE "top_env_config_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /top_env_config_generate_methods_after_class/i ) {
            $top_env_config_generate_methods_after_class = uc $param_value;
            print LOGFILE "top_env_config_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /top_env_config_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_config_inc_before_class = $1;
            $top_env_config_inc_before_inline = $3 if ($3);
            print LOGFILE "top_env_config_inc_before_class = $param_value\n";
        }
        if ( $param_name =~ /top_env_config_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_config_inc_inside_class = $1;
            $top_env_config_inc_inside_inline = $3 if ($3);
            print LOGFILE "top_env_config_inc_inside_class = $param_value\n";
        }
        if ( $param_name =~ /top_env_config_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_env_config_inc_after_class = $1;
            $top_env_config_inc_after_inline = $3 if ($3);
            print LOGFILE "top_env_config_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /top_seq_inc/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
                check_inc_file($1);
            $top_seq_inc = $1;
            $top_seq_inc_inline = $3 if ($3);
            print LOGFILE "top_seq_inc = $param_value\n";
        }

        if ( $param_name =~ /top_default_seq_count/i ) {
            $top_default_seq_count = $param_value;
            print LOGFILE "top_default_seq_count = $param_value\n";
        }

        #check for top-level factory overrides
        if ( $param_name =~ /top_factory_set/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            $top_factory_set{$1} = $3;
            print LOGFILE "top_factory_set = $param_value\n";
        }

        #check for config_var
        if ( $param_name =~ /config_var$/i ) {
            print LOGFILE "config_var: $param_value\n";
            push @common_config_var_array, $param_value;
        }

        #Syosil scoreboard package source file
        if ( $param_name =~ /syosil_scoreboard_src_path/i ) {
            unless ( defined $syosil_scoreboard_src_path ) {
                check_file($param_value);
                $syosil_scoreboard_src_path = $param_value;
                print LOGFILE "syosil_scoreboard_src_path = $param_value\n";
            }
        }

        #check for ref_model inputs
        if ( $param_name =~ /ref_model_input/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $ref_model{$1} ) {
                $ref_model{$1} = 1;
            }
            push @{ $ref_model_inputs{$1} }, $3;
            print LOGFILE "ref_model_input = $1 $3\n";
        }

        #check for ref_model outputs
        if ( $param_name =~ /ref_model_output/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $ref_model{$1} ) {
                $ref_model{$1} = 1;
            }
            push @{ $ref_model_outputs{$1} }, $3;
            print LOGFILE "ref_model_output = $1 $3\n";
        }

        #check for ref_model compare method
        if ( $param_name =~ /ref_model_compare_method/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $ref_model{$1} ) {
                $ref_model{$1} = 1;
            }
            $ref_model_compare_method{$1} = $3;
            print LOGFILE "ref_model_compare_method = $1 $3\n";
        }

        #check for ref_model include files
        if ( $param_name =~ /ref_model_inc_before_class/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            my $ref_model_name = $1;
              check_inc_file($3);
            $ref_model_inc_before_class{$ref_model_name} = $3;
            $ref_model_inc_before_inline{$ref_model_name} = $5 if ($5);
            print LOGFILE "ref_model_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /ref_model_inc_inside_class/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            my $ref_model_name = $1;
              check_inc_file($3);
            $ref_model_inc_inside_class{$ref_model_name} = $3;
            $ref_model_inc_inside_inline{$ref_model_name} = $5 if ($5);
            print LOGFILE "ref_model_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /ref_model_inc_after_class/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)([\w\.]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            my $ref_model_name = $1;
              check_inc_file($3);
            $ref_model_inc_after_class{$ref_model_name} = $3;
            $ref_model_inc_after_inline{$ref_model_name} = $5 if ($5);
            print LOGFILE "ref_model_inc_after_class = $param_value\n";
        }

        #Acceleration-ready transactors
        if ( $param_name =~ /dual_top/i ) {
            $dual_top = uc $param_value;
            print LOGFILE "dual_top = $param_value\n";
        }

        if ( $param_name =~ /split_transactors/i ) {
            $split_transactors = uc $param_value;
            print LOGFILE "split_transactors = $param_value\n";
        }

        }
    }

    unless ( $tbname ) { $tbname = "top"; }
    printf LOGFILE "prefix for top-level names: $tbname\n";

    close TH;

}    #end parse_common

sub after_parse_common {

    if ( defined $top_env_generate_methods_after_class && $top_env_generate_methods_after_class eq "NO" )
    {
        if ( defined $top_env_prepend_to_build_phase ) {
          die "ERROR in ${common_tpl_fname}. top_env_prepend_to_build_phase cannot be used in combination with top_env_generate_methods_after_class = no";
        }
        if ( defined $top_env_append_to_build_phase ) {
          die "ERROR in ${common_tpl_fname}. top_env_append_to_build_phase cannot be used in combination with top_env_generate_methods_after_class = no";
        }
        if ( defined $top_env_append_to_connect_phase ) {
          die "ERROR in ${common_tpl_fname}. top_env_append_to_connect_phase cannot be used in combination with top_env_generate_methods_after_class = no";
        }
        if ( defined $top_env_append_to_run_phase ) {
          die "ERROR in ${common_tpl_fname}. top_env_append_to_run_phase cannot be used in combination with top_env_generate_methods_after_class = no";
        }
    }

    if ( defined $test_generate_methods_after_class && $test_generate_methods_after_class eq "NO" )
    {
        if ( defined $test_prepend_to_build_phase )
        {
          die "ERROR in ${common_tpl_fname}. test_prepend_to_build_phase cannot be used in combination with test_generate_methods_after_class = no";
        }
        if ( defined $test_append_to_build_phase )
        {
          die "ERROR in ${common_tpl_fname}. test_append_to_build_phase cannot be used in combination with test_generate_methods_after_class = no";
        }
    }

    if ( $split_transactors eq "YES" ) {
        $dual_top = "YES";
    }
}

sub deal_with_deprecated_reg_template {

    if (defined($flag_regmodel_file)) {
        # With -x regmodel_file, force the script to read the deprecated register model template file reg.tpl if it exists
        $reg_template = "reg.tpl";
    }

    parse_reg_template() if ( defined $reg_template and -e $reg_template );

    if ( $regmodel ) {
        unless ( defined $top_reg_block_type ) {
            warning_prompt("-r switch given on command line but top-level regmodel block type has not been set");
        }
    }

    # The -r switch has been made optional: instantiation of the register model will be forced in the presence of top_reg_block_type (or regmodel_name in reg.tpl)
    if ( defined $top_reg_block_type ) {
        $regmodel = 1
    }
    print LOGFILE "\$regmodel = $regmodel\n";
}

sub parse_reg_template {

#    print "Register template file reg.tpl still works but is deprecated. Use top_reg_block_type in the common template file and reg_access_block_type in the interface template files instead\n";
    print LOGFILE "\nParsing reg.tpl ...\n\n";

    open( TH, $reg_template )
      || die "Exiting due to Error: can't open template: ${reg_template}\n";

    for ( ; ; ) {
        my $line;
        undef $!;
        unless ( defined( $line = <TH> ) ) {
            die $! if $!;
            last;    # reached EOF
        }

        #next if ($line =~ m/^#/); #comment line starts with "#"
        next if ( $line =~ m/\s*#/ );       #comment line starts with "#"
        next if ( $line =~ m/^\s\s*$/ );    #blank line

        $line =~ /^\s*(\w+)\s*=\s*(.+?)\s*$/
          or die "Exiting due to Error: bad entry in line $. of ${reg_template}: $line\n";
        my $param_name  = $1;
        my $param_value = $2;

        #check for sub-blocks
        if ( $param_name =~ /rm_sub_block/i or $param_name =~ /regmodel_sub_block/i) {

            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${reg_template}: $line\n";

            $reg_access_block_type{$3} = $1;
        }

        #check for register model
        if ( $param_name =~ /rm_name/i or $param_name =~ /regmodel_name/i ) {

            unless ( defined $top_reg_block_type and $top_reg_block_type ne $param_value) {
                $top_reg_block_type = $param_value;
            }
            else {
                warning_prompt("Top-level regmodel block type set to $param_value in ${reg_template} but already set to $top_reg_block_type");
            }
            print LOGFILE "regmodel_name: $top_reg_block_type\n";
        }

        #check for regmodel file
        if ( $param_name =~ /rm_file/i or $param_name =~ /regmodel_file/i) {
                check_file($param_value);
            unless ( $param_value ne $regmodel_file and $regmodel_file ne "regmodel.sv" ) {
                $regmodel_file = $param_value;
            }
            else {
                warning_prompt("regmodel_file set to $param_value in ${reg_template} but already set to $regmodel_file");
            }
            print LOGFILE "regmodel_file: $regmodel_file\n";
        }
    }
    print LOGFILE "\n";

    close TH;
}    #end parse_reg_template


sub handle_minus_x_flag {

    if (defined($flag_dut_source_path)) {
        print $dut_path . "\n";
        exit;
    }
    if (defined($flag_inc_path)) {
        print $inc_path . "\n";
        exit;
    }
    if (defined($flag_project)) {
        print $project . "\n";
        exit;
    }
    if (defined($flag_regmodel_file)) {
        if ( $regmodel ) {
            print $regmodel_file . "\n";
        }
        else {
            print "\n";
        }
        exit;
    }
}

sub create_directories_and_copy_files {

    #create backup of existing project directory
    if (-e $project && $backup ne "NO"){
        print "Copying backup of existing generated files from $project to ${project}.bak\n";
        dircopy( $project, "${project}.bak" ) or die "$!\n";
    }
    mkdir( $project, 0755 );
    $dir = $project . "/sim";
    mkdir( $dir, 0755 );
    $dir = $project . "/tb";
    mkdir( $dir, 0755 );
    $dir = $project . "/tb/" . $tbname;
    mkdir( $dir,         0755 );
    mkdir( $dir . "/sv", 0755 );
    mkdir( $dir . "/sv", 0755 );
    $dir = $project . "/tb/" . $tbname . "_tb";
    mkdir( $dir,         0755 );
    mkdir( $dir . "/sv", 0755 );
    $dir = $project . "/tb/" . $tbname . "_test";
    mkdir( $dir,         0755 );
    mkdir( $dir . "/sv", 0755 );

    $dir1 = $dut_path;
    $dut_tb_dir = "dut";
    $dut_tb_path = $project . "/" . $dut_tb_dir;
    $dir2 = $dut_tb_path;

    #print LOGFILE "dut_path: $dut_path\n";
    if ( ( -e $dir ) && $dir1 ne $dir2 ) {
        print "Copying dut files to            $dir2\n";
        dircopy( $dir1, $dir2 ) or die "$!\n";
    }
    else {
        print LOGFILE "dut_path does not exist. Nothing to copy from DUT\n";
    }
    if ( -e $inc_path ) {
        $dir1 = $inc_path;
        $dir2 = $project . "/tb/include";
        print "Copying include files to        $dir2\n";
        dircopy( $dir1, $dir2 ) or die "$!\n";
    }
}

sub parse_template {
    @agent_var_array         = ();
    @agent_enum_array        = ();
    @agent_meta_array        = ();
    @agent_var_cnstr_array   = ();
    @agent_port_array        = ();
    @agent_clock_array       = ();
    @agent_reset_array       = ();
    $agent_seqr_class        = "";
    @config_var_array        = ();
    $uvm_reg_data            = "";
    $uvm_reg_addr            = "";
    $uvm_reg_kind            = "";
    @additional_agents       = ();
    $agent_has_env           = "NO";

    open( TH, $template_name )
      || die "Exiting due to Error: can't open template: " . $template_name . "\n";

    for ( ; ; ) {
        my $line;
        undef $!;
        unless ( defined( $line = <TH> ) ) {
            die $! if $!;
            last;    # reached EOF
        }
        next if ( $line =~ m/^\s*#/ );    #comment line starts with "#"
        next if ( $line =~ m/^\s+$/ );    #blank line

        $line =~ s/(^.*?)#.*/$1/;         #delete trailing comments

        $line =~ /^\s*(\w+)\s*=\s*(.*?)\s*$/
          or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
        my $param_name  = $1;
        my $param_value = $2;

        #check for agent_name
        if ( $param_name =~ /agent_name/i ) {
            print LOGFILE "agent_name: $line";
            $agent_name = $param_value;
            if ( $agent_name eq "") {
                warning_prompt("agent_name is blank in ${template_name}");
            }
            push( @agent_list, $agent_name );

            # Set values and defaults that depend on agent name
            $number_of_instances{$agent_name}   = 1;
            $tpl_fname{$agent_name}             = $template_name;
            $agent_if                           = "${agent_name}_if";
            $if_instance_names{$agent_if}       = "${agent_if}_0";
            $if_instance_names{"${agent_if}_0"} = "${agent_if}_0";
            if ( $split_transactors eq "YES" ) {
                push( @all_agent_ifs, "${agent_name}_bfm" );
            }
            else {
                push( @all_agent_ifs, $agent_if );
            }
        }

        #number of instances of the agent and its interface
        if ( $param_name =~ /number_of_instances/i ) {
            $number_of_instances{$agent_name} = $param_value;
            print LOGFILE "number_of_instances = $param_value\n";
            if ($param_value > 1) {
                for ( my $i = 1 ; $i < $param_value ; $i++ ) {
                    $if_instance_names{"${agent_if}_${i}"} = "${agent_if}_${i}";
                }
            }
        }

        #check if agent has its own env (default = NO)
        if ( $param_name =~ /agent_has_env/i ) {
            $agent_has_env = uc $param_value;
        }

        #check if other agents to be added to same env
        if ( $param_name =~ /additional_agent/i ) {
            push @additional_agents, $param_value;
            unless ( exists $agent_parent{$param_value} ) {
                $agent_parent{$param_value} = $agent_name;
            }
            else {
                warning_prompt("An agent should not appear as an additional_agent more than once: $param_value is an additional_agent in $agent_name and $agent_parent{$param_value}");
            }
        }

        #check for uvm_seqr_class
        if ( $param_name =~ /uvm_seqr_class/i ) {
            $agent_seqr_class = $param_value;
        }

        #check for active/passive agent
        if ( $param_name =~ /agent_is_active/i ) {
            my $value = uc $param_value;
            if ( $value ne "UVM_ACTIVE" && $value ne "UVM_PASSIVE" ) {
                warning_prompt("agent_is_active must be either UVM_ACTIVE or UVM_PASSIVE in template file: ${template_name}");
            }
            $agent_is_active{$agent_name} = $value;
        }

        #check for agent checks_enable (default = YES)
        if ( $param_name =~ /agent_checks_enable/i ) {
            $agent_checks_enable{$agent_name} = uc $param_value;
        }

        #check for agent coverage_enable (default = YES)
        if ( $param_name =~ /agent_coverage_enable/i ) {
            $agent_coverage_enable{$agent_name} = uc $param_value;
        }

        #check for trans_item
        if ( $param_name =~ /trans_item/i ) {
            $agent_item = $param_value;
            print LOGFILE "trans_item= $agent_item\n";
            $agent_item_types{$agent_name} = $agent_item;
        }

        #check for trans_var
        if ( $param_name =~ /trans_var$/i ) {
            print LOGFILE "trans_var: $param_value\n";
            push @agent_var_array, $param_value
        }

        #check for trans_enum and trans_meta
        if ( $param_name =~ /trans_enum_var$/i ) {
            print LOGFILE "trans_enum_var: $param_value\n";
            push @agent_var_array, $param_value;
            push @agent_enum_array, $param_value;
        }

        if ( $param_name =~ /trans_meta$/i ) {
            print LOGFILE "trans_meta: $param_value\n";
            push @agent_meta_array, $param_value;
        }

        if ( $param_name =~ /trans_enum_meta$/i) {
            print LOGFILE "trans_enum_meta: $param_value\n";
            push @agent_meta_array, $param_value;
            push @agent_enum_array, $param_value;
        }

        #check for trans_var_constraint
        if ( $param_name =~ /trans_var_constraint/i ) {
            print LOGFILE "trans_var_constraint: $param_value\n";
            push @agent_var_cnstr_array, $param_value;
       }

        #check for config_var
        if ( $param_name =~ /config_var$/i ) {
            print LOGFILE "config_var: $param_value\n";
            push @config_var_array, $param_value;
        }

        #check for agent sequence include file
        if ( $param_name =~ /agent_seq_inc/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_seq_inc{$agent_name} = $1;
            $agent_seq_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_seq_inc = $param_value\n";
        }

        #check for agent include file
        if ( $param_name =~ /agent_generate_methods_inside_class/i ) {
            $agent_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_generate_methods_after_class/i ) {
            $agent_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_inc_before_class{$agent_name} = $1;
            $agent_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /agent_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_inc_inside_class{$agent_name} = $1;
            $agent_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_inc_after_class{$agent_name} = $1;
            $agent_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_inc_inside_bfm/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_inc_inside_bfm{$agent_name} = $1;
            $agent_inc_inside_bfm_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_inc_inside_bfm = $param_value\n";
        }

        if ( $param_name =~ /agent_prepend_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_prepend_to_build_phase{$agent_name} = $1;
            $agent_prepend_to_build_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_prepend_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /agent_append_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_append_to_build_phase{$agent_name} = $1;
            $agent_append_to_build_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_append_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /agent_append_to_connect_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_append_to_connect_phase{$agent_name} = $1;
            $agent_append_to_connect_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_append_to_connect_phase = $param_value\n";
        }

        if ( $param_name =~ /agent_copy_config_vars/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_copy_config_vars{$agent_name} = $1;
            $agent_copy_config_vars_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_copy_config_vars = $param_value\n";
        }

        #check for agent environment sequence include file
        if ( $param_name =~ /agent_env_seq_inc/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_seq_inc{$agent_name} = $1;
            $agent_env_seq_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_seq_inc = $param_value\n";
        }

        #check for agent env include file
        if ( $param_name =~ /agent_env_generate_methods_inside_class/i ) {
            $agent_env_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_env_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_env_generate_methods_after_class/i ) {
            $agent_env_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_env_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_env_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_inc_before_class{$agent_name} = $1;
            $agent_env_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /agent_env_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_inc_inside_class{$agent_name} = $1;
            $agent_env_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_env_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_inc_after_class{$agent_name} = $1;
            $agent_env_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_env_prepend_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_prepend_to_build_phase{$agent_name} = $1;
            $agent_env_prepend_to_build_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_prepend_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /agent_env_append_to_build_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_append_to_build_phase{$agent_name} = $1;
            $agent_env_append_to_build_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_append_to_build_phase = $param_value\n";
        }

        if ( $param_name =~ /agent_env_append_to_connect_phase/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_append_to_connect_phase{$agent_name} = $1;
            $agent_env_append_to_connect_phase_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_env_append_to_connect_phase = $param_value\n";
        }

        if ( $param_name =~ /adapter_generate_methods_inside_class/i ) {
            $agent_adapter_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "adapter_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /adapter_generate_methods_after_class/i ) {
            $agent_adapter_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "adapter_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /adapter_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_adapter_inc_before_class{$agent_name} = $1;
            $agent_adapter_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_adapter_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /adapter_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_adapter_inc_inside_class{$agent_name} = $1;
            $agent_adapter_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_adapter_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /adapter_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_adapter_inc_after_class{$agent_name} = $1;
            $agent_adapter_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_adapter_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /byo_interface/i ) {
            $byo_interface{$agent_name} = $param_value;
            print LOGFILE "byo_interface = $param_value\n";
        }

        if ( $param_name =~ /generate_interface_instance/i ) {
            $generate_interface_instance{$agent_name} = uc $param_value;
            print LOGFILE "generate_interface_instance = $param_value\n";
        }

        if ( $param_name =~ /if_inc_inside_interface/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $if_inc_inside_interface{$agent_name} = $1;
            $if_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "if_inc_inside_interface = $param_value\n";
        }

        if ( $param_name =~ /trans_generate_methods_inside_class/i ) {
            $agent_trans_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "trans_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /trans_generate_methods_after_class/i ) {
            $agent_trans_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "trans_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /trans_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_trans_inc_before_class{$agent_name} = $1;
            $agent_trans_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "trans_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /trans_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_trans_inc_inside_class{$agent_name} = $1;
            $agent_trans_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "trans_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /trans_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_trans_inc_after_class{$agent_name} = $1;
            $agent_trans_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "trans_inc_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_config_generate_methods_inside_class/i ) {
            $agent_config_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_config_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_config_generate_methods_after_class/i ) {
            $agent_config_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_config_generate_methods_after_class = $param_value\n";
        }
        
        if ( $param_name =~ /agent_config_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_config_inc_before_class{$agent_name} = $1;
            $agent_config_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_config_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /agent_config_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_config_inc_inside_class{$agent_name} = $1;
            $agent_config_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_config_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_config_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_config_inc_after_class{$agent_name} = $1;
            $agent_config_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_config_inc_after_class = $param_value\n";
        }

        #check for agent coverpoint include file
        if ( $param_name =~ /agent_cover_generate_methods_inside_class/i ) {
            $agent_cover_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_cover_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_cover_generate_methods_after_class/i ) {
            $agent_cover_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "agent_cover_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /agent_cover_inc\b/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_cover_inc{$agent_name} = $1;
            $agent_cover_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_cover_inc = $param_value\n";
        }

        if ( $param_name =~ /agent_cover_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_cover_inc_before_class{$agent_name} = $1;
            $agent_cover_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_cover_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /agent_cover_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_cover_inc_inside_class{$agent_name} = $1;
            $agent_cover_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_cover_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /agent_cover_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_cover_inc_after_class{$agent_name} = $1;
            $agent_cover_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "agent_cover_inc_after_class = $param_value\n";
        }

        #check for driver include file
        if ( $param_name =~ /driver_inc\b/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_driv_inc{$agent_name} = $1;
            $agent_driv_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "driver_inc = $param_value\n";
        }

        if ( $param_name =~ /driver_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_driv_inc_before_class{$agent_name} = $1;
            $agent_driv_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "driver_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /driver_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_driv_inc_inside_class{$agent_name} = $1;
            $agent_driv_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "driver_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /driver_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_driv_inc_after_class{$agent_name} = $1;
            $agent_driv_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "driver_inc_after_class = $param_value\n";
        }

        #check for monitor include file
        if ( $param_name =~ /monitor_inc\b/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_mon_inc{$agent_name} = $1;
            $agent_mon_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "monitor_inc = $param_value\n";
        }

        if ( $param_name =~ /monitor_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_mon_inc_before_class{$agent_name} = $1;
            $agent_mon_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "monitor_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /monitor_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_mon_inc_inside_class{$agent_name} = $1;
            $agent_mon_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "monitor_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /monitor_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_mon_inc_after_class{$agent_name} = $1;
            $agent_mon_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "monitor_inc_after_class = $param_value\n";
        }

        #check for sequencer include file
        if ( $param_name =~ /sequencer_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_seqr_inc_before_class{$agent_name} = $1;
            $agent_seqr_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "sequencer_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /sequencer_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_seqr_inc_inside_class{$agent_name} = $1;
            $agent_seqr_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "sequencer_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /sequencer_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_seqr_inc_after_class{$agent_name} = $1;
            $agent_seqr_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "sequencer_inc_after_class = $param_value\n";
        }

        #check for if_port
        if ( $param_name =~ /if_port/i ) {
            my $agent_port = $param_value;
            push @agent_port_array, $agent_port;
            print LOGFILE "if_port = $param_value\n";
        }

        #check for if_clock
        if ( $param_name =~ /if_clock/i ) {
            my $agent_clock = $param_value;
            push @agent_clock_array, $agent_clock;
            $env_clock_list =
              $env_clock_list
              ? "$env_clock_list $agent_name $agent_clock"
              : "$agent_name $agent_clock";
            print LOGFILE "env_clock_list: $env_clock_list\n";
        }
        @clist = split( /\s+/, $env_clock_list );
        foreach $i ( 0 .. @clist-1 ) {
            if ( $clist[$i] ne "" ) {
                print LOGFILE "clist[$i]: $clist[$i]\n";
            }
        }

        #check for if_reset
        if ( $param_name =~ /if_reset/i ) {
            $agent_reset = $param_value;
            print LOGFILE "IF_RESET: $agent_reset\n";
            push @agent_reset_array, $agent_reset;
            $env_reset_list =
              $env_reset_list
              ? "$env_reset_list $agent_name $agent_reset"
              : "$agent_name $agent_reset";
            print LOGFILE "env_reset_list: $env_reset_list\n";
        }
        @rlist = split( /\s+/, $env_reset_list );
        foreach $i ( 0 .. @rlist-1 ) {
            if ( $rlist[$i] ne "" ) {
                print LOGFILE "rlist[$i]: $rlist[$i]\n";
            }
        }

        #check for reg_access (gives addr map in uvm_reg)
        if ( $param_name =~ /reg_access_name/i ) {
            print "reg_access_name in ${template_name} still works but is deprecated. Use reg_access_mode instead. You can also set reg_access_block_type, reg_access_block_instance, and reg_access_map\n";
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $reg_access_mode{$agent_name} and $reg_access_mode{$agent_name} ne $3 ) {
                $reg_access_mode{$agent_name} = $3;
            }
            else {
                warning_prompt("reg_access_name sets mode to $3 in ${template_name} but it is already set to a different value ($reg_access_mode{$agent_name})");
            }
            print LOGFILE "reg_access_name: $param_value\n";
        }

        if ( $param_name =~ /reg_access_block_type/i ) {
            $param_value =~ /\s*(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $reg_access_block_type{$agent_name} and $reg_access_block_type{$agent_name} ne $1 ) {
                $reg_access_block_type{$agent_name} = $1;
            }
            else {
                warning_prompt("reg_access_block_type set to $1 in ${template_name} but it is already set to a different value ($reg_access_block_type{$agent_name})");
            }
            print LOGFILE "reg_access_block_type: $1\n";
        }

        if ( $param_name =~ /reg_access_block_instance/i ) {
            $param_value =~ /\s*([\w\.]*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            my $instance = $1;
            if ( $instance ne "" ) {
                if ( substr($instance, 0, 1) ne "." ) {
                   $instance = ".$instance";
                }
            }
            unless ( exists $reg_access_instance{$agent_name} and $reg_access_instance{$agent_name} ne $instance ) {
                $reg_access_instance{$agent_name} = $instance;
            }
            else {
                warning_prompt("reg_access_block_instance set to $1 in ${template_name} but it is already set to a different value ($reg_access_instance{$agent_name})");
            }
            print LOGFILE "reg_access_block_instance: $instance\n";
        }

        if ( $param_name =~ /reg_access_map/i ) {
            $param_value =~ /\s*(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            $reg_access_map{$agent_name} = $1;
            print LOGFILE "reg_access_map: $1\n";
        }

        if ( $param_name =~ /reg_access_mode/i ) {
            $param_value =~ /\s*(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            unless ( exists $reg_access_mode{$agent_name} and $reg_access_mode{$agent_name} ne $1 ) {
                $reg_access_mode{$agent_name} = $1;
            }
            else {
                warning_prompt("reg_access_mode set to $1 in ${template_name} but it is already set to a different value ($reg_access_mode{$agent_name})");
            }
            print LOGFILE "reg_access_mode: $1\n";
        }

        #check for uvm_reg to bus mappings
        if ( $param_name =~ /uvm_reg_data/i ) {
            $uvm_reg_data = $param_value;
        }
        if ( $param_name =~ /uvm_reg_addr/i ) {
            $uvm_reg_addr = $param_value;
        }
        if ( $param_name =~ /uvm_reg_kind/i ) {
            $uvm_reg_kind = $param_value;
        }

        #check for register sequence include file (an alias for agent_env_seq_inc)
        if ( $param_name =~ /reg_seq_inc/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $agent_env_seq_inc{$agent_name} = $1;
            $agent_env_seq_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "reg_seq_inc = $param_value\n";
        }

        #check for register coverpoint include file
        if ( $param_name =~ /reg_cover_generate_methods_inside_class/i ) {
            $reg_cover_generate_methods_inside_class{$agent_name} = uc $param_value;
            print LOGFILE "reg_cover_generate_methods_inside_class = $param_value\n";
        }

        if ( $param_name =~ /reg_cover_generate_methods_after_class/i ) {
            $reg_cover_generate_methods_after_class{$agent_name} = uc $param_value;
            print LOGFILE "reg_cover_generate_methods_after_class = $param_value\n";
        }

        if ( $param_name =~ /reg_cover_inc\b/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $reg_cover_inc{$agent_name} = $1;
            $reg_cover_inc_inline{$agent_name} = $3 if ($3);
            print LOGFILE "reg_cover_inc = $param_value\n";
        }

        if ( $param_name =~ /reg_cover_inc_before_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $reg_cover_inc_before_class{$agent_name} = $1;
            $reg_cover_inc_before_inline{$agent_name} = $3 if ($3);
            print LOGFILE "reg_cover_inc_before_class = $param_value\n";
        }

        if ( $param_name =~ /reg_cover_inc_inside_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $reg_cover_inc_inside_class{$agent_name} = $1;
            $reg_cover_inc_inside_inline{$agent_name} = $3 if ($3);
            print LOGFILE "reg_cover_inc_inside_class = $param_value\n";
        }

        if ( $param_name =~ /reg_cover_inc_after_class/i ) {
            $param_value =~ /\s*([\w\.\/]+)\s*(,|\s)?\s*(\w*)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
              check_inc_file($1);
            $reg_cover_inc_after_class{$agent_name} = $1;
            $reg_cover_inc_after_inline{$agent_name} = $3 if ($3);
            print LOGFILE "reg_cover_inc_after_class = $param_value\n";
        }

        #check for factory overrides
        if ( $param_name =~ /agent_factory_set/i ) {
            $param_value =~ /\s*(\w+)(\s+|\s*,\s*)(\w+)/
              or die "Exiting due to Error: bad entry in line $. of ${template_name}: $line\n";
            $agent_factory_set{$1} = $3;
        }

    } # End of file parsing loop

    close TH;
}    #end parse_template

sub after_parse_template {

    if ( exists $reg_access_mode{$agent_name} ) {

        $bus2reg_map{$agent_name} = {
            'data' => $uvm_reg_data,
            'addr' => $uvm_reg_addr,
            'kind' => $uvm_reg_kind
        };

        if ( @additional_agents ) {
            warning_prompt("additional_agent and reg_access_name/mode/type/instance are mutually exclusive and should not be used in the same template file: ${template_name}");
        }

        unless ( exists $reg_access_instance{$agent_name} ) {
            $reg_access_instance{$agent_name} = ".${agent_name}";
        }
        unless ( exists $reg_access_map{$agent_name} ) {
            $reg_access_map{$agent_name} = "${agent_name}_map";
        }
        unless ( exists $reg_access_block_type{$agent_name} ) {
            warning_prompt("reg_access_name or reg_access_mode are set without setting reg_access_block_type or regmodel_sub_block in template file: ${template_name}");
        }

        if ( $number_of_instances{$agent_name} > 1 ) {
            warning_prompt("Agent $agent_name uses reg_access_* but has number_of_instances = $number_of_instances{$agent_name} in ${template_name}." .
                           " reg_access_instance and reg_access_map will get the suffix _N. This will change in future versions of the generator.");
        }

        if ( $agent_has_env eq "NO" ) {
              print "Forcing agent_has_env = yes for agent ${agent_name} because the agent uses register access\n";
        }
        $agent_has_env = "YES";

        if ( exists $agent_is_active{$agent_name} and $agent_is_active{$agent_name} eq "UVM_PASSIVE" ) {                  
            warning_prompt("Agent $agent_name uses reg_access_* but has agent_is_active = UVM_PASSIVE in template file: ${template_name}");
        }
    }
    else
    {
        if ( exists $reg_access_block_type{$agent_name} ) {
            warning_prompt("reg_access_block_type or regmodel_sub_block are set without setting reg_access_name or reg_access_mode in template file: ${template_name}");
        }
        if ( exists $reg_access_map{$agent_name} ) {
            warning_prompt("reg_access_map is set without setting reg_access_name or reg_access_mode in template file: ${template_name}");
        }
        if ( exists $reg_access_instance{$agent_name} ) {
            warning_prompt("reg_access_block_instance is set without setting reg_access_name or reg_access_mode in template file: ${template_name}");
        }
    }


    # Build hash of agent types indexed by agent instance name
    for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
        my $suffix = calc_suffix($i, $number_of_instances{$agent_name});
        my $instance;
        if ( $agent_has_env eq "NO" ) {
            $instance = "m_${agent_name}${suffix}_agent";
        }
        else {
            $instance = "m_${agent_name}_env.m_${agent_name}${suffix}_agent";
        }
        $agent_type_by_inst{$instance} = $agent_name;
        push @agent_instance_names, $instance;
    }

    if ( $agent_has_env eq "NO" ) {
        push( @stand_alone_agents, $agent_name );
    }
    else {
        push( @env_list, "${agent_name}_env" );
    }

    if ( @additional_agents ) {
        # Array of additional_agents
        print LOGFILE "${agent_name}_env has other agents: @additional_agents\n";
        
        # Hash %env_agents needs to store a copy of the @additional_agents array per-agent
        my @copy_array = @additional_agents;
        $env_agents{"${agent_name}_env"} = \@copy_array;
        
        if ( $agent_has_env eq "NO" ) {
          warning_prompt("Agent ${agent_name} has an additional_agent (@additional_agents) and hence should have agent_has_env = yes");
        }
        foreach my $extra_agent ( @additional_agents ) {
            my $instance;
            $instance = "m_${agent_name}_env.m_${extra_agent}_agent";
            $agent_type_by_inst{$instance} = $agent_name;
            push @agent_instance_names, $instance;
        }
    }

    if ( exists $agent_generate_methods_after_class{$agent_name} && $agent_generate_methods_after_class{$agent_name} eq "NO" )
    {
        if ( exists $agent_prepend_to_build_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_prepend_to_build_phase cannot be used in combination with agent_generate_methods_after_class = no";
        }
        if ( exists $agent_append_to_build_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_append_to_build_phase cannot be used in combination with agent_generate_methods_after_class = no";
        }
        if ( exists $agent_append_to_connect_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_append_to_connect_phase cannot be used in combination with agent_generate_methods_after_class = no";
        }
    }

    unless ( $agent_seqr_class =~ /y|yes/i ) {
        if ( exists $agent_seqr_inc_before_class{$agent_name}
          or exists $agent_seqr_inc_inside_class{$agent_name}
          or exists $agent_seqr_inc_after_class{$agent_name} )
        {
          die "ERROR in ${template_name}. The sequencer_inc_before/inside/after_class include files can only be used in combination with uvm_seqr_class = yes\n";
        }
    }    

    if ( exists $agent_env_generate_methods_after_class{$agent_name} && $agent_env_generate_methods_after_class{$agent_name} eq "NO" )
    {
        if ( exists $agent_env_prepend_to_build_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_env_prepend_to_build_phase cannot be used in combination with agent_env_generate_methods_after_class = no";
        }
        if ( exists $agent_env_append_to_build_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_env_append_to_build_phase cannot be used in combination with agent_env_generate_methods_after_class = no";
        }
        if ( exists $agent_env_append_to_connect_phase{$agent_name} ) {
          die "ERROR in ${template_name}. agent_env_append_to_connect_phase cannot be used in combination with agent_env_generate_methods_after_class = no";
        }
    }
}

sub check_common_pkg {
    my ($fname) = @_;
    if (-e "${dut_path}/${fname}" ) {
        get_pkg_name("${dut_path}/${fname}");
    }
    else {
        warning_prompt("common_pkg file ${fname} specified in ${common_tpl_fname} not found in ${dut_path}");
    }
}

sub get_pkg_name {
    my ($fname_with_path) = @_;
    my $line;
    open( LFH, $fname_with_path ) or die "CANNOT OPEN FILE ${fname_with_path}!\n";
    SKIP_BL: while (<LFH>) {
        if (/\w+/) {
            $line = $_;
            last SKIP_BL;
        }
    }
    $line or die "Exiting due to Error: common package file $fname_with_path exists but is empty\n";
    FIND: while ($line) {
        while ($line) {
            if ( $line =~ m!\s*//.*\n! ) {    #comments - ignore
                $line = <LFH>;
                next FIND;
            }
            elsif ( $line =~ m/^\s*package\s+(\w+)\s*;/ ) {    #package declaration
                $common_pkg = $1;
                print LOGFILE "get_pkg_name: found package name $common_pkg\n";
                last FIND;
            }
            $line = <LFH>;
        }
    }    #FIND
}

sub check_common_env_pkg {
    my ($fname) = @_;
    if (-e "${inc_path}/${fname}" ) {
        get_env_pkg_name("${inc_path}/${fname}");
    }
    else {
        warning_prompt("common_env_pkg file ${fname} specified in ${common_tpl_fname} not found in ${inc_path}");
    }
}

sub get_env_pkg_name {
    my ($fname_with_path) = @_;
    my $line;
    open( LFH, $fname_with_path ) or die "CANNOT OPEN FILE ${fname_with_path}!\n";
    SKIP_BL: while (<LFH>) {
        if (/\w+/) {
            $line = $_;
            last SKIP_BL;
        }
    }
    $line or die "Exiting due to Error: common env package file $fname_with_path exists but is empty\n";
    FIND: while ($line) {
        while ($line) {
            if ( $line =~ m!\s*//.*\n! ) {    #comments - ignore
                $line = <LFH>;
                next FIND;
            }
            elsif ( $line =~ m/^\s*package\s+(\w+)\s*;/ ) {    #package declaration
                $common_env_pkg = $1;
                print LOGFILE "get_env_pkg_name: found env package name $common_env_pkg\n";
                last FIND;
            }
            $line = <LFH>;
        }
    }    #FIND
}

sub extra_checking_for_additional_agents {

    foreach my $agent (@stand_alone_agents) {
        push( @top_env_agents, $agent )
          unless grep( /$agent/, keys(%agent_parent) );
    }

    # Check for agent with agent_has_env = yes being used as an additional_agent
    foreach my $agent (@agent_list) {
        if ( exists $agent_parent{$agent} ) {
            unless ( grep( /$agent/, @stand_alone_agents ) ) {
                warning_prompt("Agent ${agent} is used as an additional_agent (in $agent_parent{$agent}) and hence should itself have agent_has_env = no");
            }
            if ( $number_of_instances{$agent} > 1 ) {
                warning_prompt("Agent ${agent} is used as an additional_agent (in $agent_parent{$agent}) and hence should itself have number_of_instances = 1");
            }
        }
    }
}

sub calc_suffix {
    my ($i, $n) = @_;
    my $suffix;
    if ($n == 1) { $suffix = ""; } else { $suffix = "_${i}"; }
    return $suffix;
}

sub check_file {
    my ($fname) = @_;
    unless (-e "${fname}") {
        warning_prompt("SPECIFIED FILE $fname NOT FOUND");
    }
}

sub check_inc_file {
    my ($fname) = @_;
    unless (-e "${inc_path}/${fname}") {
        warning_prompt("SPECIFIED INCLUDE FILE $fname NOT FOUND");
    }
}

sub insert_inc_file {
    my ($indent, $fname, $inline, $flagname, $templatefile) = @_;
    if ( defined $fname) {
        my $fullname = "${project}/tb/include/${fname}";
        #print "insert_inc_file, fname = ${fname}, inline = ${inline}\n";

        if (-e $fullname)
        {
            if (defined $inline && uc($inline) eq "INLINE")
            {
                open( TH, $fullname )
                  || die "Exiting due to Error: can't open include file: " . $fullname . "\n";

                print FH "${indent}// Start of inlined include file $fullname\n" if $flagname ne "file_header_inc";
                for ( ; ; ) {
                    my $line;
                    undef $!;
                    unless ( defined( $line = <TH> ) ) {
                        die $! if $!;
                        last;    # reached EOF
                    }

                    print FH $indent .$line;
                }
                print FH "${indent}// End of inlined include file\n" if $flagname ne "file_header_inc";
                print FH "\n";
            }
            else
            {
                print FH "${indent}`include \"$fname\"\n";
                print FH "\n";
            }
        }
    }
    elsif ($flagname ne "") {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "${indent}// You can insert code here by setting $flagname in file $templatefile\n\n";
        }
    }
}

sub warning_prompt {
    my $message = "@_";
    warn "WARNING! $message\n";
    unless ($continue_on_warning) {
        print "Continue? (y/n) [n] ";
        <STDIN> =~ /y/i or die "UVM CODE NOT GENERATED DUE TO ERRORS!";
    }
}

sub write_file_header {
    my ($fname,$descript) = @_;
    
    my $inline = "INLINE";
    insert_inc_file("", $file_header_inc, $inline, "file_header_inc", $common_tpl_fname);

    unless ( defined $generate_file_header && $generate_file_header eq "NO" )
    {
        print FH "//=============================================================================\n";
        if ( defined $copyright ) {
            print FH "// $copyright\n";
            print FH "//=============================================================================\n";
        }
        print FH "// Project  : " . $project . "\n";
        print FH "//\n";
        print FH "// File Name: $fname\n";
        print FH "//\n";
        print FH "// Author   : Name   : $author\n"  if ( defined $author );;
        print FH "//            Email  : $email\n"   if ( defined $email );
        print FH "//            Tel    : $tel\n"     if ( defined $tel );
        print FH "//            Dept   : $dept\n"    if ( defined $dept );
        print FH "//            Company: $company\n" if ( defined $company );
        print FH "//            Year   : $year\n"    if ( defined $year );
        print FH "//\n";
        print FH "// Version:   $version\n";
        print FH "//\n";
        print FH "// Code created by Easier UVM Code Generator version $VERNUM on $date\n";
        print FH "//=============================================================================\n";
        print FH "// Description: $descript\n";
        print FH "//=============================================================================\n";
        print FH "\n";
    }
}


my @pp_list1;
my @pp_list2;
my @pp_list3;

sub align {
    my ($arg1,$arg2,$arg3) = @_;
    push @pp_list1, $arg1;
    push @pp_list2, $arg2;
    push @pp_list3, $arg3;
}

sub gen_aligned {
    pretty_print(\@pp_list1, \@pp_list2, \@pp_list3);
    @pp_list1 = ();
    @pp_list2 = ();
    @pp_list3 = ();
}

sub pretty_print {

# Can pretty-print 2 columns (args 1 and 2) or 3 columns (args 1, 2, and 3)
# If the string in the 2nd arg is empty, the first string is printed verbatim with no \n added

    my ($arg1ref, $arg2ref, $arg3ref) = @_;
    my @string1 = @{$arg1ref};
    my @string2 = @{$arg2ref};
    my @string3 = @{$arg3ref};
    my $string1_len = @string1;
    my $string2_len = @string2;
    my $string3_len = @string3;

    unless ($string1_len == $string2_len and ($string2_len == $string3_len or $string3_len == 0)) {
      die "Parameters to pretty_print are wrong";
    }

    my $maxlen1 = 0;
    for ($i = 0; $i < @string1; $i++) {
      if ( length($string2[$i]) > 0 ) {
          my $txt = $string1[$i];
          if (length($txt) > $maxlen1) { $maxlen1 = length($txt); }
      }
    }

    my $maxlen2 = 0;
    foreach $ele (@string2) {
      if (length($ele) > $maxlen2) { $maxlen2 = length($ele); }
    }

    for ($i = 0; $i < @string1; $i++) {
        my $txt = $string1[$i];
        print FH $txt;
        if (length ($string2[$i]) > 0) {
            for (1 .. $maxlen1 - length($txt)) { print FH " "; }
            $txt = $string2[$i];
            print FH $txt;
            if ($string3_len > 0) {
                for (1 .. $maxlen2 - length($txt)) { print FH " "; }
                print FH $string3[$i];
            }
            print FH "\n";
        }
    }
}

sub gen_if {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_if.sv" )
      || die "Exiting due to Error: can't open interface: $agent_name";

    write_file_header "${agent_name}_if.sv", "Signal interface for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_IF_SV\n";
    print FH "`define " . uc($agent_name) . "_IF_SV\n";
    print FH "\n";
    print FH "interface ${agent_if}(); \n";
    print FH "\n";
    print FH "  timeunit      $timeunit;\n";
    print FH "  timeprecision $timeprecision;\n";
    print FH "\n";
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;
    print FH "  import ${agent_name}_pkg::*;\n";
    print FH "\n";

    foreach $port_decl (@agent_port_array) {
        print FH "  ${port_decl}\n";
    }
    print FH "\n";

    print FH "  // You can insert properties and assertions here\n";
    print FH "\n";

    insert_inc_file("  ", $if_inc_inside_interface{$agent_name}, $if_inc_inside_inline{$agent_name}, "if_inc_inside_interface", $tpl_fname{$agent_name});

    print FH "endinterface : ${agent_if}\n";
    print FH "\n";
    print FH "`endif // " . uc($agent_name) . "_IF_SV\n";
    print FH "\n";
    close(FH);
}    #end gen_if

sub gen_bfm {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_bfm.sv" )
      || die "Exiting due to Error: can't open interface: $agent_name";

    write_file_header "${agent_name}_bfm.sv", "Synthesizable BFM for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_BFM_SV\n";
    print FH "`define " . uc($agent_name) . "_BFM_SV\n";
    print FH "\n";

    my $interface_type;
    if ( exists $byo_interface{$agent_name} ) {               
        $interface_type = $byo_interface{$agent_name};        
    }                                                         
    else {                                                    
        $interface_type = $agent_if;                 
    }                                                         

    print FH "interface ${agent_name}_bfm(${interface_type} if_port); \n";
    print FH "\n";
    print FH "  timeunit      $timeunit;\n";
    print FH "  timeprecision $timeprecision;\n";
    print FH "\n";
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;
    print FH "  import ${agent_name}_pkg::*;\n";
    print FH "\n";

    insert_inc_file("  ", $agent_inc_inside_bfm{$agent_name}, $agent_inc_inside_bfm_inline{$agent_name}, "agent_inc_inside_bfm", $tpl_fname{$agent_name});

    print FH "endinterface : ${agent_name}_bfm\n";
    print FH "\n";
    print FH "`endif // " . uc($agent_name) . "_BFM_SV\n";
    print FH "\n";
    close(FH);
}    #end gen_bfm

sub gen_seq_item {
    printf LOGFILE "AGENT-ITEM: $agent_item\n";
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_" . $agent_item . ".sv" )
      || die "Exiting due to Error: can't open data_item: $agent_item";

    write_file_header "${agent_name}_seq_item.sv", "Sequence item for ${agent_name}_sequencer";

    print FH "`ifndef " . uc($agent_name) . "_SEQ_ITEM_SV\n";
    print FH "`define " . uc($agent_name) . "_SEQ_ITEM_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_trans_inc_before_class{$agent_name}, $agent_trans_inc_before_inline{$agent_name}, "trans_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_item} extends uvm_sequence_item; \n";
    print FH "\n";
    print FH "  `uvm_object_utils(" . $agent_item . ")\n";
    print FH "\n";

    print FH "  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file $tpl_fname{$agent_name}\n";   
    print FH "  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file $tpl_fname{$agent_name}\n";   
    print FH "\n";
    if (@agent_var_array) {
        print FH "  // Transaction variables\n";
    }

    foreach my $var_decl (@agent_var_array) {
        print FH "  $var_decl\n";
    }
    print FH "\n";

    if (@agent_meta_array) {
        print FH "  // Transaction metadata\n";
    }

    foreach my $var_decl (@agent_meta_array) {
        print FH "  $var_decl\n";
    }
    print FH "\n";

    if ( @agent_var_cnstr_array ) {
        my $cnstr_count = 0;
        foreach my $cnstr (@agent_var_cnstr_array) {
            print FH "  constraint c$cnstr_count $cnstr\n";
            $cnstr_count++;
        }
        print FH "\n";
   }
    print FH "  extern function new(string name = \"\");\n";

    unless ( exists $agent_trans_generate_methods_inside_class{$agent_name} && $agent_trans_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "\n  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n";
        }
        print FH "  extern function void do_copy(uvm_object rhs);\n";
        print FH "  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);\n";
        print FH "  extern function void do_print(uvm_printer printer);\n";
        print FH "  extern function void do_record(uvm_recorder recorder);\n";
        unless (defined $flag_nopack) {
            print FH "  extern function void do_pack(uvm_packer packer);\n";
            print FH "  extern function void do_unpack(uvm_packer packer);\n";
        }
        print FH "  extern function string convert2string();\n";
    }

    print FH "\n";

    insert_inc_file("  ", $agent_trans_inc_inside_class{$agent_name}, $agent_trans_inc_inside_inline{$agent_name}, "trans_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : $agent_item \n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_item}::new(string name = \"\");\n";
    print FH "  super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    @all_tx_vars = ();
    @non_local_tx_vars = ();
    @non_meta_tx_vars = ();
    %enum_var_types = ();
    %unpacked_bound = ();

    my $count = 1;

    PROC_VAR:foreach my $var_decl (@agent_var_array, @agent_meta_array) {
        print LOGFILE "var_decl=", $var_decl, "\n";

        my $ismeta = ($count++ > @agent_var_array);

        if ( $var_decl =~ m/^const\s+/ ) {
          print  "WARNING: CONSTANT TRANS_VAR $var_decl not adding to copy/compare functions!\n";
          next PROC_VAR;
        }
        if ( $var_decl =~ m/^static\s+/ ) {
          print  "WARNING: STATIC TRANS_VAR $var_decl not adding to copy/compare functions!\n";
          next PROC_VAR;
        }
        if ( $var_decl =~ m/^typedef\s+/ ) {
          print LOGFILE "Found type definition $var_decl\n";
          next PROC_VAR;
        }
        if ( $var_decl =~ m/^constraint\s+/ ) {
          print LOGFILE "Found constraint $var_decl\n";
          next PROC_VAR;
        }
        if ( $var_decl =~ m/^\/\// ) {
          print LOGFILE "Found comment $var_decl\n";
          next PROC_VAR;
        }

        my $islocal = ($var_decl =~ m/local|protected/);

        my $stripped_decl = $var_decl;

        $stripped_decl =~ s/\[/ \[/g;        # Insert space before [
        $stripped_decl =~ s/\]/\] /g;        # Insert space after ]
        $stripped_decl =~ s/\[.+?:.+?\]//g;  # Remove array bounds of the form [a:b]

        print LOGFILE "stripped_decl=", $stripped_decl, "\n";

        @fields = split /[\s]+/, $stripped_decl; #split on space

        # get name of field to print, has to work with following examples
        # bit parity; // Variable is field 1 (parity)
        # rand bit [Dwidth - 1:0] payload []; // Variable is field 3 (payload)
        # local logic signed [3:0][7:0] vec; // Variable is field 4 (vec)
        my $pf = 0;    # Type Variable is simplest case
        if ( $fields[$pf] =~ m/rand|local|protected/ ) {
            #starts with "rand", "local" or "protected" so skip
            $pf++;
        }
        if ( $fields[$pf] =~ m/rand|local|protected/ ) {

            #skip "rand local", "local rand", "rand protected" or "protected rand" modifier
            $pf++;
        }
        if ( $fields[$pf + 1] =~ m/signed|unsigned/ ) {

            #skip signed or unsigned modifier
            $pf++;
        }
        while ( $fields[$pf] =~ m/^\d+:\d+/ ) {

            #skip packed dimensions (i.e. bit [7:0]
           $pf++;
        }
        $pf++; # Should now point to the variable

        my $var_name =  $fields[$pf];
        $var_name =~ s/;//;   #remove trailing ';'

        if ( (@fields > $pf + 1) && $fields[$pf + 1] =~ m/\[/ ) {
            # Found unpacked array dimension (e.g. type var [N]
            # Concatenate the remaining fields in case the unpacked range contained spaces was therefore split over multiple fields
            my $parse = "";
            for ($i = $pf + 1; $i < @fields; $i++) {
                $parse = $parse . $fields[$i];
            }
            $parse =~ /\[(.+)\].*/
              or die "Exiting due to Error: ran out of steam trying to parse unpacked array dimension\n";
            $unpacked_bound{$var_name} = $1;
        }

        push @all_tx_vars,       $var_name;
        push @non_local_tx_vars, $var_name unless $islocal || $ismeta || ( exists $unpacked_bound{$var_name} );
        push @non_meta_tx_vars,  $var_name unless $ismeta;

        foreach $i ( @agent_enum_array ) {
            if ( $var_decl eq $i ) {
                $enum_var_types{$var_name} = $fields[$pf-1];
                last;
            }
        }

        if ( $ismeta ) {
            print LOGFILE "METADATA type = $fields[$pf-1], var = $var_name\n";
        }
        else {
            print LOGFILE "VARIABLE type = $fields[$pf-1], var = $var_name\n";
        }
    }


    unless ( exists $agent_trans_generate_methods_after_class{$agent_name} && $agent_trans_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function void ${agent_item}::do_copy(uvm_object rhs);\n";
        print FH "  " . $agent_item . " rhs_;\n";
        print FH "  if (!\$cast(rhs_, rhs))\n";
        print FH "    `uvm_fatal(get_type_name(), \"Cast of rhs object failed\")\n";
        print FH "  super.do_copy(rhs);\n";


        foreach $field ( @all_tx_vars ) {
            align("  ${field} ", "= rhs_.${field};", "");
        }

        gen_aligned();

        print FH "endfunction : do_copy\n";

        print FH "\n";
        print FH "\n";
        print FH "function bit ${agent_item}::do_compare(uvm_object rhs, uvm_comparer comparer);\n";
        print FH "  bit result;\n";
        print FH "  " . $agent_item . " rhs_;\n";
        print FH "  if (!\$cast(rhs_, rhs))\n";
        print FH "    `uvm_fatal(get_type_name(), \"Cast of rhs object failed\")\n";
        print FH "  result = super.do_compare(rhs, comparer);\n";

        foreach $field ( @non_meta_tx_vars ) {
            if ( exists $unpacked_bound{$field} ) {
                align("  for (int i = 0; i < $unpacked_bound{$field}; i++)\n", "", "");
                align("    result &= comparer.compare_field(\"${field}\", ${field}[i], ", "rhs_.${field}[i], ", "\$bits(${field}[i]));");
            }
            else {
                align("  result &= comparer.compare_field(\"${field}\", ${field}, ", "rhs_.${field}, ", "\$bits(${field}));");
            }
        }
        gen_aligned();

        print FH "  return result;\n";
        print FH "endfunction : do_compare\n";
        print FH "\n";
        print FH "\n";

        print FH "function void ${agent_item}::do_print(uvm_printer printer);\n";
        print FH "  if (printer.knobs.sprint == 0)\n";
        print FH "    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)\n";
        print FH "  else\n";
        print FH "    printer.m_string = convert2string();\n";
        print FH "endfunction : do_print\n";
        print FH "\n";
        print FH "\n";

        print FH "function void ${agent_item}::do_record(uvm_recorder recorder);\n";
        print FH "  super.do_record(recorder);\n";
        print FH "  // Use the record macros to record the item fields:\n";

        foreach $field ( @all_tx_vars ) {
            if ( exists $unpacked_bound{$field} ) {
                align("  for (int i = 0; i < $unpacked_bound{$field}; i++)\n", "", "");
                align("    `uvm_record_field({\"${field}_\",\$sformatf(\"%0d\",i)}, ", "${field}[i])", "");
            }
            else {
                align("  `uvm_record_field(\"${field}\", ", "${field})", "");
            }
        }

        gen_aligned();

        print FH "endfunction : do_record\n";
        print FH "\n";
        print FH "\n";

        unless (defined $flag_nopack) {
            print FH "function void ${agent_item}::do_pack(uvm_packer packer);\n";
            print FH "  super.do_pack(packer);\n";

            foreach $field ( @non_meta_tx_vars ) {
                if ( exists $unpacked_bound{$field} ) {
                    align("  `uvm_pack_sarray(${field})", " ", "");
                }
                elsif ( exists $enum_var_types{$field} ) {
                    align("  `uvm_pack_enum(${field})", " ", "");
                }
                else {
                    align("  `uvm_pack_int(${field})", " ", "");
                }
            }

            gen_aligned();

            print FH "endfunction : do_pack\n";
            print FH "\n";
            print FH "\n";

            print FH "function void ${agent_item}::do_unpack(uvm_packer packer);\n";
            print FH "  super.do_unpack(packer);\n";

            foreach $field ( @non_meta_tx_vars ) {
                if ( exists $unpacked_bound{$field} ) {
                    align("  `uvm_unpack_sarray(${field})", " ", "");
                }
                elsif ( exists $enum_var_types{$field} ) {
                    align("  `uvm_unpack_enum(${field}, ", " $enum_var_types{$field})", "");
                }
                else {
                    align("  `uvm_unpack_int(${field})", " ", "");
                }
            }

            gen_aligned();

            print FH "endfunction : do_unpack\n";
            print FH "\n";
            print FH "\n";
        }

        print FH "function string ${agent_item}::convert2string();\n";
        print FH "  string s;\n";
        print FH "  \$sformat(s, \"%s\\n\", super.convert2string());\n";

        if ( @all_tx_vars > 0 ) {
            print FH "  \$sformat(s, {\"%s\\n\",\n";

            foreach $i ( 0 .. @all_tx_vars - 1) {
                $field = $all_tx_vars[$i];
                my $terminator = ( $i < @all_tx_vars - 1 ) ? "," : "},";
                my $formatting = exists $unpacked_bound{$field} ? "%p" : exists $enum_var_types{$field} ? "%s" : "'h%0h  'd%0d";
                align("    \"${field} ", "= ${formatting}\\n\"${terminator}", "");
            }
            gen_aligned();

            print FH "    get_full_name(),";
            foreach $i ( 0 .. @all_tx_vars - 1) {
                $field = $all_tx_vars[$i];
                if ( exists $unpacked_bound{$field} ) {
                    print FH " ${field}";
                }
                elsif ( exists $enum_var_types{$field} ) {
                    print FH " ${field}.name";
                }
                else {
                    print FH " ${field}, ${field}";
                }
                my $terminator = ( $i < @all_tx_vars - 1 ) ? "," : ");";
                print FH "$terminator";
            }
        }
        print FH "\n";
        print FH "  return s;\n";
        print FH "endfunction : convert2string\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $agent_trans_inc_after_class{$agent_name}, $agent_trans_inc_after_inline{$agent_name}, "trans_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_SEQ_ITEM_SV\n";
    print FH "\n";

    close(FH);
}    #end gen_data_item

sub gen_driver {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_driver.sv" )
      || die "Exiting due to Error: can't open driver: $agent_name";

    write_file_header "${agent_name}_driver.sv", "Driver for $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_DRIVER_SV\n";
    print FH "`define " . uc($agent_name) . "_DRIVER_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_driv_inc_before_class{$agent_name}, $agent_driv_inc_before_inline{$agent_name}, "driver_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_driver extends uvm_driver #(${agent_item});\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $agent_name . "_driver)\n";
    print FH "\n";

    my $interface_type;
    if ( $split_transactors eq "YES" ) {
      $interface_type = $agent_name . "_bfm";
    }
    elsif ( exists $byo_interface{$agent_name} ) {
      $interface_type = $byo_interface{$agent_name};
    }
    else {
      $interface_type = $agent_if;
    }
    print FH "  virtual ${interface_type} vif;\n";
    print FH "\n";
    print FH "  ${agent_name}_config     m_config;\n";
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";

    if ( exists $agent_driv_inc{$agent_name}
        && -e "${project}/tb/include/$agent_driv_inc{$agent_name}" ) {
        print FH "\n";
        print FH "  // Methods run_phase and do_drive generated by setting driver_inc in file $tpl_fname{$agent_name}\n";
        print FH "  extern task run_phase(uvm_phase phase);\n";
        print FH "  extern task do_drive();\n";
    }

    print FH "\n";

    insert_inc_file("  ", $agent_driv_inc_inside_class{$agent_name}, $agent_driv_inc_inside_inline{$agent_name}, "driver_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_driver \n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_name}_driver::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    if ( exists $agent_driv_inc{$agent_name}
        && -e "${project}/tb/include/$agent_driv_inc{$agent_name}" )
    {
        print FH "task " . $agent_name . "_driver::run_phase(uvm_phase phase);\n";

        print FH "  `uvm_info(get_type_name(), \"run_phase\", UVM_HIGH)\n";
        print FH "\n";

        print FH "  forever\n";
        print FH "  begin\n";
        print FH "    seq_item_port.get_next_item(req);\n";

        print FH "      `uvm_info(get_type_name(), {\"req item\\n\",req.sprint}, UVM_HIGH)\n";
        print FH "    do_drive();\n";
        print FH "    seq_item_port.item_done();\n";

        my $agent_clock = $agent_clock_array[0];
        if ( not $agent_clock or $agent_clock eq "" ) {
            print FH "    # 10ns;\n";
        }
        print FH "  end\n";
        print FH "endtask : run_phase\n";
        print FH "\n";
        print FH "\n";

        insert_inc_file("", $agent_driv_inc{$agent_name}, $agent_driv_inc_inline{$agent_name}, "", "");
    }

    insert_inc_file("", $agent_driv_inc_after_class{$agent_name}, $agent_driv_inc_after_inline{$agent_name}, "driver_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_DRIVER_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_monitor {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_monitor.sv" )
      || die "Exiting due to Error: can't open monitor: $agent_name";

    write_file_header "${agent_name}_monitor.sv", "Monitor for $agent_name";


    print FH "`ifndef " . uc($agent_name) . "_MONITOR_SV\n";
    print FH "`define " . uc($agent_name) . "_MONITOR_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_mon_inc_before_class{$agent_name}, $agent_mon_inc_before_inline{$agent_name}, "monitor_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_monitor extends uvm_monitor;\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $agent_name . "_monitor)\n";
    print FH "\n";

    my $interface_type;
    if ( $split_transactors eq "YES" ) {
      $interface_type = $agent_name . "_bfm";
    }
    elsif ( exists $byo_interface{$agent_name} ) {
      $interface_type = $byo_interface{$agent_name};
    }
    else {
      $interface_type = $agent_if;
    }
    print FH "  virtual ${interface_type} vif;\n";
    print FH "\n";
    print FH "  ${agent_name}_config     m_config;\n";
    print FH "\n";
    print FH "  uvm_analysis_port #(${agent_item}) analysis_port;\n";
    print FH "\n";

    if ( exists $agent_mon_inc{$agent_name}
        && -e "${project}/tb/include/$agent_mon_inc{$agent_name}" )
    {
        print FH "  ${agent_item} m_trans;\n";
        print FH "\n";
    }

    print FH "  extern function new(string name, uvm_component parent);\n";

    if ( exists $agent_mon_inc{$agent_name}
        && -e "${project}/tb/include/$agent_mon_inc{$agent_name}" )
    {
        print FH "\n";
        print FH "  // Methods run_phase, and do_mon generated by setting monitor_inc in file $tpl_fname{$agent_name}\n";
        print FH "  extern task run_phase(uvm_phase phase);\n";
        print FH "  extern task do_mon();\n";
    }
    print FH "\n";

    insert_inc_file("  ", $agent_mon_inc_inside_class{$agent_name}, $agent_mon_inc_inside_inline{$agent_name}, "monitor_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_monitor \n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_name}_monitor::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "  analysis_port = new(\"analysis_port\", this);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    if ( exists $agent_mon_inc{$agent_name}
        && -e "${project}/tb/include/$agent_mon_inc{$agent_name}" )
    {
        print FH "task ${agent_name}_monitor::run_phase(uvm_phase phase);\n";
        print FH "  `uvm_info(get_type_name(), \"run_phase\", UVM_HIGH)\n";
        print FH "\n";
        print FH "  m_trans = ${agent_item}::type_id::create(\"m_trans\");\n";
        print FH "  do_mon();\n";
        print FH "endtask : run_phase\n";
        print FH "\n";
        print FH "\n";

        insert_inc_file("", $agent_mon_inc{$agent_name}, $agent_mon_inc_inline{$agent_name}, "", "");
    }

    insert_inc_file("", $agent_mon_inc_after_class{$agent_name}, $agent_mon_inc_after_inline{$agent_name}, "monitor_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_MONITOR_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_sequencer {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_sequencer.sv" )
      || die "Exiting due to Error: can't open sequencer: $agent_name";
     write_file_header "${agent_name}_sequencer.sv", "Sequencer for $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_SEQUENCER_SV\n";
    print FH "`define " . uc($agent_name) . "_SEQUENCER_SV\n";
    print FH "\n";

    if ( $agent_seqr_class =~ /y|yes/i ) {
        insert_inc_file("", $agent_seqr_inc_before_class{$agent_name}, $agent_seqr_inc_before_inline{$agent_name}, "sequencer_inc_before_class", $tpl_fname{$agent_name});

        print FH "class ${agent_name}_sequencer extends uvm_sequencer #(${agent_item});\n";
        print FH "\n";
        print FH "  `uvm_component_utils(" . $agent_name . "_sequencer)\n";
        print FH "\n";
        print FH "  extern function new(string name, uvm_component parent);\n";
        print FH "\n";

        insert_inc_file("  ", $agent_seqr_inc_inside_class{$agent_name}, $agent_seqr_inc_inside_inline{$agent_name}, "sequencer_inc_inside_class", $tpl_fname{$agent_name});

        print FH "endclass : " . $agent_name . "_sequencer \n";
        print FH "\n";
        print FH "\n";
        print FH "function ${agent_name}_sequencer::new(string name, uvm_component parent);\n";
        print FH "  super.new(name, parent);\n";
        print FH "endfunction : new\n";
        print FH "\n";
        print FH "\n";

        insert_inc_file("", $agent_seqr_inc_after_class{$agent_name}, $agent_seqr_inc_after_inline{$agent_name}, "sequencer_inc_after_class", $tpl_fname{$agent_name});

        print FH "\n";
        print FH "typedef ${agent_name}_sequencer ${agent_name}_sequencer_t;\n";
    }
    else {
        print FH "// Sequencer class is specialization of uvm_sequencer\n";
        print FH "typedef uvm_sequencer #("
          . $agent_item . ") "
          . $agent_name
          . "_sequencer_t;\n";

    }
    print FH "\n";
    print FH "\n";
    print FH "`endif // " . uc($agent_name) . "_SEQUENCER_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_config {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_config.sv" )
      || die "Exiting due to Error: can't open config: $agent_name\n";
    write_file_header "${agent_name}_config.sv", "Configuration for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_CONFIG_SV\n";
    print FH "`define " . uc($agent_name) . "_CONFIG_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_config_inc_before_class{$agent_name}, $agent_config_inc_before_inline{$agent_name}, "agent_config_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_config extends uvm_object;\n";
    print FH "\n";
    print FH "  // Do not register config class with the factory\n";
    print FH "\n";

    my $interface_type;
    if ( $split_transactors eq "YES" ) {
      $interface_type = $agent_name . "_bfm";
    }
    elsif ( exists $byo_interface{$agent_name} ) {
      $interface_type = $byo_interface{$agent_name};
    }
    else {
      $interface_type = $agent_name . "_if";
    }
    align("  virtual ${interface_type} ", "vif;\n ", "");

    if ( exists $reg_access_mode{$agent_name} ) {
        align("  $reg_access_block_type{$agent_name}  ", "regmodel;\n", "");
    }

    align("  uvm_active_passive_enum  ", "is_active = UVM_ACTIVE;", "");
    align("  bit  ", "coverage_enable;", "");
    align("  bit  ", "checks_enable;", "");

    gen_aligned();

    print FH "\n";

    unless ( @config_var_array ) {
        print FH "  // You can insert variables here by setting config_var in file $tpl_fname{$agent_name}\n";
    }
    foreach my $var_decl (@config_var_array) {
        print FH "  $var_decl\n";
    }
    print FH "\n";

    unless ( exists $agent_config_generate_methods_inside_class{$agent_name} && $agent_config_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove new by setting agent_config_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function new(string name = \"\");\n";
        print FH "\n";
    }
    
    insert_inc_file("  ", $agent_config_inc_inside_class{$agent_name}, $agent_config_inc_inside_inline{$agent_name}, "agent_config_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_config \n";
    print FH "\n";
    print FH "\n";

    unless ( exists $agent_config_generate_methods_after_class{$agent_name} && $agent_config_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove new by setting agent_config_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function ${agent_name}_config::new(string name = \"\");\n";
        print FH "  super.new(name);\n";
        print FH "endfunction : new\n";
        print FH "\n";
        print FH "\n";
    }
    
    insert_inc_file("", $agent_config_inc_after_class{$agent_name}, $agent_config_inc_after_inline{$agent_name}, "agent_config_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_CONFIG_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_cov {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_coverage.sv" )
      || die "Exiting due to Error: can't open coverage: $agent_name";

    write_file_header "${agent_name}_coverage.sv", "Coverage for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_COVERAGE_SV\n";
    print FH "`define " . uc($agent_name) . "_COVERAGE_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_cover_inc_before_class{$agent_name}, $agent_cover_inc_before_inline{$agent_name}, "agent_cover_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_coverage extends uvm_subscriber #(${agent_item});\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $agent_name . "_coverage)\n";
    print FH "\n";

    align("  ${agent_name}_config ", "m_config;", "");
    align("  bit ", "m_is_covered;", "");
    align("  $agent_item ", "m_item;\n", "");
    gen_aligned();

    #if include file for coverage collector exists, pull it in here, otherwise
    #create covergroup and coverpoints with default bins
    if ( exists $agent_cover_inc{$agent_name}
        && -e "${project}/tb/include/$agent_cover_inc{$agent_name}" )
    {
             open(FH_COV, "<${project}/tb/include/$agent_cover_inc{$agent_name}") or die "CANNOT OPEN INCLUDE FILE agent_cover_inc{$agent_name}";
            my $cov_inc = join("",<FH_COV>);
            #check that file contains covergroup named "m_cov"
            unless ($cov_inc =~ /covergroup\s+m_cov(\s|;)/) {
                warning_prompt("COVERGROUP \"m_cov\" MUST BE DEFINED IN $agent_cover_inc{$agent_name}");
        }

        insert_inc_file("  ", $agent_cover_inc{$agent_name}, $agent_cover_inc_inline{$agent_name}, "", "");
    }
    else {
        unless ( exists $agent_cover_generate_methods_inside_class{$agent_name} && $agent_cover_generate_methods_inside_class{$agent_name} eq "NO" )
        {
            unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
                print FH "  // You can replace covergroup m_cov by setting agent_cover_inc in file $tpl_fname{$agent_name}\n";
                print FH "  // or remove covergroup m_cov by setting agent_cover_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
            }
            print FH "  covergroup m_cov;\n";
            print FH "    option.per_instance = 1;\n";
            print FH "    // You may insert additional coverpoints here ...\n";
            print FH "\n";
            foreach $field ( @non_local_tx_vars ) {
#                print FH "    cp_${i}: coverpoint m_item.${tmp};\n";
                print FH "    cp_${field}: coverpoint m_item.${field};\n";
                print FH "    //  Add bins here if required\n";
                print FH "\n";
            }
            print FH "  endgroup\n";
            print FH "\n";
        }
    }

    unless ( exists $agent_cover_generate_methods_inside_class{$agent_name} && $agent_cover_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove new, write, and report_phase by setting agent_cover_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function new(string name, uvm_component parent);\n";
        print FH "  extern function void write(input " . $agent_item . " t);\n";
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "  extern function void report_phase(uvm_phase phase);\n";
        print FH "\n";
    }

    insert_inc_file("  ", $agent_cover_inc_inside_class{$agent_name}, $agent_cover_inc_inside_inline{$agent_name}, "agent_cover_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_coverage \n";
    print FH "\n";
    print FH "\n";

    unless ( exists $agent_cover_generate_methods_after_class{$agent_name} && $agent_cover_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove new, write, and report_phase by setting agent_cover_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function ${agent_name}_coverage::new(string name, uvm_component parent);\n";
        print FH "  super.new(name, parent);\n";
        print FH "  m_is_covered = 0;\n";
        print FH "  m_cov = new();\n";
        print FH "endfunction : new\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_coverage::write(input ${agent_item} t);\n";
        print FH "  if (m_config.coverage_enable)\n";
        print FH "  begin\n";
        print FH "    m_item = t;\n";
        print FH "    m_cov.sample();\n";
        print FH "    // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it\n";
        print FH "    if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;\n";
        print FH "  end\n";
        print FH "endfunction : write\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_coverage::build_phase(uvm_phase phase);\n";
        print FH "  if (!uvm_config_db #(${agent_name}_config)::get(this, \"\", \"config\", m_config))\n";
        print FH "    `uvm_error(get_type_name(), \"${agent_name} config not found\")\n";
        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_coverage::report_phase(uvm_phase phase);\n";
        print FH "  if (m_config.coverage_enable)\n";
        print FH "    `uvm_info(get_type_name(), \$sformatf(\"Coverage score = %3.1f%%\", m_cov.get_inst_coverage()), UVM_MEDIUM)\n";
        print FH "  else\n";
        print FH "    `uvm_info(get_type_name(), \"Coverage disabled for this agent\", UVM_MEDIUM)\n";
        print FH "endfunction : report_phase\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $agent_cover_inc_after_class{$agent_name}, $agent_cover_inc_after_inline{$agent_name}, "agent_cover_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_COVERAGE_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_agent {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_agent.sv" )
      || die "Exiting due to Error: can't open agent: $agent_name";

    write_file_header "${agent_name}_agent.sv", "Agent for $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_AGENT_SV\n";
    print FH "`define " . uc($agent_name) . "_AGENT_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_inc_before_class{$agent_name}, $agent_inc_before_inline{$agent_name}, "agent_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_agent extends uvm_agent;\n";
    print FH "\n";
    print FH "  `uvm_component_utils(${agent_name}_agent)\n";
    print FH "\n";
    print FH "  uvm_analysis_port #(${agent_item}) analysis_port;\n";
    print FH "\n";
    print FH "  ${agent_name}_config       m_config;\n";
    print FH "  ${agent_name}_sequencer_t  m_sequencer;\n";
    print FH "  ${agent_name}_driver       m_driver;\n";
    print FH "  ${agent_name}_monitor      m_monitor;\n";
    print FH "\n";
    print FH "  local int m_is_active = -1;\n";
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";
    print FH "\n";

    unless ( exists $agent_generate_methods_inside_class{$agent_name} && $agent_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove build/connect_phase and get_is_active by setting agent_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "  extern function void connect_phase(uvm_phase phase);\n";
        print FH "  extern function uvm_active_passive_enum get_is_active();\n";
        print FH "\n";
    }

    insert_inc_file("  ", $agent_inc_inside_class{$agent_name}, $agent_inc_inside_inline{$agent_name}, "agent_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_agent \n";
    print FH "\n";
    print FH "\n";

    print FH "function  ${agent_name}_agent::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "  analysis_port = new(\"analysis_port\", this);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    unless ( exists $agent_generate_methods_after_class{$agent_name} && $agent_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove build/connect_phase and get_is_active by setting agent_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function void ${agent_name}_agent::build_phase(uvm_phase phase);\n";
        print FH "\n";

        insert_inc_file("  ", $agent_prepend_to_build_phase{$agent_name}, $agent_prepend_to_build_phase_inline{$agent_name}, "agent_prepend_to_build_phase", $tpl_fname{$agent_name});

        print FH "  if (!uvm_config_db #(${agent_name}_config)::get(this, \"\", \"config\", m_config))\n";
        print FH "    `uvm_error(get_type_name(), \"${agent_name} config not found\")\n";
        print FH "\n";

        print FH "  m_monitor     = ${agent_name}_monitor    ::type_id::create(\"m_monitor\", this);\n";
        print FH "\n";
        print FH "  if (get_is_active() == UVM_ACTIVE)\n";
        print FH "  begin\n";
        print FH "    m_driver    = ${agent_name}_driver     ::type_id::create(\"m_driver\", this);\n";
        print FH "    m_sequencer = ${agent_name}_sequencer_t::type_id::create(\"m_sequencer\", this);\n";
        print FH "  end\n";
        print FH "\n";

        insert_inc_file("  ", $agent_append_to_build_phase{$agent_name}, $agent_append_to_build_phase_inline{$agent_name}, "agent_append_to_build_phase", $tpl_fname{$agent_name});

        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_agent::connect_phase(uvm_phase phase);\n";
        print FH "  if (m_config.vif == null)\n";
        print FH "    `uvm_warning(get_type_name(), \"${agent_name} virtual interface is not set!\")\n";
        print FH "\n";
        print FH "  m_monitor.vif      = m_config.vif;\n";
        print FH "  m_monitor.m_config = m_config;\n";
        print FH "  m_monitor.analysis_port.connect(analysis_port);\n";
        print FH "\n";
        print FH "  if (get_is_active() == UVM_ACTIVE)\n";
        print FH "  begin\n";
        print FH "    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);\n";
        print FH "    m_driver.vif      = m_config.vif;\n";
        print FH "    m_driver.m_config = m_config;\n";
        print FH "  end\n";
        print FH "\n";

        insert_inc_file("  ", $agent_append_to_connect_phase{$agent_name}, $agent_append_to_connect_phase_inline{$agent_name}, "agent_append_to_connect_phase", $tpl_fname{$agent_name});

        print FH "endfunction : connect_phase\n";
        print FH "\n";
        print FH "\n";
        print FH "function uvm_active_passive_enum ${agent_name}_agent::get_is_active();\n";
        print FH "  if (m_is_active == -1)\n";
        print FH "  begin\n";
        print FH "    if (uvm_config_db#(uvm_bitstream_t)::get(this, \"\", \"is_active\", m_is_active))\n";
        print FH "    begin\n";
        print FH "      if (m_is_active != m_config.is_active)\n";
        print FH "        `uvm_warning(get_type_name(), \"is_active field in config_db conflicts with config object\")\n";
        print FH "    end\n";
        print FH "    else \n";
        print FH "      m_is_active = m_config.is_active;\n";
        print FH "  end\n";
        print FH "  return uvm_active_passive_enum'(m_is_active);\n";
        print FH "endfunction : get_is_active\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $agent_inc_after_class{$agent_name}, $agent_inc_after_inline{$agent_name}, "agent_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_AGENT_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_env {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_env.sv" )
      || die "Exiting due to Error: can't open env: $agent_name";

    write_file_header "${agent_name}_env.sv", "Environment for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_ENV_SV\n";
    print FH "`define " . uc($agent_name) . "_ENV_SV\n";
    print FH "\n";

    insert_inc_file("", $agent_env_inc_before_class{$agent_name}, $agent_env_inc_before_inline{$agent_name}, "agent_env_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_env extends uvm_env;\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $agent_name . "_env)\n";
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";
    print FH "\n";

    for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
        my $suffix = calc_suffix($i, $number_of_instances{$agent_name});

        align("  ${agent_name}_config ", "m_${agent_name}${suffix}_config;", "");
        align("  ${agent_name}_agent ", "m_${agent_name}${suffix}_agent;", "");
        align("  ${agent_name}_coverage ", "m_${agent_name}${suffix}_coverage;", "");
        if ( exists $reg_access_mode{$agent_name} ) {
            align("  ${agent_name}_env_coverage ", "m_${agent_name}${suffix}_env_coverage;", "");
            align("  $reg_access_block_type{$agent_name} ", "regmodel${suffix};  // Register model", "");
            align("\n", "", "");
            align("  reg2${agent_name}_adapter ", "m_reg2${agent_name}${suffix};", "");
            align("  uvm_reg_predictor #($agent_item_types{$agent_name}) ", "m_${agent_name}2reg_predictor${suffix};", "");
        }
        align("\n", "", "");
    }
    gen_aligned();

    #add any other agents (%env_agents is hash of ref to array)
    do {
        foreach my $extra_agent ( @{ $env_agents{"${agent_name}_env"} } ) {
            print LOGFILE "adding extra agent $extra_agent\n";
            print FH "  ${extra_agent}_config    m_${extra_agent}_config;\n";
            print FH "  ${extra_agent}_agent     m_${extra_agent}_agent;\n";
            print FH "  ${extra_agent}_coverage  m_${extra_agent}_coverage;\n";
            print FH "\n";
        }
    } if exists $env_agents{"${agent_name}_env"};

    unless ( exists $agent_env_generate_methods_inside_class{$agent_name} && $agent_env_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove build_phase and connect_phase by setting agent_env_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "  extern function void connect_phase(uvm_phase phase);\n";
        print FH "\n";
    }

    insert_inc_file("  ", $agent_env_inc_inside_class{$agent_name}, $agent_env_inc_inside_inline{$agent_name}, "agent_env_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_env \n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_name}_env::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    unless ( exists $agent_env_generate_methods_after_class{$agent_name} && $agent_env_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove build_phase and connect_phase by setting agent_env_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function void ${agent_name}_env::build_phase(uvm_phase phase);\n";
        print FH "\n";

        insert_inc_file("  ", $agent_env_prepend_to_build_phase{$agent_name}, $agent_env_prepend_to_build_phase_inline{$agent_name}, "agent_env_prepend_to_build_phase", $tpl_fname{$agent_name});

        for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$agent_name});

            if ($i > 0) { print FH "\n"; }

            print FH "  if (!uvm_config_db #(${agent_name}_config)::get(this, \"\", \"config${suffix}\", m_${agent_name}${suffix}_config))\n";
            print FH "    `uvm_error(get_type_name(), \"Unable to get config from configuration database\")\n";
            print FH "  regmodel${suffix} = m_${agent_name}${suffix}_config.regmodel;\n" if exists $reg_access_mode{$agent_name};
            print FH "\n";
            print FH "  uvm_config_db #(${agent_name}_config)::set(this, \"m_${agent_name}${suffix}_agent\", \"config\", m_${agent_name}${suffix}_config);\n";
            print FH "  if (m_${agent_name}${suffix}_config.is_active == UVM_ACTIVE )\n";
            print FH "    uvm_config_db #(${agent_name}_config)::set(this, \"m_${agent_name}${suffix}_agent.m_sequencer\", \"config\", m_${agent_name}${suffix}_config);\n";
            print FH "  uvm_config_db #(${agent_name}_config)::set(this, \"m_${agent_name}${suffix}_coverage\", \"config\", m_${agent_name}${suffix}_config);\n";
            if ( exists $reg_access_mode{$agent_name} ) {
                print FH "  uvm_config_db #(${agent_name}_config)::set(this, \"m_${agent_name}${suffix}_env_coverage\", \"config\", m_${agent_name}${suffix}_config);\n";
            }
            print FH "\n";
            print FH "  m_${agent_name}${suffix}_agent    = ${agent_name}_agent   ::type_id::create(\"m_${agent_name}${suffix}_agent\", this);\n";
            print FH "\n";
            print FH "  m_${agent_name}${suffix}_coverage = ${agent_name}_coverage::type_id::create(\"m_${agent_name}${suffix}_coverage\", this);\n";
            if ( exists $reg_access_mode{$agent_name} ) {
                print FH "  m_${agent_name}${suffix}_env_coverage  = ${agent_name}_env_coverage::type_id::create(\"m_${agent_name}${suffix}_env_coverage\", this);\n";
                print FH "  m_reg2${agent_name}${suffix}           = reg2${agent_name}_adapter ::type_id::create(\"m_reg2${agent_name}${suffix}\", this);\n";
                print FH "\n";
                print FH "  m_${agent_name}2reg_predictor${suffix} = ";
                print FH "uvm_reg_predictor #($agent_item_types{$agent_name})::type_id::create(\"m_${agent_name}2reg_predictor${suffix}\", this);\n";
            }
        }

        do {
            print FH "\n";
            print FH "  // Additional agents";
            foreach my $extra_agent ( @{ $env_agents{"${agent_name}_env"} } ) {
                print FH "\n";
                print FH "  if (!uvm_config_db #(${extra_agent}_config)::get(this, \"\", \"config\", m_${extra_agent}_config))\n";
                print FH "    `uvm_error(get_type_name(), \"Unable to get ${extra_agent}_config from configuration database\")\n";
                print FH "\n";
                print FH "  uvm_config_db #(${extra_agent}_config)::set(this, \"m_${extra_agent}_agent\", \"config\",  m_${extra_agent}_config);\n";
                print FH "  if (m_${extra_agent}_config.is_active == UVM_ACTIVE )\n";
                print FH "    uvm_config_db #(${extra_agent}_config)::set(this, \"m_${extra_agent}_agent.m_sequencer\", \"config\",  m_${extra_agent}_config);\n";
                print FH "  uvm_config_db #(${extra_agent}_config)::set(this, \"m_${extra_agent}_coverage\", \"config\",  m_${extra_agent}_config);\n";
                print FH "\n";
                print FH "  m_${extra_agent}_agent    = ${extra_agent}_agent   ::type_id::create(\"m_${extra_agent}_agent\", this);\n";
                print FH "  m_${extra_agent}_coverage = ${extra_agent}_coverage::type_id::create(\"m_${extra_agent}_coverage\", this);\n";
            }
        } if exists $env_agents{"${agent_name}_env"};
        print FH "\n";

        insert_inc_file("  ", $agent_env_append_to_build_phase{$agent_name}, $agent_env_append_to_build_phase_inline{$agent_name}, "agent_env_append_to_build_phase", $tpl_fname{$agent_name});

        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";

        print FH "function void ${agent_name}_env::connect_phase(uvm_phase phase);\n";
        print FH "\n";

        for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$agent_name});

            align("  m_${agent_name}${suffix}_agent", ".analysis_port.connect(m_${agent_name}${suffix}_coverage.analysis_export);\n", "");

             if ( exists $reg_access_mode{$agent_name} ) {
                align("  m_${agent_name}${suffix}_agent", ".analysis_port.connect(m_${agent_name}2reg_predictor${suffix}.bus_in);\n", "");
                align("  m_${agent_name}${suffix}_agent", ".analysis_port.connect(m_${agent_name}${suffix}_env_coverage.analysis_export);\n", "");
                align("  m_${agent_name}${suffix}_env_coverage.regmodel = regmodel${suffix};\n", "", "");
            }
        }

        do {
            foreach my $extra_agent ( @{ $env_agents{"${agent_name}_env"} } ) {
                align("  m_${extra_agent}_agent", ".analysis_port.connect(m_${extra_agent}_coverage.analysis_export);", "");
            }
        } if exists $env_agents{"${agent_name}_env"};

        gen_aligned();

        print FH "\n";

        insert_inc_file("  ", $agent_env_append_to_connect_phase{$agent_name}, $agent_env_append_to_connect_phase_inline{$agent_name}, "agent_env_append_to_connect_phase", $tpl_fname{$agent_name});

        print FH "endfunction : connect_phase\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $agent_env_inc_after_class{$agent_name}, $agent_env_inc_after_inline{$agent_name}, "agent_env_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_ENV_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_seq_lib {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_seq_lib.sv" )
      || die "Exiting due to Error: can't open seq_lib: $agent_name";

    write_file_header "${agent_name}_seq_lib.sv", "Sequence for agent $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_SEQ_LIB_SV\n";
    print FH "`define " . uc($agent_name) . "_SEQ_LIB_SV\n";
    print FH "\n";

    print FH "class ${agent_name}_default_seq extends uvm_sequence #($agent_item);\n";
    print FH "\n";
    print FH "  `uvm_object_utils(" . $agent_name . "_default_seq)\n";
    print FH "\n";

    print FH "  ${agent_name}_config  m_config;\n";
    print FH "\n";
    print FH "  extern function new(string name = \"\");\n";
    print FH "  extern task body();\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "  // Functions to support UVM 1.2 objection API in UVM 1.1\n";
    print FH "  extern function uvm_phase get_starting_phase();\n";
    print FH "  extern function void set_starting_phase(uvm_phase phase);\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "endclass : " . $agent_name . "_default_seq\n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_name}_default_seq::new(string name = \"\");\n";
    print FH "  super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";
    print FH "task ${agent_name}_default_seq::body();\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence starting\", UVM_HIGH)\n";
    print FH "\n";
    print FH "  req = " . $agent_item . "::type_id::create(\"req\");\n";
    print FH "  start_item(req); \n";
    print FH "  if ( !req.randomize() )\n";
    print FH "    `uvm_error(get_type_name(), \"Failed to randomize transaction\")\n";
    print FH "  finish_item(req); \n";
    print FH "\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence completed\", UVM_HIGH)\n";
    print FH "endtask : body\n";
    print FH "\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "function uvm_phase ${agent_name}_default_seq::get_starting_phase();\n";
    print FH "  return starting_phase;\n";
    print FH "endfunction: get_starting_phase\n";
    print FH "\n";
    print FH "\n";
    print FH "function void ${agent_name}_default_seq::set_starting_phase(uvm_phase phase);\n";
    print FH "  starting_phase = phase;\n";
    print FH "endfunction: set_starting_phase\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "\n";

    insert_inc_file("", $agent_seq_inc{$agent_name}, $agent_seq_inc_inline{$agent_name}, "agent_seq_inc", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_SEQ_LIB_SV\n";
    print FH "\n";

    close(FH);
}

sub gen_env_seq_lib {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_env_seq_lib.sv" )
      || die "Exiting due to Error: can't open env_seq_lib: $agent_name";

    write_file_header "${agent_name}_env_seq_lib.sv", "Sequence for $agent_name";

    print FH "`ifndef " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "`define " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "\n";

    print FH "class ${agent_name}_env_default_seq extends uvm_sequence #(uvm_sequence_item);\n";
    print FH "\n";
    print FH "  `uvm_object_utils(" . $agent_name . "_env_default_seq)\n";
    print FH "\n";
    print FH "  ${agent_name}_env m_env;\n";
    print FH "\n";
    print FH "  extern function new(string name = \"\");\n";
    print FH "  extern task body();\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "  // Functions to support UVM 1.2 objection API in UVM 1.1\n";
    print FH "  extern function uvm_phase get_starting_phase();\n";
    print FH "  extern function void set_starting_phase(uvm_phase phase);\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "endclass : " . $agent_name . "_env_default_seq\n";
    print FH "\n";
    print FH "\n";
    print FH "function  ${agent_name}_env_default_seq::new(string name = \"\");\n";
    print FH "  super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";
    print FH "task ${agent_name}_env_default_seq::body();\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence starting\", UVM_HIGH)\n";
    print FH "\n";

    print FH
      "  // Note: there can be multiple child sequences started concurrently within this fork..join\n";
    print FH "  fork\n";

    for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
        my $suffix = calc_suffix($i, $number_of_instances{$agent_name});
        my $sequencer_instance_name = "m_env.m_${agent_name}${suffix}_agent.m_sequencer";

        if ( $i > 0 ) { print FH "\n"; }

        print FH "    if (m_env.m_${agent_name}${suffix}_config.is_active == UVM_ACTIVE)\n";
        print FH "    begin\n";
        print FH "      ${agent_name}_default_seq seq;\n";
        print FH "      seq = ${agent_name}_default_seq::type_id::create(\"seq${suffix}\");\n";
        print FH "      seq.set_item_context(this, ${sequencer_instance_name});\n";
        print FH "      if ( !seq.randomize() )\n";
        print FH "        `uvm_error(get_type_name(), \"Failed to randomize sequence\")\n";
        print FH "      seq.m_config = m_env.m_${agent_name}${suffix}_config;\n";
        print FH "      seq.set_starting_phase( get_starting_phase() );\n";
        print FH "      seq.start(${sequencer_instance_name}, this);\n";
        print FH "    end\n";

    }

    foreach my $extra_agent ( @{ $env_agents{"${agent_name}_env"} } ) {
        my $sequencer_instance_name = "m_env.m_${extra_agent}_agent.m_sequencer";

        print FH "\n";
        print FH "    if (m_env.m_${extra_agent}_agent.m_config.is_active == UVM_ACTIVE)\n";
        print FH "    begin\n";
        print FH "      ${extra_agent}_default_seq seq;\n";
        print FH "      seq = ${extra_agent}_default_seq::type_id::create(\"seq\");\n";
        print FH "      seq.set_item_context(this, ${sequencer_instance_name});\n";
        print FH "      if ( !seq.randomize() )\n";
        print FH "        `uvm_error(get_type_name(), \"Failed to randomize sequence\")\n";
        print FH "      seq.m_config = m_env.m_${extra_agent}_agent.m_config;\n";
        print FH "      seq.set_starting_phase( get_starting_phase() );\n";
        print FH "      seq.start(${sequencer_instance_name}, this);\n";
        print FH "    end\n";
    }
    print FH "  join\n";
    print FH "\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence completed\", UVM_HIGH)\n";
    print FH "endtask : body\n";

    print FH "\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "function uvm_phase ${agent_name}_env_default_seq::get_starting_phase();\n";
    print FH "  return starting_phase;\n";
    print FH "endfunction: get_starting_phase\n";
    print FH "\n";
    print FH "\n";
    print FH "function void ${agent_name}_env_default_seq::set_starting_phase(uvm_phase phase);\n";
    print FH "  starting_phase = phase;\n";
    print FH "endfunction: set_starting_phase\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "\n";

    insert_inc_file("", $agent_env_seq_inc{$agent_name}, $agent_env_seq_inc_inline{$agent_name}, "agent_env_seq_inc", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "\n";

    close(FH);
}

sub gen_agent_pkg {

    ### file list for files in sv directoru (.svh file)
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_pkg.sv" )
      || die "Exiting due to Error: can't open include file: $agent_name";

    write_file_header "${agent_name}_pkg.sv", "Package for agent $agent_name";

    print FH "package ${agent_name}_pkg;\n";
    print FH "\n";
    print FH "  `include \"uvm_macros.svh\"\n";
    print FH "\n";
    print FH "  import uvm_pkg::*;\n";
    print FH "\n";
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;
    print FH "  import regmodel_pkg::*;\n" if exists $reg_access_mode{$agent_name};
    do {
        foreach my $extra_agent ( @{ $env_agents{"${agent_name}_env"} } ) {
            print FH "  import ${extra_agent}_pkg::*;\n";
        }
    } if exists $env_agents{"${agent_name}_env"};
    print FH "\n";
    print FH "  `include \"${agent_name}_${agent_item}.sv\"\n";

    print FH "  `include \"" . $agent_name . "_config.sv\"\n";
    print FH "  `include \"" . $agent_name . "_driver.sv\"\n";
    print FH "  `include \"" . $agent_name . "_monitor.sv\"\n";
    print FH "  `include \"" . $agent_name . "_sequencer.sv\"\n";
    print FH "  `include \"" . $agent_name . "_coverage.sv\"\n";
    print FH "  `include \"" . $agent_name . "_agent.sv\"\n";
    print FH "  `include \"" . $agent_name . "_seq_lib.sv\"\n";
    if ( exists $reg_access_mode{$agent_name} ) {
        print FH "  `include \"reg2" . $agent_name . "_adapter.sv\"\n";
        print FH "  `include \"" . $agent_name . "_env_coverage.sv\"\n";
    }
    do {
        print FH "  `include \"" . $agent_name . "_env.sv\"\n";
        print FH "  `include \"" . $agent_name . "_env_seq_lib.sv\"\n";
    } unless $agent_has_env eq "NO";
    print FH "\n";
    print FH "endpackage : ${agent_name}_pkg\n";
    close(FH);
}

sub gen_top_pkg {

    ### file list for files in sv directoru (.svh file)
    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/" . $tbname . "_pkg.sv" )
      || die "Exiting due to Error: can't open include file: $tbname";

    write_file_header "${tbname}_pkg.sv", "Package for $tbname";

    print FH "package " . $tbname . "_pkg;\n";
    print FH "\n";
    print FH "  `include \"uvm_macros.svh\"\n";
    print FH "\n";
    print FH "  import uvm_pkg::*;\n";
    print FH "\n";
    print FH "  import regmodel_pkg::*;\n" if $regmodel;
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;

    foreach my $agent (@agent_list) {
        print FH "  import ${agent}_pkg::*;\n";
    }

    print FH "\n";
    print FH "  `include \"" . $tbname . "_config.sv\"\n";
    print FH "  `include \"" . $tbname . "_seq_lib.sv\"\n";

    if ( keys %ref_model ) {
        print FH "  `include \"port_converter.sv\"\n";
    }

    foreach my $ref_model_name ( keys(%ref_model) ) {
        print FH "  `include \"$ref_model_name.sv\"\n";
    }

    print FH "  `include \"" . $tbname . "_env.sv\"\n";
    print FH "\n";
    print FH "endpackage : " . $tbname . "_pkg\n";
    print FH "\n";
    close(FH);
}

sub gen_dut_inst() {
    my $port_list_file = $dut_pfile;
    open( PFH, $port_list_file )
      or die "Exiting due to Error: can't open template: ${port_list_file}\n";

    #skip empty lines
    my $line = "";
  SKIP_BL: while (<PFH>) {
        if (/\w+/) {
            $line = $_;
            last SKIP_BL;
        }
    }
    $line
      or die "Exiting due to Error: dut_pfile $dut_pfile exists but is empty\n";
    my $if_name  = $1;

    my @param_list1;
    my @param_list2;
    my @param_list3;

    my @port_list1;
    my @port_list2;
    my @port_list3;

    my $count_of_trailing_comments = 0;

  XPROC_INTF: while ($line) {
        if ($if_name) {
# The name in the pinlist file was originally an interface name but can now be a user-defined interface instance name instead
            if ( exists $if_instance_names{$if_name} ) {
              $if_name = $if_instance_names{$if_name};
            }
            print LOGFILE "Writing ports for interface $if_name\n";
        }
        
        while ($line) {
            if ( $line =~ m/\s*#/ ) {    #script comments - ignore
                $line = <PFH>;
                next XPROC_INTF;
            }
            elsif ( $line =~ m!^\s*//.*\n! ) {    #SV comments
                 push @port_list1, "    $&";
                 push @port_list2, "";
                 $count_of_trailing_comments++;
            }
            elsif ( $line =~ m/^\s*PAR\s*(\||\=)\s*(\S+)\s+(\S+)\n/ ) {    #parameters
                push @param_list1, "    .$2";
                push @param_list2, "($3),";
            }
            elsif ( $line =~ /^\s*(\S+)\s+(\S+)\s*\n/ ) {    #ports
                if ($if_name) {
                    push @port_list1, "    .$1";
                    push @port_list2, "($if_name.$2),";
                }
                else {
                    push @port_list1, "    .$1";
                    push @port_list2, "($2),";
                }
                $count_of_trailing_comments = 0;
            }
            elsif ( $line =~ /\s*DEC\s*(\||\=)\s*(.+)\s*\n/ ) {    #variable dec
                print FH "  $2\n";
            }
            elsif ( $line =~ /!(\w+){0,1}/ ) {                #next if_name
                $if_name = ( $1 and $1 ne "none" ) ? $1 : "";
                $line = <PFH>;
                next XPROC_INTF;
            }
            $line = <PFH>;
        }
    }    #XPROC_INTF

    print FH "  $dut_top ";
    if (@param_list1) {
        chop($param_list2[-1]);  #remove trailing ','
        print FH "#(\n";
        pretty_print(\@param_list1, \@param_list2, \@param_list3);
        print FH "  )\n  ";
    }
    print FH "${dut_iname} (\n";
    if (@port_list2) { chop($port_list2[-1-$count_of_trailing_comments]); }    #remove trailing ','
    pretty_print(\@port_list1, \@port_list2, \@port_list3);
    print FH "  );\n";
}


sub gen_top_env {
    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/" . $tbname . "_env.sv" )
      || die "Exiting due to Error: can't open env: $tbname";

    write_file_header "${tbname}_env.sv", "Environment for $tbname";

    print FH "`ifndef " . uc($tbname) . "_ENV_SV\n";
    print FH "`define " . uc($tbname) . "_ENV_SV\n";
    print FH "\n";

    insert_inc_file("", $top_env_inc_before_class, $top_env_inc_before_inline, "top_env_inc_before_class", $common_tpl_fname);

    if ( keys %ref_model ) {
        print FH "import pk_syoscb::*;\n";
        print FH "\n";
    }

    print FH "class ${tbname}_env extends uvm_env;\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $tbname . "_env)\n";
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";
    print FH "\n";

    if ( keys %ref_model ) {
        print FH "  // Reference model and Syosil scoreboard\n";
    }
    foreach my $ref_model_name ( keys(%ref_model) ) {
        #foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        #    $agent_name = ${agent_type_by_inst{$input}};
        #    my $name = $input;
        #    $name =~ s/\./__/g;
        #    align("  typedef port_converter #($agent_item_types{$agent_name}) ", "converter_${name}_t;", "");
        #}
        foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
            $agent_name = ${agent_type_by_inst{$output}};
            my $name = $output;
            $name =~ s/\./__/g;
            align("  typedef port_converter #($agent_item_types{$agent_name}) ", "converter_${name}_t;", "");
        }
    }
    gen_aligned();
    print FH "\n";

    foreach my $ref_model_name ( keys(%ref_model) ) {

        #foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        #    my $name = $input;
        #    $name =~ s/\./__/g;
        #    align("  converter_${name}_t ", "m_converter_${name};", "");
        #}
        foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
            my $name = $output;
            $name =~ s/\./__/g;
            align("  converter_${name}_t ", "m_converter_${name};", "");
        }

        align("\n", "", "");
        align("  $ref_model_name ", "m_${ref_model_name};", "");
        align("  cl_syoscb ", "m_${ref_model_name}_scoreboard;", "");
        align("  cl_syoscb_cfg ", "m_${ref_model_name}_config;", "");
        align("\n", "", "");
    }
    gen_aligned();

    print FH "  // Child environments\n" if @env_list;

    foreach my $agent_env (@env_list) {
        align("  ${agent_env}  ", "m_${agent_env};", "");
    }
    align("\n", "", "") if @env_list;

    foreach my $agent (@agent_list) {

        for ( my $i = 0 ; $i < $number_of_instances{$agent} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$agent});

            do {
                align("  ${agent}_config  ", "m_${agent}${suffix}_config;", "");
            } unless grep( /$agent/, @top_env_agents );
        }
    }

    align("\n", "", "") if @env_list;
    align("  // Child agents\n", "", "") if @top_env_agents;

    foreach $aname (@top_env_agents) {

        for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$aname});

                align("  ${aname}_config  ", "m_${aname}${suffix}_config;", "");
                align("  ${aname}_agent  ", "m_${aname}${suffix}_agent;", "");
                align("  ${aname}_coverage  ", "m_${aname}${suffix}_coverage;", "");
                align("\n", "", "");
        }
    }

    if ( $regmodel ) {
                align("  // Register model\n", "", "");
                align("  $top_reg_block_type  ", "regmodel;", "");
    }

    align("  ${tbname}_config ", "m_config;\n", "");

    gen_aligned();

    unless ( defined $top_env_generate_methods_inside_class && $top_env_generate_methods_inside_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove build/connect/run_phase by setting top_env_generate_methods_inside_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "  extern function void connect_phase(uvm_phase phase);\n";
        unless ( defined $top_env_generate_end_of_elaboration && $top_env_generate_end_of_elaboration eq "NO" )
        {
            print FH "  extern function void end_of_elaboration_phase(uvm_phase phase);\n";
        }
        unless ( defined $top_env_generate_run_phase && $top_env_generate_run_phase eq "NO" )
        {
            print FH "  extern task          run_phase(uvm_phase phase);\n";
        }
        print FH "\n";
    }

    insert_inc_file("  ", $top_env_inc_inside_class, $top_env_inc_inside_inline, "top_env_inc_inside_class", $common_tpl_fname);

    print FH "endclass : " . $tbname . "_env \n";
    print FH "\n";
    print FH "\n";
    print FH "function ${tbname}_env::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    unless ( defined $top_env_generate_methods_after_class && $top_env_generate_methods_after_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove build/connect/run_phase by setting top_env_generate_methods_after_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "function void ${tbname}_env::build_phase(uvm_phase phase);\n";
        print FH "  `uvm_info(get_type_name(), \"In build_phase\", UVM_HIGH)\n";
        print FH "\n";

        insert_inc_file("  ", $top_env_prepend_to_build_phase, $top_env_prepend_to_build_phase_inline, "top_env_prepend_to_build_phase", $common_tpl_fname);

        print FH "  if (!uvm_config_db #(${tbname}_config)::get(this, \"\", \"config\", m_config)) \n";
        print FH "    `uvm_error(get_type_name(), \"Unable to get ${tbname}_config\")\n";

        do {
            print FH "\n";
            print FH "  regmodel = ${top_reg_block_type}::type_id::create(\"regmodel\");\n";
            print FH "  regmodel.build();\n";
        } if $regmodel;

        foreach my $agent (@agent_list) {
            for ( my $i = 0 ; $i < $number_of_instances{$agent} ; $i++ ) {                                                                                                         
                my $suffix = calc_suffix($i, $number_of_instances{$agent});                                                                                                        

                align("\n", "", "");                                                                                                                                               
                if ( defined $nested_config_objects && $nested_config_objects eq "YES" ) {
                    align("  m_${agent}${suffix}_config ", "= m_config.m_${agent}${suffix}_config;", "");
                }
                else {
                    align("  m_${agent}${suffix}_config ", "= new(\"m_${agent}${suffix}_config\");", "");                                                                              
                    align("  m_${agent}${suffix}_config.vif ", "= m_config.${agent}${suffix}_vif;", "");                                                                               
                    align("  m_${agent}${suffix}_config.is_active ", "= m_config.is_active_${agent}${suffix};", "");                                                                   
                }
                if ( exists $reg_access_mode{$agent} ) {                                                                                                                           

                    my $value;                                                                                                                                                     
                    if ( ${reg_access_instance{$agent}} ne "" ) {                                                                                                                  
                        $value = "regmodel${reg_access_instance{$agent}}${suffix}";                                                                                                
                    }                                                                                                                                                              
                    else {                                                                                                                                                         
                        $value = "regmodel";                                                                                                                                       
                    }                                                                                                                                                              
                    align("  m_${agent}${suffix}_config.regmodel ", "= ${value};", "");                                                                                            
                }                                                                                                                                                                  

                unless ( defined $nested_config_objects && $nested_config_objects eq "YES" ) {
                    align("  m_${agent}${suffix}_config.checks_enable ", "= m_config.checks_enable_${agent}${suffix};", "");                                                           
                    align("  m_${agent}${suffix}_config.coverage_enable ", "= m_config.coverage_enable_${agent}${suffix};", "");
                }
                gen_aligned();                                                                                                                                                     
            }                                                                                                                                                                      

            print FH "\n";
            insert_inc_file("  ", $agent_copy_config_vars{$agent}, $agent_copy_config_vars_inline{$agent}, "agent_copy_config_vars", $tpl_fname{$agent});                          

            for ( my $i = 0 ; $i < $number_of_instances{$agent} ; $i++ ) {                                                                                                         
                my $suffix = calc_suffix($i, $number_of_instances{$agent});                                                                                                        

                if ( grep( /$agent/, @stand_alone_agents ) ) {                                                                                                                     
                    # agent_has_env = no                                                                                                                                           
                    if ( grep( /$agent/, @top_env_agents ) ) {                                                                                                                     
                        # Agent instantiated at top level. Need to set config for agent                                                                                            
                        align("  uvm_config_db #(${agent}_config)::set(this, \"m_${agent}${suffix}_agent\", \"config\", m_${agent}${suffix}_config);\n", "", "");                  
                        align("  if (m_${agent}${suffix}_config.is_active == UVM_ACTIVE )\n", "", "");                                                                             
                        align("    uvm_config_db #(${agent}_config)::set(this, \"m_${agent}${suffix}_agent.m_sequencer\", \"config\", m_${agent}${suffix}_config);\n", "", "");    
                        align("  uvm_config_db #(${agent}_config)::set(this, \"m_${agent}${suffix}_coverage\", \"config\", m_${agent}${suffix}_config);\n", "", "");               
                    }                                                                                                                                                              
                    else {                                                                                                                                                         
                        # additional_agent. Need to set config for env that contains agent                                                                                         
                        align("  uvm_config_db #(${agent}_config)::set(this, \"m_$agent_parent{$agent}_env\", \"config\", m_${agent}_config);\n", "", "");                         
                    }                                                                                                                                                              
                }                                                                                                                                                                  
                else {                                                                                                                                                             
                    # agent_has_env = yes. Add config to agent's own env                                                                                                           
                    align("  uvm_config_db #(${agent}_config)::set(this, \"m_${agent}_env\", \"config${suffix}\", m_${agent}${suffix}_config);\n", "", "");                        
                }                                                                                                                                                                  

                gen_aligned();                                                                                                                                                     
            }                                                                                                                                                                      
        }

        if ( keys %ref_model ) {
            print FH "\n";
            print FH "  // Default factory overrides for Syosil scoreboard\n";
            print FH "  cl_syoscb_queue::type_id::set_type_override(cl_syoscb_queue_std::type_id::get());\n";
        }

        foreach my $ref_model_name ( keys %ref_model ) {
            print FH "\n";
            print FH "  begin\n";
            print FH "    bit ok;\n";
            print FH "    uvm_factory factory = uvm_factory::get();\n";
            print FH "\n";

            unless (exists $ref_model_compare_method{$ref_model_name}) {
                $ref_model_compare_method{$ref_model_name} = "iop";
            }
            print FH "    if (factory.find_override_by_type(cl_syoscb_compare_base::type_id::get(), \"*\") == cl_syoscb_compare_base::type_id::get())\n";
            print FH "      cl_syoscb_compare_base::type_id::set_inst_override(cl_syoscb_compare_${ref_model_compare_method{$ref_model_name}}::type_id::get(), \"m_${ref_model_name}_scoreboard.*\", this);\n";
            print FH "\n";
            print FH "    // Configuration object for Syosil scoreboard\n";
            print FH "    m_${ref_model_name}_config = cl_syoscb_cfg::type_id::create(\"m_${ref_model_name}_config\");\n";
            print FH "    m_${ref_model_name}_config.set_queues( {\"DUT\", \"REF\"} );\n";
            print FH "    ok = m_${ref_model_name}_config.set_primary_queue(\"DUT\");\n";
            print FH "    assert(ok);\n";

            #foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
            #    print FH "    ok = m_${ref_model_name}_config.set_producer(\"$input\", {\"DUT\"} );\n";
            #    print FH "    assert(ok);\n";
            #}
            foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
                print FH "    ok = m_${ref_model_name}_config.set_producer(\"$output\", {\"DUT\", \"REF\"} );\n";
                print FH "    assert(ok);\n";
            }
            print FH "\n";
            print FH "    uvm_config_db#(cl_syoscb_cfg)::set(this, \"m_${ref_model_name}_scoreboard\", \"cfg\", m_${ref_model_name}_config);\n";
            print FH "\n";
            print FH "    // Instantiate reference model and Syosil scoreboard\n";
            align("    m_${ref_model_name} ", "= ${ref_model_name}", "::type_id::create(\"m_${ref_model_name}\", this);");

            #foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
            #    print FH "    m_converter_${input} = converter_${input}_t::type_id::create(\"m_converter_${input}\", this);\n";
            #}
            foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
                my $name = $output;
                $name =~ s/\./__/g;
                align("    m_converter_${name} ", "= converter_${name}_t", "::type_id::create(\"m_converter_${name}\", this);");
            }
            align("    m_${ref_model_name}_scoreboard ", "= cl_syoscb", "::type_id::create(\"m_${ref_model_name}_scoreboard\", this);");
            gen_aligned();
            print FH "  end\n";
        }

        print FH "\n";
        foreach my $agent (@agent_list) {
            align("  m_${agent}_env ", "= ${agent}_env", "::type_id::create(\"m_${agent}_env\", this);") if !grep( /$agent/, @stand_alone_agents );
        }

        foreach my $aname (@top_env_agents) {

            for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
                my $suffix = calc_suffix($i, $number_of_instances{$aname});

                align("\n", "", "");
                align("  m_${aname}${suffix}_agent ",    "= ${aname}_agent   ", "::type_id::create(\"m_${aname}${suffix}_agent\", this);");
                align("  m_${aname}${suffix}_coverage ", "= ${aname}_coverage", "::type_id::create(\"m_${aname}${suffix}_coverage\", this);");
            }
        }
        align("\n", "", "");
        gen_aligned();

        insert_inc_file("  ", $top_env_append_to_build_phase, $top_env_append_to_build_phase_inline, "top_env_append_to_build_phase", $common_tpl_fname);

        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";

        print FH "function void ${tbname}_env::connect_phase(uvm_phase phase);\n";
        print FH "  `uvm_info(get_type_name(), \"In connect_phase\", UVM_HIGH)\n";

        foreach my $env (@env_list) {
            print FH "  `uvm_info(get_type_name(), \$sformatf(\"m_${env}: %p\\n\",m_${env}), UVM_HIGH)\n";
        }
        print FH "\n";

        foreach my $aname (@top_env_agents) {

            for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
                my $suffix = calc_suffix($i, $number_of_instances{$aname});

                print FH "  m_${aname}${suffix}_agent.analysis_port.connect(m_${aname}${suffix}_coverage.analysis_export);\n";
                print FH "\n";
            }
        }

        if ( $regmodel ) {
            print FH "  // Connect the register model in each agent's env\n";
            foreach my $agent ( keys(%reg_access_mode) ) {

                for ( my $i = 0 ; $i < $number_of_instances{$agent} ; $i++ ) {
                    my $suffix = calc_suffix($i, $number_of_instances{$agent});

                    print FH "  m_${agent}_env.m_${agent}2reg_predictor${suffix}.map     = regmodel.${reg_access_map{$agent}}${suffix};\n";
                    print FH "  m_${agent}_env.m_${agent}2reg_predictor${suffix}.adapter = m_${agent}_env.m_reg2${agent}${suffix};\n";
                    print FH "  regmodel.${reg_access_map{$agent}}${suffix}.set_sequencer(m_${agent}_env.m_${agent}${suffix}_agent.m_sequencer, ",
                      "m_${agent}_env.m_reg2${agent}${suffix});\n";
                    print FH "  regmodel.${reg_access_map{$agent}}${suffix}.set_auto_predict(0);\n";

                    print FH "\n";
                }
            }
        }

        foreach my $ref_model_name ( keys(%ref_model) ) {
            print FH "  begin\n";
            print FH "    // Connect reference model and Syosil scoreboard\n";
            print FH "    cl_syoscb_subscriber subscriber;\n";
            print FH "\n";

            my $i = 0;
            foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
                print FH "    ${input}.analysis_port.connect(m_${ref_model_name}.analysis_export_$i);\n";

                #print FH "    subscriber = m_${ref_model_name}_scoreboard.get_subscriber(\"DUT\", \"${input}\");\n";
                #print FH "    ${input}.analysis_port.connect(m_converter_${input}.analysis_export);\n";
                #print FH "    m_converter_${input}.analysis_port.connect(subscriber.analysis_export);\n";
                $i++;
            }
            $i = 0;
            foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
                print FH "\n";
                print FH "    subscriber = m_${ref_model_name}_scoreboard.get_subscriber(\"REF\", \"${output}\");\n";
                print FH "    m_${ref_model_name}.analysis_port_$i.connect(subscriber.analysis_export);\n";
                print FH "\n";
                print FH "    subscriber = m_${ref_model_name}_scoreboard.get_subscriber(\"DUT\", \"${output}\");\n";
                my $name = $output;
                $name =~ s/\./__/g;
                print FH "    ${output}.analysis_port.connect(m_converter_${name}.analysis_export);\n";
                print FH "    m_converter_${name}.analysis_port.connect(subscriber.analysis_export);\n";
                $i++;
            }
            print FH "  end\n";
        }

        print FH "\n";

        insert_inc_file("  ", $top_env_append_to_connect_phase, $top_env_append_to_connect_phase_inline, "top_env_append_to_connect_phase", $common_tpl_fname);

        print FH "endfunction : connect_phase\n";
        print FH "\n";
        print FH "\n";

        unless ( defined $top_env_generate_end_of_elaboration && $top_env_generate_end_of_elaboration eq "NO" )
        {
            unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
                print FH "// You can remove end_of_elaboration_phase by setting top_env_generate_end_of_elaboration = no in file ${common_tpl_fname}\n\n";
            }
            print FH "function void ${tbname}_env::end_of_elaboration_phase(uvm_phase phase);\n";
            print FH "  uvm_factory factory = uvm_factory::get();\n";
            print FH "  `uvm_info(get_type_name(), \"Information printed from ${tbname}_env::end_of_elaboration_phase method\", UVM_MEDIUM)\n";
            print FH "  `uvm_info(get_type_name(), \$sformatf(\"Verbosity threshold is %d\", get_report_verbosity_level()), UVM_MEDIUM)\n";
            print FH "  uvm_top.print_topology();\n";
            print FH "  factory.print();\n";
            print FH "endfunction : end_of_elaboration_phase\n";
            print FH "\n";
            print FH "\n";
        }
        unless ( defined $top_env_generate_run_phase && $top_env_generate_run_phase eq "NO" )
        {
            unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
                print FH "// You can remove run_phase by setting top_env_generate_run_phase = no in file ${common_tpl_fname}\n\n";
            }
            print FH "task ${tbname}_env::run_phase(uvm_phase phase);\n";
            print FH "  ${tbname}_default_seq vseq;\n";
            print FH "  vseq = ${tbname}_default_seq::type_id::create(\"vseq\");\n";
            print FH "  vseq.set_item_context(null, null);\n";
            print FH "  if ( !vseq.randomize() )\n";
            print FH "    `uvm_fatal\(get_type_name(), \"Failed to randomize virtual sequence\")\n";

            foreach my $agent (@agent_list) {
                if ( not (grep( /$agent/, @stand_alone_agents ) or ( $agent eq "" ) ) ) {
                    align("  vseq.m_${agent}_env ", "= m_${agent}_env;", "");
                }
            }
            foreach my $aname (@top_env_agents) {

                for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
                    my $suffix = calc_suffix($i, $number_of_instances{$aname});

                    align("  vseq.m_${aname}${suffix}_agent ", "= m_${aname}${suffix}_agent;", "");
                }
            }

            if ( $regmodel ) {
                align("  vseq.regmodel ", "= regmodel;", "");
            }
            align("  vseq.m_config ", "= m_config;", "");

            gen_aligned();

            print FH "  vseq.set_starting_phase(phase);\n";
            print FH "  vseq.start(null);\n";
            print FH "\n";

            insert_inc_file("  ", $top_env_append_to_run_phase, $top_env_append_to_run_phase_inline, "top_env_append_to_run_phase", $common_tpl_fname);

            print FH "endtask : run_phase\n";
            print FH "\n";
            print FH "\n";
        }
    }

    insert_inc_file("", $top_env_inc_after_class, $top_env_inc_after_inline, "top_env_inc_after_class", $common_tpl_fname);

    print FH "`endif // " . uc($tbname) . "_ENV_SV\n";
    print FH "\n";
    close(FH);
}


sub gen_port_converter {

    # Port converter class is only necessary if there is a reference model
    unless ( keys %ref_model ) {
        return;
    }

    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/port_converter.sv" )
      || die "Exiting due to Error: can't open env: $tbname";

    write_file_header "port_converter.sv", "Analysis port type converter class for use with Syosil scoreboard";

    unless ( defined $syosil_scoreboard_src_path ) {
        warning_prompt("ref_model specified in $common_tpl_fname but \$syosil_scoreboard_src_path has not been defined");
    }

    print FH "`ifndef PORT_CONVERTER_SV\n";
    print FH "`define PORT_CONVERTER_SV\n";
    print FH "\n";

    print FH "\n";
    print FH "class port_converter #(type T = uvm_sequence_item) extends uvm_subscriber #(T);\n";
    print FH "  `uvm_component_param_utils(port_converter#(T))\n";
    print FH "\n";
    print FH "  // For connecting analysis port of monitor to analysis export of Syosil scoreboard\n";
    print FH "\n";
    print FH "  uvm_analysis_port #(uvm_sequence_item) analysis_port;\n";
    print FH "\n";
    print FH "  function new(string name, uvm_component parent);\n";
    print FH "    super.new(name, parent);\n";
    print FH "    analysis_port = new(\"a_port\", this);\n";
    print FH "  endfunction\n";
    print FH "\n";
    print FH "  function void write(T t);\n";
    print FH "    analysis_port.write(t);\n";
    print FH "  endfunction\n";
    print FH "\n";
    print FH "endclass\n";
    print FH "\n";
    print FH "\n";

    print FH "`endif // PORT_CONVERTER_SV\n";
    print FH "\n";
    close(FH);
}


sub gen_ref_model {
    my ($ref_model_name) = @_;

    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/$ref_model_name.sv" )
      || die "Exiting due to Error: can't open env: $tbname";

    write_file_header "$ref_model_name.sv", "Reference model for use with Syosil scoreboard";

    unless ( defined $syosil_scoreboard_src_path ) {
        warning_prompt("ref_model specified in $common_tpl_fname but \$syosil_scoreboard_src_path has not been defined");
    }

    print FH "`ifndef " . uc($ref_model_name) . "_SV\n";
    print FH "`define " . uc($ref_model_name) . "_SV\n";
    print FH "\n";

    insert_inc_file("", $ref_model_inc_before_class{$ref_model_name}, $ref_model_inc_before_inline{$ref_model_name}, "ref_model_inc_before_class", $common_tpl_fname);

    print FH "\n";

    my $i = 0;
    foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        print FH "`uvm_analysis_imp_decl(_${ref_model_name}_$i)\n";
        $i++;
    }

    print FH "\n";
    print FH "class $ref_model_name extends uvm_component;\n";
    print FH "  `uvm_component_utils($ref_model_name)\n";
    print FH "\n";
    $i = 0;
    foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        unless (exists ${agent_type_by_inst{$input}}) {
            warning_prompt("ref_model_input $input specified in $common_tpl_fname cannot be found as the instance name of an agent in the generated code");
        }
        $agent_name = ${agent_type_by_inst{$input}};
        print FH "  uvm_analysis_imp_${ref_model_name}_$i #($agent_item_types{$agent_name}, $ref_model_name) analysis_export_$i; // $input\n";
        $i++;
    }
    print FH "\n";
    $i = 0;
    foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
        $agent_name = ${agent_type_by_inst{$output}};
        if ($agent_name eq "") {
            warning_prompt("ref_model_input $output specified in $common_tpl_fname cannot be found as the instance name of an agent in the generated code");
        }
        print FH "  uvm_analysis_port #(uvm_sequence_item) analysis_port_$i; // $output\n";
        $i++;
    }
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";

    $i = 0;
    foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        $agent_name = ${agent_type_by_inst{$input}};

        print FH "  extern function void write_${ref_model_name}_$i(input " . $agent_item_types{$agent_name} . " t);\n";
        $i++;
    }

    print FH "\n";

    insert_inc_file("  ", $ref_model_inc_inside_class{$ref_model_name}, $ref_model_inc_inside_inline{$ref_model_name}, "ref_model_inc_inside_class", $common_tpl_fname);

    print FH "endclass\n";
    print FH "\n";
    print FH "\n";
    print FH "function ${ref_model_name}::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    $i = 0;
    foreach my $input ( @{ $ref_model_inputs{$ref_model_name} } ) {
        print FH "  analysis_export_$i = new(\"analysis_export_$i\", this);\n";
        $i++;
    }
    $i = 0;
    foreach my $output ( @{ $ref_model_outputs{$ref_model_name} } ) {
        print FH "  analysis_port_$i   = new(\"analysis_port_$i\",   this);\n";
        $i++;
    }
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    insert_inc_file("", $ref_model_inc_after_class{$ref_model_name}, $ref_model_inc_after_inline{$ref_model_name}, "ref_model_inc_after_class", $common_tpl_fname);

    print FH "`endif // " . uc($ref_model_name) . "_SV\n";
    print FH "\n";
}


sub gen_top_config {
    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/" . $tbname . "_config.sv" )
      || die "Exiting due to Error: can't open config: $tbname";

    write_file_header "${tbname}_config.sv", "Configuration for $tbname";

    print FH "`ifndef " . uc($tbname) . "_CONFIG_SV\n";
    print FH "`define " . uc($tbname) . "_CONFIG_SV\n";
    print FH "\n";

    insert_inc_file("", $top_env_config_inc_before_class, $top_env_config_inc_before_inline, "top_env_config_inc_before_class", $common_tpl_fname);

    print FH "class ${tbname}_config extends uvm_object;\n";
    print FH "\n";
    print FH "  // Do not register config class with the factory\n";
    print FH "\n";

    if ( defined $nested_config_objects && $nested_config_objects eq "YES" )
    {
        for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                my $suffix = calc_suffix($j, $number_of_instances{$agent});

                align("  rand ${agent}_config  ", "m_${agent}${suffix}_config;", "");
            }
        }
    }
    else
    {
        for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                my $suffix = calc_suffix($j, $number_of_instances{$agent});

                align("  virtual ${all_agent_ifs[$i]}  ", "${agent}${suffix}_vif;", "");
            }
        }
        align("\n", "", "");

        for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                my $suffix = calc_suffix($j, $number_of_instances{$agent});

                align("  uvm_active_passive_enum  ", "is_active_${agent}${suffix} ", "= UVM_ACTIVE;");
            }
        }
        align("\n", "", "") if ( @all_agent_ifs > 1);

        for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                my $suffix = calc_suffix($j, $number_of_instances{$agent});

                align("  bit  ", "checks_enable_${agent}${suffix};", "");
            }
        }
        align("\n", "", "") if ( @all_agent_ifs > 1);


        for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                my $suffix = calc_suffix($j, $number_of_instances{$agent});

                align("  bit  ", "coverage_enable_${agent}${suffix};", "");
            }
        }
    }
    
    gen_aligned();

    print FH "\n";

    unless ( @common_config_var_array ) {
        print FH "  // You can insert variables here by setting config_var in file ${common_tpl_fname}\n";
    }
    foreach my $var_decl (@common_config_var_array) {
        print FH "  $var_decl\n";
    }
    print FH "\n";

    unless ( defined $top_env_config_generate_methods_inside_class && $top_env_config_generate_methods_inside_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove new by setting top_env_config_generate_methods_inside_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "  extern function new(string name = \"\");\n";
        print FH "\n";
    }
    
    insert_inc_file("  ", $top_env_config_inc_inside_class, $top_env_config_inc_inside_inline, "top_env_config_inc_inside_class", $common_tpl_fname);

    print FH "endclass : " . $tbname . "_config \n";
    print FH "\n";
    print FH "\n";

    unless ( defined $top_env_config_generate_methods_after_class && $top_env_config_generate_methods_after_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove new by setting top_env_config_generate_methods_after_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "function ${tbname}_config::new(string name = \"\");\n";
        print FH "  super.new(name);\n";
        print FH "\n";

        if ( defined $nested_config_objects && $nested_config_objects eq "YES" )                                                         
        {                                                                                                                            
            for ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
                my $agent = $agent_list[$i];

                for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {
                    my $suffix = calc_suffix($j, $number_of_instances{$agent});

                    align("  m_${agent}${suffix}_config ", "= new(\"m_${agent}${suffix}_config\");", "");                              

                    my $value;                                                                                                         
                    if ( exists $agent_is_active{$agent} ) {                      
                        $value = "$agent_is_active{$agent}";                                                                
                    }                                                                                                                  
                    else {                                                                                                             
                        $value = "UVM_ACTIVE";                                                                                        
                    }                                                                                                                  
                    align("  m_${agent}${suffix}_config.is_active ", "= $value;", "");                                                 

                    if ( exists $agent_checks_enable{$agent} and $agent_checks_enable{$agent} eq "NO" ) {        
                        $value = "0";                                                                                                  
                    }                                                                                                                  
                    else {                                                                                                             
                        $value = "1";                                                                                                  
                    }                                                                                                                  
                    align("  m_${agent}${suffix}_config.checks_enable ", "= $value;", "");                                             

                    if ( exists $agent_coverage_enable{$agent} and $agent_coverage_enable{$agent} eq "NO" ) {    
                        $value = "0";                                                                                                  
                    }                                                                                                                  
                    else {                                                                                                             
                        $value = "1";                                                                                                  
                    }                                                                                                                  
                    align("  m_${agent}${suffix}_config.coverage_enable ", "= $value;", "");                                            
                    align("\n", "", "");                                                                                               
                }                                                                                                                      
            }                                                                                                                        
            gen_aligned();                                                                                                           
        }                                                                                                                            
        insert_inc_file("  ", $top_env_config_append_to_new, $top_env_config_append_to_new_inline, "top_env_config_append_to_new", $common_tpl_fname);

        print FH "endfunction : new\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $top_env_config_inc_after_class, $top_env_config_inc_after_inline, "top_env_config_inc_after_class", $common_tpl_fname);

    print FH "`endif // " . uc($tbname) . "_CONFIG_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_top_seq_lib {
    $dir = $project . "/tb/" . $tbname;
    open( FH, ">" . $dir . "/sv/" . $tbname . "_seq_lib.sv" )
      || die "Exiting due to Error: can't open seq_lib: $tbname";

    write_file_header "${tbname}_seq_lib.sv", "Sequence for $tbname";

    print FH "`ifndef " . uc($tbname) . "_SEQ_LIB_SV\n";
    print FH "`define " . uc($tbname) . "_SEQ_LIB_SV\n";
    print FH "\n";

    print FH "class ${tbname}_default_seq extends uvm_sequence #(uvm_sequence_item);\n";
    print FH "\n";
    print FH "  `uvm_object_utils(" . $tbname . "_default_seq)\n";
    print FH "\n";

    if ( $regmodel ) {
        align("  $top_reg_block_type ", "regmodel;", "");
    }
    align("  ${tbname}_config ", "m_config;\n", "");

    foreach my $agent (@agent_list) {
        do {
            align("  ${agent}_env  ", "m_${agent}_env;", "");
        } unless grep( /$agent/, @stand_alone_agents );
    }

    foreach my $aname (@top_env_agents) {

        for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$aname});

            align("  ${aname}_agent  ", "m_${aname}${suffix}_agent;", "");
        }
    }

    foreach my $env (@env_list) {
        $env =~ /(\w+)_env/;
        if ( exists $reg_access_mode{$1} ) {
            push @reg_env, $1;
            align("  ${env}_default_seq  ", "m_${env}_seq;", "");
        }
        else {    #env that does not access regmodel
            push @non_reg_env, $1;
            align("  ${1}_env_default_seq  ", "m_${1}_env_seq;", "");
        }
    }

    gen_aligned();

    print FH "\n";
    print FH "  // Number of times to repeat child sequences\n";

    if ( defined $top_default_seq_count ) {
        print FH "  int m_seq_count = $top_default_seq_count;\n";
    }
    else {
        print FH "  int m_seq_count = 1;\n";
    }
    print FH "\n";

    do {
        print FH "\n";
        print FH "  // Example built-in register sequences\n";
        print FH "  //uvm_reg_hw_reset_seq  m_reset_seq;\n";
        print FH "  //uvm_reg_bit_bash_seq  m_bit_bash_seq;\n";
        print FH "\n";
    } if $regmodel;
    print FH "  extern function new(string name = \"\");\n";
    print FH "  extern task body();\n";
    print FH "  extern task pre_start();\n";
    print FH "  extern task post_start();\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "  // Functions to support UVM 1.2 objection API in UVM 1.1\n";
    print FH "  extern function uvm_phase get_starting_phase();\n";
    print FH "  extern function void set_starting_phase(uvm_phase phase);\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "endclass : " . $tbname . "_default_seq\n";
    print FH "\n";
    print FH "\n";
    print FH "function ${tbname}_default_seq::new(string name = \"\");\n";
    print FH "  super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";
    print FH "task ${tbname}_default_seq::body();\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence starting\", UVM_HIGH)\n";
    print FH "\n";

    foreach my $env (@reg_env, @non_reg_env) {
        align("  m_${env}_env_seq ", "= ${env}_env_default_seq", "::type_id::create(\"m_${env}_env_seq\");");
        
        # For the purposes of random stability, although the virtual sequence is actually running on the null sequencer,
        # pretend instead that it is running on the sequencer of the agent.
        # If there are multiple instances of the agent, pick the first
        
        my $suffix = calc_suffix(0, $number_of_instances{$env});
        my $sequencer_instance_name = "m_${env}_env.m_${env}${suffix}_agent.m_sequencer";

        align("  m_${env}_env_seq.set_item_context(this, ${sequencer_instance_name});\n", "", "");
        align("  m_${env}_env_seq.set_starting_phase( get_starting_phase() );\n", "", "");

        if ( grep( /$env/, @reg_env ) ) {
            $aname = $env;
            for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
                my $suffix = calc_suffix($i, $number_of_instances{$aname});

                if ( ${reg_access_instance{$aname}} ne "" ) {
                    align("  m_${env}_env_seq.regmodel${suffix} ", "= regmodel${reg_access_instance{$aname}}${suffix};", "");
                }
                else {
                    # If instance = "", use the top-level regmodel
                    align("  m_${env}_env_seq.regmodel${suffix} ", "= regmodel;", "");
                }
                align("  m_${env}_env_seq.m_config${suffix} ", "= m_${aname}_env.m_${aname}${suffix}_agent.m_config;", "");
            }
        }
        align("\n", "", "");
    }

    gen_aligned();

    print FH "\n";
    print FH "  repeat (m_seq_count)\n";
    print FH "  begin\n";

    my @vseq_list;
    if ($regmodel) {
        foreach my $env (@reg_env) {
            print FH "    if ( !m_${env}_env_seq.randomize() )\n";
            print FH "      `uvm_error(get_type_name(), \"Failed to randomize sequence\")\n";
            push @vseq_list, "m_${env}_env_seq";
        }
    }
    foreach my $env (@non_reg_env) {
        push @vseq_list, "m_${env}_env_seq";
        print FH "    if ( !m_${env}_env_seq.randomize() )\n";
        print FH "      `uvm_error(get_type_name(), \"Failed to randomize sequence\")\n";
        print FH "    m_${env}_env_seq.m_env = m_${env}_env;\n";
    }

    print FH "    fork\n";
    foreach my $vseq (@vseq_list) {
        print FH "      ${vseq}.start(null, this);\n";
    }
    foreach my $aname (@top_env_agents) {

        for ( my $i = 0 ; $i < $number_of_instances{$aname} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$aname});
            my $sequencer_instance_name = "m_${aname}${suffix}_agent.m_sequencer";
            
            print FH "      if (m_${aname}${suffix}_agent.m_config.is_active == UVM_ACTIVE)\n";
            print FH "      begin\n";
            print FH "        ${aname}_default_seq seq;\n";
            print FH "        seq = ${aname}_default_seq::type_id::create(\"seq\");\n";
            print FH "        seq.set_item_context(this, ${sequencer_instance_name});\n";
            print FH "        if ( !seq.randomize() )\n";
            print FH "          `uvm_error(get_type_name(), \"Failed to randomize sequence\")\n";
            print FH "        seq.m_config = m_${aname}${suffix}_agent.m_config;\n";
            print FH "        seq.set_starting_phase( get_starting_phase() );\n";
            print FH "        seq.start(${sequencer_instance_name}, this);\n";
            print FH "      end\n";

        }
    }
    print FH "    join\n";
    print FH "  end\n";
    print FH "\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence completed\", UVM_HIGH)\n";
    print FH "endtask : body\n";
    print FH "\n";
    print FH "\n";

    print FH "task ${tbname}_default_seq::pre_start();\n";
    print FH "  uvm_phase phase = get_starting_phase();\n";
    print FH "  if (phase != null)\n";
    print FH "    phase.raise_objection(this);\n";
    print FH "endtask: pre_start\n";
    print FH "\n";
    print FH "\n";
    print FH "task ${tbname}_default_seq::post_start();\n";
    print FH "  uvm_phase phase = get_starting_phase();\n";
    print FH "  if (phase != null) \n";
    print FH "    phase.drop_objection(this);\n";
    print FH "endtask: post_start\n";
    print FH "\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "function uvm_phase ${tbname}_default_seq::get_starting_phase();\n";
    print FH "  return starting_phase;\n";
    print FH "endfunction: get_starting_phase\n";
    print FH "\n";
    print FH "\n";
    print FH "function void ${tbname}_default_seq::set_starting_phase(uvm_phase phase);\n";
    print FH "  starting_phase = phase;\n";
    print FH "endfunction: set_starting_phase\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "\n";

    insert_inc_file("", $top_seq_inc, $top_seq_inc_inline, "top_seq_inc", $common_tpl_fname);

    print FH "`endif // " . uc($tbname) . "_SEQ_LIB_SV\n";
    print FH "\n";

    close(FH);
}

sub gen_top_test {
    $dir = $project . "/tb/" . $tbname . "_test";
    open( FH, ">" . $dir . "/sv/" . $tbname . "_test_pkg.sv" )
      || die "can't open test: " . $tbname . "_test_pkg.sv";

    write_file_header "${tbname}_test_pkg.sv", "Test package for $tbname";

    print FH "`ifndef " . uc($tbname) . "_TEST_PKG_SV\n";
    print FH "`define " . uc($tbname) . "_TEST_PKG_SV\n";
    print FH "\n";
    print FH "package " . $tbname . "_test_pkg;\n";
    print FH "\n";
    print FH "  `include \"uvm_macros.svh\"\n";
    print FH "\n";
    print FH "  import uvm_pkg::*;\n";
    print FH "\n";
    print FH "  import regmodel_pkg::*;\n\n" if $regmodel;

    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;

    foreach my $agent (@agent_list) {
        print FH "  import ${agent}_pkg::*;\n";
    }
    print FH "  import " . $tbname . "_pkg::*;\n";
    print FH "\n";
    print FH "  `include \"" . $tbname . "_test.sv\"\n";
    print FH "\n";
    print FH "endpackage : " . $tbname . "_test_pkg\n";
    print FH "\n";
    print FH "`endif // " . uc($tbname) . "_TEST_PKG_SV\n";
    print FH "\n";
    close(FH);

    $dir = $project . "/tb/" . $tbname . "_test";

    # define specific tests
    $dir = $project . "/tb/" . $tbname . "_test";
    open( FH, ">" . $dir . "/sv/" . $tbname . "_test.sv" )
      || die "Exiting due to Error: can't open test: " . $tbname . "_test.sv";

    write_file_header "${tbname}_test.sv", "Test class for ${tbname} (included in package ${tbname}_test_pkg)";

    print FH "`ifndef " . uc($tbname) . "_TEST_SV\n";
    print FH "`define " . uc($tbname) . "_TEST_SV\n";
    print FH "\n";

    insert_inc_file("", $test_inc_before_class, $test_inc_before_inline, "test_inc_before_class", $common_tpl_fname);

    print FH "class ${tbname}_test extends uvm_test;\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $tbname . "_test)\n";
    print FH "\n";
    print FH "  ${tbname}_env m_env;\n";
    print FH "\n";
    print FH "  extern function new(string name, uvm_component parent);\n";
    print FH "\n";

    unless ( defined $test_generate_methods_inside_class && $test_generate_methods_inside_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove build_phase method by setting test_generate_methods_inside_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "\n";
    }

    insert_inc_file("  ", $test_inc_inside_class, $test_inc_inside_inline, "test_inc_inside_class", $common_tpl_fname);

    print FH "endclass : ${tbname}_test\n";
    print FH "\n";
    print FH "\n";
    print FH "function ${tbname}_test::new(string name, uvm_component parent);\n";
    print FH "  super.new(name, parent);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    unless ( defined $test_generate_methods_after_class && $test_generate_methods_after_class eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove build_phase method by setting test_generate_methods_after_class = no in file ${common_tpl_fname}\n\n";
        }
        print FH "function void ${tbname}_test::build_phase(uvm_phase phase);\n";
        print FH "\n";

        insert_inc_file("  ", $test_prepend_to_build_phase, $test_prepend_to_build_phase_inline, "test_prepend_to_build_phase", $common_tpl_fname);

        print FH "  // You could modify any test-specific configuration object variables here\n";
        print FH "\n";

        do {
            print FH "  // Include reg coverage from the register model\n";
            print FH "  uvm_reg::include_coverage(\"*\", UVM_CVR_ALL);\n";
        } if $regmodel;

        print FH "\n";

        foreach my $factory_override ( keys %agent_factory_set ) {
            if ($factory_override ne "") {
                align("  ${factory_override}", "::type_id::set_type_override($agent_factory_set{$factory_override}::get_type());", "");
            }
        }

        foreach my $factory_override ( keys %top_factory_set ) {
            if ($factory_override ne "") {
                align("  ${factory_override}", "::type_id::set_type_override($top_factory_set{$factory_override}::get_type());", "");
            }
        }

        gen_aligned();

        print FH "\n";
        print FH "  m_env = ${tbname}_env::type_id::create(\"m_env\", this);\n";
        print FH "\n";

        insert_inc_file("  ", $test_append_to_build_phase, $test_append_to_build_phase_inline, "test_append_to_build_phase", $common_tpl_fname);

        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $test_inc_after_class, $test_inc_after_inline, "test_inc_after_class", $common_tpl_fname);

    print FH "`endif // " . uc($tbname) . "_TEST_SV\n";
    print FH "\n";
    close(FH);

}

sub gen_top() {
    ### generate top modules
    $dir = $project . "/tb/" . $tbname;

    ### Test Harness
    open( FH, ">" . $dir . "_tb/sv/" . $tbname . "_th.sv" )
      || die "Exiting due to Error: can't open include file: " . $tbname . "_th.sv";
    write_file_header "${tbname}_th.sv", "Test Harness";
    
    if ( $split_transactors eq "YES" ) {
      $th_module_name = "${tbname}_hdl_th";
    }
    else {
      $th_module_name = "${tbname}_th";
    }
    
    print FH "module ${th_module_name};\n";
    print FH "\n";
    print FH "  timeunit      $timeunit;\n";
    print FH "  timeprecision $timeprecision;\n";
    print FH "\n";
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;
    print FH "\n";

    unless ( defined $th_generate_clock_and_reset && $th_generate_clock_and_reset eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove clock and reset below by setting th_generate_clock_and_reset = no in file ${common_tpl_fname}\n\n";
        }
        print FH "  // Example clock and reset declarations\n";
        print FH "  logic clock = 0;\n";
        print FH "  logic reset;\n";
        print FH "\n";
        print FH "  // Example clock generator process\n";
        print FH "  always #10 clock = ~clock;\n";
        print FH "\n";

        print FH "  // Example reset generator process\n";
        print FH "  initial\n";
        print FH "  begin\n";
        print FH "    reset = 0;         // Active low reset in this example\n";
        print FH "    #75 reset = 1;\n";
        print FH "  end\n";

        if (@rlist) {#
            align("\n", "", "");

            for ( $i = 0 ; $i < @rlist ; $i = $i + 2 ) {
                $agent_name = $rlist[$i];
                unless ( exists $generate_interface_instance{$agent_name} && $generate_interface_instance{$agent_name} eq "NO" ) {

                    for ( my $j = 0 ; $j < $number_of_instances{$agent_name} ; $j++ ) {
                        my $suffix = "_${j}";

                        align("  assign ${agent_name}_if${suffix}.$rlist[ $i + 1 ] ", "= reset;", "");
                    }
                }
            }
        }

        if (@clist) {
            align("\n", "", "");
            for ( $i = 0 ; $i < @clist ; $i = $i + 2 ) {
                $agent_name = $clist[$i];
                unless ( exists $generate_interface_instance{$agent_name} && $generate_interface_instance{$agent_name} eq "NO" ) {

                    for ( my $j = 0 ; $j < $number_of_instances{$agent_name} ; $j++ ) {
                        my $suffix = "_${j}";

                        align("  assign ${agent_name}_if${suffix}.$clist[ $i + 1 ] ", "= clock;", "");
                    }
                }
            }
        }
        gen_aligned();

        print FH "\n";
    }

    insert_inc_file("  ", $th_inc_inside_module, $th_inc_inside_inline, "th_inc_inside_module", $common_tpl_fname);

    align("  // Pin-level interfaces connected to DUT\n", "", "");
    unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
        align("  // You can remove interface instances by setting generate_interface_instance = no in the interface template file\n\n", "", "");
    }
    foreach my $agent_name (@agent_list) {
        unless ( exists $generate_interface_instance{$agent_name} && $generate_interface_instance{$agent_name} eq "NO" )
        {
            my $interface_type;
            if ( exists $byo_interface{$agent_name} ) {
                $interface_type = $byo_interface{$agent_name};
            }
            else {
                $interface_type = "${agent_name}_if";
            }

            for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {    
                my $suffix = "_${i}";                                        
                align("  ${interface_type}  ", "${agent_name}_if${suffix} ();", "");      
            }                                                                
        }                                                                
    }
    align("\n", "", "");

    if ( $split_transactors eq "YES" ) {
        align("  // BFM interfaces that communicate with proxy transactors in UVM environment\n", "", "");
        foreach my $agent_name (@agent_list) {
            for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {                       
                my $suffix = "_${i}";                                                           
                align("  ${agent_name}_bfm  ", "${agent_name}_bfm${suffix} (${agent_name}_if${suffix});", "");    
            }                                                                                   
        }
        align("\n", "", "");
    }
    gen_aligned();
   
    gen_dut_inst();

    print FH "\n";
    print FH "endmodule\n";
    print FH "\n";
    close(FH);

    ###Testbench

    open( FH, ">" . $dir . "_tb/sv/" . $tbname . "_tb.sv" )
      || die "Exiting due to Error: can't open include file: ${tbname}_tb.sv";

    write_file_header("${tbname}_tb.sv","Testbench");

    if ( $split_transactors eq "YES" ) {
      $tb_module_name = "${tbname}_untimed_tb";
    }
    else {
      $tb_module_name = "${tbname}_tb";
    }
   

    print FH "module ${tb_module_name};\n";
    print FH "\n";
    print FH "  timeunit      $timeunit;\n";
    print FH "  timeprecision $timeprecision;\n";
    print FH "\n";
    print FH "  `include \"uvm_macros.svh\"\n";
    print FH "\n";
    print FH "  import uvm_pkg::*;\n";
    print FH "\n";
    print FH "  import ${common_pkg}::*;\n" if $common_pkg;
    print FH "  import ${common_env_pkg}::*;\n" if $common_env_pkg;
    print FH "  import ${tbname}_test_pkg::*;\n";
    print FH "  import ${tbname}_pkg::${tbname}_config;\n";
    print FH "\n";
    print FH "  // Configuration object for top-level environment\n";
    print FH "  ${tbname}_config top_env_config;\n";
    print FH "\n";

    unless ( $dual_top eq "YES" )
    {
        print FH "  // Test harness\n";
        print FH "  ${th_module_name} th();\n";
        print FH "\n";
    }
    
    insert_inc_file("  ", $tb_inc_inside_module, $tb_inc_inside_inline, "tb_inc_inside_module", $common_tpl_fname);

    unless ( defined $tb_generate_run_test && $tb_generate_run_test eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove the initial block below by setting tb_generate_run_test = no in file ${common_tpl_fname}\n\n";
        }
        print FH "  initial\n";
        print FH "  begin\n";

        insert_inc_file("    ", $tb_prepend_to_initial, $tb_prepend_to_initial_inline, "tb_prepend_to_initial", $common_tpl_fname);

        print FH "    // Create and populate top-level configuration object\n";
        print FH "    top_env_config = new(\"top_env_config\");\n";
        print FH "    if ( !top_env_config.randomize() )\n";
        print FH "      `uvm_error(\"${tb_module_name}\", \"Failed to randomize top-level configuration object\" )\n";
        print FH "\n";

        foreach ( my $i = 0 ; $i < @all_agent_ifs ; $i++ ) {
            my $agent = $agent_list[$i];

            for ( my $j = 0 ; $j < $number_of_instances{$agent} ; $j++ ) {                                                    
                my $suffix = calc_suffix($j, $number_of_instances{$agent});                                                   

                my $test_harness_name;
                if ( $dual_top eq "YES" ) {
                    $test_harness_name = ${th_module_name};
                }
                else {
                    $test_harness_name = "th";
                }

                if ( defined $nested_config_objects && $nested_config_objects eq "YES" ) {                                           
                    unless ( exists $generate_interface_instance{$agent} && $generate_interface_instance{$agent} eq "NO" ) {
                        align("    top_env_config.m_${agent}${suffix}_config.vif ", "= $test_harness_name.$all_agent_ifs[$i]_${j};", "");      
                    }
                }
                else {
                    unless ( exists $generate_interface_instance{$agent} && $generate_interface_instance{$agent} eq "NO" ) {
                        align("    top_env_config.${agent}${suffix}_vif ", "= $test_harness_name.$all_agent_ifs[$i]_${j};", "");         
                    }
                    my $value;                                                                                                       
                    if ( exists $agent_is_active{$agent} ) {                  
                        $value = "$agent_is_active{$agent}";
                    }                                                                                                                
                    else {                                                                                                           
                        $value = "UVM_ACTIVE";
                    } 
                    align("    top_env_config.is_active_${agent}${suffix} ", "= ${value};", "");

                    if ( exists $agent_checks_enable{$agent} and $agent_checks_enable{$agent} eq "NO" ) {        
                        $value = "0";                                                                                                
                    }                                                                                                                
                    else {                                                                                                           
                        $value = "1";                                                                                                
                    }                                                                                                                
                    align("    top_env_config.checks_enable_${agent}${suffix} ", "= ${value};", "");                              

                    if ( exists $agent_coverage_enable{$agent} and $agent_coverage_enable{$agent} eq "NO" ) {    
                        $value = "0";                                                                                                
                    }                                                                                                                
                    else {                                                                                                           
                        $value = "1";                                                                                                
                    }                                                                                                                
                    align("    top_env_config.coverage_enable_${agent}${suffix} ", "= ${value};", "");                            
                    align("\n", "", "");                                                                                             
                }                                                                                                                    
            }                                                                                                                        
        }

        gen_aligned();

        print FH "\n";
        print FH "    uvm_config_db #(${tbname}_config)::set(null, \"uvm_test_top\", \"config\", top_env_config);\n";
        print FH "    uvm_config_db #(${tbname}_config)::set(null, \"uvm_test_top.m_env\", \"config\", top_env_config);\n";
        print FH "\n";

        insert_inc_file("    ", $tb_inc_before_run_test, $tb_inc_before_run_test_inline, "tb_inc_before_run_test", $common_tpl_fname);

        print FH "    run_test();\n";
        print FH "  end\n";
        print FH "\n";
    }
    print FH "endmodule\n";
    print FH "\n";
    close(FH);
}

sub gen_regmodel_pkg {

    my $line;
    print LOGFILE "\nProcessing register layer\n";
    my $dir = $project . "/tb/regmodel";
    printf LOGFILE "rdir: $dir\n";
    mkdir( $dir, 0755 );
    my $file1 = "./${regmodel_file}";
    my $file2 = $project . "/tb/regmodel/${regmodel_file}";
    print LOGFILE "file1: $file1\n";
    print LOGFILE "file2: $file2\n";

    #open regmodel file and  put into package
    open( REGFILE_IN, "<" . $file1 )
      || die "Exiting due to Error: can't open $file1";
    open( REGFILE_OUT, ">" . $file2 )
      || die "Exiting due to Error: can't open $file2";
    my $guard_macro = "";
    COPY_HEADER: {
        $line = <REGFILE_IN>;

        #write header without modification
        if ( $line =~ /^\s*$|^\s*\/\/.*$|^\s*\/\*.*$|^\s*`ifndef\s+([\w_]+).*/ )
        {
            #blank line|comment|compiler directive
            if ($1) { $guard_macro = $1; }
            print REGFILE_OUT $line;
            redo COPY_HEADER;
        }
    }
    print REGFILE_OUT "package regmodel_pkg;\n";
    print REGFILE_OUT "\n";
    print REGFILE_OUT "import uvm_pkg::*;\n";
    print REGFILE_OUT "`include \"uvm_macros.svh\"\n";
    print REGFILE_OUT "\n";
    print REGFILE_OUT "$line";
    while ( $line = <REGFILE_IN> ) {

        #copy rest of package file
        last if ( $line =~ /\s*`endif\s+$guard_macro/ );
        print REGFILE_OUT $line;
    }
    print REGFILE_OUT "\n";
    print REGFILE_OUT "endpackage: regmodel_pkg\n";
    print REGFILE_OUT "\n";
    print REGFILE_OUT $line if $line;
    close(REGFILE_IN);
    close(REGFILE_OUT);
}

sub gen_regmodel_adapter {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/reg2" . $agent_name . "_adapter.sv" )
      || die "Exiting due to Error: can't open adapter: reg2${agent_name}_adapter.sv";

    write_file_header "${agent_name}_adapter.sv", "Environment for reg2 ${agent_name}_adapter.sv\n";

    print FH "`ifndef REG2" . uc($agent_name) . "_ADAPTER_SV\n";
    print FH "`define REG2" . uc($agent_name) . "_ADAPTER_SV\n";
    print FH "\n";
    insert_inc_file("", $agent_adapter_inc_before_class{$agent_name}, $agent_adapter_inc_before_inline{$agent_name}, "adapter_inc_before_class", $tpl_fname{$agent_name});

    print FH "class reg2${agent_name}_adapter extends uvm_reg_adapter;\n";
    print FH "\n";
    print FH "  `uvm_object_utils(reg2" . $agent_name . "_adapter)\n";
    print FH "\n";
    print FH "  extern function new(string name = \"\");\n";
    print FH "\n";

    unless ( exists $agent_adapter_generate_methods_inside_class{$agent_name} && $agent_adapter_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove reg2bus and bus2reg by setting adapter_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);\n";
        print FH "  extern function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);\n";
        print FH "\n";
    }

    insert_inc_file("  ", $agent_adapter_inc_inside_class{$agent_name}, $agent_adapter_inc_inside_inline{$agent_name}, "adapter_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : reg2" . $agent_name . "_adapter \n";
    print FH "\n";
    print FH "\n";
    print FH "function reg2${agent_name}_adapter::new(string name = \"\");\n";
    print FH "   super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";

    unless ( exists $agent_adapter_generate_methods_after_class{$agent_name} && $agent_adapter_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove reg2bus and bus2reg by setting adapter_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function uvm_sequence_item reg2${agent_name}_adapter::reg2bus(const ref uvm_reg_bus_op rw);\n";
        print FH "  $agent_item_types{$agent_name} ${agent_name} = $agent_item_types{$agent_name}::type_id::create(\"${agent_name}\");\n";

        if ( $reg_access_mode{$agent_name} =~ /WR|WO/i ) {
            align("  $agent_name.$bus2reg_map{$agent_name}->{'kind'} ", "= (rw.kind == UVM_READ) ? 0 : 1;", "");
            align("  $agent_name.$bus2reg_map{$agent_name}->{'addr'} ", "= rw.addr;", "");
            align("  $agent_name.$bus2reg_map{$agent_name}->{'data'} ", "= rw.data;", "");

            gen_aligned();

            print FH "  `uvm_info(get_type_name(), \$sformatf(\"reg2bus rw::kind: %s, addr: %d, data: %h, status: %s\", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)\n";
        }
        elsif ( $reg_access_mode{$agent_name} =~ /RO/i ) {
            align("  $agent_name.$bus2reg_map{$agent_name}->{'kind'} ", "= (rw.kind == UVM_READ) ? 0 : 1;", "");
            align("  $agent_name.$bus2reg_map{$agent_name}->{'addr'} ", "= rw.addr;", "");
            align("  $agent_name.$bus2reg_map{$agent_name}->{'data'} ", "= rw.data;", "");

            gen_aligned();

            print FH "  `uvm_info(get_type_name(), \$sformatf(\"reg2bus rw::kind: %s, addr: %d, data: %h, status: %s\", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)\n";
            print FH "  if (rw.kind != UVM_READ) `uvm_warning(get_type_name(), \"Interface is READ-ONLY\")\n";
        }
        else {
            warning_prompt("reg_access_mode is neither WR, WO, nor RO, so reg2${agent_name}_adapter is incomplete");
            print FH "  `uvm_warning(get_type_name(), \"Interface mode not specified\")\n";
        }

        print FH "  return " . $agent_name . ";\n";
        print FH "endfunction : reg2bus\n";
        print FH "\n";
        print FH "\n";
        print FH "function void reg2${agent_name}_adapter::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);\n";
        print FH "  $agent_item_types{$agent_name} ${agent_name};\n";
        print FH "  if (!\$cast(${agent_name}, bus_item))\n";
        print FH "    `uvm_fatal(get_type_name(),\"Provided bus_item is not of the correct type\")\n";

        if ( $reg_access_mode{$agent_name} =~ /WR|WO/i ) {
            print FH "  rw.kind   = $agent_name.$bus2reg_map{$agent_name}->{'kind'}" . " ? UVM_WRITE : UVM_READ;\n";
        }
        else {
            print FH "  rw.kind = UVM_READ;\n";
        }
        print FH "  rw.addr   = $agent_name.$bus2reg_map{$agent_name}->{'addr'};\n";
        print FH "  rw.data   = $agent_name.$bus2reg_map{$agent_name}->{'data'};\n";
        print FH "  rw.status = UVM_IS_OK;\n";
        print FH "  `uvm_info(get_type_name(), \$sformatf(\"bus2reg rw::kind: %s, addr: %d, data: %h, status: %s\", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)\n";
        print FH "endfunction : bus2reg\n";
        print FH "\n";
        print FH "\n";
    }
    insert_inc_file("", $agent_adapter_inc_after_class{$agent_name}, $agent_adapter_inc_after_inline{$agent_name}, "adapter_inc_after_class", $tpl_fname{$agent_name});
    print FH "\n";
    print FH "`endif // REG2" . uc($agent_name) . "_ADAPTER_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_regmodel_coverage {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_env_coverage.sv" )
      || die "Exiting due to Error: can't open config: ${agent_name}_env_coverage.sv";

    write_file_header "${agent_name}_env_coverage.sv", "Coverage for $agent_name env\n";

    print FH "`ifndef " . uc($agent_name) . "_ENV_COVERAGE_SV\n";
    print FH "`define " . uc($agent_name) . "_ENV_COVERAGE_SV\n";
    print FH "\n";

    insert_inc_file("", $reg_cover_inc_before_class{$agent_name}, $reg_cover_inc_before_inline{$agent_name}, "reg_cover_inc_before_class", $tpl_fname{$agent_name});

    print FH "class ${agent_name}_env_coverage extends uvm_subscriber #($agent_item_types{$agent_name});\n";
    print FH "\n";
    print FH "  `uvm_component_utils(" . $agent_name . "_env_coverage)\n";
    print FH "\n";

    align("  ${agent_name}_config ", "m_config;", "");
    align("  bit  ", "m_is_covered;", "");
    align("  $agent_item_types{$agent_name}  ", "m_item;", "");
    align("  $reg_access_block_type{$agent_name}  ", "regmodel;\n", "");

    gen_aligned();

    #if include file for coverage collector exists, pull it in here, otherwise
    #create covergroup and coverpoints with default bins
    if ( exists $reg_cover_inc{$agent_name}
        && -e "${project}/tb/include/$reg_cover_inc{$agent_name}" )
    {
             open(FH_COV, "<${project}/tb/include/$reg_cover_inc{$agent_name}") or die "CANNOT OPEN INCLUDE FILE reg_cover_inc{$agent_name}";
            my $cov_inc = join("",<FH_COV>);
            #check that file contains covergroup named "m_cov"
            if ($cov_inc =~ /covergroup\s+m_cov(\s|;)/) {
            print FH "  // Inserting covergroup from include file\n";
            insert_inc_file("  ", $reg_cover_inc{$agent_name}, $reg_cover_inc_inline{$agent_name}, "", "");
        }
        else
        {
                warn "WARNING. The file reg_cover_inc = $reg_cover_inc{$agent_name} should contain a covergroup named m_cov. Since it does not, it is assumed to contain only coverpoints. This still works but is deprecated, so you should modify the include file to contain the whole covergroup";
            print FH "  covergroup m_cov;\n";
            print FH "    option.per_instance = 1;\n";
            print FH "    // Inserting coverpoints from include file\n";
            insert_inc_file("    ", $reg_cover_inc{$agent_name}, $reg_cover_inc_inline{$agent_name}, "", "");
            print FH "  endgroup: m_cov\n";
            print FH "\n";
        }
    }
    else {
        unless ( exists $reg_cover_generate_methods_inside_class{$agent_name} && $reg_cover_generate_methods_inside_class{$agent_name} eq "NO" )
        {
            unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
                print FH "  // You can replace covergroup m_cov by setting reg_cover_inc in file $tpl_fname{$agent_name}\n";
                print FH "  // or remove covergroup m_cov by setting reg_cover_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
            }
            print FH "  covergroup m_cov;\n";
            print FH "    option.per_instance = 1;\n";
            print FH "    // You may insert additional coverpoints here ...\n";
            print FH "\n";
            print FH "  endgroup\n";
            print FH "\n";
        }
    }

    unless ( exists $reg_cover_generate_methods_inside_class{$agent_name} && $reg_cover_generate_methods_inside_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "  // You can remove new, write, and report_phase by setting reg_cover_generate_methods_inside_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "  extern function new(string name, uvm_component parent);\n";
        print FH "  extern function void write($agent_item_types{$agent_name} t);\n";
        print FH "  extern function void build_phase(uvm_phase phase);\n";
        print FH "  extern function void report_phase(uvm_phase phase);\n";
        print FH "\n";
    }

    insert_inc_file("  ", $reg_cover_inc_inside_class{$agent_name}, $reg_cover_inc_inside_inline{$agent_name}, "reg_cover_inc_inside_class", $tpl_fname{$agent_name});

    print FH "endclass : " . $agent_name . "_env_coverage \n";
    print FH "\n";
    print FH "\n";

    unless ( exists $reg_cover_generate_methods_after_class{$agent_name} && $reg_cover_generate_methods_after_class{$agent_name} eq "NO" )
    {
        unless ( defined $comments_at_include_locations && $comments_at_include_locations eq "NO" ) {
            print FH "// You can remove new, write, and report_phase by setting reg_cover_generate_methods_after_class = no in file $tpl_fname{$agent_name}\n\n";
        }
        print FH "function ${agent_name}_env_coverage::new(string name, uvm_component parent);\n";
        print FH "  super.new(name, parent);\n";
        print FH "  m_cov = new();\n";
        print FH "endfunction : new\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_env_coverage::write($agent_item_types{$agent_name} t);\n";
        print FH "  // Assign seq item properties to member variables\n";
        print FH "  m_item = t;\n";
        print FH "  m_cov.sample();\n";
        print FH "  // Check coverage - could use m_cov.option.goal instead of 100 if your simulator supports it\n";
        print FH "  if (m_cov.get_inst_coverage() >= 100) m_is_covered = 1;\n";
        print FH "endfunction : write\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_env_coverage::build_phase(uvm_phase phase);\n";
        print FH "  if (!uvm_config_db #(${agent_name}_config)::get(this, \"\", \"config\", m_config))\n";
        print FH "    `uvm_error(get_type_name(), \"${agent_name} config not found\")\n";
        print FH "endfunction : build_phase\n";
        print FH "\n";
        print FH "\n";
        print FH "function void ${agent_name}_env_coverage::report_phase(uvm_phase phase);\n";
        print FH "  if (m_config.coverage_enable)\n";
        print FH "    `uvm_info(get_type_name(), \$sformatf(\"Coverage score = %3.1f%%\", m_cov.get_inst_coverage()), UVM_MEDIUM)\n";
        print FH "  else\n";
        print FH "    `uvm_info(get_type_name(), \"Coverage disabled for this agent\", UVM_MEDIUM)\n";
        print FH "endfunction : report_phase\n";
        print FH "\n";
        print FH "\n";
    }

    insert_inc_file("", $reg_cover_inc_after_class{$agent_name}, $reg_cover_inc_after_inline{$agent_name}, "reg_cover_inc_after_class", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_ENV_COVERAGE_SV\n";
    print FH "\n";
    close(FH);
}

sub gen_regmodel_seq_lib {
    $dir = $project . "/tb/" . $agent_name;
    open( FH, ">" . $dir . "/sv/" . $agent_name . "_env_seq_lib.sv" )
      || die "Exiting due to Error: can't open seq_lib: " . $agent_name . "_env_seq_lib.sv";

    write_file_header "${agent_name}_env_seq_lib.sv", "Sequence for $agent_name env\n";

    print FH "`ifndef " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "`define " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "\n";

    print FH "class ${agent_name}_env_default_seq extends uvm_sequence #($agent_item_types{$agent_name});\n";
    print FH "\n";
    print FH "  `uvm_object_utils(" . $agent_name . "_env_default_seq)\n";
    print FH "\n";

    for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
        my $suffix = calc_suffix($i, $number_of_instances{$agent_name});

        align("  $reg_access_block_type{$agent_name} ", "regmodel${suffix};", "");
        align("  ${agent_name}_config ", "m_config${suffix};", "");
    }
    align("\n", "", "");
    align("  uvm_status_e ", "status;", "// Returning access status");
    align("  rand uvm_reg_data_t ", "data;", "// For passing data");

    gen_aligned();

    print FH "\n";
    print FH "  extern function new(string name = \"\");\n";
    print FH "  extern task body();\n";
    print FH "\n";
    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "  // Functions to support UVM 1.2 objection API in UVM 1.1\n";
    print FH "  extern function uvm_phase get_starting_phase();\n";
    print FH "  extern function void set_starting_phase(uvm_phase phase);\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "endclass : " . $agent_name . "_env_default_seq\n";
    print FH "\n";
    print FH "\n";
    print FH "function ${agent_name}_env_default_seq::new(string name = \"\");\n";
    print FH "  super.new(name);\n";
    print FH "endfunction : new\n";
    print FH "\n";
    print FH "\n";
    print FH "task ${agent_name}_env_default_seq::body();\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence starting\", UVM_HIGH)\n";
    print FH "\n";

    my $n = $number_of_instances{$agent_name};
    print FH "  fork\n" if $n > 1;

    for ( my $i = 0 ; $i < $n ; $i++ ) {
        my $suffix = calc_suffix($i, $n);

        print FH "  begin\n";
        print FH "    uvm_reg      data_regs[\$];\n";
        print FH "    regmodel${suffix}.get_registers(data_regs);\n";
        print FH "    data_regs.shuffle();\n";
        print FH "    foreach(data_regs[i])\n";
        print FH "    begin\n";
        print FH "      // Randomize register content and then update\n";
        print FH "      if ( !data_regs[i].randomize() )\n";
        print FH "        `uvm_error(get_type_name(), \$sformatf(\"Failed to randomize data_regs[%0d]\", i))\n";
        print FH "      data_regs[i].update(status, .path(UVM_FRONTDOOR), .parent(this));\n";
        print FH "    end\n";
        print FH "  end\n"

    }
    print FH "  join\n" if $n > 1;
    print FH "\n";
    print FH "  `uvm_info(get_type_name(), \"Default sequence completed\", UVM_HIGH)\n";
    print FH "endtask : body\n";
    print FH "\n";
    print FH "\n";

    print FH "`ifndef UVM_POST_VERSION_1_1\n";
    print FH "function uvm_phase ${agent_name}_env_default_seq::get_starting_phase();\n";
    print FH "  return starting_phase;\n";
    print FH "endfunction: get_starting_phase\n";
    print FH "\n";
    print FH "\n";
    print FH "function void ${agent_name}_env_default_seq::set_starting_phase(uvm_phase phase);\n";
    print FH "  starting_phase = phase;\n";
    print FH "endfunction: set_starting_phase\n";
    print FH "`endif\n";
    print FH "\n";
    print FH "\n";

    insert_inc_file("", $agent_env_seq_inc{$agent_name}, $agent_env_seq_inc_inline{$agent_name}, "agent_env_seq_inc", $tpl_fname{$agent_name});

    print FH "`endif // " . uc($agent_name) . "_ENV_SEQ_LIB_SV\n";
    print FH "\n";

    close(FH);
}

sub deal_with_files_f {
    if ( open( FILESFH, "<", "${dut_path}/files.f") ) {
        # files.f already exists in DUT directory
        close(FILESFH);
    }
    else {
        # files.f does not exist, so create files.f in the output directory
        open( FILESFH, ">", "${dut_tb_path}/files.f");
        opendir( DH, $dut_path ) or die "Unable to open DUT directory ${dut_path} when looking for DUT files.f\n";
        while (my $file = readdir(DH)) {
            if ( $file =~ /.*\.sv/ ) {
                print FILESFH "${file}\n";
            }
        }
        closedir(DH);
        close(FILESFH);
    }
}

sub gen_questa_script {
    $dir = $project . "/sim";
    open( FH, ">" . $dir . "/compile_questa.do" )
      || die "Exiting due to Error: can't open file: compile_questa.do";
    print FH "\n";
    print FH "file delete -force work\n\n";
    print FH "vlib work\n\n";
    print FH "#compile the dut code\n";
    print FH "set cmd \"vlog -F ../${dut_tb_dir}/files.f\"\n";
    print FH "eval \$cmd\n\n";

    if($common_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        do {
            print FH "set cmd \"vlog -sv ../${dut_tb_dir}/${common_pkg_fname}\"\n";
            print FH "eval \$cmd\n\n";
        } unless (grep /$common_pkg_fname/,<FFH>);
         close FFH;
    }

    do {
        print FH "#compile the register model package\n";
        print FH "set cmd \"vlog -sv  ../tb/regmodel/${regmodel_file}\"\n";
        print FH "eval \$cmd\n\n";
    } if $regmodel;

    print FH "set tb_name $tbname\n";
    $incdir = "+incdir+../tb/include ";
    foreach my $inc_path ( @inc_path_list ) {
        if ( $inc_path ne "" ) {
            $incdir .= "+incdir+" . $inc_path . " ";
        }
    }

    if($common_env_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        do {
            print FH "set cmd \"vlog -sv " . $incdir . " ../tb/include/${common_env_pkg_fname}\"\n";
            print FH "eval \$cmd\n\n";
        } unless (grep /$common_env_pkg_fname/,<FFH>);
         close FFH;
    }

    print FH "set agent_list {\\ \n";
    print LOGFILE "env_list=@env_list, agent_list=@agent_list,\n";
    foreach my $aname (@stand_alone_agents) {
        if ( $aname ne "" ) {
            print FH "    $aname \\\n";
        }
    }
    foreach my $agent (@agent_list) {
        if ( !grep( /$agent/, @stand_alone_agents ) ) {
            print FH "    $agent \\\n";
        }
    }
    print FH "}\n";

    print FH "foreach  ele \$agent_list {\n";
    print FH "  if {\$ele != \" \"} {\n";
    print FH "    set cmd  \"vlog -sv " . $incdir . "+incdir+../tb/\"\n";
    print FH "    append cmd \$ele \"/sv ../tb/\" \$ele \"/sv/\" \$ele \"_pkg.sv\ ../tb/\" \$ele \"/sv/\" \$ele \"_if.sv\"\n";

    if ( $split_transactors eq "YES") {
        print FH "    append cmd \" ../tb/\" \$ele \"/sv/\" \$ele \"_bfm.sv\"\n";
    }
    
    print FH "    eval \$cmd\n";
    print FH "  }\n";
    print FH "}\n\n";

    if ( defined $syosil_scoreboard_src_path ) {
        print FH "set cmd  \"vlog -sv +incdir+../../$syosil_scoreboard_src_path ../../$syosil_scoreboard_src_path/pk_syoscb.sv\"\n";
        print FH "eval \$cmd\n\n";
    }

    print FH "set cmd  \"vlog -sv " . $incdir . "+incdir+../tb/\"\n";
    print FH "append cmd \$tb_name \"/sv ../tb/\" \$tb_name \"/sv/\" \$tb_name \"_pkg.sv\"\n";
    print FH "eval \$cmd\n\n";

    print FH "set cmd  \"vlog -sv " . $incdir . "+incdir+../tb/\"\n";
    print FH "append cmd \$tb_name \"_test/sv ../tb/\" \$tb_name \"_test/sv/\" \$tb_name \"_test_pkg.sv\"\n";
    print FH "eval \$cmd\n\n";

    print FH "set cmd  \"vlog -sv -timescale $timeunit/$timeprecision "
      . $incdir
      . "+incdir+../tb/\"\n";
    print FH "append cmd \$tb_name \"_tb/sv ../tb/\" \$tb_name \"_tb/sv/\" \$tb_name \"_th.sv\"\n";
    print FH "eval \$cmd\n\n";

    print FH "set cmd  \"vlog -sv -timescale $timeunit/$timeprecision "
      . $incdir
      . "+incdir+../tb/\"\n";
    print FH "append cmd \$tb_name \"_tb/sv ../tb/\" \$tb_name \"_tb/sv/\" \$tb_name \"_tb.sv\"\n";
    print FH "eval \$cmd\n\n";

    print FH "vsim ${tb_module_name} ";
    if ( $dual_top eq "YES" ) {
        print FH "${th_module_name} ";
    }
    print FH "+UVM_TESTNAME=${tbname}_test ${uvm_cmdline} -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug\n";
    print FH "run 0\n";
    print FH "#do wave.do\n";
    close(FH);

    ### add execute permissions for script
    chmod( 0755, $dir . "/compile_questa.do" );
}

sub gen_vcs_script {
    my $dir = $project . "/sim";
    my $vcs_opts =
      "-sverilog +acc +vpi -timescale=$timeunit/$timeprecision -ntb_opts uvm-1.2";
    open( FH, ">" . $dir . "/compile_vcs.sh" )
      || die "Exiting due to Error: can't open file: compile_vcs.sh";
    print FH "#!/bin/sh\n";
    print FH "vcs $vcs_opts \\\n";
    gen_compile_file_list();
    print FH "-R +UVM_TESTNAME=${tbname}_test ${uvm_cmdline} \$* \n";
    close(FH);

    ### add execute permissions for script
    chmod( 0755, $dir . "/compile_vcs.sh" );
}

sub gen_ius_script {
    my $dir = $project . "/sim";
    my $ius_opts =
      "-vtimescale $timeunit/$timeprecision -uvmhome \${IUS_HOME}/tools/methodology/UVM/CDNS-1.2";
    open( FH, ">" . $dir . "/compile_ius.sh" )
      || die "Exiting due to Error: can't open file: compile_ius.sh";
    print FH "#!/bin/sh\n";
    print FH "IUS_HOME=`ncroot`\n";
    print FH "irun $ius_opts \\\n";
    gen_compile_file_list();
    print FH "+UVM_TESTNAME=${tbname}_test ${uvm_cmdline} \$* \n";
    close(FH);

    ### add execute permissions for script
    chmod( 0755, $dir . "/compile_ius.sh" );
}

sub gen_riviera_script {
    $dir = $project . "/sim";
    open( FH, ">" . $dir . "/compile_riviera.do" )
      || die "Exiting due to Error: can't open file: compile_riviera.do";
    print FH "\n";
    print FH "file delete -force work\n\n";
    print FH "alib work\n\n";
    print FH "# Compile the dut code\n";

    print FH "#set cmd \"alog -uvm -F ../${dut_tb_dir}/files.f\"  # Previous version using UVM 1.1d\n";
    print FH "set cmd \"alog +incdir+\$aldec/vlib/uvm-1.2/src -l uvm_1_2 -err VCP5417 W9 -err VCP3003 W9 -err VCP2129 W9 -F ../${dut_tb_dir}/files.f\"\n";

    print FH "eval \$cmd\n\n";

    print FH "#set cmd \"alog -uvm \"  # Previous version using UVM 1.1d\n";
    print FH "set cmd \"alog +incdir+\$aldec/vlib/uvm-1.2/src -l uvm_1_2 -err VCP5417 W9 -err VCP3003 W9 -err VCP2129 W9 \"\n";

    if($common_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        do {
        print FH "\n# Compile the common package\n";
            print FH "append cmd \" ../${dut_tb_dir}/${common_pkg_fname}\"\n";
        } unless (grep /$common_pkg_fname/,<FFH>);
         close FFH;
    }

    do {
        print FH "\n# Compile the register model package\n";
        print FH "append cmd \"  ../tb/regmodel/${regmodel_file}\"\n";
    } if $regmodel;

    print FH "\nset tb_name $tbname\n";
    $incdir = "+incdir+../tb/include ";
    foreach my $inc_path ( @inc_path_list  ) {
        if ( $inc_path ne "" ) {
            $incdir .= "+incdir+" . $inc_path . " ";
        }
    }
    print FH "append cmd \" " . $incdir . "\"\n";

    if($common_env_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        do {
            print FH "\n# Compile the common env package\n";
            print FH "append cmd \" ../tb/include/${common_env_pkg_fname}\"\n";
        } unless (grep /$common_env_pkg_fname/,<FFH>);
         close FFH;
    }

    print FH "\n# Compile the agents\n";
    print FH "set agent_list {\\ \n";
    print LOGFILE "env_list=@env_list, agent_list=@agent_list,\n";
    foreach my $aname (@stand_alone_agents) {
        if ( $aname ne "" ) {
            print FH "    $aname \\\n";
        }
    }
    foreach my $agent (@agent_list) {
        if ( !grep( /$agent/, @stand_alone_agents ) ) {
            print FH "    $agent \\\n";
        }
    }
    print FH "}\n";

    print FH "foreach  ele \$agent_list {\n";
    print FH "  if {\$ele != \" \"} {\n";
    print FH "    append cmd \" +incdir+../tb/\" \$ele \"/sv ../tb/\" \$ele \"/sv/\" \$ele \"_pkg.sv\ ../tb/\" \$ele \"/sv/\" \$ele \"_if.sv\"\n";
    if ( $split_transactors eq "YES") {
        print FH "    append cmd \" ../tb/\" \$ele \"/sv/\" \$ele \"_bfm.sv\"\n";
    }
    print FH "  }\n";
    print FH "}\n";

    if ( defined $syosil_scoreboard_src_path ) {
        print FH "\n# Compile the Syosil scoreboard\n";
        print FH "append cmd  \" +incdir+../../$syosil_scoreboard_src_path ../../$syosil_scoreboard_src_path/pk_syoscb.sv\"\n";
    }

    print FH "\n# Compile the test and the modules\n";
    print FH "append cmd \" +incdir+../tb/\" \$tb_name \"/sv\"\n";
    print FH "append cmd \" ../tb/\" \$tb_name \"/sv/\" \$tb_name \"_pkg.sv\"\n";
    print FH "append cmd \" ../tb/\" \$tb_name \"_test/sv/\" \$tb_name \"_test_pkg.sv\"\n";
    print FH "append cmd \" ../tb/\" \$tb_name \"_tb/sv/\" \$tb_name \"_th.sv\"\n";
    print FH "append cmd \" ../tb/\" \$tb_name \"_tb/sv/\" \$tb_name \"_tb.sv\"\n";
    print FH "eval \$cmd\n\n";

    print FH "asim ${tb_module_name} ";
    if ( $dual_top eq "YES" ) {
        print FH "${th_module_name} ";
    }
    print FH "+UVM_TESTNAME=${tbname}_test ${uvm_cmdline} -voptargs=+acc -solvefaildebug -uvmcontrol=all -classdebug\n";
    print FH "run -all\n";
    print FH "quit\n";
    close(FH);

    ### add execute permissions for script
    chmod( 0755, $dir . "/compile_riviera.do" );
}

sub gen_compile_file_list {
    my $incdir = "+incdir+../tb/include \\\n";
    foreach my $inc_path ( @inc_path_list ) {
        if ( $inc_path ne "" ) {
            $incdir .= "+incdir+$inc_path \\\n";
        }
    }
#    $incdir .= "+incdir+../tb/${tbname}_common/sv \\\n";

    foreach my $aname (@stand_alone_agents) {
        if ( $aname ne "" ) {
            $incdir .= "+incdir+../tb/${aname}/sv \\\n";
        }
    }
    foreach my $agent (@agent_list) {
        if ( !grep( /$agent/, @stand_alone_agents ) ) {
            $incdir .= "+incdir+../tb/${agent}/sv \\\n";
        }
    }

    if ( defined $syosil_scoreboard_src_path ) {
        $incdir .= "+incdir+../../${syosil_scoreboard_src_path}\\\n";
    }
    $incdir .= "+incdir+../tb/${tbname}/sv \\\n";
    $incdir .= "+incdir+../tb/${tbname}_test/sv \\\n";
    $incdir .= "+incdir+../tb/${tbname}_tb/sv \\\n";

    print FH "$incdir";
    print FH "-F ../${dut_tb_dir}/files.f \\\n";

    if ($common_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        print FH "../${dut_tb_dir}/${common_pkg_fname} \\\n" unless (grep /$common_pkg_fname/,<FFH>);
        close FFH;
    }

    if ($common_env_pkg_fname) {
        open (FFH, "<", "${dut_tb_path}/files.f") || die "Exiting due to Error: can't open file: ${dut_tb_path}/files.f";
        print FH "../tb/include/${common_env_pkg_fname} \\\n" unless (grep /$common_env_pkg_fname/,<FFH>);
        close FFH;
    }

    #compile the register model package;
    print FH "../tb/regmodel/${regmodel_file} \\\n" if $regmodel;

    #need to compile agents before envs
    foreach my $aname (@stand_alone_agents) {
        if ( $aname ne "" ) {
            print FH "../tb/${aname}/sv/${aname}_pkg.sv \\\n";
            print FH "../tb/${aname}/sv/${aname}_if.sv \\\n";
        }
    }
    foreach my $agent (@agent_list) {
        if ( !grep( /$agent/, @stand_alone_agents ) ) {
            print FH "../tb/${agent}/sv/${agent}_pkg.sv \\\n";
            print FH "../tb/${agent}/sv/${agent}_if.sv \\\n";
        }
    }

    if ( $split_transactors eq "YES") {
       foreach my $agent (@agent_list) {
            print FH "../tb/${agent}/sv/${agent}_bfm.sv \\\n";
       }
    }

    if ( defined $syosil_scoreboard_src_path ) {
        print FH "../../$syosil_scoreboard_src_path/pk_syoscb.sv \\\n";
    }

    print FH "../tb/${tbname}/sv/${tbname}_pkg.sv \\\n";
    print FH "../tb/${tbname}_test/sv/${tbname}_test_pkg.sv \\\n";
    print FH "../tb/${tbname}_tb/sv/${tbname}_th.sv \\\n";
    print FH "../tb/${tbname}_tb/sv/${tbname}_tb.sv \\\n";
}

sub print_structure {
    print "Generated hierarchy of envs and agents:\n";
    foreach my $agent_env (@env_list) {
        print "  m_$agent_env\n";

        $agent_env =~ /(\w+)_env/;
        my $agent_name = $1;
        
        for ( my $i = 0 ; $i < $number_of_instances{$agent_name} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$agent_name});

            print "    m_${agent_name}${suffix}_agent\n";
        }
        foreach my $extra_agent ( @{ $env_agents{$agent_env} } ) {
            print "    m_${extra_agent}_agent\n";
        }
    }
    foreach my $agent (@top_env_agents) {
        for ( my $i = 0 ; $i < $number_of_instances{$agent} ; $i++ ) {
            my $suffix = calc_suffix($i, $number_of_instances{$agent});

            print "  m_${agent}${suffix}_agent\n";
        }
    }

    #print "----- ----- ----- ----- -----\n";
    #foreach my $inst ( @agent_instance_names ) {
    #    print "Instance name = $inst, agent type = $agent_type_by_inst{$inst}\n";
    #}
    #print "----- ----- ----- ----- -----\n";

}
