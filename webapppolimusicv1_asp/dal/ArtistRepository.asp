<%
' =====================================================================
'  ArtistRepository.asp  -  Acceso a datos de TBL_ARTIST
' =====================================================================

Function ArtistListAll()
    Dim rs, list, m
    Set list = Server.CreateObject("Scripting.Dictionary")
    Set rs = DbQuery("SELECT * FROM TBL_ARTIST ORDER BY ID_ARTIST", Empty)
    If Not rs Is Nothing Then
        Do While Not rs.EOF
            Set m = NewArtist(CLng(rs("ID_ARTIST").Value), CStr(rs("ARTIST_NAME").Value), _
                              CStr(rs("ARTIST_LASTNAME").Value & ""), CStr(rs("ARTIST_IMAGE").Value & ""))
            list.Add CStr(m("Id")), m
            rs.MoveNext
        Loop
        RsClose rs
    End If
    Set ArtistListAll = list
End Function

Function ArtistFindById(id)
    Dim rs, m
    Set rs = DbQuery("SELECT * FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(id))
    Set ArtistFindById = Nothing
    If Not rs Is Nothing Then
        If Not rs.EOF Then
            Set m = NewArtist(CLng(rs("ID_ARTIST").Value), CStr(rs("ARTIST_NAME").Value), _
                              CStr(rs("ARTIST_LASTNAME").Value & ""), CStr(rs("ARTIST_IMAGE").Value & ""))
            Set ArtistFindById = m
        End If
        RsClose rs
    End If
End Function

Function ArtistCreate(name, lastname, imagePath)
    ArtistCreate = DbInsertReturnId( _
        "INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) VALUES (?, ?, ?)", _
        Array(name, lastname, imagePath))
End Function

Function ArtistUpdate(id, name, lastname, imagePath)
    ArtistUpdate = DbExecute( _
        "UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?", _
        Array(name, lastname, imagePath, id))
End Function

Function ArtistDelete(id)
    DbExecute "DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", Array(id)
    ArtistDelete = DbExecute("DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?", Array(id))
End Function
%>
