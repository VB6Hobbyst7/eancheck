B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim ftp As FTP
	Dim su As StringUtils
End Sub

Public Sub Initialize
'	clsImportJson.Initialize
End Sub

'pickerId "998" for test
Public Sub DownloadAndProcessOrder(pickerId As String) As ResumableSub
	Dim sTime As Long = DateTime.Now
	Dim orderCount As Int = 0
	Dim ftp As FTP
	Dim pickerPath, strCsv As String
	Dim lstProdLoc As List
	
	
	If ftp.IsInitialized = False Then
		ftp.Initialize("ftp", Starter.ftpServer, Starter.ftpPort, Starter.ftpUserName, Starter.FtpPassword)
		ftp.PassiveMode = True
	End If
	
	pickerPath = $"/scan_app/${pickerId}/prodloc"$
	pickerPath = $"/scan_app/prodloc"$
	
	'GET A FILE LIST FROM A SPECIFIC FOLDER
	ftp.List(pickerPath)
	
	wait for FTP_ListCompleted(ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
					
	If Success = False Then
		Log(LastException)
		ftp.Close
		orderCount = -1
	Else
		'LOOP ALL FILES IN THE SELECTED FOLDER
		For i = 0 To Files.Length - 1
			If Files(i).Name = "productLocation.csv" Then
				Log(Files(i).Name & " - " &Files(i).Timestamp)
				Dim sf As Object = ftp.DownloadFile($"${pickerPath}/${Files(i).Name}"$, False, Starter.filePath, Files(i).Name)
				Wait For (sf) ftp_DownloadCompleted (ServerPath As String, Success As Boolean)

				If Success Then
					lstProdLoc = su.LoadCSV(Starter.filePath, Files(i).Name, ";")
'					If Files(i).Name = "productLocation.csv" Then
'						strCsv = File.ReadString(Starter.filePath, Files(i).Name)
'					End If
				
				End If
				Exit
			End If
			'		File.Delete(Starter.ftpFolder, Files(i).Name)
		Next
		
		ftp.Close
	End If
	Log($"Duration connect & download : ${DateTime.Now-sTime} ms"$)
End Sub


'pickerId "998" for test
Public Sub UploadOrderData(pickerId As String)
	Dim pickerSendPath, pickerId, uploadFolder As String
	Dim filesToSend, filesSent As List
	Dim ftp As FTP
	Dim ctm As CustomTrustManager
	
	ctm.InitializeAcceptAll
	uploadFolder = Starter.ftpFolder
	pickerId = Starter.pickerId
	pickerSendPath = $"/scan_app/${pickerId}/sent/"$
	filesSent.Initialize
	
	'GET FILES
	filesToSend = File.ListFiles(uploadFolder)
	If filesToSend.Size = 0 Then
		Return
	End If
	
	ProgressDialogShow2("Bestanden versturen..", False)
	
	If ftp.IsInitialized = False Then
		ftp.PassiveMode = True
		ftp.Initialize("ftp", Starter.ftpServer, Starter.ftpPort, Starter.ftpUserName, Starter.FtpPassword)
	End If
	
	For Each fileToSend As String In filesToSend
		Dim ftpObj As Object = ftp.UploadFile(uploadFolder, fileToSend, False, $"${pickerSendPath}${fileToSend}"$)
		
		Wait For (ftpObj) ftp_UploadCompleted (ServerPath As String, Success As Boolean)
		
		If Success Then
			filesSent.Add(fileToSend)
		Else
			Log(LastException.Message)
		End If
	Next
	
	ftp.Close
	
	ProgressDialogHide
	
	For Each fileToDelete As String In filesSent	
		File.Delete(Starter.ftpFolder, fileToDelete)
	Next
End Sub

