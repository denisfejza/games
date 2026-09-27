import { describe, expect, it } from 'vitest';
import { detectLang, otherLang, t } from './i18n';

describe('detectLang', () => {
  it('prefers a saved language', () => {
    expect(detectLang('sq', ['en-US'])).toBe('sq');
  });
  it('uses Albanian when the browser asks for it', () => {
    expect(detectLang(null, ['en-US', 'sq-AL'])).toBe('sq');
  });
  it('falls back to English', () => {
    expect(detectLang(null, ['de-DE'])).toBe('en');
    expect(detectLang('xx', [])).toBe('en');
  });
});

it('translates and toggles', () => {
  expect(t('sq', 'wellDone')).toBe('Të lumtë!');
  expect(otherLang('sq')).toBe('en');
});
