using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        public int CheckExistSong(string songName, int idSong)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName, idSong);
        }

        public string Validate(Entities.Song song)
        {
            if (song == null)
            {
                return "No se recibió la información de la canción.";
            }
            if (song.SongName == null || song.SongName.Trim() == string.Empty)
            {
                return "El nombre de la canción es obligatorio.";
            }
            if (song.SongName.Trim().Length > 50)
            {
                return "El nombre de la canción no puede superar los 50 caracteres.";
            }
            if (song.SongPath == null || song.SongPath.Trim() == string.Empty)
            {
                return "Debes indicar la ruta del archivo de audio.";
            }
            if (song.SongPath.Trim().Length > 255)
            {
                return "La ruta del archivo no puede superar los 255 caracteres.";
            }
            return string.Empty;
        }

        public string ValidationsDuplicated(Entities.Song song)
        {
            int returnValue = (song.ID > 0)
                ? CheckExistSong(song.SongName, song.ID)
                : CheckExistSong(song.SongName);
            if (returnValue != 0)
            {
                return "Ya existe una canción con ese nombre!.";
            }
            return string.Empty;
        }
    }

}
