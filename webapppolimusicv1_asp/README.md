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

El rol se guarda en `TBL_USER.USER_TYPE` (`0` = normal, `1` = administrador).

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
