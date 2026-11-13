from pathlib import Path
import concurrent.futures
import json
import os
import subprocess
import argparse

task = Path(__file__).resolve().parent
project = task/'qa-project'
wiki_python = r'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
cli = r'C:\Users\86186\.agents\skills\research-wiki\wiki.py'
inventory = subprocess.run([wiki_python,'-X','utf8',cli,'suggest-methods','--q','回归 预测 验证','--columns','observed,predicted,subject,algorithm','--limit','5'],capture_output=True,encoding='utf-8',check=True)
(project/'wiki-candidates.json').write_text(inventory.stdout,encoding='utf-8')
prompt_template = '''这是只读的隔离软件验收，请勿写文件、运行分析、安装依赖或修改 Wiki。不要读取任何凭据/无关课题目录。

请使用 research-wiki。先读 {skill} 和 E:\\research-wiki\\知识库\\AGENTS.md，再读当前目录 README.md、wiki-use/fixture-run/context.json、data/observed-predicted.csv 的必要内容。候选检索结果已用当前 Wiki CLI 生成到 wiki-candidates.json，可读它并核对相关 Wiki 页面。只读这些路径的必要信息。

请分别回答：1）这个课题下一步还能做什么分析，列当前可做项与少量补材料候选；2）已有预测/指标适合什么可视化，能否现在调用库存模板；3）observed/predicted 等列与 Wiki 输入不同，具体如何处理；4）假如 observed 和 predicted 的单位/定义没有说明，应如何处理；5）来源 XGBoost＋SHAP 能推广到哪里、代码和验证范围如何确认；6）一段当前课题映射成功后要不要自动写回 Wiki。

候选请给页面路径、研究用途、当前前提/材料与缺口、代码状态及关系验证范围。用中文简洁作答，不要实际执行新分析。全部样本是软件夹具，不是真实训练或科学有效性证据。
'''
def run_host(host):
    skill = rf'C:\Users\86186\{host}\skills\research-wiki\SKILL.md'
    prompt = prompt_template.format(skill=skill)
    if host == '.codex':
        prompt += '\n本次是精简验收：最多 3 次只读工具调用，尽量批量读取上述必要文件；不用读资产代码或展开其他技能。不得执行查询之外的任务。已有 CLI 候选已提供，按 code_status 判断证据范围即可。最终回答不超过 700 字，若读不到关键文件如实报告。\n'
    (task/(host[1:]+'-prompt.txt')).write_text(prompt,encoding='utf-8')
    if host == '.codex':
        command = [r'C:\Users\86186\AppData\Local\OpenAI\Codex\bin\896a0166b774037a\codex.exe','exec','--sandbox','read-only','--ephemeral','--skip-git-repo-check','-C',str(project),'-o',str(task/'codex-fresh-answer.md'),'--json','-']
    else:
        command = [r'C:\Users\86186\AppData\Roaming\npm\claude.cmd','-p','--permission-mode','plan',
                   '--tools','Read,Glob,Grep','--allowedTools','Read,Glob,Grep','--no-session-persistence',
                   '--add-dir',r'E:\research-wiki\知识库',r'C:\Users\86186\.claude\skills\research-wiki',
                   '--output-format','json']
    try:
        result = subprocess.run(command,input=prompt,capture_output=True,encoding='utf-8',cwd=project,timeout=240)
        (task/(host[1:]+'-fresh.stdout')).write_text(result.stdout,encoding='utf-8')
        (task/(host[1:]+'-fresh.stderr')).write_text(result.stderr,encoding='utf-8')
        return {'host':host,'returncode':result.returncode,'stdout_chars':len(result.stdout),'stderr_chars':len(result.stderr)}
    except subprocess.TimeoutExpired as error:
        for label,value in [('stdout',error.stdout),('stderr',error.stderr)]:
            if value:
                (task/(host[1:]+'-fresh.'+label)).write_bytes(value if isinstance(value,bytes) else value.encode('utf-8'))
        return {'host':host,'timeout_seconds':240}
if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--host', choices=['.codex','.claude'])
    a=parser.parse_args()
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        results = list(executor.map(run_host,[a.host] if a.host else ['.codex','.claude']))
    (task/('fresh-host-runs'+('-'+a.host[1:] if a.host else '')+'.json')).write_text(json.dumps(results,indent=2),encoding='utf-8')
    print(json.dumps(results))
