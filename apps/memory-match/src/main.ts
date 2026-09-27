import Phaser from 'phaser';
import { palette } from '@kids-games/shared';
import { MenuScene } from './scenes/MenuScene';
import { GameScene } from './scenes/GameScene';

const game = new Phaser.Game({
  type: Phaser.AUTO,
  parent: 'app',
  backgroundColor: palette.background,
  scale: { mode: Phaser.Scale.RESIZE, width: '100%', height: '100%' },
  scene: [MenuScene, GameScene],
});

// Handle for browser smoke tests (Playwright) to inspect the running game.
(window as unknown as { __game: Phaser.Game }).__game = game;
