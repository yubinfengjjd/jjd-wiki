// Independent browser harness. Only local readonly review URLs and own Chrome.
import {spawn} from 'node:child_process';
import {mkdtempSync,readFileSync,writeFileSync} from 'node:fs';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
const [url,stepsPath,out]=process.argv.slice(2);
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const profile=mkdtempSync(join(tmpdir(),'rwiki-review-cdp-'));
const chrome=spawn('C:/Program Files/Google/Chrome/Application/chrome.exe',[
  '--headless=new','--use-angle=swiftshader','--enable-unsafe-swiftshader',
  '--remote-debugging-port=0',`--user-data-dir=${profile}`,'--window-size=1440,1000','about:blank'
],{stdio:'ignore'});
const logs=[],results=[];
let ws;
try{
  let port;
  for(let i=0;i<60;i++){try{port=Number(readFileSync(join(profile,'DevToolsActivePort'),'utf8').split('\n')[0]);break;}catch{} await sleep(200);}
  if(!port) throw Error('own Chrome DevTools port unavailable');
  const targets=await(await fetch(`http://127.0.0.1:${port}/json`)).json();
  const target=targets.find(t=>t.type==='page');
  ws=new WebSocket(target.webSocketDebuggerUrl);
  await new Promise(r=>ws.addEventListener('open',r,{once:true}));
  let id=0;const pending=new Map();
  ws.addEventListener('message',e=>{const m=JSON.parse(e.data);if(m.id&&pending.has(m.id)){pending.get(m.id)(m);pending.delete(m.id);}if(['Runtime.exceptionThrown','Log.entryAdded','Network.loadingFailed'].includes(m.method)) logs.push(m);});
  const send=(method,params={})=>new Promise((resolve,reject)=>{const n=++id;const timer=setTimeout(()=>{pending.delete(n);reject(Error('CDP timeout '+method));},15000);pending.set(n,m=>{clearTimeout(timer);m.error?reject(Error(JSON.stringify(m.error))):resolve(m.result);});ws.send(JSON.stringify({id:n,method,params}));});
  await send('Runtime.enable');await send('Log.enable');await send('Network.enable');await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride',{width:1440,height:1000,deviceScaleFactor:1,mobile:false});
  results.push({navigate:await send('Page.navigate',{url})});
  let ready=false;
  for(let i=0;i<120;i++){
    await sleep(500);
    const r=await send('Runtime.evaluate',{expression:'!!document.querySelector("h1")',returnByValue:true});
    if(r.result?.value){ready=true;break;}
  }
  if(!ready){
    const diag=await send('Runtime.evaluate',{expression:'({url:location.href,ready:document.readyState,text:document.body?.innerText.slice(0,2400),resources:performance.getEntriesByType("resource").map(r=>({name:r.name,duration:r.duration})).slice(-20)})',returnByValue:true});
    writeFileSync(join(out,'initial-load-diagnostic.json'),JSON.stringify({diagnostic:diag,logs},null,2));
    const shot=await send('Page.captureScreenshot',{format:'png'});
    writeFileSync(join(out,'initial-load-timeout.png'),Buffer.from(shot.data,'base64'));
    throw Error('initial application h1 not ready within 60 seconds');
  }
  for(const step of JSON.parse(readFileSync(stepsPath,'utf8'))){
    if(step.wait)await sleep(step.wait);
    if(step.waitFor){
      let ok=false;
      for(let i=0;i<80;i++){
        const r=await send('Runtime.evaluate',{expression:step.waitFor,returnByValue:true});
        if(r.result?.value){ok=true;break;}
        await sleep(500);
      }
      if(!ok)throw Error('view condition not ready: '+step.waitFor);
    }
    if(step.eval){const r=await send('Runtime.evaluate',{expression:step.eval,returnByValue:true,awaitPromise:true});results.push({eval:step.eval.slice(0,160),value:r.result?.value,error:r.exceptionDetails});}
    if(step.shot){const r=await send('Page.captureScreenshot',{format:'png'});writeFileSync(join(out,step.shot),Buffer.from(r.data,'base64'));}
  }
  console.log(JSON.stringify({results,logs},null,2));
  writeFileSync(join(out,'cdp-results.json'),JSON.stringify({results,logs},null,2));
  await send('Browser.close').catch(()=>{});
}finally{if(ws)ws.close();if(chrome.exitCode===null)chrome.kill();}
