
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rear_motor_controller_tb is
end rear_motor_controller_tb;

architecture Behavioral of rear_motor_controller_tb is

    constant CLK_PERIOD : time := 1 us;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal distance : unsigned(15 downto 0) :=
        (others => '0');
    signal valid : std_logic := '0';

    signal requested_speed : unsigned(7 downto 0) :=
        to_unsigned(128, 8);

    signal motor_pwm_out : std_logic := '0';
    signal obstacle_detected : std_logic := '0';

begin

    -- 1 MHz clock
    clk <= not clk after CLK_PERIOD / 2;

    -- Unit under test
    uut : entity work.rear_motor_controller
        generic map (
            CLK_FREQ_HZ  => 1_000_000,
            PWM_FREQ_HZ  => 1_000,
            THRESHOLD_CM => 30
        )
        port map (
            clk               => clk,
            rst               => rst,
            distance          => distance,
            valid             => valid,
            requested_speed   => requested_speed,
            motor_pwm_out     => motor_pwm_out,
            obstacle_detected => obstacle_detected
        );

    stimulus : process
    begin

        report "TEST 1: Reset stops the motor";

        rst <= '0';
        wait for 10 * CLK_PERIOD;

        assert motor_pwm_out = '0'
            report "FAIL: PWM should be low during reset"
            severity error;

        assert obstacle_detected = '0'
            report "FAIL: Obstacle signal should clear on reset"
            severity error;

        report "TEST 1 PASSED";

        -- Release active-low reset
        rst <= '1';
        wait for 5 * CLK_PERIOD;

        --------------------------------------------------
        -- TEST 2: No obstacle, motor runs
        --------------------------------------------------
        report "TEST 2: Clear path enables motor PWM";

        distance <= to_unsigned(100, 16);
        valid <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        valid <= '0';

        wait until motor_pwm_out = '1' for 2 ms;

        assert motor_pwm_out = '1'
            report "FAIL: PWM did not become active on a clear path"
            severity error;

        assert obstacle_detected = '0'
            report "FAIL: 100 cm should not be an obstacle"
            severity error;

        report "TEST 2 PASSED";

        --------------------------------------------------
        -- TEST 3: Obstacle at 20 cm stops motor
        --------------------------------------------------
        report "TEST 3: Nearby obstacle stops motor";

        distance <= to_unsigned(20, 16);
        valid <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        valid <= '0';

        -- Allow registered obstacle and PWM signals to update
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait for 1 ns;

        assert obstacle_detected = '1'
            report "FAIL: Obstacle at 20 cm was not detected"
            severity error;

        assert motor_pwm_out = '0'
            report "FAIL: Motor PWM should stop for a nearby obstacle"
            severity error;

        -- Verify the motor remains stopped
        wait for 2 ms;

        assert motor_pwm_out = '0'
            report "FAIL: PWM became active while obstacle remained detected"
            severity error;

        report "TEST 3 PASSED";

        --------------------------------------------------
        -- TEST 4: Clear path, motor resumes
        --------------------------------------------------
        report "TEST 4: Motor resumes when path clears";

        distance <= to_unsigned(100, 16);
        valid <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        valid <= '0';

        assert obstacle_detected = '0'
            report "FAIL: Obstacle signal did not clear"
            severity error;

        wait until motor_pwm_out = '1' for 2 ms;

        assert motor_pwm_out = '1'
            report "FAIL: Motor PWM did not resume"
            severity error;

        report "TEST 4 PASSED";

        --------------------------------------------------
        -- TEST 5: Requested speed zero stops motor
        --------------------------------------------------
        report "TEST 5: Zero requested speed stops motor";

        requested_speed <= (others => '0');

        wait for 2 ms;

        assert motor_pwm_out = '0'
            report "FAIL: PWM should be low at zero requested speed"
            severity error;

        report "TEST 5 PASSED";

        report "ALL REAR MOTOR CONTROLLER TESTS PASSED";

        wait;
    end process;

end Behavioral;
