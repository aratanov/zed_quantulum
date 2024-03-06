# Add custom pgts repo
set quantulum_ip_repo_path [file normalize [file join [file dirname [info script]] "./hdl-quantulum"]]
set ip_repo_list [get_property IP_REPO_PATHS [current_fileset]]
if {[lsearch $ip_repo_list $quantulum_ip_repo_path] == -1} {
	lappend ip_repo_list $quantulum_ip_repo_path
	set_property IP_REPO_PATHS $ip_repo_list [current_fileset]
	update_ip_catalog
	puts "Added IP Repo: $quantulum_ip_repo_path"
}

source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
##source ../common/fmcomms2_bd.tcl
source ./fmcomms2_bd_qts.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23

ad_ip_parameter axi_ad9361 CONFIG.TDD_DISABLE 1

