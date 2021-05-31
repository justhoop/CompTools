#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <Date.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Inet.au3>

#Region ### START Koda GUI section ### Form=frmmain.kxf
$frmMain = GUICreate("Computer Utilities", 266, 187, 219, 138)
$Label1 = GUICtrlCreateLabel("Service Tag:", 8, 8, 65, 17)
$iptServiceTag = GUICtrlCreateInput("", 8, 24, 89, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$btnCDrive = GUICtrlCreateButton("C Drive", 184, 120, 75, 25)
$btnManage = GUICtrlCreateButton("Manage", 184, 152, 75, 25)
$btnAdmin = GUICtrlCreateButton("Admin", 8, 152, 75, 25)
$iptPassword = GUICtrlCreateInput("iptPassword", 104, 24, 153, 21)
$btnPassword = GUICtrlCreateButton("Password", 183, 47, 75, 25)
$Label2 = GUICtrlCreateLabel("Password Status:", 104, 8, 86, 17)
$btnAddWatch = GUICtrlCreateButton("Add Watch", 8, 120, 75, 25)
$btnShowWatch = GUICtrlCreateButton("Show Watch", 98, 120, 75, 25)
$lblInfo = GUICtrlCreateLabel("", 8, 50, 84, 65)
$btnCMRC = GUICtrlCreateButton("CMRC", 98, 152, 75, 25)
$lblInfo2 = GUICtrlCreateLabel("", 99, 50, 84, 65)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

KillButtons("on")
$oldmem = ""
WinMove("Computer Utilities", "Service Tag:", RegRead("HKEY_CURRENT_USER\SOFTWARE\CompTool", "x"), RegRead("HKEY_CURRENT_USER\SOFTWARE\CompTool", "y"))
GuiCtrlSetData($iptPassword,"")
GuiCtrlSetState($btnPassword,$GUI_DEFBUTTON)
KillButtons("off")

While 1
	GetMem()
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			RememberPosition()
			Exit
		Case $iptServiceTag
			GUICtrlSetData($lblInfo, "")
			ClipPut(GuiCtrlRead($iptServiceTag))
		Case $btnCDrive
			ShellExecute("\\" & GuiCtrlRead($iptServiceTag) & "\c$")
		Case $btnAdmin
			KillButtons("on")
			$host = GuiCtrlRead($iptServiceTag)
			GetLocalAdmins($host)
			Killbuttons("off")
		Case $btnPassword
			$domain = EnvGet("USERDOMAIN")
			Local $iPID = Run("LockoutStatus.exe -u:" & $domain & "\" & GUICtrlRead($iptPassword))
			if $iPID Then
				
			Else
				MsgBox(0, "Application not found", "Please make sure LockoutStatus is in the path.")
			EndIf
			GuiCtrlSetData($iptPassword,"")
		Case $btnManage
			ShellExecute("c:\windows\system32\compmgmt.msc"," /computer:\\" & GuiCtrlRead($iptServiceTag))
		Case $btnCMRC
			Local $iPID = Run("CmRcViewer.exe " & GuiCtrlRead($iptServiceTag))
			if $iPID Then
				
			Else
				MsgBox(0, "Application not found", "Please make sure CmRcViewer is in the path.")
			EndIf
		Case $btnShowWatch
			Run("notepad.exe watch.txt")
		Case $btnAddWatch
			KillButtons("on")
			If GuiCtrlRead($iptServiceTag) Then
				AddWatch(GuiCtrlRead($iptServiceTag))
			EndIf
			KillButtons("off")
	EndSwitch
WEnd

Func AddWatch($computer)
	$file = FileOpen("watch.txt",1)
	FileWriteLine($file,$computer)
	FileClose($file)
	GUICtrlSetData($lblInfo2, $computer & " added to watchlist.")
EndFunc

Func KillButtons($state)
	If $state = "on" Then
		GUICtrlSetState($btnManage,$GUI_DISABLE)
		GUICtrlSetState($btnAdmin,$GUI_DISABLE)
		GUICtrlSetState($btnPassword,$GUI_DISABLE)
		GUICtrlSetState($btnAddWatch,$GUI_DISABLE)
		GUICtrlSetState($btnShowWatch,$GUI_DISABLE)
		GUICtrlSetState($btnCMRC,$GUI_DISABLE)
		GUICtrlSetState($btnCDrive,$GUI_DISABLE)
		Sleep(30)
	Else
		GUICtrlSetState($btnManage,$GUI_ENABLE)
		GUICtrlSetState($btnAdmin,$GUI_ENABLE)
		GUICtrlSetState($btnPassword,$GUI_ENABLE)
		GUICtrlSetState($btnAddWatch,$GUI_ENABLE)
		GUICtrlSetState($btnShowWatch,$GUI_ENABLE)
		GUICtrlSetState($btnCMRC,$GUI_ENABLE)
		GUICtrlSetState($btnCDrive,$GUI_ENABLE)
		
	EndIf
	Sleep(10)
EndFunc

Func GetLocalAdmins($host)
	KillButtons("on")
	$output=""
	$display = ""
	GUICtrlSetData($lblInfo2, "Getting admin")
	Dim $filter[1] = ["group"]     
	$colGroups = ObjGet("WinNT://" & $host & "")
	If Not IsObj($colGroups) Then Return 0     
	$colGroups.Filter = $filter     
	For $objGroup In $colGroups         
		If $objGroup.name = "Administrators" Then               
			For $objUser In $objGroup.Members
				MsgBox(1,"",$objUser.name)
				If StringInStr($objUser.name, ".") Then
					$output = $output & $objUser.name & ","
					$display = $display & $objUser.name & @CRLF
				EndIf
			Next             
		EndIf     
	Next
	GUICtrlSetData($lblInfo2, $display)
	KillButtons("off")
	Return $output
EndFunc

Func RememberPosition()
	$tempAr = WinGetPos("Computer Utilities")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\CompTool", "x", "REG_SZ", $tempAr[0])
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\CompTool", "y", "REG_SZ", $tempAr[1])
EndFunc

Func GetMem()
	If controlgetfocus("Computer Utilities") <> "Edit2" Then
		$mem = ClipGet()
		$mem = StringStripWS($mem,8)
		If $mem <> $oldmem Then
			If StringLen($mem)=7 Or StringLen($mem)=10 Then
				GUICtrlSetData($lblInfo, "")
				GUICtrlSetData($lblInfo2, "")
				GUICtrlSetData($iptServiceTag, $mem)
				WinSetOnTop("Computer Utilities", "",1)
				$oldmem = $mem
				Pingit($mem)
				WinSetOnTop("Computer Utilities", "",0)
			EndIf
		EndIf
	EndIf
EndFunc

Func Pingit($stag)
		$ping = Ping($stag)
		If $ping > 0 Then
			TCPStartup()
			$ipadd = TCPNameToIP($stag)
			GUICtrlSetData($lblInfo, $ipadd)
			$hostname = _TCPIPToName($ipadd,0)
			$dotlocation = Stringlen($hostname) - (stringinstr($hostname,".") - 1)
			If ($dotlocation > 0) Then
				$hostname = StringTrimRight($hostname,$dotlocation)
			EndIf
			If (StringLower($stag) <> StringLower($hostname)) Then
				$result = " - false"
			Else
				$result = " - true"
			EndIf
			GUICtrlSetData($lblInfo2, $hostname & $result)
			Return 0
		Else
			Select
				Case @error = "1"
					GUICtrlSetData($lblInfo, "Host is offline")
				Case @error = "2"
					GUICtrlSetData($lblInfo, "Host is unreachable")
				Case @error = "3"
					GUICtrlSetData($lblInfo, "Bad destination")
				Case @error = "4"
					GUICtrlSetData($lblInfo, "Ping Failure")
			EndSelect
			Return 1
		EndIf
EndFunc