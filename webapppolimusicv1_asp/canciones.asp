<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  canciones.asp  -  Pantalla principal: listado de canciones (Song List).
'
'  Cumple con lo solicitado:
'    - Mensaje de bienvenida con el nombre leido de la variable de sesion
'      (almacenada en login.asp).
'    - Texto que anuncia el listado de canciones (Song List).
'    - Tabla HTML de canciones con estilos CSS propios.
'    - Capacidad de reproducir cada cancion.
'    - Opcion de cierre de sesion en la barra superior.
'    - El CRUD solo aparece para el rol administrador.
' =====================================================================
%>
<!--#include file="includes/bootstrap.asp"-->
<%
RequireLogin

Dim RootPath
RootPath = ""

Dim songs, restrictedMsg, songCount
Set songs = CatalogSongsForView()
songCount = songs.Count

If Request.QueryString("msg") = "forbidden" Then
    restrictedMsg = "Solo el usuario administrador puede realizar operaciones CRUD."
End If

Dim PageTitle, ActiveMenu
PageTitle  = "Canciones"
ActiveMenu = "canciones"
%>
<!--#include file="includes/header.asp"-->
<%
' --- Construccion de la playlist para el reproductor (JS) -----------
Dim jsQueue, k, s, first
jsQueue = "["
k = 0
For Each s In songs.Items
    If Len(s("Url")) > 0 Then
        If k > 0 Then jsQueue = jsQueue & ","
        jsQueue = jsQueue & "{id:" & s("Id") & _
                  ",name:'" & JsEncode(s("Name")) & "'" & _
                  ",artist:'" & JsEncode(s("Artist")) & "'" & _
                  ",url:'" & JsEncode(s("Url")) & "'" & _
                  ",cover:'" & JsEncode(ResolveAssetPath(IMG_ALBUM_DEFAULT, "")) & "'}"
        k = k + 1
    End If
Next
jsQueue = jsQueue & "]"

Response.Write "<script>window.__POLI_QUEUE = " & jsQueue & ";</script>"
%>

<div class="page-head">
    <div>
        <h1>Song List</h1>
        <p class="page-sub">
            Listado de canciones disponibles. Haz clic en <b>Reproducir</b> para escucharlas.
        </p>
    </div>
    <div style="display:flex;gap:8px;flex-wrap:wrap">
        <button class="btn btn-primary" type="button" id="btnPlayAll">
            <svg viewBox="0 0 24 24" width="15" height="15" fill="none"><path d="M8 5l11 7-11 7V5z" fill="currentColor"/></svg>
            Reproducir todo
        </button>
        <% If AuthIsAdmin() Then %>
        <a class="btn btn-ghost" href="admin/canciones.asp">Administrar canciones</a>
        <% End If %>
    </div>
</div>

<%=AlertHtml(restrictedMsg, "info")%>

<% If songCount = 0 Then %>
<div class="card empty">
    <svg viewBox="0 0 24 24" fill="none"><path d="M9 18V6l10-2v12" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/><circle cx="6.5" cy="18" r="2.5" stroke="currentColor" stroke-width="1.6"/><circle cx="16.5" cy="16" r="2.5" stroke="currentColor" stroke-width="1.6"/></svg>
    <h2>No hay canciones registradas</h2>
    <p>La tabla TBL_SONG esta vacia.</p>
</div>
<% Else %>

<div class="table-wrap">
    <table class="data">
        <thead>
            <tr>
                <th style="width:52px">#</th>
                <th>Cancion</th>
                <th>Album</th>
                <th style="width:110px">Reproducciones</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <%
        Dim rowIndex
        rowIndex = 0
        For Each s In songs.Items
        %>
            <tr data-song-id="<%=s("Id")%>">
                <td><%=rowIndex + 1%></td>
                <td>
                    <div class="cell-song">
                        <img class="mini-cover" src="<%=ResolveAssetPath(IMG_ALBUM_DEFAULT,"")%>" alt="">
                        <div>
                            <div class="song-name"><%=HtmlEncode(s("Name"))%></div>
                            <div class="song-artist"><%=IIf(Len(s("Artist")&"")>0, HtmlEncode(s("Artist")), "Artista desconocido")%></div>
                        </div>
                    </div>
                </td>
                <td><%=IIf(Len(s("Album")&"")>0, HtmlEncode(s("Album")), "&mdash;")%></td>
                <td><%=s("Plays")%></td>
                <td>
                    <div class="actions">
                    <% If s("IsPlayable") Then %>
                        <button class="btn btn-primary btn-sm" type="button"
                                data-play-index="<%=rowIndex%>" title="Reproducir">
                            <svg viewBox="0 0 24 24" width="12" height="12" fill="none"><path d="M8 5l11 7-11 7V5z" fill="currentColor"/></svg>
                            Reproducir
                        </button>
                    <% Else %>
                        <span class="hint" style="color:var(--err)">Archivo no disponible</span>
                    <% End If %>
                    <% If AuthIsAdmin() Then %>
                        <a class="btn btn-ghost btn-sm" href="admin/canciones.asp?edit=<%=s("Id")%>">Editar</a>
                    <% End If %>
                    </div>
                </td>
            </tr>
        <%
            rowIndex = rowIndex + 1
        Next
        %>
        </tbody>
    </table>
</div>
<% End If %>

<script>
(function () {
    "use strict";
    var queue = window.__POLI_QUEUE || [];

    function boot() {
        if (!window.PoliPlayer) { return; }
        window.PoliPlayer.setQueue(queue);

        var idx = window.PoliPlayer.getIndex();
        if (idx >= 0) { window.PoliPlayer.refreshHighlight(); }

        document.querySelectorAll("[data-play-index]").forEach(function (btn) {
            btn.addEventListener("click", function () {
                var visible = parseInt(btn.getAttribute("data-play-index"), 10);
                var songId  = btn.closest("tr").getAttribute("data-song-id");
                var real = 0, i;
                for (i = 0; i < queue.length; i++) {
                    if (String(queue[i].id) === String(songId)) { real = i; break; }
                }
                window.PoliPlayer.play(real);
            });
        });

        var all = document.getElementById("btnPlayAll");
        if (all) {
            all.addEventListener("click", function () {
                if (queue.length) { window.PoliPlayer.play(0); }
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", boot);
    } else { boot(); }
})();
</script>

<!--#include file="includes/footer.asp"-->
