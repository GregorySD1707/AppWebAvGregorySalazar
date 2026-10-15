<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  login.asp  -  Pantalla de inicio de sesion.
'  Al validar, almacena en Session el nombre y rol del usuario.
'  La pantalla principal (canciones.asp) lee ese nombre para el saludo.
' =====================================================================
%>
<!--#include virtual="/includes/bootstrap.asp"-->
<%
Dim username, password, errorMsg, okMsg

If AuthIsLogged() Then Response.Redirect "canciones.asp"

' Si venimos de una redireccion por sesion expirada, avisamos.
If Request.QueryString("msg") = "session" Then
    errorMsg = "Tu sesion expiro. Inicia sesion nuevamente."
End If
If Request.QueryString("msg") = "logout" Then
    okMsg = "Sesion cerrada correctamente."
End If

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    username = Trim(Request.Form("username"))
    password = Request.Form("password")

    If AuthLogin(username, password) Then
        Response.Redirect "canciones.asp"
    Else
        errorMsg = "Usuario o contrasena incorrectos."
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesion &middot; <%=APP_NAME%></title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="auth-brand">
            <span class="brand-mark">
                <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path d="M9 18V6l10-2v12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <circle cx="6.5" cy="18" r="2.5" stroke="currentColor" stroke-width="2"/>
                    <circle cx="16.5" cy="16" r="2.5" stroke="currentColor" stroke-width="2"/>
                </svg>
            </span>
            <%=APP_NAME%>
        </div>
        <p class="auth-tag">Tu musica, en azul.</p>

        <%=AlertHtml(errorMsg, "error")%>
        <%=AlertHtml(okMsg, "ok")%>

        <div class="credentials">
            <b>Usuarios de prueba</b><br>
            Admin: <b>userAdmin</b> / 12345678<br>
            Normal: <b>userNormal</b> / 12345678
        </div>

        <form method="post" action="login.asp" autocomplete="off">
            <div class="field">
                <label for="username">Usuario</label>
                <input type="text" id="username" name="username" required maxlength="50" autofocus
                       value="<%=AttrEncode(Request.Form("username"))%>">
            </div>
            <div class="field">
                <label for="password">Contrasena</label>
                <input type="password" id="password" name="password" required maxlength="50">
            </div>
            <button class="btn btn-primary" type="submit">Iniciar sesion</button>
        </form>

        <p class="auth-alt">No tienes cuenta? <a href="registro.asp">Registrate aqui</a></p>
    </div>
</div>
</body>
</html>
