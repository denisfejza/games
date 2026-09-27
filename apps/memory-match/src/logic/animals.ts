import type { Lang } from '@kids-games/shared';

export interface Animal {
  id: string;
  /** Placeholder art until the CC0 sprite pack lands (M3). */
  emoji: string;
  name: Record<Lang, string>;
}

export const animals: readonly Animal[] = [
  { id: 'dog', emoji: '🐶', name: { en: 'Dog', sq: 'Qen' } },
  { id: 'cat', emoji: '🐱', name: { en: 'Cat', sq: 'Mace' } },
  { id: 'cow', emoji: '🐮', name: { en: 'Cow', sq: 'Lopë' } },
  { id: 'pig', emoji: '🐷', name: { en: 'Pig', sq: 'Derr' } },
  { id: 'frog', emoji: '🐸', name: { en: 'Frog', sq: 'Bretkosë' } },
  { id: 'lion', emoji: '🦁', name: { en: 'Lion', sq: 'Luan' } },
  { id: 'monkey', emoji: '🐵', name: { en: 'Monkey', sq: 'Majmun' } },
  { id: 'rabbit', emoji: '🐰', name: { en: 'Rabbit', sq: 'Lepur' } },
];
