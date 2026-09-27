export type Lang = 'en' | 'sq';

export const languages: Record<Lang, { label: string; flag: string }> = {
  en: { label: 'English', flag: '🇬🇧' },
  sq: { label: 'Shqip', flag: '🇦🇱' },
};

const strings = {
  en: {
    appTitle: 'Kids Games',
    chooseGame: 'Choose a game',
    memoryMatch: 'Animal Memory',
    play: 'Play',
    playAgain: 'Play again',
    home: 'Home',
    wellDone: 'Well done!',
  },
  sq: {
    appTitle: 'Lojëra për Fëmijë',
    chooseGame: 'Zgjidh një lojë',
    memoryMatch: 'Kujtesa e Kafshëve',
    play: 'Luaj',
    playAgain: 'Luaj përsëri',
    home: 'Kreu',
    wellDone: 'Të lumtë!',
  },
} satisfies Record<Lang, Record<string, string>>;

export type StringKey = keyof (typeof strings)['en'];

const STORAGE_KEY = 'kids-games.lang';

/** Picks the saved language, else the browser's, else English. */
export function detectLang(
  saved: string | null = readSaved(),
  browser: readonly string[] = typeof navigator === 'undefined' ? [] : navigator.languages,
): Lang {
  if (saved === 'en' || saved === 'sq') return saved;
  return browser.some((l) => l.toLowerCase().startsWith('sq')) ? 'sq' : 'en';
}

export function saveLang(lang: Lang): void {
  try {
    localStorage.setItem(STORAGE_KEY, lang);
  } catch {
    // Storage can be unavailable (private mode); the choice just isn't remembered.
  }
}

function readSaved(): string | null {
  try {
    return localStorage.getItem(STORAGE_KEY);
  } catch {
    return null;
  }
}

export function t(lang: Lang, key: StringKey): string {
  return strings[lang][key];
}

export function otherLang(lang: Lang): Lang {
  return lang === 'en' ? 'sq' : 'en';
}
