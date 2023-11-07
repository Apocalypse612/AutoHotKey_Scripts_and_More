﻿#Requires AutoHotKey v1.0
 
#Persistent
#SingleInstance Force
DetectHiddenWindows, On
SelfID := WinExist(A_ScriptFullPath " ahk_class AutoHotkey")
Menu, Tray, NoStandard ; Disable standard menu
WinGet, AList, List, ahk_class AutoHotkey ; Get a list of all AutoHotkey scripts

; Create a variable to track the number of .ahk scripts running
NumAHKScripts := 0

Loop %AList%
{
    ID := AList%A_Index%
    IfEqual, ID, %SelfID%, Continue ; If the ahk script is this script, don't proceed
    WinGetTitle, ATitle, ahk_id %ID%
    ATitle1 := SubStr(ATitle, 1, InStr(ATitle, "-", 0, 0, 1) - 1)
    SplitPath, ATitle1, Name
    ; Check if the script should be ignored based on its location
    FilePath := "C:\Program Files\AutoHotkey\UX\" . Name
    if (FileExist(FilePath))
        Continue
    Menu,%Name%,Add, %A_Index%:Reload , MenuChoice
    Menu,%Name%,Add, %A_Index%:Edit   , MenuChoice
    Menu,%Name%,Add, %A_Index%:Pause  , MenuChoice
    Menu,%Name%,Add, %A_Index%:Suspend, MenuChoice
    Menu,%Name%,Add, %A_Index%:Exit   , MenuChoice
    ; Check if the script name contains ".ahk"
    if (InStr(Name, ".ahk"))
        NumAHKScripts++
    Menu, Tray, Add, %Name%,  :%Name%
}

Menu, Tray, Add ; Insert a blank line in menus for a break
Menu, Tray, Add, Quick Reload, Reload
Menu, Tray, Add, Close All AHK Scripts, CloseAllAHKScripts ; Add a new menu item
Menu, Tray, Add, Run WindowSpy, RunWindowSpy ; Add the "Run WindowSpy" menu item
Menu, Tray, Default, Quick Reload ; Set it so "Reload" is the default if clicking
Menu, Tray, Click, 1 ; Single click to reload

; Function to check if a new .ahk script was launched
CheckNewAHKScript:
WinGet, NewAList, List, ahk_class AutoHotkey
NewNumAHKScripts := 0

Loop %NewAList%
{
    ID := NewAList%A_Index%
    IfEqual, ID, %SelfID%, Continue
    WinGetTitle, ATitle, ahk_id %ID%
    ATitle1 := SubStr(ATitle, 1, InStr(ATitle, "-", 0, 0, 1) - 1)
    SplitPath, ATitle1, Name
    ; Check if the script should be ignored based on its location
    FilePath := "C:\Program Files\AutoHotkey\UX\" . Name
    if (FileExist(FilePath))
        Continue
    if (InStr(Name, ".ahk"))
        NewNumAHKScripts++
}

; Check if the number of .ahk scripts has increased
if (NewNumAHKScripts > NumAHKScripts)
    Reload

; Update the number of .ahk scripts
NumAHKScripts := NewNumAHKScripts

; Set a timer to check for new .ahk scripts every second
SetTimer, CheckNewAHKScript, 1000

Return

MenuChoice:
F := StrSplit(A_ThisMenuItem, ":")
ControlHWND := "AList" F[1]
if (F.2 = "Reload")
    PostMessage, 0x111, 65400, 0, , % "ahk_id " %ControlHWND%
if (F.2 = "Edit")
    PostMessage, 0x111, 65401, 0, , % "ahk_id " %ControlHWND%
if (F.2 = "Pause")
    PostMessage, 0x111, 65403, 0, , % "ahk_id " %ControlHWND%
if (F.2 = "Suspend")
    PostMessage, 0x111, 65404, 0, , % "ahk_id " %ControlHWND%
if (F.2 = "Exit")
    PostMessage, 0x111, 65405, 0, , % "ahk_id " %ControlHWND%
Reload
Return

CloseAllAHKScripts:
; Close all .ahk scripts except the master script
Loop %AList%
{
    ID := AList%A_Index%
    if (ID = SelfID)
        Continue
    WinGetTitle, ATitle, ahk_id %ID%
    ATitle1 := SubStr(ATitle, 1, InStr(ATitle, "-", 0, 0, 1) - 1)
    SplitPath, ATitle1, Name
    ; Check if the script should be ignored based on its location
    FilePath := "C:\Program Files\AutoHotkey\UX\" . Name
    if (FileExist(FilePath))
        Continue
    if (InStr(Name, ".ahk"))
    {
        PostMessage, 0x111, 65405, 0,,% "ahk_id " ID ; Send a close message
    }
}

; Force the master script to reload
Reload
Return

Reload:
Reload
Return

RunWindowSpy:
; Add your code to run WindowSpy here
Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk" ; Modify this line to match the actual path to WindowSpy
Return

esc::exitapp
