B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.9
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Private rp As RuntimePermissions
	Public const port As Int = 1883
	Public const host As String = "pdeg3005.mynetgear.com"
	Public filePath As String
	Public scannerMac, firstCodeScanned, secondCodeScanned As String
	Public testSecondCode, eanJongensFound, eanProductFound As Boolean
	Public scannedJongensCode, scannedProductCode As String
	Public prodEan1, prodEan2, prodEan3 As String
	Public ftpServer, ftpUserName, FtpPassword, pickerId As String
	Public filePath, ftpFolder As String
	Public ftpPort, SelectedOrderIndex As Int
	Dim sql As SQL
	Private streamer As AudioStreamer
	Dim sp As SoundPool
	Dim LoadId As Int
End Sub

Sub Service_Create
	GetSafeFolder
	streamer.Initialize("streamer", 8000, True, 16, streamer.VOLUME_MUSIC)
	streamer.StartPlaying
	SetFtpData
	sp.Initialize(1)
	LoadId = sp.Load(File.DirAssets, "iphone_whatsapp_2016.mp3")
'	sp.Play(LoadId, 1, 1, 1, 1, 1)
	
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub

Private Sub GetSafeFolder
	Dim folder() As String
	folder = rp.GetAllSafeDirsExternal("")
	
	filePath = folder(0)
End Sub

Public Sub Beep (DurationMs As Double, Frequency As Int)
	Dim sampleRate As Int = 8000
	Dim numSamples As Int = sampleRate * DurationMs / 1000
	Dim gsnd(2 * numSamples) As Byte
	For i = 0 To numSamples - 1
		Dim d As Double = Sin(2 * cPI * i / (sampleRate / Frequency))
		Dim val As Short = d * 32767
		gsnd(2 * i) = Bit.And(val, 0x00ff)
		gsnd(2 * i + 1) = Bit.UnsignedShiftRight(Bit.And(val, 0xff00), 8)
	Next
	streamer.Write(gsnd)
End Sub

Public Sub PlayFound
	sp.Play(LoadId, 1, 1, 1, 0, 1)
End Sub

Private Sub SetFtpData
	ftpServer = "dev.distridata.nl"
	ftpUserName = "ftp_youwe_zegro"
	FtpPassword = "Y0uw3FTP_2o19@"
	ftpPort = 21
	
End Sub