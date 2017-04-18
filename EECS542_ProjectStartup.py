#Declare a dictionary for the OK Error Codes
Error_Code_Dict = {0:"No Error",
                   -1:"Failed",
                   -2:"Timeout",
                   -3:"Done but not High",
                   -4:"Transfer Error",
                   -5:"Communication Error",
                   -6:"Invalid BitStream",
                   -7:"File Error",
                   -8:"Device Not Open",
                   -9:"Invalid Endpoint",
                   -10:"Invalid Block Size",
                   -11:"I2C Restricted Address",
                   -12:"I2C Bit Error",
                   -13:"I2C Nack Recieved",
                   -14:"I2C Unknown Status",
                   -15:"Unsupported Feature",
                   -16:"FIFO Underflow",
                   -17:"FIFO Overflow",
                   -18:"Data Allignment Error",
                   -19:"Invalid Reset Profile",
                   -20:"Invalid Parameter"}

                   
#
# Variable Declarations
#
Bitfile_Location = r'D:\Documents\GitHub\EECS_542_SeniorDesignProject\Vivado_Projects\Senior_Design_For_OK\Senior_Design_For_OK.runs\impl_1\OK_BoardWrapper.bit'

#Import Opal Kelly Libraries
import ok
import time
from bitstring import BitArray

#Print out the status messages
print("EECS 542 FPGA Startup File")
print("Created by: Austin Cosner")
print("----------------------------")
print("")

#Initalize a Opal Kelly Object
print("Creating an Opal Kelly Object")
dev = ok.okCFrontPanel()
print("Creating a PLL Object")
pll = ok.okCPLL22150()

#Display all of the avaliable devices
numOfDevices = dev.GetDeviceCount()
print("Connected Devices: " + str(numOfDevices))
for x in range(numOfDevices):
    print("Device " + str(x) + ": " + str(dev.GetDeviceListModel(x)) + " : " + str(dev.GetDeviceListSerial(x)))
print()

#Connect to the first devices
print("Openning the first device...")
EC = dev.OpenBySerial("")
print("Device opened with Error Code: " + Error_Code_Dict[EC])
print()

#Program the device
print("Attempting to program device with Bitfile located at: " + Bitfile_Location)
EC = dev.ConfigureFPGA(Bitfile_Location) 
print("Device programmed with Error Code: " + Error_Code_Dict[EC])
print()

#Wait before we start sampiling
print("Ready to start sampiling, press any key to begin!")
x = input()

#Trigger the sampiling to start
EC = dev.ActivateTriggerIn(int("55",16), 0) 
print("Start Sampiling Trigger completed with error code: " + Error_Code_Dict[EC])
print()

#Loop until sampiling is done
readyToGo = 0;
while (readyToGo == 0):
    #Wait for 1 sec
    time.sleep(1)
    
    #Check the trigger
    dev.UpdateTriggerOuts();
    readyToGo = dev.IsTriggered(0x6A, 0x1)
    print("Trigger value: " + str(readyToGo))

#Get the ammount of data in the FIFO
EC = dev.UpdateWireOuts();
print("Updating the wire outs with Error Code: " + Error_Code_Dict[EC])
a = dev.GetWireOutValue(int("25",16));
print("The FIFO currently contains " + str(a) + " entries!")
print()

#Read the data from the FIFO through a pipe
buf = bytearray(a*2)
EC = dev.ReadFromPipeOut(0xA5, buf)
if(EC < 0):
    print("Pipe Out Read completed with Error Code: " + Error_Code_Dict[EC])
    print()
    
#Print out the data for easy reading

#Create a bit array for each channel
channel1_Bits = BitArray()
channel2_Bits = BitArray()
channel3_Bits = BitArray()
channel4_Bits = BitArray()
channel4_Bits_Offset = 0

for i in range(EC):
    #Get the byte
    b1 = buf[i]
    
    print("Byte at index " + str(i) + " has a value of " + hex(b1))
    
    #Get the low nibble
    lowN = b1 & 0xF
    
    #print("Lower Nibble")
    
    #Get the Channel Samples
    c1_Samp = lowN & 0x1
    #print("C1 Sample: " + str(c1_Samp) + " = " + str(hex(c1_Samp)))
    c2_Samp = (lowN & 0x02) >> 1
    #print("C2 Sample: " + str(c2_Samp))
    c3_Samp = (lowN & 0x04) >> 2
    #print("C3 Sample: " + str(c3_Samp))
    c4_Samp = (lowN & 0x08) >> 3
    #print("C4 Sample: " + str(c4_Samp))
    
    #Append them to their arrays
    #channel1_Bits.append(uint=c1_Samp, length=1)
    #channel2_Bits.append(uint=c2_Samp, length=1)
    #channel3_Bits.append(uint=c3_Samp, length=1)
    #channel4_Bits.append(uint=c4_Samp, length=1)
    
    #Get the high Nibble
    highN = b1 >> 4
    
    #print("Higher Nibble")
    
    #Get the Channel Samples
    c1_Samp = highN & 0x01
    #print("C1 Sample: " + str(c1_Samp))
    c2_Samp = (highN & 0x02) >> 1
    #print("C2 Sample: " + str(c2_Samp))
    c3_Samp = (highN & 0x04) >> 2
    #print("C3 Sample: " + str(c3_Samp))
    c4_Samp = (highN & 0x08) >> 3
    #print("C4 Sample: " + str(c4_Samp))
    
    #Append them to their arrays
    #channel1_Bits.append(uint=c1_Samp, length=1)
    #channel2_Bits.append(uint=c2_Samp, length=1)
    #channel3_Bits.append(uint=c3_Samp, length=1)
    #channel4_Bits.append(uint=c4_Samp, length=1)
        
#Print out all of the bit strings
print()
print("Channel Sampled Values")
print("1: " + channel1_Bits.bin)
print("2: " + channel2_Bits.bin)
print("3: " + channel3_Bits.bin)
print("4: " + channel4_Bits.bin)