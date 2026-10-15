<%
' =====================================================================
'  SongRepository.asp  -  Acceso a datos de TBL_SONG
' =====================================================================

Function SongListAll()
    Dim rs, list, m
    Set list = Server.CreateObject("Scripting.Dictionary")
    Set rs = DbQuery( _
        "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, s.PLAYS, " & _
        "       (SELECT TOP 1 a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,'') " & _
        "        FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "        WHERE p.ID_SONG = s.ID_SONG ORDER BY a.ID_ARTIST) AS ARTIST_NAME, " & _
        "       (SELECT TOP 1 al.TITLE_ALBUM " & _
        "        FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "        WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM) AS ALBUM_TITLE " & _
        "FROM TBL_SONG s ORDER BY s.ID_SONG", Empty)
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Set m = NewSong(CLng(rs("ID_SONG").Value), CStr(rs("SONG_NAME").Value), _
                            CStr(rs("SONG_PATH").Value), ToLong(rs("PLAYS").Value, 0))
            m("Artist") = CStr(rs("ARTIST_NAME").Value & "")
            m("Album")  = CStr(rs("ALBUM_TITLE").Value & "")
            list.Add CStr(m("Id")), m
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set SongListAll = list
End Function

Function SongFindById(id)
    Dim rs, m
    Set rs = DbQuery("SELECT * FROM TBL_SONG WHERE ID_SONG = ?", Array(id))
    Set SongFindById = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewSong(CLng(rs("ID_SONG").Value), CStr(rs("SONG_NAME").Value), _
                            CStr(rs("SONG_PATH").Value), ToLong(rs("PLAYS").Value, 0))
            Set SongFindById = m
        End If
        RsClose rs
    End If
End Function

Function SongCreate(name, path, plays, artistId, albumId)
    Dim id
    id = DbInsertReturnId( _
        "INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?)", _
        Array(name, path, plays))
    If id > 0 Then
        If artistId > 0 Then DbExecute "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", Array(id, artistId)
        If albumId  > 0 Then DbExecute "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", Array(albumId, id)
    End If
    SongCreate = id
End Function

Function SongUpdate(id, name, path, plays, artistId, albumId)
    DbExecute "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?", _
              Array(name, path, plays, id)
    DbExecute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id)
    DbExecute "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id)
    If artistId > 0 Then DbExecute "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) VALUES (?, ?)", Array(id, artistId)
    If albumId  > 0 Then DbExecute "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) VALUES (?, ?)", Array(albumId, id)
    SongUpdate = 1
End Function

Function SongDelete(id)
    DbExecute "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", Array(id)
    DbExecute "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(id)
    DbExecute "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", Array(id)
    SongDelete = DbExecute("DELETE FROM TBL_SONG WHERE ID_SONG = ?", Array(id))
End Function

' Registra una reproduccion (usado al dar play).
Sub SongRegisterPlay(id)
    DbExecute "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS,0) + 1 WHERE ID_SONG = ?", Array(id)
End Sub

' Devuelve el ID de artista asociado a una cancion (o 0).
Function SongArtistId(songId)
    Dim v
    v = DbScalar("SELECT TOP 1 ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", Array(songId))
    If IsNull(v) Then v = 0
    SongArtistId = CLng(v)
End Function

' Devuelve el ID de album asociado a una cancion (o 0).
Function SongAlbumId(songId)
    Dim v
    v = DbScalar("SELECT TOP 1 ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?", Array(songId))
    If IsNull(v) Then v = 0
    SongAlbumId = CLng(v)
End Function
%>
