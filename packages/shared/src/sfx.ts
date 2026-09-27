/**
 * Tiny synthesized sound effects so games have feedback before real audio
 * assets exist. Must be triggered from a user gesture (browsers block audio
 * until the first tap).
 */
let ctx: AudioContext | undefined;

function audio(): AudioContext | undefined {
  if (typeof AudioContext === 'undefined') return undefined;
  ctx ??= new AudioContext();
  if (ctx.state === 'suspended') void ctx.resume();
  return ctx;
}

function tone(freq: number, start: number, duration: number, volume = 0.2): void {
  const ac = audio();
  if (!ac) return;
  const t0 = ac.currentTime + start;
  const osc = ac.createOscillator();
  const gain = ac.createGain();
  osc.type = 'triangle';
  osc.frequency.setValueAtTime(freq, t0);
  gain.gain.setValueAtTime(volume, t0);
  gain.gain.exponentialRampToValueAtTime(0.001, t0 + duration);
  osc.connect(gain).connect(ac.destination);
  osc.start(t0);
  osc.stop(t0 + duration);
}

export const sfx = {
  tap: () => tone(660, 0, 0.08, 0.15),
  match: () => {
    tone(784, 0, 0.15);
    tone(1047, 0.12, 0.25);
  },
  miss: () => tone(330, 0, 0.18, 0.1),
  win: () => [523, 659, 784, 1047].forEach((f, i) => tone(f, i * 0.12, 0.3)),
};
