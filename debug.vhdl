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
        variable priv  : std_ulogic_vector(1 downto 0)  := "00";
        variable ciea  : std_ulogic_vector(63 downto 0) := (others => '0');
        variable match : std_ulogic                     := '0';
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ciabr <= 64x"0";
                priv := "00";
                ciea := (others => '0');
                match := '0';
            else
                if p_in.mtspr = '1' and p_in.spr_num(4 downto 0) = "11011" then
                    ciabr <= p_in.spr_val;
                end if;

                if p_in.d_smfctrl /= '1' then
                    priv := ciabr(1 downto 0);
                    ciea(63 downto 2) := ciabr(63 downto 2);
                    if ciea = p_in.instr_addr then
                        match := '1';
                    else
                        match := '0';
                    end if;
                    p_out.intr <= '0';

                    if match = '1' and priv = "01" and p_in.pr_msr = '0' then
                        p_out.intr <= '1';
                    elsif match = '1' and priv = "10" and p_in.pr_msr = '0' and p_in.hv_msr = '0' then
                        p_out.intr <= '1';
                    elsif match = '1' and priv = "11" and p_in.pr_msr = '0' and p_in.hv_msr = '1' and p_in.s_msr = '0' then
                        p_out.intr <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end architecture behavior;
