<%
' =====================================================================
'  bootstrap.asp  -  Punto de entrada unico de dependencias.
'
'  Cada pagina hace unicamente:
'      pagina en la raiz :  <!--#include file="includes/bootstrap.asp"-->
'      pagina en /admin  :  <!--#include file="../includes/bootstrap.asp"-->
'  y con eso recibe configuracion, seguridad, datos, servicios y modelos.
'  Orden de carga: config -> helpers -> datos -> modelos -> servicios.
'
'  Se usa la forma "file=" con rutas RELATIVAS (no "virtual=").
'  Motivo (comprobado al desplegar en IIS):
'    "virtual='/ruta'" se resuelve desde la raiz del SITIO, no desde la
'    raiz de la APLICACION. Como el sitio se publica en un subdirectorio
'    ("/webapppolimusicv1_asp"), un include virtual="/includes/x.asp"
'    apuntaba a /includes/x.asp (inexistente) y Classic ASP devolvia
'    HTTP 500. En IIS Express funcionaba solo porque la aplicacion estaba
'    en la raiz.
'    "file=" se resuelve de forma relativa al archivo que lo contiene, de
'    modo que la misma directiva funciona igual en la raiz y en /admin.
'
'  Nota: esta carpeta usa "../config/", "../dal/", etc. porque este
'  archivo vive en /includes y esas carpetas cuelgan de la raiz.
' =====================================================================

%>
<!--#include file="../config/AppConfig.asp"-->
<!--#include file="../includes/Security.asp"-->
<!--#include file="../config/Connection.asp"-->
<!--#include file="../dal/Db.asp"-->
<!--#include file="../models/Models.asp"-->
<!--#include file="../dal/UserRepository.asp"-->
<!--#include file="../dal/SongRepository.asp"-->
<!--#include file="../dal/AlbumRepository.asp"-->
<!--#include file="../dal/ArtistRepository.asp"-->
<!--#include file="../dal/PlaylistRepository.asp"-->
<!--#include file="../services/AuthService.asp"-->
<!--#include file="../services/CatalogService.asp"-->
<%
' Endurecimiento basico de la respuesta (evita el sniffing de tipos MIME).
Response.AddHeader "X-Content-Type-Options", "nosniff"
%>
