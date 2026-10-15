<%
' =====================================================================
'  Db.asp  -  Helper ADO parametrizado (capa de acceso a datos).
'
'  Toda consulta a la base pasa por aqui. Los repositorios NUNCA
'  concatenan valores del usuario en el SQL: siempre usan parametros,
'  lo que elimina de raiz la inyeccion SQL.
'
'  Uso:
'    Set rs = DbQuery("SELECT * FROM TBL_SONG WHERE ID_SONG = ?", Array(5))
'    DbExecute "UPDATE TBL_SONG SET SONG_NAME = ? WHERE ID_SONG = ?", Array(n, id)
'
'  Notas de implementacion (apegadas al comportamiento real de ADO):
'   - Un Recordset abierto a partir de un Command NO permite reasignar
'     su propiedad ActiveConnection (error 800a0e7b). Por eso la
'     conexion se administra a traves del propio Command y se cierra
'     despues de consumir los datos.
'   - DbQuery devuelve un Recordset cliente ya leido en memoria, de modo
'     que el llamador puede recorrerlo con seguridad y luego cerrarlo.
' =====================================================================

' --- Crea un parametro tipado para ADO -----------------------------
'
'  REGLA CENTRAL: el tipo lo determina el TIPO del valor recibido
'  (VarType), NO su contenido.
'
'  Es importante no "adivinar" con IsNumeric(). Si un valor es una
'  cadena, se envia SIEMPRE como texto, aunque parezca un numero.
'  Motivo real (defecto detectado y corregido):
'
'      La consulta de login compara PASSWORD contra dos parametros:
'
'          WHERE USERNAME = ? AND (PASSWORD = ? OR PASSWORD = ?)
'
'      Si la contrasena escrita por el usuario es "12345678", IsNumeric
'      la marca como numero y el parametro viaja como adInteger. Al
'      comparar la columna PASSWORD (varchar) contra un entero, SQL
'      Server aplica precedencia de tipos y trata de convertir la
'      columna a int. Para la fila cuyo PASSWORD es un hash SHA-1
'      ("7C222FB2927D828AF22F592134E8932480637C0D") esa conversion
'      falla:
'
'          error 80040e07: Conversion failed when converting the
'          varchar value '7C222...' to data type int.
'
'      Es decir, una contrasena numerica rompia el inicio de sesion de
'      cualquier usuario cuya clave estuviera guardada como hash.
'      Al tipar por VarType el problema desaparece de raiz.
'
'  Los valores verdaderamente numericos llegan como Long (VarType 3),
'  porque las paginas los normalizan con ToLong() antes de pasarlos.
Function DbParam(value)
    Dim p
    Set p = Server.CreateObject("ADODB.Parameter")
    p.Direction = 1 ' adParamInput

    If IsNull(value) Then
        p.Type = 202 ' adVarChar
        p.Size = 4000
        p.Value = Null

    ElseIf VarType(value) = 7 Then ' vbDate
        p.Type = 135 ' adDBTimeStamp
        p.Value = value

    ElseIf VarType(value) = 11 Then ' vbBoolean
        p.Type = 11 ' adBoolean
        p.Value = value

    ElseIf VarType(value) = 3 Or VarType(value) = 2 Then ' vbLong / vbInteger
        p.Type = 3 ' adInteger
        p.Value = CLng(value)

    ElseIf Len(Trim(value & "")) = 0 Then
        ' Cadena vacia -> NULL (evita errores de conversion en fechas).
        p.Type = 202
        p.Size = 4000
        p.Value = Null

    Else
        ' Cualquier otro caso es texto; NUNCA se infiere numero.
        p.Type = 202 ' adVarChar
        p.Size = 4000
        p.Value = CStr(value)
    End If

    Set DbParam = p
End Function

' --- Construye un Command parametrizado ----------------------------
Function DbCommand(conn, sql, params)
    Dim cmd, i
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = 1 ' adCmdText
    cmd.CommandTimeout = 30
    cmd.CommandText = sql
    If IsArray(params) Then
        For i = 0 To UBound(params)
            cmd.Parameters.Append DbParam(params(i))
        Next
    End If
    Set DbCommand = cmd
End Function

' --- SELECT: devuelve un Recordset (o Nothing) ----------------------
'
'  Se mantiene el Command parametrizado (proteccion contra inyeccion).
'  Verificado en este entorno: tras cerrar la conexion, el Recordset
'  deja de ser legible (error 3265), por lo que la conexion permanece
'  abierta y se cierra en RsClose(), usando la propia conexion que el
'  Recordset referencia.
Function DbQuery(sql, params)
    Dim rs
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.CursorLocation = 3 ' adUseClient
    rs.Open DbCommand(OpenConnection(), sql, params), , 3, 1 ' adOpenStatic, adLockReadOnly
    If Not rs.EOF Then rs.MoveFirst
    Set DbQuery = rs
End Function

' --- Cierra un Recordset y su conexion -----------------------------
Sub RsClose(rs)
    Dim cn
    If IsObject(rs) Then
        If Not (rs Is Nothing) Then
            On Error Resume Next
            Set cn = rs.ActiveConnection
            If IsObject(cn) Then
                If Not (cn Is Nothing) Then
                    If cn.State <> 0 Then cn.Close
                    Set cn = Nothing
                End If
            End If
            If rs.State <> 0 Then rs.Close
            Err.Clear
            On Error GoTo 0
            Set rs = Nothing
        End If
    End If
End Sub

' --- SELECT de un solo valor escalar --------------------------------
Function DbScalar(sql, params)
    Dim rs, v
    Set rs = DbQuery(sql, params)
    v = Null
    If Not rs Is Nothing Then
        If Not rs.EOF Then If Not IsNull(rs(0).Value) Then v = rs(0).Value
        RsClose rs
    End If
    DbScalar = v
End Function

' --- INSERT / UPDATE / DELETE --------------------------------------
Function DbExecute(sql, params)
    Dim conn, cmd, affected
    Set conn = OpenConnection()
    Set cmd  = DbCommand(conn, sql, params)
    cmd.Execute affected, , 129 ' adExecuteNoRecords + adCmdText
    DbExecute = affected
    CloseConn conn
End Function

' --- INSERT que devuelve el IDENTITY generado ----------------------
'  SET NOCOUNT ON evita que el INSERT genere un resultset vacio previo,
'  de modo que la primera (y unica) consulta es el SELECT del ID.
'  Se recorre por seguridad hasta encontrar un resultset con columnas.
Function DbInsertReturnId(sql, params)
    Dim rs, id, guard
    Set rs = DbQuery("SET NOCOUNT ON; " & sql & "; SELECT CAST(SCOPE_IDENTITY() AS INT) AS NEW_ID", params)
    id = -1
    If Not rs Is Nothing Then
        guard = 0
        Do While rs.State <> 0 And rs.Fields.Count = 0 And guard < 10
            Set rs = rs.NextRecordset
            guard = guard + 1
        Loop
        If rs.State <> 0 Then
            If rs.Fields.Count > 0 Then
                If Not rs.EOF Then
                    If Not IsNull(rs("NEW_ID").Value) Then id = CLng(rs("NEW_ID").Value)
                End If
            End If
        End If
        RsClose rs
    End If
    DbInsertReturnId = id
End Function
%>
