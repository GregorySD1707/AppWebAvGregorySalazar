<%
' =====================================================================
'  AlbumRepository.asp  -  Acceso a datos de TBL_ALBUM
' =====================================================================

Function AlbumListAll()
    Dim rs, list, m
    Set list = Server.CreateObject("Scripting.Dictionary")
    Set rs = DbQuery("SELECT * FROM TBL_ALBUM ORDER BY ID_ALBUM", Empty)
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Set m = NewAlbum(CLng(rs("ID_ALBUM").Value), CStr(rs("TITLE_ALBUM").Value), _
                             ToLong(rs("RELEASE_YEAR").Value, 0), CStr(rs("ALBUM_IMAGE_PATH").Value & ""))
            list.Add CStr(m("Id")), m
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set AlbumListAll = list
End Function

Function AlbumFindById(id)
    Dim rs, m
    Set rs = DbQuery("SELECT * FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(id))
    Set AlbumFindById = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewAlbum(CLng(rs("ID_ALBUM").Value), CStr(rs("TITLE_ALBUM").Value), _
                             ToLong(rs("RELEASE_YEAR").Value, 0), CStr(rs("ALBUM_IMAGE_PATH").Value & ""))
            Set AlbumFindById = m
        End If
        RsClose rs
    End If
End Function

Function AlbumCreate(title, releaseYear, imagePath)
    AlbumCreate = DbInsertReturnId( _
        "INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) VALUES (?, ?, ?)", _
        Array(title, releaseYear, imagePath))
End Function

Function AlbumUpdate(id, title, releaseYear, imagePath)
    AlbumUpdate = DbExecute( _
        "UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?", _
        Array(title, releaseYear, imagePath, id))
End Function

Function AlbumDelete(id)
    DbExecute "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", Array(id)
    AlbumDelete = DbExecute("DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?", Array(id))
End Function
%>
