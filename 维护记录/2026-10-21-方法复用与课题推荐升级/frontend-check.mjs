// T06 isolated SSR/helper checks. No production API calls or file mutations.
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
const frontend = 'E:/research-wiki/开发/frontend';
const require = createRequire(`${frontend}/package.json`);
const { createServer } = await import(pathToFileURL(`${frontend}/node_modules/vite/dist/node/index.js`));
const React = require('react');
const { renderToStaticMarkup: render } = require('react-dom/server');
const server = await createServer({ root: frontend, configFile: false, server: { middlewareMode: true }, appType: 'custom', logLevel: 'error' });
let checks = 0;
function check(fn) { fn(); checks++; }
try {
  const { Flow } = await server.ssrLoadModule('/src/flow.ts');
  const { methodFigures, methodPlateFigures, singlePanelKnowledge } = await server.ssrLoadModule('/src/figureModels.ts');
  const { MethodCard, PlateCard } = await server.ssrLoadModule('/src/components.tsx');
  const { CodeTextView, isReconstruction, codeFileKey } = await server.ssrLoadModule('/src/CodeViewer.tsx');
  const { RelationList } = await server.ssrLoadModule('/src/RelationList.tsx');
  const { codeDownload } = await server.ssrLoadModule('/src/api.ts');
  const { relationTargetLabel, verificationLabel } = await server.ssrLoadModule('/src/relations.ts');
  const method = { type: 'method', id: 'm', title: '方法', status: 'ready', tags: [], favorite: false, inputs: [], outputs: ['table'], source: { kind: 'written' }, license: 'none', cite: [] };
  const layout = (id, panels = { a: 'single' }) => ({ type: 'layout', id, title: id, status: 'pending_template', tags: [], favorite: false, language: 'r', gallery_entry: 'post', gallery_version: 1, chart_types: [], panels, templates: [], template_panels: {} });
  const template = (id) => ({ type: 'template', id, title: id, status: 'ready', tags: [], favorite: false, language: 'python', layouts: [], panels: ['a'], chart_types: [] });
  const relation = (figure, compatibility = 'adaptable') => ({ method: 'methods/m.md', figure, method_title: '方法', figure_title: figure, method_status: 'ready', figure_status: figure.startsWith('layouts/') ? 'pending_template' : 'ready', compatibility, reason: '每行含义已对照', prerequisites: ['同一验证单位'], adaptation: '映射列并核对键', evidence: ['方法页与图输入说明'], verification: { state: 'not_run', scope: '尚未在课题运行', evidence: [] }, target_kind: figure.startsWith('layouts/') ? 'layout' : 'template', active: true });
  const pages = [
    { path: 'methods/m.md', meta: method, relations: [relation('templates/semantic.md'), relation('layouts/semantic-source.md'), { ...relation('templates/archived.md'), active: false }], figure_refs: ['layouts/reference.md'] },
    { path: 'templates/structure.md', meta: template('structure') },
    { path: 'templates/semantic.md', meta: template('semantic') },
    { path: 'layouts/semantic-source.md', meta: layout('semantic-source') },
    { path: 'layouts/reference.md', meta: layout('reference') },
    { path: 'layouts/whole.md', meta: layout('whole', { a: 'one', b: 'two' }) },
    { path: 'templates/archived.md', meta: { ...template('archived'), status: 'archived' } },
  ];
  const graph = { nodes: pages.map((p) => ({ id: p.path, title: p.meta.title, type: p.meta.type, status: p.meta.status })), links: [
    { source: 'methods/m.md', target: 'interfaces/table.md', kind: 'feeds' },
    { source: 'interfaces/table.md', target: 'templates/structure.md', kind: 'feeds' },
    { source: 'methods/m.md', target: 'templates/semantic.md', kind: 'relation', compatibility: 'adaptable', verification: { state: 'not_run' } },
    { source: 'methods/m.md', target: 'layouts/whole.md', kind: 'link' },
  ] };
  const flow = new Flow(graph);
  check(() => assert.deepEqual(flow.figuresOf('methods/m.md'), ['templates/structure.md']));
  check(() => assert.deepEqual(flow.methodsFor('templates/structure.md'), ['methods/m.md']));
  check(() => assert(!flow.outputs('methods/m.md').includes('templates/semantic.md')));
  const figures = methodFigures('methods/m.md', pages, graph, flow);
  check(() => assert.equal(figures[0].relation, 'semantic'));
  check(() => assert.equal(figures.find((f) => f.path.includes('reference')).relation, 'reference'));
  check(() => assert.equal(figures.find((f) => f.path.includes('structure')).relation, 'compatible'));
  check(() => assert(!figures.some((f) => f.path.includes('whole') || f.path.includes('archived'))));
  check(() => assert.deepEqual(methodPlateFigures(figures).map((f) => f.relation), ['semantic', 'semantic', 'reference']));
  check(() => assert(!singlePanelKnowledge(pages, graph).pages.some((p) => p.path.includes('whole'))));
  const card = render(React.createElement(MethodCard, { path: 'methods/m.md', meta: method, number: 1, outputs: [], figures }));
  const plate = render(React.createElement(PlateCard, { path: 'layouts/l.md', meta: layout('l'), number: 1 }));
  for (const html of [card, plate]) {
    check(() => assert.equal((html.match(/>查看代码<\/button>/g) ?? []).length, 1));
    check(() => assert(!/<a\b[^>]*>(?:(?!<\/a>)[\s\S])*查看代码/.test(html), 'Code action must be outside card anchors'));
  }
  const code = render(React.createElement(CodeTextView, { text: '<script>globalThis.PWN=1</script>\n<img src=x onerror=alert(1)>\n# Markdown' }));
  check(() => assert(!code.includes('<script>') && !code.includes('<img ')));
  check(() => assert(code.includes('&lt;script&gt;') && code.includes('line-number')));
  check(() => assert(isReconstruction({ kind: 'generated-replica' })));
  check(() => assert(!isReconstruction('author original source')));
  check(() => assert.notEqual(codeFileKey({ variant: 'original', path: 'same.py' }), codeFileKey({ variant: 'reusable', path: 'same.py' })));
  check(() => assert(codeDownload('methods', 'm', { variant: 'original', path: 'nested/中文 file.R' }).includes('variant=original&path=nested%2F')));
  const record = relation('templates/semantic.md');
  const fromMethod = render(React.createElement(RelationList, { self: record.method, relations: [record] }));
  const fromFigure = render(React.createElement(RelationList, { self: record.figure, relations: [record] }));
  for (const html of [fromMethod, fromFigure]) {
    check(() => assert(html.includes('需要适配') && html.includes('同一验证单位') && html.includes('映射列并核对键')));
    check(() => assert(html.includes('未运行验证') && html.includes('尚未在课题运行')));
    check(() => assert(!html.includes('已验证可运行')));
  }
  check(() => assert.equal(relationTargetLabel(relation('layouts/semantic-source.md')), '图样参考／尚待模板化'));
  check(() => assert.equal(verificationLabel({ state: 'unexpected' }), '验证状态未知'));
  check(() => assert(render(React.createElement(RelationList, { self: record.method, relations: [{ ...record, active: false }] })).includes('已停用')));
  console.log(JSON.stringify({ checks, passed: true, scope: 'SSR/helpers only; no browser or scientific execution' }));
} finally { await server.close(); }
