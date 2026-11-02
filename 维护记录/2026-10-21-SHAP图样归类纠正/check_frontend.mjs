import { createRequire } from 'node:module';
import { readFile,writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
const frontend='E:/research-wiki/开发/frontend';
const require=createRequire(frontend+'/package.json');
const {build}=require('esbuild');
const fixtures=JSON.parse(await readFile(new URL('./pages.json',import.meta.url),'utf8'));
const graph=JSON.parse(await readFile(new URL('./graph.json',import.meta.url),'utf8'));
const outfile='E:/research-wiki-env/tmp/shap-style-shelf.cjs';
await build({stdin:{contents:`
import assert from 'node:assert/strict';
import React from 'react';
import {renderToStaticMarkup} from 'react-dom/server';
import {Gallery} from './src/views/Gallery';
import {api} from './src/api';
import {singlePanelKnowledge,galleryEntries,galleryInventory,methodFigures,methodPlateFigures} from './src/figureModels';
import {Flow} from './src/flow';
const raw=${JSON.stringify(fixtures)};
const graph=${JSON.stringify(graph)};
async function main(){
 globalThis.fetch=async()=>({ok:true,json:async()=>raw}); await api.pages();
 const visible=singlePanelKnowledge(raw,graph);
 const before=JSON.stringify(visible.pages);
 const data={pages:visible.pages,graph:visible.graph,flow:new Flow(visible.graph),env:{titles:new Map(visible.pages.map(p=>[p.path,p.meta.title])),hiddenSources:visible.hiddenSources},reload:async()=>{}};
 const html=renderToStaticMarkup(<Gallery data={data}/>);
 assert.equal((html.match(/class="plate-card"/g)||[]).length,5,'single-panel gallery must include the three existing SHAP panel styles');
 for(const title of ['SHAP 条形图（含环形 inset）','SHAP 蜂群图','SHAP 环形贡献图'])assert.ok(html.includes(title),title);
 assert.ok(html.includes('单 panel 图样<span class="muted"> <!-- -->5</span>')||/单 panel 图样.*?5/.test(html));
 assert.equal(JSON.stringify(visible.pages),before,'classification is derived, not a new entry or status change');
 let checks=6;
 const entries=galleryEntries(visible.pages);
 assert.equal(entries.template.length,5);checks++;
 assert.equal(new Set(entries.single.map(p=>p.path)).size,5);checks++;
 assert.ok(entries.single.every(p=>p.meta.type==='template'||Object.keys(p.meta.panels).length===1));checks++;
 assert.deepEqual(galleryInventory(visible.pages,visible.hiddenSources),{styles:5,sources:2,templates:5,historical:3});checks++;
 const archived=structuredClone(visible.pages);
 archived.find(p=>p.meta.type==='template'&&p.meta.id.endsWith('--beeswarm')).meta.status='archived';
 assert.equal(galleryEntries(archived).single.length,4);checks++;
 assert.equal(galleryEntries(archived).template.length,4);checks++;
 const archivedDensity=structuredClone(visible.pages);
 archivedDensity.find(p=>p.meta.type==='template'&&p.meta.id.endsWith('--density-scatter')).meta.status='archived';
 assert.equal(galleryEntries(archivedDensity).single.length,5,'source style remains browsable when its function is archived');checks++;
 assert.equal(galleryEntries(archivedDensity).template.length,4);checks++;
 const missingSource=visible.pages.filter(p=>p.path!=='layouts/2026-10-19-regression-stability__fig03-density-panel.md');
 assert.equal(galleryEntries(missingSource).single.length,5,'template style remains browsable without a separate source page');checks++;
 const unproven=structuredClone(visible.pages);
 unproven.find(p=>p.path==='layouts/2026-10-19-regression-stability__fig03-density-panel.md').meta.template_panels={};
 assert.equal(galleryEntries(unproven).single.length,6,'unknown coverage must not silently merge different variants');checks++;
 for(const [id,count] of [['regression-resampling-evaluation',2],['shap-explanation',3]]){
   assert.equal(methodPlateFigures(methodFigures('methods/'+id+'.md',visible.pages,visible.graph,data.flow)).length,count);checks++;
 }
 assert.equal((html.match(/>查看代码<\\/button>/g)||[]).length,5);checks++;
 assert.ok(html.includes('可以包含同一条记录')||html.includes('可以包含同一条')||html.includes('两栏可以包含同一条记录'));checks++;
 console.log(JSON.stringify({passed:true,checks,styles:5,templates:5,sourceRecords:2,scope:'actual Gallery SSR, overlapping views, source/template coverage, archive and method-card regressions; no entry/status mutations'}));
}
main().catch(error=>{console.error(error);process.exit(1)});
`,resolveDir:frontend,loader:'tsx'},outfile,bundle:true,platform:'node',format:'cjs',jsx:'automatic',target:'node22',logLevel:'silent'});
const result=spawnSync(process.execPath,[outfile],{encoding:'utf8'});
if(result.status){console.error(result.stderr);process.exit(result.status);}
console.log(result.stdout);
await writeFile(new URL('./frontend-verification.json',import.meta.url),result.stdout,'utf8');
