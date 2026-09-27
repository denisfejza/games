import Phaser from 'phaser';
import { detectLang, hex, languages, otherLang, palette, saveLang, sfx, type Lang } from '@kids-games/shared';

export const FONT = 'system-ui, "Segoe UI", Roboto, sans-serif';
/** Colour emoji fonts first, otherwise some systems draw emoji as black outlines. */
export const EMOJI_FONT = '"Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji", sans-serif';

/** Current language, shared by all scenes through the game registry. */
export function getLang(scene: Phaser.Scene): Lang {
  if (!scene.registry.has('lang')) scene.registry.set('lang', detectLang());
  return scene.registry.get('lang') as Lang;
}

export function text(
  scene: Phaser.Scene,
  x: number,
  y: number,
  value: string,
  size: number,
  color: string = palette.ink,
  fontFamily: string = FONT,
): Phaser.GameObjects.Text {
  return scene.add
    .text(x, y, value, { fontFamily, fontSize: `${Math.round(size)}px`, fontStyle: 'bold', color, align: 'center' })
    .setOrigin(0.5)
    .setResolution(window.devicePixelRatio || 1);
}

export function emoji(scene: Phaser.Scene, x: number, y: number, value: string, size: number): Phaser.GameObjects.Text {
  return text(scene, x, y, value, size, palette.ink, EMOJI_FONT);
}

/** A chunky rounded button that presses down when tapped. */
export function button(
  scene: Phaser.Scene,
  x: number,
  y: number,
  w: number,
  h: number,
  color: string,
  onTap: () => void,
  draw?: (c: Phaser.GameObjects.Container) => void,
): Phaser.GameObjects.Container {
  const radius = Math.min(w, h) * 0.3;
  const bg = scene.add.graphics();
  bg.fillStyle(0x000000, 0.12).fillRoundedRect(-w / 2, -h / 2 + 5, w, h, radius);
  bg.fillStyle(hex(color)).fillRoundedRect(-w / 2, -h / 2, w, h, radius);
  const c = scene.add.container(x, y, [bg]).setSize(w, h);
  draw?.(c);
  c.setInteractive({ useHandCursor: true });
  c.on('pointerdown', () => {
    sfx.tap();
    scene.tweens.add({ targets: c, scale: 0.92, duration: 60, yoyo: true, onComplete: onTap });
  });
  return c;
}

/** Top bar: home button (back to the launcher) and language toggle. */
export function topBar(scene: Phaser.Scene, onHome: () => void, onLangChange: () => void): number {
  const { width } = scene.scale;
  const size = Math.max(64, Math.min(88, width * 0.1));
  const y = size / 2 + 12;
  button(scene, size / 2 + 12, y, size, size, palette.cardFace, onHome, (c) => c.add(emoji(scene, 0, 0, '🏠', size * 0.5)));
  const next = otherLang(getLang(scene));
  button(scene, width - size / 2 - 12, y, size, size, palette.cardFace, () => {
    scene.registry.set('lang', next);
    saveLang(next);
    onLangChange();
  }, (c) => c.add(emoji(scene, 0, 0, languages[next].flag, size * 0.5)));
  return size + 24;
}

/** Leaves the game for the launcher page (the site root one level up). */
export function goToLauncher(): void {
  window.location.href = '../';
}

/** Rebuilds the scene's objects when the window size changes. */
export function onResize(scene: Phaser.Scene, redraw: () => void): void {
  const handler = () => redraw();
  scene.scale.on('resize', handler);
  scene.events.once('shutdown', () => scene.scale.off('resize', handler));
}
