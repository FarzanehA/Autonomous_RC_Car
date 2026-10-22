
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity obstacle_detector_tb is
end obstacle_detector_tb;

architecture sim of obstacle_detector_tb is

    constant CLK_PERIOD : time := 20 ns;

    signal clk               : std_logic := '0';
    signal rst               : std_logic := '0';
    signal distance          : unsigned(15 downto 0) := (others => '0');
    signal valid             : std_logic := '0';
    signal obstacle_detected : std_logic;

begin

    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.obstacle_detector
        generic map (
            THRESHOLD_CM => 30
        )
        port map (
            clk               => clk,
            rst               => rst,
            distance          => distance,
            valid             => valid,
            obstacle_detected => obstacle_detected
        );

    stimulus : process
    begin
        -- Reset
        rst <= '0';
        wait for 3 * CLK_PERIOD;
        rst <= '1';
        wait until rising_edge(clk);

        -- Test 1: 100 cm -> clear
        distance <= to_unsigned(100, 16);
        valid <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '0'
            report "TEST 1 FAILED: 100 cm"
            severity error;
        report "TEST 1 PASSED: 100 cm" severity note;

        -- Test 2: 31 cm -> clear
        distance <= to_unsigned(31, 16);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '0'
            report "TEST 2 FAILED: 31 cm"
            severity error;
        report "TEST 2 PASSED: 31 cm" severity note;

        -- Test 3: 30 cm -> obstacle
        distance <= to_unsigned(30, 16);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '1'
            report "TEST 3 FAILED: 30 cm"
            severity error;
        report "TEST 3 PASSED: 30 cm" severity note;

        -- Test 4: 15 cm -> obstacle
        distance <= to_unsigned(15, 16);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '1'
            report "TEST 4 FAILED: 15 cm"
            severity error;
        report "TEST 4 PASSED: 15 cm" severity note;

        -- Test 5: invalid measurement -> hold previous result
        valid <= '0';
        distance <= to_unsigned(100, 16);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '1'
            report "TEST 5 FAILED: result should hold"
            severity error;
        report "TEST 5 PASSED: invalid holds result"
            severity note;

        -- Test 6: valid clear measurement -> clear again
        valid <= '1';
        distance <= to_unsigned(100, 16);
        wait until rising_edge(clk);
        wait for 1 ns;
        assert obstacle_detected = '0'
            report "TEST 6 FAILED: clear after 100 cm"
            severity error;
        report "TEST 6 PASSED: clear after 100 cm"
            severity note;

        report "ALL OBSTACLE DETECTOR TESTS COMPLETED"
            severity note;

        wait;
    end process;

end sim;
