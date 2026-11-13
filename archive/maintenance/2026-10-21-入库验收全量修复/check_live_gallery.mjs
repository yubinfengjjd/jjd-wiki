import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { spawnSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
const root = 'E:/research-wiki/开发/frontend';
const here = new URL('.', import.meta.url);
const require = createRequire(root + '/package.json');
const { build } = require('esbuild');
const output = new URL('live-gallery.cjs', here);
await build({stdin:{contents:`
import { galleryEntries, methodDisplayFigures } from './src/figureModels';
async function main() {
  const pages = await (await fetch('http://127.0.0.1:8765/api/pages')).json();
  const shelves = galleryEntries(pages);
  const method = methodDisplayFigures(pages.filter(p => p.meta.type === 'template' || p.meta.type === 'layout').map(p => ({...p, relation: 'reference'})));
  const report = {
    single: shelves.single.map(p => ({path:p.path, sources:(p.sourceLinks||[]).length})),
    templates: shelves.template.map(p => ({path:p.path, sources:(p.sourceLinks||[]).length})),
    method_visuals: method.length,
  };
  console.log(JSON.stringify(report, null, 2));
  if (shelves.single.length !== 5 || shelves.template.length !== 5) process.exit(1);
}
main();
`, resolveDir:root, loader:'ts'}, outfile:fileURLToPath(output), bundle:true, platform:'node', format:'cjs', target:'node22', logLevel:'silent'});
const result = spawnSync(process.execPath, [fileURLToPath(output)], {encoding:'utf8'});
if (result.status) { console.error(result.stderr); process.exit(result.status); }
console.log(result.stdout);
writeFileSync(new URL('live-gallery.json', here), result.stdout, 'utf8');
