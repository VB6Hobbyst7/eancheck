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

Sub ParseArticleCsv(csvList As List) As ResumableSub
	DbInitialized
	
	Dim mArtnr, recId As String

	Sleep(400)
	
	
	qry = $"INSERT INTO article (id, article_number, ean_1, ean_2, ean_3, description, pack, alfa, statie)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"$
	
	
	Starter.sql.BeginTransaction
	For Each item As List In csvList
		Dim itemData As productDataCsv = item
'		Dim ean1 As String = colartikelen.Get("ean1")
'		Dim oms As String = colartikelen.Get("oms")
'		Dim artnr As Int = colartikelen.Get("artnr")
'		Dim alfa As String = colartikelen.Get("alfa")
'		Dim pack As String = colartikelen.Get("pack")
'		Dim statie As Int = colartikelen.Get("statie")
'		Dim ean3 As String = colartikelen.Get("ean3")
'		Dim ean2 As String = colartikelen.Get("ean2")
		
'		mArtnr = artnr
'		If mArtnr.Length < 7 Then
'			mArtnr = $"0${mArtnr}"$
'		End If
'		
'		recId = clsFunc.UUIDv4
'		Starter.sql.ExecNonQuery2(qry, Array As String(recId, mArtnr, ean1, ean2, ean3, oms, pack, alfa, statie))
	Next

	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
	Return True
End Sub

Sub ParseArticleJson As ResumableSub
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

Sub AddItemToUnknownTable(item As productData) As List
	DbInitialized
	Dim artnrFound, ean1Found, ean2Found As Int = 0
	
	If Starter.eanJongensFound Then 
		artnrFound = 1
	End If
	
	If Starter.eanProductFound Then
		ean1Found = 1
	End If
	
	qry = $"INSERT INTO ean_not_found (id, id_from_unknown, article_number, ean_1, ean_2
	       , ean_3, description, pack, alfa, statie, date_added, articlenr_found, ean_1_found, ean_2_found)
			VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"$
'	Starter.sql.ExecNonQuery2(qry, Array As String(clsFunc.UUIDv4,item.id, item.articleNr, _
'					item.ean1, item.ean2, item.ean3, item.descr, item.pack, item.alfa, _
'					item.statie, DateTime.Now, artnrFound, ean1Found, ean2Found))
 	Starter.sql.ExecNonQuery2(qry, Array As String(clsFunc.UUIDv4,item.id, Starter.scannedJongensCode, _
					Starter.scannedProductCode, "", "", item.descr, item.pack, item.alfa, _
					item.statie, DateTime.Now, artnrFound, ean1Found, ean2Found))


	
	Return GetLastAddedUnknownItem		
					
End Sub
 
Sub GetLastAddedUnknownItem As List
	DbInitialized
	
	Dim lst As List
	Dim lastId, prodEan1, prodEan2, prodEan3 As String
	
	prodEan1 = Starter.prodEan1
	prodEan2 = Starter.prodEan2
	prodEan3 = Starter.prodEan3
	
	lst.Initialize
	lastId = GetLastId
	qry = $"SELECT * FROM ean_not_found WHERE id = ? ORDER BY date_added"$
	
	rs = Starter.sql.ExecQuery2(qry, Array As String(lastId))
	If rs.IsInitialized Then
		Do While rs.NextRow
			lst.Add(CreateproductData(rs.GetString("id"), rs.GetString("article_number"), _
			rs.GetString("ean_1"), prodEan2,	prodEan3, _
			rs.GetString("description"), rs.GetString("pack"), rs.GetString("alfa"), _
			rs.GetString("statie"),	rs.GetString("date_added"), rs.GetInt("articlenr_found"), _
			rs.GetInt("ean_1_found"), rs.GetInt("ean_2_found")))
		Loop
	End If
	
	rs.close
	Return lst
 	
End Sub

Sub GetLastId As String
	DbInitialized
	
	qry = $"SELECT id FROM ean_not_found ORDER BY date_added DESC LIMIT 1;"$
	
	Return Starter.sql.ExecQuerySingleResult(qry)
	
End Sub

Sub GetUnknownEanItems As List
	DbInitialized
	
	Dim lst As List
	lst.Initialize
	qry = $"SELECT * FROM ean_not_found ORDER BY date_added"$
	
	rs = Starter.sql.ExecQuery(qry)
	If rs.IsInitialized Then
		Do While rs.NextRow
			lst.Add(CreateproductData(rs.GetString("id"), rs.GetString("article_number"), _
			rs.GetString("ean_1"), rs.GetString("ean_2"),	rs.GetString("ean_3"), _
			rs.GetString("description"), rs.GetString("pack"), rs.GetString("alfa"), _
			rs.GetString("statie"),	rs.GetString("date_added"), rs.GetInt("articlenr_found"), _
			rs.GetInt("ean_1_found"), rs.GetInt("ean_2_found")))
		Loop
	End If
	
	rs.close
	Return lst
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

public Sub ProcessScannedCode(isJongens As Boolean) As Int
	DbInitialized
	
	If isJongens Then
		qry = "SELECT count(id) FROM article WHERE article_number = ?"
		Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(Starter.firstCodeScanned))
	Else
		'qry = "SELECT count(id) FROM article WHERE article_number = ? Or (ean_1 = ? Or ean_2 = ? Or ean_3 = ?)"
		qry = "SELECT count(id) FROM article WHERE (ean_1 = ? Or ean_2 = ? Or ean_3 = ?)"
		Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(Starter.firstCodeScanned, Starter.firstCodeScanned, Starter.firstCodeScanned))
	End If
End Sub

public Sub GetUnknownEanData As List
	DbInitialized
	Dim lst As List
	Dim cs As CSBuilder
	Dim qryRun As Boolean
	'Dim unknownText As String = cs.Initialize.Typeface(Typeface.FONTAWESOME).Color(0xFF01FF20).Size(40).Append(Chr(0xF044)).Append(" Onbekend").PopAll
	
	Dim unknownText As String =  cs.Initialize.Underline.Color(0xFF00D0FF).Clickable("word", "Onbekend").Append("Onbekend").PopAll

	
	If Starter.scannedJongensCode.Length > 0 And Starter.eanJongensFound Then
		qry = $"SELECT * FROM article where article_number = ?"$
		rs = Starter.sql.ExecQuery2(qry, Array As String(Starter.scannedJongensCode))
		qryRun = True
	End If
	
	If Starter.scannedProductCode.Length > 0 And Starter.eanProductFound Then
		qry = $"SELECT * FROM article where (ean_1 = ? or ean_2 = ? or ean_3 = ?)"$
		rs = Starter.sql.ExecQuery2(qry, Array As String(Starter.scannedProductCode, Starter.scannedProductCode, Starter.scannedProductCode))
		qryRun = True
	End If
	lst.Initialize
	If qryRun Then
		If rs.RowCount > 0 Then
			Do While rs.NextRow
				lst.Add(CreateproductData(rs.GetString("id"), rs.GetString("article_number"), rs.GetString("ean_1"), _
			rs.GetString("ean_2"), rs.GetString("ean_3"), rs.GetString("description"), rs.GetString("pack"), _
			rs.GetString("alfa"), rs.GetString("statie"), DateTime.Now, 0, _
			0, 0))
			Loop
			Log(rs.Position)
			Starter.prodEan1 = rs.GetString("ean_1")
			Starter.prodEan2 = rs.GetString("ean_2")
			Starter.prodEan3 = rs.GetString("ean_3")
			rs.close
		End If
	End If
	If lst.Size = 0 Then
		lst.Add(CreateproductData(clsFunc.UUIDv4, Starter.scannedJongensCode, Starter.scannedProductCode, "", "", unknownText, "", "", "", DateTime.Now, 0, 0, 0))
	End If
	Return lst
	
End Sub

Public Sub CreateproductData (id As String, articleNr As String, ean1 As String, ean2 As String, ean3 As String, descr As String, pack As String, alfa As String, statie As String, dateAdded As Long, artnrFound As Int, ean1Found As Int, ean2Found As Int) As productData
	Dim t1 As productData
	t1.Initialize
	t1.id = id
	t1.articleNr = articleNr
	t1.ean1 = ean1
	t1.ean2 = ean2
	t1.ean3 = ean3
	t1.descr = descr
	t1.pack = pack
	t1.alfa = alfa
	t1.statie = statie
	t1.dateAdded = dateAdded
	t1.artnrFound = artnrFound
	t1.ean1Found = ean1Found
	t1.ean2Found = ean2Found
	Return t1
End Sub

Public Sub DeleteItemFromList(id As String)
	DbInitialized
	qry = $"DELETE FROM ean_not_found WHERE id = ?"$
	Starter.sql.BeginTransaction
	Starter.sql.ExecNonQuery2(qry, Array As String(id))
	Starter.sql.TransactionSuccessful
	Starter.sql.EndTransaction
End Sub

'Public Sub CheckIfItemExistsInUnknownTable(id As String) As Int
Public Sub CheckIfItemExistsInUnknownTable(article_number As String, ean_1 As String) As Int
	DbInitialized
	qry = $"SELECT Count(id) FROM ean_not_found WHERE id_from_unknown = ?"$
	qry = $"SELECT Count(id) FROM ean_not_found WHERE article_number = ? and (ean_1 = ? or ean_2 = ? or ean_3 = ?)"$
	Return Starter.sql.ExecQuerySingleResult2(qry, Array As String(article_number, ean_1))
End Sub