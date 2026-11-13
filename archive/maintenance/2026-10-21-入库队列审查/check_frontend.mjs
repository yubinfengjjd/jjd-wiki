import { createRequire } from 'node:module';
import { writeFile, readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
const frontend = 'E:/research-wiki/开发/frontend';
const require = createRequire(frontend + '/package.json');
const { build } = require('esbuild');
const out = 'E:/research-wiki-env/tmp/workflow-frontend-check.cjs';
await build({stdin:{contents:`
import assert from 'node:assert/strict';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { api } from './src/api';
import { queueOf, pendingCount } from './src/workflow';
import { QueueView } from './src/views/QueueView';
const source = {path:'layouts/source.md',meta:{type:'layout',id:'source',title:'Source',status:'pending_template',panels:{A:'bar'},templates:['template'],template_panels:{template:['A']},tags:[],language:'python',chart_types:['bar'],favorite:false}};
const template = {path:'templates/template.md',meta:{type:'template',id:'template',title:'Template',status:'draft',layouts:['source'],panels:['A'],tags:[],language:'python',chart_types:['bar'],favorite:false}};
const workflow = (stage, queue, label='fixture') => ({stage,queue,label,reason:'fixture',templates:[]});
let checks = 0;
async function check(records, agent, confirm, total) {
  globalThis.fetch = async () => ({ok:true,json:async()=>records});
  const pages = await api.pages();
  const html = renderToStaticMarkup(<QueueView data={{pages,graph:{nodes:[],links:[]},flow:{outputs:()=>[]},reload:async()=>{}}} />);
  assert.equal(pendingCount(pages),total); checks++;
  for(const [title,expected] of [['等 agent 处理',agent],['待你确认',confirm]]) {
    assert.equal(Number(html.match(new RegExp(title+'<span class="count">(\\\\d+)</span>'))?.[1]),expected,html); checks++;
  }
}
async function main() {
await check([{...source,workflow:workflow('complete',null)},{...template,meta:{...template.meta,status:'ready'},workflow:workflow('complete',null)}],0,0,0);
await check([{...source,workflow:workflow('template_work',null)},{...template,workflow:workflow('template_work','agent')}],1,0,1);
await check([{...source,workflow:workflow('template_confirm',null)},{...template,workflow:workflow('template_confirm','confirm')}],0,1,1);
await check([{...source,workflow:workflow('template_missing','agent')}],1,0,1);
assert.equal(queueOf({...template,meta:{...template.meta,status:'archived'},workflow:workflow('archived',null)}),null); checks++;
console.log(JSON.stringify({passed:true,checks,scope:'Actual QueueView SSR, API cache and shared navigation count; no browser mutation'}));
}
main().catch((error)=>{console.error(error);process.exit(1)});
`,resolveDir:frontend,loader:'tsx'},outfile:out,bundle:true,platform:'node',format:'cjs',target:'node22',logLevel:'silent'});
const { spawnSync } = await import('node:child_process');
const result = spawnSync(process.execPath,[out],{encoding:'utf8'});
if (result.status) { console.error(result.stderr); process.exit(result.status); }
console.log(result.stdout);
await writeFile(new URL('./frontend-verification.json', import.meta.url),result.stdout,'utf8');
