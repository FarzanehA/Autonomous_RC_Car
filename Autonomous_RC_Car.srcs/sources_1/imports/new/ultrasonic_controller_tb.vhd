----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/04/2026 12:52:37 PM
-- Design Name: 
-- Module Name: ultrasonic_controller_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultrasonic_controller_tb is
end ultrasonic_controller_tb;

architecture Behavioral of ultrasonic_controller_tb is

    constant CLK_PERIOD : time := 1 us;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal echo     : std_logic := '0';
    signal trigger  : std_logic;
    signal distance : unsigned(15 downto 0);
    signal valid    : std_logic;

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut: entity work.ultrasonic_controller
        generic map (
            CLK_FREQ_HZ => 1_000_000
        )
        port map (
            clk      => clk,
            rst      => rst,
            echo     => echo,
            trigger  => trigger,
            distance => distance,
            valid    => valid
        );

    stimulus: process

        procedure run_test(
            constant pulse_cycles : in integer;
            constant expected_cm  : in integer;
            constant test_number  : in integer
        ) is
        begin
            -- Wait for the next trigger pulse
            wait until rising_edge(trigger);
            wait until falling_edge(trigger);

            -- Generate simulated Echo pulse
            echo <= '1';
            wait for pulse_cycles * CLK_PERIOD;
            echo <= '0';

            -- Wait for measurement result
            wait until rising_edge(valid);

            report "Test " & integer'image(test_number) &
                   ": Expected = " & integer'image(expected_cm) &
                   " cm, Measured = " &
                   integer'image(to_integer(distance)) & " cm";

            assert abs(to_integer(distance) - expected_cm) <= 1
                report "Test failed!"
                severity error;

            report "Test " & integer'image(test_number) & " passed"
                severity note;

        end procedure;

    begin

        -- Reset
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        wait until falling_edge(clk);
        rst <= '0';

        -- Test 1: 10 cm
        run_test(580, 10, 1);

        -- Test 2: 30 cm
        run_test(1740, 30, 2);

        -- Test 3: 50 cm
        run_test(2900, 50, 3);

        report "All tests completed."
            severity note;

        wait;
    end process;

end Behavioral;
