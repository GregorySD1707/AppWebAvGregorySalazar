SET NOCOUNT ON;

/* =====================================================================
   limpiar-duplicados.sql
   ---------------------------------------------------------------------
   QUE HACE
     Elimina las filas DUPLICADAS que quedaron en BDD_PoliMusic porque
     el script de datos de ejemplo (los INSERT de BDD_PoliMusic.sql) se
     ejecuto tres veces sobre la misma base.

     Estado detectado:
       TBL_ALBUM     15 filas  (deberian ser  5)
       TBL_ARTIST    15 filas  (deberian ser  5)
       TBL_SONG      15 filas  (deberian ser  5)
       TBL_PLAYLIST  15 filas  (deberian ser  5)
       TBL_USER      11 filas  (deberian ser  3 + las que cree el usuario)

     Se conservan SIEMPRE los registros originales, es decir la PRIMERA
     aparicion de cada titulo (ID mas bajo: el de la primera ejecucion).

   COMO USARLO
     sqlcmd -S localhost -d BDD_PoliMusic -U usr_polimusic -P <clave> ^
            -C -i limpiar-duplicados.sql

   SEGURIDAD
     - Hacer copia de seguridad ANTES:
         BACKUP DATABASE BDD_PoliMusic TO DISK='C:\temp\PoliMusic.bak'
     - Todo el trabajo va dentro de una transaccion; al final se decide
       con COMMIT o ROLLBACK.
     - Ejecutar primero la seccion "DIAGNOSTICO" para revisar que es lo
       que se va a borrar.
   ===================================================================== */


/* ---------------------------------------------------------------------
   1) DIAGNOSTICO  (no borra nada)
   --------------------------------------------------------------------- */
PRINT '=== DIAGNOSTICO: duplicados detectados ===';

PRINT '-- TBL_ALBUM --';
SELECT TITLE_ALBUM, COUNT(*) AS veces,
       MIN(ID_ALBUM) AS se_conserva, MAX(ID_ALBUM) AS max_id
FROM TBL_ALBUM GROUP BY TITLE_ALBUM HAVING COUNT(*) > 1;

PRINT '-- TBL_ARTIST --';
SELECT ARTIST_NAME, ARTIST_LASTNAME, COUNT(*) AS veces,
       MIN(ID_ARTIST) AS se_conserva
FROM TBL_ARTIST GROUP BY ARTIST_NAME, ARTIST_LASTNAME HAVING COUNT(*) > 1;

PRINT '-- TBL_SONG --';
SELECT SONG_NAME, COUNT(*) AS veces, MIN(ID_SONG) AS se_conserva
FROM TBL_SONG GROUP BY SONG_NAME HAVING COUNT(*) > 1;

PRINT '-- TBL_PLAYLIST --';
SELECT TITLE, COUNT(*) AS veces, MIN(ID_PLAYLIST) AS se_conserva
FROM TBL_PLAYLIST GROUP BY TITLE HAVING COUNT(*) > 1;

PRINT '-- TBL_USER --';
SELECT USERNAME, COUNT(*) AS veces, MIN(ID_USER) AS se_conserva
FROM TBL_USER GROUP BY USERNAME HAVING COUNT(*) > 1;


/* ---------------------------------------------------------------------
   2) LIMPIEZA  (transaccional)
   --------------------------------------------------------------------- */
BEGIN TRANSACTION;

/* --- IDs que se van a eliminar -------------------------------------- */
DECLARE @delAlbum TABLE (id INT PRIMARY KEY);
DECLARE @delArtist TABLE (id INT PRIMARY KEY);
DECLARE @delSong  TABLE (id INT PRIMARY KEY);
DECLARE @delPlay  TABLE (id INT PRIMARY KEY);
DECLARE @delUser  TABLE (id INT PRIMARY KEY);

INSERT INTO @delAlbum (id) SELECT ID_ALBUM FROM TBL_ALBUM
WHERE ID_ALBUM NOT IN (SELECT MIN(ID_ALBUM) FROM TBL_ALBUM GROUP BY TITLE_ALBUM);

INSERT INTO @delArtist (id) SELECT ID_ARTIST FROM TBL_ARTIST
WHERE ID_ARTIST NOT IN (SELECT MIN(ID_ARTIST) FROM TBL_ARTIST GROUP BY ARTIST_NAME, ARTIST_LASTNAME);

INSERT INTO @delSong (id) SELECT ID_SONG FROM TBL_SONG
WHERE ID_SONG NOT IN (SELECT MIN(ID_SONG) FROM TBL_SONG GROUP BY SONG_NAME);

INSERT INTO @delPlay (id) SELECT ID_PLAYLIST FROM TBL_PLAYLIST
WHERE ID_PLAYLIST NOT IN (SELECT MIN(ID_PLAYLIST) FROM TBL_PLAYLIST GROUP BY TITLE);

/* Solo usuarios duplicados; nunca se toca la cuenta unica del usuario. */
INSERT INTO @delUser (id) SELECT ID_USER FROM TBL_USER
WHERE ID_USER NOT IN (SELECT MIN(ID_USER) FROM TBL_USER GROUP BY USERNAME);

PRINT 'Se eliminaran:';
SELECT 'albumes'   AS entidad, COUNT(*) AS filas FROM @delAlbum
UNION ALL SELECT 'artistas',  COUNT(*) FROM @delArtist
UNION ALL SELECT 'canciones', COUNT(*) FROM @delSong
UNION ALL SELECT 'playlists', COUNT(*) FROM @delPlay
UNION ALL SELECT 'usuarios',  COUNT(*) FROM @delUser;

/* --- Primero las tablas de relacion (claves foraneas) --------------- */
DELETE ps FROM TBL_PLAYLIST_SONG ps
WHERE ps.ID_PLAYLIST IN (SELECT id FROM @delPlay)
   OR ps.ID_SONG     IN (SELECT id FROM @delSong);

DELETE tr FROM TBL_TRACKLIST tr
WHERE tr.ID_ALBUM IN (SELECT id FROM @delAlbum)
   OR tr.ID_SONG  IN (SELECT id FROM @delSong);

DELETE pl FROM TBL_PLAYER pl
WHERE pl.ID_SONG   IN (SELECT id FROM @delSong)
   OR pl.ID_ARTIST IN (SELECT id FROM @delArtist);

/* --- Luego las tablas de entidad ------------------------------------ */
DELETE FROM TBL_PLAYLIST WHERE ID_PLAYLIST IN (SELECT id FROM @delPlay);
DELETE FROM TBL_ALBUM    WHERE ID_ALBUM    IN (SELECT id FROM @delAlbum);
DELETE FROM TBL_ARTIST   WHERE ID_ARTIST   IN (SELECT id FROM @delArtist);
DELETE FROM TBL_SONG     WHERE ID_SONG     IN (SELECT id FROM @delSong);
DELETE FROM TBL_USER     WHERE ID_USER     IN (SELECT id FROM @delUser);

/* ---------------------------------------------------------------------
   3) VERIFICACION dentro de la transaccion
   --------------------------------------------------------------------- */
PRINT '=== Conteos despues de la limpieza ===';
SELECT 'TBL_ALBUM'    AS tabla, COUNT(*) AS filas FROM TBL_ALBUM
UNION ALL SELECT 'TBL_ARTIST',   COUNT(*) FROM TBL_ARTIST
UNION ALL SELECT 'TBL_SONG',     COUNT(*) FROM TBL_SONG
UNION ALL SELECT 'TBL_PLAYLIST', COUNT(*) FROM TBL_PLAYLIST
UNION ALL SELECT 'TBL_USER',     COUNT(*) FROM TBL_USER
UNION ALL SELECT 'TBL_TRACKLIST',COUNT(*) FROM TBL_TRACKLIST
UNION ALL SELECT 'TBL_PLAYER',   COUNT(*) FROM TBL_PLAYER;

/* ---------------------------------------------------------------------
   DECISION FINAL
     Si los conteos son los esperados (5 canciones/albumes/artistas/
     playlists y el numero de usuarios correcto), descomente COMMIT.
     Si algo no cuadra, deje ROLLBACK para no cambiar nada.
   --------------------------------------------------------------------- */
-- COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

PRINT 'Transaccion revertida (ROLLBACK). Descomente COMMIT para aplicar.';
