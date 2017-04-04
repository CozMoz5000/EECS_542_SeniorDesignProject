# Import the required libraries for the GUI
from tkinter import *
from tkinter import ttk
import ok
from tkinter import messagebox

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

#Initalize a Opal Kelly Object
print("Creating an Opal Kelly Object")
dev = ok.okCFrontPanel()
print("Creating a PLL Object")
pll = ok.okCPLL22150()

# Declare a string to hold the status of the device
deviceStatus = "Idle"

# Function to connect to the device
def deviceConnect():
    # Check to see if there is at least 1 device to connect to
    if dev.GetDeviceCount() > 0:
        # At least 1 device, attempt to connect to device 0
        EC = dev.OpenBySerial("")
        # See if we were sucessful
        if EC == 0:
            # No Error
            # Get info about the device
            devInfo = dev.GetDeviceInfo() 
            
            # Update the status String
            deviceStatus = "Connected to device with a Serial Number of {}".format(devInfo.serialNumber)
        else:
            # Error Occured, show a dialog box
            messagebox.showerror('Device Error', 'Unable to connect to device!\nDevice returned an error code of: {}, This means:{}'.format(EC, Error_Code_Dict[EC]))
    else:
        # No devices connected show an error
        messagebox.showerror('Device Error', 'Unable to connect to device as there are no connected devices')

# Function to handle disconnecting the device
def deviceDisconnect():
    # Close the device we are connected to
    # If we are not connected to a device this does nothing
    dev.Close()

# Main function to create the GUI
def main():
    # Create the root/main window
    root = Tk()

    # Set the title of the window
    root.title("EECS 542 - Logic Analyzer")

    # Create the menu at the top of the window
    menubar = Menu(root, tearoff=0)

    # Create a pulldown menu for the device
    filemenu = Menu(menubar, tearoff=0)
    filemenu.add_command(label="Connect to Device", command=deviceConnect)
    filemenu.add_command(label="Disconnect", command=deviceDisconnect)
    filemenu.add_separator()
    filemenu.add_command(label="Exit", command=root.quit)
    menubar.add_cascade(label="Device", menu=filemenu)

    # Configure the root to use our menubar
    root.config(menu=menubar)

    # Create a status bar for the bottom of the window


    # Set the size of the root window
    root.geometry('500x100')

    # Run the main loop of the root
    root.mainloop() 

#Set the code to run our main function when it is called
if __name__== "__main__":
    main()