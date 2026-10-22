
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultrasonic_controller is
    generic (
        CLK_FREQ_HZ : integer := 50_000_000
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;  -- Active-low reset
        echo     : in  std_logic;
        trigger  : out std_logic;
        distance : out unsigned(15 downto 0);
        valid    : out std_logic
    );
end ultrasonic_controller;

architecture Behavioral of ultrasonic_controller is

    type state_type is (IDLE, TRIG_HIGH, WAIT_ECHO, MEASURE);
    signal state : state_type := IDLE;

    constant TRIG_COUNT     : integer := CLK_FREQ_HZ / 100_000;
    constant PERIOD_COUNT   : integer := CLK_FREQ_HZ / 16;
    constant TIMEOUT_COUNT  : integer := CLK_FREQ_HZ / 30;
    constant TICKS_PER_CM   : integer := CLK_FREQ_HZ / 17_200;

    signal period_counter : integer range 0 to PERIOD_COUNT := 0;
    signal timer_counter  : integer range 0 to TIMEOUT_COUNT := 0;
    signal echo_counter   : integer range 0 to TIMEOUT_COUNT := 0;

    signal echo_sync1 : std_logic := '0';
    signal echo_sync2 : std_logic := '0';

    signal trigger_reg  : std_logic := '0';
    signal distance_reg : unsigned(15 downto 0) := (others => '0');
    signal valid_reg    : std_logic := '0';

begin

    trigger  <= trigger_reg;
    distance <= distance_reg;
    valid    <= valid_reg;

    -- Synchronize the asynchronous sensor Echo signal.
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                echo_sync1 <= '0';
                echo_sync2 <= '0';
            else
                echo_sync1 <= echo;
                echo_sync2 <= echo_sync1;
            end if;
        end if;
    end process;

    -- Ultrasonic measurement state machine.
    process(clk)
        variable measured_cm : integer;
    begin
        if rising_edge(clk) then
            if rst = '0' then
                state          <= IDLE;
                period_counter <= 0;
                timer_counter  <= 0;
                echo_counter   <= 0;
                trigger_reg    <= '0';
                distance_reg   <= (others => '0');
                valid_reg      <= '0';

            else
                -- Default: valid is a one-clock-cycle pulse.
                valid_reg <= '0';

                case state is

                    when IDLE =>
                        trigger_reg <= '0';
                        timer_counter <= 0;
                        echo_counter <= 0;

                        if period_counter >= PERIOD_COUNT - 1 then
                            period_counter <= 0;
                            trigger_reg <= '1';
                            timer_counter <= 0;
                            state <= TRIG_HIGH;
                        else
                            period_counter <= period_counter + 1;
                        end if;

                    when TRIG_HIGH =>
                        if timer_counter >= TRIG_COUNT - 1 then
                            trigger_reg <= '0';
                            timer_counter <= 0;
                            echo_counter <= 0;
                            state <= WAIT_ECHO;
                        else
                            timer_counter <= timer_counter + 1;
                        end if;

                    when WAIT_ECHO =>
                        if echo_sync2 = '1' then
                            timer_counter <= 0;
                            echo_counter <= 0;
                            state <= MEASURE;
                        elsif timer_counter >= TIMEOUT_COUNT - 1 then
                            -- No Echo pulse received: discard this reading.
                            trigger_reg <= '0';
                            period_counter <= 0;
                            timer_counter <= 0;
                            state <= IDLE;
                        else
                            timer_counter <= timer_counter + 1;
                        end if;

                    when MEASURE =>
                        if echo_sync2 = '0' then
                            -- Echo pulse ended; convert its duration to cm.
                            if TICKS_PER_CM > 0 then
                                measured_cm := echo_counter / TICKS_PER_CM;

                                if measured_cm > 65535 then
                                    distance_reg <= (others => '1');
                                else
                                    distance_reg <=
                                        to_unsigned(measured_cm, 16);
                                end if;

                                valid_reg <= '1';
                            end if;

                            period_counter <= 0;
                            timer_counter <= 0;
                            state <= IDLE;

                        elsif echo_counter >= TIMEOUT_COUNT - 1 then
                            -- Echo remained high too long: discard reading.
                            period_counter <= 0;
                            timer_counter <= 0;
                            echo_counter <= 0;
                            state <= IDLE;

                        else
                            echo_counter <= echo_counter + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
