set_global_assignment -entity "clock_24" -library "lib_clock_24" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_24" -library "lib_clock_24" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "clock_24" -library "lib_clock_24" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_24" -name SPD_FILE [file join $::quartus(sip_path) "clock_24.spd"]

set_global_assignment -library "lib_clock_24" -name MISC_FILE [file join $::quartus(sip_path) "clock_24_sim/clock_24.vo"]
