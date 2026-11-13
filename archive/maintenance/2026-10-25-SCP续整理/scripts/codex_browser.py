"""Read-only API plus actual Chrome click verification; never signs anything."""
from pathlib import Path
import argparse,base64,importlib.util,json,subprocess,time,urllib.parse
import requests
P=argparse.ArgumentParser();P.add_argument('--base',default='http://127.0.0.1:8765');P.add_argument('--label',default='formal');args=P.parse_args()
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP续整理')
spec=importlib.util.spec_from_file_location('prior_cdp',Path('E:/research-wiki/维护记录/2026-10-23-分类与灵活输入/scripts/browser-review1.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
eid='2026-10-22-scp-example__fig17-group-heatmap-dot'
page=requests.get(args.base+'/api/page',params={'path':f'layouts/{eid}.md'},timeout=30);page.raise_for_status();page=page.json()
assert page['meta']['status']=='pending_signoff',page['meta']
assert page['gallery']['status']=='draft',page['gallery']
files=requests.get(args.base+f'/api/layouts/{eid}/code-files',timeout=30);files.raise_for_status();files=files.json()['files']
assert any(f['variant']=='original' and f['path'].endswith('groupheatmap.R') for f in files)
assert any(f['variant']=='reusable' and f['path'].endswith('core.R') for f in files)
for variant in ('original','reusable'):
    f=next(f for f in files if f['variant']==variant and f['text'])
    r=requests.get(args.base+f'/api/layouts/{eid}/code',params={'variant':variant,'path':f['path']},timeout=30);r.raise_for_status();assert r.json()['text']
preview=requests.get(args.base+page['preview']['url'],timeout=30);preview.raise_for_status()
profile=Path('E:/research-wiki-env/tmp')/f'scp-review-{args.label}-{int(time.time())}'
chrome=subprocess.Popen([r'C:/Program Files/Google/Chrome/Application/chrome.exe','--headless=new','--disable-gpu','--no-first-run','--no-default-browser-check','--no-proxy-server','--remote-allow-origins=*','--remote-debugging-port=9239',f'--user-data-dir={profile}','about:blank'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
client=None
try:
    for _ in range(80):
        try:
            tabs=requests.get('http://127.0.0.1:9239/json/list',timeout=1).json()
            if tabs:break
        except requests.RequestException:pass
        time.sleep(.25)
    client=module.CDPClient(next(t['webSocketDebuggerUrl'] for t in tabs if t['type']=='page'))
    client.send('Page.enable');client.send('Runtime.enable')
    client.send('Emulation.setDeviceMetricsOverride',{'width':1440,'height':1100,'deviceScaleFactor':1,'mobile':False})
    client.send('Page.navigate',{'url':args.base+f'/#/page/layouts/{eid}.md'})
    client.wait("document.querySelector('h1')?.textContent.includes('分组表达点阵热图')")
    client.wait("[...document.images].some(i=>i.complete && i.naturalWidth>0)")
    title=client.eval("document.querySelector('h1').textContent")
    client.eval("[...document.querySelectorAll('button')].find(b=>b.textContent.trim()==='查看代码').click()")
    client.wait("document.querySelector('[role=dialog] pre')?.textContent.length>30")
    reusable=client.eval("document.querySelector('[role=dialog] pre').textContent.slice(0,150)")
    client.eval("[...document.querySelectorAll('[role=tab]')].find(b=>b.textContent.includes('原始')).click()")
    client.wait("document.querySelector('[role=dialog] [role=tabpanel] button')!=null")
    client.eval("[...document.querySelectorAll('[role=dialog] [role=tabpanel] button')].find(b=>b.textContent.includes('groupheatmap.R')).click()")
    client.wait("document.querySelector('[role=dialog] pre')?.textContent.includes('GroupHeatmap <- function')")
    shot=client.send('Page.captureScreenshot',{'format':'png','captureBeyondViewport':False})
    (A/f'browser-{args.label}.png').write_bytes(base64.b64decode(shot['result']['data']))
    result={'title':title,'base':args.base,'layout_status':page['meta']['status'],'gallery_status':page['gallery']['status'],'preview':page['preview'],'code_files':len(files),'real_click_reusable_preview':reusable,'real_click_original':True,'author_actions_performed':False}
    (A/f'browser-{args.label}.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False))
finally:
    if client:client.ws.close()
    chrome.terminate()
