<%
' =====================================================================
'  UserRepository.asp  -  Acceso a datos de TBL_USER
'  Unico lugar del sistema que conoce las columnas de la tabla usuario.
' =====================================================================

' Devuelve un usuario por credenciales, o Nothing.
' La contrasena se compara con la almacenada. La BD guarda en claro
' ("12345678") y tambien en SHA1 mayusculas ("7C222..."), por lo que
' se acepta cualquiera de los dos formatos.
Function UserFindByCredentials(username, password)
    Dim rs, m, sha
    sha = UCase(Sha1Hex(password))

    Set rs = DbQuery( _
        "SELECT TOP 1 ID_USER, USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE " & _
        "FROM TBL_USER WHERE USERNAME = ? AND (PASSWORD = ? OR PASSWORD = ?)", _
        Array(username, password, sha))

    Set UserFindByCredentials = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewUser(CLng(rs("ID_USER").Value), CStr(rs("USERNAME").Value), _
                            CStr(rs("EMAIL").Value), rs("BIRTHDAY").Value, _
                            CStr(rs("USER_PHOTO").Value & ""), CInt(rs("USER_TYPE").Value))
            Set UserFindByCredentials = m
        End If
        RsClose rs
    End If
End Function

Function UserFindById(id)
    Dim rs, m
    Set rs = DbQuery("SELECT * FROM TBL_USER WHERE ID_USER = ?", Array(id))
    Set UserFindById = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewUser(CLng(rs("ID_USER").Value), CStr(rs("USERNAME").Value), _
                            CStr(rs("EMAIL").Value), rs("BIRTHDAY").Value, _
                            CStr(rs("USER_PHOTO").Value & ""), CInt(rs("USER_TYPE").Value))
            Set UserFindById = m
        End If
        RsClose rs
    End If
End Function

Function UserExists(username)
    UserExists = (ToLong(DbScalar("SELECT COUNT(*) FROM TBL_USER WHERE USERNAME = ?", Array(username)), 0) > 0)
End Function

Function UserEmailExists(email)
    UserEmailExists = (ToLong(DbScalar("SELECT COUNT(*) FROM TBL_USER WHERE EMAIL = ?", Array(email)), 0) > 0)
End Function

Function UserCreate(username, password, email, birthday, photo, userType)
    UserCreate = DbInsertReturnId( _
        "INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE) " & _
        "VALUES (?, ?, ?, ?, ?, ?)", _
        Array(username, password, email, birthday, photo, userType))
End Function

Function UserUpdate(id, username, email, birthday, photo, userType)
    UserUpdate = DbExecute( _
        "UPDATE TBL_USER SET USERNAME = ?, EMAIL = ?, BIRTHDAY = ?, USER_PHOTO = ?, USER_TYPE = ? " & _
        "WHERE ID_USER = ?", Array(username, email, birthday, photo, userType, id))
End Function

Function UserUpdatePassword(id, password)
    UserUpdatePassword = DbExecute("UPDATE TBL_USER SET PASSWORD = ? WHERE ID_USER = ?", Array(password, id))
End Function

Function UserDelete(id)
    DbExecute "UPDATE TBL_PLAYLIST SET ID_USER = 1 WHERE ID_USER = ?", Array(id)
    UserDelete = DbExecute("DELETE FROM TBL_USER WHERE ID_USER = ?", Array(id))
End Function

Function UserListAll()
    Dim rs, list
    Set list = Server.CreateObject("Scripting.Dictionary")
    Set rs = DbQuery("SELECT * FROM TBL_USER ORDER BY ID_USER", Empty)
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            list.Add CStr(rs("ID_USER").Value), NewUser(CLng(rs("ID_USER").Value), _
                CStr(rs("USERNAME").Value), CStr(rs("EMAIL").Value), rs("BIRTHDAY").Value, _
                CStr(rs("USER_PHOTO").Value & ""), CInt(rs("USER_TYPE").Value))
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set UserListAll = list
End Function
%>
