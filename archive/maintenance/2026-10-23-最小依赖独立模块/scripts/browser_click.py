import json
import os
import subprocess
import time
import urllib.request

from websocket import create_connection

record = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
chrome = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
profile = os.path.join(record, 'browser', 'cdp-profile2')
proc = subprocess.Popen([chrome, '--headless=new', '--disable-gpu', '--no-sandbox',
                         '--remote-debugging-port=9224', '--user-data-dir=' + profile,
                         'about:blank'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
try:
    targets = None
    for _ in range(60):
        try:
            targets = json.load(urllib.request.urlopen('http://127.0.0.1:9224/json'))
            break
        except Exception:
            time.sleep(0.2)
    page = next(t for t in targets if t['type'] == 'page')
    ws = create_connection(page['webSocketDebuggerUrl'], timeout=60)
    seq = [0]

    def call(method, **params):
        seq[0] += 1
        ws.send(json.dumps({'id': seq[0], 'method': method, 'params': params}))
        while True:
            msg = json.loads(ws.recv())
            if msg.get('id') == seq[0]:
                return msg

    def ev(expr):
        result = call('Runtime.evaluate', expression=expr, returnByValue=True)
        return result['result']['result'].get('value')

    call('Page.enable')
    call('Runtime.enable')
    call('Page.navigate', url='http://127.0.0.1:8787/#/methods')
    evidence = {}
    for _ in range(40):
        time.sleep(1)
        count = ev("document.querySelectorAll('a[href^=\"#/page/methods/\"]').length")
        if count and count > 0:
            break
    evidence['hash_before'] = ev('location.hash')
    evidence['cards_before'] = ev("document.querySelectorAll('a[href^=\"#/page/methods/\"]').length")
    evidence['clicked'] = ev("(() => { const a = [...document.querySelectorAll('a')].find(x => x.textContent.includes('拟时序与轨迹推断')); if (!a) return false; a.click(); return true; })()")
    time.sleep(5)
    evidence['hash_after'] = ev('location.hash')
    evidence['body_has_runtime'] = ev("document.body.innerText.includes('独立模块')")
    evidence['required_occurrences'] = ev("(document.body.innerText.match(/必要依赖/g)||[]).length")
    evidence['monocle_rows'] = ev("[...document.querySelectorAll('tr')].filter(r => r.innerText.includes('Monocle2 分析核心') || r.innerText.includes('Monocle2 Seurat')).length")
    evidence['code_button'] = ev("(() => { const b = [...document.querySelectorAll('button')].find(x => x.textContent.includes('查看代码')); if (!b) return false; b.click(); return true; })()")
    time.sleep(4)
    evidence['dialog_open'] = ev("!!document.querySelector('.code-dialog')")
    evidence['active_tab'] = ev("(() => { const t = document.querySelector('.code-tabs [aria-selected=\"true\"], .code-tabs .active'); return t ? t.textContent.trim() : null; })()")
    evidence['dialog_has_entry'] = ev("!!document.querySelector('.code-dialog') && /monocle2_core\\.R|monocle2\\.R|analysis\\.R/.test(document.querySelector('.code-dialog').innerText)")
    evidence['dialog_text_head'] = ev("document.querySelector('.code-dialog') ? document.querySelector('.code-dialog').innerText.slice(0, 400) : null")
    print(json.dumps(evidence, ensure_ascii=False, indent=2))
    with open(os.path.join(record, 'browser', 'browser-click-round1-fix.json'), 'w', encoding='utf-8') as stream:
        json.dump(evidence, stream, ensure_ascii=False, indent=2)
finally:
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except Exception:
        proc.kill()
