<%
' =====================================================================
'  Connection.asp  -  Unica cadena de conexion de la aplicacion.
'  Cambiar el servidor o credenciales se hace SOLO aqui.
' =====================================================================

Function GetConnectionString()
    GetConnectionString = _
        "Provider=SQLOLEDB;Server=localhost;Database=BDD_PoliMusic;" & _
        "User Id=usr_polimusic;Password=Politecnica1;" & _
        "Encrypt=true;TrustServerCertificate=true;"
End Function

' Abre una conexion ADO. El llamador es responsable de cerrarla
' (los repositorios lo hacen mediante CloseConn).
Function OpenConnection()
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.ConnectionTimeout = 15
    conn.Open GetConnectionString()
    Set OpenConnection = conn
End Function

Sub CloseConn(conn)
    If IsObject(conn) Then
        If conn.State <> 0 Then conn.Close
        Set conn = Nothing
    End If
End Sub
%>
