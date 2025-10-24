library verilog;
use verilog.vl_types.all;
entity cpu is
    generic(
        ADDR_WIDTH      : integer := 6;
        DATA_WIDTH      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        mem             : in     vl_logic_vector;
        \in\            : in     vl_logic_vector;
        control         : in     vl_logic;
        status          : out    vl_logic;
        we              : out    vl_logic;
        addr            : out    vl_logic_vector;
        data            : out    vl_logic_vector;
        \out\           : out    vl_logic_vector;
        pc              : out    vl_logic_vector;
        sp              : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end cpu;
