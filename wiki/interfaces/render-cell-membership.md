---
type: interface
slug: render-cell-membership
title: 细胞级集合成员表
columns:
  cell:
    type: str
    description: 细胞标识；同一集合内唯一；每个细胞每个集合一行
  set:
    type: str
    description: 集合名；如 Ductal、G1S；顺序显式给出
  member:
    type: int
    description: 是否属于该集合；只接受 0 或 1
---
# 细胞级集合成员表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell | str | 必需 | 细胞标识；同一集合内唯一；每个细胞每个集合一行 |
| set | str | 必需 | 集合名；如 Ductal、G1S；顺序显式给出 |
| member | int | 必需 | 是否属于该集合；只接受 0 或 1 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]] · [[templates/2026-10-22-scp-example__fig13-upset--upset|多集合交集 UpSet 图]]
<!-- facts:end -->

## 含义

行单位是「一个细胞 × 一个集合」：同一 `cell` 在每个 `set` 下恰好一行，`member` 只取 0 或 1（不是 `TRUE`/`FALSE` 文本，也不是 0–100 的百分比）。模板把长表透视为 `cell × set` 的逻辑矩阵，再交给 ggVennDiagram / ggupset 计算集合大小和交集；集合大小等于该 `set` 的 `member` 之和，交集大小等于对应多个集合同时为 1 的细胞数，不做加权、不补缺失、不重新定义集合。准备数据时最重要的前提是「同一细胞全集 × 同一集合全集」的完整笛卡尔积：缺一个 `cell × set` 行会让该集合看起来更小，并在交集中被静默排除；重复的 `cell × set` 行会把计数成倍放大；`member` 出现 0/1 以外的值、NA 或文本都必须报错。`set` 的顺序由 `style.set_levels` 显式给出，未给时按输入首次出现顺序；集合名就是图上标签，不能用同一名字指代两种定义。与 `render-cell-linkage` 的区别：后者每个维度是互斥的单值类别（一个细胞在一个维度只能属于一个类别），本接口是每个集合独立的布尔成员关系，一个细胞可以同时属于多个集合，因此才能画维恩/UpSet 交集。与 `render-cell-metadata` 的区别：后者每个细胞一行、一个 `group` 与一个 `stat`，用于组成图；本接口不表达组内比例。模板不重算上游统计，只按本表还原成员矩阵；若集合定义依赖表达阈值或细胞类型合并，须在课题内先算好并记录定义。

<!-- user:start -->
<!-- user:end -->
