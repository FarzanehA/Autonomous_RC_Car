----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2026 06:28:58 PM
-- Design Name: 
-- Module Name: motor_pwm_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity motor_pwm_tb is
end motor_pwm_tb;

architecture Behavioral of motor_pwm_tb is

    constant CLK_FREQ_HZ : positive := 1_000_000;
    constant PWM_FREQ_HZ : positive := 1_000;
    constant CLK_PERIOD  : time := 1 us;
    constant PWM_PERIOD  : time := 1 ms;

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal duty_cycle : unsigned(7 downto 0) := (others => '0');
    signal pwm_out    : std_logic;

begin

    -- Device under test
    uut : entity work.motor_pwm
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => PWM_FREQ_HZ
        )
        port map (
            clk        => clk,
            rst        => rst,
            duty_cycle => duty_cycle,
            pwm_out    => pwm_out
        );

    -- 1 MHz clock
    clk <= not clk after CLK_PERIOD / 2;

    stimulus : process
        variable high_count : integer;
        variable expected   : integer;
    begin

        report "Starting motor_pwm tests";

        -- Test 0: Reset
        rst <= '0';
        duty_cycle <= to_unsigned(128, 8);
        wait for 5 * CLK_PERIOD;

        assert pwm_out = '0'
            report "FAIL: PWM should be LOW during reset"
            severity error;

        report "Test 0 passed: Reset";

        -- Release reset
        wait until falling_edge(clk);
        rst <= '1';

        -- Test 1: 0% duty cycle
        duty_cycle <= to_unsigned(0, 8);
        wait for PWM_PERIOD;

        assert pwm_out = '0'
            report "FAIL: PWM should remain LOW at 0%"
            severity error;

        report "Test 1 passed: 0% duty cycle";

        -- Test 2: 25% duty cycle
        duty_cycle <= to_unsigned(64, 8);
        wait for 2 * PWM_PERIOD;

        high_count := 0;
        for i in 1 to 1000 loop
            wait until rising_edge(clk);
            if pwm_out = '1' then
                high_count := high_count + 1;
            end if;
        end loop;

        expected := (64 * 1000) / 255;

        assert abs(high_count - expected) <= 2
            report "FAIL: Incorrect PWM high time at 25%"
            severity error;

        report "Test 2 passed: 25% duty cycle";

        -- Test 3: 50% duty cycle
        duty_cycle <= to_unsigned(128, 8);
        wait for 2 * PWM_PERIOD;

        high_count := 0;
        for i in 1 to 1000 loop
            wait until rising_edge(clk);
            if pwm_out = '1' then
                high_count := high_count + 1;
            end if;
        end loop;

        expected := (128 * 1000) / 255;

        assert abs(high_count - expected) <= 2
            report "FAIL: Incorrect PWM high time at 50%"
            severity error;

        report "Test 3 passed: 50% duty cycle";

        -- Test 4: 75% duty cycle
        duty_cycle <= to_unsigned(192, 8);
        wait for 2 * PWM_PERIOD;

        high_count := 0;
        for i in 1 to 1000 loop
            wait until rising_edge(clk);
            if pwm_out = '1' then
                high_count := high_count + 1;
            end if;
        end loop;

        expected := (192 * 1000) / 255;

        assert abs(high_count - expected) <= 2
            report "FAIL: Incorrect PWM high time at 75%"
            severity error;

        report "Test 4 passed: 75% duty cycle";

        -- Test 5: 100% duty cycle
        duty_cycle <= to_unsigned(255, 8);
        wait for 2 * PWM_PERIOD;

        high_count := 0;
        for i in 1 to 1000 loop
            wait until rising_edge(clk);
            if pwm_out = '1' then
                high_count := high_count + 1;
            end if;
        end loop;

        assert high_count = 1000
            report "FAIL: PWM should remain HIGH at 100%"
            severity error;

        report "Test 5 passed: 100% duty cycle";

        report "All motor_pwm tests completed successfully"
            severity note;

        wait;
    end process;

end Behavioral;
