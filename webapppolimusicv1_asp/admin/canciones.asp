<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/canciones.asp  -  CRUD de Canciones (solo administrador).
'  Administra tambien las relaciones TBL_PLAYER y TBL_TRACKLIST.
' =====================================================================
%>
<!--#include file="../includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Canciones"
AdminMenu = "canciones"

Dim msg, msgType, action
Dim id, songName, songPath, plays, artistId, albumId
msg = "" : msgType = "ok"
action = LCase(Trim(Request.QueryString("action")))

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action   = LCase(Trim(Request.Form("action")))
    id       = ToLong(Request.Form("id"), 0)
    songName = Trim(Request.Form("name"))
    songPath = Trim(Request.Form("path"))
    plays    = ToLong(Request.Form("plays"), 0)
    artistId = ToLong(Request.Form("artist"), 0)
    albumId  = ToLong(Request.Form("album"), 0)

    If action = "delete" Then
        SongDelete id
        msg = "Cancion eliminada."

    ElseIf action = "save" Then
        If Len(songName) = 0 Or Len(songPath) = 0 Then
            msg = "El nombre y la ruta del archivo son obligatorios." : msgType = "error"
        ElseIf id = 0 Then
            SongCreate songName, songPath, plays, artistId, albumId
            msg = "Cancion creada correctamente."
        Else
            SongUpdate id, songName, songPath, plays, artistId, albumId
            msg = "Cancion actualizada."
        End If
    End If
End If

Dim showForm, editSong, editId, isEditing, editArtistId, editAlbumId
showForm  = (action = "new")
isEditing = False
editId    = ToLong(Request.QueryString("edit"), 0)
editArtistId = 0 : editAlbumId = 0
Set editSong = Nothing
If editId > 0 Then
    Set editSong = SongFindById(editId)
    If Not editSong Is Nothing Then
        showForm = True : isEditing = True
        editArtistId = SongArtistId(editId)
        editAlbumId  = SongAlbumId(editId)
    End If
End If

Dim songs, s
Set songs = CatalogSongsForView()
%>
<!--#include file="../includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Canciones</h1>
        <p class="page-sub">Alta, edicion y baja de canciones del catalogo.</p>
    </div>
    <a class="btn btn-primary" href="canciones.asp?action=new">Nueva cancion</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar cancion", "Nueva cancion")%></h2>
    <form method="post" action="canciones.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=ValOr(editSong, "Id", 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="name">Nombre de la cancion</label>
                <input type="text" id="name" name="name" required maxlength="50"
                       value="<%=ValOrEnc(editSong, "Name", "")%>">
            </div>
            <div class="field">
                <label for="plays">Reproducciones</label>
                <input type="number" id="plays" name="plays" min="0" value="<%=ValOr(editSong, "Plays", 0)%>">
            </div>
            <div class="field full">
                <label for="path">Ruta del archivo de audio</label>
                <input type="text" id="path" name="path" required maxlength="255"
                       placeholder="~/songFiles/bensound-adventure.mp3"
                       value="<%=ValOrEnc(editSong, "Path", "")%>">
                <span class="hint">El reproductor resuelve automaticamente la carpeta assets de la aplicacion.</span>
            </div>
            <div class="field">
                <label for="artist">Artista</label>
                <select id="artist" name="artist"><%=CatalogArtistOptions(editArtistId)%></select>
            </div>
            <div class="field">
                <label for="album">Album</label>
                <select id="album" name="album"><%=CatalogAlbumOptions(editAlbumId)%></select>
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:8px">
            <button class="btn btn-primary" type="submit">Guardar</button>
            <a class="btn btn-ghost" href="canciones.asp">Cancelar</a>
        </div>
    </form>
</div>
<% End If %>

<div class="table-wrap">
    <table class="data">
        <thead>
            <tr>
                <th style="width:52px">ID</th>
                <th>Cancion</th>
                <th>Artista</th>
                <th>Album</th>
                <th style="width:90px">Plays</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If songs.Count = 0 Then %>
            <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--ink-500)">Sin registros.</td></tr>
        <% Else %>
            <% For Each s In songs.Items %>
            <tr>
                <td><%=s("Id")%></td>
                <td><span class="song-name"><%=HtmlEncode(s("Name"))%></span></td>
                <td><%=IIf(Len(s("Artist")&"")>0, HtmlEncode(s("Artist")), "&mdash;")%></td>
                <td><%=IIf(Len(s("Album")&"")>0, HtmlEncode(s("Album")), "&mdash;")%></td>
                <td><%=s("Plays")%></td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="canciones.asp?edit=<%=s("Id")%>">Editar</a>
                        <form method="post" action="canciones.asp"
                              onsubmit="return confirm('Eliminar la cancion &quot;<%=JsEncode(s("Name"))%>&quot;?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%=s("Id")%>">
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
