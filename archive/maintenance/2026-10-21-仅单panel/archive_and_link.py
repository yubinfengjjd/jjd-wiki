from pathlib import Path
import json,re,urllib.request,hashlib,shutil

root=Path('E:/research-wiki')
out=root/'维护记录/2026-10-21-仅单panel'
groups=['2026-08-17-shap-feature-mechanism__fig01-shap-a-f',
        '2026-10-19-regression-stability__fig01-density-grid',
        '2026-10-19-regression-stability__fig02-metric-boxplots']
prefix='2026-10-19-regression-stability__'
density=prefix+'fig03-density-panel'
box=prefix+'fig04-boxplot-panel'
results={}
for gid in groups:
    url='http://127.0.0.1:8765/api/layouts/'+gid+'/archive'
    # Archive only through the supported API; never edit status/frontmatter directly.
    with urllib.request.urlopen(urllib.request.Request(url,method='POST'),timeout=30) as r:
        results[gid]=json.load(r)['meta']['status']

mapping={groups[1]:(density,'密度散点与边缘分布'),groups[2]:(box,'箱线散点与均值')}
for p in (root/'知识库').rglob('*.md'):
    if p.stem in groups or p.name in ['index.md','log.md','AGENTS.md']:continue
    s=p.read_text(encoding='utf-8')
    original=s
    # Only agent-authored prose; generated facts and author blocks stay byte-for-byte.
    parts=re.split(r'(<!-- (?:facts|user):start -->.*?<!-- (?:facts|user):end -->)',s,flags=re.S)
    for i in range(0,len(parts),2):
        for old,(new,label) in mapping.items():
            parts[i]=re.sub(r'\[\[layouts/'+re.escape(old)+r'(?:\|[^\]]*)?\]\]',
                            '[[layouts/'+new+'|'+label+']]',parts[i])
        if p.stem==density:
            parts[i]=re.sub(r'；同帖 .*?是这种结构的重复模型组图来源范围，不要求先制作整组。',
                           '；历史重复模型整图已归档，仅保留在画廊作溯源。',parts[i])
        if p.stem==box:
            parts[i]=re.sub(r'；同帖 .*?为重复指标组图，模型/指标变化可由函数参数表达。',
                           '；历史重复指标整图已归档，模型/指标变化由单 panel 函数参数表达。',parts[i])
        if p.stem=='shap-explanation':
            parts[i]=parts[i].replace('本库的 SHAP 组图（[[layouts/'+groups[0]+']]）',
                '已归档的 SHAP 原图（仅作溯源）；可复用图样见 '
                '[[templates/'+groups[0]+'--bar|SHAP条形图]]、'
                '[[templates/'+groups[0]+'--beeswarm|SHAP蜂群图]]、'
                '[[templates/'+groups[0]+'--radial-bar|SHAP环形图]]')
    s=''.join(parts)
    if s!=original:
        backup=out/'修改前Wiki正文'/p.relative_to(root/'知识库')
        backup.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(p,backup)
        p.write_text(s,encoding='utf-8')
(out/'archive-result.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(results,ensure_ascii=False))
