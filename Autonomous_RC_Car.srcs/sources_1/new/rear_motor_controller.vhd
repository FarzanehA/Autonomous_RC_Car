----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2026 08:44:35 PM
-- Design Name: 
-- Module Name: rear_motor_controller - Behavioral
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

entity rear_motor_controller is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        PWM_FREQ_HZ : positive := 1_000;
        THRESHOLD_CM : positive := 30
    );
    port (
        clk : in std_logic;
        rst : in std_logic;  -- Active-low reset

        -- Ultrasonic measurement inputs
        distance : in unsigned(15 downto 0);
        valid : in std_logic;

        -- Requested motor speed: 0 = stop, 255 = full duty
        requested_speed : in unsigned(7 downto 0);

        -- Output to the motor driver's enable/PWM input
        motor_pwm_out : out std_logic;

        -- Status output for testing and debugging
        obstacle_detected : out std_logic
    );
end rear_motor_controller;

architecture Behavioral of rear_motor_controller is

    signal obstacle_internal : std_logic := '0';
    signal effective_speed : unsigned(7 downto 0) := (others => '0');

begin

    -- Detect obstacles using the existing detector.
    u_obstacle_detector : entity work.obstacle_detector
        generic map (
            THRESHOLD_CM => THRESHOLD_CM
        )
        port map (
            clk => clk,
            rst => rst,
            distance => distance,
            valid => valid,
            obstacle_detected => obstacle_internal
        );

    -- Stop the motor when an obstacle is detected.
    effective_speed <= (others => '0')
    when rst = '0' or obstacle_internal = '1'
    else requested_speed;

    -- Generate PWM for the rear motor.
    u_motor_pwm : entity work.motor_pwm
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => PWM_FREQ_HZ
        )
        port map (
            clk => clk,
            rst => rst,
            duty_cycle => effective_speed,
            pwm_out => motor_pwm_out
        );

    obstacle_detected <= obstacle_internal;

end Behavioral;
