<%
' =====================================================================
'  CatalogService.asp  -  Reglas de negocio del catalogo.
'  Prepara los datos listos para la vista (roles, rutas resueltas).
' =====================================================================

' Lista de canciones lista para pintar en la tabla principal.
' Cada elemento agrega: Url (ruta web del mp3) y IsPlayable.
Function CatalogSongsForView()
    Dim src, list, key, song, resolved
    Set src  = SongListAll()
    Set list = Server.CreateObject("Scripting.Dictionary")

    For Each key In src.Keys
        Set song = src(key)
        resolved = ResolveAssetPath(song("Path"), "")
        song("Url")        = resolved
        song("IsPlayable") = (Len(resolved) > 0)
        list.Add key, song
    Next
    Set CatalogSongsForView = list
End Function

Function CatalogAlbumsForView()
    Dim src, list, key, alb
    Set src  = AlbumListAll()
    Set list = Server.CreateObject("Scripting.Dictionary")
    For Each key In src.Keys
        Set alb = src(key)
        alb("ImageUrl") = ResolveAssetPath(alb("ImagePath"), IMG_ALBUM_DEFAULT)
        list.Add key, alb
    Next
    Set CatalogAlbumsForView = list
End Function

Function CatalogArtistsForView()
    Dim src, list, key, ar
    Set src  = ArtistListAll()
    Set list = Server.CreateObject("Scripting.Dictionary")
    For Each key In src.Keys
        Set ar = src(key)
        ar("ImageUrl") = ResolveAssetPath(ar("ImagePath"), IMG_ARTIST_DEFAULT)
        list.Add key, ar
    Next
    Set CatalogArtistsForView = list
End Function

' --- Playlists ------------------------------------------------------
' Un administrador ve y administra todas; un usuario normal solo las suyas.
Function CatalogPlaylistsForView(userId, isAdmin)
    Dim src, list, key, pl
    If isAdmin Then
        Set src = PlaylistListByUser(0)
    Else
        Set src = PlaylistListByUser(userId)
    End If

    Set list = Server.CreateObject("Scripting.Dictionary")
    For Each key In src.Keys
        Set pl = src(key)
        pl("PhotoUrl") = ResolveAssetPath(pl("Photo"), IMG_PLAYLIST_DEFAULT)
        pl("TypeName") = IIf(CLng(pl("Type")) = PLAYLIST_PRIVATE, "Privada", "Publica")
        pl("SongCount") = ToLong(DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(pl("Id"))), 0)
        list.Add key, pl
    Next
    Set CatalogPlaylistsForView = list
End Function

' Regla de autorizacion de playlist: el dueno o un admin.
Function CatalogCanEditPlaylist(playlist, userId, isAdmin)
    CatalogCanEditPlaylist = False
    If playlist Is Nothing Then Exit Function
    If isAdmin Then
        CatalogCanEditPlaylist = True
    ElseIf CLng(playlist("UserId")) = CLng(userId) Then
        CatalogCanEditPlaylist = True
    End If
End Function

' --- Opciones para los <select> de los formularios ------------------
Function CatalogAlbumOptions(selectedId)
    Dim src, key, alb, html
    Set src = AlbumListAll()
    html = "<option value='0'>&mdash; Sin album &mdash;</option>"
    For Each key In src.Keys
        Set alb = src(key)
        html = html & "<option value='" & alb("Id") & "'"
        If CLng(selectedId) = CLng(alb("Id")) Then html = html & " selected"
        html = html & ">" & HtmlEncode(alb("Title")) & "</option>"
    Next
    CatalogAlbumOptions = html
End Function

Function CatalogArtistOptions(selectedId)
    Dim src, key, ar, html
    Set src = ArtistListAll()
    html = "<option value='0'>&mdash; Sin artista &mdash;</option>"
    For Each key In src.Keys
        Set ar = src(key)
        html = html & "<option value='" & ar("Id") & "'"
        If CLng(selectedId) = CLng(ar("Id")) Then html = html & " selected"
        html = html & ">" & HtmlEncode(ar("Name") & " " & ar("Lastname")) & "</option>"
    Next
    CatalogArtistOptions = html
End Function

' --- Mensajes de exito/error compartidos ---------------------------
Function AlertHtml(message, alertType)
    Dim cls
    If Len(message) = 0 Then AlertHtml = "" : Exit Function
    cls = "alert-info"
    If alertType = "ok"    Then cls = "alert-ok"
    If alertType = "error" Then cls = "alert-error"
    AlertHtml = "<div class='alert " & cls & "'>" & HtmlEncode(message) & "</div>"
End Function
%>
