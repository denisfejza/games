import Phaser from 'phaser';
import { hex, palette, sfx, t } from '@kids-games/shared';
import { animals } from '../logic/animals';
import { createGame, flip, hideMismatch, isComplete, type Difficulty, type Game } from '../logic/memory';
import { button, emoji, getLang, onResize, text, topBar } from '../ui';

const MISMATCH_DELAY = 1000;
const FLIP_MS = 120;

interface CardView {
  container: Phaser.GameObjects.Container;
  back: Phaser.GameObjects.Graphics;
  face: Phaser.GameObjects.Container;
}

export class GameScene extends Phaser.Scene {
  private difficulty!: Difficulty;
  private board!: Game;
  private views: CardView[] = [];
  private won = false;

  constructor() {
    super('game');
  }

  init(data: { difficulty: Difficulty }): void {
    this.difficulty = data.difficulty;
    this.board = createGame(animals.map((a) => a.id), (data.difficulty.cols * data.difficulty.rows) / 2);
    this.won = false;
  }

  create(): void {
    this.draw();
    onResize(this, () => this.draw());
  }

  /** Rebuilds every object from the game state (on start, resize and language change). */
  private draw(): void {
    this.children.removeAll(true);
    const top = topBar(this, () => this.scene.start('menu'), () => this.draw());
    this.drawBoard(top);
    if (this.won) this.showWin(false);
  }

  private drawBoard(top: number): void {
    const { width, height } = this.scale;
    // Turn wide grids sideways on portrait screens so cards stay big.
    let { cols, rows } = this.difficulty;
    const portrait = height > width;
    if (portrait !== rows > cols) [cols, rows] = [rows, cols];

    const pad = 16;
    const availW = width - pad * 2;
    const availH = height - top - pad;
    const size = Math.min(availW / (cols + (cols - 1) * 0.08), availH / (rows + (rows - 1) * 0.08), 220);
    const gap = size * 0.08;
    const boardW = cols * size + (cols - 1) * gap;
    const boardH = rows * size + (rows - 1) * gap;
    const x0 = (width - boardW) / 2 + size / 2;
    const y0 = top + (availH - boardH) / 2 + size / 2;

    this.views = this.board.cards.map((card, i) => {
      const x = x0 + (i % cols) * (size + gap);
      const y = y0 + Math.floor(i / cols) * (size + gap);
      const view = this.cardView(x, y, size, card.face);
      const showing = card.state !== 'down';
      view.back.setVisible(!showing);
      view.face.setVisible(showing);
      if (card.state === 'matched') view.face.setAlpha(0.85);
      view.container.on('pointerdown', () => this.onTap(i));
      return view;
    });
  }

  private cardView(x: number, y: number, size: number, faceId: string): CardView {
    const r = size * 0.16;
    const back = this.add.graphics();
    back.fillStyle(0x000000, 0.15).fillRoundedRect(-size / 2, -size / 2 + 5, size, size, r);
    back.fillStyle(hex(palette.cardBack)).fillRoundedRect(-size / 2, -size / 2, size, size, r);
    back.fillStyle(0xffffff, 0.25).fillCircle(0, 0, size * 0.22);

    const faceBg = this.add.graphics();
    faceBg.fillStyle(0x000000, 0.15).fillRoundedRect(-size / 2, -size / 2 + 5, size, size, r);
    faceBg.fillStyle(hex(palette.cardFace)).fillRoundedRect(-size / 2, -size / 2, size, size, r);
    const animal = animals.find((a) => a.id === faceId)!;
    const face = this.add.container(0, 0, [faceBg, emoji(this, 0, 0, animal.emoji, size * 0.55)]);

    const container = this.add.container(x, y, [back, face]).setSize(size, size);
    container.setInteractive({ useHandCursor: true });
    return { container, back, face };
  }

  private onTap(index: number): void {
    const result = flip(this.board, index);
    if (result === 'ignored') return;
    sfx.tap();
    this.animateFlip(index, true);

    if (result === 'match') {
      const face = this.board.cards[index].face;
      this.time.delayedCall(FLIP_MS * 2, () => this.celebrateMatch(face));
    } else if (result === 'mismatch') {
      this.time.delayedCall(MISMATCH_DELAY, () => {
        sfx.miss();
        for (const i of hideMismatch(this.board)) this.animateFlip(i, false);
      });
    }
  }

  private animateFlip(index: number, faceUp: boolean): void {
    const view = this.views[index];
    this.tweens.add({
      targets: view.container,
      scaleX: 0,
      duration: FLIP_MS,
      onComplete: () => {
        view.back.setVisible(!faceUp);
        view.face.setVisible(faceUp);
        this.tweens.add({ targets: view.container, scaleX: 1, duration: FLIP_MS });
      },
    });
  }

  private celebrateMatch(face: string): void {
    sfx.match();
    this.board.cards.forEach((card, i) => {
      if (card.face !== face) return;
      this.tweens.add({ targets: this.views[i].container, scale: 1.12, duration: 150, yoyo: true });
    });

    // Show the animal's name so kids learn the word in the chosen language.
    const { width, height } = this.scale;
    const name = animals.find((a) => a.id === face)!.name[getLang(this)];
    const label = text(this, width / 2, height / 2, `${name}!`, Math.min(96, width * 0.12), palette.primary)
      .setStroke('#ffffff', 10)
      .setDepth(10)
      .setScale(0.5);
    this.tweens.add({
      targets: label,
      scale: 1,
      duration: 250,
      ease: 'Back.Out',
      onComplete: () => this.tweens.add({ targets: label, alpha: 0, delay: 500, duration: 300, onComplete: () => label.destroy() }),
    });

    if (isComplete(this.board)) {
      this.won = true;
      this.time.delayedCall(900, () => this.showWin(true));
    }
  }

  private showWin(animate: boolean): void {
    const { width, height } = this.scale;
    const lang = getLang(this);
    if (animate) {
      sfx.win();
      this.confetti();
    }
    const shade = this.add.rectangle(width / 2, height / 2, width, height, hex(palette.background), 0.9).setDepth(20);
    shade.setInteractive(); // blocks taps on the board underneath
    const s = Math.min(width, height);
    const items: (Phaser.GameObjects.Text | Phaser.GameObjects.Container)[] = [
      emoji(this, width / 2, height * 0.28, '⭐⭐⭐', s * 0.14),
      text(this, width / 2, height * 0.45, t(lang, 'wellDone'), s * 0.1),
    ];
    const bw = Math.min(160, s * 0.3);
    items.push(
      button(this, width / 2 - bw * 0.65, height * 0.68, bw, bw, palette.success, () => this.scene.restart({ difficulty: this.difficulty }), (c) =>
        c.add(emoji(this, 0, 0, '🔁', bw * 0.45)),
      ),
      button(this, width / 2 + bw * 0.65, height * 0.68, bw, bw, palette.secondary, () => this.scene.start('menu'), (c) =>
        c.add(emoji(this, 0, 0, '🏠', bw * 0.45)),
      ),
    );
    for (const item of items) item.setDepth(21);
    if (animate) {
      for (const item of items) item.setScale(0);
      this.tweens.add({ targets: items, scale: 1, duration: 400, ease: 'Back.Out', delay: this.tweens.stagger(80, {}) });
    }
  }

  private confetti(): void {
    const { width } = this.scale;
    const colors = [palette.primary, palette.secondary, palette.success, palette.accent, palette.cardBack];
    for (let i = 0; i < 60; i++) {
      const piece = this.add
        .rectangle(Phaser.Math.Between(0, width), -20, 12, 18, hex(Phaser.Utils.Array.GetRandom(colors)))
        .setDepth(30)
        .setAngle(Phaser.Math.Between(0, 360));
      this.tweens.add({
        targets: piece,
        y: this.scale.height + 40,
        angle: piece.angle + Phaser.Math.Between(180, 720),
        x: piece.x + Phaser.Math.Between(-80, 80),
        duration: Phaser.Math.Between(1400, 2600),
        delay: Phaser.Math.Between(0, 500),
        onComplete: () => piece.destroy(),
      });
    }
  }
}
