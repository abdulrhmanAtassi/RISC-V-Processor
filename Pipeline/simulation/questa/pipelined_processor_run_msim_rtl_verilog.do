transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/pipelined_processor.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/InstructionMemory.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/Mux2x1.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/PC.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/PC_Adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/stages {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/stages/fetch_stage.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/EqReg.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/RegisterFile.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/ControlUnit.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/stages {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/stages/decode_stage.v}
vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/datapath/sign_extension.v}

vlog -vlog01compat -work work +incdir+C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/tb {C:/Users/sarah/Desktop/ArchProject/RISC-V-Processor/Pipeline/src/tb/decode_stage_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  decode_stage_tb

add wave *
view structure
view signals
run -all
