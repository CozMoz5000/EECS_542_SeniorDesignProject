@echo off
set xv_path=D:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 0264c5f5b9c849b4aca419beac6433d7 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot test_tb_behav xil_defaultlib.test_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
