<%
' =====================================================================
'  footer.asp  -  Pie compartido + reproductor global persistente.
'  El audio vive aqui para que siga sonando al navegar entre paginas.
' =====================================================================
%>
</main>

<div class="playerbar" id="playerBar">
    <div class="playerbar-inner">
        <div class="now-playing">
            <img id="npCover" src="/assets/albumImages/album1.png" alt="">
            <div class="np-meta">
                <span id="npTitle" class="np-title">Sin reproduccion</span>
                <span id="npArtist" class="np-artist">Selecciona una cancion</span>
            </div>
        </div>

        <div class="player-controls">
            <button class="pc-btn" id="btnPrev" title="Anterior" type="button">
                <svg viewBox="0 0 24 24" fill="none"><path d="M19 20L9 12l10-8v16zM5 19V5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </button>
            <button class="pc-btn pc-main" id="btnPlay" title="Reproducir / Pausar" type="button">
                <svg id="icoPlay" viewBox="0 0 24 24" fill="none"><path d="M8 5l11 7-11 7V5z" fill="currentColor"/></svg>
                <svg id="icoPause" viewBox="0 0 24 24" fill="none" style="display:none"><path d="M9 5v14M15 5v14" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"/></svg>
            </button>
            <button class="pc-btn" id="btnNext" title="Siguiente" type="button">
                <svg viewBox="0 0 24 24" fill="none"><path d="M5 4l10 8-10 8V4zM19 5v14" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </button>
        </div>

        <div class="player-progress">
            <span id="curTime" class="ptime">0:00</span>
            <input type="range" id="seek" value="0" min="0" max="100" step="0.1" aria-label="Progreso">
            <span id="durTime" class="ptime">0:00</span>
            <button class="pc-btn pc-small" id="btnMute" title="Silenciar" type="button">
                <svg viewBox="0 0 24 24" fill="none"><path d="M11 5L6 9H3v6h3l5 4V5z" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/><path d="M16 9a4 4 0 0 1 0 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
            </button>
        </div>
    </div>
    <audio id="audioPlayer" preload="metadata"></audio>
</div>

<script src="/js/player.js"></script>
</body>
</html>
