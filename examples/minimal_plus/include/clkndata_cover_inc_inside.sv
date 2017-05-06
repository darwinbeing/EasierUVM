covergroup m_cov;
  option.per_instance = 1;
  cp_data: coverpoint m_item.data {
    bins zero = {0};
    bins one  = {1};
    bins negative = { [-128:-1] };
    bins positive = { [1: 127] };
    option.at_least = 16;
  }
endgroup

extern function new (string name, uvm_component parent);
extern function void write(input data_tx t);
