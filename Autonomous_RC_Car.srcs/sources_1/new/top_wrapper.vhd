
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_wrapper is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;  -- Active-low reset
        echo          : in  std_logic;
        trigger       : out std_logic;
        motor_pwm_out : out std_logic;
        led           : out std_logic;
        motor_in1     : out std_logic;
        motor_in2     : out std_logic
    );
end top_wrapper;

architecture Behavioral of top_wrapper is

    constant CLK_FREQ_HZ  : positive := 50_000_000;
    constant PWM_FREQ_HZ  : positive := 1_000;
    constant THRESHOLD_CM : positive := 15;
    constant FULL_SPEED_CM : positive := 100;

    -- Full speed = 255/255
    -- Half speed = 128/255
    signal requested_speed_internal : unsigned(7 downto 0) :=
        (others => '0');

    signal trigger_internal : std_logic := '0';

    signal distance_internal : unsigned(15 downto 0) :=
        (others => '0');

    signal valid_internal : std_logic := '0';

    signal obstacle_detected_internal : std_logic := '0';

    signal motor_pwm_internal : std_logic := '0';

    component ila_0
        port (
            clk    : in std_logic;
            probe0 : in std_logic_vector(0 downto 0);
            probe1 : in std_logic_vector(0 downto 0);
            probe2 : in std_logic_vector(15 downto 0);
            probe3 : in std_logic_vector(0 downto 0);
            probe4 : in std_logic_vector(0 downto 0);
            probe5 : in std_logic_vector(0 downto 0);
            probe6 : in std_logic_vector(0 downto 0)
        );
    end component;

begin

    --------------------------------------------------
    -- 1. Ultrasonic sensor controller
    --------------------------------------------------
    u_ultrasonic : entity work.ultrasonic_controller
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ
        )
        port map (
            clk      => clk,
            rst      => rst,
            echo     => echo,
            trigger  => trigger_internal,
            distance => distance_internal,
            valid    => valid_internal
        );

    --------------------------------------------------
    -- 2. Distance-based speed selection
    --
    -- > 100 cm : Full speed
    -- 16-100 cm: Half speed
    -- <= 15 cm : Stop through obstacle override
    --------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                requested_speed_internal <= (others => '0');

            elsif valid_internal = '1' then
                if distance_internal <= to_unsigned(15, 16) then
                    requested_speed_internal <= (others => '0');

                elsif distance_internal > to_unsigned(100, 16) then
                    -- More than 100 cm: full speed
                    requested_speed_internal <= to_unsigned(255, 8);

                else
                    -- 16 to 100 cm: half speed
                    requested_speed_internal <= to_unsigned(50, 8);
                end if;
            end if;
            -- When valid_internal = '0', keep the previous speed.
        end if;
    end process;

    --------------------------------------------------
    -- 3. Rear motor controller
    --------------------------------------------------
    u_rear_motor_controller : entity work.rear_motor_controller
        generic map (
            CLK_FREQ_HZ  => CLK_FREQ_HZ,
            PWM_FREQ_HZ  => PWM_FREQ_HZ,
            THRESHOLD_CM => THRESHOLD_CM
        )
        port map (
            clk               => clk,
            rst               => rst,
            distance          => distance_internal,
            valid             => valid_internal,
            requested_speed   => requested_speed_internal,
            motor_pwm_out     => motor_pwm_internal,
            obstacle_detected => obstacle_detected_internal
        );

    --------------------------------------------------
    -- 4. External outputs
    --------------------------------------------------
    trigger <= trigger_internal;

    -- LED off when an obstacle is detected
    led <= not obstacle_detected_internal;

    -- Forward direction; both LOW during reset
    motor_in1 <= '1' when rst = '1' else '0';
    motor_in2 <= '0';

    -- Route internal PWM to the FPGA output pin
    motor_pwm_out <= motor_pwm_internal;

    --------------------------------------------------
    -- 5. Integrated Logic Analyzer
    --------------------------------------------------
    u_ila : ila_0
        port map (
            clk       => clk,
            probe0(0) => trigger_internal,
            probe1(0) => echo,
            probe2    => std_logic_vector(distance_internal),
            probe3(0) => obstacle_detected_internal,
            probe4(0) => rst,
            probe5(0) => valid_internal,
            probe6(0) => motor_pwm_internal
        );

end Behavioral;
