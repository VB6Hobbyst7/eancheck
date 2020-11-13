B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Dim cs As CSBuilder
	Private access As Accessiblity
	Dim phHaptic As PhoneVibrate
	Dim buttonColorWhite As ColorDrawable
	Dim buttonTextColorBlue As Long = 0xFF0099DA
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	buttonColorWhite.Initialize(Colors.White, 4dip)
End Sub

Sub UUIDv4 As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			If sb.Length = 19 Then c = Asc("8")
			If sb.Length = 14 Then c = Asc("4")
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString.ToLowerCase
End Sub

Sub UUIDv1 As String
	Dim sb As StringBuilder
	Dim code As String
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			If sb.Length = 19 Then c = Asc("8")
			If sb.Length = 14 Then c = Asc("4")
			sb.Append(Chr(c))
		Next
	Next
	Dim str() As String
	code = sb.ToString.ToLowerCase
	str =  Regex.Split("-",code)
	Return str(0)
End Sub

Public Sub GetValueFromClvByTag(clv As CustomListView, tag As String, index As Int)
	Dim p As Panel

	p = clv.GetPanel(index)
	
	For Each v As View In p.GetAllViewsRecursive
	If v Is Panel And v.Tag = "item_id"  Then
			
		End If
	Next
End Sub

Public Sub GetValueFromPanelByTag(pnl As Panel, tag As String) As String
	Dim lbl As Label
	Dim value As String
	
	For Each v As View In pnl.GetAllViewsRecursive
		If v.Tag = tag Then
			lbl = v
			value = lbl.Text
			Return value
		End If
	Next
	Return "err"
End Sub

Public Sub GetLabelFromPanelByTag(pnl As Panel, t As String) As Label
	Dim lbl As Label
	
	For Each v As View In pnl.GetAllViewsRecursive
		If v.Tag = t Then
			lbl = v
			Return lbl
		End If
	Next
	Return lbl
End Sub

Public Sub GetPanelFromTag(clv As CustomListView, tag As String) As Panel
	Dim pnl As Panel
	For i = 0 To clv.Size - 1
		pnl = clv.GetPanel(i)
		If pnl.Tag = tag Then
			Exit
		End If
	Next
	Return pnl
End Sub

'HIGHLITE PANEL IF SELECTED
Public Sub GetItemIdFromPanel(clv As CustomListView, index As Int) As String
	DeselectClvItem(clv)
	Dim p As Panel = clv.GetPanel(index)
	For Each pnl As Panel In p
		If pnl Is Panel Then
			pnl.SetColorAnimated(0, 0xFFE2FCFF, 0xFFE2FCFF)
			Exit
		End If
	Next

'	clv.GetPanel(index).Color = Colors.RGB(0,153,218)
	Return p.Tag
	
End Sub

Public Sub GetPanelFromClvIndex(clv As CustomListView, index As Int) As Panel
	Return clv.GetPanel(index)
End Sub

'DESELECT PANELS
Public Sub DeselectClvItem(clv As CustomListView)
	Dim p As Panel
	For i = 0 To clv.Size -1
		p = clv.GetPanel(i)
		For Each pnl As Panel In p
			If pnl Is Panel Then
				pnl.Color = 0xFFFFFFFF
				Exit
			End If
		Next
		'p.Color = Colors.RGB(255,255,255)
	Next
End Sub

Public Sub TextFieldPadding(v As View)
	v.Padding = Array As Int(10dip, 0dip, 0dip, 0dip)
End Sub

Public Sub AppTitle(textSize As Int, zegrisColor As Int) As CSBuilder
	cs.Initialize.Typeface(Typeface.DEFAULT).Size(textSize).Color(zegrisColor).Bold.Append("ZEGRIS")
	cs.Typeface(Typeface.CreateNew(Typeface.DEFAULT, Typeface.STYLE_ITALIC)).Color(Colors.Blue).Append("NG").PopAll
	Return cs
End Sub

Sub createCustomToast(txt As String, color As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("Arial.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, False, color)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	'  toast.RunMethod("setGravity", Array( _
	' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub

Public Sub GetPanelFromView(v As View) As Panel
	Return v.Parent
End Sub

Public Sub TestNumber(s As String) As Boolean
	Return IsNumber(s) And Regex.IsMatch("[\d\.]+", s)
End Sub

'resize fonts to original/intended size
Sub ResetUserFontScale(p As Panel)
	For Each v As View In p
		If v.Tag Is B4XFloatTextField Then
			Dim vw As B4XFloatTextField = v.tag
			vw.LargeLabelTextSize = vw.LargeLabelTextSize/access.GetUserFontScale
			vw.SmallLabelTextSize = vw.SmallLabelTextSize/access.GetUserFontScale
			vw.Update
			Continue
		End If
		If v Is Panel Then
			ResetUserFontScale(v)
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.TextSize = lbl.TextSize / access.GetUserFontScale
		Else If v Is Spinner Then
			Dim s As Spinner = v
			s.TextSize = s.TextSize / access.GetUserFontScale
		End If
	Next
End Sub

'e,g, getDateString("y|m|d|/") use getDateString("y|m|d|$") for no splitChar
Sub getDateString(format As String) As String
	'TODO CHECK FOR VALID CHARS IN FORMAT
	Dim y, m, d, retDate, splitChar As String 'ignore
	Dim retFormat() As String
	
	retFormat = Regex.Split("\|", format)
	splitChar = retFormat(3)
	If splitChar = "$" Then splitChar = ""
	
	y = DateTime.GetYear(DateTime.Now)
	m = DateTime.GetMonth(DateTime.Now)
	d = DateTime.GetDayOfMonth(DateTime.Now)
	
	For i = 0 To retFormat.Length - 1
		If retFormat(i) = "y" Then 
			retFormat(i) = y
		End If
		If retFormat(i) = "m" Then 
			retFormat(i) = m
		End If
		If retFormat(i) = "d" Then 
			retFormat(i) = d
		End If
	Next
	If retFormat(0).Length = 1 Then
		retFormat(0) = $"0${retFormat(0)}"$
	End If
	
	If retFormat(1).Length = 1 Then
		retFormat(1) = $"0${retFormat(1)}"$
	End If
	If retFormat(2).Length = 1 Then
		retFormat(2) = $"0${retFormat(2)}"$
	End If
	
	retDate = $"${retFormat(0)}${splitChar}${retFormat(1)}${splitChar}${retFormat(2)}"$
	Return retDate
	
End Sub

'e,g, getDateString("h|m|s|/") use getDateString("h|m|s|$") for no splitChar
Sub getTimeString(format As String) As String
	'TODO CHECK FOR VALID CHARS IN FORMAT
	Dim h, m, s, retTime, splitChar As String 'ignore
	Dim retFormat() As String
	
	retFormat = Regex.Split("\|", format)
	splitChar = retFormat(3)
	If splitChar = "$" Then splitChar = ""
	
	h = DateTime.GetHour(DateTime.Now)
	m = DateTime.GetMinute(DateTime.Now)
	s = DateTime.GetSecond(DateTime.Now)
	
	For i = 0 To retFormat.Length - 1
		If retFormat(i) = "h" Then 
			retFormat(i) = h
		End If
		If retFormat(i) = "m" Then 
			retFormat(i) = m
		End If
		If retFormat(i) = "s" Then 
			retFormat(i) = s
		End If
	Next
	
	If retFormat(0).Length = 1 Then
		retFormat(0) = $"0${retFormat(0)}"$
	End If
	
	If retFormat(1).Length = 1 Then
		retFormat(1) = $"0${retFormat(1)}"$
	End If
	If retFormat(2).Length = 1 Then
		retFormat(2) = $"0${retFormat(2)}"$
	End If
	
	retTime = $"${retFormat(0)}${splitChar}${retFormat(1)}${splitChar}${retFormat(2)}"$
	Return retTime
	
End Sub

Sub PlayHaptic(duration As Int)
	phHaptic.Vibrate(duration)
End Sub

Sub SetButtonColors(pnl As Activity)
	Dim btn As Button
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is Button Then
			btn = v
			btn.Background = buttonColorWhite
			btn.TextColor = buttonTextColorBlue
			Continue
		End If
	Next
	
End Sub