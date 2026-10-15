<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  logout.asp  -  Cierre de sesion.
'  Destruye la sesion y regresa al login con un aviso.
' =====================================================================
%>
<!--#include virtual="/includes/bootstrap.asp"-->
<%
AuthLogout()
Response.Redirect "login.asp?msg=logout"
%>
