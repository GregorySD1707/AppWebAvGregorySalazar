<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  playlists.asp  -  Playlists del usuario.
'
'  Regla de negocio (segun el enunciado):
'    - Admin     : administra TODAS las playlists.
'    - Usuario   : administra UNICAMENTE las suyas (puede crear,
'                  actualizar y eliminar sus propias playlists).
' =====================================================================
%>
<!--#include file="includes/bootstrap.asp"-->
<%
RequireLogin

Dim RootPath : RootPath = ""
Dim playlists, pl, PageTitle, ActiveMenu
Dim msg, msgType, action, plId, title, plType, photo, target

action = LCase(Trim(Request.QueryString("action")))
msg = "" : msgType = "ok"

' ----------------------------- Acciones -----------------------------
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action = LCase(Trim(Request.Form("action")))

    If action = "delete" Then
        plId   = ToLong(Request.Form("id"), 0)
        Set pl = PlaylistFindById(plId)
        If CatalogCanEditPlaylist(pl, AuthUserId(), AuthIsAdmin()) Then
            PlaylistDelete plId
            msg = "Playlist eliminada."
        Else
            msg = "No tienes permiso para eliminar esa playlist." : msgType = "error"
        End If

    ElseIf action = "save" Then
        plId   = ToLong(Request.Form("id"), 0)
        title  = Trim(Request.Form("title"))
        plType = ToLong(Request.Form("type"), 0)
        photo  = Trim(Request.Form("photo"))
        If Len(photo) = 0 Then photo = "~/playlistImages/default.jpg"

        If Len(title) = 0 Then
            msg = "El titulo es obligatorio." : msgType = "error"
        ElseIf plId = 0 Then
            PlaylistCreate AuthUserId(), title, plType, photo
            msg = "Playlist creada correctamente."
        Else
            Set pl = PlaylistFindById(plId)
            If CatalogCanEditPlaylist(pl, AuthUserId(), AuthIsAdmin()) Then
                PlaylistUpdate plId, title, plType, photo
                msg = "Playlist actualizada."
            Else
                msg = "No tienes permiso para modificar esa playlist." : msgType = "error"
            End If
        End If
    End If
End If

' Playlist a editar (si viene ?edit=)
Dim editId, editPl, isEditing
editId = ToLong(Request.QueryString("edit"), 0)
isEditing = False
Set editPl = Nothing
If editId > 0 Then
    Set editPl = PlaylistFindById(editId)
    If CatalogCanEditPlaylist(editPl, AuthUserId(), AuthIsAdmin()) Then
        isEditing = True
    Else
        msg = "No tienes permiso para editar esa playlist." : msgType = "error"
        Set editPl = Nothing
    End If
End If

' Si se pidio crear, mostramos el formulario vacio.
Dim showForm
showForm = (action = "new") Or isEditing

Set playlists = CatalogPlaylistsForView(AuthUserId(), AuthIsAdmin())
PageTitle  = "Playlists"
ActiveMenu = "playlists"
%>
<!--#include file="includes/header.asp"-->
<div class="page-head">
    <div>
        <h1>Mis Playlists</h1>
        <p class="page-sub">
            <%=IIf(AuthIsAdmin(), "Vista de administrador: todas las playlists del sistema.", "Puedes crear, editar y eliminar tus propias playlists.")%>
        </p>
    </div>
    <a class="btn btn-primary" href="playlists.asp?action=new">Nueva playlist</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar playlist", "Nueva playlist")%></h2>
    <form method="post" action="playlists.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=IIf(isEditing, editPl("Id"), 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="title">Titulo</label>
                <input type="text" id="title" name="title" required maxlength="50"
                       value="<%=IIf(isEditing, AttrEncode(editPl("Title")), "")%>">
            </div>
            <div class="field">
                <label for="type">Visibilidad</label>
                <select id="type" name="type">
                    <option value="<%=PLAYLIST_PUBLIC%>"  <%=IIf(isEditing And CLng(editPl("Type"))=PLAYLIST_PUBLIC, "selected", "")%>>Publica</option>
                    <option value="<%=PLAYLIST_PRIVATE%>" <%=IIf(isEditing And CLng(editPl("Type"))=PLAYLIST_PRIVATE,"selected", "")%>>Privada</option>
                </select>
            </div>
            <div class="field full">
                <label for="photo">Ruta de imagen (opcional)</label>
                <input type="text" id="photo" name="photo" maxlength="255"
                       placeholder="~/playlistImages/default.jpg"
                       value="<%=IIf(isEditing, AttrEncode(editPl("Photo")), "")%>">
                <span class="hint">Si lo dejas vacio se usara la imagen por defecto.</span>
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
                <th style="width:60px">Foto</th>
                <th>Titulo</th>
                <th style="width:120px">Visibilidad</th>
                <th style="width:90px">Canciones</th>
                <th style="width:130px">Creada</th>
                <th style="width:160px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If playlists.Count = 0 Then %>
            <tr><td colspan="6" style="text-align:center;color:var(--ink-500);padding:26px">
                No hay playlists para mostrar.
            </td></tr>
        <% Else %>
            <% For Each pl In playlists.Items %>
            <tr>
                <td><img class="mini-cover" src="<%=pl("PhotoUrl")%>" alt=""></td>
                <td><span class="song-name"><%=HtmlEncode(pl("Title"))%></span></td>
                <td><%=HtmlEncode(pl("TypeName"))%></td>
                <td><%=pl("SongCount")%></td>
                <td><%=FormatDateTime(pl("CreationDate"), 2)%></td>
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

<!--#include file="includes/footer.asp"-->
