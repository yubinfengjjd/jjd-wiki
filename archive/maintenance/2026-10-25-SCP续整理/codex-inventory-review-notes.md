# 独立盘点补充（2026-10-25）

1. 实际固定NAMESPACE有142个export，正式analysis家族15个、SCP-example模板16个；coverage必须逐export可追踪，不把S3结束等同全库结束。
2. 还存在历史半成品E:/research-wiki-env/work/scp-embedding与scp-enrichment。不要覆盖或直接认领其pass。enrichment的previews-contact.png经Codex打开：与权威man/figures/Enrichment_comparison-1.png相比主题、背景、点和标签几何显著不同；code/core.R为table-only自写核心，原run_upstream.R仍加载完整本地SCP。source/replays/attempts.json里wordcloud原版失败（gg_par不存在），但contact里有重画图。不能将这些候选整体标原生已复现；可复用数据/数值检查和来源证据，图须按原函数核对。embedding也有半成品，不因存在python-scp环境认定新分支可用；禁止安装。
3. 当前AGENTS有标签措辞矛盾：第88/145/333行说Wiki tags用“规范键”，而ingest.new_page实际把画廊scenarios的规范英文key映射成中文label（ingest.py84-85）。应澄清gallery.scenarios用key，Wiki.tags用配置taxonomy里的label，purposes为另一词表；不能让新条目把single-cell写进tags而老页面全是单细胞分析。
4. 进一步静态检查发现当前rwiki/lint.py metadata_errors仅检查tags为字符串列表，未见实际受控词表校验，虽然规则声称未知tags会ERROR。Codex已独立查正式可读页面，当前未知标签为0，因此不是要批量重写用户标签。下一修复轮须先复现实例、再决定是否补统一校验并同步lint/check-entry/CLI/API；不要只修改文档宣称已有校验，也不要引入另一套词表。此项尚未交付给运行中的Devin，须在其结束后同会话提交明确范围。

本文件只记录审查证据/下一修复建议，不代表本轮已修改或全库已通过，不改变作者签核。
