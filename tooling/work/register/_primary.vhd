library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        DATA_WIDTH      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        cl              : in     vl_logic;
        ld              : in     vl_logic;
        \in\            : in     vl_logic_vector;
        inc             : in     vl_logic;
        dec             : in     vl_logic;
        sr              : in     vl_logic;
        ir              : in     vl_logic;
        sl              : in     vl_logic;
        il              : in     vl_logic;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end \register\;
