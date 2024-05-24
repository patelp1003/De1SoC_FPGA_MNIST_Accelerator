set_global_assignment -entity "clock_25" -library "lib_clock_25" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_25" -library "lib_clock_25" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_25" -library "lib_clock_25" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_25" -name SPD_FILE [file join $::quartus(sip_path) "clock_25.spd"]

set_global_assignment -library "lib_clock_25" -name MISC_FILE [file join $::quartus(sip_path) "clock_25_sim/clock_25.vo"]
