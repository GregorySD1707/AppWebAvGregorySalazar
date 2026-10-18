<%@ Language="VBScript" CodePage="65001" %>
<%
' =====================================================================
'  admin/usuarios.asp  -  CRUD de Usuarios (solo administrador).
' =====================================================================
%>
<!--#include file="../includes/bootstrap.asp"-->
<%
RequireAdmin

Dim RootPath : RootPath = "../"
Dim PageTitle, AdminMenu
PageTitle = "Usuarios"
AdminMenu = "usuarios"

Dim msg, msgType, action
Dim id, username, email, birthday, photo, userType, password
msg = "" : msgType = "ok"
action = LCase(Trim(Request.QueryString("action")))

' ---------------------------- POST ----------------------------
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    action   = LCase(Trim(Request.Form("action")))
    id       = ToLong(Request.Form("id"), 0)
    username = Trim(Request.Form("username"))
    email    = Trim(Request.Form("email"))
    birthday = Trim(Request.Form("birthday"))
    photo    = Trim(Request.Form("photo"))
    userType = ToLong(Request.Form("type"), 0)
    password = Trim(Request.Form("password"))

    If action = "delete" Then
        If id = AuthUserId() Then
            msg = "No puedes eliminar tu propia cuenta en sesion." : msgType = "error"
        Else
            UserDelete id
            msg = "Usuario eliminado."
        End If

    ElseIf action = "save" Then
        If Len(username) = 0 Or Len(email) = 0 Then
            msg = "Usuario y correo son obligatorios." : msgType = "error"
        ElseIf id = 0 Then
            If Len(password) < 6 Then
                msg = "La contrasena debe tener al menos 6 caracteres." : msgType = "error"
            ElseIf UserExists(username) Then
                msg = "Ese nombre de usuario ya existe." : msgType = "error"
            Else
                UserCreate username, Sha1Hex(password), email, birthday, photo, userType
                msg = "Usuario creado correctamente."
            End If
        Else
            UserUpdate id, username, email, birthday, photo, userType
            If Len(password) >= 6 Then UserUpdatePassword id, Sha1Hex(password)
            msg = "Usuario actualizado."
        End If
    End If
End If

' ---------------------------- Edicion ----------------------------
Dim showForm, editUser, editId, isEditing
showForm  = (action = "new")
isEditing = False
editId    = ToLong(Request.QueryString("edit"), 0)
Set editUser = Nothing
If editId > 0 Then
    Set editUser = UserFindById(editId)
    If Not editUser Is Nothing Then showForm = True : isEditing = True
End If

Dim users, u
Set users = UserListAll()
%>
<!--#include file="../includes/adminHeader.asp"-->
<div class="page-head">
    <div>
        <h1>Usuarios</h1>
        <p class="page-sub">Alta, edicion y baja de usuarios del sistema.</p>
    </div>
    <a class="btn btn-primary" href="usuarios.asp?action=new">Nuevo usuario</a>
</div>

<%=AlertHtml(msg, msgType)%>

<% If showForm Then %>
<div class="card">
    <h2 style="margin-bottom:14px"><%=IIf(isEditing, "Editar usuario", "Nuevo usuario")%></h2>
    <form method="post" action="usuarios.asp">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%=ValOr(editUser, "Id", 0)%>">
        <div class="form-grid">
            <div class="field">
                <label for="username">Usuario</label>
                <input type="text" id="username" name="username" required maxlength="50"
                       value="<%=ValOrEnc(editUser, "Username", "")%>">
            </div>
            <div class="field">
                <label for="email">Correo</label>
                <input type="email" id="email" name="email" required maxlength="50"
                       value="<%=ValOrEnc(editUser, "Email", "")%>">
            </div>
            <div class="field">
                <label for="password">Contrasena <%=IIf(isEditing, "(dejar vacio para no cambiar)", "")%></label>
                <input type="password" id="password" name="password" maxlength="50"
                       <%=IIf(isEditing, "", "required minlength='6'")%>>
            </div>
            <div class="field">
                <label for="type">Rol</label>
                <select id="type" name="type">
                    <option value="<%=ROLE_USER%>"  <%=SelIf(editUser, "UserType", ROLE_USER)%>>Usuario normal</option>
                    <option value="<%=ROLE_ADMIN%>" <%=SelIf(editUser, "UserType", ROLE_ADMIN)%>>Administrador</option>
                </select>
            </div>
            <div class="field">
                <label for="birthday">Fecha de nacimiento</label>
                <input type="date" id="birthday" name="birthday"
                       value="<%=FormatDateInput(ValOr(editUser, "Birthday", ""))%>">
            </div>
            <div class="field">
                <label for="photo">Foto (ruta)</label>
                <input type="text" id="photo" name="photo" maxlength="255" placeholder="~/userImages/default.jpg"
                       value="<%=ValOrEnc(editUser, "Photo", "")%>">
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:8px">
            <button class="btn btn-primary" type="submit">Guardar</button>
            <a class="btn btn-ghost" href="usuarios.asp">Cancelar</a>
        </div>
    </form>
</div>
<% End If %>

<div class="table-wrap">
    <table class="data">
        <thead>
            <tr>
                <th style="width:52px">ID</th>
                <th>Usuario</th>
                <th>Correo</th>
                <th style="width:130px">Nacimiento</th>
                <th style="width:130px">Rol</th>
                <th style="width:150px">Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% If users.Count = 0 Then %>
            <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--ink-500)">Sin registros.</td></tr>
        <% Else %>
            <% For Each u In users.Items %>
            <tr>
                <td><%=u("Id")%></td>
                <td><span class="song-name"><%=HtmlEncode(u("Username"))%></span></td>
                <td><%=HtmlEncode(u("Email"))%></td>
                <td><%=FormatDateInput(u("Birthday"))%></td>
                <td>
                    <span class="badge <%=IIf(CLng(u("UserType"))=ROLE_ADMIN,"badge-admin","badge-user")%>">
                        <%=IIf(CLng(u("UserType"))=ROLE_ADMIN,"Administrador","Usuario")%>
                    </span>
                </td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="usuarios.asp?edit=<%=u("Id")%>">Editar</a>
                        <form method="post" action="usuarios.asp"
                              onsubmit="return confirm('Eliminar el usuario &quot;<%=JsEncode(u("Username"))%>&quot;?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%=u("Id")%>">
                            <button class="btn btn-danger btn-sm" type="submit">Eliminar</button>
                        </form>
                    </div>
                </td>
            </tr>
            <% Next %>
        <% End If %>
        </tbody>
    </table>
</div>

<!--#include file="../includes/footer.asp"-->
