transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages/memory_stage.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/pipelined_processor.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/Mux2x1.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/PC.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/PC_Adder.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages/fetch_stage.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/EqReg.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/RegisterFile.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/ControlUnit.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages/decode_stage.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/sign_extension.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages/execution_stage.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/ALU_Control.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/ALU.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/Mux4x1.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/stages/writeback_stage.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/DataMemoryAsync.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/hazard {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/hazard/forwarding_unit.v}
vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/datapath/Instruction_Memory_asy.v}

vlog -vlog01compat -work work +incdir+D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/tb {D:/Users/Atassi/Desktop/RISC-V-Processor/Pipeline/src/tb/benchmark_testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  benchmark_testbench

add wave *
view structure
view signals
run -all
