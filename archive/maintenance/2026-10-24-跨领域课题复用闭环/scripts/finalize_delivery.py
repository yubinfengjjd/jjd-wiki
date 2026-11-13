"""Assemble the evidence-scoped delivery record after actual deployment."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,sys,subprocess,urllib.request
A=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
P=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024')
sys.path.insert(0,str(A/'scripts'))
from check_protection import check
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

integration=read(A/'reviewed-integration-plan.json')
for row in integration['changes']:
 p=Path('E:/research-wiki/开发')/row['path']
 assert (sha(p) if p.is_file() else None)==row['new'],row['path']
governance=read(A/'governance-sync-plan.json')
for row in governance['rows']:assert sha(Path(row['path']))==row['new'],row['path']
for p,h in governance['protected'].items():assert sha(Path(p))==h,p

browser=read(A/'formal-browser-review/cdp-results.json')
assert not browser['logs']
assert not any(r.get('error') for r in browser['results'])
values=[r.get('value') for r in browser['results'] if isinstance(r.get('value'),dict)]
assert any(v.get('count','').startswith('显示 2 / 15') or '2 / 15' in str(v.get('count','')) for v in values),values
assert any(v.get('runtimeText') is True and v.get('title')=='基因集与通路签名打分' for v in values)
with urllib.request.urlopen('http://127.0.0.1:8765/api/discover-methods?limit=2',timeout=20) as res:assert res.status==200

protections=check()
expected={r['path'] for r in integration['changes'] if r['old'] is not None}
assert set(protections['development']['changed_or_missing'])==expected
assert all(not item['changed_or_missing'] for name,item in protections.items() if name!='development')
log=Path('E:/research-wiki/知识库/log.md')
assert log.read_bytes().startswith((A/'wiki-log-before-release-note.md').read_bytes())
index_path=subprocess.run(['git','-C','E:/research-wiki/开发','rev-parse','--git-path','index'],check=True,capture_output=True,text=True).stdout.strip()
ip=Path(index_path);ip=ip if ip.is_absolute() else Path('E:/research-wiki/开发')/ip
assert sha(ip)==integration['index_before']

text=(A/'acceptance-draft.md').read_text(encoding='utf-8')
text=text.replace('# 跨领域课题复用闭环：独立验收草稿','# 跨领域课题复用闭环：正式交付与独立验收')
text=text.replace('此文件仍为草稿，正式交付结论以final-acceptance.md为准。','本轮基础机制已发布，结论为“限定范围通过，保留具体未验证能力和维护项”，不表示任意领域任意算法已经可运行。')
text=text.replace('- 新会话接手和最终同步仍待本轮尾项核查；不把HANDOVER文档存在本身当接手测试通过。','- 全新消费者relic-sailor实际读取revision50、核对哈希与已有结果，未重算，唯一写入FRESH-SESSION-REVIEW.md；33个受保护课题文件保持原字节。它自行发现未登记的复核结果与clusterProfiler依赖分类错误。Codex随后登记本次复核运行，状态revision54、5次运行、19个产物、3份pending经验草稿；未改旧运行收据。推荐语义另经NEXT-STEPS-REVIEWED.md收窄，不将Slingshot/ORA前提缺口写成已批准执行。')
text=text.replace('新会话接手尚待最终记录','实际新会话接手已核查且未重算；保留推荐内容需独立审查的边界')
text+='''

## 正式同步与服务验收

- 35项经审查的开发源文件增删改已按清单整合；原开发Git暂存区哈希不变，未stage/commit/reset/clean/stash已有工作。
- 使用tools/deploy.py完成.agents/.codex/.claude/.cc-switch/.config/opencode五处安装。每处296个文件与正式staged源逐文件SHA-256一致，旧bundle各清理2项并有备份。正式config仍指E:/research-wiki/知识库，未部署隔离试用config。
- 精确同步20项规则/分类资产：sci-figure-replica实际主源和五处副本的taxonomy、派生metadata schema、分类reference，另同步开发spec和正式AGENTS。五份安装manifest只更新对应资产记录并追加范围说明。798个其他外部skill文件核对未变，未整包覆盖该技能。领域词表15键、证据profile8类；不表示15种领域已实际跑过算法。
- 正式服务http://127.0.0.1:8765启动于已核对的全局.agents技能；API首页、分类和方法发现返回200，当前生产bundle可达。实际Chrome完成领域→用途筛选、计数/URL/返回、方法详情和最小运行事实查看，无该次浏览器错误；methods-filtered.png已独立打开核查。临时8878测试服务已准确关闭。
- 正式lint无ERROR，19项WARN均为已有具体实现not_run/独立性未运行；pending仍为细胞类型注释、双细胞检测、RNA velocity的待验证实现，不清零、不标可用。正式检查发现注释页旧结构验收过期，核对完整正文及现有分支限制后仅刷新acceptance.json；SingleR仍not_run，作者状态与备注未改。
- Wiki规则/结构验收保存于cfcd426；追加交付审计日志保存于4712202。原错误登记及精确恢复的历史保留。最终原始source36、原课题25、画廊来源/元数据146、100个真实作者区块及状态字段核对通过；不得把101个含规则示例的标记片段误计为101作者区块。

## 使用与后续维护

在课题会话中调用research-wiki，让agent先核查当前材料与证据，再列主线/探索/缺材料候选；沿已有授权复制具体分支的最小闭包，显式适配输入、实际运行/出图并检查。没有约定的执行范围/预算不能当无限授权；缺依赖不安装；正式知识回写与作者签核仍分开。原生对象不必全转CSV，表格接口只在确实需要的绘图边界派生。

本轮实测的是显式定位试用技能的Devin自然语言流程、独立新会话接手，以及正式部署后的CLI/API/浏览器；五处文件同源不等于每个宿主的原生自动发现、Claude执行或所有领域算法已另行实测。

已排定的后续维护范围：
1. P1：scp-detest的R options恢复。修复应保留source原始字节、修正正常/异常路径的新增options清理及真实诊断，按分支重做原版/修订版输出与副作用比较；代码变化须生成新证据，禁止把旧算法/独立性收据重绑新哈希。本轮仅以独立R进程隔离，不宣称该缺陷已修。
2. G3：已有ML分支补齐有依据的运行闭包与独立验证，再选择第二领域真实材料。缺资料/依赖的具体分支继续not_run，不新造算法凑数量。
3. 候选推荐继续核对研究问题/谱系、背景基因集、单位和实际入口；来源日志/列存在不证明历史算法已运行。作者3份经验草稿保持pending，真实日常收益需另测，不编节省百分比。

备份/逐文件依据：reviewed-integration-plan.json、integration-backup/、integration-verification.json、governance-sync-plan.json、governance-sync-backup/、governance-sync-verification.json、deployment/backup/、deployment/deployment-verification.json、five-host-independent-hashes.json、final-protection-verification.json、formal-api-smoke.json、formal-browser-review/、fresh-handoff-independent-check.json、native-reviewed-independent-check.json。
'''
assert not (A/'final-acceptance.md').exists(),'Preserve an existing final record'
(A/'final-acceptance.md').write_text(text,encoding='utf-8')
s=read(A/'task-state.json');s.update(status='delivered_with_explicit_limits',phase='deployed_and_independently_checked',deployed=True,review_approved=True,active_label=None,active_state=None,active_result=None,active_events=None,updated_at=datetime.now(timezone.utc).isoformat(),next_action='Framework delivery complete; G3 material gap, existing scp-detest options maintenance and author lesson review remain explicitly open',delivery='final-acceptance.md')
s['acceptance']={'G0':'passed_structural','G1':'passed_real_descriptive_scoped; options_restoration_gap_explicit','G2':'scoped_GSM_handover_and_reuse_passed; disease_inference_not_approved','G3':'partial_not_run_material_runtime_inventory_gap','A25':'first_partial_then_reviewed_actual_call_and_plot; actual_fresh_handoff_passed','authors':'3_project_lessons_pending_no_signoff','formal_api':'200','formal_browser':'passed','five_installs':296}
(A/'task-state.json').write_text(json.dumps(s,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'delivered':str(A/'final-acceptance.md'),'status':s['status'],'formal_service':'http://127.0.0.1:8765/#/methods','protected':True},ensure_ascii=False))

