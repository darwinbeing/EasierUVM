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


class bus1_reg_block extends uvm_reg_block;
   `uvm_object_utils(bus1_reg_block)

   rand dummy_reg reg0;

   uvm_reg_map bus1_map; // Code gen seems to demand exactly this name!?????

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      reg0 = dummy_reg::type_id::create("reg0");
      reg0.configure(this);
      reg0.build();

      bus1_map = create_map("bus1_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = bus1_map;

      bus1_map.add_reg(reg0, 'h0, "RW");

      lock_model();
   endfunction
endclass


class bus2_reg_block extends uvm_reg_block;
   `uvm_object_utils(bus2_reg_block)

   rand dummy_reg reg0;

   uvm_reg_map bus2_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      reg0 = dummy_reg::type_id::create("reg0");
      reg0.configure(this);
      reg0.build();

      bus2_map = create_map("bus2_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = bus2_map;

      bus2_map.add_reg(reg0, 'h0, "RW");

      lock_model();
   endfunction
endclass


class top_reg_block extends uvm_reg_block;
   `uvm_object_utils(top_reg_block)

   bus1_reg_block bus1; 
   bus2_reg_block bus2; 

   uvm_reg_map bus1_map; 
   uvm_reg_map bus2_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      bus1 = bus1_reg_block::type_id::create("bus");
      bus1.configure(this);
      bus1.build();

      bus1_map = create_map("bus1_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map = bus1_map;

      bus1_map.add_submap(bus1.bus1_map, 'h0);

      bus2 = bus2_reg_block::type_id::create("bus2");
      bus2.configure(this);
      bus2.build();

      bus2_map = create_map("bus2_map", 'h8, 1, UVM_LITTLE_ENDIAN);
      default_map = bus2_map;

      bus2_map.add_submap(bus2.bus2_map, 'h0);

      lock_model();
   endfunction
endclass
