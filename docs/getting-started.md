# 开始使用

本项目有内容库 jjd-wiki 与开发工具库 jjd-wiki-dev。新电脑将两个仓库放在同一父目录；已有嵌套开发检出继续兼容。

## 获取

已取得本仓库的 tools/get-wiki.ps1 后，可在 PowerShell 运行：

```powershell
.\tools\get-wiki.ps1 -Destination '<工作目录>' -Profile light
# 需要全部知识资产与原始材料：-Profile full
```

脚本不会覆盖已有目录，也不安装环境。light 省略原始画廊、大型输入和代码资产，全部知识页可读；full 获取完整内容。当前机器已有的完整检出不会自动转为 light。

## 配置已有环境

```powershell
& 'D:\anaconda\python.exe' -X utf8 tools/configure-machine.py --python-exe '<科学运行器>' --rscript-exe '<Rscript>'
```

本机配置包含路径，保持 Git 忽略。已有配置不覆盖；迁移现有机器应使用 migrate-layout.py，不重复 configure。新增依赖需先列出清单并得到作者批准。

## 查找与复用

```text
rwiki find 判断每个细胞属于什么类型
rwiki find 差异表达 --kind method
rwiki find RunDEtest --scope source
rwiki show differential-expression
rwiki use differential-expression --project <课题目录>
```

浏览器内使用“全局搜索”，可按类型筛选并进入命中章节。检索结果是发现线索；核对研究问题、输入单位、分组和验证范围后再执行。

正式入库、确认与全库保存使用完整检出。课题数据与成图留在课题目录。
