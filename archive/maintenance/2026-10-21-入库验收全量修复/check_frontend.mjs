import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
const root = 'E:/research-wiki/开发/frontend';
const here = new URL('.', import.meta.url);
const require = createRequire(root + '/package.json');
const {build} = require('esbuild');
const output = new URL('frontend-regression.cjs', here);
await build({stdin:{contents:`
import assert from 'node:assert/strict';
import { galleryEntries, methodDisplayFigures } from './src/figureModels';
const tid='shared-bar';
const source=(id)=>({path:'layouts/'+id+'.md',meta:{
 type:'layout',id,title:id,status:'pending_template',language:'python',
 tags:[],favorite:false,panels:{A:'bar'},chart_types:['bar'],
 templates:[tid],template_panels:{[tid]:['A']}}});
const template={path:'templates/'+tid+'.md',meta:{
 type:'template',id:tid,title:'One shared style',status:'ready',language:'python',
 tags:[],favorite:false,panels:['A'],chart_types:['bar'],layouts:['source-one','source-two']}};
const pages=[source('source-one'),source('source-two'),template];
const shelves=galleryEntries(pages);
const method=methodDisplayFigures(pages.map(p=>({...p,relation:'reference'})));
assert.equal(shelves.single.length,1);
assert.equal(shelves.template.length,1);
assert.equal(method.length,1);
assert.equal(shelves.single[0].sourceLinks.length,2);
assert.equal(method[0].sourceLinks.length,2);
console.log(JSON.stringify({passed:true,
  description:'Two source pages explicitly reuse the same template and exact panel structure; Gallery and method display both show one style and preserve both source links.',
  gallery_style_paths:shelves.single.map(p=>p.path),
  callable_templates:shelves.template.length,method_visuals:method.length},null,2));
`,resolveDir:root,loader:'ts'},outfile:fileURLToPath(output),bundle:true,
platform:'node',format:'cjs',target:'node22',logLevel:'silent'});
const result=spawnSync(process.execPath,[fileURLToPath(output)],{encoding:'utf8'});
if(result.status){console.error(result.stderr);process.exit(result.status);}
console.log(result.stdout);
await writeFile(new URL('frontend-regression.json',here),result.stdout,'utf8');
