# System clock: 50 MHz
set_property PACKAGE_PIN N18 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 20.000 -name sys_clk [get_ports {clk}]

# Reset
set_property PACKAGE_PIN P14 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

# Ultrasonic sensor
set_property PACKAGE_PIN F16 [get_ports {trigger}]
set_property IOSTANDARD LVCMOS33 [get_ports {trigger}]

set_property PACKAGE_PIN E17 [get_ports {echo}]
set_property IOSTANDARD LVCMOS33 [get_ports {echo}]

# Onboard LED
set_property PACKAGE_PIN R14 [get_ports {led}]
set_property IOSTANDARD LVCMOS33 [get_ports {led}]

# L298N rear motor driver — JP2 GPIO

# PWM speed control — JP2 pin 7
set_property PACKAGE_PIN E18 [get_ports {motor_pwm_out}]
set_property IOSTANDARD LVCMOS33 [get_ports {motor_pwm_out}]

# Motor direction — JP2 pin 9
set_property PACKAGE_PIN G17 [get_ports {motor_in1}]
set_property IOSTANDARD LVCMOS33 [get_ports {motor_in1}]

# Motor direction — JP2 pin 10
set_property PACKAGE_PIN G18 [get_ports {motor_in2}]
set_property IOSTANDARD LVCMOS33 [get_ports {motor_in2}]
