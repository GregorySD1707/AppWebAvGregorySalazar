<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/index.asp  -  Panel de administracion (solo rol admin).
' =====================================================================
%>
<!--#include file="../includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Administracion"
AdminMenu = "inicio"

Dim cUsers, cSongs, cArtists, cAlbums, cPlaylists
cUsers     = DbScalar("SELECT COUNT(*) FROM TBL_USER", Empty)
cSongs     = DbScalar("SELECT COUNT(*) FROM TBL_SONG", Empty)
cArtists   = DbScalar("SELECT COUNT(*) FROM TBL_ARTIST", Empty)
cAlbums    = DbScalar("SELECT COUNT(*) FROM TBL_ALBUM", Empty)
cPlaylists = DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST", Empty)
%>
<!--#include file="../includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Panel de administracion</h1>
        <p class="page-sub">Gestion completa del catalogo (CRUD) disponible solo para el rol administrador.</p>
    </div>
</div>

<div class="grid-cards">
    <a class="tile" href="usuarios.asp" style="color:inherit">
        <h2><%=cUsers%></h2><div class="t-meta">Usuarios</div>
    </a>
    <a class="tile" href="canciones.asp" style="color:inherit">
        <h2><%=cSongs%></h2><div class="t-meta">Canciones</div>
    </a>
    <a class="tile" href="artistas.asp" style="color:inherit">
        <h2><%=cArtists%></h2><div class="t-meta">Artistas</div>
    </a>
    <a class="tile" href="albumes.asp" style="color:inherit">
        <h2><%=cAlbums%></h2><div class="t-meta">Albumes</div>
    </a>
    <a class="tile" href="playlists.asp" style="color:inherit">
        <h2><%=cPlaylists%></h2><div class="t-meta">Playlists</div>
    </a>
</div>

<!--#include file="../includes/footer.asp"-->
