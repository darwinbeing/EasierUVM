class dummy_reg extends uvm_reg;
   `uvm_object_utils(dummy_reg)

   rand uvm_reg_field F;

   function new(string name = "");
      super.new(name, 8, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      F = uvm_reg_field::type_id::create("F");
      F.configure(this, 8, 0, "RW", 1, 8'h00, 1, 1, 1);
   endfunction
endclass


class bus_reg_block extends uvm_reg_block;
   `uvm_object_utils(bus_reg_block)

   rand dummy_reg reg0;

   uvm_reg_map bus_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      reg0 = dummy_reg::type_id::create("reg0");
      reg0.configure(this);
      reg0.build();

      bus_map = create_map("bus_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = bus_map;

      bus_map.add_reg(reg0, 'h0, "RW");

      lock_model();
   endfunction
endclass

class top_reg_block extends uvm_reg_block;
   `uvm_object_utils(top_reg_block)

   bus_reg_block bus; 

   uvm_reg_map bus_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      bus = bus_reg_block::type_id::create("bus");
      bus.configure(this);
      bus.build();

      bus_map = create_map("bus_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = bus_map;

      bus_map.add_submap(bus.bus_map, 'h0);

      lock_model();
   endfunction
endclass
