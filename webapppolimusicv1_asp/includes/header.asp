<%
' =====================================================================
'  header.asp  -  Cabecera compartida (nav + mensaje de bienvenida).
'  Recibe:  PageTitle     (titulo de la pestana)
'           ActiveMenu    ("canciones" | "albumes" | "artistas" | "playlists")
'  Usa:     mensaje de bienvenida con el nombre del usuario en sesion.
' =====================================================================
Dim curWelcomeName, curIsAdmin, curActive
curWelcomeName = AuthUsername()
curIsAdmin  = AuthIsAdmin()
If IsEmpty(ActiveMenu) Then ActiveMenu = "canciones"
curActive = ActiveMenu
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%=HtmlEncode(PageTitle)%> &middot; <%=APP_NAME%></title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
<header class="topbar">
    <a class="brand" href="<%=RootPath%>canciones.asp">
        <span class="brand-mark">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M9 18V6l10-2v12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <circle cx="6.5" cy="18" r="2.5" stroke="currentColor" stroke-width="2"/>
                <circle cx="16.5" cy="16" r="2.5" stroke="currentColor" stroke-width="2"/>
            </svg>
        </span>
        <span class="brand-text"><%=APP_NAME%></span>
    </a>

    <nav class="mainnav">
        <a href="<%=RootPath%>canciones.asp" class="<%=IIf(curActive="canciones","is-active","")%>">Canciones</a>
        <a href="<%=RootPath%>albumes.asp"   class="<%=IIf(curActive="albumes","is-active","")%>">Albumes</a>
        <a href="<%=RootPath%>artistas.asp"  class="<%=IIf(curActive="artistas","is-active","")%>">Artistas</a>
        <a href="<%=RootPath%>playlists.asp" class="<%=IIf(curActive="playlists","is-active","")%>">Playlists</a>
        <% If curIsAdmin Then %>
        <a href="<%=RootPath%>admin/index.asp" class="<%=IIf(curActive="admin","is-active","")%>">Administracion</a>
        <% End If %>
    </nav>

    <div class="userbox">
        <img class="avatar" src="<%=ResolveAssetPath(Session(SESSION_USER_PHOTO), IMG_USER_DEFAULT)%>" alt="Foto de perfil">
        <div class="userinfo">
            <span class="hello">Bienvenido,</span>
            <span class="uname"><%=HtmlEncode(curWelcomeName)%></span>
            <span class="badge <%=IIf(curIsAdmin,"badge-admin","badge-user")%>"><%=IIf(curIsAdmin,"Administrador","Usuario")%></span>
        </div>
        <a class="btn-logout" href="<%=RootPath%>logout.asp" title="Cerrar sesion">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M15 17l5-5-5-5M20 12H9M12 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h6"
                      stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Salir
        </a>
    </div>
</header>
<main class="page">
