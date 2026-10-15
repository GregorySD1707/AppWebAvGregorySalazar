/* =====================================================================
   player.js  -  Reproductor de audio y playlist de la sesion.
   Mantiene la cancion y el estado en sessionStorage para que la musica
   siga sonando al navegar entre paginas (la barra es persistente).
   ===================================================================== */
(function () {
    "use strict";

    var audio = document.getElementById("audioPlayer");
    var bar   = document.getElementById("playerBar");
    if (!audio || !bar) { return; }

    var el = {
        cover:  document.getElementById("npCover"),
        title:  document.getElementById("npTitle"),
        artist: document.getElementById("npArtist"),
        play:   document.getElementById("btnPlay"),
        prev:   document.getElementById("btnPrev"),
        next:   document.getElementById("btnNext"),
        mute:   document.getElementById("btnMute"),
        seek:   document.getElementById("seek"),
        cur:    document.getElementById("curTime"),
        dur:    document.getElementById("durTime"),
        icoPlay:  document.getElementById("icoPlay"),
        icoPause: document.getElementById("icoPause")
    };

    var KEY = "polimusic.player";

    function readState() {
        try { return JSON.parse(sessionStorage.getItem(KEY)) || {}; }
        catch (e) { return {}; }
    }
    function writeState(s) {
        try { sessionStorage.setItem(KEY, JSON.stringify(s)); } catch (e) {}
    }

    function fmt(sec) {
        if (!isFinite(sec) || sec < 0) { return "0:00"; }
        var m = Math.floor(sec / 60), s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    /* --- Estado publico que leen las tablas --- */
    var queue = [];
    var index = -1;

    function current() { return queue[index] || null; }

    function highlightRow() {
        var rows = document.querySelectorAll("tr[data-song-id]");
        for (var i = 0; i < rows.length; i++) {
            var match = current() && rows[i].getAttribute("data-song-id") === String(current().id);
            rows[i].classList.toggle("is-playing", !!match);
        }
    }

    function paintMeta() {
        var s = current();
        if (!s) {
            el.title.textContent  = "Sin reproduccion";
            el.artist.textContent = "Selecciona una cancion";
            return;
        }
        el.title.textContent  = s.name;
        el.artist.textContent = s.artist || "Artista desconocido";
        if (s.cover) { el.cover.src = s.cover; }
        document.title = s.name + " \u00b7 PoliMusic";
    }

    function setPlayIcon(playing) {
        el.icoPlay.style.display  = playing ? "none" : "";
        el.icoPause.style.display = playing ? "" : "none";
    }

    function persist(keepTime) {
        var s = current();
        writeState({
            queue: queue,
            index: index,
            time: keepTime ? audio.currentTime : 0,
            volume: audio.volume,
            muted: audio.muted
        });
    }

    function playIndex(i, restoreTime) {
        if (i < 0 || i >= queue.length) { return; }
        index = i;
        var s = current();
        if (!s || !s.url) { return; }

        audio.src = s.url;
        paintMeta();
        highlightRow();

        audio.addEventListener("loadedmetadata", function once() {
            audio.removeEventListener("loadedmetadata", once);
            if (restoreTime) { audio.currentTime = restoreTime; }
        });

        var p = audio.play();
        if (p && p.catch) {
            p.catch(function () { setPlayIcon(false); });
        }
        persist(restoreTime);
    }

    /* --- API expuesta a las paginas --- */
    window.PoliPlayer = {
        setQueue: function (songs) { queue = songs || []; },
        getIndex: function () { return index; },
        load: function (songs, idx, startTime) {
            queue = songs || [];
            playIndex(idx, startTime || 0);
        },
        play: function (i) { playIndex(i, 0); },
        toggle: function () {
            if (!current()) {
                if (queue.length) { playIndex(0, 0); }
                return;
            }
            if (audio.paused) { audio.play(); } else { audio.pause(); }
        }
    };

    /* --- Controles --- */
    el.play.addEventListener("click", function () { window.PoliPlayer.toggle(); });

    el.next.addEventListener("click", function () {
        if (queue.length) { playIndex((index + 1) % queue.length, 0); }
    });

    el.prev.addEventListener("click", function () {
        if (!queue.length) { return; }
        if (audio.currentTime > 3) { audio.currentTime = 0; return; }
        playIndex((index - 1 + queue.length) % queue.length, 0);
    });

    el.mute.addEventListener("click", function () {
        audio.muted = !audio.muted;
        el.mute.style.opacity = audio.muted ? ".5" : "1";
        persist(true);
    });

    el.seek.addEventListener("input", function () {
        if (isFinite(audio.duration) && audio.duration > 0) {
            audio.currentTime = (el.seek.value / 100) * audio.duration;
        }
    });

    audio.addEventListener("timeupdate", function () {
        el.cur.textContent = fmt(audio.currentTime);
        if (isFinite(audio.duration) && audio.duration > 0) {
            el.seek.value = (audio.currentTime / audio.duration) * 100;
        }
    });

    audio.addEventListener("loadedmetadata", function () {
        el.dur.textContent = fmt(audio.duration);
    });

    audio.addEventListener("play",  function () { setPlayIcon(true);  persist(true); });
    audio.addEventListener("pause", function () { setPlayIcon(false); persist(true); });
    audio.addEventListener("ended", function () {
        if (queue.length > 1) { playIndex((index + 1) % queue.length, 0); }
        else { setPlayIcon(false); }
    });

    /* --- Restauracion al cargar una pagina nueva --- */
    (function restore() {
        var st = readState();
        if (st.queue && st.queue.length) {
            queue = st.queue;
            index = (typeof st.index === "number") ? st.index : -1;
            if (st.volume !== undefined) { audio.volume = st.volume; }
            if (st.muted) { audio.muted = true; el.mute.style.opacity = ".5"; }
            if (current()) {
                audio.src = current().url;
                audio.currentTime = st.time || 0;
                paintMeta();
                highlightRow();
                var p = audio.play();
                if (p && p.catch) {
                    p.catch(function () {
                        setPlayIcon(false);
                        audio.addEventListener("canplay", function once() {
                            audio.removeEventListener("canplay", once);
                            audio.play().catch(function () {});
                        });
                    });
                }
            }
        }
    })();

    window.PoliPlayer.refreshHighlight = highlightRow;
})();
