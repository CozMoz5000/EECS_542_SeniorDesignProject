2. SIMULATION
=============
The following samples have associated simulation versions:

   + First (Verilog and VHDL)
   + DES   (Verilog)

Simulation versions are setup very similar to an actual FPGA-targeted 
project, but might differ in a specific detail or two.  In particular:

   + Simulation projects have the additional "*_tf.v" file which 
     contains the test fixture and attaches the FPGA pinout to the 
     host simulation.  The host simulation represents everything from the
     FPGA host interface pins back to the PC application code.
     
   + Simulation projects have the additional "okHostCalls.v" file which 
     contains Verilog or HDL models for the functions in the FrontPanel API.
   
   + Simulation projects include a Modelsim "do file" for executing the 
     simulation compiler and performing the test bench setup.

4. BUILDING SAMPLES BITFILES USING XILINX VIVADO
=============================================
This will briefly guide you through the setup of a Xilinx
Vivado project and help you build this sample on your own.
The same process can be extended to any of the included samples as well
as your own projects.

This file is written for the Counters project, but with appropriate changes,
it will extend easily to the others.

If you are new to Vivado, you should review the Xilinx 
documentation on that software.  At least some familiarity with Vivado is
assumed here.


Step 1: Create a new Project
----------------------------
Within Project Navigator, create a new project.  This will also create
a new directory to contain the project.  You will be copying files into
this new location.

When prompted to select the project type, select "RTL project". Check 
the box "Do not specify sources at this time".

Be sure to select the correct FPGA device for your particular board:
   XEM7350-K70T      => xc7k70tfbg676-1
   XEM7350-K160T     => xc7k160tffg676-1
   XEM7350-K410T     => xc7k410tffg676-1
   XEM7001-A15T      => xc7a15tftg256-1


Step 2: Copy source files to Project
------------------------------------
Copy the Verilog file from the sample directory to your new Project directory.
For the Counters (XEM7350-Verilog) sample, this is:
   + Counters.v     - Counters Verilog source.
Copy the XDC constraints file from the Samples directory. For the XEM7350,
this is:
   + xem7350.xdc    - Constraints file for the XEM7350 board.


Step 3: Copy Opal Kelly FrontPanel HDL files
--------------------------------------------
From the FrontPanel installation directory, copy the HDL module files.
Be sure to use the files from the correct board model as some of the 
items are board-specific.  The README.txt file indicates which version
of Xilinx ISE was used to produce the NGC files.  Note that these files
are forward-compatible with newer ISE versions.
   + okLibrary.v    - Verilog library file
   + *.ngc          - Pre-compiled FrontPanel HDL modules (XEM7350)
   + *.v            - Encrypted FrontPanel HDL modules (XEM7001)
   
   
Step 4: Add sources to your Project
-----------------------------------
Within Project Navigator, select "Add Sources.."->"Add or Create Constraints" 
from the "File" menu. Add the XDC file to your project.
Select "Add Sources"->"Add or Create Design Sources".
Add the following files to your project: (Note that you have already copied
these files to your project directory in the previous steps.  They are now
being added to your Project.)
   + Counters.v
   + okLibrary.v

   XEM7001:
   + okBTPipeIn.v
   + okBTPipeOut.v
   + okCoreHarness.v
   + okPipeIn.v
   + okPIpeOut.v
   + okTriggerIn.v
   + okTriggerOut.v
   + okWireIn.v
   + okWireOut.v

   XEM7350:
   + *.ngc
Select "TFIFO64x8a_64x8b.ngc" in the Sources panel.
Select "Tools"->"Property Editor" and check the "IS_GLOBAL_INCLUDE" box.
   
   
Step 5: Generate Programming File
---------------------------------
Within Flow Navigator, click on "Generate Bitfile" to have Vivado build a
programming file that you can then download to your board using FrontPanel.
The default location of this file for Counters is:
counters.runs/impl_1/Counters.bit