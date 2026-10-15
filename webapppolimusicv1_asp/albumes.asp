<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  albumes.asp  -  Consulta de albumes (disponible para ambos roles).
' =====================================================================
%>
<!--#include virtual="/includes/bootstrap.asp"-->
<%
RequireLogin

Dim RootPath : RootPath = ""
Dim albums, alb, PageTitle, ActiveMenu
Set albums = CatalogAlbumsForView()
PageTitle  = "Albumes"
ActiveMenu = "albumes"
%>
<!--#include virtual="/includes/header.asp"-->
<div class="page-head">
    <div>
        <h1>Albumes</h1>
        <p class="page-sub">Consulta de albumes registrados en el catalogo.</p>
    </div>
    <% If AuthIsAdmin() Then %>
    <a class="btn btn-primary" href="admin/albumes.asp?action=new">Nuevo album</a>
    <% End If %>
</div>

<% If albums.Count = 0 Then %>
<div class="card empty"><h2>No hay albumes registrados</h2></div>
<% Else %>
<div class="grid-cards">
    <% For Each alb In albums.Items %>
    <div class="tile">
        <img src="<%=alb("ImageUrl")%>" alt="Portada de <%=AttrEncode(alb("Title"))%>">
        <div class="t-name"><%=HtmlEncode(alb("Title"))%></div>
        <div class="t-meta">Anio: <%=alb("ReleaseYear")%></div>
    </div>
    <% Next %>
</div>
<% End If %>

<!--#include virtual="/includes/footer.asp"-->
