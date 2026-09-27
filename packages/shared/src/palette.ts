/** Bright, high-contrast colours shared by every game. */
export const palette = {
  background: '#fff7e6',
  primary: '#ff8a3d',
  secondary: '#3dbbff',
  success: '#5cc96b',
  accent: '#ffd23d',
  ink: '#3b2c4a',
  cardBack: '#7b6cf6',
  cardFace: '#ffffff',
} as const;

/** Converts a `#rrggbb` string to the numeric form Phaser expects. */
export function hex(color: string): number {
  return parseInt(color.slice(1), 16);
}
