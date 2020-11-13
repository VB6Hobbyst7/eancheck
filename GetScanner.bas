B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
#Region doc
	'PGR 30-october-2020
	'class for use with bluetooth scanner in SPP mode
	'USAGE : 
	'	In calling Activity create an instance of this class,
	'	e.g.	Dim Scaner As GetScanner 
	'			Scan.Initialize
	'			Scan.serial1.Initialize("Serial")
	'			Scan.T.Initialize("Timer", 2000)

	' Handle Activity_Pause like
	'			Sub Activity_Pause (UserClosed As Boolean)
	'				Scan.AStream.Close
	'				Scan.serial1.Disconnect
	'				Scan.T.Enabled=False
	'			End Sub
	'
	' Handele Activity_Resume
	'		Sub Activity_Resume
'				Show("Connectie maken...", False)
'				Scan.ShowPairedDevices
'				If Scan.ScannerOnceConnected=True Then
'					Scan.T.Enabled=True
'				End If
'			End Sub
'USAGE
#End Region

Sub Class_Globals
	Dim clsFunc As GeneralFunctions
	Dim serial1 As Serial
	Dim AStream As AsyncStreams
	Dim TimeGetDevice As Timer
	Dim ScannerMacAddress As String
	Dim ScannerOnceConnected As Boolean
	Dim maxTriesToConnect As Int = 0
	Dim noDevice As String = "Geen apparaten gevonden.."
	Dim selectNoScanner As String = "Annuleer"
	Dim act As String
	Dim beepje As Beeper
End Sub

'PASS THE ACTIVITY NAME AS STRING e.g. clsScan.Initialize("login"), THIS IS USED IN SUB AStream_NewData
'TO CALL "ProcessScannedEanCode" IN THE PASSED ACTIVITY
Public Sub Initialize(callingActivity As String)
	act = callingActivity
	clsFunc.Initialize
	beepje.Initialize(200, 2000)
End Sub

Sub ShowPairedDevices
	Dim PairedDevices As Map
	Dim deviceList As List
	Dim res As Int
	
	PairedDevices = serial1.GetPairedDevices
	deviceList.Initialize
	
	'ADD DEVICES FOUND TO LIST
	For i = 0 To PairedDevices.Size - 1
		deviceList.Add(PairedDevices.GetKeyAt(i))
	Next
	deviceList.Add(selectNoScanner)
	
	'IF NO DEVICES ARE FOUND
	If  deviceList.Size = 0 Then
		deviceList.Add(noDevice)
	End If
	
	
	'A SCAN DEVICE IS PREVIOUSLY SELECTED, NO NEED TO SHOW DEVICE LIST
	If Starter.scannerMac <> "" Then
		serial1.Connect(Starter.scannerMac)
		Return
	End If
	
	'SHOW LIST WITH DEVICES FOUND (OR "No DEVICES FOUND..)"
	res = InputList(deviceList, "Choose device", -1) 'show list with paired devices 'ignore
	
	If res <> DialogResponse.CANCEL Then
		If deviceList.Get(res) = noDevice Or deviceList.Get(res) = selectNoScanner Then
			Starter.scannerMac = ""
			TimeGetDevice.Enabled = False
			serial1.Disconnect
			AStream.Close
			Return
		Else
			TimeGetDevice.Initialize("Timer", 2000)
			'TRY TO CONNECT TO THE SELECTED DEVICE
			ScannerMacAddress= PairedDevices.Get(deviceList.Get(res)) 'convert the name to mac address and connect
			serial1.Connect(ScannerMacAddress)
			'REMEMBER SELECTED DEVICE FOR QUICK START
			Starter.scannerMac = ScannerMacAddress
	'		Starter.mqttMac = Starter.scannerMac.Replace(":", "")
		End If
	End If
 
End Sub

'DATA IS RECEIVED AS BYTES, CONVERT BYTES TO STRING AND CALL FUNCTION TO PROCESS
Sub AStream_NewData (Buffer() As Byte)
	Dim eanReceived As String = BytesToString(Buffer, 0, Buffer.Length, "UTF8")
	CallSub2($"${act}"$, "ProcessScannedCode", eanReceived)
End Sub

'WE DON'T WANT THIS TO HAPPEN
Sub AStream_Error
	'CallSub2(orderpickingitems, "ScannerFound", False)
	CallSubDelayed2($"${act}"$, "ScannerFound", False)
	clsFunc.createCustomToast("Fout ...", Colors.Blue)
'	AStream.Close
'	serial1.Disconnect
	If ScannerOnceConnected = True Then
		If TimeGetDevice.IsInitialized Then
			TimeGetDevice.Enabled = True
		End If
	Else
		ShowPairedDevices
	End If
End Sub

Sub AStream_Terminated
	clsFunc.createCustomToast("Verbinding beëindigd...", Colors.Blue)
	AStream_Error
End Sub

Sub Timer_Tick
	TimeGetDevice.Enabled = False
	serial1.Connect(ScannerMacAddress)
	clsFunc.createCustomToast ("Verbinden met apparaat...", Colors.Blue)
End Sub

Sub Serial_Connected (success As Boolean)
	Dim strDeviceMac As String
	
	If success = True Then
		strDeviceMac = Starter.scannerMac
		File.WriteString(Starter.filePath, "scnmac.dis", strDeviceMac)
			
		AStream.Initialize(serial1.InputStream, serial1.OutputStream, "AStream")
		ScannerOnceConnected = True
		TimeGetDevice.Enabled = False
		clsFunc.createCustomToast("Scanner verbonden", Colors.Blue)
	Else
		If ScannerOnceConnected=False Then

		Else
			'SET SOMEKIND OF TIMEOUT TIME OR MAX TRIES
			maxTriesToConnect = maxTriesToConnect + 1
			Log($"Still waiting for the scanner to reconnect : ${ScannerMacAddress} (${maxTriesToConnect})"$)
			If maxTriesToConnect <= 3 Then
				TimeGetDevice.Enabled = True
			Else
				TimeGetDevice.Enabled = False
			End If
		End If
	End If
End Sub