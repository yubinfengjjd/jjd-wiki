const fs=require('node:fs'),path=require('node:path');
const {createRequire}=require('node:module');
const test=require('node:test'),assert=require('node:assert/strict');
const root='E:/research-wiki/开发/frontend';
const dep=createRequire(path.join(root,'package.json')),ts=dep('typescript');
const loaded=new Map();
function load(name){
 let file=path.join(root,'src',name);if(!fs.existsSync(file))file+=fs.existsSync(file+'.ts')?'.ts':'.tsx';
 if(loaded.has(file))return loaded.get(file).exports;
 const mod={exports:{}};loaded.set(file,mod);
 const js=ts.transpileModule(fs.readFileSync(file,'utf8'),{compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.CommonJS,jsx:ts.JsxEmit.ReactJSX,esModuleInterop:true}}).outputText;
 new Function('require','module','exports',js)(s=>s.startsWith('.')?load(path.join(path.dirname(name),s)):dep(s),mod,mod.exports);
 return mod.exports;
}
const {api,imageOf,pageCache}=load('api');
const {FigureImage}=load('components');
const {DeleteArchived}=load('DeleteArchived');
const React=dep('react'),{renderToStaticMarkup}=dep('react-dom/server');
const meta={type:'template',id:'draft-panel',title:'草稿',status:'archived',archived_from:'draft',layouts:['source'],panels:['A'],language:'python',tags:[],chart_types:['boxplot'],favorite:false};
function serve(preview){global.fetch=async()=>({ok:true,json:async()=>[{path:'templates/draft-panel.md',meta,preview}]});}
test('archived unfinished template uses existing source and labels it',async()=>{
 serve({kind:'source',url:'/files/wiki/layouts/source/thumb.png',label:'来源参考图 · 模板尚无回放'});await api.pages();
 assert.equal(imageOf(meta),'/files/wiki/layouts/source/thumb.png');
 const html=renderToStaticMarkup(React.createElement(FigureImage,{meta}));
 assert(html.includes('来源参考图'));assert(!html.includes('draft-panel/preview.png'));
});
test('no preview yields text instead of broken img',async()=>{
 serve({kind:'none',url:null,label:'暂无预览图'});await api.pages();
 const html=renderToStaticMarkup(React.createElement(FigureImage,{meta}));
 assert(html.includes('暂无预览图'));assert(!html.includes('<img'));
});
test('replay retains its real preview',async()=>{
 serve({kind:'replay',url:'/files/wiki/templates/draft-panel/preview.png',label:'模板回放'});await api.pages();
 const html=renderToStaticMarkup(React.createElement(FigureImage,{meta}));
 assert(html.includes('模板回放'));assert(!html.includes('来源参考图'));
});
test('frontend delete calls backend plan and confirmed revision endpoint',async()=>{
 const calls=[];global.fetch=async(url,init)=>{calls.push({url,init});return {ok:true,json:async()=>({revision:'v1',deleted:true})};};
 await api.deletePlan('templates',meta.id);
 pageCache.set('test',{});
 await api.deleteArchived('templates',meta.id,'v1');
 assert.equal(calls[0].url,'/api/templates/draft-panel/delete-plan');
 assert.equal(calls[1].url,'/api/templates/draft-panel/delete');
 assert.equal(calls[1].init.method,'POST');
 assert.deepEqual(JSON.parse(calls[1].init.body),{confirmed:true,revision:'v1'});
 assert.equal(pageCache.size,0);
});
test('delete control is shown only for archived items',()=>{
 const html=renderToStaticMarkup(React.createElement(DeleteArchived,{meta,onDeleted:async()=>{}}));
 assert(html.includes('删除'));
 const ready=renderToStaticMarkup(React.createElement(DeleteArchived,{meta:{...meta,status:'ready'},onDeleted:async()=>{}}));
 assert.equal(ready,'');
});
