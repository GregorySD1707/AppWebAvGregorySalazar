<%
' =====================================================================
'  adminHeader.asp  -  Cabecera de la seccion de administracion.
'  Reutiliza la cabecera general y agrega la navegacion del CRUD.
'  Recibe: PageTitle, AdminMenu
' =====================================================================
%>
<!--#include file="../includes/header.asp"-->
<div class="admin-nav">
    <a href="<%=RootPath%>admin/index.asp"      class="<%=IIf(AdminMenu="inicio","is-active","")%>">Inicio</a>
    <a href="<%=RootPath%>admin/usuarios.asp"   class="<%=IIf(AdminMenu="usuarios","is-active","")%>">Usuarios</a>
    <a href="<%=RootPath%>admin/canciones.asp"  class="<%=IIf(AdminMenu="canciones","is-active","")%>">Canciones</a>
    <a href="<%=RootPath%>admin/artistas.asp"   class="<%=IIf(AdminMenu="artistas","is-active","")%>">Artistas</a>
    <a href="<%=RootPath%>admin/albumes.asp"    class="<%=IIf(AdminMenu="albumes","is-active","")%>">Albumes</a>
    <a href="<%=RootPath%>admin/playlists.asp"  class="<%=IIf(AdminMenu="playlists","is-active","")%>">Playlists</a>
</div>
