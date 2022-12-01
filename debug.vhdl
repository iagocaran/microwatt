library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;
use work.decode_types.all;

entity debug is
    port (
        clk   : in  std_ulogic;
        rst   : in  std_ulogic;
        p_in  : in  Execute1ToDebugType;
        p_out : out DebugToExecute1Type
        );
end entity debug;

architecture behavior of debug is
    signal ciabr : std_ulogic_vector(63 downto 0);
begin
    with p_in.spr_num(4 downto 0) select p_out.spr_val <=
        ciabr     when "11011",
        64x"0"    when others;

    debug_1: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ciabr <= 64x"0";
            end if;
        end if;
    end process;
    
end architecture behavior;
