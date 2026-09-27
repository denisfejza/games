import Phaser from 'phaser';
import { hex, palette, t } from '@kids-games/shared';
import { difficulties, type Difficulty } from '../logic/memory';
import { button, emoji, getLang, goToLauncher, onResize, text, topBar } from '../ui';

const levelColors = [palette.success, palette.secondary, palette.primary];

export class MenuScene extends Phaser.Scene {
  constructor() {
    super('menu');
  }

  create(): void {
    this.draw();
    onResize(this, () => this.draw());
  }

  private draw(): void {
    this.children.removeAll(true);
    const { width, height } = this.scale;
    const top = topBar(this, goToLauncher, () => this.draw());
    const lang = getLang(this);

    const titleSize = Math.min(64, width * 0.08);
    text(this, width / 2, top + titleSize * 0.2, t(lang, 'memoryMatch'), titleSize);
    emoji(this, width / 2, top + titleSize * 1.5, '🐶 🐱 🐮 🐷', titleSize);

    // One big button per level, drawn as a mini grid so no reading is needed.
    const portrait = height > width;
    const areaTop = top + titleSize * 2.6;
    const areaH = height - areaTop - 16;
    const n = difficulties.length;
    const size = portrait
      ? Math.min(width * 0.6, (areaH - 16 * (n - 1)) / n)
      : Math.min(areaH * 0.8, (width - 32 - 24 * (n - 1)) / n);
    difficulties.forEach((d, i) => {
      const x = portrait ? width / 2 : width / 2 + (i - (n - 1) / 2) * (size + 24);
      const y = portrait ? areaTop + size / 2 + i * (size + 16) : areaTop + areaH / 2;
      button(this, x, y, size, size, levelColors[i], () => this.start(d), (c) => c.add(miniGrid(this, d, size * 0.7)));
    });
  }

  private start(difficulty: Difficulty): void {
    this.scene.start('game', { difficulty });
  }
}

function miniGrid(scene: Phaser.Scene, d: Difficulty, size: number): Phaser.GameObjects.Graphics {
  const g = scene.add.graphics();
  const gap = size * 0.06;
  const cell = Math.min((size - gap * (d.cols - 1)) / d.cols, (size - gap * (d.rows - 1)) / d.rows);
  const w = d.cols * cell + (d.cols - 1) * gap;
  const h = d.rows * cell + (d.rows - 1) * gap;
  g.fillStyle(hex(palette.cardFace));
  for (let r = 0; r < d.rows; r++) {
    for (let c = 0; c < d.cols; c++) {
      g.fillRoundedRect(-w / 2 + c * (cell + gap), -h / 2 + r * (cell + gap), cell, cell, cell * 0.2);
    }
  }
  return g;
}
