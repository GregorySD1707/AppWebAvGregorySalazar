<%
' =====================================================================
'  AppConfig.asp  -  Configuracion central de la aplicacion
'  Unico punto de verdad para rutas, roles y ajustes generales.
'  Ninguna otra pagina debe declarar estos valores por su cuenta.
' =====================================================================

Const APP_NAME          = "PoliMusic"

' --- Rol de usuario (mapea contra TBL_CATALOG / TBL_USER.USER_TYPE) ---
Const ROLE_USER         = 0
Const ROLE_ADMIN        = 1

' --- Tipo de playlist (mapea contra TBL_CATALOG: PLAYLIST TYPE) ---
Const PLAYLIST_PUBLIC   = 0
Const PLAYLIST_PRIVATE  = 1

' --- Carpetas de recursos (convencion "~/" usada por la base de datos) ---
Const ASSETS_ROOT       = "assets"
Const DIR_SONGS         = "SongFiles"
Const DIR_ALBUM_IMAGES  = "albumImages"
Const DIR_ARTIST_IMAGES = "ArtistImages"
Const DIR_USER_IMAGES   = "UserImages"
Const DIR_PLAYLIST_IMG  = "PlaylistImages"

' --- Imagen de respaldo cuando el recurso no existe -------------------
'     (rutas absolutas desde la raiz del sitio, igual que ResolveAssetPath)
Const IMG_USER_DEFAULT     = "/assets/UserImages/default.jpg"
Const IMG_ALBUM_DEFAULT    = "/assets/albumImages/album1.png"
Const IMG_ARTIST_DEFAULT   = "/assets/ArtistImages/artist1.jpg"
Const IMG_PLAYLIST_DEFAULT = "/assets/PlaylistImages/default.jpg"

' --- Claves de sesion (evita strings sueltos en las paginas) ---
Const SESSION_USER_ID    = "UserId"
Const SESSION_USERNAME   = "Username"
Const SESSION_USER_TYPE  = "UserType"
Const SESSION_USER_PHOTO = "UserPhoto"

' --- Nombre de la cookie de sesion ---
Const SESSION_COOKIE_NAME = "POLIMUSIC_SID"

' ---------------------------------------------------------------------
'  Convierte una ruta de la BD ("~/songFiles/x.mp3") en una ruta web
'  absoluta desde la raiz del sitio ("/assets/SongFiles/x.mp3").
'
'  La base de datos:
'    - usa "~/" y "\", que el navegador no resuelve;
'    - mezcla mayusculas y minusculas ("Playlist2.png", "playlist2.png").
'
'  Se devuelve una ruta que empieza con "/" para que funcione igual
'  desde la raiz del sitio y desde subcarpetas como /admin.
' ---------------------------------------------------------------------
Function ResolveAssetPath(dbPath, fallbackPath)
    Dim clean, folder, fileName, parts
    ResolveAssetPath = fallbackPath
    If IsNull(dbPath) Or Len(Trim(dbPath & "")) = 0 Then Exit Function

    clean = Replace(Trim(dbPath), "\", "/")
    clean = Replace(clean, "~/", "")
    If Left(clean, 1) = "/" Then clean = Mid(clean, 2)

    parts = Split(clean, "/")
    If UBound(parts) < 1 Then Exit Function

    folder   = LCase(parts(UBound(parts) - 1))
    fileName = parts(UBound(parts))

    Select Case folder
        Case "songfiles"      folder = DIR_SONGS
        Case "albumimages"    folder = DIR_ALBUM_IMAGES
        Case "artistimages"   folder = DIR_ARTIST_IMAGES
        Case "userimages"     folder = DIR_USER_IMAGES
        Case "playlistimages" folder = DIR_PLAYLIST_IMG
        Case Else             ResolveAssetPath = fallbackPath : Exit Function
    End Select

    ' En disco los nombres estan en minusculas (playlist1.png ...).
    ' Se normaliza el nombre completo a minusculas para que las
    ' variantes "Playlist2.png" / "playlist2.png" apunten al archivo real.
    fileName = LCase(fileName)

    ' Todo el sitio sirve los assets desde la raiz del sitio.
    ResolveAssetPath = "/" & ASSETS_ROOT & "/" & folder & "/" & fileName
End Function
%>
