library verilog;
use verilog.vl_types.all;
entity alu is
    generic(
        DATA_WIDTH      : integer := 16
    );
    port(
        oc              : in     vl_logic_vector(2 downto 0);
        a               : in     vl_logic_vector;
        b               : in     vl_logic_vector;
        f               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end alu;
