@echo off
set xv_path=D:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xsim test_tb_behav -key {Behavioral:sim_1:Functional:test_tb} -tclbatch test_tb.tcl -view D:/Documents/Git_Projects/EECS_542_SeniorDesignProject/Vivado_Projects/Senior_Design_For_OK/Senior_Design_For_OK.sim/LA_and_CU_TB.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
