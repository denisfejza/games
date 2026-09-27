import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  // Phaser is one ~1.4 MB bundle (360 kB gzipped); that's expected.
  build: { outDir: '../../dist/memory-match', emptyOutDir: true, chunkSizeWarningLimit: 1500 },
});
