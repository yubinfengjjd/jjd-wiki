"""Register Codex's already performed isolated validation; never execute analysis."""
from pathlib import Path
import sys,json,hashlib
A=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
P=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024')
sys.path.insert(0,str(P/'.agents/skills/research-wiki'))
from rwiki.project_state import load_project,add_task,record_run,add_observation,add_lesson
before=json.loads((A/'fresh-handoff-before.json').read_text(encoding='utf-8'))
changed=[r for r,h in before.items() if hashlib.sha256((P/r).read_bytes()).hexdigest()!=h]
assert not changed,changed
s=load_project(P);assert s['revision']==50
events=[json.loads(l) for l in (A/'logs/devin-a25-fresh-handoff-events.jsonl').read_text(encoding='utf-8').splitlines()]
writes=[e.get('path') for e in events if e.get('kind')=='file_write']
assert writes==[str(P/'FRESH-SESSION-REVIEW.md')],writes
(A/'fresh-handoff-independent-check.json').write_text(json.dumps({'session':'relic-sailor','revision_read':50,'protected_files_unchanged':len(before),'file_writes':writes,'no_recomputation':'No new scientific analysis/render launched in the read-only consumer turn; existing reviewer rerun was independently produced before discovery. Native output identity rechecked by hashes.','result':'passed_scoped_handoff_and_reuse; remaining recommendation wording corrected separately'},ensure_ascii=False,indent=2),encoding='utf-8')

driver='file:scripts/run_de_reviewed.R'
code=['file:scripts/wiki-scp-detest/analysis.R','file:scripts/wiki-scp-detest/de_native.R',driver]
add_task(P,'task-de-independent-review',family_id='differential-expression',implementation_id='scp-detest',
 purpose='Codex独立复核诊断保存修复；相同真实输入和算法，不是新增生物学主张',
 role='support',inputs=['object:seurat-annotated'],params={'group_by':'celltype','group1':'RGC_like','group2':None,'test.use':'wilcox','p.adjust.method':'bonferroni','seed':11},
 authorization='authorization:auth-acceptance',stage='independent_verification',
 note='编码驱动由Devin提供，实际运行和检查由Codex完成；不冒充A25消费者的新运行；旧表/收据不变。')
outdir='analysis/de-rgclike-reviewed/'
record_run(P,'run-de-reviewed-codex-001','task-de-independent-review',status='completed',
 command='D:/R-4.5.0/bin/x64/Rscript.exe --vanilla scripts/run_de_reviewed.R',
 outputs=[outdir+n for n in ('allmarkers.csv','diagnostics.rds','diagnostics.json','process-checks.json')],
 checks=['actual process exit0; elapsed157.003sec <=600sec',
 '7403 rows; raw table SHA256 identical to first run 971b39c5c7a4abce111c3ff7f2efdd69068eb3c03cd8907c67443b7dd0d743fd',
 'S4 SerialParam preserved in actual diagnostics.rds; JSON explicitly class/summary; all four output files nonempty',
 'actual search restored=true; actual options restored=false and closure options_restored=false; separate R process ended, no shared-session cleanliness approval'],
 code=code,environment={'R':'4.5.0','Seurat':'5.6.0','SeuratObject':'5.4.0','BiocParallel':'1.42.0','Matrix':'1.7.3','rlang':'1.1.6'},
 note='完成指本次计算与数据/序列化检查；存在明确options恢复缺陷，不表示所有副作用检查或科学结论通过。历史零字节诊断文件及原收据仍保留。')
add_observation(P,'obs-options-restoration-gap',
 '真实复核运行中search恢复但options新增项未恢复；闭包自身options_restored也为false。当前仅在独立新R进程调用，不批准共享R会话无副作用复用。',
 about='task:task-de-independent-review',value='true',basis='verified',evidence=outdir+'process-checks.json',
 scope='仅本次SCP-local scp-detest/现有R依赖组合；不外推其他实现',note='实际诊断和退出证据均保留；未改源码/算法收据/作者签核。')
add_lesson(P,'lesson-options-restoration',
 '运行结果与图正确不足以证明R环境无副作用；诊断必须保留实际options增删和恢复状态，S4参数应原生保存并显式摘要，而不是清空JSON。',
 evidence=['run:run-de-reviewed-codex-001','observation:obs-options-restoration-gap'],
 applies_to='本次SCP-local 0.5.6 scp-detest、R4.5.0/Seurat5.6.0案例；其他分支需分别核查。暂以独立R进程隔离，不推广共享会话安全。',
 links=['differential-expression'],basis='verified',note='Codex阶段审阅草稿，pending；不代作者接受或自动回写正式库。')
s=load_project(P)
note='\n\n## Codex最终接手补充（2026-10-25）\n'
note+=f'- 全新消费者relic-sailor在revision50完成只读接手，原有33个受保护课题文件未改，唯一写入FRESH-SESSION-REVIEW.md；未重算。该报告是当时快照，后续状态以当前project.json（revision{s["revision"]}）为准。\n'
note+='- 已通过公开API补登记run-de-reviewed-codex-001：实际新进程退出0、157.003秒、7403行表与初次逐字节相同、诊断RDS/JSON非空。旧零字节文件不改写。options恢复=false，search恢复=true；只批准独立R进程的描述性运行，不宣称环境无副作用。\n'
note+='- 新增lesson-options-restoration为pending草稿；其余作者草稿仍pending，无作者签核。后续建议以NEXT-STEPS-REVIEWED.md为准，不能把条件候选标题当执行授权。\n'
for name in ('HANDOVER.md','REVIEW-RESPONSE.md'):
 p=P/name;p.write_text(p.read_text(encoding='utf-8')+note,encoding='utf-8')
(A/'native-run-registration.json').write_text(json.dumps({'revision':s['revision'],'run':'run-de-reviewed-codex-001','old_receipts_retained':True,'lessons_pending':list(s['lessons'])},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'revision':s['revision'],'runs':len(s['runs']),'artifacts':len(s['artifacts']),'lessons':len(s['lessons'])}))
