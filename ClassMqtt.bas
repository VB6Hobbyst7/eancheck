B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As GeneralFunctions
'	Private client As MqttClient
	Public connected As Boolean
	Private serializator As B4XSerializator
	Public subscribeTo As String = $"pdeg/devices"$
	Private mqttIdentifier As String
End Sub

Public Sub Initialize
	clsFunc.Initialize
End Sub

Public Sub StartConnection
'	Log($"CONNECTING : $Time{DateTime.Now}"$)
	Connect
	Wait For client_Connected (Success As Boolean)
	clsFunc.createCustomToast($"CONNECTED : $Time{DateTime.Now}"$, Colors.Blue)
End Sub

Public Sub Connect
'	If Starter.mqttDevice.Connected Then Return 'Starter.mqttDevice.Close
	mqttIdentifier = clsFunc.UUIDv1
	
'	Starter.mqttDevice.Initialize("client", $"tcp://${Starter.host}:${Starter.port}"$, mqttIdentifier & Rnd(1, 10000000))
	Dim mo As MqttConnectOptions
	mo.Initialize("", "")
	'this message will be sent if the client is disconnected unexpectedly.
'	mo.SetLastWill(Starter.subDisconnectString, serializator.ConvertObjectToBytes(mqttIdentifier), 0, False)
'	Starter.mqttDevice.Connect2(mo)
	
End Sub

Private Sub client_Connected (Success As Boolean)
	Try
		If Success Then
			Log("CONNECTED : " &Success)
			connected = True
'			Starter.mqttDevice.Subscribe(subscribeTo, 0)
		Else
			ProcessConnectError
		End If
	Catch
		Log($"Error caught : " ${LastException}"$)
		ProcessConnectError
	End Try
	
	
End Sub

Public Sub Disconnect
	connected = False
'	If Starter.mqttDevice.connected Then
'		Starter.mqttDevice.Unsubscribe(subscribeTo)
'		Starter.mqttDevice.Close
'	End If
End Sub

Private Sub client_MessageArrived (Topic As Object, Payload() As Byte)
	Dim passedTopic As String =$"${Topic}"$ 'ignore
	Dim receivedObject As Object = serializator.ConvertBytesToObject(Payload)'ignore
End Sub

Public Sub SendMessage(Body As String, from As String)
'	If Starter.mqttDevice.connected Then
'		Starter.mqttDevice.Publish2(subscribeTo, CreateMessage(Body, from), 0, False)
'	End If
End Sub

Public Sub SendMessageOrder(Body As List, from As String)
'	Sleep(100)
'	If Starter.mqttDevice.connected Then
'		'Starter.mqttDevice.Publish2(subscribeTo, ser.ConvertObjectToBytes(Body), 0, False)
'		Starter.mqttDevice.Publish2(subscribeTo, CreateDataMessage(Body, from), 0, False)
'	End If
End Sub

Private Sub CreateDataMessage(Body As List, from As String) As Byte()
	Dim ser As B4XSerializator
'	Dim m As orderData
'	m.Initialize
'	m.data = Body
'	m.From = from
'	
'	Return ser.ConvertObjectToBytes(m)
End Sub

Private Sub CreateMessage(Body As String, from As String) As Byte()
	Dim ser As B4XSerializator
'	Dim m As mqttMessage
'	m.Initialize
'	m.Body = Body
'	m.From = from
'	
'	Return ser.ConvertObjectToBytes(m)
End Sub

Sub GetClientConnected As Boolean
'	Return Starter.mqttDevice.Connected
End Sub

Sub ProcessConnectError
End Sub

