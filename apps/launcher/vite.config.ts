import { defineConfig } from 'vite';

// Relative base so the build works under GitHub Pages' /games/ path and inside Capacitor.
// The launcher owns the site root, so it builds first and empties dist/.
export default defineConfig({
  base: './',
  build: { outDir: '../../dist', emptyOutDir: true },
});
