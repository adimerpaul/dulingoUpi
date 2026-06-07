/* ===== Lumo — App principal (conectado a la API) ===== */
'use strict';

// ---- Verificar sesión ----
const TOKEN = localStorage.getItem('lumo_token');
if (!TOKEN) { window.location.href = './login.html'; }

const USER = JSON.parse(localStorage.getItem('lumo_user') || '{}');

// ---- Estado de la app ----
const STORE_KEY = 'lumo_game_v1';
let store = loadStore();
const PATH_OFFSET = [0, -52, -80, -52, 0, 56, 88, 56, 0, -52];

let APP = { secciones: [], currentSeccion: null };
let lesson = null;
const view = { screen: 'map', nav: 'aprender', activeDetalle: null, earnedXp: 0 };
const IS_ADMIN = USER.rol === 'Administrador' || Number(USER.id) === 1;
const ADMIN_RESOURCES = [
  { id: 'seccion', label: 'Seccion' },
  { id: 'seccion_detalle', label: 'Seccion detalle' },
  { id: 'preguntas', label: 'Preguntas' },
  { id: 'respuesta', label: 'Respuesta' },
  { id: 'usuario_seccion_detalle', label: 'Progreso usuario' },
];
let adminState = {
  resource: 'seccion',
  fields: [],
  rows: [],
  loading: false,
  error: '',
};

function loadStore() {
  try { return Object.assign({ hearts: 5, gems: 183, dailyPct: 40, xp: 0 }, JSON.parse(localStorage.getItem(STORE_KEY) || '{}')); }
  catch { return { hearts: 5, gems: 183, dailyPct: 40, xp: 0 }; }
}
function saveStore() { localStorage.setItem(STORE_KEY, JSON.stringify(store)); }

// ---- Iconos SVG ----
const S = 'fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"';
const ICON = {
  home:    (s=26) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.2"><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V20a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V9.5"/><path d="M9.5 21v-6h5v6"/></svg>`,
  league:  (s=26) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.2"><path d="M6 4h12v4a6 6 0 0 1-12 0z"/><path d="M6 6H4v1a3 3 0 0 0 3 3"/><path d="M18 6h2v1a3 3 0 0 1-3 3"/><path d="M9 20h6"/><path d="M12 14v6"/></svg>`,
  profile: (s=26) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.2"><circle cx="12" cy="8" r="4"/><path d="M5 20c0-3.6 3.1-6 7-6s7 2.4 7 6"/></svg>`,
  logout:  (s=26) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>`,
  check:   (s=32) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="3.2"><path d="m5 13 4 4L19 7"/></svg>`,
  star:    (s=32) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M12 3.5l2.6 5.3 5.9.85-4.25 4.15 1 5.85L12 16.9l-5.25 2.75 1-5.85L3.5 9.65l5.9-.85z"/></svg>`,
  book:    (s=32) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.2"><path d="M4 5a2 2 0 0 1 2-2h5v17H6a2 2 0 0 0-2 2z"/><path d="M20 5a2 2 0 0 0-2-2h-5v17h5a2 2 0 0 1 2 2z"/></svg>`,
  crown:   (s=32) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M3 8l3.5 3L12 5l5.5 6L21 8l-1.5 11h-15z"/></svg>`,
  chest:   (s=32) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M4 10h16v9H4z" opacity=".55"/><path d="M4 10V8a3 3 0 0 1 3-3h10a3 3 0 0 1 3 3v2z"/><rect x="10.5" y="9" width="3" height="5" rx="1" fill="#5a3d00"/></svg>`,
  flame:   (s=24) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M12 2c1 3-2 4-2 7 0 1.5 1 2.5 2 2.5S16 10 14 7c3 1.5 5 4.2 5 7.5a7 7 0 0 1-14 0c0-3.5 3-5.5 4-8 .8 1.5 2 1.6 3 3.5z"/></svg>`,
  gem:     (s=24) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M6 3h12l3 5-9 13L3 8z" opacity=".9"/><path d="m3 8 9 3 9-3-3 4-6 9-6-9z" fill="rgba(255,255,255,.25)"/></svg>`,
  heart:   (s=24) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M12 21S3.5 14.8 3.5 8.9A4.9 4.9 0 0 1 12 5.6 4.9 4.9 0 0 1 20.5 8.9C20.5 14.8 12 21 12 21z"/></svg>`,
  speaker: (s=28) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="currentColor"><path d="M4 9v6h4l5 4V5L8 9z"/><path d="M16 8.5a4 4 0 0 1 0 7" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>`,
  arrowL:  (s=22) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.6"><path d="M15 5l-7 7 7 7"/></svg>`,
  x:       (s=26) => `<svg viewBox="0 0 24 24" width="${s}" height="${s}" ${S} stroke-width="2.6"><path d="M6 6l12 12M18 6 6 18"/></svg>`,
};

function MASCOT(s=130) {
  return `<svg viewBox="0 0 130 130" width="${s}" height="${s}">
    <ellipse cx="50" cy="120" rx="11" ry="6" fill="#d97a18"/><ellipse cx="80" cy="120" rx="11" ry="6" fill="#d97a18"/>
    <path d="M34 38 L40 12 L54 32 Z" fill="#ff8a2a"/><path d="M96 38 L90 12 L76 32 Z" fill="#ff8a2a"/>
    <ellipse cx="65" cy="72" rx="42" ry="46" fill="#ff9a3d"/><ellipse cx="65" cy="82" rx="29" ry="33" fill="#ffd99a"/>
    <ellipse cx="22" cy="74" rx="10" ry="24" fill="#ff8a2a"/><ellipse cx="108" cy="74" rx="10" ry="24" fill="#ff8a2a"/>
    <circle cx="50" cy="56" r="20" fill="#fff"/><circle cx="80" cy="56" r="20" fill="#fff"/>
    <circle cx="53" cy="58" r="9" fill="#33271a"/><circle cx="77" cy="58" r="9" fill="#33271a"/>
    <circle cx="56" cy="54" r="3.4" fill="#fff"/><circle cx="80" cy="54" r="3.4" fill="#fff"/>
    <path d="M57 68 L73 68 L65 80 Z" fill="#ffb838"/></svg>`;
}
function TUTOR(s=96) {
  return `<svg viewBox="0 0 120 120" width="${s}" height="${s}">
    <ellipse cx="60" cy="110" rx="34" ry="8" fill="rgba(0,0,0,.25)"/>
    <ellipse cx="60" cy="78" rx="34" ry="30" fill="#2aa9f0"/><ellipse cx="60" cy="74" rx="26" ry="22" fill="#67c5ff" opacity=".5"/>
    <circle cx="60" cy="44" r="26" fill="#ffd9b0"/>
    <path d="M38 36c2-14 42-14 44 0 2 6-6 4-22 4s-24 2-22-4z" fill="#ff8a2a"/>
    <circle cx="51" cy="44" r="4.2" fill="#33271a"/><circle cx="69" cy="44" r="4.2" fill="#33271a"/>
    <circle cx="52.4" cy="42.6" r="1.4" fill="#fff"/><circle cx="70.4" cy="42.6" r="1.4" fill="#fff"/>
    <path d="M55 53q5 4 10 0" fill="none" stroke="#cf855a" stroke-width="2.4" stroke-linecap="round"/></svg>`;
}
function LOGO(s=34) {
  return `<svg viewBox="0 0 40 40" width="${s}" height="${s}">
    <rect x="2" y="2" width="36" height="36" rx="11" fill="#ff9a3d"/>
    <circle cx="14" cy="17" r="6.5" fill="#fff"/><circle cx="26" cy="17" r="6.5" fill="#fff"/>
    <circle cx="15" cy="18" r="3" fill="#33271a"/><circle cx="25" cy="18" r="3" fill="#33271a"/>
    <path d="M16 25 L24 25 L20 31 Z" fill="#ffb838"/></svg>`;
}

// ---- Convierte pregunta API → ejercicio del motor ----
function apiToExercise(p) {
  if (p.tipo_pregunta === 'multiple_choice') {
    const answerIdx = p.respuestas.findIndex(r => r.es_correcta);
    return { type: 'choice', q: p.nombre, options: p.respuestas.map(r => r.nombre), answer: answerIdx };
  }
  if (p.tipo_pregunta === 'build') {
    return { type: 'build', q: 'Traduce esta oración', prompt: p.nombre, ...p.config };
  }
  if (p.tipo_pregunta === 'match') {
    return { type: 'match', q: 'Empareja los pares', pairs: p.config.pairs };
  }
}

// ---- Render mapa ----
const NAV_ITEMS = [
  { id: 'aprender', label: 'Aprender', icon: 'home' },
  { id: 'ligas',    label: 'Ligas',    icon: 'league' },
  { id: 'perfil',   label: 'Perfil',   icon: 'profile' },
];
function navItems() {
  return IS_ADMIN ? [...NAV_ITEMS, { id: 'admin', label: 'Admin', icon: 'crown' }] : NAV_ITEMS;
}
const TIPO_ICON = { lesson: 'star', review: 'book', chest: 'chest', crown: 'crown' };

function getNodeStatus(index, detalles) {
  const completed = detalles.filter(d => d.realizado).length;
  if (index < completed) return 'done';
  if (index === completed) return 'active';
  return 'locked';
}

function nodeHTML(detalle, index, detalles) {
  const status = getNodeStatus(index, detalles);
  const kind   = detalle.tipo || 'lesson';
  let cls = 'node';
  if (status === 'done')   cls += (kind === 'lesson' ? ' done' : ' review');
  else if (status === 'active') cls += (kind === 'lesson' ? ' active' : ' review');
  else cls += ' locked';

  const iconFn   = ICON[status === 'done' ? 'check' : (TIPO_ICON[kind] || 'star')];
  const offset   = PATH_OFFSET[index % PATH_OFFSET.length];
  const completed = detalles.filter(d => d.realizado).length;
  const isMascot = index === Math.min(completed + 1, detalles.length - 1) && completed < detalles.length;
  const mascotSide = offset > 0 ? 'left:-96px;right:auto' : 'right:-96px';

  return `<div class="node-wrap" style="transform:translateX(${offset}px)">
    ${status === 'active' ? '<div class="start-bubble fred">EMPIEZA</div>' : ''}
    <button class="${cls}" data-act="start-node" data-id="${detalle.id}" data-i="${index}" ${status === 'locked' ? 'disabled' : ''} title="${detalle.nombre}">
      <span class="face">${iconFn()}</span>
    </button>
    ${isMascot ? `<div class="mascot-rest" style="${mascotSide}">${MASCOT(104)}</div>` : ''}
  </div>`;
}

function adminCell(field, value) {
  const raw = value ?? '';
  if (field === 'config') {
    return `<textarea class="admin-input admin-textarea" data-field="${field}">${String(raw).replace(/</g, '&lt;')}</textarea>`;
  }
  if (field === 'es_correcta' || field === 'realizado') {
    return `<input class="admin-check" type="checkbox" data-field="${field}" ${Number(raw) ? 'checked' : ''}>`;
  }
  return `<input class="admin-input" data-field="${field}" value="${String(raw).replace(/"/g, '&quot;')}">`;
}

function adminHTML() {
  if (!IS_ADMIN) {
    return `<div class="admin-panel"><h2 class="fred">Sin permisos</h2><p>No tienes acceso a administracion.</p></div>`;
  }

  const tabs = ADMIN_RESOURCES.map(r =>
    `<button class="admin-tab ${adminState.resource === r.id ? 'active' : ''}" data-act="admin-resource" data-resource="${r.id}">${r.label}</button>`
  ).join('');

  if (adminState.loading) {
    return `<div class="admin-panel"><div class="admin-head"><h2 class="fred">Administracion</h2></div><div class="admin-tabs">${tabs}</div><div class="spinner" style="margin:40px auto"></div></div>`;
  }

  const header = adminState.fields.map(f => `<th>${f}</th>`).join('');
  const rows = adminState.rows.map(row => `
    <tr data-id="${row.id}">
      <td class="admin-id">${row.id}</td>
      ${adminState.fields.map(f => `<td>${adminCell(f, row[f])}</td>`).join('')}
      <td><button class="btn btn-primary admin-save" data-act="admin-save">Guardar</button></td>
    </tr>
  `).join('');

  return `<div class="admin-panel">
    <div class="admin-head">
      <div>
        <p class="admin-kicker fred">Rol: Administrador</p>
        <h2 class="fred">Modificar tablas</h2>
      </div>
    </div>
    <div class="admin-tabs">${tabs}</div>
    ${adminState.error ? `<div class="admin-error">${adminState.error}</div>` : ''}
    <div class="admin-table-wrap">
      <table class="admin-table">
        <thead><tr><th>ID</th>${header}<th>Accion</th></tr></thead>
        <tbody>${rows || '<tr><td colspan="99">Sin registros</td></tr>'}</tbody>
      </table>
    </div>
  </div>`;
}

function mapHTML() {
  const sec      = APP.currentSeccion;
  const detalles = sec?.detalles || [];
  const completed = detalles.filter(d => d.realizado).length;

  const nodes    = detalles.map((d, i) => nodeHTML(d, i, detalles)).join('');
  const navSide  = navItems().map(n => `<button class="nav-item ${view.nav === n.id ? 'active' : ''}" data-act="nav" data-id="${n.id}">${ICON[n.icon]()}<span>${n.label}</span></button>`).join('');
  const navMob   = navItems().map(n => `<button class="mnav-btn ${view.nav === n.id ? 'active' : ''}" data-act="nav" data-id="${n.id}">${ICON[n.icon]()}</button>`).join('');
  const mainContent = view.nav === 'admin' ? adminHTML() : `
        <div class="unit-banner">
          <div>
            <div class="eyebrow">${ICON.arrowL()}${sec?.nombre || ''}</div>
            <h2>${sec?.nombre || 'Cargandoâ€¦'}</h2>
          </div>
        </div>
        <div class="path">
          ${nodes}
          <div class="path-divider"><span>PrÃ³xima secciÃ³n</span></div>
          <button class="node locked" style="margin-bottom:18px" disabled><span class="face">${ICON.star()}</span></button>
        </div>`;

  return `<div class="app">
    <header class="mobile-top">
      <div class="brand" style="padding:0">${LOGO(28)}<h1 class="fred" style="font-size:22px;display:block">Lumo</h1></div>
      <div style="display:flex;gap:18px">
        <div class="stat gems">${ICON.gem()}${store.gems}</div>
        <div class="stat hearts">${ICON.heart()}${store.hearts}</div>
      </div>
    </header>

    <aside class="side scroller">
      <div class="brand">${LOGO()}<h1 class="fred">Lumo</h1></div>
      ${navSide}
      <button class="nav-item nav-logout" data-act="logout" style="margin-top:auto">${ICON.logout()}<span>Salir</span></button>
    </aside>

    <main class="main scroller">
      <div class="main-inner">
        <div class="unit-banner">
          <div>
            <div class="eyebrow">${ICON.arrowL()}${sec?.nombre || ''}</div>
            <h2>${sec?.nombre || 'Cargando…'}</h2>
          </div>
        </div>
        <div class="path">
          ${nodes}
          <div class="path-divider"><span>Próxima sección</span></div>
          <button class="node locked" style="margin-bottom:18px" disabled><span class="face">${ICON.star()}</span></button>
        </div>
      </div>
      <nav class="mobile-nav">${navMob}</nav>
    </main>

    <aside class="rail scroller">
      <div class="rail-inner">
        <div class="stats" style="justify-content:flex-end;gap:22px">
          <div class="stat gems">${ICON.gem()}${store.gems}</div>
          <div class="stat hearts">${ICON.heart()}${store.hearts}</div>
        </div>
        <div class="card">
          <div style="font-weight:700;font-size:15px;color:var(--muted);font-family:'Fredoka',sans-serif">Hola, ${USER.nombre || 'Estudiante'} 👋</div>
          <div class="row" style="margin-top:14px"><h3 style="margin:0">Desafíos del día</h3></div>
          <div class="daily"><div class="ic" style="color:var(--amber)">${ICON.flame(24)}</div><div style="flex:1"><div style="font-family:'Fredoka',sans-serif;font-weight:600;font-size:15px">Gana 10 XP</div><div class="bar"><i style="width:${store.dailyPct}%"></i></div></div></div>
          <div class="daily"><div class="ic" style="color:var(--gem)">${ICON.gem(24)}</div><div style="flex:1"><div style="font-family:'Fredoka',sans-serif;font-weight:600;font-size:15px">Completa 1 lección</div><div class="bar"><i style="width:${Math.min(100, completed * 100)}%"></i></div></div></div>
        </div>
      </div>
    </aside>
  </div>`;
}

// ---- Lesson shell ----
const esc = s => String(s).replace(/"/g, '&quot;');
const cur = () => lesson.exercises[lesson.idx];

function lessonShellHTML() {
  return `<div class="lesson">
    <div class="lesson-top">
      <button class="close-x" data-act="quit">${ICON.x()}</button>
      <div class="progress"><i id="pbar"></i></div>
      <div class="heart-count" id="heart-box">${ICON.heart()}<span id="heart-num">${store.hearts}</span></div>
    </div>
    <div class="lesson-body"><div class="lesson-wrap">
      <h2 class="q-title" id="q-title"></h2>
      <div id="ex-area"></div>
    </div></div>
    <div class="lesson-foot" id="lesson-foot"><div class="foot-inner" id="foot-inner"></div></div>
  </div>`;
}

function choiceBodyHTML() {
  const ex = cur();
  const play = ex.play ? `<div class="prompt-row">${TUTOR(92)}<div class="speech"><button class="speaker" data-act="speak" data-text="${esc(ex.play)}">${ICON.speaker()}</button><span>${ex.play}</span></div></div>` : '';
  const opts = ex.options.map((o, i) => {
    let c = 'choice';
    if (lesson.checked) { if (i === ex.answer) c += ' correct'; else if (i === lesson.sel) c += ' wrong'; else c += ' disabled'; }
    else if (i === lesson.sel) c += ' sel';
    return `<button class="${c}" data-act="choice" data-i="${i}"><span class="kbd">${i + 1}</span>${o}</button>`;
  }).join('');
  return play + `<div class="choices ${ex.options.length === 4 ? 'grid2' : ''}">${opts}</div>`;
}

function buildAnswerInner() {
  const ex = cur();
  return `<div class="build-line"></div>` + lesson.placed.map((bi, pos) =>
    `<button class="word placed" data-act="unword" data-pos="${pos}">${ex.bank[bi]}</button>`).join('');
}
function buildBankInner() {
  const ex = cur();
  return ex.bank.map((w, bi) =>
    `<button class="word ${lesson.placed.includes(bi) ? 'used' : ''}" data-act="word" data-i="${bi}">${w}</button>`).join('');
}
function buildBodyHTML() {
  const ex = cur();
  return `<div class="prompt-row">${TUTOR(92)}<div class="speech"><span>${ex.prompt}</span></div></div>
    <div class="build-answer" id="build-answer">${buildAnswerInner()}</div>
    <div class="bank" id="bank">${buildBankInner()}</div>`;
}

function matchColHTML(side) {
  const list  = side === 'L' ? lesson.cols.L : lesson.cols.R;
  const selId = side === 'L' ? lesson.mLeft  : lesson.mRight;
  return list.map(it => {
    let c = 'mtile';
    if (lesson.mDone.includes(it.i)) c += ' done';
    else if (selId === it.i) c += ' sel';
    if (lesson.mMiss && (side === 'L' ? lesson.mMiss.l : lesson.mMiss.r) === it.i) c += ' miss';
    return `<button class="${c}" data-act="match" data-side="${side}" data-i="${it.i}">${it.t}</button>`;
  }).join('');
}
function matchBodyHTML() {
  return `<div class="match"><div class="match-col">${matchColHTML('L')}</div><div class="match-col">${matchColHTML('R')}</div></div>`;
}
function exBodyHTML() {
  const t = cur().type;
  return t === 'choice' ? choiceBodyHTML() : t === 'build' ? buildBodyHTML() : matchBodyHTML();
}

function footerHTML() {
  const ex = cur();
  const correctText = ex.type === 'build' ? ex.answer.join(' ') : ex.type === 'choice' ? ex.options[ex.answer] : '';
  if (lesson.checked) {
    const left  = `<div class="feedback ${lesson.isCorrect ? 'ok' : 'no'}"><span class="fic">${lesson.isCorrect ? ICON.check(26) : ICON.x(24)}</span><div>${lesson.isCorrect ? '¡Correcto!' : 'Respuesta correcta:'}${(!lesson.isCorrect && correctText) ? `<small>${correctText}</small>` : ''}</div></div>`;
    const right = `<button class="btn ${lesson.isCorrect ? 'btn-green' : 'btn-red'}" data-act="continue">Continuar</button>`;
    return left + right;
  }
  const left    = `<button class="btn btn-skip" data-act="skip">${ex.type === 'match' ? 'Saltar' : 'No sé'}</button>`;
  const canCheck = ex.type === 'choice' ? lesson.sel !== null : ex.type === 'build' ? lesson.placed.length > 0 : false;
  const right   = ex.type === 'match' ? '' : `<button class="btn ${canCheck ? 'btn-primary' : 'btn-disabled'}" data-act="check">Comprobar</button>`;
  return left + right;
}

function renderFooter() {
  document.getElementById('foot-inner').innerHTML = footerHTML();
  document.getElementById('lesson-foot').className = 'lesson-foot' + (lesson.checked ? (lesson.isCorrect ? ' correct' : ' wrong') : '');
}
function updateProgress() {
  const pct = ((lesson.idx + (lesson.checked ? 1 : 0)) / lesson.exercises.length) * 100;
  const bar = document.getElementById('pbar');
  if (bar) bar.style.width = pct + '%';
}
function updateHeart(pulse) {
  const num = document.getElementById('heart-num');
  if (num) num.textContent = Math.max(store.hearts, 0);
  if (pulse) { const box = document.getElementById('heart-box'); if (box) { box.classList.add('lose'); setTimeout(() => box.classList.remove('lose'), 450); } }
}

function shuffle(a) {
  const r = a.slice();
  for (let i = r.length - 1; i > 0; i--) { const j = (Math.random() * (i + 1)) | 0; [r[i], r[j]] = [r[j], r[i]]; }
  return r;
}

function initInput() {
  lesson.checked = false; lesson.isCorrect = false; lesson.sel = null;
  lesson.placed = []; lesson.mLeft = null; lesson.mRight = null;
  lesson.mDone = []; lesson.mMiss = null;
  if (cur().type === 'match') {
    lesson.cols = {
      L: shuffle(cur().pairs.map((p, i) => ({ t: p[0], i }))),
      R: shuffle(cur().pairs.map((p, i) => ({ t: p[1], i }))),
    };
  }
}

function renderQuestion() {
  const qt = document.getElementById('q-title');
  if (!qt) return;
  qt.textContent = cur().q;
  qt.style.animation = 'none'; void qt.offsetWidth; qt.style.animation = '';
  document.getElementById('ex-area').innerHTML = exBodyHTML();
  renderFooter(); updateProgress();
}

function selectChoice(i) {
  if (lesson.checked) return;
  lesson.sel = i;
  document.querySelectorAll('#ex-area .choice').forEach((b, idx) => b.classList.toggle('sel', idx === i));
  renderFooter();
}
function addWord(bi) {
  if (lesson.checked || lesson.placed.includes(bi)) return;
  lesson.placed.push(bi); refreshBuild();
}
function removeWord(pos) {
  if (lesson.checked) return;
  lesson.placed.splice(pos, 1); refreshBuild();
}
function refreshBuild() {
  document.getElementById('build-answer').innerHTML = buildAnswerInner();
  document.getElementById('bank').innerHTML = buildBankInner();
  renderFooter();
}
function tapMatch(side, i) {
  if (lesson.checked || lesson.mDone.includes(i)) return;
  if (side === 'L') { lesson.mLeft  = lesson.mLeft  === i ? null : i; if (lesson.mLeft  !== null && lesson.mRight !== null) return resolveMatch(); }
  else              { lesson.mRight = lesson.mRight === i ? null : i; if (lesson.mRight !== null && lesson.mLeft  !== null) return resolveMatch(); }
  document.getElementById('ex-area').innerHTML = matchBodyHTML();
}
function resolveMatch() {
  const l = lesson.mLeft, r = lesson.mRight;
  if (l === r) {
    lesson.mDone.push(l); lesson.mLeft = null; lesson.mRight = null;
    document.getElementById('ex-area').innerHTML = matchBodyHTML();
    if (lesson.mDone.length === cur().pairs.length) {
      setTimeout(() => { lesson.isCorrect = true; lesson.checked = true; renderFooter(); updateProgress(); }, 350);
    }
  } else {
    lesson.mMiss = { l, r }; document.getElementById('ex-area').innerHTML = matchBodyHTML();
    setTimeout(() => { lesson.mMiss = null; lesson.mLeft = null; lesson.mRight = null; document.getElementById('ex-area').innerHTML = matchBodyHTML(); }, 500);
  }
}

function evaluate() {
  const ex = cur();
  if (ex.type === 'choice') return lesson.sel === ex.answer;
  if (ex.type === 'build')  { const w = lesson.placed.map(bi => ex.bank[bi]); return w.length === ex.answer.length && w.every((x, i) => x === ex.answer[i]); }
  return true;
}
function check() {
  const ok = evaluate();
  lesson.isCorrect = ok; lesson.checked = true;
  if (!ok) { store.hearts = Math.max(0, store.hearts - 1); saveStore(); updateHeart(true); }
  if (cur().type === 'choice') {
    document.querySelectorAll('#ex-area .choice').forEach((b, i) => {
      b.classList.remove('sel');
      if (i === cur().answer) b.classList.add('correct');
      else if (i === lesson.sel) b.classList.add('wrong');
      else b.classList.add('disabled');
    });
  }
  renderFooter(); updateProgress();
}
function cont() {
  if (!lesson.isCorrect && store.hearts <= 0) { showNoHearts(); return; }
  if (lesson.idx + 1 >= lesson.exercises.length) { finishLesson(); return; }
  lesson.idx++; initInput(); renderQuestion();
}
function skip() {
  if (cur().type === 'match') { quitLesson(); return; }
  lesson.sel = null; lesson.placed = []; renderQuestion();
}

// ---- Iniciar lección ----
async function startNode(detalleId, nodeIndex) {
  const sec      = APP.currentSeccion;
  const detalles = sec.detalles;
  const completed = detalles.filter(d => d.realizado).length;

  if (nodeIndex !== completed) return; // solo el nodo activo

  if (store.hearts <= 0) { showNoHearts(); return; }

  view.activeDetalle = detalles[nodeIndex];

  // Loading
  document.getElementById('root').innerHTML = `<div class="loading-overlay"><div class="spinner"></div><p style="color:var(--muted);font-family:'Fredoka',sans-serif">Cargando lección…</p></div>`;

  try {
    const res = await api.secciones.preguntas(sec.id, detalleId);
    const exercises = res.data.preguntas.map(apiToExercise).filter(Boolean);

    lesson = { exercises, idx: 0 };
    initInput();
    view.screen = 'lesson';
    render();
    renderQuestion();
  } catch (err) {
    console.error(err);
    render(); // volver al mapa
  }
}
function quitLesson() { view.screen = 'map'; render(); }

// ---- Completar lección ----
async function finishLesson() {
  const kind = view.activeDetalle?.tipo || 'lesson';
  const xp   = 10 + (kind === 'crown' ? 20 : kind === 'review' ? 5 : 0);
  view.earnedXp = xp;
  store.gems    += 5;
  store.xp      += xp;
  store.dailyPct = Math.min(100, store.dailyPct + 30);
  saveStore();
  view.screen = 'complete';
  render();

  // Guardar progreso en API sin bloquear la UI
  try {
    await api.progreso.marcar(view.activeDetalle.id);
    // Recargar secciones con progreso actualizado
    const res = await api.secciones.list();
    APP.secciones      = res.data.secciones;
    APP.currentSeccion = APP.secciones[0];
  } catch { /* silencioso */ }
}

// ---- Pantalla completada ----
function confettiHTML() {
  const colors = ['#ff7a45','#ffc53d','#2dd4bf','#5fcf2f','#ff5d6c','#38c6f4'];
  return Array.from({ length: 60 }, (_, i) =>
    `<span class="confetti" style="left:${(Math.random()*100).toFixed(1)}vw;background:${colors[i%colors.length]};animation-duration:${(1.6+Math.random()*1.4).toFixed(2)}s;animation-delay:${(Math.random()*.6).toFixed(2)}s;transform:rotate(${(Math.random()*360)|0}deg)"></span>`
  ).join('');
}
function completeHTML() {
  return `<div class="complete">
    ${confettiHTML()}
    <div style="animation:bob 1.6s ease-in-out infinite">${MASCOT(150)}</div>
    <h2 class="fred">¡Lección completada!</h2>
    <p class="sub">Sigue así — ¡tu racha está más fuerte que nunca!</p>
    <div class="reward-row">
      <div class="reward xp"><div class="top">Total XP</div><div class="val">${ICON.flame(24)}${view.earnedXp}</div></div>
      <div class="reward acc"><div class="top">Precisión</div><div class="val">${ICON.star(22)}100%</div></div>
    </div>
    <button class="btn btn-primary" style="min-width:240px" data-act="complete-continue">Continuar</button>
  </div>`;
}

// ---- No hearts modal ----
function noHeartsHTML() {
  return `<div class="modal-bg" id="nh-modal"><div class="modal">
    <h3 class="fred">¡Sin corazones!</h3>
    <p>Perdiste todos tus vidas. Recárgalas gratis para continuar.</p>
    <button class="btn btn-green" data-act="refill">Recargar vidas</button>
    <button class="btn btn-skip" data-act="nh-quit">Volver al mapa</button>
  </div></div>`;
}
function showNoHearts() { if (!document.getElementById('nh-modal')) document.getElementById('root').insertAdjacentHTML('beforeend', noHeartsHTML()); }

// ---- Administracion ----
async function loadAdmin(resource = adminState.resource) {
  if (!IS_ADMIN) return;
  adminState = { ...adminState, resource, loading: true, error: '' };
  view.nav = 'admin';
  view.screen = 'map';
  render();
  try {
    const res = await api.admin.list(resource);
    adminState = {
      resource,
      fields: res.data.fields,
      rows: res.data.rows,
      loading: false,
      error: '',
    };
  } catch (err) {
    adminState = { ...adminState, loading: false, error: err.message || 'No se pudo cargar administracion' };
  }
  render();
}

async function saveAdminRow(btn) {
  const tr = btn.closest('tr[data-id]');
  if (!tr) return;
  const id = tr.getAttribute('data-id');
  const data = {};

  tr.querySelectorAll('[data-field]').forEach(input => {
    const field = input.getAttribute('data-field');
    data[field] = input.type === 'checkbox' ? input.checked : input.value;
  });

  btn.textContent = 'Guardando...';
  btn.disabled = true;
  try {
    await api.admin.update(adminState.resource, id, data);
    await loadAdmin(adminState.resource);
  } catch (err) {
    adminState.error = err.message || 'No se pudo guardar el registro';
    render();
  }
}

// ---- Audio ----
function speak(text) {
  try {
    const u = new SpeechSynthesisUtterance(text);
    u.lang = /[a-zA-Z]/.test(text) && !/[áéíóúñ¿¡]/.test(text) ? 'en-US' : 'es-ES';
    u.rate = 0.9;
    speechSynthesis.cancel(); speechSynthesis.speak(u);
  } catch {}
}

// ---- Render principal ----
function render() {
  const root = document.getElementById('root');
  if (!root) return;
  if      (view.screen === 'map') {
    root.innerHTML = mapHTML();
    if (view.nav === 'admin') {
      const main = root.querySelector('.main-inner');
      if (main) main.innerHTML = adminHTML();
    }
  }
  else if (view.screen === 'lesson')   root.innerHTML = lessonShellHTML();
  else if (view.screen === 'complete') root.innerHTML = completeHTML();
}

// ---- Eventos ----
document.getElementById('root').addEventListener('click', e => {
  const t   = e.target.closest('[data-act]');
  if (!t) return;
  const act = t.getAttribute('data-act');
  switch (act) {
    case 'nav':
      view.nav = t.getAttribute('data-id');
      if (view.nav === 'admin') loadAdmin();
      else render();
      break;
    case 'start-node':       startNode(+t.getAttribute('data-id'), +t.getAttribute('data-i')); break;
    case 'choice':           selectChoice(+t.getAttribute('data-i')); break;
    case 'word':             addWord(+t.getAttribute('data-i')); break;
    case 'unword':           removeWord(+t.getAttribute('data-pos')); break;
    case 'match':            tapMatch(t.getAttribute('data-side'), +t.getAttribute('data-i')); break;
    case 'check':            check(); break;
    case 'continue':         cont(); break;
    case 'skip':             skip(); break;
    case 'quit':             quitLesson(); break;
    case 'speak':            speak(t.getAttribute('data-text')); break;
    case 'admin-resource':   loadAdmin(t.getAttribute('data-resource')); break;
    case 'admin-save':       saveAdminRow(t); break;
    case 'complete-continue':
      view.screen = 'map'; render(); break;
    case 'refill':
      store.hearts = 5; saveStore();
      document.getElementById('nh-modal')?.remove();
      if (view.screen === 'lesson') updateHeart(false);
      else { view.screen = 'map'; render(); }
      break;
    case 'nh-quit':
      document.getElementById('nh-modal')?.remove();
      quitLesson(); break;
    case 'logout':
      localStorage.removeItem('lumo_token');
      localStorage.removeItem('lumo_user');
      window.location.href = './login.html'; break;
  }
});

// ---- Arranque ----
async function init() {
  document.getElementById('root').innerHTML = `<div class="loading-overlay"><div class="spinner"></div><p style="color:var(--muted);font-family:'Fredoka',sans-serif">Cargando…</p></div>`;
  try {
    const res = await api.secciones.list();
    APP.secciones      = res.data.secciones;
    APP.currentSeccion = APP.secciones[0] || null;
    view.screen = 'map';
    render();
  } catch (err) {
    console.error('Error al cargar:', err);
    document.getElementById('root').innerHTML = `<div class="loading-overlay"><p style="color:var(--red);font-family:'Fredoka',sans-serif">Error al conectar con el servidor</p></div>`;
  }
}

init();
