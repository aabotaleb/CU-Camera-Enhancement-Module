vsim -gui work.afmodule(afmodule_arch)
add wave  \
sim:/afmodule/Clk \
sim:/afmodule/Reset \
sim:/afmodule/Start_FromCPU \
sim:/afmodule/FocusAdress_FromCPU \
sim:/afmodule/DONE_ToCPU \
sim:/afmodule/DMA_ACK_FromDMA \
sim:/afmodule/DMA_EN_ToDMA \
sim:/afmodule/FocusAdress_ToDMA \
sim:/afmodule/Cache_Data_FromCache \
sim:/afmodule/Cache_Address_ToCache \
sim:/afmodule/Cache_RD_EN_ToCache \
sim:/afmodule/MOV_LEN_ToMechPart \
sim:/afmodule/DIR_ToMechPart \
sim:/afmodule/AFCU_Time \
sim:/afmodule/FSM1_EN_SIG \
sim:/afmodule/FSM2_EN_SIG \
sim:/afmodule/FSM3_EN_SIG \
sim:/afmodule/FSM2_FIN_SIG \
sim:/afmodule/FSM3_FIN_SIG \
sim:/afmodule/FSM2_CHDIR_SIG \
sim:/afmodule/AFSC_INC_SIG \
sim:/afmodule/AFSC_CLR_SIG \
sim:/afmodule/AFAR_INC_SIG \
sim:/afmodule/AFAR_LD_SIG \
sim:/afmodule/CacheAR_INC_SIG \
sim:/afmodule/CacheAR_CLR_SIG \
sim:/afmodule/RAE_SIG \
sim:/afmodule/RBE_SIG \
sim:/afmodule/WE_SIG \
sim:/afmodule/OE_SIG \
sim:/afmodule/IE_SIG \
sim:/afmodule/RAA_SIG \
sim:/afmodule/RBA_SIG \
sim:/afmodule/WA_SIG \
sim:/afmodule/ALU_OP_SIG \
sim:/afmodule/DP_OUT_SIG \
sim:/afmodule/X_SIG \
sim:/afmodule/Y_SIG \
sim:/afmodule/CF_SIG \
sim:/afmodule/Cache_Data_Extended \
sim:/afmodule/Registers

force -freeze sim:/afmodule/Clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/afmodule/Reset 1 0
force -freeze sim:/afmodule/Start_FromCPU 0 0
force -freeze sim:/afmodule/FocusAdress_FromCPU 12'h000 0
run 200
force -freeze sim:/afmodule/Reset 0 0
force -freeze sim:/afmodule/Start_FromCPU 1 0
force -freeze sim:/afmodule/FocusAdress_FromCPU 12'h245 0
run 300

