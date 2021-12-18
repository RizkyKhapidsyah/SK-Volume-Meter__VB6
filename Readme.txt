                     ---------------------------------------
                              Microsoft Visual Basic
                     Audio Level Sample Project Readme File
                                    April 1998
			   ---------------------------------------

Audiolbl.exe is a self-extracting compressed file with a Visual Basic project that displays the input and output volume levels from a sound card. The project uses several Windows API functions.

MORE INFORMATION
================

When you run the self-extracting compressed file, the following files are expanded into the Audio Level Sample Project directory of your system:

 - Form1.frm    (6K)-the main form of the project.
 - Module1.bas (53K)-the module file with the function declarations.
 - Project1.vbp (1K)-the project file
 - Project1.vbw (1K)-the project workspace file
 - Readme.txt-you are currently reading this file.

To run the project, you will need a system with a sound card and a microphone. Open the project in Visual Basic and click Start from the Run menu. Click get input and speak into the microphone. The audio level from the microphone is displayed in a input level progress bar. Play a .WAV file and the audio level is displayed in the output level progress bar.

How The Sample Works
--------------------

The sample demonstrates how to display the audio level of an input or output device. The level is stored in a member of a user-defined type variable. The sample uses several API functions to manipulate several user-defined type variables in order to extract the audio level.

When you first run the project, the mixerOpen function is used to get a handle to the mixer device. The handle is used with the mixerGetLineInfo function to get the capabilities of the mixer device. The capabilities are stored in the MIXERLINE and the MIXERLINECONTROLS user-defined variables. Some of the members of these variables are pointers that you need to manipulate in order to control the mixer. To manipulate this pointers, you need to copy the variables into a buffer using the GlobalAlloc function. After manipulating the variable members, you copy the contents of the buffer back to the variable using the RtlMemory function.

The Timer control is used to query these user-defined variables to get the audio level. This level is displayed in the appropriate progress bar.

When you click get input, a user-defined function opens the wave input device using the waveInOpen function. The waveInOpen function requires the WAVEFORMAT user-defined type to configure the recording settings such as the number of channels, the number of sampling bits, and the sampling rate. The wave input device requires a buffer to process the input data. You create this buffer with the waveInPrepareHeader function. The buffer is then sent to the wave input device with the waveInAddBuffer function.

With the buffer created, you can start input on the wave device using the waveInStart function. 

The output level is displayed in a similar fashion.

REFERENCES
==========

For more information about the functions used in this sample project, please see the following topics in the Platform SDK product documentation:

- Memory Management functions
   GlobalAlloc
   GlobalLock
   GlobalFree
   RtlMoveMemory

- Mixer device functions
   mixerClose
   mixerGetControlDetails
   mixerGetDevCaps
   mixerGetID
   mixerGetLineControls
   mixerGetLineInfo
   mixerGetNumDevs
   mixerMessage
   mixerOpen
   mixerSetControlDetails

- Wave Input device functions
   waveInOpen
   waveInPrepareHeader
   waveInReset
   waveInStart
   waveInStop
   waveInUnprepareHeader
   waveInClose
   waveInGetDevCaps
   waveInGetNumDevs
   waveInGetErrorText
   waveInAddBuffer

For more information about the user-defined types used in this sample, please see the following topics in the Platform SDL product documentation:

- Mixer device user-defined types
   MIXERCAPS
   MIXERCONTROL
   MIXERCONTROLDETAILS
   MIXERCONTROLDETAILS_SIGNED
   MIXERLINE
   MIXERLINECONTROLS

- Wave device user-defined types
   WAVEHDR
   WAVEINCAPS
   WAVEFORMAT
