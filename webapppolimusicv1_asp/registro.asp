<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  registro.asp  -  Enrolamiento de nuevos usuarios.
'  Todo usuario registrado desde aqui obtiene el rol normal.
' =====================================================================
%>
<!--#include file="includes/bootstrap.asp"-->
<%
Dim username, password, confirm, email, errorMsg, okMsg

If AuthIsLogged() Then Response.Redirect "canciones.asp"

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    username = Trim(Request.Form("username"))
    password = Request.Form("password")
    confirm  = Request.Form("confirm")
    email    = Trim(Request.Form("email"))

    errorMsg = AuthRegister(username, password, confirm, email)
    If Len(errorMsg) = 0 Then
        okMsg = "Cuenta creada correctamente. Ya puedes iniciar sesion."
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registro &middot; <%=APP_NAME%></title>
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
        <p class="auth-tag">Crea tu cuenta para empezar a escuchar.</p>

        <%=AlertHtml(errorMsg, "error")%>
        <%=AlertHtml(okMsg, "ok")%>

        <% If Len(okMsg) = 0 Then %>
        <form method="post" action="registro.asp" autocomplete="off">
            <div class="field">
                <label for="username">Usuario</label>
                <input type="text" id="username" name="username" required minlength="3" maxlength="50"
                       value="<%=AttrEncode(Request.Form("username"))%>">
            </div>
            <div class="field">
                <label for="email">Correo electronico</label>
                <input type="email" id="email" name="email" required maxlength="50"
                       value="<%=AttrEncode(Request.Form("email"))%>">
            </div>
            <div class="field">
                <label for="password">Contrasena</label>
                <input type="password" id="password" name="password" required minlength="6" maxlength="50">
                <span class="hint">Minimo 6 caracteres.</span>
            </div>
            <div class="field">
                <label for="confirm">Confirmar contrasena</label>
                <input type="password" id="confirm" name="confirm" required minlength="6" maxlength="50">
            </div>
            <button class="btn btn-primary" type="submit">Crear cuenta</button>
        </form>
        <% Else %>
        <a class="btn btn-primary" href="login.asp" style="width:100%;justify-content:center">Ir a iniciar sesion</a>
        <% End If %>

        <p class="auth-alt">Ya tienes cuenta? <a href="login.asp">Inicia sesion</a></p>
    </div>
</div>
</body>
</html>
