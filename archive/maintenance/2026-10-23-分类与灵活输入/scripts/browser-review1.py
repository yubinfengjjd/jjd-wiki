"""Drive a real headless Chrome over CDP against a temporary review server (not 8765)."""
import base64
import json
import subprocess
import sys
import time
from pathlib import Path

import requests
import websocket

CHROME = Path(r'C:/Program Files/Google/Chrome/Application/chrome.exe')
PORT = 8788
CDP = 9223
BASE = f'http://127.0.0.1:{PORT}'
RECORD = Path(r'E:/research-wiki/维护记录/2026-10-23-分类与灵活输入')
PROFILE = Path(r'E:/research-wiki-env/tmp/chrome-review1')
OUT = RECORD / 'browser-review1.json'


class CDPClient:
    def __init__(self, url):
        self.ws = websocket.create_connection(url, timeout=20)
        self.next_id = 0
        self.events = []

    def send(self, method, params=None):
        self.next_id += 1
        self.ws.send(json.dumps({'id': self.next_id, 'method': method, 'params': params or {}}))
        while True:
            message = json.loads(self.ws.recv())
            if message.get('id') == self.next_id:
                return message
            self.events.append(message)

    def eval(self, expression):
        result = self.send('Runtime.evaluate', {
            'expression': expression, 'returnByValue': True, 'awaitPromise': True})
        value = result.get('result', {}).get('result', {})
        if value.get('subtype') == 'error':
            raise RuntimeError(value.get('description'))
        return value.get('value')

    def wait(self, expression, timeout=20):
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                if self.eval(expression):
                    return True
            except Exception:
                pass
            time.sleep(0.25)
        raise TimeoutError(expression)


def start_server(config):
    log = open(RECORD / 'logs' / 'browser-server-review1.log', 'w', encoding='utf-8')
    process = subprocess.Popen(
        [r'C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe', '-X', 'utf8',
         r'E:/research-wiki/开发/staged/research-wiki/wiki.py', '--config', str(config),
         'serve', '--no-browser'], stdout=log, stderr=log)
    for _ in range(80):
        try:
            if requests.get(BASE + '/api/method-taxonomy', timeout=1).status_code == 200:
                return process
        except requests.RequestException:
            pass
        time.sleep(0.25)
    raise RuntimeError('review server did not start')


def start_chrome():
    if PROFILE.exists():
        import shutil
        shutil.rmtree(PROFILE)
    PROFILE.mkdir(parents=True)
    process = subprocess.Popen([
        str(CHROME), '--headless=new', '--disable-gpu', '--no-sandbox', '--no-proxy-server',
        '--no-first-run', '--no-default-browser-check', '--remote-allow-origins=*',
        f'--remote-debugging-port={CDP}', f'--user-data-dir={PROFILE}', 'about:blank'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for _ in range(80):
        try:
            response = requests.get(f'http://127.0.0.1:{CDP}/json/list', timeout=1)
            if response.status_code == 200:
                return process, response.json()
        except requests.RequestException:
            pass
        time.sleep(0.25)
    raise RuntimeError('chrome did not start')


def main():
    config = Path(r'E:/research-wiki-env/tmp/review-server-config.json')
    staged = Path(r'E:/research-wiki/开发/staged/research-wiki/config.json')
    data = json.loads(staged.read_text(encoding='utf-8'))
    data['port'] = PORT
    config.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

    server = start_server(config)
    chrome = None
    results = {'server': BASE, 'checks': [], 'console_errors': []}
    try:
        chrome, targets = start_chrome()
        page = next(item for item in targets if item['type'] == 'page')
        client = CDPClient(page['webSocketDebuggerUrl'])
        client.send('Page.enable')
        client.send('Runtime.enable')
        client.send('Page.addScriptToEvaluateOnNewDocument', {
            'source': "window.__rwikiErrors=[];"
                      "addEventListener('error',e=>__rwikiErrors.push(String(e.error||e.message)));"
                      "addEventListener('unhandledrejection',e=>__rwikiErrors.push(String(e.reason)));"
        })
        client.send('Page.navigate', {'url': BASE + '/#/methods'})
        client.wait("document.readyState==='complete'")
        client.wait("document.querySelectorAll('.plate-card').length > 0", timeout=60)
        results['checks'].append({'name': 'initial load', 'cards': client.eval("document.querySelectorAll('.plate-card').length"),
                                  'hash': client.eval('location.hash')})

        # Click a domain link, then a purpose link.
        client.eval("Array.from(document.querySelectorAll('.taxonomy-domains a')).find(a=>a.textContent.includes('单细胞分析')).click()")
        client.wait("location.hash.includes('domain=')")
        client.wait("document.querySelectorAll('.taxonomy-purposes a').length > 1")
        results['checks'].append({'name': 'click domain', 'hash': client.eval('location.hash'),
                                  'cards': client.eval("document.querySelectorAll('.plate-card').length")})
        client.eval("Array.from(document.querySelectorAll('.taxonomy-purposes a')).find(a=>a.textContent.includes('轨迹与动态分析')).click()")
        client.wait("location.hash.includes('purpose=')")
        client.wait("document.querySelectorAll('.plate-card').length === 3")
        results['checks'].append({'name': 'click purpose', 'hash': client.eval('location.hash'),
                                  'cards': client.eval("document.querySelectorAll('.plate-card').length"),
                                  'titles': client.eval("Array.from(document.querySelectorAll('.plate-card h3')).map(h=>h.textContent.trim())")})

        # Search by purpose from the full directory, then clear the URL-backed input.
        client.eval("Array.from(document.querySelectorAll('.taxonomy-domains a')).find(a=>a.textContent.includes('全部')).click()")
        client.wait("location.hash === '#/methods'")
        client.wait("document.querySelectorAll('.plate-card').length === 15")
        client.eval("""(() => {
          const input=document.querySelector('.method-search input');
          const setter=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set;
          setter.call(input,'模型解释');
          input.dispatchEvent(new Event('input',{bubbles:true}));
          document.querySelector('.method-search button').click();
        })()""")
        client.wait("location.hash.includes('q=')")
        client.wait("document.querySelectorAll('.plate-card').length === 1")
        results['checks'].append({'name': 'search purpose', 'hash': client.eval('location.hash'),
                                  'cards': client.eval("document.querySelectorAll('.plate-card').length"),
                                  'input': client.eval("document.querySelector('.method-search input').value"),
                                  'titles': client.eval("Array.from(document.querySelectorAll('.plate-card h3')).map(h=>h.textContent.trim())")})
        client.eval("Array.from(document.querySelectorAll('.method-search a')).find(a=>a.textContent.includes('清除')).click()")
        client.wait("!location.hash.includes('q=')")
        client.wait("document.querySelector('.method-search input').value === ''")
        results['checks'].append({'name': 'clear search', 'hash': client.eval('location.hash'),
                                  'input': client.eval("document.querySelector('.method-search input').value")})

        # Refresh with the domain/purpose URL and check persistence.
        client.send('Page.navigate', {'url': BASE + '/#/methods?domain=%E5%8D%95%E7%BB%86%E8%83%9E%E5%88%86%E6%9E%90&purpose=%E8%BD%A8%E8%BF%B9%E4%B8%8E%E5%8A%A8%E6%80%81%E5%88%86%E6%9E%90'})
        client.wait("document.readyState==='complete'")
        client.wait("document.querySelectorAll('.plate-card').length === 3")
        client.eval('location.reload()')
        client.wait("document.readyState==='complete'")
        client.wait("document.querySelectorAll('.plate-card').length === 3")
        results['checks'].append({'name': 'refresh keeps selection', 'hash': client.eval('location.hash'),
                                  'cards': client.eval("document.querySelectorAll('.plate-card').length"),
                                  'input': client.eval("document.querySelector('.method-search input').value")})

        # Click a method card: page routing must not fall back to the gallery.
        card_href = client.eval("document.querySelector('.plate-card a.face.front').getAttribute('href')")
        client.eval("document.querySelector('.plate-card a.face.front').click()")
        client.wait(f"location.hash === {json.dumps(card_href)}")
        client.wait("document.querySelector('h1') && document.body.innerText.includes('具体实现与验证范围')")
        results['checks'].append({'name': 'click method card', 'hash': client.eval('location.hash'),
                                  'title': client.eval("document.querySelector('h1')?.textContent")})

        results['console_errors'] = client.eval('window.__rwikiErrors')
        screenshot = client.send('Page.captureScreenshot', {'format': 'png'})
        (RECORD / 'browser-review1.png').write_bytes(base64.b64decode(screenshot['result']['data']))
        client.ws.close()
    finally:
        if chrome is not None:
            chrome.terminate()
            try:
                chrome.wait(timeout=10)
            except subprocess.TimeoutExpired:
                chrome.kill()
        server.terminate()
        try:
            server.wait(timeout=10)
        except subprocess.TimeoutExpired:
            server.kill()
    OUT.write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
