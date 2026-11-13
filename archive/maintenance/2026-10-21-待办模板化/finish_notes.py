from pathlib import Path
import copy,json,shutil,yaml,hashlib,difflib

TASK=Path(__file__).resolve().parent;ROOT=Path(r'E:\research-wiki\知识库')
P='2026-10-19-regression-stability__'
def read(path):
    text=path.read_bytes().decode('utf-8');header,body=text[4:].split('\n---\n',1)
    return yaml.safe_load(header),body
def block(body,name):return body.split(f'<!-- {name}:start -->',1)[1].split(f'<!-- {name}:end -->',1)[0]
def write(path,meta,body):
    old,oldbody=read(path)
    for key in ['status','archived_from','favorite']:assert old.get(key)==meta.get(key)
    assert block(body,'user')==block(oldbody,'user')
    path.write_text('---\n'+yaml.safe_dump(meta,sort_keys=False,allow_unicode=True)+'---\n'+body,encoding='utf-8',newline='\n')

for fig,chart,kind,title in [('fig03-density-panel','density-scatter','density','密度散点与边缘分布（单 panel）'),
                             ('fig04-boxplot-panel','boxplot','boxplot','箱线、散点与均值（单 panel）')]:
    tid=P+fig+'--'+chart;page=ROOT/'templates'/f'{tid}.md';target=page.with_suffix('')
    meta,old=read(page);meta['title']=title
    spec=json.loads((target/'spec.json').read_text(encoding='utf-8'))
    shutil.copy2(TASK/'function-verification.json',target/'verify/function-verification.json')
    manifest=json.loads((target/'code-manifest.json').read_text(encoding='utf-8'))
    for item in manifest['files']:
        item['verification']={'state':'not_run' if item['variant']=='original' else 'example',
                              'scope':'只读保留的旧重建源码，非原作者完整代码。' if item['variant']=='original' else
                              '估读/合成展示示例回放及15项绘图复用检查；未进行真实课题分析流水线验证。',
                              'evidence':[] if item['variant']=='original' else [f'templates/{tid}/verify/verify.json',f'templates/{tid}/verify/function-verification.json']}
        item['sha256']=hashlib.sha256((target/item['path']).read_bytes()).hexdigest()
    (target/'code-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    oldcode=(target/'source/panels.py').read_text(encoding='utf-8');newcode=(target/'code/core.py').read_text(encoding='utf-8')
    (target/'source/rendering-changes.diff').write_text(''.join(difflib.unified_diff(oldcode.splitlines(True),newcode.splitlines(True),fromfile='source/panels.py',tofile='code/core.py')),encoding='utf-8')
    data='points=render-scatter-rgb.csv；histograms=render-marginal-bars.csv' if kind=='density' else 'points=render-category-points.csv；summaries=render-box-summaries.csv'
    purpose=('配对坐标的散点与两侧预计算边缘分布，色标可显式启用。一个逻辑 panel，可有主轴、两边缘轴与色标轴。'
             if kind=='density' else '单指标分组分布：外部提供的点、箱体、须和均值。组数从真实输入识别，模型名称/组数/标签不是函数限制。')
    boundaries=('输入已有坐标、RGB和边缘条；不拟合、不算KDE/直方图、不从RGB倒推频数。1:1线要求两轴同定义同量纲。需要色标时显式传 show_colorbar=True、color_range、color_label，确保上游颜色策略一致；默认不假定颜色是频数。'
                if kind=='density' else '点与摘要须来自同一真实分析；图不计算分位数/均值/须或生成抖动。jitter显式提供且绝对值小于0.5；逐类摘要须满足 low≤q1≤median≤q3≤high。点可在须外，图不另重复画fliers。')
    sizing=('散点不随点数无限增长。默认7×6.2215英寸，预留上下刻度边距；很长的轴标题等可能需显式增加尺寸/边距，固定比例越界会报错。图形回放 example/style.json 使用原比例、原刻度与原标注。'
            if kind=='density' else '默认 W=左右留白+n×每组最小0.8英寸，长标签还可增宽并增加底边距；n为实际任意合法类别数，无白名单。默认无宽度上限、不分面、不缩字；自定义色表不足报错，默认超出来源色数时按n生成颜色而不循环。可覆盖 sizing.item_width_in、plot_height_in、width_in、max_width_in 等。')
    limitations=('示例点/RGB/边缘条均为旧估读；拟合线、指标、Test(XGBoost)只在 example/style.json 中，未由点重新计算。右边缘保留旧0..40，原单图为0..20，沿用前次已说明的差异。默认复用不带这些旧标注。'
                 if kind=='density' else '示例点值、箱体与均值是独立估读，横向抖动为固定合成展示位置；它们不能作为一致的原始验证数据进行统计推断。换数据时由课题分析先准备同源点与摘要。')
    pkg='density_panel' if kind=='density' else 'box_panel'
    inputs='\n'.join(f'- `{name}` → [[interfaces/{value["interface"]}]]：{value["description"]}。' for name,value in spec['tables'].items())
    body=f'''# {title}

![[templates/{tid}/preview.png]]

<!-- facts:start -->{block(old,'facts')}<!-- facts:end -->

## 适用

{purpose}

{boundaries}

## 不适用

不将估读示例作为原始观测、真实样本量或模型有效性证据。缺关键数据、统计含义或上游算法时先说明并询问，不能以整理绘图接口为由补算法。

## 数据要求

{inputs}

接口CSV只用于绘图层；课题保留样本身份、配对/重复层级和量纲说明。可接受带其他追溯列的表。`style.columns` 为语义列名→实际列名映射，调用前核对含义，原表不改。

## 代码与独立调用

`source/panels.py` 原字节保留旧重建代码；不是原作者缺失函数。`code/core.py` 为绘图改造版，`code/panel.py` 保留 draw(fig,rect,tables,style) 并提供 plot_panel(tables,style=None)，两者共享同一核心。代码卡片区分原版/复用版和实际验证范围。

将整个 code/ 复制为课题包 `{pkg}/`，使用课题自己的 numpy/pandas/matplotlib 环境；不要在 Wiki 安装包。函数无隐式读写、训练、联网、安装或随机生成。返回 figure、handles、sizing_plan；导出由调用层完成。示例文件对应：{data}。

```python
from {pkg}.panel import plot_panel
# tables为已准备的DataFrame字典；列映射、顺序、颜色和尺寸在style中显式传入。
fig, handles, plan = plot_panel(tables, style)
fig.savefig('result.png', dpi=300)
```

## 尺寸与换数据

{sizing}

组合调用不会调整外层figure；空间不足明确报错，交调用方扩大。独立函数与render默认值快照一致，复制后无需Wiki/spec路径。`example/style.json` 专用于来源回放，不随意套到新数据。

## 回放、来源与限制

{limitations}

verify-template 已回放PNG/PDF/SVG，15项绘图/可移植性检查通过：来源维度及数值图元与旧renderer在绝对容差1e-12内一致；任意n的代表规模/长标签/列映射/顺序/配色/上限/不同cwd调用已检查。仅为绘图软件验证，未验证真实课题统计有效性。详情见 verify/function-verification.json。PNG已目视，PDF/SVG为结构检查，独立查看器视觉未测。

当前为draft，等待作者确认本轮模板回放；不因测试通过自动ready。来源签核继续保留。确认后可独立render，不以来源layout整体ready为前置。

## 知识关联检查

检查现存回归评估/SHAP家族、两个来源及既有SHAP三模板。与 [[methods/regression-resampling-evaluation]] 有条件关联，但该方法的预测/逐折指标需另外整理成预计算绘图表；适配不是新增训练/密度/统计算法授权。关系在方法侧唯一记录，验证范围与模板状态分开。

SHAP图表达特征归因，输入语义不同，未找到当前模板直接读取其表的依据；不为连通图谱硬连。参考来源 [[layouts/{P+fig}]] 与本模板是单panel来源/复用阶段，未收录整图、未创建宽泛迁移方法。

## 使用记录

2026-10-21：按“处理待办”完成所选单panel模板化、原字节存档、回放与复用检查，待作者确认。

<!-- user:start -->{block(old,'user')}<!-- user:end -->
'''
    write(page,meta,body)
    (target/'README.md').write_text(f'# {title}\n\n复制code/为{pkg}后调用plot_panel(tables,style)，或用原render入口读取spec约定CSV。无训练/统计计算。\n\n数据：{data}\n\n{boundaries}\n\n{sizing}\n\n{limitations}\n\n状态draft，模板回放待作者确认。详见同名Wiki页面与verify/目录。\n',encoding='utf-8')

method=ROOT/'methods/regression-resampling-evaluation.md';meta,body=read(method)
relations=meta.get('figure_relations',[])
for r in list(relations):
    if not r['figure'].startswith('layouts/'+P):continue
    chart='density-scatter' if 'density-panel' in r['figure'] else 'boxplot'
    target='templates/'+r['figure'].split('/',1)[1]+'--'+chart
    if any(x['figure']==target for x in relations):continue
    new=copy.deepcopy(r);new['figure']=target
    new['reason']=('可用本绘图模板表达真实预测的配对分布，但需上游明确准备RGB/边缘表。' if chart=='density-scatter' else
                   '逐折指标可用于该单指标分组分布，需上游按已确认规则准备同源点与箱线摘要。')
    new['adaptation']=('课题内准备坐标/RGB/边缘条及真实注释；不从估读点重建频数，密度算法仍需确认。' if chart=='density-scatter' else
                       '课题内选定指标、明确采样单位/须规则、整理同源points/summaries；不自动新写统计算法。')
    new['verification']={'state':'not_run','scope':'本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。','evidence':[]}
    new['evidence'] += [target+'/spec.json',target+'/verify/function-verification.json']
    relations.append(new)
meta['figure_relations']=relations
body=body.replace('没有 ready 密度/箱线模板；原暂停草稿已由作者在前端删除，本轮不恢复或重建。',
                  '2026-10-21 作者再次要求处理待办后，新建了密度与箱线单panel模板并完成回放，目前draft待确认；不恢复旧草稿字节，也不自动ready。')
body=body.replace('尚未拆出ready图模板。','本轮模板回放已完成，draft等待作者确认。')
insert='\n2026-10-21 待办处理：新增上述两个单panel函数模板，分别记录需要适配的关系；保留来源参考关联。绘图通过不等于上游方法流水线已验证；SHAP分支与归档迁移笔记不变。\n\n'
body=body.replace('<!-- user:start -->',insert+'<!-- user:start -->')
write(method,meta,body)

for fig in ['fig03-density-panel','fig04-boxplot-panel']:
    path=ROOT/'layouts'/f'{P+fig}.md';meta,body=read(path)
    body=body.replace('正式wiki render尚未进行。','本轮verify-template/render入口回放已完成，模板待作者确认。')
    body=body.replace('正式wiki render尚未验收，','本轮verify-template已完成，')
    body=body.replace('当前没有ready箱线模板，不把来源图样标成可调用模板。','本轮已建箱线单panel模板并回放，draft待确认；来源与模板阶段仍分别记录。')
    chart='density-scatter' if 'density' in fig else 'boxplot';tid=P+fig+'--'+chart
    body=body.replace('<!-- user:start -->',f'\n本轮待办：[[templates/{tid}]] 已完成绘图代码、接口、回放及复用检查，draft待作者确认。来源状态保留pending_template；无整图交付。\n\n<!-- user:start -->')
    write(path,meta,body)
print('Updated two template notes/manifests, four render interfaces, source notes and explicit method relations; statuses preserved.')
