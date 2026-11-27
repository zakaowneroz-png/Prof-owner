// توسيع فكرة — the whole edit is a pure function of time (rough-cut timeline, s). Voice is sample-exact: no drift map needed.
window.EDIT = (() => {
  const FPS = 30, CLIP = 119.5333, END_IN = 119.53, DUR = 121.9;
  const CAPS = window.CAPTIONS || [];
  const JUMPS = [3.933, 6.067, 8.233, 11.7, 16.9, 18.1, 18.933, 22.2, 24.633, 26.933, 32.1, 35.367, 38.233, 39.433, 43.1, 44.567, 47.867, 49.1, 50.4, 50.833, 53.8, 55.633, 59.533, 61.467, 62.367, 66.533, 68.6, 69.033, 70.7, 73.633, 76.467, 78.967, 81.233, 81.767, 83.433, 86.8, 88.733, 94.567, 97.2, 98.433, 100.333, 105.533, 110.3, 112.8, 113.7, 115.8, 116.667];
  // hero words: vertical centre of the word's line box (px from the top of the frame) — head top sits near y≈245
  const HERO = { cy: 108, scale: 0.9 };
  if (typeof location !== "undefined") { const q = new URLSearchParams(location.search); if (q.get("cy")) HERO.cy = +q.get("cy"); if (q.get("hs")) HERO.scale = +q.get("hs"); }

  // ---------- footage framings ----------
  const FULL = (k) => ({ x: 0, y: 0, w: 1080, h: 1920, r: 0, k, ax: 540, ay: 300, fx: 540, fy: 300, bw: 0 });
  const CARD = { x: 72, y: 268, w: 300, h: 380, r: 32, k: 0.40, ax: 150, ay: 175, fx: 540, fy: 560, bw: 5 };
  const BAND = { x: 60, y: 300, w: 960, h: 560, r: 40, k: 0.92, ax: 480, ay: 250, fx: 540, fy: 500, bw: 0 };
  const lerpBox = (a, b, p) => { const o = {}; for (const k in a) o[k] = lerp(a[k], b[k], p); return o; };
  const BEHIND = [
    { text: "ماشي الطول", a: 1.84, b: 3.8, size: 150, mk: true },
    { text: "صحة الأفكار", a: 5.04, b: 7.95, size: 140, mk: true },
    { text: "توسيع فكرة", a: 10.6, b: 11.62, size: 150, yellow: true },
    { text: "العرض", a: 53.26, b: 55.5, size: 190, mk: true },
    { text: "المفهوم", a: 56.7, b: 59.3, size: 175, mk: true },
    { text: "الشرح والتحليل", a: 60.9, b: 61.95, size: 118, mk: true },
    { text: "الخاتمة", a: 83.55, b: 84.58, size: 180, mk: true },
    { text: "خلاصة", a: 84.63, b: 88.45, size: 185, mk: true },
    { text: "رأيك", a: 89.12, b: 91.25, size: 210, yellow: true },
    { text: "بشكل معقلن", a: 93.37, b: 94.45, size: 135, mk: true },
  ];
  BEHIND.forEach((B) => { B.size = Math.round(B.size * HERO.scale); B.top = HERO.cy - B.size * 0.625; });
  const KICKS = BEHIND.map((B) => B.a);
  function punch(t) {
    let i = 0; while (i < JUMPS.length && t >= JUMPS[i]) i++;
    const kicks = KICKS.reduce((a, at) => a + 0.025 * Math.max(0, kick(t - at + 0.03, { freq: 1.2, decay: 4 })), 0);
    return (i % 2 ? 1.06 : 1.0) + 0.008 * Math.sin(t * 0.5) + kicks;
  }
  const pop = (t, a) => { const s = spring(t - a, { freq: 1.8, damping: 0.72 }); return { s: lerp(0.86, 1, s), o: clamp((t - a) * 6) }; };

  function footage(t) {
    const F = FULL(punch(t)), mo = (a, b, A, B) => lerpBox(A, B, easeInOutCubic(prog(t, a, b)));
    const base = { clip: 0, dim: 0, o: 1, s: 1, full: false };
    if (t < 11.7) return { ...base, box: F, full: true };
    if (t < 50.0) { const p = pop(t, 11.7); return { ...base, box: CARD, s: p.s }; }
    if (t < 50.4) return { ...base, box: mo(50.0, 50.4, CARD, F) };
    if (t < 62.0) return { ...base, box: F, full: true };
    if (t < 62.37) { const e = easeInCubic(prog(t, 62.0, 62.37)); return { ...base, box: F, clip: 1920 * e, dim: 0.5 * e, full: true }; }
    if (t < 70.3) { const p = pop(t, 62.37); return { ...base, box: CARD, s: p.s, o: p.o }; }
    if (t < 70.75) return { ...base, box: mo(70.3, 70.75, CARD, BAND) };
    if (t < 83.05) return { ...base, box: BAND };
    if (t < 83.45) return { ...base, box: mo(83.05, 83.45, BAND, F) };
    if (t < 94.57) return { ...base, box: F, full: true };
    if (t < 113.3) { const p = pop(t, 94.57); return { ...base, box: CARD, s: p.s }; }
    if (t < 113.7) return { ...base, box: mo(113.3, 113.7, CARD, F) };
    if (t < CLIP) return { ...base, box: F, full: true };
    return { ...base, box: F, o: 0 };
  }
  const ZB = [{ at: 11.7, f1: { x: 540, y: 520 }, f2: { x: 222, y: 458 } }, { at: 94.57, f1: { x: 540, y: 520 }, f2: { x: 222, y: 458 } }];
  function camera(t) {
    for (const z of ZB) {
      if (t >= z.at - 0.28 && t < z.at) { const p = easeInCubic(prog(t, z.at - 0.28, z.at)); return { s: 1 + 0.85 * p, blur: 22 * p, f: z.f1 }; }
      if (t >= z.at && t < z.at + 0.6) { const q = spring(t - z.at, { freq: 1.4, damping: 0.78 }); return { s: lerp(1.3, 1, q), blur: lerp(14, 0, clamp(q * 1.3)), f: z.f2 }; }
    }
    return { s: 1, blur: 0, f: { x: 540, y: 960 } };
  }
  function bgs(t) {
    return {
      paper1: (t >= 11.7 && t < 22.25) || (t >= 94.57 && t < 113.75),
      green: t >= 21.75 && t < 50.45, greenR: lerp(0, 2700, easeInCubic(prog(t, 21.75, 22.2))),
      paper2: t >= 62.0 && t < 70.8,
      dark: t >= 70.3 && t < 83.5, darkY: 1920 * (1 - easeOutCubic(prog(t, 70.3, 70.75))),
    };
  }

  // ---------- element states ----------
  function rise(t, a, b, { dy = 60, blur = 10, out = 0.22 } = {}) {
    const s = spring(t - a, { freq: 1.9, damping: 0.7 }), x = easeInCubic(prog(t, b - out, b));
    return { on: t >= a - 0.01 && t < b, y: lerp(dy, 0, s) - 90 * x, o: clamp((t - a) * 7) * (1 - x), blur: lerp(blur, 0, clamp(s * 1.4)) + 10 * x, s: 1 };
  }
  const popIn = (t, a, b, out = 0.2) => { const s = spring(t - a, { freq: 2.2, damping: 0.55 }), x = easeInCubic(prog(t, b - out, b));
    return { on: t >= a - 0.01 && t < b, y: 0, o: clamp((t - a) * 8) * (1 - x), blur: 6 * x, s: lerp(0.6, 1, s) * (1 - 0.15 * x) }; };
  const fade = (t, a, b, d = 0.25) => ({ on: t >= a && t < b, y: 0, o: clamp((t - a) / d) * (1 - clamp((t - (b - d)) / d)), blur: 0, s: 1 });
  const marker = (t, a, d = 0.28) => ({ p: easeOutCubic(prog(t, a, a + d)) });
  const L = 2 / FPS;

  const TIPS = [[11.7, 22.0], [22.0, 50.4], [50.4, 70.7], [70.7, 83.43], [83.43, 94.57], [94.57, 113.7]];
  const tipAt = (t) => TIPS.findIndex(([a, b]) => t >= a && t < b);
  const trackerOn = (t) => (t >= 11.95 && t < 49.95) || (t >= 62.6 && t < 83.0) || (t >= 94.8 && t < 113.25);
  const trackerIn = (t) => [11.95, 62.6, 94.8].reduce((m, a) => (t >= a ? a : m), 0);

  const els = {};
  const S = (id, st) => (els[id] = st);
  function ui(t, tt) {
    for (const k in els) delete els[k];
    S("chips", rise(t, 0.2, 2.5, { dy: -40 }));
    S("tracker", { on: trackerOn(t), y: 0, o: clamp((t - trackerIn(t)) * 4), blur: 0, s: 1 });
    // S1 — توسيع فكرة (paper)
    const o1 = 21.75;
    S("s1Title", rise(t, 11.85, o1, { dy: 50 })); S("s1TitleMk", marker(t, 12.15));
    S("s1Flow", fade(t, 14.0, o1, 0.2)); S("s1A", popIn(t, 14.12 - L, o1)); S("s1Arrow", marker(t, 14.9, 0.5)); S("s1B", popIn(t, 15.5 - L, o1));
    S("s1Doc", rise(t, 16.6, o1, { dy: 60 }));
    [["s1p1", 16.96], ["s1p2", 17.6], ["s1p3", 18.02]].forEach(([id, a]) => { S(id, popIn(t, a - L, o1)); S(id + "Mk", marker(t, a + 0.05, 0.26)); });
    S("s1Ex", rise(t, 18.88 - L, o1, { dy: 40 })); S("s1ExMk", marker(t, 20.98, 0.35));
    // S2 — المقدمة (green)
    const o2 = 49.95;
    S("s2Title", rise(t, 22.3, o2, { dy: 50 })); S("s2TitleMk", marker(t, 22.6));
    S("st1", rise(t, 22.64 - L, o2, { dy: 50 })); S("st1Sub", rise(t, 25.0 - L, o2, { dy: 20 })); S("st1Ex", popIn(t, 27.42 - L, o2)); S("st1ExMk", marker(t, 30.78, 0.35));
    S("st2", rise(t, 32.04 - L, o2, { dy: 50 })); S("st2Ex", popIn(t, 35.37 - L, o2)); S("st2ExMk", marker(t, 38.09, 0.35));
    S("st3", rise(t, 40.37 - L, o2, { dy: 50 }));
    [["q1", 43.45], ["q2", 44.29], ["q3", 47.71], ["q4", 48.77]].forEach(([id, a]) => S(id, popIn(t, a - L, o2)));
    S("st1Hl", fade(t, 22.64, 32.04, 0.2)); S("st2Hl", fade(t, 32.04, 40.37, 0.2)); S("st3Hl", fade(t, 40.37, o2, 0.2));
    // S3 — العرض (paper 2)
    const o3 = 70.3;
    S("s3Title", rise(t, 62.5, o3, { dy: 50 })); S("s3TitleMk", marker(t, 62.8));
    S("s3Grid", rise(t, 62.7, o3, { dy: 60 }));
    [["s3k1", 63.4], ["s3k2", 67.69], ["s3k3", 68.55], ["s3k4", 69.29]].forEach(([id, a]) => { S(id, popIn(t, a - L, o3)); S(id + "Mk", marker(t, a + 0.05, 0.3)); });
    // S4 — الدعم (dark band)
    const o4 = 83.0;
    S("s4Title", rise(t, 71.86 - L, o4, { dy: 40 })); S("s4TitleMk", marker(t, 72.1, 0.3));
    S("s4o1", popIn(t, 73.92 - L, o4)); S("s4o1b", popIn(t, 75.44 - L, o4));
    S("s4o2", popIn(t, 76.66 - L, o4)); [["s4c1", 78.34], ["s4c2", 79.32], ["s4c3", 80.08]].forEach(([id, a]) => S(id, popIn(t, a - L, o4)));
    S("s4o3", popIn(t, 81.77 - L, o4)); S("s4c4", popIn(t, 82.35 - L, o4));
    // S6 — الخلاصة (paper 1 again)
    const o6 = 113.25;
    S("s6Title", rise(t, 94.85, o6, { dy: 50 })); S("s6TitleMk", marker(t, 95.15));
    S("s6Card", rise(t, 95.1, o6, { dy: 60 }));
    S("s6h1", popIn(t, 95.27 - L, o6)); S("s6n1", popIn(t, 96.07 - L, o6));
    S("s6h2", popIn(t, 100.49 - L, o6)); S("s6h3", popIn(t, 110.3 - L, o6));
    [["c11", 97.03], ["c12", 97.69], ["c13", 98.37], ["c21", 101.43], ["c22", 102.65], ["c23", 104.27], ["c24", 107.27], ["c25", 108.15], ["c26", 109.03], ["c31", 112.04], ["c32", 112.58]]
      .forEach(([id, a]) => S(id, popIn(t, a - L, o6)));
    // CTA
    S("icSave", popIn(t, 115.6 - L, END_IN)); S("icSend", popIn(t, 116.5 - L, END_IN));
    // end card
    const eIn = END_IN;
    S("endSheet", { on: tt >= eIn, y: 1920 * (1 - easeOutCubic(prog(tt, eIn, eIn + 0.38))) });
    S("endLogo", popIn(tt, eIn + 0.45, 999)); S("endName", rise(tt, eIn + 0.65, 999, { dy: 40 })); S("endHandle", rise(tt, eIn + 0.8, 999, { dy: 30 }));
    S("endCta", rise(tt, eIn + 1.0, 999, { dy: 30 })); S("endCtaMk", marker(tt, eIn + 1.25, 0.35));
    return els;
  }

  function behind(t) {
    return BEHIND.map((B) => {
      const s = spring(t - B.a + L, { freq: 1.6, damping: 0.72 }), x = easeInCubic(prog(t, B.b - 0.2, B.b));
      return { on: t >= B.a - L && t < B.b, y: lerp(140, 0, s) - 160 * x, sc: lerp(1.18, 1, s), o: clamp((t - B.a + L) * 6) * (1 - x),
        blur: lerp(16, 0, clamp(s * 1.3)) + 14 * x, mk: marker(t, B.a + 0.12, 0.3).p };
    });
  }

  // ---------- captions ----------
  const ZONE_TOP = { full: 1190, band: 1470 };
  const zoneAt = (t) => (t < 11.7 || (t >= 50.4 && t < 62.0) || (t >= 83.45 && t < 94.57) || (t >= 113.7 && t < END_IN + 0.1) ? "full" : null);
  function wordState(t, start) {
    const d = t - (start - L), s = spring(d, { freq: 2.0, damping: 0.6 });
    return { y: lerp(60, 0, s), blur: lerp(10, 0, clamp(s * 1.4)), o: clamp(d * 8), mk: marker(t, start + 0.04, 0.24).p };
  }
  const firstOf = (c) => (c.t1.length ? c.t1[0] : c.t2[0]);
  const EXIT = CAPS.map((c, i) => {
    const next = CAPS[i + 1] ? firstOf(CAPS[i + 1]) - L - 0.02 : Infinity, last = (c.t2.length ? c.t2 : c.t1).at(-1);
    const a = Math.max(last + 0.1, Math.min(c.out, next - 0.24));
    return { a, b: Math.max(a + 0.16, Math.min(a + 0.3, next)) };
  });
  function capState(c, t, i) {
    const X = EXIT[i], p = easeInCubic(prog(t, X.a, X.b));
    return { visible: t >= firstOf(c) - 0.1 && t < X.b + 0.02, exit: { y: -120 * p, blur: 12 * p, o: 1 - p },
      l1: c.t1.map((s) => wordState(t, s)), l2: c.t2.map((s) => wordState(t, s)) };
  }

  function sceneAt(f) {
    const tt = f / FPS, t = tt < CLIP ? tt : CLIP - 0.001;
    return { t: tt, foot: footage(tt < CLIP ? tt : 999), cam: camera(t), bg: bgs(t), ui: ui(t, tt), behind: behind(t), tip: tipAt(t),
      zone: tt < END_IN + 0.1 ? zoneAt(t) : null, caps: CAPS.map((c, i) => capState(c, t, i)) };
  }
  return { FPS, DUR, CLIP, CAPS, BEHIND, ZONE_TOP, HERO, sceneAt };
})();
