---
title: "scRNA-hdWGCNA共表达网络分析【2】:富集分析及大型球体网络图构建可视化"
account: "KS生信科研课"
author: "TS的美梦"
publish_time: "2026-08-10"
url: "https://mp.weixin.qq.com/s?__biz=Mzg5OTYzMzY5Ng==&mid=2247492704&idx=1&sn=d5e8d942bac81e23c39a125459d31256"
parent_url: "https://mp.weixin.qq.com/s/LOpSnqiK3nfG-wVU8urzVw"
---

# scRNA-hdWGCNA共表达网络分析【2】:富集分析及大型球体网络图构建可视化

（作者手动粘贴自浏览器已验证正文；完整内容 `.rds` 示例对象及自定义球体网络函数源码未随公开正文附带，原帖注明发布于微信 VIP 群。）

## 加载数据与上游提取（原帖节 2）

```r
TOM <- GetTOM(seurat_obj, wgcna_name='ARH')
hub_df <- GetHubGenes(seurat_obj, n_hubs = 300)
TOM <- TOM[hub_df$gene_name,hub_df$gene_name]
dim(TOM)
adj_mat <- melt(TOM, varnames = c("from", "to"), value.name = "tom")
adj_mat <- adj_mat[adj_mat$tom>0.02,]
edge_file <- adj_mat[,1:2]
#write.csv(edge_file,file = './edge_file.csv')
#获取node，需要基因及module两列即可
gene_module <- hub_df[,1:2]
gene_module <- gene_module[gene_module$gene_name %in% unique(c(unique(edge_file$from),unique(edge_file$to))),]
#module color
mod_color_df <- GetModules(seurat_obj) %>%
  dplyr::select(c(module, color)) %>%
  distinct %>% arrange(module)
mod_color_df <- mod_color_df[-1,]
gene_module <- gene_module %>%
  left_join(mod_color_df, by = "module")
#write.csv(gene_module,file = './gene_module.csv')
```
