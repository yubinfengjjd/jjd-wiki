"""Reviewer correction of local trial metadata using the public revision API."""
from pathlib import Path
import sys, json, shutil
from copy import deepcopy
P=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024')
A=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
sys.path.insert(0,str(P/'.agents/skills/research-wiki'))
from rwiki.project_state import load_project,update_project,add_observation

s=load_project(P)
assert s['revision']==48,'Already changed: review rather than repeat'
backup=A/'pilot-metadata-review-before'
assert not backup.exists()
backup.mkdir()
for rel in ('wiki-use/_project/project.json','wiki-use/_project/summary.md','HANDOVER.md','REVIEW-RESPONSE.md'):
 dst=backup/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(P/rel,dst)

def fix(old):
 new=deepcopy(old)
 task=new['tasks']['task-prop-gsm']
 assert task['family_id']=='cell-type-annotation' and task['implementation_id'] is None
 task['family_id']=None
 task['note']+='；Codex复核修订：既有标签的计数/比例聚合，不执行注释算法，规范家族未绑定；原始登记和收据保留在审计历史。'
 obj=new['objects']['expr-annotated-v']
 assert obj['properties'].pop('assay')=='normalized'
 obj['note']+='；Codex复核：移除缺少充分证据的assay=normalized枚举，不能由data层存在/源脚本推断历史归一化正确；mouse/symbol有源材料支持但不证明注释正确。'
 obs=new['observations']['obs-pathway-10']
 obs['claim']='scored rds中存在10个*_score列；存在性由实际对象读取核查。五方法ensemble执行历史未证实。'
 obs['value']='true';obs['scope']='仅列存在性；不批准任何打分算法实际执行/正确性'
 obs['note']='Codex明确收窄当前可消费事实；旧宽泛描述保留在revision48备份。'
 return new,('review_correction','Codex: task-prop-gsm family cell-type-annotation -> null; remove unsupported normalized assertion; narrow score observation to actual column existence. Original receipts/outputs retained, revision48 archived.')

result=update_project(P,fix,expected_revision=48)
result=add_observation(P,'obs-review-codex-final',
 'Codex独立核查7403行原始/映射表、71个零p值的显式绘图下界、两文件运行闭包哈希，并实际打开火山图；结果表与图可作描述性软件验收，诊断JSON为空的缺口仍在。首次正式登记已精确恢复；此前元数据命令被客户端文字过滤器拒绝，不是人类用户拒绝。',
 value='true',basis='verified',scope='限定的软件与图像核查，不代替作者签核、疾病推断或归一化/注释科学验证',
 note='独立证据 E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环/a25-independent-output-review.json')
note='\n\n## Codex独立复核补充（2026-10-25）\n'
note+='- 通过公开update_project留痕修订，task-prop-gsm当前family_id已实际置空；保留任务ID、原始收据、产物和revision48备份。先前“字段不可修改”的说明不准确。\n'
note+='- expr-annotated-v移除缺少充分证据的assay=normalized；10个score列的当前观察收窄为列存在性，不声称五法ensemble已运行。\n'
note+='- Codex独立检查7403行映射、71个零p值绘图下界、运行闭包哈希，并实际打开火山图。原生图横轴diff_pct，纵轴带方向的-log10校正p，颜色log2FC；不是常规横轴log2FC的火山图。顶部是绘图下界显示，并非精确p值。\n'
note+='- 诊断JSON为空的历史缺口保留，不据此声称整个R驱动成功退出或恢复检查已通过。\n'
note+='- 此前关于“用户拒绝元数据登记”的归因有误：实际是客户端已知操作的文字过滤器拒绝，未发生人类用户拒绝。\n'
note+='- 首次错误正式登记已由5119fa326da1的针对性恢复提交04c1f767f815纠正，审计日志保留；不声称正式Wiki从未被触及。\n'
for name in ('HANDOVER.md','REVIEW-RESPONSE.md'):
 p=P/name;p.write_text(p.read_text(encoding='utf-8')+note,encoding='utf-8')
(A/'pilot-metadata-correction.json').write_text(json.dumps({'before_revision':48,'after_revision':result['revision'],
 'task_family':result['tasks']['task-prop-gsm']['family_id'],'receipts_untouched':True,'backup':str(backup)},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'revision':result['revision'],'family':result['tasks']['task-prop-gsm']['family_id']},ensure_ascii=False))
