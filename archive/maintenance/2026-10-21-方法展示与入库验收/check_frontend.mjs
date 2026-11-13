import { createRequire } from 'node:module';
import { writeFile, readFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
const frontend = 'E:/research-wiki/开发/frontend';
const require = createRequire(frontend+'/package.json');
const { build } = require('esbuild');
const fixture = JSON.parse(await readFile(new URL('./pages.json',import.meta.url),'utf8'));
const graph = JSON.parse(await readFile(new URL('./graph.json',import.meta.url),'utf8'));
const bodies = {};
for(const name of ['shap-explanation','regression-resampling-evaluation']) {
  bodies[name] = (await readFile('E:/research-wiki/知识库/methods/'+name+'.md','utf8')).replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n/,'');
}
const out = 'E:/research-wiki-env/tmp/method-display-check.cjs';
await build({stdin:{contents:`
import assert from 'node:assert/strict';
import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { methodFigures,methodPlateFigures,methodDisplayFigures,singlePanelKnowledge,galleryInventory,templateSourceNote } from './src/figureModels';
import { api,pageCache } from './src/api';
import { Flow } from './src/flow';
import { PageView } from './src/views/PageView';
import { renderBody,methodPurpose } from './src/markdown';
const raw = ${JSON.stringify(fixture)};
const bodies = ${JSON.stringify(bodies)};
const visible = singlePanelKnowledge(raw,${JSON.stringify(graph)});
const flow = {figuresOf:()=>[]};
const regression = methodFigures('methods/regression-resampling-evaluation.md',visible.pages,visible.graph,flow);
const shap = methodFigures('methods/shap-explanation.md',visible.pages,visible.graph,flow);
assert.equal(regression.length,4,'underlying source and template relationships must all remain');
assert.equal(methodPlateFigures(regression).length,2,'same source/panel and its callable template must not appear as duplicate pictures');
assert.ok(methodPlateFigures(regression).every(f=>f.meta.type==='template'));
assert.equal(methodPlateFigures(shap).length,3);
assert.ok(methodPlateFigures(shap).every(f=>f.semantic.compatibility==='direct'));
assert.ok(methodPlateFigures(regression).every(f=>f.semantic.compatibility==='adaptable'));
let checks=6;
assert.deepEqual(galleryInventory(visible.pages,visible.hiddenSources),{sources:2,templates:5,historical:3}); checks++;
for(const f of methodPlateFigures(shap)){assert.match(templateSourceNote(f.meta,visible.pages,visible.hiddenSources),/历史.*整图来源已归档/);checks++;}
for(const f of methodPlateFigures(regression)){assert.match(templateSourceNote(f.meta,visible.pages,visible.hiddenSources),/已收录单 panel 图样/);checks++;}
const unmatched = regression.map(f=>f.meta.type==='layout'?{...f,meta:{...f.meta,template_panels:{}}}:f);
assert.equal(methodDisplayFigures(unmatched).length,4,'unproven coverage must not hide different/unresolved source styles'); checks++;
const env={titles:new Map(visible.pages.map(p=>[p.path,p.meta.title])),hiddenSources:visible.hiddenSources};
assert.ok(methodPurpose(bodies['regression-resampling-evaluation']).includes('验证预测')); checks++;
const rawBody='# Method\\n<!-- facts:start -->\\nFACTS_METADATA\\n<!-- facts:end -->\\n## 用途\\n正文\\n<!-- user:start -->\\nAUTHOR_ONLY\\n<!-- user:end -->';
const clean=renderBody(rawBody,env,{dropUser:true,dropFacts:true});
assert.ok(clean.includes('正文')&&!clean.includes('FACTS_METADATA')&&!clean.includes('AUTHOR_ONLY')); checks++;
assert.ok(renderBody(rawBody,env).includes('FACTS_METADATA'),'default full Markdown rendering is unchanged'); checks++;
async function main(){
globalThis.fetch=async()=>({ok:true,json:async()=>raw});
await api.pages();
const realFlow=new Flow(visible.graph);
for(const [id,count,compat] of [['regression-resampling-evaluation',2,'需要适配'],['shap-explanation',3,'直接可接']]){
 const page=visible.pages.find(p=>p.path==='methods/'+id+'.md');
 pageCache.set(page.path,{...page,body:bodies[id],backlinks:[],gallery:null});
 const html=renderToStaticMarkup(<PageView path={page.path} data={{pages:visible.pages,graph:visible.graph,flow:realFlow,env,reload:async()=>{}}}/>);
 assert.equal((html.match(/class="method-visual"/g)||[]).length,count);checks++;
 assert.ok(html.includes(compat)&&html.includes('分析到绘图：未运行验证'));checks++;
 assert.ok(html.includes('分析需要什么')&&html.includes('分析得到什么')&&html.includes('查看代码'));checks++;
 assert.ok(html.includes('<details class="method-details">')&&!html.includes('<details open'));checks++;
 assert.ok(html.indexOf('可以怎样画')<html.indexOf('查看接口结构匹配与完整关联证据'));checks++;
 assert.equal((html.match(/class="relation-record"/g)||[]).length,id.startsWith('regression')?4:3);checks++;
 if(id.startsWith('regression')){assert.ok(html.includes('使用前需准备')&&!html.includes('compatibility-direct'));checks++;}
}
console.log(JSON.stringify({passed:true,checks,regressionVisuals:2,shapVisuals:3,underlyingRegressionRelations:4,inventory:{sources:2,templates:5,historical:3},scope:'actual PageView SSR, display dedupe, provenance, compatibility and full-record preservation'}));
}
main().catch(error=>{console.error(error);process.exit(1)});
`,resolveDir:frontend,loader:'tsx'},outfile:out,bundle:true,platform:'node',format:'cjs',jsx:'automatic',target:'node22',logLevel:'silent'});
const result = spawnSync(process.execPath,[out],{encoding:'utf8'});
if(result.status){console.error(result.stderr);process.exit(result.status);}
console.log(result.stdout);
await writeFile(new URL('./frontend-verification.json',import.meta.url),result.stdout,'utf8');
