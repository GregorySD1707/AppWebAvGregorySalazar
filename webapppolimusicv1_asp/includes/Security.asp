<%
' =====================================================================
'  Security.asp  -  Utilidades de seguridad
'
'  La base de datos BDD_PoliMusic almacena las contrasenas de dos formas:
'    - Texto plano  : '12345678'   (usuarios userNormal / userAdmin)
'    - SHA-1 hex    : '7C222F...'  (usuario username1)
'  Para ser compatible con los datos ya existentes, el login acepta
'  ambos formatos. Para nuevas cuentas se guarda SHA-1.
'
'  Nota academica: SHA-1 no es un algoritmo moderno de hash de
'  contrasenas (carece de salt). Se conserva aqui unicamente porque es
'  el formato que la base de datos entregada ya utiliza.
' =====================================================================

Function Sha1Hex(plainText)
    Dim enc, utf8, hasher, bytes, i, sb
    Set enc  = Server.CreateObject("System.Text.UTF8Encoding")
    utf8     = enc.GetBytes_4(plainText)
    Set hasher = Server.CreateObject("System.Security.Cryptography.SHA1CryptoServiceProvider")
    bytes    = hasher.ComputeHash_2((utf8))

    sb = ""
    For i = 0 To UBound(bytes)
        sb = sb & Right("0" & Hex(AscB(MidB(bytes, i + 1, 1))), 2)
    Next
    Sha1Hex = UCase(sb)
End Function

' --- Escapa texto para mostrarlo en HTML (evita XSS) ----------------
Function HtmlEncode(value)
    Dim s
    s = Trim(value & "")
    s = Replace(s, "&", "&amp;")
    s = Replace(s, "<", "&lt;")
    s = Replace(s, ">", "&gt;")
    s = Replace(s, """", "&quot;")
    s = Replace(s, "'", "&#39;")
    HtmlEncode = s
End Function

' --- Escapa para un atributo / contexto JS simple -------------------
Function AttrEncode(value)
    AttrEncode = HtmlEncode(value)
End Function

' --- IIf: VBScript NO trae esta funcion (existe en VBA, no aqui).
'     Se implementa aqui porque se usa en toda la capa de presentacion.
Function IIf(condition, valueIfTrue, valueIfFalse)
    If condition Then
        IIf = valueIfTrue
    Else
        IIf = valueIfFalse
    End If
End Function

' --- ValOr: lectura perezosa (lazy) de un valor de un diccionario ----
'
'  ADVERTENCIA IMPORTANTE sobre IIf:
'  VBScript evalua TODOS los argumentos ANTES de llamar a la funcion.
'  No existe evaluacion de corto circuito. Por tanto esto es un error:
'
'      IIf(isEditing, editSong("Id"), 0)
'
'  Cuando isEditing es False, editSong vale Nothing y la expresion
'  editSong("Id") se evalua igualmente, produciendo:
'
'      error 800a000d "No coinciden los tipos"
'
'  ValOr resuelve el problema porque la expresion peligrosa NO se
'  evalua fuera: se pasa el objeto y la clave, y aqui se comprueba
'  primero si el objeto existe.
'
'  Uso:
'      ValOr(editSong, "Id", 0)             ' devuelve 0 si no hay edicion
'      ValOr(editSong, "Name", "")          ' devuelve "" si no hay edicion
Function ValOr(source, key, fallback)
    ValOr = fallback
    If Not IsObject(source) Then Exit Function
    If source Is Nothing Then Exit Function
    If source.Exists(key) Then
        If Not IsNull(source(key)) Then ValOr = source(key)
    End If
End Function

' --- ValOrEnc: como ValOr pero escapando el texto para HTML ----------
'     Se usa en los value="..." de los formularios de edicion.
Function ValOrEnc(source, key, fallback)
    ValOrEnc = HtmlEncode(ValOr(source, key, fallback))
End Function

' --- SelIf: marca "selected" en un <select> de edicion --------------
'  Compara de forma perezosa el valor guardado en el modelo con el
'  valor de la opcion. Si no se esta editando (modelo Nothing),
'  devuelve cadena vacia, sin evaluar la conversion a numero.
'  Evita el mismo error 800a000d que ValOr (ver nota mas arriba).
Function SelIf(source, key, optionValue)
    SelIf = ""
    If Not IsObject(source) Then Exit Function
    If source Is Nothing Then Exit Function
    If ToLong(ValOr(source, key, -1), -1) = CLng(optionValue) Then SelIf = "selected"
End Function

' --- Formatea una fecha como yyyy-mm-dd para <input type="date"> ----
'     Devuelve "" si la fecha es nula o invalida.
Function FormatDateInput(value)
    FormatDateInput = ""
    If IsNull(value) Then Exit Function
    If Not IsDate(value) Then Exit Function
    Dim d
    d = CDate(value)
    FormatDateInput = Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2)
End Function

' --- Escapa comillas para incrustar en JavaScript -------------------
Function JsEncode(value)
    Dim s
    s = Trim(value & "")
    s = Replace(s, "\", "\\")
    s = Replace(s, "'", "\'")
    s = Replace(s, """", "\""")
    s = Replace(s, Chr(10), " ")
    s = Replace(s, Chr(13), " ")
    JsEncode = s
End Function
%>
