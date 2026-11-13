"""Approved content migration; test with an isolated Wiki copy before --wiki formal root."""
import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, r'E:\research-wiki\开发\staged\research-wiki')
from dataclasses import replace
from fastapi.testclient import TestClient
from rwiki.config import load_config
from rwiki.pages import read_page, write_page, get_block, set_block
from rwiki.server import create_app
from rwiki.store import save

args = argparse.ArgumentParser()
args.add_argument('--wiki', required=True, type=Path)
a = args.parse_args()
config = replace(load_config(Path(r'E:\research-wiki\开发\staged\research-wiki\config.json')), wiki_root=a.wiki.resolve())
root = config.wiki_root
old_notes = ['paired-reference-visual-comparison', 'repeated-benchmark-distribution']
before = {p: get_block(read_page(p)[1], 'user') for kind in ['methods', 'layouts', 'templates'] for p in (root/kind).glob('*.md')}

def protected_write(path, meta, body):
    # Restore the author block BEFORE any write/automatic save; transformations
    # only own agent text. read_page preserves original newlines as well as text.
    current = get_block(read_page(path)[1], 'user')
    assert current == before[path], 'Author content changed during migration: ' + str(path)
    body = set_block(body, 'user', current)
    assert get_block(body, 'user') == current
    write_page(path, meta, body)
    assert get_block(read_page(path)[1], 'user') == current

def relation(figure, compatibility, reason, prerequisites, adaptation, evidence):
    return dict(figure=figure, compatibility=compatibility, reason=reason, prerequisites=prerequisites,
                adaptation=adaptation, evidence=evidence,
                verification={'state': 'not_run', 'scope': '本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。', 'evidence': []})

shap_id = '2026-08-17-shap-feature-mechanism__fig01-shap-a-f'
p = root/'methods/shap-explanation.md'
meta, old = read_page(p)
meta['tags'] = ['模型解释', 'SHAP', '方法家族']
meta['cite'] = list(dict.fromkeys(meta['cite'] + [
    'SHAP TreeExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.TreeExplainer.html',
    'SHAP LinearExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.LinearExplainer.html',
    'SHAP Explainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.Explainer.html']))
meta['figure_relations'] = []
for chart in ['bar', 'beeswarm', 'radial-bar']:
    summary = chart != 'beeswarm'
    meta['figure_relations'].append(relation('templates/'+shap_id+'--'+chart, 'direct',
        '特征级平均绝对 SHAP 及其占比对应汇总图契约。' if summary else '逐样本×特征的带符号 SHAP 和着色特征值对应蜂群图契约。',
        ['同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。',
         '使用真实 SHAP 表；示例估读/合成数据仅作画法参考。',
         '模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。'],
        '', [f'methods/shap-explanation.md#输出', f'templates/{shap_id}--{chart}/spec.json',
             'interfaces/shap-summary.md' if summary else 'interfaces/shap-samples.md']))
body = '''# 机器学习模型 + SHAP 解释

<!-- facts:start -->
<!-- facts:end -->

## 用途

对既定模型输出作特征归因，分别保存逐样本带符号贡献和特征级平均绝对贡献。此页是有条件的方法家族说明；家族范围、代码分支、实际验证三个维度分开。解释训练模型的行为，不提供因果或临床效用结论。

## 原始实现与家族范围

来源是公众号的 XGBoost＋SHAP 示例，原生片段在 source/，manifest 记录字节哈希和 example_not_target：它不是原帖目标整图的完整可运行实现。复用版 code/shap_explain.py 是后来整理的独立脚本，不是原作者原件。

可推广的核心是“明确模型输出→选择适用解释器/背景→计算归因→整理结果”，而非承诺所有模型都支持同一入口：

- 树分支：官方 TreeExplainer 支持列出的模型家族，输出模式与特征依赖假设有条件。具体版本/模型/输出单位需核对，不能一律称概率贡献。
- 线性分支：LinearExplainer 可解释线性模型，背景与特征相关性处理影响归因；贡献通常不等于裸系数。
- 其他预测函数：Explainer 依据模型、masker 和算法选择估计器；计算成本与解释含义须核对。存在通用入口不证明本库存实现对所有任务适用。

依据为本页 cite 中三份 SHAP 官方文档（2026-10-21 复核）。原始具体实现保留，其他分支先按条件讨论；未实现/未验证的任务不补算法。

## 适用

已明确研究任务、训练好的模型、特征处理、背景/解释样本及模型输出。现存复用脚本面向数值表格的回归或二分类示例；真实课题先审查训练/验证边界、类别编码、缺失值与重复测量。标签名或模型名不能代替这些前提。

## 不适用

不能直接据此处理多分类、多输出、时序/分组划分或任意原生类别特征；需要另核接口和实现。特征归因不等于因果、预测校准、外部验证或模型临床有效性。相关特征与背景选择必须说明，不能仅看排名定机制。

## 输入

家族需要既定模型、训练时对应的特征处理、解释样本和背景定义。现存脚本读取 data.csv（一行一个样本，数值特征及目标列），DATA/TARGET/TASK/MODEL 等集中在文件开头，并会自己随机划分与训练；它不是接入任意已拟合模型的纯函数。

## 怎么做

先读课题计划和运行证据，确定要解释哪份模型输出、哪些样本和何种背景。代码复制到课题，在课题环境核查具体分支与依赖；不得为换模型静默改统计设计。已有课题模型时先判断现存训练脚本是否适合，不擅自重训替换原模型。选定分析后再运行；指标异常时检查数据/流程，不把解释图视为模型有效证明。

## 代码

source/ 保留原语言和原字节，code/shap_explain.py 为现存复用脚本，卡片“查看代码”可区分版本并复制/下载。依赖 numpy、pandas、scipy、shap、scikit-learn，模型库按分支需要；本轮未安装或运行模型。

实现范围：脚本列有树、线性、SVM/MLP 等分支，但列出分支不等于全部可运行。本轮静态核查发现部分线性构造传入 random_state、不同分类解释器输出尺度等仍需逐分支复核；不修改历史代码。本轮未找到足以复验旧“四类模型实测”表的配套日志，旧表已留在迁移备份/Git 历史，当前不沿用为验证证明。调用前需课题环境核对；若涉及改统计逻辑或补算法先问作者。

## 输出

[[interfaces/shap-summary]]：feature、shap（解释样本的平均绝对归因）、percent（筛选前总贡献占比）；[[interfaces/shap-samples]]：每行样本×特征的带符号 shap 和 feature_value（脚本按解释样本内各特征缩放到 0–1）。TOP_N/MIN_MEAN_ABS_SHAP 筛选后不重新归一化 percent。输出尺度取决于实际解释分支，图注需说明。

三个历史单 panel 模板使用这些表，语义契约已对照；关系 direct 只表示表无需再改名/整形，不证明上游脚本分支正确或当前课题已联调。模板本身历史固定尺寸，任意 n 的自适应复用仍未迁移。

## 使用记录

2026-10-21：本轮为方法边界、代码来源和关系核查，未运行真实课题分析。

## 知识关联检查

检查现存方法页、单 panel 来源、模板与接口，包括另一来源的回归评估。SHAP 汇总可配条形/环形，逐样本贡献可配蜂群，同一方法对应多图，关系唯一记在 frontmatter，反向由程序派生。

[[methods/regression-resampling-evaluation|回归重采样评估]] 与 SHAP 是有条件的互补参考：前者评估预测，后者归因。预测/指标表没有 SHAP 所需模型、特征及背景，不能直接串联；密度/箱线图的现存输入也不能据此标成 SHAP 兼容。未发现有依据的第二个现存方法可直接读取 SHAP 图表契约，不为多对多演示虚构方法。

'''
protected_write(p, meta, body + '<!-- user:start -->' + get_block(old, 'user') + '<!-- user:end -->\n')

p = root/'methods/regression-resampling-evaluation.md'
meta, body = read_page(p)
meta['figure_relations'] = [
    relation('layouts/2026-10-19-regression-stability__fig03-density-panel', 'adaptable',
             '验证预测中的真实值与预测值可用于观察偏差和边缘分布；现存来源是估读 RGB/直方表，不能直接接真实预测。',
             ['连续结局且同一原始量纲；明确样本、模型、重复/折身份。', '需先确定密度/边缘分布策略与注释统计，不用估读颜色倒推真实频数。'],
             '先确认真实预测的密度/分布计算方案，另完成单 panel 模板化；算法缺失不作为格式改名自动补写。',
             ['methods/regression-resampling-evaluation.md#输入', 'layouts/2026-10-19-regression-stability__fig03-density-panel.md#适用']),
    relation('layouts/2026-10-19-regression-stability__fig04-boxplot-panel', 'adaptable',
             '逐折指标可按模型比较一个指标的分布；来源只消费独立 points/summaries，需要真实一致的摘要且尚未模板化。',
             ['同一验证方案、指标定义与单位；明确折间相关性。', '按已确认的箱体/须/均值规则产生一致结果，横向抖动仅作展示。'],
             '在课题中选指标、整理长表；另确认摘要/须规则和待模板化实现，不拿原估读摘要配真实点。',
             ['methods/regression-resampling-evaluation.md#输出', 'layouts/2026-10-19-regression-stability__fig04-boxplot-panel.md#适用'])]
body = body.replace('已复刻并收录两张组图：', '已复刻并收录两个代表单 panel：')
body = body.replace('两者均待作者签核；尚未拆出ready图模板。方法笔记本身仍为draft，等待作者确认。',
                    '两张来源已签核、待模板化；本方法当前为已确认笔记，现存脚本仅汇总预测，不提供模型训练。没有 ready 密度/箱线模板；原暂停草稿已由作者在前端删除，本轮不恢复或重建。')
body = body.replace('暂停模板保持归档。', '原暂停草稿已由作者在前端删除，本轮不恢复或重建。')
body = body.replace('均为估读图形/待签核来源，', '均为估读来源/已签核待模板化，')
body = body.replace('迁移笔记 [[methods/paired-reference-visual-comparison]] 与 [[methods/repeated-benchmark-distribution]] 分别探索参考解比较和重复运行分布；输入条件不同，先保留文字关联，不自动补算法。',
'''## 家族范围与历史迁移说明

家族限定为连续结局预测模型的验证评估，模型不同可沿用相同预测/指标定义，具体训练与划分实现留在课题。本页现有代码只汇总已有预测；不同模型/重采样设计的训练算法不因家族说明而自动存在或经过验证。

两篇宽泛迁移笔记 [[methods/paired-reference-visual-comparison|配对值迁移（已归档）]]、[[methods/repeated-benchmark-distribution|基准分布迁移（已归档）]] 因不符合作者定义的方法家族联想而停止推荐。仅保留下列适用于当前家族的内容：真实值/预测必须配对、同量纲；重复/折身份及配对不可丢；箱线点/摘要须同源一致；抖动是展示位置；视觉窄箱体和高相关不能证明泛化。不继续推广到参考解、耗时/内存或其他新的分析主题。

2026-10-21 双向检查：查现存方法、单 panel、模板与接口。评估家族可参考密度与箱线两图，但估读渲染表不是原始预测/指标表，故记需要适配且未课题联调。既有 SHAP 三图不表达预测性能；未找到可直接套用其契约的依据。单图对应多个方法的能力以隔离软件夹具验证，不虚构库存关系。''')
body = body.replace('查全部现存方法、两个单 panel、五个模板和四个接口。', '查现存方法、单 panel、模板与接口。')
protected_write(p, meta, body)

for slug in old_notes:
    p = root/'methods'/f'{slug}.md'
    meta, body = read_page(p)
    if '## 归档说明' not in body:
        marker = '<!-- facts:start -->'
        body = body.replace(marker, '## 归档说明\n\n2026-10-21：按作者 Q063 决定归档，不再推荐。本页是历史广泛迁移推导，不属于本库现在采用的有边界方法家族联想。有效的配对/量纲/重复单位/摘要一致性原则已并入 [[methods/regression-resampling-evaluation]]；历史正文和来源保留。\n\n' + marker)
        protected_write(p, meta, body)

for p in (root/'layouts').glob('*.md'):
    meta, body = read_page(p)
    if len(meta.get('panels', {})) != 1:
        continue
    import re
    body = re.sub(r'迁移分析文字笔记：\[\[methods/[^\]]+\]\]；原文方法：', '方法家族：', body)
    body = body.replace('关联 [[methods/repeated-benchmark-distribution]] 和 ', '关联 ')
    body = body.replace('关联 [[methods/paired-reference-visual-comparison]] 和 ', '关联 ')
    body = body.replace('待作者签核，方法笔记也是draft。', '来源已签核待模板化，方法页为已确认笔记；本来源尚非可调用模板。')
    body = body.replace('作者签核后才scaffold-template/verify-template，不提前标ready。', '后续模板化仍须完成代码与回放并由作者确认，不提前标ready。')
    protected_write(p, meta, body)

# Metadata describes actual files only. It never rewrites or claims to execute native code.
for kind in ['methods', 'templates']:
    for page in (root/kind).glob('*.md'):
        asset = page.with_suffix('')
        files = []
        for directory, variant in [('source', 'original'), ('code', 'reusable')]:
            folder = asset/directory
            if not folder.is_dir():
                continue
            for file in sorted(folder.rglob('*')):
                if not file.is_file() or '__pycache__' in file.parts or file.suffix.lower() in {'.pyc', '.html', '.png'}:
                    continue
                if file.name.lower() in {'manifest.json', 'readme.md', 'source.md'}:
                    continue
                rel = file.relative_to(asset).as_posix()
                original = variant == 'original'
                state, evidence = 'not_run', []
                scope = '本轮仅展示原字节与来源，未执行；原始材料可能为示例/片段，非目标图完整实现。' if original else '本轮未执行，不将存在代码当成验证通过。'
                if not original and kind == 'templates' and (asset/'verify/verify.json').is_file():
                    state, evidence = 'example', [f'{kind}/{page.stem}/verify/verify.json']
                    scope = '历史模板示例回放记录；本轮未重跑、不证明真实课题或任意 n 自适应。'
                elif not original and page.stem == 'regression-resampling-evaluation':
                    state, evidence = 'example', [f'{kind}/{page.stem}/verification.md']
                    scope = '历史合成预测表指标/校验检查记录；不含模型训练或真实课题分析→出图联调。'
                files.append({'variant': variant, 'path': rel,
                              'source': '只读归档的来源示例/片段；不是目标图完整原实现。' if original else '重建/整理的复用版本；不是原作者原件，具体分支和环境须核对。',
                              'verification': {'state': state, 'scope': scope, 'evidence': evidence}})
        if files:
            (asset/'code-manifest.json').write_text(json.dumps({'files': files}, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

with TestClient(create_app(config)) as client:
    for slug in old_notes:
        meta, _ = read_page(root/'methods'/f'{slug}.md')
        if meta['status'] != 'archived':
            response = client.post(f'/api/methods/{slug}/archive')
            assert response.status_code == 200, response.text

(root/'AGENTS.md').write_bytes(Path(r'E:\research-wiki\开发\staged\research-wiki\assets\AGENTS.md').read_bytes())
save(config, '方法家族范围、双向图关系、原生代码查看和课题适配规则；归档两篇宽泛迁移笔记')
for p, value in before.items():
    assert get_block(read_page(p)[1], 'user') == value, str(p)
print(json.dumps({'root': str(root), 'archived': old_notes, 'semantic_relations': 5, 'user_blocks_preserved': len(before)}, ensure_ascii=False))
