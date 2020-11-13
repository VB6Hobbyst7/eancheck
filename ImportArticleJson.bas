B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub ParseArticleJson
	Dim strArtJson As String = File.ReadString(File.DirAssets, "artikel.json")
	Dim mArtnr As String
	Dim parser As JSONParser

	Sleep(400)
	
	parser.Initialize(strArtJson)
	
	Dim root As Map = parser.NextObject
	Dim artikelen As List = root.Get("artikelen")
	For Each colartikelen As Map In artikelen
		Dim ean1 As String = colartikelen.Get("ean1")
		Dim oms As String = colartikelen.Get("oms")
		Dim artnr As Int = colartikelen.Get("artnr")
		Dim alfa As String = colartikelen.Get("alfa")
		Dim pack As String = colartikelen.Get("pack")
		Dim statie As Int = colartikelen.Get("statie")
		Dim ean3 As String = colartikelen.Get("ean3")
		Dim ean2 As String = colartikelen.Get("ean2")
		
		mArtnr = artnr
		If mArtnr.Length < 7 Then
			mArtnr = $"0${mArtnr}"$
		End If
	Next

End Sub