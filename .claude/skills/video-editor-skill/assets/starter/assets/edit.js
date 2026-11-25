// Video Editor Skill: starter scene math. The whole edit is sceneAt(frame) → plain numbers; index.html only paints them.
// Replace the example beats with the ones from script.md. Every time below should be a word timestamp.
window.EDIT = (() => {
  const FPS = 30;
  const DUR = 10.0;                      // ← footage length in seconds; also set data-duration on #root and on <video id="foot">
  const CAPS = window.CAPTIONS || [];    // from scripts/captions.py (assets/captions.js)
  const FOCUS = { x: 540, y: 760 };      // face height: punch-ins scale around this point

  // camera punch-ins on key words: [time, amount]
  const PUNCH = [[1.2, 0.03], [8.4, 0.03]];
  // one example full-screen graphic scene: in = zoom-blur match cut, out = diamond iris back to the footage
  const SCENE = { from: 4.0, to: 7.0, iris: 0.5, irisFrom: { x: 540, y: 960 }, title: "Big idea", sub: "a full-screen graphic scene" };
  // caption tops per zone (base px at 1080×1920)
  const ZONE_TOP = { full: 1110, scene: 1290 };

  // ---------- footage ----------
  function footage(t) {
    const s = 1.02 + 0.02 * Math.sin(t * 0.3) + PUNCH.reduce((a, [at, amt]) => a + amt * Math.max(0, kick(t - at)), 0);
    const img = { x: FOCUS.x - FOCUS.x * s, y: FOCUS.y - FOCUS.y * s, s };
    if (t >= SCENE.from && t < SCENE.to - SCENE.iris) return { show: false, img };
    if (t >= SCENE.to - SCENE.iris && t < SCENE.to) {
      const r = lerp(0, 2600, easeInCubic(prog(t, SCENE.to - SCENE.iris, SCENE.to)));
      return { show: true, img, clip: diamondClip(SCENE.irisFrom, r), iris: { c: SCENE.irisFrom, r } };
    }
    return { show: true, img, clip: "none" };
  }
  // zoom-blur push into the cut, then the new scene settles from zoomed + blurred
  function camera(t) {
    const a = SCENE.from;
    if (t >= a - 0.3 && t < a) { const p = easeInCubic(prog(t, a - 0.3, a)); return { s: 1 + 0.9 * p, blur: 26 * p, f: FOCUS }; }
    if (t >= a && t < a + 0.7) { const q = spring(t - a, { freq: 1.4, damping: 0.75 }); return { s: lerp(1.35, 1, q), blur: lerp(16, 0, clamp(q * 1.3)), f: { x: 540, y: 900 } }; }
    return { s: 1, blur: 0, f: { x: 540, y: 960 } };
  }
  function scene(t) {
    const on = t >= SCENE.from - 0.02 && t < SCENE.to;
    const e = spring(t - SCENE.from - 0.1, { freq: 1.6, damping: 0.8 });
    return { on, title: { y: lerp(80, 0, e), o: clamp((t - SCENE.from - 0.1) * 5), blur: lerp(14, 0, clamp(e * 1.4)) },
      sub: { o: clamp((t - SCENE.from - 0.5) * 4), y: lerp(30, 0, easeOutCubic(prog(t, SCENE.from + 0.5, SCENE.from + 1.0))) } };
  }

  // ---------- captions ----------
  // the zone follows the background at this frame (a caption that spans the cut switches with the cut)
  const zoneAt = (t) => (t >= SCENE.from && t < SCENE.to ? "scene" : "full");
  function wordState(t, start) { // rise from below with blur; land 2 frames before the word
    const d = t - (start - 2 / FPS), s = spring(d, { freq: 2.0, damping: 0.55 });
    return { y: lerp(70, 0, s), blur: lerp(10, 0, clamp(s * 1.4)), o: clamp(d * 8) };
  }
  const firstOf = (c) => (c.t1.length ? c.t1[0] : c.t2[0]);
  const EXIT = CAPS.map((c, i) => { // each exit finishes before the next caption's first word
    const next = CAPS[i + 1] ? firstOf(CAPS[i + 1]) - 2 / FPS - 0.02 : Infinity, last = (c.t2.length ? c.t2 : c.t1).at(-1);
    const a = Math.max(last + 0.2, Math.min(c.out, next - 0.24));
    return { a, b: Math.max(a + 0.16, Math.min(a + 0.3, next)) };
  });
  function capState(c, t, i) {
    const X = EXIT[i], p = easeInCubic(prog(t, X.a, X.b));
    return { visible: t >= firstOf(c) - 0.1 && t < X.b + 0.02, exit: { y: -200 * p, blur: 12 * p, o: 1 - p },
      l1: c.t1.map((s) => wordState(t, s)), l2: c.t2.map((s) => wordState(t, s)) };
  }

  function sceneAt(f) {
    const t = f / FPS;
    return { t, foot: footage(t), cam: camera(t), scene: scene(t), capZone: zoneAt(t), caps: CAPS.map((c, i) => capState(c, t, i)) };
  }
  return { FPS, DUR, CAPS, SCENE, ZONE_TOP, sceneAt };
})();
