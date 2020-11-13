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
	Dim sql As SQL
End Sub

Sub Service_Create
	GetSafeFolder
	
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
