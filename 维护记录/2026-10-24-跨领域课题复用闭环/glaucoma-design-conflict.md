# 指定课题的样本标签冲突

2026-10-24，Codex只读检查。

- 原脚本preprocess.R第142–147行含“请根据实际实验设计修改分组”的注释，并将GSM7986396标为Control、GSM7986397标为Glaucoma。
- [GEO系列GSE251716](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE251716)列两个样本：GSM7986396 Control，GSM7986397 LXB4。
- [GSM7986396](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM7986396)为小鼠视网膜，treatment=None。
- [GSM7986397](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM7986397)的title与treatment为LXB4。

上述公开元数据与脚本的Glaucoma标签不同；不能由项目目录名或论文涉及青光眼推导这两个样本就是疾病/健康比较。尚未核实是否有额外课题设计依据，已向作者询问。

本轮继续编码与软件复用验收，但使用GSM编号表达样本；原脚本/RDS/已有图一律保留。任何疾病分组推断和需要疾病标签的统计解释保留待核实，不静默“纠正”原课题或拿细胞数当生物学重复数。

这应成为真实课题状态识别的反例：区分脚本自述与来源证据，记录冲突和影响，而不是无条件接受已有phenotype字段。
# 作者最新决定（2026-10-24）

作者答复：“我不知道，你看着做就可以，反正是跑个实验”。本轮继续软件实验验收，使用GSM7986396/GSM7986397身份标签，保留原文件与原始分组。不再要求作者补充设计后才推进独立软件工作。这不解决疾病/处理设计事实，也不授权把每个细胞当生物学重复进行疾病推断。

