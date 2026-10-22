
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity obstacle_detector is
    generic (
        THRESHOLD_CM : positive := 30
    );
    port (
        clk               : in  std_logic;
        rst               : in  std_logic;  -- Active-low reset
        distance          : in  unsigned(15 downto 0);
        valid             : in  std_logic;
        obstacle_detected : out std_logic
    );
end obstacle_detector;

architecture Behavioral of obstacle_detector is

    signal obstacle_reg : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                obstacle_reg <= '0';

            elsif valid = '1' then
                if distance <= to_unsigned(THRESHOLD_CM, 16) then
                    obstacle_reg <= '1';
                else
                    obstacle_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    obstacle_detected <= obstacle_reg;

end Behavioral;
