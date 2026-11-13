---
title: "EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性"
account: "Python机器学习AI"
author: "Python机器学习AI"
publish_time: "2026-10-19 00:00:00"
url: "https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg"
source_html: "article.html"
---
![图片](<https://mmbiz.qpic.cn/sz_mmbiz_gif/qHBoqosjg4rakg7KPm75YgiaAYYfMjickBiaLGqXHZlj8BS19Rh5icaUongybUkmiappmoSgvSyribDQSyagdt9OPSNQ/640?wx_fmt=gif&wxfrom=5&wx_lazy=1&wx_co=1&retryload=1&tp=webp>)

✨ 欢迎关注Python机器学习AI ✨
本节介绍：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性，数据采用模拟数据无任何现实意义，作者根据个人对机器学习的理解进行代码实现与图表输出，仅供参考。完整数据和代码压缩包，需要的朋友可关注公众文末提供的获取方式。点赞、推荐、转发支持~！





✨ 相关信息 ✨

![image](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOXibc3gpknrUsjITT5ePWIJzBatiadhZmOibevLVGShlK1pCORJluKRwn0RUlwXu2W8hqibibqLmNFQxxzBTO9iaemapZulXHe99CZhQ/640?wx_fmt=png&from=appmsg>)


![image](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOXf0FVd572ZBG8e8TTiaFGjPI8qwbyficRYncLNjTbayGjMpytc2fosICXrAHCvILOtt3OibMaSOdmqM4Wia4m2icRsLIgEhTqmFicK0/640?wx_fmt=png&from=appmsg>)

文献配图采用“上部密度散点图+下部箱线图”的复合形式，核心目的是在多模型对比下，全面评估并证明提出模型（MCMM）不仅预测最准，而且在不同数据划分下表现最稳。在方法上，作者没有采用单次数据划分，而是进行10次独立重复随机划分（Repeated-split，64%训练/16%验证/20%测试）。图(a-f)汇总了10次测试集的预测结果，通过红绿颜色映射（KDE核密度）直观展示预测值与观测值的吻合度；图(g-i)则利用箱线图叠加散点（灰点代表单次实验，菱形代表均值），展示RMSE、R²和MAE在10次实验中的分布范围。结果显示，MCMM模型的散点最贴近1:1基准线，R²最高（0.66），且底部箱体最窄、中位数最优，证明该机制约束模型相较于传统机器学习模型（MLP、XGB等）具有更优的预测精度和极强的鲁棒性（稳定性）

![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOWfUAD2WaY7sSqvRzdZNg99ab5J6enTUBDJN2bo3Q3cMzvxLbR4j3kEE7fcQwH4f26DicwMy0OxHm2IKJmD9FJ4Siczllmq4BqicE/640?wx_fmt=png&from=appmsg>)


![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOWkmsl2VlOF4wtZ193CN4DUsS6aYKJjBjkRVU66icVRVmibORjrWgu0aeqeXLsvuXKMzqZc1SH1r01K23EKicUpuCJwSZ3qujNaqM/640?wx_fmt=png&from=appmsg>)

原文献采用10次独立重复的随机划分（利用不同随机种子打乱数据）来评估，但在实际复现中，采用K折交叉验证更为通用。K折交叉验证的本质作用是“消除划分偏差”，确保每条数据都轮流作为测试集，彻底排除单次随机划分的运气成分。在复现该图时，只需将K折中每一折的测试集预测值汇总画出密度散点图，并将每折产生的评估指标作为箱线图的独立数据点，就能最严谨、无死角地展示模型在不同数据下的稳定性
✨ 基础代码 ✨










































































```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import warnings
# 忽略所有警告
warnings.filterwarnings("ignore")

path = r"2026-10-18公众号Python机器学习AI.xlsx"
df = pd.read_excel(path)

from sklearn.model_selection import train_test_split

# 划分特征和目标变量
X = df.drop(columns=["SR"])
y = df["SR"].astype(float)

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.3,
    random_state=42
)

from sklearn.model_selection import GridSearchCV, KFold
from sklearn.base import clone
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from xgboost import XGBRegressor
from scipy.stats import pearsonr

#  定义10折交叉验证策略
cv = KFold(
    n_splits=10,
    shuffle=True,
    random_state=42
)


xgb_model = XGBRegressor(
    objective="reg:squarederror",
    random_state=42,
    n_jobs=-1,
    verbosity=0
)

#  设置网格搜索参数
param_grid = {
    "n_estimators": [100, 300, 500],
    "max_depth": [3, 5, 7],
    "learning_rate": [0.01, 0.05, 0.1],
    "subsample": [0.8, 1.0],
    "colsample_bytree": [0.8, 1.0]
}


grid_search = GridSearchCV(
    estimator=xgb_model,
    param_grid=param_grid,
    scoring="neg_root_mean_squared_error",
    cv=cv,
    n_jobs=-1,
    refit=True,
    verbose=1,
    return_train_score=True
)

grid_search.fit(X_train, y_train)


# 最优模型和最优参数
best_model = grid_search.best_estimator_
best_params = grid_search.best_params_
best_cv_rmse = -grid_search.best_score_
```


通过XGBoost结合网格搜索（GridSearchCV）和K折交叉验证（K-Fold CV）来寻找最优超参数，具体做法是将训练集划分为10份，在每一轮参数组合评估中轮流用9份训练、1份验证，从而彻底消除单次数据划分的偶然性，确保筛选出的模型参数在全局数据上具有最稳健的泛化能力


































```python
fig, axes = plot_observed_predicted(
    df_samples=df_oof_pred,
    x_col="y_true",
    y_col="y_pred",

    # 图中显示的名称和单位
    x_label="Observed",
    y_label="Predicted",
    x_unit="SR",
    y_unit="SR",

    # fold 指标表
    df_fold_metrics=df_fold_metrics,
    fold_col="fold",

    # 不传时自动根据数据确定
    xlim=None,
    ylim=None,

    # 自定义配色
    colors=colors,
    cmap="RdYlGn_r",

    # 自动刻度数量
    tick_count=6,
    annotation_text="Test (XGBoost)",

    # 保存图片
    savepath="observed_predicted.png",
)

plt.show()
```



![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOXDdJCeSV815j62icfibgPKxLPt5h95GTm4TLXAyuETicWD6oc1ecfmWvUPkibMpamG4JkQxlrbSqrkKDdEQficCVrJSVyRxW5ziakSs/640?wx_fmt=png&from=appmsg>)

基于10折交叉验证的折外预测结果（Out-of-Fold Predictions），绘制真实值与预测值的密度散点及边缘分布图
左上角的评价指标矩阵是证明模型“既准又稳”的核心证据：其中R2=0.86±0.06和r=0.93±0.03表明模型具有极高的解释力和线性相关性，而RMSE=10.18±2.06与MAE=6.90±1.09则显示其整体预测误差较小（且RMSE与MAE的差值反映出存在少量较大的离群误差）；最关键的是，所有指标后附带的“±”标准差数值均非常小，这意味着在10次不同的数据划分下，模型性能波动极小，证明其卓越的泛化能力和极高的鲁棒性，而图中的线性拟合方程（y=0.86x+5.29）及实线略低于1:1虚线的表现，则直观揭示了模型在极高分样本中存在轻微的“低估”趋势
回归任务中常见的性能散点图，通常只展示单次划分下独立测试集的预测结果，其核心目的是为横向对比不同模型在同一未知数据上的泛化下限（即谁预测得最准）；而这里展示的散点图（图中标注nsplit=10且指标带有“±”标准差）则有着本质的区别——它汇总了 10 折交叉验证的折外预测结果，其核心目的从“单向对比”转向了“多维度评估稳定性”。它不仅展示模型拟合的整体趋势（深绿实线），更通过指标后极小的标准差数值（如R2=0.86±0.06）以及颜色密度分布，向读者证明：模型不仅在绝大多数数据上预测准确，且在多轮不断打乱的数据划分中都能维持极高的表现，体现其强大的鲁棒性与泛化可靠性






















```python
y_test_pred = best_model.predict(X_test)

test_rmse = np.sqrt(
    mean_squared_error(y_test, y_test_pred)
)

test_r2 = r2_score(
    y_test,
    y_test_pred
)

test_mae = mean_absolute_error(
    y_test,
    y_test_pred
)

print("\n独立测试集结果：")
print(f"RMSE: {test_rmse:.6f}")
print(f"R2:   {test_r2:.6f}")
print(f"MAE:  {test_mae:.6f}")
```








```makefile
独立测试集结果：
RMSE: 9.643960
R2:   0.895816
MAE:  7.167841
```


使用经过交叉验证调优后的最优模型，在一个完全未参与训练和调参的独立测试集上进行最终评估，得到极高精度的预测结果（R2=0.896，RMSE=9.64）；它与前面K折结果的差异在于：K折交叉验证是用训练集内部的多轮验证来评估模型的稳定性与鲁棒性并用于挑选参数，而独立测试集则是对模型最终泛化能力的一次性“盲测”，用于证明模型在真正未知的新数据上依然具备强大的预测精度

![image](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOWjWc6QBCBaOH0LMSNGye6W5j1BcVxRTvwKicrtDkcvTWoaDVeicoWcyNuibaBATcUtwThY2UrBEHUTZJ4friciaDTgPJT0xnIXofJY/640?wx_fmt=png&from=appmsg>)

在前面，基于单一模型绘制高颜值的“密度散点+边缘直方图”。但在顶刊论文中，为了证明模型具有普适的优越性，通常需要将多个基线模型组合在同一张画布上进行横向对比，同理绘制即可










```javascript
fig, ax = plot_prediction_error(
    model_metrics=model_metrics,
    metric_col="RMSE",
    y_label="Test RMSE (SR)",
    savepath="rmse.png",
)

plt.show()
```



![image](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOUvtTWnWL9WabrVoHicibticYmClX9T7CY48H1WvZ7DxmthrR3Sicz8c68sAo1U6ykBC0HdCgBZG9w7jzb60lg2p5rBia4WpyCdDeo8/640?wx_fmt=png&from=appmsg>)

将六种模型在K折交叉验证中产生的多次测试集RMSE指标绘制成带叠加散点和均值菱形的箱线图；从结果可以看出，ET和MLP模型的箱体最短、均值菱形最低且离群点较少，说明它们在多次实验中预测误差最小且表现最稳定，而AdaBoost和GB（梯度提升）不仅误差上限较高，箱体较宽，且存在较高的离群点，稳定性相对较差











```javascript
fig, ax = plot_prediction_error(
    model_metrics=model_metrics,
    metric_col="MAE",
    title="Absolute error",
    y_label="Test MAE (SR)",
    savepath="mae.png",
)

plt.show()
```



![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOUyNLTem5bo6g8vkND2ERXqkLoxEFBfjN4RcXLRDibHgma3VoVCVNpYnyxFZ2D7akclsjs0uaibwEeIkSCVQW2dBa6FrWpSpxEEs/640?wx_fmt=png&from=appmsg>)

将六种模型在多次重复划分中产生的测试集平均绝对误差（MAE）绘制成带有均值菱形和数据散点的箱线图；从图中可以看出，MLP和ET模型的箱体最为紧凑且均值最低，说明它们不仅平均绝对误差最小，而且在不同数据划分下表现最稳定，而AdaBoost不仅整体误差最高，且箱体拉长、散点分散，说明其预测波动性较大，鲁棒性相对较弱











```javascript
fig, ax = plot_prediction_error(
    model_metrics=model_metrics,
    metric_col="R2",
    ylim=(0.75, 1),
    title="Explained variance",
    savepath="r2.png",
)

plt.show()
```



![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOW8J6vpvHicJj4vruQxD69mUw4wxfgQ73KMlg4sukHSL9XibiasxiaWsibicWjDjaBvS3TlFb6bg9NkegzZMEcicicG3HyU6ic1rpSJzF6o/640?wx_fmt=png&from=appmsg>)

将六种模型的测试集决定系数（R2）绘制成带有数据散点和均值菱形的箱线图；从图中可以看出，XGB和ET模型的均值最高，表明它们的平均解释能力最强，但XGB的离群点极多且跨度极大（低至0.76），而ET和RF的上限很高但下限略低。综合来看，MLP、GB和RF的箱体相对紧凑，说明它们在多次数据划分中表现更为稳健，而AdaBoost整体R2最低且分布靠下，解释能力最弱

![image](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOXf9sNrTdoYgJr7gRDibLRvKB9sx5sausmehiaRysCiausMnrf1sPiarrwgpsXrBEJkmQvdLYKNJY9TXYY74EQZg8qnEFhGZbd34fE/640?wx_fmt=png&from=appmsg>)

共同表明最稳定的模型是 MLP，因为它的三个箱体最为紧凑、离散程度最小；而平均评价指标最好的模型是 ET，它在 R2上的均值（菱形位置）最高，且在RMSE和MAE上的均值也处于第一梯队，综合表现最优。因此，在后续进行模型超参数优化以及利用SHAP等方法进行模型驱动解读时，就建议在ET模型上进行，因为它既代表了当前数据下的最优预测能力，又能保证后续解读出的特征重要性是建立在最稳健的拟合基础上；当然，如果侧重点是完全排除异常点的干扰、追求绝对的预测波动最小，也可以选择MLP进行后续分析——还可以引入模型完全未见过的独立测试集计算其评价指标——如果该模型在独立测试集上依然能跑出与交叉验证均值高度吻合的优秀成绩，就能从“多次实验的稳定性”和“绝对未知数据的泛化精度”双重维度，彻底坐实它是进行后续深度驱动解读的最佳基线模型
当然，公众号中还有更多机器学习期刊实战技巧，您可以通过历史文章进行检索和阅读，关注公众号，点击“发信息”>“历史文章”即可搜索公众号所有文章信息

![图片](<https://mmbiz.qpic.cn/sz_mmbiz_gif/gtjgibGaKbYMN90bp4wVPvbkZic2ySgbScynp2Idc2w9XCsoFbsZic1brzvF9GkfTjialJQibCR0lib80kB5dJJRicZJ4cIHccAyp5vQ9cM3rXAKkw/640?wx_fmt=gif&from=appmsg&wxfrom=5&wx_lazy=1&tp=webp>)


点赞



收藏



分享






![图片](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOUtMIRLszyhZt2qW3QOibq8b9n0ibxZuyicxEBia6m2fpAKucrX4A9Xian9twDMicCWHafbqnkhPzFpf3MLZuN4bQQkacp2VDvzq2RO8/640?wx_fmt=png&from=appmsg&watermark=1&wxfrom=5&wx_lazy=1&randomid=2086ckg2&tp=webp>)

✨ 该文章案例 ✨

![image](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOUcBxuibiaibxvaynVIjz2fJJYPFFibkbxcvA0aX5ZXhp9n2SNib96cMLy3KqJQDlbT3qjxGW6HZARIGHWIQlic0T9f0FvaZkFgsOKsI/640?wx_fmt=png&from=appmsg>)

在上传的文件中，像往期文章一样，将对案例进行逐步分析，确保读者能够达到最佳的学习效果。内容都经过详细解读，帮助读者深入理解模型的实现过程和数据分析步骤，从而最大化学习成果。
同时，结合提供的免费AI网站进行学习，能够让读者在理论与实践之间实现融会贯通，更加全面地掌握核心概念。
✨ 介绍 ✨
本节内容到此结束。若需要获取本案例的源码及相关资料，可通过公众号后台私信按钮“源码获取”了解相关信息。资料中包含代码、注释、数据说明及参考文献，便于读者进一步学习和复现。合集目前包含近400篇资料，更多内容等你探索~~
如需进一步咨询或交流，也可以添加微信：deep_ML
更新的内容包含数据、代码、注释和参考资料。作者仅分享案例项目，不提供额外的答疑服务。项目中将提供详细的代码注释和丰富的解读，帮助您理解每个步骤。获取前请咨询，避免不必要的问题。

![图片](<https://mmbiz.qpic.cn/mmbiz_png/jb0kicTZHlOUoiaicvI5fZ6dYzCyovMgia8YAbYPHQT49KKLAItsNoEwLDqB5lM0ECWv37GKV2Qibia8WedFzicRt0wTPoriaUnXibmZGEKjwEWIhXl0/640?wx_fmt=png&from=appmsg&watermark=1&wxfrom=5&wx_lazy=1&tp=webp>)

✨ 淘宝店铺 ✨

![图片](<https://mmbiz.qpic.cn/mmbiz_png/cCtGVD6h9mfF6Rctm7QfnQmSdK3Ont7Uia637kIkFTdHm9wbqu8hic3qnY2jvyLRGAjInby8yOo3ejaraJ2TIoiag/640?wx_fmt=png&from=appmsg&wxfrom=5&wx_lazy=1&wx_co=1&randomid=zhcgubsw&tp=webp>)

请大家打开淘宝，进入“Python机器学习AI”，获取更多Python机器学习和AI相关的内容，希望能为您的学习之路提供帮助！
✨ 反馈 ✨

![图片](<https://mmbiz.qpic.cn/sz_mmbiz_png/jb0kicTZHlOW5As77RTgBkg99uvhzkhUgSZ7ibLvY6yjQFLkJgLX4aTaroiaZxRpv6XLm86F9Tw2DUP5N6ibGdfkq2joHuydtAx1rPtOU0Dkn3I/640?wx_fmt=png&from=appmsg&watermark=1&wxfrom=5&wx_lazy=1&tp=webp>)


![图片](<https://mmbiz.qpic.cn/sz_mmbiz_jpg/jb0kicTZHlOWuctyKgWhz92miaHHvU0whoMzgHict6LFTl5fA0S53DYupib0XN2w8eia8T52Q0JM1qTBmavTKv5mJhoIEoicZMASl9l2iaLAVJIdcQ/640?wx_fmt=jpeg&from=appmsg&watermark=1&wxfrom=5&wx_lazy=1&tp=webp>)

如果你对类似于这样的文章感兴趣。
欢迎关注、点赞、转发~
个人观点，仅供参考
