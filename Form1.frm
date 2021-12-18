VERSION 5.00
Object = "{6B7E6392-850A-101B-AFC0-4210102A8DA7}#1.3#0"; "COMCTL32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Volume Meter"
   ClientHeight    =   1770
   ClientLeft      =   -15
   ClientTop       =   270
   ClientWidth     =   4695
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1770
   ScaleWidth      =   4695
   StartUpPosition =   3  'Windows Default
   Begin ComctlLib.ProgressBar ProgressBar2 
      Height          =   255
      Left            =   1200
      TabIndex        =   4
      Top             =   1320
      Width           =   3375
      _ExtentX        =   5953
      _ExtentY        =   450
      _Version        =   327682
      Appearance      =   1
   End
   Begin ComctlLib.ProgressBar ProgressBar1 
      Height          =   255
      Left            =   1200
      TabIndex        =   3
      Top             =   240
      Width           =   3375
      _ExtentX        =   5953
      _ExtentY        =   450
      _Version        =   327682
      Appearance      =   1
   End
   Begin VB.CheckBox Check1 
      Caption         =   "get input"
      Height          =   375
      Left            =   1200
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   600
      Width           =   975
   End
   Begin VB.Timer Timer1 
      Interval        =   50
      Left            =   4200
      Top             =   600
   End
   Begin VB.Label Label2 
      Caption         =   "output level"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   1320
      Width           =   855
   End
   Begin VB.Label Label1 
      Caption         =   "input level"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   855
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim hmixer As Long                  ' mixer handle
Dim inputVolCtrl As MIXERCONTROL    ' waveout volume control
Dim outputVolCtrl As MIXERCONTROL   ' microphone volume control
Dim rc As Long                      ' return code
Dim ok As Boolean                   ' boolean return code

Dim mxcd As MIXERCONTROLDETAILS         ' control info
Dim vol As MIXERCONTROLDETAILS_SIGNED   ' control's signed value
Dim volume As Long                      ' volume value
Dim volHmem As Long                     ' handle to volume memory

Private Sub Form_Load()
   ' Open the mixer specified by DEVICEID
   rc = mixerOpen(hmixer, DEVICEID, 0, 0, 0)
   
   If ((MMSYSERR_NOERROR <> rc)) Then
       MsgBox "Couldn't open the mixer."
       Exit Sub
   End If
       
   ' Get the input volume meter
   ok = GetControl(hmixer, MIXERLINE_COMPONENTTYPE_DST_WAVEIN, MIXERCONTROL_CONTROLTYPE_PEAKMETER, inputVolCtrl)
   
   If (ok <> True) Then
       ok = GetControl(hmixer, MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE, MIXERCONTROL_CONTROLTYPE_PEAKMETER, inputVolCtrl)
   End If
   
   If (ok = True) Then
      ProgressBar1.Min = 0
      ProgressBar1.Max = inputVolCtrl.lMaximum
   Else
      ProgressBar1.Enabled = False
      MsgBox "Couldn't get wavein meter"
   End If
       
   ' Get the output volume meter
   ok = GetControl(hmixer, MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT, MIXERCONTROL_CONTROLTYPE_PEAKMETER, outputVolCtrl)
   
   If (ok = True) Then
      ProgressBar2.Min = 0
      ProgressBar2.Max = outputVolCtrl.lMaximum
   Else
      ProgressBar2.Enabled = False
      MsgBox "Couldn't get waveout meter"
   End If
   
   ' Initialize mixercontrol structure
   mxcd.cbStruct = Len(mxcd)
   volHmem = GlobalAlloc(&H0, Len(volume))  ' Allocate a buffer for the volume value
   mxcd.paDetails = GlobalLock(volHmem)
   mxcd.cbDetails = Len(volume)
   mxcd.cChannels = 1

End Sub

Private Sub Check1_Click()
   If (Check1.Value = 1) Then
      StartInput  ' Start receiving audio input
   Else
      StopInput   ' Stop receiving audio input
   End If
End Sub

Private Sub Timer1_Timer()

   On Error Resume Next

   ' Process sound buffer if recording
   If (fRecording) Then
      For i = 0 To (NUM_BUFFERS - 1)
         If inHdr(i).dwFlags And WHDR_DONE Then
            rc = waveInAddBuffer(hWaveIn, inHdr(i), Len(inHdr(i)))
         End If
      Next
   End If

   ' Get the current input level
   If (ProgressBar1.Enabled = True) Then
      mxcd.dwControlID = inputVolCtrl.dwControlID
      mxcd.item = inputVolCtrl.cMultipleItems
      rc = mixerGetControlDetails(hmixer, mxcd, MIXER_GETCONTROLDETAILSF_VALUE)
      CopyStructFromPtr volume, mxcd.paDetails, Len(volume)
      If (volume < 0) Then
         volume = -volume
         End If
      ProgressBar1.Value = volume
   End If

   ' Get the current output level
   If (ProgressBar2.Enabled = True) Then
      mxcd.dwControlID = outputVolCtrl.dwControlID
      mxcd.item = outputVolCtrl.cMultipleItems
      rc = mixerGetControlDetails(hmixer, mxcd, MIXER_GETCONTROLDETAILSF_VALUE)
      CopyStructFromPtr volume, mxcd.paDetails, Len(volume)
      
      If (volume < 0) Then volume = -volume
   
      ProgressBar2.Value = volume
   End If

End Sub

Private Sub Form_Unload(Cancel As Integer)
   If (fRecording = True) Then
       StopInput
   End If
   GlobalFree volHmem
End Sub


