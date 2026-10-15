<%
' =====================================================================
'  PlaylistRepository.asp  -  Acceso a datos de TBL_PLAYLIST y
'  TBL_PLAYLIST_SONG.
' =====================================================================

' Lista las playlists de un usuario (o todas si userId = 0).
Function PlaylistListByUser(userId)
    Dim rs, list, m, sql
    Set list = Server.CreateObject("Scripting.Dictionary")
    sql = "SELECT * FROM TBL_PLAYLIST "
    If userId > 0 Then sql = sql & "WHERE ID_USER = ? "
    sql = sql & "ORDER BY ID_PLAYLIST"

    If userId > 0 Then
        Set rs = DbQuery(sql, Array(userId))
    Else
        Set rs = DbQuery(sql, Empty)
    End If

    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Set m = NewPlaylist(CLng(rs("ID_PLAYLIST").Value), CLng(rs("ID_USER").Value), _
                                CStr(rs("TITLE").Value), rs("CREATION_DATE").Value, _
                                CInt(rs("TYPE").Value), CStr(rs("PHOTO").Value & ""))
            list.Add CStr(m("Id")), m
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set PlaylistListByUser = list
End Function

Function PlaylistFindById(id)
    Dim rs, m
    Set rs = DbQuery("SELECT * FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(id))
    Set PlaylistFindById = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewPlaylist(CLng(rs("ID_PLAYLIST").Value), CLng(rs("ID_USER").Value), _
                                CStr(rs("TITLE").Value), rs("CREATION_DATE").Value, _
                                CInt(rs("TYPE").Value), CStr(rs("PHOTO").Value & ""))
            Set PlaylistFindById = m
        End If
        RsClose rs
    End If
End Function

Function PlaylistCreate(userId, title, playType, photo)
    PlaylistCreate = DbInsertReturnId( _
        "INSERT INTO TBL_PLAYLIST (ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO) " & _
        "VALUES (?, ?, GETDATE(), ?, ?)", Array(userId, title, playType, photo))
End Function

Function PlaylistUpdate(id, title, playType, photo)
    PlaylistUpdate = DbExecute( _
        "UPDATE TBL_PLAYLIST SET TITLE = ?, TYPE = ?, PHOTO = ? WHERE ID_PLAYLIST = ?", _
        Array(title, playType, photo, id))
End Function

Function PlaylistDelete(id)
    DbExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ?", Array(id)
    PlaylistDelete = DbExecute("DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ?", Array(id))
End Function

' --- Relacion playlist <-> cancion ----------------------------------
Sub PlaylistAddSong(playlistId, songId)
    If DbScalar("SELECT COUNT(*) FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
                Array(playlistId, songId)) = 0 Then
        DbExecute "INSERT INTO TBL_PLAYLIST_SONG (ID_PLAYLIST, ID_SONG) VALUES (?, ?)", _
                  Array(playlistId, songId)
    End If
End Sub

Sub PlaylistRemoveSong(playlistId, songId)
    DbExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST = ? AND ID_SONG = ?", _
              Array(playlistId, songId)
End Sub

Function PlaylistSongs(playlistId)
    Dim rs, list, m
    Set list = Server.CreateObject("Scripting.Dictionary")
    Set rs = DbQuery( _
        "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS " & _
        "FROM TBL_PLAYLIST_SONG ps INNER JOIN TBL_SONG s ON s.ID_SONG = ps.ID_SONG " & _
        "WHERE ps.ID_PLAYLIST = ? ORDER BY s.ID_SONG", Array(playlistId))
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Set m = NewSong(CLng(rs("ID_SONG").Value), CStr(rs("SONG_NAME").Value), _
                            CStr(rs("SONG_PATH").Value), ToLong(rs("PLAYS").Value, 0))
            list.Add CStr(m("Id")), m
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set PlaylistSongs = list
End Function
%>
