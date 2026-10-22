----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/17/2026 06:27:47 PM
-- Design Name: 
-- Module Name: motor_pwm - Behavioral
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

entity motor_pwm is
    generic (
        CLK_FREQ_HZ : positive := 50_000_000;
        PWM_FREQ_HZ : positive := 1_000
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;  -- Active-low reset
        duty_cycle : in  unsigned(7 downto 0); -- 0 to 255
        pwm_out    : out std_logic
    );
end motor_pwm;

architecture Behavioral of motor_pwm is

    constant PWM_PERIOD : positive := CLK_FREQ_HZ / PWM_FREQ_HZ;

    signal counter : integer range 0 to PWM_PERIOD - 1 := 0;
    signal pwm_reg : std_logic := '0';

begin

    process(clk)
        variable duty_count : integer range 0 to PWM_PERIOD;
    begin
        if rising_edge(clk) then
            if rst = '0' then
                counter <= 0;
                pwm_reg <= '0';
            else
                if counter = PWM_PERIOD - 1 then
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

                duty_count :=
                    (to_integer(duty_cycle) * PWM_PERIOD) / 255;

                if to_integer(duty_cycle) = 0 then
                    pwm_reg <= '0';
                elsif counter < duty_count then
                    pwm_reg <= '1';
                else
                    pwm_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    pwm_out <= pwm_reg;

end Behavioral;
