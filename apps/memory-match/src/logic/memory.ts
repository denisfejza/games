import { shuffle, type Rng } from '@kids-games/shared';

export type CardState = 'down' | 'up' | 'matched';

export interface Card {
  /** Which pair this card belongs to (e.g. an animal id). */
  face: string;
  state: CardState;
}

export interface Game {
  cards: Card[];
  /** Indexes of face-up cards that aren't matched yet (0–2). */
  selected: number[];
  moves: number;
}

export type FlipResult = 'ignored' | 'flipped' | 'match' | 'mismatch';

export interface Difficulty {
  cols: number;
  rows: number;
}

export const difficulties: readonly Difficulty[] = [
  { cols: 2, rows: 2 },
  { cols: 3, rows: 2 },
  { cols: 4, rows: 3 },
];

export function createGame(faces: readonly string[], pairs: number, rng?: Rng): Game {
  if (pairs > faces.length) throw new Error(`Need ${pairs} faces, got ${faces.length}`);
  const chosen = shuffle(faces, rng).slice(0, pairs);
  const cards = shuffle([...chosen, ...chosen], rng).map((face) => ({ face, state: 'down' as const }));
  return { cards, selected: [], moves: 0 };
}

/**
 * Flips the card at `index`. Taps are ignored on cards already showing and
 * while a mismatched pair is waiting for {@link hideMismatch}.
 * Mutates `game` in place and reports what happened so the view can animate it.
 */
export function flip(game: Game, index: number): FlipResult {
  const card = game.cards[index];
  if (!card || card.state !== 'down' || game.selected.length >= 2) return 'ignored';

  card.state = 'up';
  game.selected.push(index);
  if (game.selected.length < 2) return 'flipped';

  game.moves++;
  const [a, b] = game.selected.map((i) => game.cards[i]);
  if (a.face !== b.face) return 'mismatch';

  a.state = b.state = 'matched';
  game.selected = [];
  return 'match';
}

/** Turns a mismatched pair face-down again; returns the indexes that flipped back. */
export function hideMismatch(game: Game): number[] {
  if (game.selected.length < 2) return [];
  const hidden = game.selected;
  for (const i of hidden) game.cards[i].state = 'down';
  game.selected = [];
  return hidden;
}

export function isComplete(game: Game): boolean {
  return game.cards.every((c) => c.state === 'matched');
}
