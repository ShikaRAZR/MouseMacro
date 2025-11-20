#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global guiWindowX := 0
global guiWindowY := 0
global macroCompilerArray := []

refresh:
Gui,+LastFound
WinGetPos,xWindow,yWindow
if (xWindow != "" or yWindow != ""){
	guiWindowX = %xWindow%
	guiWindowY = %yWindow%
}
Gui, 1:Destroy


;Global Variable
isRecording := 0
global saveMacroDirectory := A_ScriptDir . "\IndividualMacros\"
global xTempCoordArray := []
global yTempCoordArray := []
global tTempCoordArray := []
global windowTempArray := []
global gui_Id := ""
FileList := ""
macroList := ""
CheckFolderExistence()

;GUI_____________________________________________________________________________
;GUI Variable
xMacroOptions := 20
yMacroOptions := 20
xMacroListOptions := 20
yMacroListOptions := 270

; General Layout
GUI, 1:-AlwaysOnTop ; + makes it always stay up, - will make it go behind other windows
Gui, 1:Color, 222222
Gui, 1:Color,,222222
Gui, 1:Show, x%guiWindowX% y%guiWindowY% w420 h600, Mouse Macro

; Options Layout


	; Macro Layout
Gui, 1:Font, s14 cDDDDDD
Gui, 1:Add, Text, x%xMacroOptions% y%yMacroOptions%, Options
Gui, 1:Font, s8 cDDDDDD
Gui, 1:Add, Button, x+40 grefresh, Refresh Window
Gui, 1:Add, Button, x%xMacroOptions% y+20 grunMacro, Run Macro
Gui, 1:Add, Button, x+40 geditMacro, Edit Macro
Gui, 1:Add, Button, x+40 grecord, Record
Gui, 1:Add, Button, x+40 gstopRecording, End Recording
SetTimer, MouseRecordingNotification, 1
Loop, %saveMacroDirectory%\*.txt
{
	FileList = %FileList%|%A_LoopFileName%|
}
Gui, 1:Add, ListBox,  x%xMacroOptions% y+20 w380 h150 vMacroList, %FileList%
	; Macro Compiler Layout
Gui, 1:Font, s14 cDDDDDD
Gui, 1:Add, Text, x%xMacroListOptions% y%yMacroListOptions%, Macro Compiler
Gui, 1:Font, s8 cDDDDDD
Gui, 1:Add, Text, y+20, Repeat Amount:
Gui, 1:Add, Edit, x+20 vMacroListRepeat Number limit1
Gui, 1:Add, Updown, vrepeatAmount Range1-10, 1
Gui, 1:Add, Button, x%xMacroListOptions% y+20 gaddMacro, Add Macro
Gui, 1:Add, Button, x+40 gresetMacroList, Reset Macro List
Gui, 1:Add, Button, x+40 grunMacroList, Run Macro List
for macroCompilerIndex, macroCompilerElement in macroCompilerArray
{
	macroList = %macroList%|%macroCompilerElement%|
}
Gui, 1:Add, ListBox,  x%xMacroOptions% y+20 w380 h150 ReadOnly vMacroCompilerList, %macroList%
return




;Labels_________________________________________________________________________
runMacro: ; Should Minimize GUI
	if(isRecording = 1){
		Msgbox, Can't Run Macro When Recording
	}else{
		Gui, +OwnDialogs
		Gui, Submit,NoHide
		runningMacroPath := saveMacroDirectory . MacroList
		runningMacro := new MacroObject(runningMacroPath)
		runningMacro.runMacro()
		MsgBox, Macro Success
	}
	return

editMacro:
	; used to obtain MacroList variable (selected macro to edit)
	Gui, Submit,NoHide
	runningMacroPath := saveMacroDirectory . MacroList
	tempLocationDataArray := []

	Loop, read, %runningMacroPath%
	tempLocationDataArray.Push(A_LoopReadLine)

	currentCoord := tempLocationDataArray.RemoveAt(1)
	currentTime := tempLocationDataArray.RemoveAt(1)
	currentRunChance := tempLocationDataArray.RemoveAt(1)
	currentRepeatAmount := tempLocationDataArray.RemoveAt(1)

	Gui, 2:Show, w430 h500, Settings
	Gui, 2:Color, 222222
	Gui, 1:+Disabled
	Gui, 2:Font, s14 cDDDDDD
	Gui, 2:Add, Text, x%xMacroOptions% y%yMacroOptions%, Settings
	Gui, 2:Font, s10 cDDDDDD
	Gui, 2:Add, Text, y+20, Random Coordinate Dispostion (Pixel Displacement Range:0-20)
	Gui, 2:Font, s10 c000000
	Gui, 2:Add, Edit, y+20 w50 limit2 Number veditCoord, %currentCoord%
	Gui, 2:Font, s10 cDDDDDD
	Gui, 2:Add, Text, y+20, Random Time Delay Onclick (Millisecond Range:0-10000)
	Gui, 2:Font, s10 c000000
	Gui, 2:Add, Edit, y+20 w50 limit5 Number veditTime, %currentTime%
	Gui, 2:Font, s10 cDDDDDD
	Gui, 2:Add, Text, y+20, Random Run Chance (Percent Range:1-100)
	Gui, 2:Font, s10 c000000
	Gui, 2:Add, Edit, y+20 w50 limit3 Number veditRunChance, %currentRunChance%
	Gui, 2:Font, s10 cDDDDDD
	Gui, 2:Add, Text, y+20, Repeat Amount (Repeat Range:1-10)
	Gui, 2:Font, s10 c000000
	Gui, 2:Add, Edit, y+20 w50 limit2 Number veditRepeatAmount, %currentRepeatAmount%
	Gui, 2:Add, Button, y+30 gsubmitMacroEdit, Submit
	return

submitMacroEdit:
	; used to obtain varibles to edit macro attributes
	Gui, Submit,NoHide
	; Msgbox, %MacroList%
	; Msgbox, 1: %editCoord% 2: %editTime% 3: %editRunChance% 4: %editRepeatAmount%
	runningMacroPath := saveMacroDirectory . MacroList
	runningMacro := new MacroObject(runningMacroPath)
	runningMacro.editAttributes(runningMacroPath, editCoord, editTime, editRunChance, editRepeatAmount)
	Gui, 1:-Disabled
	Gui, 2:Destroy
	return

2GuiClose:
	Gui, 1:-Disabled
	Gui, 2:Destroy
	return

record:
	isRecording=1
	MouseGetPos,,,MacroWindowID
	gui_Id = %MacroWindowID%
	xTempCoordArray := []
	yTempCoordArray := []
	tTempCoordArray := []
	windowTempArray := []
	return


stopRecording:
	isRecording=0
	OutputRecordedFile()
	Goto, refresh


MouseRecordingNotification:
	if(isRecording=1)
	{
		MouseGetPos, px, py
		ToolTip, Recording..., px+10, py+10
	}else{
		ToolTip
	}
	return

; Sends Mouse Coordinates and time into a variable
~LButton::
Keywait,LButton
MouseGetPos,XPos,YPos,Window
time:=A_TimeSincePriorHotkey
If (isRecording=1 and gui_Id != Window)
{
	xTempCoordArray.Push(XPos)
	yTempCoordArray.Push(YPos)
	tTempCoordArray.Push(time)
	windowTempArray.Push(Window)
	; Msgbox, %XPos%, %YPos%, %time%, %Window%
}
return

addMacro:
	Gui, Submit,NoHide
	if(MacroList = ""){
		Msgbox, Invalid Macro Choice
		return
	}
	macroCompilerArray.Push(MacroList)
	maxIndexTest:=macroCompilerArray.MaxIndex()
	Goto, refresh

resetMacroList:
	macroCompilerArray := []
	Goto, refresh

runMacroList:
	Gui, Submit,NoHide
	if(isRecording = 1){
		Msgbox, Can't Run Macro When Recording
	}else{
		macroListRepeatCounter := MacroListRepeat
		while(macroListRepeatCounter>=1)
		{
			for macroCompilerIndex, macroCompilerElement in macroCompilerArray
			{
						runningMacroPath := saveMacroDirectory . macroCompilerElement
						runningMacro := new MacroObject(runningMacroPath)
						runningMacro.runMacro()
			}
			macroListRepeatCounter -= 1
		}
		MsgBox, Macro List Success
	}
	return















;Methods________________________________________________________________________
CheckFolderExistence() ; Checks if macro save directory is created
{
	if (!FileExist(saveMacroDirectory))
	{
		Msgbox, Create this directory before using:`n%saveMacroDirectory%
		return 0
	}
	return 1
}
OutputRecordedFile() ; outputs recorded clicks onto a text file in the macro save directory
{
	if (xTempCoordArray.MaxIndex()=0){
		Msgbox, No actions were recorded. (Or actions were with this program)
	}
	else{
		InputBox, Name, Input Name of Recorded Macro
		if (Name = ""){
			Msgbox, Invalid Name, Macro Not Saved
		}
		else
		{
			filePath:= saveMacroDirectory . name . ".txt"
			MsgBox, Path: %filePath%
			if FileExist(filePath)
			{
				FileDelete, %filePath%
			}
			FileAppend, 0`n0`n100`n1`n, %filePath% ; Default Input For Coordinate Dispostion (0), Time Delay Onclick (0), Random Run Chance (100), Repeat Amount (1)
			tTempCoordArray.RemoveAt(1)
			xTemp := xTempCoordArray.RemoveAt(1)
			yTemp := yTempCoordArray.RemoveAt(1)
			tTemp := 0
			winTemp := windowTempArray.RemoveAt(1)
			FileAppend, %xTemp%`n%yTemp%`n%tTemp%`n%winTemp%`n, %filePath%
			while xTempCoordArray.MaxIndex()>0
			{
				xTemp := xTempCoordArray.RemoveAt(1)
				yTemp := yTempCoordArray.RemoveAt(1)
				tTemp :=tTempCoordArray.RemoveAt(1)
				winTemp := windowTempArray.RemoveAt(1)
				FileAppend, %xTemp%`n%yTemp%`n%tTemp%`n%winTemp%`n, %filePath%
			}
		}
		xTempCoordArray := []
		yTempCoordArray := []
		tTempCoordArray := []
		windowTempArray := []
	}
}

Class MacroObject{
 ; C:\Users\matth\Downloads\AutoHotKeyStuff\GFLMacroKordRefill.txt
 ; Instantiate Arrays
	locationDataArray := [] ; Array used to save every line of text file as an array index to organize and set the attributes
	randomCoordDisposition := 0
	randomTimeDelay := 0
	runChance := 100
	repeatAmount:= 1
	xCoordArray := []
	yCoordArray := []
	tCoordArray := []
	windowArray := []


	__New(macroFilePath)
	{
		this.macroFilePath := macroFilePath
		Loop, read, %macroFilePath%
		this.locationDataArray.Push(A_LoopReadLine)


		this.randomCoordDisposition := this.locationDataArray.RemoveAt(1)
		this.randomTimeDelay := this.locationDataArray.RemoveAt(1)
		this.runChance := this.locationDataArray.RemoveAt(1)
		this.repeatAmount:= this.locationDataArray.RemoveAt(1)

		while this.locationDataArray.MaxIndex()>0
		{
			this.xCoordArray.Push(this.locationDataArray.RemoveAt(1))
			this.yCoordArray.Push(this.locationDataArray.RemoveAt(1))
			this.tCoordArray.Push(this.locationDataArray.RemoveAt(1))
			this.windowArray.Push(this.locationDataArray.RemoveAt(1))
		}
	}
	runMacro()
	{
		repeatCounter := this.repeatAmount
		while(repeatCounter>=1)
		{
				Random, runChanceCounter, 0,100
				if(runChanceCounter<(this.runChance+1)){
						this.runMacroOnce()
						sleep, 2000
				}
				repeatCounter -= 1
		}
	}
	runMacroOnce() ; runs recorded macro with random poistioning and timing offsets
	{
		if(this.xCoordArray.MaxIndex()=this.yCoordArray.MaxIndex() and this.yCoordArray.MaxIndex()=this.tCoordArray.MaxIndex()){
			for index, element in this.xCoordArray ; Runs Coordinates in File
			{
				Random, randCoordDisposition, (this.randomCoordDisposition*-1),this.randomCoordDisposition
				Random, randTimeDisposition, 0,this.randomTimeDelay
				x := this.xCoordArray[index]+randCoordDisposition
				y := this.yCoordArray[index]+randCoordDisposition
				sleeptime := this.tCoordArray[index] + randTimeDisposition

				sleep, %sleeptime%
				window_id := this.windowArray[index]
				WinActivate, ahk_id %window_id%
				KeyWait Control
				KeyWait Alt
				BlockInput On
				MouseClick, left, %x%, %y%
				BlockInput Off
			}
		}else{
			MsgBox, Macro Failed, Press Tab
		}
		return
	}
	editAttributes(filePath, coordDispositionInput, timeDelayInput, runChanceInput, repeatAmountInput){
		; Msgbox, %filePath%
		saveMacroDirectory := A_ScriptDir . "\IndividualMacros\"
		; Msgbox, %saveMacroDirectory%
		if (!FileExist(filePath) or saveMacroDirectory = filePath)
		{
			Msgbox, This file doesnt exist: %filepath%
			return
		}
		if(coordDispositionInput<0 or coordDispositionInput>20 or timeDelayInput<0 or timeDelayInput>10000 or runChanceInput<1 or runChanceInput>100 or repeatAmountInput<1 or repeatAmountInput>10){
			Msgbox, Invalid Inputs
			return
		}
		newLocationDataArray := []
		Loop, read, %filePath%
		newLocationDataArray.Push(A_LoopReadLine)
		FileDelete, %filePath%

		newLocationDataArray.RemoveAt(1)
		newLocationDataArray.RemoveAt(1)
		newLocationDataArray.RemoveAt(1)
		newLocationDataArray.RemoveAt(1)
		FileAppend, %coordDispositionInput%`n%timeDelayInput%`n%runChanceInput%`n%repeatAmountInput%`n, %filePath%
		while newLocationDataArray.MaxIndex()>0
		{
			line := newLocationDataArray.RemoveAt(1)
			FileAppend, %line%`n, %filePath%
			; Msgbox, %line%
		}
		return
	}
}




GuiClose:
ExitApp

; In case of a critical error in macro execution press Esc to end program
Esc::
MsgBox, Macro is Exiting...
ExitApp
