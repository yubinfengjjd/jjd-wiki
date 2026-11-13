from pathlib import Path
import hashlib,json,subprocess,sys
from PIL import Image,ImageChops
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP续整理')
B=Path('E:/research-wiki-env/work/scp-ingestion-20261025')
C=B/'candidates/group-heatmap-dot'
R=A/'codex-native-reference'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
results={}
for variant,name in [('fixed-1m','native-dot'),('fixed-1m-reticle','native-dot-reticle'),('fixed-2m','native-dot-2m')]:
    extensions=['png'] if variant.endswith('reticle') else ['png','svg']
    for ext in extensions:
        ref=R/f'{name}.{ext}';candidate=C/'verify'/variant/f'figure.{ext}'
        results[f'{variant}_{ext}']={'reference':sha(ref),'candidate':sha(candidate),'equal':sha(ref)==sha(candidate)}
    if variant.endswith('reticle'):continue
    for label,pdf in [('native',R/f'{name}.pdf'),('candidate',C/'verify'/variant/'figure.pdf')]:
        dest=A/'pdf-raster'/f'{variant}-{label}'
        dest.parent.mkdir(parents=True,exist_ok=True)
        subprocess.run(['pdftoppm','-f','1','-singlefile','-scale-to','1200','-png',str(pdf),str(dest)],check=True,capture_output=True)
    im1=Image.open(A/'pdf-raster'/f'{variant}-native.png').convert('RGB')
    im2=Image.open(A/'pdf-raster'/f'{variant}-candidate.png').convert('RGB')
    results[f'{variant}_pdf_pixels']={'size1':im1.size,'size2':im2.size,'equal':im1.size==im2.size and ImageChops.difference(im1,im2).getbbox() is None}
orig=B/'gallery/2026-10-22-scp-example/figures/fig17-group-heatmap-dot/original_code/groupheatmap.R'
src=Path('E:/research-wiki-env/sources/scp-2026-10-22/R/SCP-plot.R')
excerpt=b''.join(src.read_bytes().splitlines(keepends=True)[7910:9036])
body=orig.read_bytes();body=body[body.index(b'GroupHeatmap <-'):]
results['original_excerpt']={'source_file_sha256':sha(src),'excerpt_bytes_identical':body==excerpt,'text_identical':body.decode('utf-8').replace('\r\n','\n').strip()==excerpt.decode('utf-8').replace('\r\n','\n').strip()}
(A/'codex-artifacts.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(results,ensure_ascii=False))
