// Isolated headless browser acceptance. The fixture server has no production proxy.
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
const frontend = 'E:/research-wiki/开发/frontend';
const task = 'E:/research-wiki/维护记录/2026-10-21-方法复用与课题推荐升级';
const cache = 'E:/research-wiki-env';
mkdirSync(cache, { recursive: true });
const temp = mkdtempSync(join(cache, 't06-ui-'));
const downloads = join(temp, 'downloads');
mkdirSync(downloads);
const { createServer } = await import(pathToFileURL(`${frontend}/node_modules/vite/dist/node/index.js`));
const raw = Buffer.from('print("R original")\r\n# 原始字节\r\n', 'utf8');
const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="/src/styles.css"></head><body><div id="root"></div><script type="module">
import React from '/node_modules/.vite/deps/react.js';
import ReactDOM from '/node_modules/.vite/deps/react-dom_client.js';
import { CodeButton } from '/src/CodeViewer.tsx';
import { MethodCard, PlateCard } from '/src/components.tsx';
window.__copied = null;
Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: async text => { window.__copied = text; } } });
const method = id => ({ type:'method', id, title:id, status:'ready', tags:[], favorite:false, inputs:[], outputs:[], source:{kind:'written'},license:'none',cite:[] });
const plate = {type:'layout', id:'plate', title:'图样卡',status:'pending_template',tags:[],favorite:false,language:'r',gallery_entry:'fixture',gallery_version:1,chart_types:[],panels:{a:'one'},templates:[],template_panels:{}};
const contents = { 'original:main.R': ${JSON.stringify(raw.toString())}, 'original:slow.py':'SLOW_OLD_CONTENT', 'original:note.ipynb':'<scr'+'ipt>globalThis.__executed = true</scr'+'ipt>\\n<img src=x onerror=globalThis.__executed=true>', 'reusable:main.py':'print("reusable")\\n' };
const files = [ ['original','main.R','r',true,'author original'], ['original','slow.py','python',true,'author snippet'], ['original','note.ipynb','json',true,'author original'], ['original','raw.bin','binary',false,'author original'], ['reusable','main.py','python',true,'generated replica'] ].map(([variant,path,language,text,source])=>({variant,path,language,text,source,size:42,sha256:'fixture-sha256',verification:{state:'not_run',scope:'界面夹具，未运行分析',evidence:[]}}));
window.fetch = async (url) => {
 const u = new URL(String(url),location.origin), item = u.pathname.split('/')[3];
 if (!u.pathname.startsWith('/api/')) throw new Error('Unexpected fixture fetch '+url);
 if (item === 'error') return new Response(JSON.stringify({detail:'fixture expected error'}), {status:500,headers:{'Content-Type':'application/json'}});
 if(u.pathname.endsWith('code-files')) { await new Promise(r=>setTimeout(r,item==='slowitem'?200:35)); return Response.json({files:item==='empty'?[]:files,note:'仅用于界面验收的代码夹具'}); }
 const variant=u.searchParams.get('variant'),path=u.searchParams.get('path');
 await new Promise(r=>setTimeout(r,path==='slow.py'?220:25));
 return Response.json({variant,path,language:files.find(f=>f.path===path&&f.variant===variant)?.language,text:contents[variant+':'+path]??null,encoding:path==='raw.bin'?null:'utf-8',note:path==='raw.bin'?'二进制文件；只能下载':'',sha256:'fixture-sha256',size:42});
};
function App(){const [id,setId]=React.useState('normal');return React.createElement('main',{className:'main'},
 React.createElement('div',{'data-testid':'cards',className:'grid'},
 React.createElement(MethodCard,{path:'methods/normal.md',meta:method('normal'),number:1,outputs:[],figures:[]}),
 React.createElement(PlateCard,{path:'layouts/plate.md',meta:plate,number:2})),
 React.createElement('div',{'data-testid':'switcher'},
 React.createElement('button',{onClick:()=>setId('slowitem')},'切换慢条目'),React.createElement('button',{onClick:()=>setId('empty')},'切换空条目'),
 React.createElement(CodeButton,{meta:method(id)})),
 React.createElement('div',{'data-testid':'empty'},React.createElement(CodeButton,{meta:method('empty')})),
 React.createElement('div',{'data-testid':'error'},React.createElement(CodeButton,{meta:method('error')})) );}
ReactDOM.createRoot(document.getElementById('root')).render(React.createElement(App));
</script></body></html>`;
const server = await createServer({ root: frontend, configFile: false, logLevel: 'error', optimizeDeps: { include: ['react', 'react-dom/client'] }, server: { host: '127.0.0.1', port: 0 }, plugins: [{ name: 'isolated-fixture', configureServer(s) { s.middlewares.use((req, res, next) => {
  if (req.url === '/__t06') { res.setHeader('Content-Type', 'text/html; charset=utf-8'); res.end(html); }
  else if (req.url?.startsWith('/api/') && req.url.includes('/code-download?')) { res.setHeader('Content-Type', 'application/octet-stream'); res.setHeader('Content-Disposition', 'attachment; filename="main.R"'); res.end(raw); }
  else next();
}); } }] });
let chrome, ws;
const checks = [], errors = [];
const sleep = (ms) => new Promise(r => setTimeout(r,ms));
try {
  await server.listen();
  const url = `http://127.0.0.1:${server.httpServer.address().port}/__t06`;
  chrome = spawn('C:/Program Files/Google/Chrome/Application/chrome.exe', ['--headless=new', '--remote-debugging-port=0', `--user-data-dir=${join(temp,'chrome')}`, '--window-size=1440,1000', '--no-first-run', '--no-default-browser-check', 'about:blank'], { windowsHide: true, stdio: ['ignore','ignore','pipe'] });
  let endpoint = '';
  chrome.stderr.on('data', data => { const match = String(data).match(/DevTools listening on (ws:\/\/[^\s]+)/); if (match) endpoint = match[1]; });
  for(let i=0;i<100&&!endpoint;i++) await sleep(50);
  assert(endpoint,'Chrome debugging endpoint must start');
  const targets = await (await fetch(endpoint.replace(/^ws:/,'http:').replace(/\/devtools\/browser\/.*$/,'/json/list'))).json();
  ws = new WebSocket(targets.find(t=>t.type==='page').webSocketDebuggerUrl);
  await new Promise(r=>ws.addEventListener('open',r));
  let id=0;
  const pending = new Map();
  ws.addEventListener('message',e=>{ const m=JSON.parse(e.data); if(m.id&&pending.has(m.id)){pending.get(m.id)(m);pending.delete(m.id);} if(m.method==='Runtime.exceptionThrown') errors.push(m.params.exceptionDetails.exception?.description??m.params.exceptionDetails.text); });
  const send=(method,params={})=>new Promise(resolve=>{const n=++id;pending.set(n,resolve);ws.send(JSON.stringify({id:n,method,params}));});
  const evaluate=async expression=>{ const r=await send('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true}); if(r.result.exceptionDetails)throw new Error(r.result.exceptionDetails.exception?.description??r.result.exceptionDetails.text);return r.result.result?.value; };
  const verify=async(name,expression)=>{assert(await evaluate(expression),`${name}: ${await evaluate('document.activeElement?.outerHTML?.slice(0,200)')}`);checks.push(name);};
  const waitFor=async expression=>{for(let i=0;i<100;i++){if(await evaluate(expression))return;await sleep(30);}throw new Error('Timed out '+expression+' '+JSON.stringify({errors,body:await evaluate('document.body.innerText')}));};
  await send('Runtime.enable'); await send('Page.enable');
  await send('Browser.setDownloadBehavior',{behavior:'allow',downloadPath:downloads,eventsEnabled:true});
  await send('Page.navigate',{url});
  await waitFor("document.querySelectorAll('.plate-card').length === 2");
  await verify('card buttons independent of navigation anchors', "[...document.querySelectorAll('.plate-card .card-code')].every(b=>!b.closest('a'))");
  await evaluate("window.__beforeHash=location.hash;document.querySelector('.plate-card .card-code').focus();document.querySelector('.plate-card .card-code').click()");
  await verify('code click does not navigate or flip', "location.hash===window.__beforeHash&&!document.querySelector('.plate-card').classList.contains('flipped')&&!!document.querySelector('[role=dialog]')");
  await waitFor("document.querySelector('.code-text')?.textContent.includes('R original')");
  await verify('version tabs and multi-file languages', "document.querySelectorAll('.code-tabs [role=tab]').length===2&&document.querySelectorAll('.code-file-list button').length===4&&document.querySelector('.code-file-list').textContent.includes('r')&&document.querySelector('.code-file-list').textContent.includes('python')");
  await evaluate("[...document.querySelectorAll('.code-toolbar button')].find(b=>b.textContent.includes('复制')).click()");
  await waitFor("window.__copied !== null");
  await verify('copy preserves current file exact text', `window.__copied === ${JSON.stringify(raw.toString())}`);
  await evaluate("document.querySelector('.code-toolbar a').click()");
  for(let i=0;i<100&&!existsSync(join(downloads,'main.R'));i++) await sleep(30);
  assert(existsSync(join(downloads,'main.R')),'actual download exists');
  assert.equal(createHash('sha256').update(readFileSync(join(downloads,'main.R'))).digest('hex'),createHash('sha256').update(raw).digest('hex')); checks.push('download exact original bytes/hash');
  await evaluate("[...document.querySelectorAll('.code-file-list button')].find(b=>b.textContent.includes('slow.py')).click()");
  await sleep(35);
  await verify('snippet and file loading explicit without old code', "document.querySelector('.code-current').textContent.includes('代码片段')&&!document.querySelector('.code-text')&&document.querySelector('.code-current').textContent.includes('正在读取文件')");
  await evaluate("[...document.querySelectorAll('.code-file-list button')].find(b=>b.textContent.includes('note.ipynb')).click()");
  await waitFor("document.querySelector('.code-text')?.textContent.includes('<script>')");
  await sleep(250);
  await verify('late file response cannot replace current file', "document.querySelector('.code-current h3').textContent==='note.ipynb'&&!document.querySelector('.code-text').textContent.includes('SLOW_OLD_CONTENT')");
  await verify('HTML and notebook payload remain escaped text', "!window.__executed&&document.querySelector('.code-text').querySelectorAll('script,img').length===0&&document.querySelector('.code-text').textContent.includes('<script>')");
  await evaluate("[...document.querySelectorAll('.code-file-list button')].find(b=>b.textContent.includes('raw.bin')).click()");
  await waitFor("document.querySelector('.code-current')?.textContent.includes('无法作为文本显示')");
  await verify('binary is download-only with copy disabled', "document.querySelector('.code-toolbar button').disabled&&!document.querySelector('.code-text')&&!!document.querySelector('.code-toolbar a[download]')");
  await evaluate("[...document.querySelectorAll('.code-tabs button')].find(b=>b.textContent.includes('复用版')).click()");
  await waitFor("document.querySelector('.code-text')?.textContent.includes('reusable')");
  await verify('reusable reconstruction and verification scope explicit', "document.querySelector('[role=dialog]').textContent.includes('并非原作者完整实现')&&document.querySelector('[role=dialog]').textContent.includes('未运行验证')&&document.querySelector('[role=dialog]').textContent.includes('界面夹具，未运行分析')");
  const desktopShot = await send('Page.captureScreenshot',{format:'png'});
  writeFileSync(join(task,'frontend-code-desktop.png'),Buffer.from(desktopShot.result.data,'base64'));
  await send('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});
  await verify('mobile modal stays within viewport width', "innerWidth<=390&&document.querySelector('.code-dialog').getBoundingClientRect().right<=innerWidth&&document.querySelector('.code-dialog').getBoundingClientRect().left>=0");
  const mobileShot = await send('Page.captureScreenshot',{format:'png'});
  writeFileSync(join(task,'frontend-code-mobile.png'),Buffer.from(mobileShot.result.data,'base64'));
  await send('Emulation.clearDeviceMetricsOverride');
  await evaluate("document.querySelector('.code-dialog button').focus()");
  await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Tab',code:'Tab',modifiers:8});
  await verify('keyboard focus stays in modal', "!!document.activeElement.closest('[role=dialog]')");
  await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Escape',code:'Escape'});
  await verify('Escape closes and restores trigger focus', "!document.querySelector('[role=dialog]')&&document.activeElement.classList.contains('card-code')");
  await evaluate("document.querySelectorAll('.plate-card .card-code')[1].click()");
  await waitFor("document.querySelector('.code-text')?.textContent.includes('R original')");
  await verify('figure card opens its own item dialog', "document.querySelector('.code-dialog h2').textContent.includes('图样卡')");
  await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Escape',code:'Escape'});
  await evaluate("document.querySelector('[data-testid=empty] button').click()");
  await waitFor("document.querySelector('[role=dialog]')?.textContent.includes('此条目尚未保存代码')");
  await verify('no code shown as explicit empty state', "!document.querySelector('.code-text')&&!document.querySelector('.code-toolbar')");
  await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Escape',code:'Escape'});
  await evaluate("document.querySelector('[data-testid=error] button').click()");
  await waitFor("document.querySelector('[role=alert]')?.textContent.includes('fixture expected error')");
  await verify('API error clear without stale code', "document.querySelector('[role=alert]').textContent.includes('加载失败')&&!document.querySelector('.code-text')");
  await send('Input.dispatchKeyEvent',{type:'keyDown',key:'Escape',code:'Escape'});
  await evaluate("document.querySelector('[data-testid=switcher] button').click();document.querySelectorAll('[data-testid=switcher] button')[2].click()");
  await sleep(30);
  // Programmatically change the fixture parent while its slow item request is pending.
  await evaluate("document.querySelectorAll('[data-testid=switcher] button')[1].click()");
  await waitFor("document.querySelector('[role=dialog]')?.textContent.includes('此条目尚未保存代码')");
  await sleep(250);
  await verify('cross-item slow response never leaks content', "document.querySelector('.code-dialog h2').textContent.includes('empty')&&!document.querySelector('.code-text')&&document.querySelector('[role=dialog]').textContent.includes('此条目尚未保存代码')");
  assert.deepEqual(errors,[]);
  const report={passed:true,checks:checks.length,items:checks,consoleExceptions:errors,fixtureUrl:url,temp,scope:'isolated fixture; no production API or code execution'};
  writeFileSync(join(task,'frontend-browser-check.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify(report));
} finally { if(ws)ws.close();if(chrome)chrome.kill();await server.close(); }
