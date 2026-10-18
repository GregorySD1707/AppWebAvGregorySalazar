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

' ---------------------------------------------------------------------
'  Base de la aplicacion (ruta virtual donde esta publicada).
'
'  POR QUE EXISTE:
'    Una ruta que empieza con "/" se resuelve desde la RAIZ DEL SITIO,
'    no desde la aplicacion. Si el sitio se publica en un subdirectorio
'    (por ejemplo /webapppolimusicv1_asp), entonces "/assets/x.png"
'    apunta a un lugar equivocado y la pagina se queda sin CSS, sin
'    imagenes y sin audio.
'
'  COMO SE CALCULA:
'    NO se usa SCRIPT_NAME, porque devuelve la ruta del ARCHIVO actual:
'    en /admin/canciones.asp valdria "/app/admin/canciones.asp" y la base
'    quedaria como "/app/admin", duplicando la carpeta en cada enlace.
'
'    Se usa APPL_MD_PATH, que es la ruta del METADIRECTORIO de la
'    aplicacion y es igual para todas las paginas:
'        /LM/W3SVC/1/ROOT/webapppolimusicv1_asp
'    Quitando el prefijo "/LM/W3SVC/<n>/ROOT" queda la base virtual:
'        /webapppolimusicv1_asp      (app en subdirectorio)
'        ""                          (app en la raiz)
'
'  USO:  en una pagina, escribir  < % = APP_BASE % > /css/styles.css
'        o en codigo:  APP_BASE & "/assets/SongFiles/x.mp3"
'
'  OJO: no escribir la etiqueta de impresion completa dentro de este
'  comentario, porque su cierre terminaria el bloque ASP actual y el
'  resto del archivo se enviaria como texto al navegador.
' ---------------------------------------------------------------------
Function AppBasePath()
    Dim md, prefixPos, rest, slashPos
    AppBasePath = ""

    ' Ruta del metadirectorio de la aplicacion (igual en todas las paginas).
    md = Request.ServerVariables("APPL_MD_PATH") & ""
    If Len(md) = 0 Then Exit Function

    ' Formato: /LM/W3SVC/<sitio>/ROOT/<ruta-virtual>
    prefixPos = InStr(1, md, "/ROOT", vbTextCompare)
    If prefixPos = 0 Then Exit Function

    rest = Mid(md, prefixPos + Len("/ROOT"))
    If Len(rest) = 0 Then Exit Function

    ' Normaliza: quita la barra final si la hubiera.
    If Right(rest, 1) = "/" Then rest = Left(rest, Len(rest) - 1)

    ' Debe empezar por "/" (p. ej. "/webapppolimusicv1_asp").
    If Left(rest, 1) <> "/" Then rest = "/" & rest

    AppBasePath = rest
End Function

' Se calcula una sola vez por peticion.
Dim APP_BASE
APP_BASE = AppBasePath()

' --- Imagen de respaldo cuando el recurso no existe -------------------
'     (rutas relativas a la aplicacion, igual que ResolveAssetPath)
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
'  valida ("<APP_BASE>/assets/SongFiles/x.mp3").
'
'  La base de datos:
'    - usa "~/" y "\", que el navegador no resuelve;
'    - mezcla mayusculas y minusculas ("Playlist2.png", "playlist2.png").
'
'  Se antepone APP_BASE para que la ruta funcione tanto si la aplicacion
'  esta en la raiz del sitio como si esta en un subdirectorio.
' ---------------------------------------------------------------------
Function ResolveAssetPath(dbPath, fallbackPath)
    Dim clean, folder, fileName, parts
    ResolveAssetPath = APP_BASE & fallbackPath
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
        Case Else             ResolveAssetPath = APP_BASE & fallbackPath : Exit Function
    End Select

    ' En disco los nombres estan en minusculas (playlist1.png ...).
    ' Se normaliza el nombre completo a minusculas para que las
    ' variantes "Playlist2.png" / "playlist2.png" apunten al archivo real.
    fileName = LCase(fileName)

    ' Los assets cuelgan de la raiz de la aplicacion (APP_BASE).
    ResolveAssetPath = APP_BASE & "/" & ASSETS_ROOT & "/" & folder & "/" & fileName
End Function
%>
