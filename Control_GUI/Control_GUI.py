#General Imports
import time, sys
from bitstring import BitArray, Bits

#Matplotlib Imports
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from matplotlib.figure import Figure

#Tkinter Imports
from tkinter import *
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

#OK Imports
import ok

#OK Global Variables
dev = ok.okCFrontPanel()
connectedToDevice = False
Bitfile_Location = r'D:\Documents\GitHub\EECS_542_SeniorDesignProject\Working_Bitfiles\OK_BoardWrapper_VariableSamples.bit'

#
#Tkinter Global Variables
#
samplingRateLabel = None
numOfSamplesLabel = None

#Create the object to represent the status bar at the bottom of the window
statusBarObj = None

#Create another string variable for the number of samples choices
numberOfSamplesVar = None
samplingChoices = ['160 Samples', '1000 Samples', '2000 Samples', '3000 Samples', '4000 Samples']

#Create a string var and a list of the sampiling frequency options
samplingFreqChoices = None
choices = ['50 MHz', '25 MHz', '10 MHz', '5 MHz', '1 MHz', '500 kHz']

#Create a dictionary to convert the sampling frequency into an integer
samplingFreqDict = {'50 MHz': 1, '25 MHz': 2, '10 MHz': 3, '5 MHz': 4, '1 MHz': 5, '500 KHz':6}

#Create a dictionary to convert the number of samples into an integer
numberOfSamplesDict = {'160 Samples':0, '1000 Samples':1, '2000 Samples':2, '3000 Samples':3, '4000 Samples':4}
numberOfSamplesDict1 = {'160 Samples':160, '1000 Samples':1000, '2000 Samples':2000, '3000 Samples':3000, '4000 Samples':4000}

#
#Tkinter Constants
#
LARGE_FONT= ("Verdana", 12)
MEDIUM_FONT=("Verdana", 10)

datax1 = [0,1,2,3,4,5,6,7,8]
datay1 = [0,1,0,1,0,1,0,1,0]

datax2 = [0,1,2,3,4,5,6,7,8]
datay2 = [0,1,1,0,0,1,1,0,0]

datax3 = [0,1,2,3,4,5,6,7,8]
datay3 = [0,1,1,0,0,0,0,1,1]

datax4 = [0,1,2,3,4,5,6,7,8]
datay4 = [0,1,1,1,1,0,0,0,0]

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
                   
#Main Method
def main():
    #Create an nstance of the GUI class
    LA_GUI = Logic_Analyzer()
    
    #Run the GUI's mainloop (Create the window, etc.)
    LA_GUI.mainloop()
    
#Class to display a status bar at the bottom of the GUI
class StatusBar(Frame):
    def __init__(self, master):
        #Initalize the frame we have been passed
        Frame.__init__(self, master)
        #Create the label widget we are using
        self.label = Label(self, bd=1, relief=SUNKEN, anchor=W)
        #Add the label to the frame
        self.label.pack(fill=X)

    #Method to set the text in the status bar
    def set(self, format, *args):
        #Configure the label text
        self.label.config(text=format % args)
        #Force the GUi to complete all outstanding draw update operations
        self.label.update_idletasks()

    def clear(self):
        #Set the label's text to nothing
        self.label.config(text="")
        #Force the GUi to complete all outstanding draw update operations
        self.label.update_idletasks()

def data_transform_y(list2,channel):
        y = len(list2)
        yaxis = list2
        yaxisnew = []

        for number in range(0,y-1):
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
            yaxisnew.append(yaxis[number])
        print("transforming y")
        if channel == 1:
            global datay1
            datay1 = yaxisnew
        if channel == 2:
            global datay2
            datay2 = yaxisnew
        if channel == 3:
            global datay3
            datay3 = yaxisnew
        if channel == 4:
            global datay4
            datay4 = yaxisnew       
        
def data_transform_x(list1,channel):
        x = len(list1)
        xaxis = list1
        xaxisnew = []

        for number in range(0,x-1):
            xaxisnew.append(xaxis[number])
            xaxisnew.append(xaxis[number]+0.1)
            xaxisnew.append(xaxis[number]+0.2)
            xaxisnew.append(xaxis[number]+0.3)
            xaxisnew.append(xaxis[number]+0.4)
            xaxisnew.append(xaxis[number]+0.5)
            xaxisnew.append(xaxis[number]+0.6)
            xaxisnew.append(xaxis[number]+0.7)
            xaxisnew.append(xaxis[number]+0.8)
            xaxisnew.append(xaxis[number]+0.9)
        print("transforming x")
        if channel == 1:
            global datax1
            datax1 = xaxisnew
        if channel == 2:
            global datax2
            datax2 = xaxisnew
        if channel == 3:
            global datax3
            datax3 = xaxisnew
        if channel == 4:
            global datax4
            datax4 = xaxisnew
            
#Get the global variables for the sampling frequency and number of samples and display them
def print_var_status():
    #Print out the status of the global variables
    print("Sampling Freq: "+str(numberOfSamplesVar.get()) + ", Sample Count: " + str(samplingFreqChoices.get()))
    
class Logic_Analyzer(tk.Tk):
    def __init__(self, *args, **kwargs):      
        tk.Tk.__init__(self, *args, **kwargs)
        tk.Tk.wm_title(self, "Logic Analyzer")
        
        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand = True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        #Create the global string Vars
        global numberOfSamplesVar
        numberOfSamplesVar = StringVar()
        numberOfSamplesVar.set('160 Samples') #Set the default option
        
        global samplingFreqChoices
        samplingFreqChoices = StringVar()
        samplingFreqChoices.set('50 MHz') #Set the default option
        
        self.frames = {}
        
        for F in (StartPage, PageOne, transferSettingsPage, graphDisplayPage):
            frame = F(container, self)
            self.frames[F] = frame
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame(StartPage)
        
        #Create a status bar object in the root frame
        global statusBarObj
        statusBarObj = StatusBar(self)
        #Set the initial status text
        statusBarObj.set("%s", "Not connected to OK device")
        #Add the status bar to the bottom of the root frame
        statusBarObj.pack(side=BOTTOM, fill=X)

    def show_frame(self, cont):
        frame = self.frames[cont]
        frame.tkraise()


#Create a function to chcek if we should enter the setup menu
def checkForOKDevice(controller, frame):
    global connectedToDevice
    #Check to see if there is at least 1 device connected
    if((dev.GetDeviceCount() > 0) or connectedToDevice):
        if(not connectedToDevice):
            #Get the SN of device 0
            devSerial = dev.GetDeviceListSerial(0)
            
            #Connect to the first device
            EC = dev.OpenBySerial("")
            print("Device opened with Error Code: " + Error_Code_Dict[EC])
            
            #Check the EC to see if we can continue
            if(EC >= 0):
                #We can continue, attempt to program the device
                print("Attempting to program device with Bitfile located at: " + Bitfile_Location)
                EC = dev.ConfigureFPGA(Bitfile_Location) 
                print("Device programmed with Error Code: " + Error_Code_Dict[EC])
                
                #Check EC to see if we can continue
                if(EC >= 0):
                    #Setup sucessful
                    
                    #Set the flag
                    global connectedToDevice
                    connectedToDevice = True
                    
                    #Update the status bar
                    global statusBarObj
                    statusBarObj.set("%s", "Connected to OK device with SN: " + devSerial)
                    
                    #Update our global variables
                    global samplingRateLabel
                    global numOfSamplesLabel
                    samplingRateLabel.config(text = "Sampling Frequency: " + str(samplingFreqChoices.get()))
                    samplingRateLabel.update_idletasks()
                    numOfSamplesLabel.config(text = "Number Of Samples: " + str(numberOfSamplesVar.get()))
                    numOfSamplesLabel.update_idletasks()
                    
                    #We can continue, show the frame we were passed
                    controller.show_frame(frame)
                else:
                    #Errored out, show an error window
                    messagebox.showerror("Error", "Error programming device, error was: " + Error_Code_Dict[EC])
            else:
                #Errored out, show an error window
                messagebox.showerror("Error", "Error Connecting to the device, error was: " + Error_Code_Dict[EC])
        else:
            #Already connected, so just show frame
            controller.show_frame(frame)
    else:
        #We should not continue, print a debug message
        print("Device Count was less than or equal to 0, code was: " + str(dev.GetDeviceCount()))
        
        #Show an error box to the user to explain error
        messagebox.showerror("Error", "Please connect an OK device")
    
    
class StartPage(tk.Frame):
    def __init__(self, parent, controller):
        tk.Frame.__init__(self,parent)
        label = tk.Label(self, text="Main Page", font=LARGE_FONT)
        label.pack(pady=10,padx=10)

        print("Initalizing the Setup Button")
        button = ttk.Button(self, text="Setup",
                            command=lambda: checkForOKDevice(controller, PageOne))
        button.pack()
        print("Setup Button initalized")
        
        button2 = ttk.Button(self, text="Sampling Configuation",
                            command=lambda: checkForOKDevice(controller, transferSettingsPage))
        button2.pack()

        button3 = ttk.Button(self, text="Graph Results",
                            command=lambda: checkForOKDevice(controller, graphDisplayPage))
        button3.pack()
        button4 = ttk.Button(self, text="Variable Check",
                            command=print_var_status)
        button4.pack()


class PageOne(tk.Frame):
    def print_status(self,sampling_num, sampling_freq):
        print(sampling_num)
        print("Sampling Frequency set to "+ str(sampling_freq))
        
    def __init__(self, parent, controller):
        #Initalize the frame
        tk.Frame.__init__(self, parent)
        
        #Create the label at the top of the frame
        label = tk.Label(self, text="Setup", font=LARGE_FONT)
        label.pack(pady=10,padx=10)
        
        #Create the heading for the Frequency selection
        freq_title = tk.Label(self, text="Sampling Frequency", font=MEDIUM_FONT)
        freq_title.pack(anchor = W)
        
        #Create the Combo box to select the sampiling frequency
        popupMenu = OptionMenu(self, samplingFreqChoices, *choices)
        
        #Add the options menu to the frame
        popupMenu.pack(anchor = W)

        #Create the heading for the number of samples selection
        samp_title = tk.Label(self, text="Number of Samples", font=MEDIUM_FONT)
        samp_title.pack(anchor = W)
        
        #Create another options menu and add it to the window
        samplingChoicesBox = OptionMenu(self, numberOfSamplesVar, *samplingChoices)
        samplingChoicesBox.pack(anchor = W)
        
        #Create the button to go back to the home frame
        button1 = ttk.Button(self, text="Back to Home", command=lambda: controller.show_frame(StartPage))
        button1.pack(side = BOTTOM)

#Method to send settings to the device
def transferSettings():
    #Debug Print
    print("INFO: Sending settings to device")
    print("Sampling Frequency: " + samplingFreqChoices.get() + " :: Number of Samples: " + numberOfSamplesVar.get())
    
    #Get values for the current settings
    clockCode = samplingFreqDict[samplingFreqChoices.get()]
    numCode = numberOfSamplesDict[numberOfSamplesVar.get()]
    
    #Set WireIns for the clock values
    EC = dev.SetWireInValue(0x05, clockCode << 1, 0x0E)
    print("First Wire In set completed with Error Code: " + Error_Code_Dict[EC])
    
    #Set WireIns for the number of samples values
    EC = dev.SetWireInValue(0x05, numCode << 4, 0x70)
    print("Second Wire In set completed with Error Code: " + Error_Code_Dict[EC])
    
    #Set wireins for the reset
    EC = dev.SetWireInValue(0x05, 0x01, 0x01)
    print("Third Wire In set completed with Error Code: " + Error_Code_Dict[EC])
    
    #Update the Wire Ins
    EC = dev.UpdateWireIns()
    print("1: Updating the Wire Ins completed with Error Code: " + Error_Code_Dict[EC])
    
    #Wait for 1 second
    time.sleep(1)
    
    #Change the Wire In's to not have reset asserted
    #Use 0x01 as the mask so only bit 0 gets changed, use 0x00 as the value so it gets set to 0
    EC = dev.SetWireInValue(0x05, 0x00, 0x01)
    print("Fourth Wire In set completed with Error Code: " + Error_Code_Dict[EC])
    
    #Update the WireIns
    EC = dev.UpdateWireIns()
    print("2: Updating the Wire Ins completed with Error Code: " + Error_Code_Dict[EC])
    
    #Debug Print
    print("Device Settings Updated")
    
    #Show a completed message
    messagebox.showinfo("Settings Transfer", "Device sucesfully configured with settings")

#Method to sample the signals and fill the internal data with the values
def executeSampiling():    
    #Trigger the sampiling to start
    EC = dev.ActivateTriggerIn(int("55",16), 0) 
    print("Start Sampiling Trigger completed with error code: " + Error_Code_Dict[EC])

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

    #Read the data from the FIFO through a pipe
    buf = bytearray(a*2)
    EC = dev.ReadFromPipeOut(0xA5, buf)
    if(EC < 0):
        print("Pipe Out Read completed with Error Code: " + Error_Code_Dict[EC])
        print()
    
    #Create a bit array for each channel
    channel1_Bits = BitArray()
    channel2_Bits = BitArray()
    channel3_Bits = BitArray()
    channel4_Bits = BitArray()
    
    #Loop through every byte that we recieved
    for i in range(EC):
        #Get the byte
        b1 = buf[i]
        
        #print("Byte at index " + str(i) + " has a value of " + hex(b1))
        
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
        channel1_Bits.append(Bits(uint=c1_Samp, length=1))
        channel2_Bits.append(Bits(uint=c2_Samp, length=1))
        channel3_Bits.append(Bits(uint=c3_Samp, length=1))
        channel4_Bits.append(Bits(uint=c4_Samp, length=1))
        
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
        channel1_Bits.append(Bits(uint=c1_Samp, length=1))
        channel2_Bits.append(Bits(uint=c2_Samp, length=1))
        channel3_Bits.append(Bits(uint=c3_Samp, length=1))
        channel4_Bits.append(Bits(uint=c4_Samp, length=1))
            
    #Create a range from 0 to the final sample
    xPositions = range(numberOfSamplesDict1[numberOfSamplesVar.get()])
    
    #Set the x arrays to the range
    global datax1
    datax1 = []
    global datax2
    datax2 = []
    global datax3
    datax3 = []
    global datax4
    datax4 = []
    datax1 = xPositions
    datax2 = xPositions
    datax3 = xPositions
    datax4 = xPositions
    
    #Set the y data to the Bit Arrays values
    global datay1
    datay1 = []
    global datay2
    datay2 = []
    global datay3
    datay3 = []
    global datay4
    datay4 = []
    
    print("Length of bit string: " + str(channel1_Bits.len))
    for x in range(channel1_Bits.len):
        #Get the bits at the index
        datay1.append(int(channel1_Bits[x]))
        datay2.append(int(channel2_Bits[x]))
        datay3.append(int(channel3_Bits[x]))
        datay4.append(int(channel4_Bits[x]))
    
    #Alert that sampling was finsihed
    print("Length of x1: " + str(len(datax1)) + ", Length of y1: " + str(len(datay1)))
    messagebox.showinfo("Sampling Status", "Sampling completed sucessfully, see Graph page for visualization")

    
#Page to send settings to the device and stat sampiling
class transferSettingsPage(tk.Frame):
    def __init__(self, parent, controller):
        #Initalze the frame
        tk.Frame.__init__(self, parent)
        
        #Create the header label for the page
        label = tk.Label(self, text="Send/Receive", font=LARGE_FONT)
        label.pack(pady=10,padx=10)
        
        #Create some labels to display the current settings
        global samplingRateLabel
        global numOfSamplesLabel
        samplingRateLabel = tk.Label(self, text = "Sampling Frequency: " + str(samplingFreqChoices.get()), font = MEDIUM_FONT)
        numOfSamplesLabel = tk.Label(self, text = "Number Of Samples: " + str(numberOfSamplesVar.get()), font = MEDIUM_FONT)
        
        #Pack the labels
        samplingRateLabel.pack()
        numOfSamplesLabel.pack()
        
        #Create a button to send the settings to the device
        sendSettingsButton = ttk.Button(self, text = "Send Settings To Device", command = transferSettings)
        sendSettingsButton.pack()
        
        #Create a button to start sampiling
        startSamplingButton = ttk.Button(self, text = "Start Sampling", command = executeSampiling)
        startSamplingButton.pack()
        
        #Create a button to take us back to the home screen
        button1 = ttk.Button(self, text="Back to Home",
                            command=lambda: controller.show_frame(StartPage))
        button1.pack(side = BOTTOM)
        
        
#Page to display the graphs
class graphDisplayPage(tk.Frame):
    def display_graph(self):
        data_transform_x(datax1,1)
        data_transform_y(datay1,1)

        data_transform_x(datax2,2)
        data_transform_y(datay2,2)

        data_transform_x(datax3,3)
        data_transform_y(datay3,3)

        data_transform_x(datax4,4)
        data_transform_y(datay4,4)
        
        f = Figure(figsize=(5,5), dpi=100)
        a = f.add_subplot(411)
        a.plot(datax1,datay1)
        b = f.add_subplot(412)
        b.plot(datax2,datay2)
        c = f.add_subplot(413)
        c.plot(datax3,datay3)
        d = f.add_subplot(414)
        d.plot(datax4,datay4)
        
        
        canvas = FigureCanvasTkAgg(f, self)
        canvas.show()
        canvas.get_tk_widget().pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)

        toolbar = NavigationToolbar2TkAgg(canvas, self)
        toolbar.update()
        canvas._tkcanvas.pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        print ("Sampling Frequency set to "+ str(samplingFreqChoices.get())+ ", Code: "+ str(samplingFreqDict[samplingFreqChoices.get()]))
        
    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Graph", font=LARGE_FONT)
        label.pack(pady=10,padx=10)

        button1 = ttk.Button(self, text="Back to Home", command = lambda: controller.show_frame(StartPage))
        button1.pack()
        button2 = ttk.Button(self, text="Show Graph", command = lambda: self.display_graph())
        button2.pack()

#Main Insertion point for the script
if __name__ == "__main__":
    #Execute the main method
    main()
