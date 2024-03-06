proc build_dts {args} {
	set my_dts [lindex $args 0]
    set board zedboard
    set version 2021.2
    set xsa ../system_top.xsa
    set repo /home/user/git/device-tree-xlnx_v2021.2
    if {$my_dts == 0} {
        set my_dts .
    }
    set fsbl_dir ./fsbl
    ## next two files are similar to those in   meta-adi/meta-adi-xilinx/recipes-bsp/device-tree/files/
    set pl_delete ./my_inc/pl-delete-nodes-zynq-zed-adv7511-ad9361-fmcomms2-3.dtsi
    set pl_overlay ./my_inc/pl-zynqmp-zcu104-revc-ad9361-fmcomms2-3.dtsi
    set st_bootargs ./my_inc/bootargs-zed.dtsi
    ###
    hsi::open_hw_design $xsa
    hsi::set_repo_path $repo
    hsi::create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
    hsi::generate_target -dir $my_dts
    ###
    hsi::create_sw_design -proc ps7_cortexa9_0  -os standalone fsbl
    hsi::add_library xilffs
    hsi::add_library xilrsa
    hsi::generate_app -proc ps7_cortexa9_0  -app zynq_fsbl -dir $fsbl_dir -compile
    ###
    hsi::close_hw_design [hsi::current_hw_design]
    if {$board != 0} {
        foreach lib [glob -nocomplain -directory $repo/device_tree/data/kernel_dtsi/${version}/include/dt-bindings -type d *] {
            if {![file exists $my_dts/include/dt-bindings/[file tail $lib]]} {
                file copy -force $lib $my_dts/include/dt-bindings
            }
        }
        set dtsi_files [glob -nocomplain -directory $repo/device_tree/data/kernel_dtsi/${version}/BOARD -type f *${board}*]
        if {[llength $dtsi_files] != 0} {
            file copy -force [lindex $dtsi_files end] $my_dts
            set fileId [open $my_dts/system-user.dtsi "w"]
            puts $fileId "/include/ \"[file tail [lindex $dtsi_files end]]\""
            puts $fileId "/ {"
            puts $fileId "};"
            close $fileId
            set fileId [open $my_dts/system-top.dts "a"]
            puts $fileId "#include \"[file tail [lindex $dtsi_files end]]\""
            puts $fileId "#include \"$st_bootargs\""
            close $fileId
            set fileId [open $my_dts/pl.dtsi "a"]
            #puts $fileId "#include \"$pl_delete\""
            #puts $fileId "#include \"$pl_overlay\""
            close $fileId
        } else {
            puts "Info: Board file: $board is not found and will not be added to the system-top.dts"
        }
    }
}
