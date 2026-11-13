"""Isolated software fixture, not a real research study or new Wiki method."""
from pathlib import Path
import hashlib
import importlib.util
import json
import shutil
import pandas as pd

task = Path(__file__).resolve().parent
project = task/'qa-project'
for name in ['data', 'analysis', 'scripts', 'wiki-use/fixture-run']:
    (project/name).mkdir(parents=True, exist_ok=True)
hashfile = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
rows = []
for model, error in [('model_a', 0.5), ('model_b', 1.0)]:
    for i in range(6):
        rows.append(dict(subject=f'S{i+1}', algorithm=model, repetition=1, validation_fold=i//2+1,
                         observed=10.0+i*2, predicted=10.0+i*2+error, design='kfold'))
raw = project/'data/observed-predicted.csv'
pd.DataFrame(rows).to_csv(raw, index=False)
baseline = hashfile(raw)
mapping = {'subject':'sample_id', 'algorithm':'model', 'repetition':'repeat', 'validation_fold':'fold',
           'observed':'y_true', 'predicted':'y_pred', 'design':'split_design'}
source = pd.read_csv(raw)
adapted = source.rename(columns=mapping).copy()
pd.testing.assert_frame_equal(adapted.rename(columns={v:k for k,v in mapping.items()}), source)
target = project/'analysis/regression-predictions.csv'
adapted.to_csv(target, index=False)
module_src = Path(r'E:\research-wiki\知识库\methods\regression-resampling-evaluation\code\summarize_predictions.py')
module_dst = project/'scripts/summarize_predictions.py'
shutil.copy2(module_src, module_dst)
spec = importlib.util.spec_from_file_location('project_summary', module_dst)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
result = module.summarize(adapted, expected_ids=[f'S{i+1}' for i in range(6)])
assert result.shape[0] == 6
assert set(result.loc[result.model == 'model_a', 'RMSE']) == {0.5}
assert set(result.loc[result.model == 'model_b', 'MAE']) == {1.0}
result.to_csv(project/'analysis/regression-fold-metrics.csv', index=False)

# Table shape adaptation retains exact values, keys, and deliberately missing entries.
wide = pd.DataFrame({'case':['p1','p2','p3'], 'A':[1.2,2.3,None], 'B':[4.5,5.6,6.7]})
long = wide.melt(id_vars=['case'], var_name='model', value_name='value')
restored = long.pivot(index='case', columns='model', values='value').reset_index()
restored.columns.name = None
pd.testing.assert_frame_equal(restored, wide)
assert len(long) == 2*len(wide) and long.value.isna().sum() == wide[['A','B']].isna().sum().sum()
assert hashfile(raw) == baseline and hashfile(module_src) == hashfile(module_dst)
run = project/'wiki-use/fixture-run'
context = {'fixture':True, 'question':'固定验证方案的连续结局预测评估，现有逐样本预测还能做什么分析/配什么图？',
           'unit':'synthetic quantity; observed and predicted use same unit', 'row_unit':'one subject/model/held-out fold',
           'completed':[{'work':'synthetic prediction table exists', 'evidence':str(raw)}],
           'unknown':['no real fitted model or features supplied; SHAP cannot be executed from prediction table'],
           'environment':'D:\\anaconda\\python.exe; synthetic software QA only'}
(run/'context.json').write_text(json.dumps(context, ensure_ascii=False, indent=2), encoding='utf-8')
(run/'mapping.json').write_text(json.dumps({'source':str(raw), 'source_sha256':baseline, 'target':str(target),
    'columns':mapping, 'action':'rename only, no statistics/row changes',
    'checks':{'source_unchanged':True,'values_roundtrip':True,'long_wide_roundtrip':True,'missing_values_preserved':True},
    'wiki_code_sha256':hashfile(module_src),'project_code_sha256':hashfile(module_dst)}, ensure_ascii=False, indent=2), encoding='utf-8')
(project/'README.md').write_text('''# 隔离软件验收夹具

全部数据为本次软件检查的合成值，不是真实课题或训练证据。已有 observed/predicted 等列，含义已由夹具定义为同一结局同一量纲；设计字段记录 kfold，样本标识跨模型一致。没有模型文件、特征矩阵或 SHAP 值。原始表只读保留。

任务 A：当前还能做什么分析？任务 B：已有预测/指标该配什么单 panel？仅提出建议，不执行或补缺算法。若上下文改成未知量纲或同名异义，必须询问。不得将只读预测表存在称为模型训练通过或真实科学验证。
''', encoding='utf-8')
report = {'synthetic_fixture': True, 'source_preserved':hashfile(raw)==baseline,'metric_rows':len(result),
          'rename_value_roundtrip':True,'long_wide_value_roundtrip':True,'missing_preserved':True,
          'copy_code_bytes_equal':hashfile(module_src)==hashfile(module_dst)}
(task/'project-adaptation-verification.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report))
