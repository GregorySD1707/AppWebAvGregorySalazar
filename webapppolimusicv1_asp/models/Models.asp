<%
' =====================================================================
'  Models.asp  -  Modelos de dominio (DTOs).
'  Representan una fila de cada tabla. Se usan para mover datos entre
'  repositorios y servicios sin exponer el Recordset a la vista.
'
'  Convencion: por simplicidad y rendimiento, los modelos son Dictionary
'  con claves de nombre fijo; los repositorios son los unicos que
'  conocen el nombre real de las columnas.
' =====================================================================

Function ModelDict()
    Dim d
    Set d = Server.CreateObject("Scripting.Dictionary")
    d.CompareMode = 1 ' vbTextCompare
    Set ModelDict = d
End Function

' --- TBL_USER -------------------------------------------------------
Function NewUser(id, username, email, birthday, photo, userType)
    Dim m : Set m = ModelDict()
    m("Id")       = id
    m("Username") = username
    m("Email")    = email
    m("Birthday") = birthday
    m("Photo")    = photo
    m("UserType") = userType
    Set NewUser = m
End Function

' --- TBL_SONG -------------------------------------------------------
Function NewSong(id, name, path, plays)
    Dim m : Set m = ModelDict()
    m("Id")    = id
    m("Name")  = name
    m("Path")  = path
    m("Plays") = plays
    Set NewSong = m
End Function

' --- TBL_ALBUM ------------------------------------------------------
Function NewAlbum(id, title, releaseYear, imagePath)
    Dim m : Set m = ModelDict()
    m("Id")          = id
    m("Title")       = title
    m("ReleaseYear") = releaseYear
    m("ImagePath")   = imagePath
    Set NewAlbum = m
End Function

' --- TBL_ARTIST -----------------------------------------------------
Function NewArtist(id, name, lastname, imagePath)
    Dim m : Set m = ModelDict()
    m("Id")       = id
    m("Name")     = name
    m("Lastname") = lastname
    m("ImagePath")= imagePath
    Set NewArtist = m
End Function

' --- TBL_PLAYLIST ---------------------------------------------------
Function NewPlaylist(id, userId, title, creationDate, playType, photo)
    Dim m : Set m = ModelDict()
    m("Id")           = id
    m("UserId")       = userId
    m("Title")        = title
    m("CreationDate") = creationDate
    m("Type")         = playType
    m("Photo")        = photo
    Set NewPlaylist = m
End Function
%>
