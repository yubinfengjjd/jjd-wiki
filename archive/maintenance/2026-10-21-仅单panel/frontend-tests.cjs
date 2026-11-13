const fs = require('node:fs');
const path = require('node:path');
const {createRequire} = require('node:module');
const assert = require('node:assert/strict');
const test = require('node:test');
const frontend = 'E:/research-wiki/开发/frontend';
const dep = createRequire(path.join(frontend,'package.json'));
const ts = dep('typescript');
const cache = new Map();
function load(name) {
  const file = path.join(frontend,'src',name+'.ts');
  if(cache.has(file)) return cache.get(file);
  const module = {exports:{}}; cache.set(file,module.exports);
  const code = ts.transpileModule(fs.readFileSync(file,'utf8'),{
    compilerOptions:{target:ts.ScriptTarget.ES2022,module:ts.ModuleKind.CommonJS,esModuleInterop:true}
  }).outputText;
  new Function('require','module','exports',code)((s)=>s.startsWith('.')?load(path.join(path.dirname(name),s)):dep(s),module,module.exports);
  cache.set(file,module.exports); return module.exports;
}
const model = load('figureModels');
const {Flow} = load('flow');
const {renderBody} = load('markdown');
const pages = JSON.parse(fs.readFileSync(path.join(__dirname,'api-pages.json'),'utf8'));
const graph = JSON.parse(fs.readFileSync(path.join(__dirname,'api-graph.json'),'utf8'));
const visible = model.singlePanelKnowledge(pages,graph);
test('actual whole sources hidden from all global data including graph edges',()=>{
  assert.equal(visible.hiddenSources.size,3);
  assert(visible.pages.every(p=>!model.isWholeSource(p.meta)));
  assert(visible.graph.nodes.every(n=>!visible.hiddenSources.has(n.id)));
  assert(visible.graph.links.every(e=>!visible.hiddenSources.has(e.source)&&!visible.hiddenSources.has(e.target)));
});
test('single sources and all five single-panel templates retained',()=>{
  assert.equal(visible.pages.filter(p=>p.meta.type==='layout').length,2);
  assert.equal(visible.pages.filter(p=>p.meta.type==='template').length,5);
  for(const p of visible.pages.filter(p=>p.meta.type==='template')) assert.equal(model.shelfOf(p.meta),'template');
});
test('a newly imported unarchived whole source is hidden too',()=>{
  const group = pages.find(p=>model.isWholeSource(p.meta));
  assert.equal(model.shelfOf({...group.meta,status:'ready'}),null);
  assert.equal(model.singlePanelKnowledge([{...group,meta:{...group.meta,status:'ready'}}],graph).pages.length,0);
});
test('all four methods retain relevant single-panel illustrations',()=>{
  const flow = new Flow(visible.graph);
  for(const m of visible.pages.filter(p=>p.meta.type==='method')) {
    const pictures = model.methodFigures(m.path,visible.pages,visible.graph,flow);
    assert(pictures.length>0,m.path);
    assert(pictures.every(p=>!model.isWholeSource(p.meta)));
  }
});
test('historical source facts retain provenance without whole-source navigation',()=>{
  const hidden = [...visible.hiddenSources][0];
  const html=renderBody('[[ '+hidden+'|whole figure title]]',{
    titles:new Map(),hiddenSources:visible.hiddenSources
  });
  assert(html.includes('原始来源已归档'));
  assert(!html.includes('href='));
  assert(!html.includes('whole figure title'));
});
