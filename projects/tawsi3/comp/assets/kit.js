// Video Editor Skill: math kit. Pure functions only (no clocks, no Math.random), so every frame is reproducible.
const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
const lerp = (a, b, t) => a + (b - a) * t;
const prog = (t, a, b) => clamp((t - a) / (b - a));                  // 0→1 progress of t between a and b
const easeOutExpo = (t) => (t >= 1 ? 1 : 1 - Math.pow(2, -10 * t));
const easeOutCubic = (t) => 1 - Math.pow(1 - t, 3);
const easeInCubic = (t) => t * t * t;
const easeInOutCubic = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);
// Damped spring 0→1 (t in seconds). damping ≥ 0.8 = calm settle, 0.4 = bouncy.
function spring(t, { freq = 2.0, damping = 0.6 } = {}) {
  if (t <= 0) return 0;
  const w = 2 * Math.PI * freq, z = Math.min(damping, 0.999), wd = w * Math.sqrt(1 - z * z);
  return 1 - Math.exp(-z * w * t) * (Math.cos(wd * t) + ((z * w) / wd) * Math.sin(wd * t));
}
// Decaying kick 0 → peak → 0: camera punch-ins, squash, shake.
const kick = (t, { freq = 1.1, decay = 3.4 } = {}) => (t <= 0 ? 0 : Math.sin(2 * Math.PI * freq * t) * Math.exp(-decay * t));
// Seeded random: use instead of Math.random so renders match snapshots.
function mulberry32(seed) {
  return () => { seed |= 0; seed = (seed + 0x6d2b79f5) | 0; let t = Math.imul(seed ^ (seed >>> 15), 1 | seed); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
}
const diamondClip = (c, r) => `polygon(${c.x}px ${c.y - r}px, ${c.x + r}px ${c.y}px, ${c.x}px ${c.y + r}px, ${c.x - r}px ${c.y}px)`;
