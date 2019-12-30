; <COMPILER: v1.1.28.02>
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Ignore
#NoTrayIcon
if(!InStr(A_OSVersion, "10.0.")) {
MsgBox, 16, Error, This application is compatible with Windows 10 only
ExitApp
}
if(!A_IsAdmin) {
MsgBox, 16, Error, This application needs to be run as administrator
ExitApp
}
if(A_Is64bitOS) {
system32 = %A_WinDir%\sysnative
} else {
system32 = %A_WinDir%\system32
}
gosub, RefreshLicenseInformation
InProcess = 0
Gui, Font, S9, Segoe UI
Gui, Font, bold
Gui, Add, Text, x8 y8 w284, Edition
Gui, Font, norm
Gui, Add, Text, vEditionInfo x8 y26 w284, %ProductFamily%
Gui, Font, bold
Gui, Add, Text, x8 y50 w284, License status
Gui, Font, norm
Gui, Add, Text, vStatusCodeInfo x8 y68 w284, %ProductStatusMsg%
Gui, Font, bold
Gui, Add, Text, x8 y92 w284, Partial product key
Gui, Font, norm
Gui, Add, Text, vPartialKeyInfo x8 y110 w284, %ProductPartialKey%
Gui, Add, Text, vStatusInfo x8 y134 w284, Ready
Gui, Add, Progress, x8 y154 w284 h16 -smooth vStatusProgress, 0
Gui, Add, Button, x8 y178 w138 h24 vStartActBtn gStartAct Default, Start process
Gui, Add, Button, x154 y178 w138 h24 vExitBtn gGuiClose, Exit
if(UnsupportedSku) {
GuiControl, , StatusInfo, Not supported
GuiControl, Disable , StartActBtn
GuiControl, +Default, ExitBtn
}
Gui, -MinimizeBox
Gui, Show, h208 w300, HWIDWizard
return
StartAct:
InProcess = 1
Gui, +Disabled
GuiControl, , StatusInfo, Preparing...
gosub, RefreshGUILicenseInformation
if(UnsupportedSku) {
GuiControl, , StatusInfo, Not supported
GuiControl, Disable , StartActBtn
GuiControl, +Default, ExitBtn
MsgBox, 16, Error, Unsupported edition
Gui, -Disabled
InProcess = 0
return
}
FileAppend, Starting activation at %A_DD% %A_MMM% %A_YYYY% %A_Hour%:%A_Min%:%A_Sec%...`n`n, HWID.log
GuiControl, , StatusProgress, 0
GuiControl, , StatusInfo, Installing key...
FileAppend, Installing key %NewKey%...`n, HWID.log
try RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ipk %NewKey% >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
gosub, RefreshGUILicenseInformation
GuiControl, , StatusProgress, 15
GuiControl, , StatusInfo, Adding registry entries...
FileAppend, Adding registry entries...`n, HWID.log
RegWrite, REG_SZ, HKLM\SYSTEM\Tokens, Channel, Retail
RegWrite, REG_DWORD, HKLM\SYSTEM\Tokens\Kernel, Kernel-ProductInfo, %NewSku%
RegWrite, REG_DWORD, HKLM\SYSTEM\Tokens\Kernel, Security-SPP-GenuineLocalStatus, 1
GuiControl, , StatusProgress, 20
GuiControl, , StatusInfo, Running GatherOsState...
FileAppend, Running GatherOsState...`n, HWID.log
Random, rand
dir = %A_Temp%\GatherOsState%rand%
FileCreateDir, %dir%
FileInstall, GatherOsState.exe, %dir%\GatherOsState.exe, 1
FileInstall, slshim32.dll, %dir%\slc.dll, 1
try RunWait, %dir%\GatherOsState.exe, %dir%, Hide
catch {
gosub, ProcessFail
return
}
GuiControl, , StatusProgress, 60
GuiControl, , StatusInfo, Removing registry entries...
FileAppend, Removing registry entries...`n`n, HWID.log
RegDelete, HKLM\SYSTEM\Tokens
GuiControl, , StatusProgress, 65
GuiControl, , StatusInfo, Applying GenuineTicket.xml...
FileAppend, Applying GenuineTicket.xml...`n, HWID.log
try RunWait, %system32%\cmd.exe /c "clipup -v -o -altto `"%dir%`" >>HWID.log", , Hide
catch {
gosub, ProcessFail
return
}
FileRemoveDir, %dir%, 1
FileAppend, `n, HWID.log
GuiControl, , StatusProgress, 75
GuiControl, , StatusInfo, Activating...
FileAppend, Activating...`n, HWID.log
RunWait, %system32%\cmd.exe /c "cscript.exe /nologo %A_WinDir%\system32\slmgr.vbs -ato >>HWID.log", , Hide
gosub, RefreshGUILicenseInformation
GuiControl, , StatusProgress, 100
GuiControl, , StatusInfo, Done
if(ProductStatusCode = 1) {
FileAppend, Successfully activated %ProductFamily%!`n, HWID.log
MsgBox, 64, Success, Successfully activated %ProductFamily%!
} else {
MsgBox, 16, Error, Failed to activate %ProductFamily%.`n`nPlease check HWID.log file for details.
FileAppend, Failed to activate %ProductFamily%. License status: %ProductStatusMsg%`n, HWID.log
}
FileAppend, `n`n, HWID.log
Gui, -Disabled
InProcess = 0
return
RefreshLicenseInformation:
WMI := ComObjGet("winmgmts:")
Query := WMI.ExecQuery("Select * FROM SoftwareLicensingProduct WHERE PartialProductKey IS NOT NULL")._NewEnum()
while(Query[Info]) {
ProductFamily := Info.LicenseFamily
if(!ProductFamily)
continue
ProductDescription := Info.Description
ProductStatusCode := Info.LicenseStatus
ProductPartialKey := Info.PartialProductKey
ProductLicenseID := Info.ID
}
gosub, ConvertStatus
gosub, DetermineKeyAndSkuID
WMI := ""
Query := ""
Info := ""
return
ConvertStatus:
if(ProductStatusCode = 0) {
ProductStatusMsg = Unlicensed
} else if(ProductStatusCode = 1) {
ProductStatusMsg = Licensed
} else if(ProductStatusCode = 2) {
ProductStatusMsg = Initial grace period
} else if(ProductStatusCode = 3) {
ProductStatusMsg = Additional grace period
} else if(ProductStatusCode = 4) {
ProductStatusMsg = Non-genuine grace period
} else if(ProductStatusCode = 5) {
ProductStatusMsg = Notification
} else {
ProductStatusMsg = Unknown status: %ProductStatusCode%
}
return
DetermineKeyAndSkuID:
if(ProductFamily = "Cloud") {
NewKey=V3WVW-N2PV2-CGWC3-34QGF-VMJ2C
NewSku=178
} else if(ProductFamily = "CloudN") {
NewKey=NH9J3-68WK7-6FB93-4K3DF-DJ4F6
NewSku=179
} else if(ProductFamily = "Core") {
NewKey=YTMG3-N6DKC-DKB77-7M9GH-8HVX7
NewSku=101
} else if(ProductFamily = "CoreCountrySpecific") {
NewKey=N2434-X9D7W-8PF6X-8DV9T-8TYMD
NewSku=99
} else if(ProductFamily = "CoreN") {
NewKey=4CPRK-NM3K3-X6XXQ-RXX86-WXCHW
NewSku=98
} else if(ProductFamily = "CoreSingleLanguage") {
NewKey=BT79Q-G7N6G-PGBYW-4YWX6-6F4BT
NewSku=100
} else if(ProductFamily = "Education") {
NewKey=YNMGQ-8RYV3-4PGQ3-C8XTP-7CFBY
NewSku=121
} else if(ProductFamily = "EducationN") {
NewKey=84NGF-MHBT6-FXBX8-QWJK7-DRR8H
NewSku=122
} else if(ProductFamily = "Enterprise") {
NewKey=XGVPP-NMH47-7TTHJ-W3FW7-8HV2C
NewSku=4
} else if(ProductFamily = "EnterpriseN") {
NewKey=3V6Q6-NQXCX-V8YXR-9QCYV-QPFCT
NewSku=27
} else if(ProductFamily = "EnterpriseS") {
if(A_OSVersion = "10.0.14393") {
NewKey=NK96Y-D9CD8-W44CQ-R8YTK-DYJWX
NewSku=125
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "EnterpriseSN") {
if(A_OSVersion = "10.0.14393") {
NewKey=2DBW3-N2PJG-MVHW3-G7TDK-9HKR4
NewSku=126
} else {
UnsupportedSku=1
}
} else if(ProductFamily = "Professional") {
NewKey=VK7JG-NPHTM-C97JM-9MPGT-3V66T
NewSku=48
} else if(ProductFamily = "ProfessionalEducation") {
NewKey=8PTT6-RNW4C-6V7J2-C2D3X-MHBPB
NewSku=164
} else if(ProductFamily = "ProfessionalEducationN") {
NewKey=GJTYN-HDMQY-FRR76-HVGC7-QPF8P
NewSku=165
} else if(ProductFamily = "ProfessionalN") {
NewKey=2B87N-8KFHP-DKV6R-Y2C8J-PKCKT
NewSku=49
} else if(ProductFamily = "ProfessionalWorkstation") {
NewKey=DXG7C-N36C4-C4HTG-X4T3X-2YV77
NewSku=161
} else if(ProductFamily = "ProfessionalWorkstationN") {
NewKey=WYPNQ-8C467-V2W6J-TX4WX-WT2RQ
NewSku=162
} else {
UnsupportedSku=1
}
return
RefreshGUILicenseInformation:
gosub, RefreshLicenseInformation
GuiControl, , EditionInfo, %ProductFamily%
GuiControl, , StatusCodeInfo, %ProductStatusMsg%
GuiControl, , PartialKeyInfo, %ProductPartialKey%
return
ProcessFail:
MsgBox, 16, Error, Process failed.
GuiControl, , StatusProgress, 0
GuiControl, , StatusInfo, Failed
Gui, -Disabled
InProcess = 0
return
GuiClose:
if(InProcess) {
return
}
ExitApp
