<%
' =====================================================================
'  AuthService.asp  -  Reglas de autenticacion, sesion y roles.
'  Toda decision de "quien puede que" vive aqui; las paginas solo
'  preguntan, nunca deciden por su cuenta.
' =====================================================================

' Intenta iniciar sesion. Devuelve True si las credenciales son validas
' y deja los datos del usuario en Session.
Function AuthLogin(username, password)
    Dim user
    AuthLogin = False
    If Len(Trim(username)) = 0 Or Len(Trim(password)) = 0 Then Exit Function

    Set user = UserFindByCredentials(Trim(username), Trim(password))
    If user Is Nothing Then Exit Function

    Session(SESSION_USER_ID)    = user("Id")
    Session(SESSION_USERNAME)   = user("Username")
    Session(SESSION_USER_TYPE)  = user("UserType")
    Session(SESSION_USER_PHOTO) = user("Photo")
    AuthLogin = True
End Function

Sub AuthLogout()
    Session.Contents.RemoveAll()
    Session.Abandon()
End Sub

' --- Conversion segura a numero ------------------------------------
'     Ojo: NO usar "valor & 0" porque, si el valor ya es "1", la
'     concatenacion produce "10" y cambia el numero. Aqui se valida
'     explicitamente antes de convertir.
Function ToLong(value, defaultValue)
    ToLong = defaultValue
    If IsNull(value) Or Len(Trim(value & "")) = 0 Then Exit Function
    If IsNumeric(value) Then ToLong = CLng(value)
End Function

Function AuthIsLogged()
    AuthIsLogged = (Len(Session(SESSION_USERNAME) & "") > 0)
End Function

Function AuthUserId()
    AuthUserId = ToLong(Session(SESSION_USER_ID), 0)
End Function

Function AuthUsername()
    AuthUsername = Session(SESSION_USERNAME) & ""
End Function

Function AuthUserType()
    AuthUserType = ToLong(Session(SESSION_USER_TYPE), ROLE_USER)
End Function

Function AuthIsAdmin()
    AuthIsAdmin = (AuthUserType() = ROLE_ADMIN)
End Function

' --- Guardas de acceso ---------------------------------------------
' Exigen sesion activa; si no la hay, redirigen al login.
' Se usa una ruta absoluta (/login.asp) para que la redireccion sea
' correcta tanto desde la raiz como desde subcarpetas como /admin.
Sub RequireLogin()
    If Not AuthIsLogged() Then
        Response.Redirect APP_BASE & "/login.asp?msg=session"
    End If
End Sub

' Exigen rol administrador. Un usuario normal recibe un aviso y se le
' devuelve a la pantalla principal (no se le muestra el CRUD).
Sub RequireAdmin()
    If Not AuthIsLogged() Then
        Response.Redirect APP_BASE & "/login.asp?msg=session"
        Exit Sub
    End If
    If Not AuthIsAdmin() Then
        Response.Redirect APP_BASE & "/canciones.asp?msg=forbidden"
    End If
End Sub

' --- Registro (enrolamiento de usuario) ----------------------------
' Devuelve "" si todo fue bien, o el mensaje de error.
Function AuthRegister(username, password, confirmPassword, email)
    If Len(Trim(username)) < 3 Then
        AuthRegister = "El usuario debe tener al menos 3 caracteres."
    ElseIf Len(Trim(password)) < 6 Then
        AuthRegister = "La contrasena debe tener al menos 6 caracteres."
    ElseIf Trim(password) <> Trim(confirmPassword) Then
        AuthRegister = "Las contrasenas no coinciden."
    ElseIf InStr(Trim(email), "@") = 0 Then
        AuthRegister = "El correo electronico no es valido."
    ElseIf UserExists(Trim(username)) Then
        AuthRegister = "Ese nombre de usuario ya esta registrado."
    ElseIf UserEmailExists(Trim(email)) Then
        AuthRegister = "Ese correo ya esta registrado."
    Else
        UserCreate Trim(username), Sha1Hex(Trim(password)), Trim(email), Now(), IMG_USER_DEFAULT, ROLE_USER
        AuthRegister = ""
    End If
End Function
%>
