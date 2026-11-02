import { createRequire } from 'node:module';
import { mkdir, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
const root = 'E:/research-wiki-env/work/wiki-cross-domain-20261024';
const require = createRequire(`${root}/development/frontend/package.json`);
const { build } = require('esbuild');
await mkdir(`${root}/codex-frontend-probe`, { recursive: true });
const source = `import assert from 'node:assert/strict';
import { conditionFacts } from '${root}/development/frontend/src/methods.ts';
const runtime = {tools:[{name:'vina',condition:'docking_only'}],
  hardware:{accelerator:'gpu',condition:'training_only'}};
const displayed = conditionFacts(runtime).join(';');
console.log(JSON.stringify({displayed, tool_condition_visible:displayed.includes('docking_only'),
  hardware_condition_visible:displayed.includes('training_only')}));
assert.ok(displayed.includes('docking_only') && displayed.includes('training_only'),
  'Conditional tools/hardware must not be displayed as unconditional requirements');`;
const output = `${root}/codex-frontend-probe/conditions.cjs`;
await build({ stdin: { contents: source, resolveDir: `${root}/development/frontend`, loader:'ts' },
  outfile:output, bundle:true, platform:'node', format:'cjs', target:'node22', logLevel:'silent' });
const result = spawnSync(process.execPath, [output], { encoding:'utf8' });
process.stdout.write(result.stdout);
process.stderr.write(result.stderr);
process.exitCode = result.status ?? 1;
