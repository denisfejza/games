import { detectLang, languages, otherLang, saveLang, t, type Lang } from '@kids-games/shared';
import './style.css';

let lang = detectLang();

function el(id: string): HTMLElement {
  return document.getElementById(id)!;
}

function render(): void {
  document.documentElement.lang = lang;
  document.title = t(lang, 'appTitle');
  el('title').textContent = t(lang, 'appTitle');
  el('choose').textContent = t(lang, 'chooseGame');
  el('memory-name').textContent = t(lang, 'memoryMatch');
  const next: Lang = otherLang(lang);
  el('lang').textContent = `${languages[next].flag} ${languages[next].label}`;
}

el('lang').addEventListener('click', () => {
  lang = otherLang(lang);
  saveLang(lang);
  render();
});

render();
