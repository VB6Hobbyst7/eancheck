B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Private qry As String
	Private clsFunc As GeneralFunctions
	Dim rs As ResultSet
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
End Sub

Private Sub DbInitialized
	If Starter.sql.IsInitialized = False Then
		Starter.sql.Initialize(Starter.filePath, "eancheck.db", False)
	End If
End Sub

Sub ParseArticleJson as ResumableSub
	DbInitialized
	
	Dim strArtJson As String = File.ReadString(File.DirAssets, "artikel.json")
	Dim mArtnr, recId As String
	Dim parser As JSONParser

	Sleep(400)
	
	parser.Initialize(strArtJson)
	qry = $"INSERT INTO article (id, article_number, ean_1, ean_2, ean_3, description, pack, alfa, statie)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"$
	
	Dim root As Map = parser.NextObject
	Dim artikelen As List = root.Get("artikelen")
	
	Starter.sql.BeginTransaction
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
		
		recId = clsFunc.UUIDv4
		Starter.sql.ExecNonQuery2(qry, Array As String(recId, mArtnr, ean1, ean2, ean3, oms, pack, alfa, statie))
	Next

	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
	Return True
End Sub

Sub GetArticleCount As Int
	DbInitialized
	
	qry = $"select count(article_number) as count from article"$
	Return Starter.sql.ExecQuerySingleResult(qry)
End Sub

Sub GetUnknownEanCount As Int
	DbInitialized
	
	qry = $"select count(id) as count from ean_not_found"$
	Return Starter.sql.ExecQuerySingleResult(qry)
End Sub

Sub PurgeArticleTable As ResumableSub
	DbInitialized
	
	qry = $"DELETE FROM article"$
	Starter.sql.ExecNonQuery(qry)
	'clean db space
	vacuumDB
	Return True
End Sub

Private Sub vacuumDB
	Starter.sql.ExecNonQuery("VACUUM")
End Sub
