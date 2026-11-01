<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#fef9f5" />
    <title>PoliMusic · Canciones</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        
        :root {
            --brand: #eb7d1e; --brand-light: #d35400; --brand-dark: #c0560f;
            --grad: linear-gradient(135deg, #f39c12 0%, #eb7d1e 55%, #d35400 100%);
            --grad-soft: linear-gradient(135deg, rgba(235,125,30,.14), rgba(243,156,18,.06));
            --bg: #fef9f5; --card: #ffffff; --cream: #fffdfb;
            --text: #2c3e50; --muted: #8a6a55; --muted-dim: #a98f7c;
            --line: #fae5d3; --line-2: #f4d0a9;
            --ok: #1e9e6a; --danger: #c0392b;
            --r-sm: 14px; --r-md: 18px; --r-lg: 26px; --r-xl: 34px;
            --shadow: 0 10px 30px rgba(235,125,30,.08);
            --glow: 0 10px 24px -12px rgba(235,125,30,.55);
            --side: 250px; --player: 92px; --top: 64px;
            --ease: cubic-bezier(.22,1,.36,1); --spring: cubic-bezier(.34,1.32,.64,1);
        }

        *, *::before, *::after { box-sizing: border-box; }
        html, body { min-height: 100%; }
        body {
            margin: 0; font-family: "Inter", -apple-system, "Segoe UI", Roboto, sans-serif;
            font-size: 15px; line-height: 1.5; color: var(--text); background: var(--bg);
            -webkit-font-smoothing: antialiased; overflow-x: hidden;
        }
        h1, h2, h3, h4 { font-family: "Outfit", "Inter", sans-serif; margin: 0; font-weight: 600; letter-spacing: -.02em; }
        p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        code { font-family: ui-monospace, Consolas, monospace; font-size: .92em; color: var(--brand-light); }
        button { font-family: inherit; font-size: inherit; color: inherit; background: none; border: 0; cursor: pointer; }
        svg { width: 20px; height: 20px; display: block; }
        ::selection { background: rgba(235,125,30,.3); }
        :focus-visible { outline: 2px solid var(--brand); outline-offset: 2px; border-radius: 8px; }

        .card { background: var(--card); border: 1px solid var(--line); box-shadow: var(--shadow); }

        /* ---------- Layout ---------- */
        .app { display: grid; grid-template-columns: var(--side) minmax(0,1fr); min-height: 100vh; }
        .workspace { min-width: 0; display: flex; flex-direction: column; }

        /* ---------- Sidebar ---------- */
        .sidebar {
            position: sticky; top: 0; height: 100vh; display: flex; flex-direction: column; gap: 28px;
            padding: 22px 14px calc(var(--player) + 14px); background: #fff; border-right: 1px solid var(--line);
        }
        .brand { display: flex; align-items: center; gap: 12px; padding: 2px 10px; }
        .brand-mark { width: 40px; height: 40px; border-radius: 13px; display: grid; place-items: center; background: var(--grad); color: #fff; box-shadow: var(--glow); }
        .brand-mark svg { width: 21px; height: 21px; }
        .brand-text { display: flex; flex-direction: column; line-height: 1.1; }
        .brand-name { font-family: "Outfit", sans-serif; font-size: 17px; font-weight: 700; color: var(--brand-light); }
        .brand-sub { font-size: 9.5px; letter-spacing: .2em; text-transform: uppercase; color: var(--muted-dim); font-weight: 600; }
        .nav { display: flex; flex-direction: column; gap: 3px; }
        .nav-label { font-size: 9.5px; letter-spacing: .2em; text-transform: uppercase; color: var(--muted-dim); font-weight: 700; padding: 0 12px 9px; }
        .nav-link {
            position: relative; display: flex; align-items: center; gap: 12px; padding: 11px 12px; border-radius: var(--r-sm);
            color: var(--muted); font-size: 14px; font-weight: 500; border: 1px solid transparent;
            transition: color .2s, background .2s, transform .2s var(--ease);
        }
        .nav-link svg { width: 18px; height: 18px; flex: none; }
        .nav-link:hover { color: var(--brand-light); background: rgba(235,125,30,.08); transform: translateX(2px); }
        .nav-link.is-active { color: var(--brand-light); background: var(--grad-soft); border-color: var(--line-2); }
        .nav-link.is-active::before { content: ""; position: absolute; left: -14px; top: 50%; transform: translateY(-50%); width: 3px; height: 20px; border-radius: 0 3px 3px 0; background: var(--brand); }
        .nav-link.is-soon { opacity: .5; cursor: default; }
        .nav-link.is-soon:hover { transform: none; background: none; color: var(--muted); }
        .nav-badge { margin-left: auto; font-size: 8.5px; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; color: var(--brand-light); background: rgba(235,125,30,.12); padding: 2px 7px; border-radius: 99px; }
        .side-foot { margin-top: auto; }
        .hint-card { border: 1px solid var(--line); border-radius: var(--r-md); padding: 14px 15px; background: var(--cream); }
        .hint-card h4 { font-size: 12.5px; margin-bottom: 6px; }
        .hint-card p { font-size: 11.5px; color: var(--muted); line-height: 1.6; }
        kbd { display: inline-block; min-width: 18px; text-align: center; font-family: inherit; font-size: 10px; font-weight: 700; background: var(--bg); border: 1px solid var(--line-2); border-bottom-width: 2px; border-radius: 5px; padding: 0 5px; color: var(--text); line-height: 1.5; }

        /* ---------- Topbar ---------- */
        .topbar {
            position: sticky; top: 0; z-index: 40; display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
            min-height: var(--top); padding: 12px 28px; background: rgba(255,255,255,.9);
            backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px); border-bottom: 1px solid var(--line);
        }
        .crumbs { display: flex; align-items: center; gap: 9px; font-size: 12.5px; color: var(--muted-dim); }
        .crumbs strong { color: var(--text); }
        .top-tools { margin-left: auto; display: flex; align-items: center; gap: 10px; }
        .search { position: relative; display: flex; align-items: center; }
        .search svg { position: absolute; left: 12px; width: 15px; height: 15px; color: var(--muted-dim); pointer-events: none; }
        .search input {
            width: 260px; max-width: 42vw; padding: 9px 40px 9px 36px; border-radius: 11px;
            background: #fff; border: 1px solid var(--line-2); color: var(--text); font-size: 13px; font-family: inherit;
            transition: border-color .2s, box-shadow .2s;
        }
        .search input:focus { outline: none; border-color: var(--brand); box-shadow: 0 0 0 3px rgba(235,125,30,.15); }
        .search kbd { position: absolute; right: 9px; pointer-events: none; }
        .user-chip { display: flex; align-items: center; gap: 10px; padding: 5px 13px 5px 5px; border-radius: 99px; background: #fff; border: 1px solid var(--line-2); }
        .avatar { width: 32px; height: 32px; border-radius: 50%; display: grid; place-items: center; overflow: hidden; background: var(--grad); color: #fff; font-size: 12px; font-weight: 700; }
        .avatar img { width: 100%; height: 100%; object-fit: cover; }
        .user-meta { display: flex; flex-direction: column; line-height: 1.2; min-width: 0; }
        .user-name { font-size: 12.5px; font-weight: 600; max-width: 190px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .user-role { font-size: 9.5px; letter-spacing: .09em; text-transform: uppercase; color: var(--brand-light); font-weight: 700; }

        /* ---------- Botones ---------- */
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 11px 17px; border-radius: var(--r-sm);
            font-size: 13.5px; font-weight: 600; line-height: 1; white-space: nowrap; border: 1px solid transparent;
            transition: transform .18s var(--spring), background .2s, border-color .2s, box-shadow .25s, color .2s;
        }
        .btn svg { width: 16px; height: 16px; }
        .btn:active { transform: scale(.97); }
        .btn-primary { background: var(--grad); color: #fff; box-shadow: var(--glow); }
        .btn-primary:hover { transform: translateY(-1px); }
        .btn-ghost { background: #fff; color: var(--muted); border-color: var(--line-2); }
        .btn-ghost:hover { color: var(--brand-light); background: var(--bg); }
        .btn-danger { background: rgba(192,57,43,.08); color: var(--danger); border-color: rgba(192,57,43,.3); }
        .btn-danger:hover { background: rgba(192,57,43,.15); }
        .btn-sm { padding: 9px 13px; font-size: 12.5px; border-radius: 11px; }
        .icon-btn {
            width: 34px; height: 34px; border-radius: 10px; padding: 0; flex: none; display: inline-grid; place-items: center;
            background: #fff; border: 1px solid var(--line-2); color: var(--muted); transition: all .18s;
        }
        .icon-btn svg { width: 16px; height: 16px; }
        .icon-btn:hover { color: var(--brand-light); background: var(--bg); transform: translateY(-1px); }
        .icon-btn.is-play { color: var(--brand-light); background: rgba(235,125,30,.1); }
        .icon-btn.is-play:hover { color: #fff; background: var(--grad); border-color: transparent; box-shadow: var(--glow); }
        .icon-btn[disabled] { opacity: .35; cursor: not-allowed; transform: none; }

        /* ---------- Contenido ---------- */
        .content { flex: 1; width: 100%; max-width: 1380px; margin: 0 auto; padding: 22px 28px calc(var(--player) + 44px); display: flex; flex-direction: column; gap: 16px; }

        /* ---------- Hero ---------- */
        .hero { position: relative; display: flex; align-items: center; gap: 28px; padding: 26px 30px; border-radius: var(--r-xl); overflow: hidden; }
        .hero::after { content: ""; position: absolute; inset: 0; pointer-events: none; background: radial-gradient(560px 240px at 86% 6%, rgba(243,156,18,.18), transparent 72%); }
        .hero-copy { position: relative; z-index: 1; display: flex; flex-direction: column; gap: 9px; min-width: 0; }
        .eyebrow { display: inline-flex; align-items: center; gap: 8px; font-size: 10px; font-weight: 700; letter-spacing: .2em; text-transform: uppercase; color: var(--brand-light); }
        .eyebrow .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--brand); }
        .hero h1 { font-size: 36px; font-weight: 700; letter-spacing: -.04em; line-height: 1.04; color: var(--brand-light); }
        .hero h1 em { font-style: normal; background: var(--grad); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; color: transparent; }
        .hero-sub { font-size: 13.5px; color: var(--muted); max-width: 580px; line-height: 1.65; }
        .hero-sub strong { color: var(--text); }
        .hero-actions { display: flex; align-items: center; gap: 10px; margin-top: 6px; flex-wrap: wrap; }
        .hero-art { position: relative; z-index: 1; margin-left: auto; flex: none; }
        .disc {
            position: relative; width: 130px; height: 130px; border-radius: 50%; display: grid; place-items: center;
            background: radial-gradient(circle at 32% 26%, rgba(255,255,255,.2), transparent 46%), repeating-radial-gradient(circle at 50% 50%, #3a2418 0 2px, #25160e 2px 5px);
            box-shadow: 0 20px 40px -20px rgba(211,84,0,.6); animation: spin 22s linear infinite;
        }
        .disc-label { width: 50px; height: 50px; border-radius: 50%; display: grid; place-items: center; background: var(--grad); color: #fff; font-size: 20px; }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ---------- Stats ---------- */
        .stats { display: grid; grid-template-columns: repeat(3, minmax(0,1fr)); gap: 14px; }
        .stat { padding: 13px 16px; border-radius: var(--r-md); display: flex; flex-direction: column; gap: 7px; transition: transform .25s var(--ease), border-color .25s; }
        .stat:hover { transform: translateY(-2px); border-color: var(--line-2); }
        .stat-top { display: flex; align-items: center; gap: 8px; font-size: 10.5px; font-weight: 600; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }
        .stat-top svg { width: 14px; height: 14px; color: var(--brand); }
        .stat-value { font-family: "Outfit", sans-serif; font-size: 24px; font-weight: 700; line-height: 1; color: var(--brand-light); }

        /* ---------- Panel + GridView ---------- */
        .panel { border-radius: var(--r-lg); padding: 22px 24px 24px; display: flex; flex-direction: column; gap: 15px; }
        .panel-head { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .panel-title { display: flex; align-items: center; gap: 10px; }
        .panel-title h2 { font-size: 17.5px; }
        .chip { font-size: 10px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase; color: var(--brand-light); background: rgba(235,125,30,.12); border: 1px solid var(--line-2); padding: 3px 9px; border-radius: 99px; white-space: nowrap; }
        .panel-tools { margin-left: auto; }

        .tracks { width: 100%; border-collapse: separate !important; border-spacing: 0 3px; }
        .tracks th {
            padding: 0 12px 9px; text-align: left; font-size: 10px; font-weight: 700; letter-spacing: .16em; text-transform: uppercase;
            color: var(--muted-dim); border-bottom: 1px solid var(--line);
        }
        .tracks td { padding: 8px 12px; vertical-align: middle; background: var(--cream); border-top: 1px solid transparent; border-bottom: 1px solid transparent; transition: background .2s; }
        .tracks tr:nth-child(even) td { background: var(--bg); }
        .tracks td:first-child { border-left: 1px solid transparent; border-radius: var(--r-sm) 0 0 var(--r-sm); }
        .tracks td:last-child { border-right: 1px solid transparent; border-radius: 0 var(--r-sm) var(--r-sm) 0; }
        .tracks tr:hover td { background: var(--line); }
        .tracks tr.is-playing td { background: #fde7d0; border-top-color: var(--brand); border-bottom-color: var(--brand); }
        .tracks tr.is-playing td:first-child { border-left-color: var(--brand); }
        .tracks tr.is-playing td:last-child { border-right-color: var(--brand); }
        .tracks tr.is-playing .track-name { color: var(--brand-light); }
        .tracks .c-idx { width: 54px; text-align: center; font-size: 11.5px; color: var(--muted-dim); font-variant-numeric: tabular-nums; }
        .tracks th.c-idx { text-align: center; }
        .tracks .c-plays { width: 130px; text-align: right; font-size: 12.5px; color: var(--muted); font-variant-numeric: tabular-nums; }
        .tracks .c-actions { width: 210px; text-align: right; }
        .row-actions { display: flex; align-items: center; justify-content: flex-end; gap: 5px; }

        .song-cell { display: flex; align-items: center; gap: 14px; min-width: 0; }
        .cover {
            position: relative; flex: none; width: 46px; height: 46px; border-radius: 12px; display: grid; place-items: center; overflow: hidden;
            font-family: "Outfit", sans-serif; font-size: 17px; font-weight: 700; color: #fff;
            background: linear-gradient(135deg, #f39c12, #d35400); box-shadow: 0 8px 16px -10px rgba(211,84,0,.8);
        }
        .tracks tr:nth-child(6n+3) .cover { background: linear-gradient(135deg, #f5b041, #eb7d1e); }
        .tracks tr:nth-child(6n+4) .cover { background: linear-gradient(135deg, #eb7d1e, #a04000); }
        .tracks tr:nth-child(6n+5) .cover { background: linear-gradient(135deg, #f8c471, #e67e22); }
        .tracks tr:nth-child(6n+6) .cover { background: linear-gradient(135deg, #f39c12, #b9460b); }
        .tracks tr:nth-child(6n+7) .cover { background: linear-gradient(135deg, #eb984e, #873600); }
        .eq { display: none; position: absolute; inset: 0; align-items: flex-end; justify-content: center; gap: 2px; padding-bottom: 12px; background: rgba(60,25,5,.55); }
        .tracks tr.is-playing .eq { display: flex; }
        .eq i { display: block; width: 2.5px; height: 10px; border-radius: 2px; background: #fff; animation: eq 1s ease-in-out infinite; }
        .eq i:nth-child(2) { animation-delay: .16s; }
        .eq i:nth-child(3) { animation-delay: .32s; }
        @keyframes eq { 0%,100% { height: 4px; } 50% { height: 13px; } }

        .track-text { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .track-name { display: flex; align-items: center; gap: 8px; font-size: 13.5px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .track-file { font-size: 11.5px; color: var(--muted-dim); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .track-meta { display: none; }
        .flag { display: inline-flex; align-items: center; gap: 4px; flex: none; font-size: 9px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase; color: #b9770e; background: rgba(243,156,18,.14); border: 1px solid rgba(243,156,18,.35); padding: 1px 7px; border-radius: 99px; }
        .flag svg { width: 10px; height: 10px; }

        a.link-action {
            font-size: 10px; font-weight: 700; letter-spacing: .07em; text-transform: uppercase; color: var(--muted-dim);
            padding: 7px 9px; border-radius: 9px; border: 1px solid transparent; white-space: nowrap; transition: all .18s;
        }
        a.link-action:hover { color: var(--brand-light); background: rgba(235,125,30,.1); border-color: var(--line-2); }
        a.link-action.is-danger:hover { color: var(--danger); background: rgba(192,57,43,.08); border-color: rgba(192,57,43,.28); }

        .empty { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 50px 20px; text-align: center; }
        .empty[hidden] { display: none; }
        .empty-icon { width: 56px; height: 56px; border-radius: var(--r-md); display: grid; place-items: center; background: rgba(235,125,30,.1); border: 1px solid var(--line-2); color: var(--brand); margin-bottom: 4px; }
        .empty-icon svg { width: 25px; height: 25px; }
        .empty h3 { font-size: 16.5px; }
        .empty p { font-size: 13px; color: var(--muted); max-width: 380px; line-height: 1.6; }
        .empty .btn { margin-top: 8px; }
        .foot { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; font-size: 11.5px; color: var(--muted-dim); padding: 0 6px 4px; }
        .foot .sep { width: 3px; height: 3px; border-radius: 50%; background: currentColor; opacity: .55; }

        /* ---------- Reproductor ---------- */
        .player {
            position: fixed; left: 0; right: 0; bottom: 0; z-index: 60; height: var(--player); display: grid;
            grid-template-columns: minmax(190px,1fr) minmax(300px,2fr) minmax(150px,1fr); align-items: center; gap: 20px; padding: 0 24px;
            background: rgba(255,255,255,.95); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);
            border-top: 1px solid var(--line-2); box-shadow: 0 -10px 30px -18px rgba(235,125,30,.4);
        }
        .player::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 1px; background: linear-gradient(90deg, transparent, var(--brand), transparent); }
        .player-track { display: flex; align-items: center; gap: 12px; min-width: 0; }
        .player .cover { width: 54px; height: 54px; border-radius: 13px; font-size: 19px; }
        .player-meta { display: flex; flex-direction: column; gap: 2px; min-width: 0; }
        .player-title { font-size: 13px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .player-sub { font-size: 11px; color: var(--muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .player-center { display: flex; flex-direction: column; align-items: center; gap: 7px; }
        .controls { display: flex; align-items: center; gap: 12px; }
        .pc { width: 34px; height: 34px; border-radius: 50%; display: grid; place-items: center; color: var(--muted); transition: color .18s, transform .18s var(--spring), background .18s; }
        .pc svg { width: 17px; height: 17px; }
        .pc:hover { color: var(--brand-light); background: rgba(235,125,30,.1); }
        .pc:active { transform: scale(.92); }
        .pc.is-primary { width: 44px; height: 44px; color: #fff; background: var(--grad); box-shadow: var(--glow); }
        .pc.is-primary svg { width: 19px; height: 19px; }
        .pc.is-primary:hover { transform: scale(1.06); color: #fff; }
        .timeline { display: flex; align-items: center; gap: 9px; width: 100%; max-width: 520px; }
        .timeline span { font-size: 10.5px; color: var(--muted-dim); font-variant-numeric: tabular-nums; min-width: 32px; text-align: center; }
        input[type=range] {
            -webkit-appearance: none; appearance: none; width: 100%; height: 4px; border-radius: 99px; outline: none; cursor: pointer;
            background: linear-gradient(to right, var(--brand) 0%, var(--brand) calc(var(--p,0) * 1%), var(--line-2) calc(var(--p,0) * 1%), var(--line-2) 100%);
        }
        input[type=range]::-webkit-slider-thumb { -webkit-appearance: none; appearance: none; width: 12px; height: 12px; border-radius: 50%; background: #fff; border: 2px solid var(--brand); box-shadow: 0 0 0 3px rgba(235,125,30,.18); }
        input[type=range]::-moz-range-thumb { width: 12px; height: 12px; border-radius: 50%; background: #fff; border: 2px solid var(--brand); }
        .player-right { display: flex; align-items: center; gap: 8px; justify-content: flex-end; }
        .player-right input[type=range] { max-width: 92px; }

        /* ---------- Modales ---------- */
        .modal { position: fixed; inset: 0; z-index: 100; display: none; align-items: center; justify-content: center; padding: 20px; }
        .modal.is-open { display: flex; }
        .modal-backdrop { position: absolute; inset: 0; background: rgba(80,40,10,.35); backdrop-filter: blur(4px); }
        .modal-card {
            position: relative; width: 100%; max-width: 500px; max-height: calc(100vh - 40px); overflow-y: auto; padding: 24px; border-radius: var(--r-lg);
            background: #fff; border: 1px solid var(--line-2); box-shadow: 0 30px 80px -30px rgba(235,125,30,.45); animation: pop .28s var(--spring);
        }
        @keyframes pop { from { opacity: 0; transform: translateY(14px) scale(.975); } to { opacity: 1; transform: none; } }
        .modal-head { display: flex; align-items: flex-start; gap: 13px; margin-bottom: 20px; }
        .modal-head h3 { font-size: 17.5px; }
        .modal-head p { font-size: 12.5px; color: var(--muted); margin-top: 4px; line-height: 1.55; }
        .modal-head .icon-btn { margin-left: auto; }
        .modal-icon { width: 40px; height: 40px; border-radius: 13px; flex: none; display: grid; place-items: center; background: rgba(235,125,30,.12); border: 1px solid var(--line-2); color: var(--brand); }
        .modal-icon svg { width: 19px; height: 19px; }
        .modal-icon.is-danger { background: rgba(192,57,43,.1); border-color: rgba(192,57,43,.28); color: var(--danger); }
        .field { margin-bottom: 15px; }
        .field label { display: flex; align-items: center; justify-content: space-between; gap: 8px; font-size: 12px; font-weight: 600; color: var(--muted); margin-bottom: 7px; }
        .field label .req { color: var(--brand-light); }
        .field .hint { font-size: 10.5px; color: var(--muted-dim); font-weight: 500; }
        .field input[type=text], .field input[type=file] { width: 100%; padding: 11px 13px; border-radius: 11px; background: var(--cream); border: 1px solid var(--line-2); color: var(--text); font-size: 13.5px; font-family: inherit; transition: border-color .2s, box-shadow .2s; }
        .field input[type=text]:focus { outline: none; border-color: var(--brand); box-shadow: 0 0 0 3px rgba(235,125,30,.15); }
        .field input[type=file] { padding: 8px 11px; font-size: 12.5px; color: var(--muted); }
        .field input[type=file]::file-selector-button { margin-right: 11px; padding: 6px 11px; border-radius: 8px; border: 1px solid var(--line-2); background: var(--bg); color: var(--brand-light); font-family: inherit; font-size: 11.5px; font-weight: 600; cursor: pointer; }
        .field-note { font-size: 11px; color: var(--muted-dim); margin-top: 6px; line-height: 1.55; }
        .form-alert { display: flex; align-items: flex-start; gap: 9px; padding: 11px 13px; border-radius: 11px; margin-bottom: 15px; background: rgba(192,57,43,.08); border: 1px solid rgba(192,57,43,.28); font-size: 12.5px; color: #a93226; line-height: 1.5; }
        .form-alert svg { width: 15px; height: 15px; flex: none; margin-top: 2px; color: var(--danger); }
        .modal-foot { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; flex-wrap: wrap; }
        .modal-foot .btn { min-width: 104px; }

        /* ---------- Toasts ---------- */
        .toasts { position: fixed; right: 20px; bottom: calc(var(--player) + 16px); z-index: 120; display: flex; flex-direction: column; gap: 9px; pointer-events: none; }
        .toast { display: flex; align-items: flex-start; gap: 10px; min-width: 250px; max-width: 370px; padding: 12px 14px; border-radius: 13px; background: #fff; border: 1px solid var(--line-2); box-shadow: 0 14px 34px -16px rgba(235,125,30,.5); pointer-events: auto; animation: toastIn .3s var(--spring); }
        @keyframes toastIn { from { opacity: 0; transform: translateX(18px); } to { opacity: 1; transform: none; } }
        .toast .t-icon { width: 25px; height: 25px; border-radius: 8px; flex: none; display: grid; place-items: center; }
        .toast .t-icon svg { width: 14px; height: 14px; }
        .toast.is-success .t-icon { background: rgba(30,158,106,.14); color: var(--ok); }
        .toast.is-error .t-icon { background: rgba(192,57,43,.12); color: var(--danger); }
        .toast.is-info .t-icon { background: rgba(235,125,30,.14); color: var(--brand); }
        .toast .t-body { display: flex; flex-direction: column; gap: 1px; min-width: 0; }
        .toast .t-title { font-size: 12.5px; font-weight: 600; }
        .toast .t-msg { font-size: 11.5px; color: var(--muted); line-height: 1.45; }

        /* ---------- Responsive ---------- */
        @media (max-width: 1000px) {
            .app { grid-template-columns: minmax(0,1fr); }
            .sidebar { display: none; }
            .content { padding: 18px 16px calc(var(--player) + 26px); }
            .topbar { padding: 11px 16px; }
            .tracks .c-plays, .tracks th.c-plays { display: none; }
        }
        @media (max-width: 900px) { .top-tools .search { display: none; } }
        @media (max-width: 760px) {
            .hero { flex-direction: column; align-items: flex-start; padding: 24px; gap: 18px; }
            .hero-art { display: none; }
            .hero h1 { font-size: 28px; }
            .stats { gap: 8px; }
            .stat { padding: 12px; }
            .stat-top { font-size: 8.5px; letter-spacing: .07em; }
            .stat-value { font-size: 20px; }
            .panel { padding: 18px 14px; }
            .panel-tools { width: 100%; margin-left: 0; }
            .panel-tools .search, .panel-tools .search input { width: 100%; max-width: none; }
            .tracks .c-actions { width: auto; }
            a.link-action { display: none; }
            .user-meta { display: none; }
            .player { grid-template-columns: minmax(0,1fr) auto; padding: 0 14px; gap: 10px; }
            .player-center .timeline, .player-right { display: none; }
            .foot { display: none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="app">

            <!-- ==================== SIDEBAR ==================== -->
            <aside class="sidebar">
                <a class="brand" href="Default.aspx" title="PoliMusic">
                    <span class="brand-mark">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                    </span>
                    <span class="brand-text">
                        <span class="brand-name">PoliMusic</span>
                        <span class="brand-sub">Web App</span>
                    </span>
                </a>

                <nav class="nav" aria-label="Navegación principal">
                    <span class="nav-label">Descubrir</span>
                    <a class="nav-link is-active" href="Song.aspx" aria-current="page">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                        <span>Canciones</span>
                    </a>
                    <span class="nav-link is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1.6" /><rect x="14" y="3" width="7" height="7" rx="1.6" /><rect x="3" y="14" width="7" height="7" rx="1.6" /><rect x="14" y="14" width="7" height="7" rx="1.6" /></svg>
                        <span>Playlists</span><span class="nav-badge">Pronto</span>
                    </span>
                    <span class="nav-link is-soon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15a4 4 0 0 0 4-4V6a4 4 0 0 0-8 0v5a4 4 0 0 0 4 4Z" /><path d="M19 11a7 7 0 0 1-14 0" /><path d="M12 18v3" /></svg>
                        <span>Artistas</span><span class="nav-badge">Pronto</span>
                    </span>
                </nav>

                <div class="side-foot">
                    <div class="hint-card">
                        <h4>Atajos</h4>
                        <p>Busca con <kbd>/</kbd>, reproduce o pausa con <kbd>espacio</kbd>.</p>
                    </div>
                </div>
            </aside>

            <!-- ==================== WORKSPACE ==================== -->
            <div class="workspace">
                <header class="topbar">
                    <div class="crumbs">
                        <span>Biblioteca</span>
                        <span>/</span>
                        <strong>Canciones</strong>
                    </div>

                    <div class="top-tools">
                        <div class="search">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                            <input type="search" id="searchInput" placeholder="Buscar canción…" aria-label="Buscar canciones" autocomplete="off" />
                            <kbd>/</kbd>
                        </div>

                        <div class="user-chip" title="Sesión iniciada">
                            <span class="avatar"><asp:Literal ID="litAvatar" runat="server" /></span>
                            <span class="user-meta">
                                <span class="user-name"><asp:Literal ID="litUserName" runat="server" /></span>
                                <span class="user-role"><asp:Literal ID="litUserRole" runat="server" /></span>
                            </span>
                        </div>

                        <a class="btn btn-ghost btn-sm" href="Logout.aspx">Salir</a>
                    </div>
                </header>

                <main class="content">

                    <!-- HERO -->
                    <section class="hero card">
                        <div class="hero-copy">
                            <span class="eyebrow"><span class="dot"></span>Tu biblioteca</span>
                            <h1>Escucha tu <em>catálogo</em></h1>
                            <p class="hero-sub">
                                Hola <strong><asp:Literal ID="litHeroName" runat="server" /></strong>, estas son todas las
                                canciones registradas en <strong>TBL_SONG</strong>. Elige una pista de la lista y empieza a sonar.
                            </p>
                            <div class="hero-actions">
                                <button type="button" class="btn btn-primary" id="btnPlayAll">
                                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                                    Reproducir todo
                                </button>
                                <asp:Button ID="btnNew" runat="server" CssClass="btn btn-ghost" Text="+ Nueva canción" OnClick="btnNew_Click" CausesValidation="false" />
                            </div>
                        </div>

                        <div class="hero-art" aria-hidden="true">
                            <div class="disc"><span class="disc-label">&#9834;</span></div>
                        </div>
                    </section>

                    <!-- STATS -->
                    <section class="stats" aria-label="Resumen del catálogo">
                        <article class="stat card">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                                <span>Canciones</span>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatSongs" runat="server" /></div>
                        </article>
                        <article class="stat card">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 5.5v13l10-6.5-10-6.5Z" /></svg>
                                <span>Reproducciones</span>
                            </div>
                            <div class="stat-value"><span id="statPlays"><asp:Literal ID="litStatPlays" runat="server" /></span></div>
                        </article>
                        <article class="stat card">
                            <div class="stat-top">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M16 9a4 4 0 0 1 0 6" /></svg>
                                <span>Con audio</span>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatAudio" runat="server" /></div>
                        </article>
                    </section>

                    <!-- LISTA (GridView) -->
                    <section class="panel card">
                        <div class="panel-head">
                            <div class="panel-title">
                                <h2>Canciones</h2>
                                <span class="chip"><asp:Literal ID="litCountChip" runat="server" /></span>
                            </div>
                            <div class="panel-tools">
                                <div class="search">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                                    <input type="search" id="searchInline" placeholder="Filtrar por nombre…" aria-label="Filtrar canciones" autocomplete="off" />
                                </div>
                            </div>
                        </div>

                        <asp:GridView ID="gvSongs" runat="server" CssClass="tracks" AutoGenerateColumns="false"
                            GridLines="None" UseAccessibleHeader="true" OnRowCommand="gvSongs_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="#" HeaderStyle-CssClass="c-idx" ItemStyle-CssClass="c-idx">
                                    <ItemTemplate><%# RowNumber(Container.DataItemIndex) %></ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Canción">
                                    <ItemTemplate>
                                        <div class="song-cell">
                                            <div class="cover" aria-hidden="true">
                                                <span><%# SongInitial(Eval("SONG_NAME")) %></span>
                                                <span class="eq"><i></i><i></i><i></i></span>
                                            </div>
                                            <div class="track-text">
                                                <span class="track-name">
                                                    <%# HtmlText(Eval("SONG_NAME")) %>
                                                    <%# MissingFlag(Eval("SONG_PATH")) %>
                                                </span>
                                                <span class="track-file"><%# FileName(Eval("SONG_PATH")) %></span>
                                            </div>
                                            <span class="track-meta"
                                                data-id='<%# AttrEncode(Eval("ID_SONG")) %>'
                                                data-name='<%# AttrEncode(Eval("SONG_NAME")) %>'
                                                data-src='<%# AttrEncode(SongUrl(Eval("SONG_PATH"))) %>'
                                                data-available='<%# IsAvailable(Eval("SONG_PATH")) %>'></span>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Reproducciones" HeaderStyle-CssClass="c-plays" ItemStyle-CssClass="c-plays">
                                    <ItemTemplate><span data-plays-cell><%# PlaysText(Eval("PLAYS")) %></span></ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Acciones" HeaderStyle-CssClass="c-actions" ItemStyle-CssClass="c-actions">
                                    <ItemTemplate>
                                        <div class="row-actions">
                                            <button type="button" class="icon-btn is-play" data-play title="Reproducir" aria-label="Reproducir">
                                                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                                            </button>
                                            <asp:LinkButton ID="lnkEdit" runat="server" CssClass="link-action" CommandName="editSong" CommandArgument='<%# Eval("ID_SONG") %>' Text="Editar" CausesValidation="false" />
                                            <asp:LinkButton ID="lnkDelete" runat="server" CssClass="link-action is-danger" CommandName="deleteSong" CommandArgument='<%# Eval("ID_SONG") %>' Text="Eliminar" CausesValidation="false" />
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="empty">
                                    <span class="empty-icon">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                                    </span>
                                    <h3>Tu catálogo está vacío</h3>
                                    <p>Todavía no hay canciones registradas. Agrega la primera para empezar a escuchar música.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>

                        <div class="empty" id="noResults" hidden>
                            <span class="empty-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
                            </span>
                            <h3>Sin resultados</h3>
                            <p>No encontramos canciones que coincidan con tu búsqueda.</p>
                            <button type="button" class="btn btn-ghost" id="btnClearSearch">Limpiar filtro</button>
                        </div>
                    </section>

                    <div class="foot">
                        <span>PoliMusic</span>
                        <span class="sep"></span>
                        <span>ASP.NET WebForms · .NET Framework 2.0</span>
                        <span class="sep"></span>
                        <span>SQL Server · TBL_SONG</span>
                    </div>
                </main>
            </div>
        </div>

        <!-- ==================== MODAL FORMULARIO ==================== -->
        <asp:Panel ID="pnlFormModal" runat="server" CssClass="modal">
            <div class="modal-backdrop" data-close="1"></div>
            <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="formTitle">
                <div class="modal-head">
                    <span class="modal-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18V5l12-2v13" /><circle cx="6" cy="18" r="3" /><circle cx="18" cy="16" r="3" /></svg>
                    </span>
                    <div>
                        <h3 id="formTitle"><asp:Literal ID="litFormTitle" runat="server" /></h3>
                        <p>Completa los datos de la canción para guardarla en el catálogo.</p>
                    </div>
                    <button type="button" class="icon-btn" data-close="1" aria-label="Cerrar">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                    </button>
                </div>

                <asp:Literal ID="litFormError" runat="server" />
                <asp:HiddenField ID="hfSongId" runat="server" Value="0" />

                <div class="field">
                    <label for="txtSongName">
                        <span>Nombre de la canción <span class="req">*</span></span>
                        <span class="hint">máx. 50</span>
                    </label>
                    <asp:TextBox ID="txtSongName" runat="server" MaxLength="50" />
                </div>

                <div class="field">
                    <label for="txtSongPath">
                        <span>Ruta del archivo <span class="req">*</span></span>
                        <span class="hint">máx. 255</span>
                    </label>
                    <asp:TextBox ID="txtSongPath" runat="server" MaxLength="255" />
                    <datalist id="songFilesList"><asp:Literal ID="litSongFiles" runat="server" /></datalist>
                    <p class="field-note">Ruta lógica dentro del sitio, por ejemplo <code>~/songFiles/mi-cancion.mp3</code>.</p>
                </div>

                <div class="field">
                    <label for="fuSongFile">
                        <span>Subir archivo MP3</span>
                        <span class="hint">opcional · máx. 50 MB</span>
                    </label>
                    <asp:FileUpload ID="fuSongFile" runat="server" />
                    <p class="field-note">Si subes un archivo, la ruta se actualiza automáticamente con su nombre.</p>
                </div>

                <div class="modal-foot">
                    <button type="button" class="btn btn-ghost" data-close="1">Cancelar</button>
                    <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Text="Guardar" OnClick="btnSave_Click" />
                </div>
            </div>
        </asp:Panel>

        <!-- ==================== MODAL ELIMINAR ==================== -->
        <asp:Panel ID="pnlDeleteModal" runat="server" CssClass="modal">
            <div class="modal-backdrop" data-close="1"></div>
            <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="deleteTitle" style="max-width: 430px;">
                <div class="modal-head">
                    <span class="modal-icon is-danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="M19 6l-1 14H6L5 6" /><path d="M10 11v5" /><path d="M14 11v5" /></svg>
                    </span>
                    <div>
                        <h3 id="deleteTitle">Eliminar canción</h3>
                        <p>Esta acción no se puede deshacer. La canción también se quitará de las playlists donde aparezca.</p>
                    </div>
                    <button type="button" class="icon-btn" data-close="1" aria-label="Cerrar">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12" /><path d="M18 6 6 18" /></svg>
                    </button>
                </div>

                <p style="font-size: 13px; color: var(--muted);">
                    Vas a eliminar <strong style="color: var(--text);"><asp:Literal ID="litDeleteName" runat="server" /></strong> del catálogo.
                </p>

                <asp:HiddenField ID="hfDeleteId" runat="server" Value="0" />

                <div class="modal-foot">
                    <button type="button" class="btn btn-ghost" data-close="1">Cancelar</button>
                    <asp:Button ID="btnConfirmDelete" runat="server" CssClass="btn btn-danger" Text="Eliminar" OnClick="btnConfirmDelete_Click" />
                </div>
            </div>
        </asp:Panel>

        <div class="toasts" aria-live="polite"><asp:Literal ID="litToast" runat="server" /></div>
    </form>

    <!-- ==================== REPRODUCTOR ==================== -->
    <div class="player" role="region" aria-label="Reproductor de audio">
        <div class="player-track">
            <div class="cover" id="playerCover" aria-hidden="true"><span id="playerCoverText">&#9834;</span></div>
            <div class="player-meta">
                <span class="player-title" id="playerTitle">Ninguna canción seleccionada</span>
                <span class="player-sub" id="playerSub">Elige una pista de la lista</span>
            </div>
        </div>

        <div class="player-center">
            <div class="controls">
                <button type="button" class="pc" id="btnPrev" title="Anterior" aria-label="Canción anterior">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 5h2v14H6z" /><path d="M20 5.6v12.8a1 1 0 0 1-1.55.83l-9-6.4a1 1 0 0 1 0-1.66l9-6.4A1 1 0 0 1 20 5.6Z" /></svg>
                </button>
                <button type="button" class="pc is-primary" id="btnPlayPause" title="Reproducir / Pausar" aria-label="Reproducir">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z" /></svg>
                </button>
                <button type="button" class="pc" id="btnNext" title="Siguiente" aria-label="Siguiente canción">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M16 5h2v14h-2z" /><path d="M4 5.6v12.8a1 1 0 0 0 1.55.83l9-6.4a1 1 0 0 0 0-1.66l-9-6.4A1 1 0 0 0 4 5.6Z" /></svg>
                </button>
            </div>
            <div class="timeline">
                <span id="timeCurrent">0:00</span>
                <input type="range" id="seek" min="0" max="100" value="0" step="0.1" aria-label="Progreso de la canción" style="--p: 0" />
                <span id="timeTotal">0:00</span>
            </div>
        </div>

        <div class="player-right">
            <button type="button" class="pc" id="btnMute" title="Silenciar" aria-label="Silenciar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H3v6h3l5 4V5Z" /><path d="M16 9a4 4 0 0 1 0 6" /><path d="M19 6a8 8 0 0 1 0 12" /></svg>
            </button>
            <input type="range" id="volume" min="0" max="1" step="0.01" value="0.8" aria-label="Volumen" style="--p: 80" />
        </div>

        <audio id="pmAudio" preload="metadata"></audio>
    </div>

    <script type="text/javascript">
        (function () {
            "use strict";

            var audio = document.getElementById("pmAudio");
            if (!audio) { return; }

            var ICON_PLAY = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.5v13a1 1 0 0 0 1.53.85l10-6.5a1 1 0 0 0 0-1.7l-10-6.5A1 1 0 0 0 8 5.5Z"/></svg>';
            var ICON_PAUSE = '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="7" y="5" width="3.6" height="14" rx="1.2"/><rect x="13.4" y="5" width="3.6" height="14" rx="1.2"/></svg>';
            var COVERS = [
                "linear-gradient(135deg,#f39c12,#d35400)", "linear-gradient(135deg,#f5b041,#eb7d1e)",
                "linear-gradient(135deg,#eb7d1e,#a04000)", "linear-gradient(135deg,#f8c471,#e67e22)",
                "linear-gradient(135deg,#f39c12,#b9460b)", "linear-gradient(135deg,#eb984e,#873600)"
            ];

            /* Filas del GridView: las que traen su <span class="track-meta"> */
            var rows = [].slice.call(document.querySelectorAll("#gvSongs tr")).filter(function (tr) {
                return tr.querySelector(".track-meta") !== null;
            });
            function meta(row, key) { return row.querySelector(".track-meta").getAttribute("data-" + key); }
            var playable = rows.filter(function (row) { return meta(row, "available") === "1"; });

            var btnPlayPause = document.getElementById("btnPlayPause");
            var btnPrev = document.getElementById("btnPrev");
            var btnNext = document.getElementById("btnNext");
            var btnMute = document.getElementById("btnMute");
            var btnPlayAll = document.getElementById("btnPlayAll");
            var seek = document.getElementById("seek");
            var volume = document.getElementById("volume");
            var timeCurrent = document.getElementById("timeCurrent");
            var timeTotal = document.getElementById("timeTotal");
            var playerTitle = document.getElementById("playerTitle");
            var playerSub = document.getElementById("playerSub");
            var playerCover = document.getElementById("playerCover");
            var playerCoverText = document.getElementById("playerCoverText");

            var currentRow = null;
            var countedId = null;

            function formatTime(seconds) {
                if (!isFinite(seconds) || seconds < 0) { return "0:00"; }
                var total = Math.floor(seconds);
                var minutes = Math.floor(total / 60);
                var rest = total % 60;
                return minutes + ":" + (rest < 10 ? "0" + rest : rest);
            }
            function setFill(el, percent) { if (el) { el.style.setProperty("--p", percent); } }
            function highlightRow(row) {
                rows.forEach(function (item) { item.classList.remove("is-playing"); });
                if (row) { row.classList.add("is-playing"); }
            }
            function updatePlayIcon(playing) {
                btnPlayPause.innerHTML = playing ? ICON_PAUSE : ICON_PLAY;
                btnPlayPause.setAttribute("aria-label", playing ? "Pausar" : "Reproducir");
            }

            /* Contador de reproducciones (SongPlay.ashx llama a BLL.Song.IncrementPlays) */
            function registerPlay(row) {
                var id = meta(row, "id");
                if (!id || countedId === id) { return; }
                countedId = id;
                try {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", "SongPlay.ashx?id=" + encodeURIComponent(id), true);
                    xhr.onload = function () {
                        if (xhr.status !== 200) { return; }
                        try {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.ok) {
                                var cell = row.querySelector("[data-plays-cell]");
                                if (cell) { cell.textContent = data.plays; }
                                var stat = document.getElementById("statPlays");
                                if (stat) { stat.textContent = (parseInt(stat.textContent, 10) || 0) + 1; }
                            }
                        } catch (error) { }
                    };
                    xhr.send();
                } catch (error) { }
            }

            function startAudio(row) {
                var result = audio.play();
                if (result && typeof result.then === "function") {
                    result.then(function () {
                        updatePlayIcon(true);
                        if (row) { registerPlay(row); }
                    }, function () { updatePlayIcon(false); });
                } else {
                    updatePlayIcon(true);
                    if (row) { registerPlay(row); }
                }
            }

            function loadRow(row, autoplay) {
                if (!row) { return; }
                var src = meta(row, "src");
                if (!src) { return; }

                currentRow = row;
                countedId = null;
                highlightRow(row);

                var name = meta(row, "name") || "Canción";
                playerTitle.textContent = name;
                playerSub.textContent = "PoliMusic";
                playerCover.style.background = COVERS[(parseInt(meta(row, "id"), 10) || 0) % COVERS.length];
                playerCoverText.textContent = name.charAt(0).toUpperCase();
                document.title = name + " · PoliMusic";

                audio.src = src;
                seek.value = 0;
                setFill(seek, 0);
                timeCurrent.textContent = "0:00";
                timeTotal.textContent = "0:00";

                if (autoplay) { startAudio(row); }
            }

            function step(offset) {
                if (playable.length === 0) { return; }
                var index = currentRow ? playable.indexOf(currentRow) : -1;
                index = (index < 0) ? 0 : (index + offset + playable.length) % playable.length;
                loadRow(playable[index], true);
            }

            function togglePlayPause() {
                if (!currentRow) {
                    if (playable.length > 0) { loadRow(playable[0], true); }
                    return;
                }
                if (audio.paused) { startAudio(currentRow); } else { audio.pause(); updatePlayIcon(false); }
            }

            btnPlayPause.addEventListener("click", togglePlayPause);
            btnPrev.addEventListener("click", function () { step(-1); });
            btnNext.addEventListener("click", function () { step(1); });
            if (btnPlayAll) {
                btnPlayAll.addEventListener("click", function () {
                    if (playable.length > 0) { loadRow(playable[0], true); }
                });
            }

            audio.addEventListener("timeupdate", function () {
                if (!audio.duration) { return; }
                var percent = (audio.currentTime / audio.duration) * 100;
                seek.value = percent;
                setFill(seek, percent.toFixed(2));
                timeCurrent.textContent = formatTime(audio.currentTime);
            });
            audio.addEventListener("loadedmetadata", function () { timeTotal.textContent = formatTime(audio.duration); });
            audio.addEventListener("ended", function () {
                updatePlayIcon(false);
                if (playable.length > 1) { step(1); }
            });
            audio.addEventListener("pause", function () { updatePlayIcon(false); });
            audio.addEventListener("play", function () { updatePlayIcon(true); });
            audio.addEventListener("error", function () {
                updatePlayIcon(false);
                if (currentRow) { playerSub.textContent = "No se pudo cargar el audio"; }
            });

            seek.addEventListener("input", function () {
                if (!audio.duration) { return; }
                audio.currentTime = (parseFloat(seek.value) / 100) * audio.duration;
                setFill(seek, parseFloat(seek.value).toFixed(2));
            });
            volume.addEventListener("input", function () {
                audio.volume = parseFloat(volume.value);
                audio.muted = audio.volume === 0;
                setFill(volume, (audio.volume * 100).toFixed(0));
            });
            btnMute.addEventListener("click", function () {
                audio.muted = !audio.muted;
                setFill(volume, audio.muted ? 0 : (audio.volume * 100).toFixed(0));
            });

            /* Botón play de cada fila del GridView */
            rows.forEach(function (row) {
                var button = row.querySelector("[data-play]");
                if (!button) { return; }
                if (meta(row, "available") !== "1") { button.disabled = true; }
                button.addEventListener("click", function () {
                    if (meta(row, "available") !== "1") { return; }
                    if (currentRow === row) { togglePlayPause(); } else { loadRow(row, true); }
                });
            });

            /* Filtro instantáneo */
            var searchTop = document.getElementById("searchInput");
            var searchInline = document.getElementById("searchInline");
            var noResults = document.getElementById("noResults");
            var btnClearSearch = document.getElementById("btnClearSearch");

            function applyFilter(term) {
                term = (term || "").toLowerCase().trim();
                var visible = 0;
                rows.forEach(function (row) {
                    var name = (meta(row, "name") || "").toLowerCase();
                    var match = term === "" || name.indexOf(term) >= 0;
                    row.style.display = match ? "" : "none";
                    if (match) { visible++; }
                });
                if (noResults) { noResults.hidden = !(visible === 0 && rows.length > 0); }
            }
            function syncSearch(source) {
                var value = source.value;
                if (searchTop && source !== searchTop) { searchTop.value = value; }
                if (searchInline && source !== searchInline) { searchInline.value = value; }
                applyFilter(value);
            }
            function focusSearch() {
                var target = (searchTop && searchTop.offsetParent !== null) ? searchTop : searchInline;
                if (target) { target.focus(); }
            }
            [searchTop, searchInline].forEach(function (input) {
                if (!input) { return; }
                input.addEventListener("input", function () { syncSearch(input); });
                input.addEventListener("keydown", function (event) {
                    if (event.key === "Enter") { event.preventDefault(); }
                });
            });
            if (btnClearSearch) {
                btnClearSearch.addEventListener("click", function () {
                    if (searchTop) { searchTop.value = ""; }
                    if (searchInline) { searchInline.value = ""; }
                    applyFilter("");
                    focusSearch();
                });
            }

            /* Modales */
            function closeModal(modal) { if (modal) { modal.classList.remove("is-open"); } }
            function findModal(node) {
                while (node && node !== document) {
                    if (node.classList && node.classList.contains("modal")) { return node; }
                    node = node.parentNode;
                }
                return null;
            }
            [].slice.call(document.querySelectorAll("[data-close]")).forEach(function (el) {
                el.addEventListener("click", function () { closeModal(findModal(el)); });
            });

            document.addEventListener("keydown", function (event) {
                var openModal = document.querySelector(".modal.is-open");
                if (event.key === "Escape" && openModal) { closeModal(openModal); return; }
                var tag = (event.target.tagName || "").toLowerCase();
                var typing = tag === "input" || tag === "textarea" || tag === "select" || tag === "button" || tag === "a";
                if (event.key === "/" && !typing) { event.preventDefault(); focusSearch(); }
                if (event.key === " " && !typing && !openModal) { event.preventDefault(); togglePlayPause(); }
            });

            /* Toasts */
            [].slice.call(document.querySelectorAll(".toast")).forEach(function (toast) {
                setTimeout(function () {
                    toast.style.transition = "opacity .35s ease, transform .35s ease";
                    toast.style.opacity = "0";
                    toast.style.transform = "translateX(18px)";
                    setTimeout(function () { if (toast.parentNode) { toast.parentNode.removeChild(toast); } }, 400);
                }, 4500);
            });

            updatePlayIcon(false);
            audio.volume = 0.8;
        })();
    </script>
</body>
</html>
