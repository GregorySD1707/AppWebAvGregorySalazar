<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  artistas.asp  -  Consulta de artistas (disponible para ambos roles).
' =====================================================================
%>
<!--#include file="includes/bootstrap.asp"-->
<%
RequireLogin

Dim RootPath : RootPath = ""
Dim artists, ar, PageTitle, ActiveMenu
Set artists = CatalogArtistsForView()
PageTitle  = "Artistas"
ActiveMenu = "artistas"
%>
<!--#include file="includes/header.asp"-->
<div class="page-head">
    <div>
        <h1>Artistas</h1>
        <p class="page-sub">Consulta de artistas registrados en el catalogo.</p>
    </div>
    <% If AuthIsAdmin() Then %>
    <a class="btn btn-primary" href="admin/artistas.asp?action=new">Nuevo artista</a>
    <% End If %>
</div>

<% If artists.Count = 0 Then %>
<div class="card empty"><h2>No hay artistas registrados</h2></div>
<% Else %>
<div class="grid-cards">
    <% For Each ar In artists.Items %>
    <div class="tile">
        <img src="<%=ar("ImageUrl")%>" alt="<%=AttrEncode(ar("Name"))%>">
        <div class="t-name"><%=HtmlEncode(ar("Name"))%> <%=HtmlEncode(ar("Lastname"))%></div>
    </div>
    <% Next %>
</div>
<% End If %>

<!--#include file="includes/footer.asp"-->
