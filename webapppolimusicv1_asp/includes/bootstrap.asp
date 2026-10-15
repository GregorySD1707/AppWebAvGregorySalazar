<%
' =====================================================================
'  bootstrap.asp  -  Punto de entrada unico de dependencias.
'
'  Cada pagina hace unicamente:
'      <!--#include virtual="/includes/bootstrap.asp"-->
'  y con eso recibe configuracion, seguridad, datos, servicios y modelos.
'  Orden de carga: config -> helpers -> datos -> modelos -> servicios.
'
'  Se usa la forma "virtual=" (ruta desde la raiz de la aplicacion) en
'  lugar de "file=" porque:
'    1) Resuelve siempre igual, sin importar desde que carpeta se incluya
'       la pagina (raiz o /admin).
'    2) NO requiere habilitar "enableParentPaths" en IIS, que viene
'       deshabilitado por defecto y es una mala practica de seguridad.
' =====================================================================

%>
<!--#include virtual="/config/AppConfig.asp"-->
<!--#include virtual="/includes/Security.asp"-->
<!--#include virtual="/config/Connection.asp"-->
<!--#include virtual="/dal/Db.asp"-->
<!--#include virtual="/models/Models.asp"-->
<!--#include virtual="/dal/UserRepository.asp"-->
<!--#include virtual="/dal/SongRepository.asp"-->
<!--#include virtual="/dal/AlbumRepository.asp"-->
<!--#include virtual="/dal/ArtistRepository.asp"-->
<!--#include virtual="/dal/PlaylistRepository.asp"-->
<!--#include virtual="/services/AuthService.asp"-->
<!--#include virtual="/services/CatalogService.asp"-->
<%
' Endurecimiento basico de la respuesta (evita el sniffing de tipos MIME).
Response.AddHeader "X-Content-Type-Options", "nosniff"
%>
