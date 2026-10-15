# WebAppPoliMusicV1 — Clon academico de Spotify (ASP clasico)

Aplicacion web desarrollada en **ASP clasico (VBScript)** con **SQL Server**,
como parte del laboratorio de *Aplicaciones Web Avanzadas*.

> Proyecto con fines exclusivamente academicos. No reproduce ni distribuye
> contenido musical con derechos de autor.

---

## 1. Requisitos

| Componente | Version / nota |
|---|---|
| Windows | Con IIS habilitado |
| IIS | Classic ASP habilitado (`IIS-ASP`) |
| SQL Server | Engine escuchando en `localhost:1433` |
| Base de datos | `BDD_PoliMusic` (script `BDD_PoliMusic.sql`) |
| Visual Studio | Community 2022 / 2026 (o ejecucion directa en IIS) |

Credenciales de base de datos usadas por la aplicacion:

```
Server=localhost; Database=BDD_PoliMusic; User Id=usr_polimusic; Password=Politecnica1;
Encrypt=true; TrustServerCertificate=true;
```

---

## 2. Usuarios de prueba

| Usuario | Contrasena | Rol | Puede |
|---|---|---|---|
| `userAdmin` | `12345678` | Administrador | CRUD de usuarios, canciones, artistas, albumes y playlists |
| `userNormal` | `12345678` | Usuario normal | Reproducir canciones, consultar catalogo y administrar **sus propias** playlists |
| `username1` | `12345678` | Usuario normal | Igual que `userNormal` (su clave ya esta guardada como SHA-1) |

El rol se guarda en `TBL_USER.USER_TYPE` (`0` = normal, `1` = administrador).

La base entregada guarda las contrasenas de dos formas: en texto plano
(`userAdmin`, `userNormal`) y como hash SHA-1 (`username1`). El login acepta
**ambos formatos** para ser compatible con los datos existentes.

---

## 3. Estructura del proyecto

```
webapppolimusicv1_asp/
├── config/
│   ├── AppConfig.asp          # Constantes: roles, rutas, claves de sesion
│   └── Connection.asp         # Unica cadena de conexion
├── includes/
│   ├── bootstrap.asp          # Carga todas las capas con un solo include
│   ├── Security.asp           # IIf, HtmlEncode, JsEncode, SHA1
│   ├── header.asp             # Barra superior + mensaje de bienvenida
│   ├── adminHeader.asp        # Navegacion del CRUD
│   └── footer.asp             # Reproductor persistente
├── models/Models.asp          # Modelos de dominio (DTOs)
├── dal/
│   ├── Db.asp                 # Helper ADO parametrizado
│   ├── UserRepository.asp
│   ├── SongRepository.asp
│   ├── AlbumRepository.asp
│   ├── ArtistRepository.asp
│   └── PlaylistRepository.asp
├── services/
│   ├── AuthService.asp        # Login, logout, registro, roles
│   └── CatalogService.asp     # Datos listos para la vista
├── admin/                     # CRUD (acceso solo administrador)
├── css/styles.css             # Diseno propio (paleta azul)
├── js/player.js               # Reproductor de audio
├── assets/                    # Canciones e imagenes
├── sql/
│   └── limpiar-duplicados.sql # Mantenimiento: quita filas duplicadas
├── login.asp / logout.asp / registro.asp
├── canciones.asp              # Pantalla principal (Song List)
├── albumes.asp / artistas.asp / playlists.asp
├── web.config                 # Configuracion para IIS
└── deploy-iis.ps1             # Script de despliegue en IIS
```

---

## 4. Arquitectura en capas

```
Presentacion (.asp)  ->  Servicios  ->  Repositorios  ->  SQL Server
     html+css+js          reglas          ADO              BDD_PoliMusic
```

Reglas de dependencia aplicadas:

- Las **paginas** nunca escriben SQL: solo llaman a servicios.
- Los **servicios** contienen las reglas de negocio y de autorizacion.
- Los **repositorios** son los unicos que conocen nombres de tablas y columnas.
- `Db.asp` es el unico punto de acceso a ADO y **siempre** usa consultas
  parametrizadas, lo que elimina la inyeccion SQL.

---

## 5. Como ejecutar

### Opcion A — Visual Studio Community

1. Abrir `AppWebAvGregorySalazar.sln`.
2. Establecer `WebAppPoliMusicV1` como proyecto de inicio.
3. Presionar **F5** (IIS Express se inicia en `http://localhost:8899/`).

### Opcion B — Despliegue en IIS

Desde una consola **de administrador**:

```powershell
cd webapppolimusicv1_asp
powershell -ExecutionPolicy Bypass -File .\deploy-iis.ps1
```

El script habilita Classic ASP si hace falta, copia el sitio a
`C:\inetpub\wwwroot\webapppolimusicv1_asp`, crea el Application Pool,
otorga permisos y verifica que el sitio responda en
`http://localhost/webapppolimusicv1_asp/login.asp`.

---

## 6. Funcionalidades implementadas

- **Dos roles** normal y administrador, con autorizacion verificada en el servidor.
- **CRUD completo** (usuarios, canciones, artistas, albumes y playlists)
  visible y accesible solo para el administrador.
- **Login** que almacena el nombre de usuario en la variable de sesion.
- **Mensaje de bienvenida** en la pantalla principal leyendo esa variable de sesion.
- **Cierre de sesion** (logout) que destruye la sesion.
- **Registro** de nuevos usuarios (rol normal).
- **Texto "Song List"** que anuncia el listado.
- **Tabla HTML** de canciones con estilos CSS propios.
- **Reproduccion de audio** con controles de play/pausa, anterior, siguiente,
  barra de progreso, silencio y reproduccion continua.
- **Diseno original** en tonos azules (HTML + CSS + JavaScript), adaptado a
  pantallas pequenas.

---

## 7. Seguridad

- Consultas **parametrizadas** en toda la capa de datos (sin concatenacion de SQL).
- **Codificacion HTML** de toda salida (`HtmlEncode`) para evitar XSS.
- Autorizacion **del lado del servidor** (`RequireLogin`, `RequireAdmin`);
  ocultar enlaces no es la unica defensa.
- Contrasenas nuevas almacenadas con **SHA-1** (formato que ya usaba la base
  de datos entregada). Se documenta que SHA-1 no es el algoritmo recomendado
  hoy para contrasenas; se conserva por compatibilidad con los datos existentes.

---

## 8. Notas tecnicas (decisiones y trampas de Classic ASP)

Estas son decisiones tomadas a partir de comportamiento verificado en
ejecucion, no de suposiciones. Se documentan porque es facil volver a
caer en ellas.

### 8.1 `web.config` NO puede declarar `<asp>`

La seccion `system.webServer/asp` esta bloqueada en el servidor:

```xml
<section name="asp" overrideModeDefault="Deny" />
```

Declararla en `web.config` (incluso solo `<asp><session>`) produce
**HTTP 501 “Error en nueva aplicacion”**. Comprobado con una matriz de
pruebas: `<asp>`, `<asp><session>` y `<asp><limits>` dan 501, mientras que
`<defaultDocument>`, `<staticContent>` y `<directoryBrowse>` dan 200.

Por eso `web.config` solo contiene esas tres secciones, y los ajustes de ASP
se aplican al servidor (`iisexpress.config` en desarrollo;
`deploy-iis.ps1` con `MACHINE/WEBROOT/APPHOST` en IIS).

### 8.2 Includes con `virtual=`, sin `enableParentPaths`

Todos los `<!--#include ... -->` usan la forma `virtual="/ruta/desde/raiz"`.
Motivo: la forma `file=` se resuelve segun la profundidad de anidamiento y
obligaba a activar `enableParentPaths`, que IIS trae desactivado por
seguridad. Con `virtual=` los includes funcionan igual desde la raiz y desde
`/admin`, y la aplicacion mantiene `enableParentPaths="false"`.

### 8.3 `DbParam` tipa por `VarType`, nunca por el contenido

El helper de parametros decide el tipo ADO segun el **tipo del valor**
(`Long` -> `adInteger`, `String` -> `adVarChar`), no segun si “parece
numero”. Si se usa `IsNumeric()` para inferir:

- La contrasena `"12345678"` viaja como entero.
- Al comparar `PASSWORD` (varchar) contra un entero, SQL Server aplica
  precedencia de tipos e intenta convertir la columna a `int`.
- En la fila cuyo `PASSWORD` es un hash SHA-1, esa conversion falla:
  `error 80040e07: Conversion failed when converting the varchar value
  '7C222...' to data type int`.

Es decir, **una contrasena numerica rompia el login de cualquier usuario con
la clave guardada como hash**. Los valores realmente numericos llegan a la
capa de datos como `Long` porque las paginas los normalizan con `ToLong()`.

### 8.4 `IIf` en VBScript evalua TODOS sus argumentos

`IIf` es una funcion, no una construccion del lenguaje, y VBScript **no**
hace evaluacion de corto circuito: calcula los tres argumentos antes de
entrar. Por tanto esto falla:

```vbscript
IIf(isEditing, editSong("Id"), 0)   ' editSong es Nothing si no se edita
```

al evaluar `editSong("Id")` sobre `Nothing`:

```
error 800a000d  "No coinciden los tipos"
```

Afectaba a los formularios de alta y edicion de las cinco pantallas de CRUD.
La solucion son los helpers con evaluacion perezosa de `includes/Security.asp`:

| Helper | Uso |
|---|---|
| `ValOr(modelo, "Clave", respaldo)` | Lee un valor sin fallar si el modelo es `Nothing` |
| `ValOrEnc(modelo, "Clave", respaldo)` | Igual, escapando el texto para HTML |
| `SelIf(modelo, "Clave", valorOpcion)` | Marca `selected` comparando de forma segura |

### 8.5 Otros detalles de VBScript a tener presentes

- **No existe `IIf` nativo** (esta en VBA, no en VBScript): se implementa en
  `Security.asp`.
- **Los identificadores no pueden empezar por doble guion bajo** (`__var`
  produce “Caracter no valido”).
- **No usar `CLng(valor & 0)`** para convertir: si el valor ya es `"1"`, la
  concatenacion forma `"10"`. Para eso existe `ToLong(valor, respaldo)`.
- Los `Recordset` abiertos desde un `Command` no permiten reasignar
  `ActiveConnection`; la conexion se cierra en `RsClose` usando la que el
  propio `Recordset` referencia.

---

## 9. Mantenimiento de datos

El script de datos de ejemplo de `BDD_PoliMusic` se ejecuto varias veces, por
lo que la base puede contener filas repetidas (por ejemplo 15 albumes donde
deberia haber 5). Para dejarla consistente:

```bash
sqlcmd -S localhost -d BDD_PoliMusic -U usr_polimusic -P <clave> -C \
       -i sql/limpiar-duplicados.sql
```

El script **conserva la primera aparicion** de cada registro y trabaja dentro
de una transaccion. Por defecto termina en `ROLLBACK`: revise el diagnostico
que imprime y descomente `COMMIT TRANSACTION` para aplicar los cambios.
Haga una copia de seguridad antes de ejecutarlo.
