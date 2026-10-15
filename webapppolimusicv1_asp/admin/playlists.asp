<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/playlists.asp  -  CRUD de Playlists (solo administrador).
'  El administrador ve y administra las playlists de TODOS los usuarios.
' =====================================================================
%>
<!--#include virtual="/includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Playlists"
AdminMenu = "playlists"

Dim msg, msgType, action
Dim id, title, plType, photo, ownerId
msg = "" : msgType = "ok"
action = LCase(Trim(Request.QueryString("action")))

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action  = LCase(Trim(Request.Form("action")))
    id      = ToLong(Request.Form("id"), 0)
    title   = Trim(Request.Form("title"))
    plType  = ToLong(Request.Form("type"), 0)
    photo   = Trim(Request.Form("photo"))
    ownerId = ToLong(Request.Form("owner"), 0)

    If action = "delete" Then
        PlaylistDelete id
        msg = "Playlist eliminada."

    ElseIf action = "save" Then
        If Len(title) = 0 Then
            msg = "El titulo es obligatorio." : msgType = "error"
        ElseIf Len(photo) = 0 Then
            photo = "~/playlistImages/default.jpg"
        End If

        If Len(msg) = 0 Then
            If id = 0 Then
                If ownerId = 0 Then ownerId = AuthUserId()
                PlaylistCreate ownerId, title, plType, photo
                msg = "Playlist creada correctamente."
            Else
                PlaylistUpdate id, title, plType, photo
                msg = "Playlist actualizada."
            End If
        End If
    End If
End If

Dim showForm, editPl, editId, isEditing
showForm  = (action = "new")
isEditing = False
editId    = ToLong(Request.QueryString("edit"), 0)
Set editPl = Nothing
If editId > 0 Then
    Set editPl = PlaylistFindById(editId)
    If Not editPl Is Nothing Then showForm = True : isEditing = True
End If

Dim playlists, pl, users, u
Set playlists = CatalogPlaylistsForView(AuthUserId(), True)
Set users     = UserListAll()
%>
<!--#include virtual="/includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Playlists</h1>
        <p class="page-sub">Administracion de playlists de todos los usuarios.</p>
    </div>
    <a class="btn btn-primary" href="playlists.asp?action=new">Nueva playlist</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar playlist", "Nueva playlist")%></h2>
    <form method="post" action="playlists.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=ValOr(editPl, "Id", 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="title">Titulo</label>
                <input type="text" id="title" name="title" required maxlength="50"
                       value="<%=ValOrEnc(editPl, "Title", "")%>">
            </div>
            <div class="field">
                <label for="type">Visibilidad</label>
                <select id="type" name="type">
                    <option value="<%=PLAYLIST_PUBLIC%>"  <%=SelIf(editPl, "Type", PLAYLIST_PUBLIC)%>>Publica</option>
                    <option value="<%=PLAYLIST_PRIVATE%>" <%=SelIf(editPl, "Type", PLAYLIST_PRIVATE)%>>Privada</option>
                </select>
            </div>
            <% If Not isEditing Then %>
            <div class="field">
                <label for="owner">Propietario</label>
                <select id="owner" name="owner">
                    <% For Each u In users.Items %>
                    <option value="<%=u("Id")%>"><%=HtmlEncode(u("Username"))%></option>
                    <% Next %>
                </select>
            </div>
            <% End If %>
            <div class="field full">
                <label for="photo">Imagen (ruta)</label>
                <input type="text" id="photo" name="photo" maxlength="255" placeholder="~/playlistImages/default.jpg"
                       value="<%=ValOrEnc(editPl, "Photo", "")%>">
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:8px">
            <button class="btn btn-primary" type="submit">Guardar</button>
            <a class="btn btn-ghost" href="playlists.asp">Cancelar</a>
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
                <th>Titulo</th>
                <th style="width:110px">Visibilidad</th>
                <th style="width:90px">Canciones</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If playlists.Count = 0 Then %>
            <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--ink-500)">Sin registros.</td></tr>
        <% Else %>
            <% For Each pl In playlists.Items %>
            <tr>
                <td><%=pl("Id")%></td>
                <td><img class="mini-cover" src="<%=pl("PhotoUrl")%>" alt=""></td>
                <td><span class="song-name"><%=HtmlEncode(pl("Title"))%></span></td>
                <td><%=HtmlEncode(pl("TypeName"))%></td>
                <td><%=pl("SongCount")%></td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="playlists.asp?edit=<%=pl("Id")%>">Editar</a>
                        <form method="post" action="playlists.asp"
                              onsubmit="return confirm('Eliminar la playlist &quot;<%=JsEncode(pl("Title"))%>&quot;?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%=pl("Id")%>">
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
