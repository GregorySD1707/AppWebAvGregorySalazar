<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/albumes.asp  -  CRUD de Albumes (solo administrador).
' =====================================================================
%>
<!--#include virtual="/includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Albumes"
AdminMenu = "albumes"

Dim msg, msgType, action
Dim id, title, releaseYear, imagePath
msg = "" : msgType = "ok"
action = LCase(Trim(Request.QueryString("action")))

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action      = LCase(Trim(Request.Form("action")))
    id          = ToLong(Request.Form("id"), 0)
    title       = Trim(Request.Form("title"))
    releaseYear = ToLong(Request.Form("year"), 0)
    imagePath   = Trim(Request.Form("image"))

    If action = "delete" Then
        AlbumDelete id
        msg = "Album eliminado."

    ElseIf action = "save" Then
        If Len(title) = 0 Then
            msg = "El titulo del album es obligatorio." : msgType = "error"
        ElseIf id = 0 Then
            AlbumCreate title, releaseYear, imagePath
            msg = "Album creado correctamente."
        Else
            AlbumUpdate id, title, releaseYear, imagePath
            msg = "Album actualizado."
        End If
    End If
End If

Dim showForm, editAlbum, editId, isEditing
showForm  = (action = "new")
isEditing = False
editId    = ToLong(Request.QueryString("edit"), 0)
Set editAlbum = Nothing
If editId > 0 Then
    Set editAlbum = AlbumFindById(editId)
    If Not editAlbum Is Nothing Then showForm = True : isEditing = True
End If

Dim albums, alb
Set albums = CatalogAlbumsForView()
%>
<!--#include virtual="/includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Albumes</h1>
        <p class="page-sub">Alta, edicion y baja de albumes del catalogo.</p>
    </div>
    <a class="btn btn-primary" href="albumes.asp?action=new">Nuevo album</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar album", "Nuevo album")%></h2>
    <form method="post" action="albumes.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=ValOr(editAlbum, "Id", 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="title">Titulo</label>
                <input type="text" id="title" name="title" required maxlength="50"
                       value="<%=ValOrEnc(editAlbum, "Title", "")%>">
            </div>
            <div class="field">
                <label for="year">Anio de lanzamiento</label>
                <input type="number" id="year" name="year" min="1900" max="2100"
                       value="<%=ValOr(editAlbum, "ReleaseYear", Year(Date))%>">
            </div>
            <div class="field full">
                <label for="image">Imagen de portada (ruta)</label>
                <input type="text" id="image" name="image" maxlength="255" placeholder="~/albumImages/album1.png"
                       value="<%=ValOrEnc(editAlbum, "ImagePath", "")%>">
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:8px">
            <button class="btn btn-primary" type="submit">Guardar</button>
            <a class="btn btn-ghost" href="albumes.asp">Cancelar</a>
        </div>
    </form>
</div>
<% End If %>

<div class="table-wrap">
    <table class="data">
        <thead>
            <tr>
                <th style="width:52px">ID</th>
                <th style="width:60px">Portada</th>
                <th>Titulo</th>
                <th style="width:130px">Anio</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If albums.Count = 0 Then %>
            <tr><td colspan="5" style="text-align:center;padding:24px;color:var(--ink-500)">Sin registros.</td></tr>
        <% Else %>
            <% For Each alb In albums.Items %>
            <tr>
                <td><%=alb("Id")%></td>
                <td><img class="mini-cover" src="<%=alb("ImageUrl")%>" alt=""></td>
                <td><span class="song-name"><%=HtmlEncode(alb("Title"))%></span></td>
                <td><%=alb("ReleaseYear")%></td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="albumes.asp?edit=<%=alb("Id")%>">Editar</a>
                        <form method="post" action="albumes.asp"
                              onsubmit="return confirm('Eliminar el album &quot;<%=JsEncode(alb("Title"))%>&quot;?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%=alb("Id")%>">
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

<!--#include virtual="/includes/footer.asp"-->
