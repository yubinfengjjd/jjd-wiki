# GroupHeatmap候选途中审查

运行中的valley-handsaw尚未收到本文件；待返回后同会话提交，不能视为已修。

## R1：真实嵌套source失败（已独立复现）

Codex复制当时完整code到dot-module-checkpoint/code，经另一目录driver用source(core.R,local=env)加载，报cannot open E:/research-wiki/scp_helpers.R。日志logs/codex-dot-nested-source-red.log。core.R沿用sys.frame(1)$ofile，并且source(helper)未传local，会把helper泄漏到全局；source两模块到同一环境时共享名称也可能覆盖。源码/资源路径必须取当前被source文件（最内层ofile），helper与native engine放模块私有闭包，实际入口保留唯一捕获，不再依赖全局get_style/build_matrices/SCP_helpers。公开render、直接函数、嵌套source与先后加载两模板后旧入口分别调用须做有据验证。这个探针只验证加载边界，不授予算法/视觉通过。

## R2：输入与顺序语义

panel.R对value/percent直接as.numeric，R factor可能被变成level code而仍通过有限值检查；直接函数也要按真实float契约拒绝此类无声明转换。matrix_order/feature_order/group_order的同身份多值、不同身份同order、跨matrix的feature顺序冲突需要明确拒绝或按已声明显式规则处理，不能仅unique(order())后悄悄认领。联合主键matrix×feature×group唯一；feature跨group重复是合法长表，现接口文字“同一矩阵内重复feature”有误，应澄清。

percent真实来源：固定原GroupHeatmap在mat_raw每细胞表达上计算sum(x>exp_cutoff)/length(x)，不是对聚合后value/zscore求比例。0–1尺度已核对；不填补缺失或自动除100。

## R3：组合入口与声明不能混淆

当时draw(fig,rect,tables,style)只是print(p$plot)，忽略rect，会画整页；这不能称为通过区域内组合绘图。优先按R原生grob/plot对象返回让明确的组合层处理；如保留draw适配则须实际尊重区域/不resize外层画布。实际支持与未验证范围写清，不能拿render成功当draw组合也成功。

## R4：黄金参考和副作用

固定样式必须用本次原函数真实运行参考，记录源调用/表/设备/尺寸/字体/seed和hash。不能用历史重画preview当golden。算法/数值对照、PNG视觉、异目录独立执行、作者签核分开；新来源保留review/pending_signoff，不代签。包在新进程加载是已知运行环境，不因此声称共享R会话无副作用。

## R5：官方运行清单校验未通过（实际读取）

Codex用当前正式rwiki.runtime_contract.runtime_facts读取当时候选runtime.json，结果portability.state=invalid、issues=[独立性收据绑定的闭包已变化]；详见runtime-facts-checkpoint.json。自写verify.json标exit0不足以替代正式解析器。最终id要与实际来源/未来规范template id一致，不用短fig17-id冒充完整业务id；chart-type优先现有概念，不能仅为原生样式多造同义图型。当前入口是Rscript code/render.R，应如实声明script入口而非默认function（v2兼容字段，读现有parser契约），复制清单/资源/闭包hash/真实新进程/命令与当前文件绑定。变更后必须实际再跑并由官方runtime_facts给出verified，保留原无效证据，不通过重绑旧图像hash假装新调用。
