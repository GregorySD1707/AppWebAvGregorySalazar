<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/artistas.asp  -  CRUD de Artistas (solo administrador).
' =====================================================================
%>
<!--#include file="../includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Artistas"
AdminMenu = "artistas"

Dim msg, msgType, action
Dim id, artistName, lastname, imagePath
msg = "" : msgType = "ok"
action = LCase(Trim(Request.QueryString("action")))

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action     = LCase(Trim(Request.Form("action")))
    id         = ToLong(Request.Form("id"), 0)
    artistName = Trim(Request.Form("name"))
    lastname   = Trim(Request.Form("lastname"))
    imagePath  = Trim(Request.Form("image"))

    If action = "delete" Then
        ArtistDelete id
        msg = "Artista eliminado."

    ElseIf action = "save" Then
        If Len(artistName) = 0 Then
            msg = "El nombre del artista es obligatorio." : msgType = "error"
        ElseIf id = 0 Then
            ArtistCreate artistName, lastname, imagePath
            msg = "Artista creado correctamente."
        Else
            ArtistUpdate id, artistName, lastname, imagePath
            msg = "Artista actualizado."
        End If
    End If
End If

Dim showForm, editArtist, editId, isEditing
showForm  = (action = "new")
isEditing = False
editId    = ToLong(Request.QueryString("edit"), 0)
Set editArtist = Nothing
If editId > 0 Then
    Set editArtist = ArtistFindById(editId)
    If Not editArtist Is Nothing Then showForm = True : isEditing = True
End If

Dim artists, ar
Set artists = CatalogArtistsForView()
%>
<!--#include file="../includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Artistas</h1>
        <p class="page-sub">Alta, edicion y baja de artistas del catalogo.</p>
    </div>
    <a class="btn btn-primary" href="artistas.asp?action=new">Nuevo artista</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar artista", "Nuevo artista")%></h2>
    <form method="post" action="artistas.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=ValOr(editArtist, "Id", 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="name">Nombre</label>
                <input type="text" id="name" name="name" required maxlength="100"
                       value="<%=ValOrEnc(editArtist, "Name", "")%>">
            </div>
            <div class="field">
                <label for="lastname">Apellido</label>
                <input type="text" id="lastname" name="lastname" maxlength="100"
                       value="<%=ValOrEnc(editArtist, "Lastname", "")%>">
            </div>
            <div class="field full">
                <label for="image">Imagen (ruta)</label>
                <input type="text" id="image" name="image" maxlength="255" placeholder="~/ArtistImages/artist1.jpg"
                       value="<%=ValOrEnc(editArtist, "ImagePath", "")%>">
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:8px">
            <button class="btn btn-primary" type="submit">Guardar</button>
            <a class="btn btn-ghost" href="artistas.asp">Cancelar</a>
        </div>
    </form>
</div>
<% End If %>

<div class="table-wrap">
    <table class="data">
        <thead>
            <tr>
                <th style="width:52px">ID</th>
                <th style="width:60px">Foto</th>
                <th>Artista</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If artists.Count = 0 Then %>
            <tr><td colspan="4" style="text-align:center;padding:24px;color:var(--ink-500)">Sin registros.</td></tr>
        <% Else %>
            <% For Each ar In artists.Items %>
            <tr>
                <td><%=ar("Id")%></td>
                <td><img class="mini-cover" src="<%=ar("ImageUrl")%>" alt=""></td>
                <td><span class="song-name"><%=HtmlEncode(ar("Name"))%> <%=HtmlEncode(ar("Lastname"))%></span></td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="artistas.asp?edit=<%=ar("Id")%>">Editar</a>
                        <form method="post" action="artistas.asp"
                              onsubmit="return confirm('Eliminar el artista &quot;<%=JsEncode(ar("Name"))%>&quot;?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%=ar("Id")%>">
                            <button class="btn btn-danger btn-sm" type="submit">Eliminar</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% Next %>
        <% End If %>
        </tbody>
    </table>
</div>

<!--#include file="../includes/footer.asp"-->
