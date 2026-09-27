import { seededRng } from '@kids-games/shared';
import { describe, expect, it } from 'vitest';
import { createGame, difficulties, flip, hideMismatch, isComplete, type Game } from './memory';
import { animals } from './animals';

const faces = animals.map((a) => a.id);

function pairOf(game: Game, index: number): number {
  return game.cards.findIndex((c, i) => i !== index && c.face === game.cards[index].face);
}

function nonPairOf(game: Game, index: number): number {
  return game.cards.findIndex((c) => c.face !== game.cards[index].face);
}

describe('createGame', () => {
  it('deals each chosen face exactly twice, face down', () => {
    const game = createGame(faces, 6, seededRng(1));
    expect(game.cards).toHaveLength(12);
    const counts = new Map<string, number>();
    for (const c of game.cards) counts.set(c.face, (counts.get(c.face) ?? 0) + 1);
    expect([...counts.values()]).toEqual(Array(6).fill(2));
    expect(game.cards.every((c) => c.state === 'down')).toBe(true);
  });

  it('is repeatable with the same seed', () => {
    expect(createGame(faces, 4, seededRng(7))).toEqual(createGame(faces, 4, seededRng(7)));
  });

  it('has enough animals for every difficulty', () => {
    for (const d of difficulties) {
      expect((d.cols * d.rows) % 2).toBe(0);
      expect(() => createGame(faces, (d.cols * d.rows) / 2)).not.toThrow();
    }
  });
});

describe('flip', () => {
  it('matches a pair', () => {
    const game = createGame(faces, 2, seededRng(3));
    expect(flip(game, 0)).toBe('flipped');
    expect(flip(game, pairOf(game, 0))).toBe('match');
    expect(game.cards.filter((c) => c.state === 'matched')).toHaveLength(2);
    expect(game.moves).toBe(1);
  });

  it('holds a mismatch until hidden and ignores taps meanwhile', () => {
    const game = createGame(faces, 2, seededRng(3));
    const other = nonPairOf(game, 0);
    flip(game, 0);
    expect(flip(game, other)).toBe('mismatch');
    const third = game.cards.findIndex((c) => c.state === 'down');
    expect(flip(game, third)).toBe('ignored');
    expect(hideMismatch(game).sort()).toEqual([0, other].sort());
    expect(game.cards.every((c) => c.state === 'down')).toBe(true);
  });

  it('ignores the same card twice, matched cards and bad indexes', () => {
    const game = createGame(faces, 2, seededRng(3));
    flip(game, 0);
    expect(flip(game, 0)).toBe('ignored');
    flip(game, pairOf(game, 0));
    expect(flip(game, 0)).toBe('ignored');
    expect(flip(game, 99)).toBe('ignored');
  });

  it('completes when every pair is found', () => {
    const game = createGame(faces, 3, seededRng(5));
    for (let i = 0; i < game.cards.length; i++) {
      if (game.cards[i].state === 'down') {
        flip(game, i);
        flip(game, pairOf(game, i));
      }
    }
    expect(isComplete(game)).toBe(true);
    expect(game.moves).toBe(3);
  });
});
