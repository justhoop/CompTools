#include <MsgBoxConstants.au3>
#include <Inet.au3>
#RequireAdmin

While 1
	Global $watchlist = FileReadToArray("watch.txt")
	$writelist = ""
	If Watch() Then
		Write()
	EndIf
	Sleep(600000)
	ShellExecute("ipconfig","/flushdns","","",@SW_HIDE)
	ShellExecute("nbtstat","-RR","","",@SW_HIDE)
Wend

Func Watch()
	$x = 0
	For $i = 0 to Ubound($watchlist) - 1
		If Not $watchlist[$i] = "" Then
			If Ping($watchlist[$i]) > 0 Then
				TCPStartup()
				$ipadd = TCPNameToIP($watchlist[$i])
				$hostname = _TCPIPToName($ipadd,0)
				$dotlocation = Stringlen($hostname) - (stringinstr($hostname,".") - 1)
				If ($dotlocation > 0) Then
					$hostname = StringTrimRight($hostname,$dotlocation)
				EndIf
				If (StringLower($watchlist[$i]) <> StringLower($hostname)) Then
					$result = False
				Else
					$result = True
				EndIf
				If $result Then
					If msgbox(4,$watchlist[$i] & " is on.","Would you like to remove " & $watchlist[$i] & " from the list?" ) = 7 Then
						$writelist = $writelist & $watchlist[$i] & ","
					EndIf
					$x = 1
				Else	
					$writelist = $writelist & $watchlist[$i] & ","
				EndIf
			EndIf
		EndIf
	Next
	Return $x
EndFunc

Func Write()
	$file = FileOpen("watch.txt",2)
	$write = StringSplit($writelist,',')
	For $i = 1 to Ubound($write) -1
		If $write[$i] <> "" Then
			FileWriteLine($file,$write[$i])
		EndIf
	Next
	FileClose($file)
EndFunc