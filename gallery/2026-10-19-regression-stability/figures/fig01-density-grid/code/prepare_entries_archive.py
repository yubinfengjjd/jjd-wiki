from pathlib import Path
import json,shutil,hashlib
import numpy as np
import pandas as pd
from scipy import ndimage
from PIL import Image

HERE=Path(__file__).resolve().parent
POST=Path(r'E:\research-wiki\画廊\2026-10-19-regression-stability')
for name in ['source.md','article.html','meta.json']:shutil.copyfile(HERE/name,POST/name)
meta=json.loads((HERE/'meta.json').read_text(encoding='utf-8'))
density=POST/'figures/fig01-density-grid';boxes=POST/'figures/fig02-metric-boxplots'
params=[('XGBoost',.86,5.29,'.86','.06','10.18','2.06','6.90','1.09','.93','.03'),
('Random Forest',.85,5.59,'.86','.04','10.11','1.32','7.05','.67','.93','.02'),
('Extra Trees',.87,4.88,'.87','.04','9.89','1.63','6.81','.82','.93','.02'),
('Gradient Boosting',.87,4.96,'.86','.04','10.24','1.44','7.16','.82','.93','.02'),
('AdaBoost',.79,9.06,'.82','.05','11.57','1.47','8.56','.84','.91','.03'),
('MLP',.89,3.74,'.86','.02','10.21','.68','7.46','.56','.94','.01')]
image=np.array(Image.open(density/'source/fig01.png').convert('RGB'))
pointrows=[];histrows=[];panels=[]
for i,p in enumerate(params):
    row,col=divmod(i,3);x0=36+362*col;x1=x0+255;y0=58 if row==0 else 391;y1=y0+230
    lim=[-5,109,-5,110] if i<5 else [-5,105,-5,110]
    top=[x0,4 if row==0 else 338,x1,52 if row==0 else 385]
    right=[x1+5,y0,x1+59,y1]
    cb=[x0+205,y0+117,x0+218,y0+215]
    panel=dict(id=chr(65+i),name=p[0],slope=p[1],intercept=p[2],R2=p[3],R2_sd=p[4],RMSE=p[5],RMSE_sd=p[6],MAE=p[7],MAE_sd=p[8],r=p[9],r_sd=p[10],bbox=[x0,y0,x1,y1],limits=lim,top_bbox=top,right_bbox=right,colorbar_bbox=cb)
    panels.append(panel)
    crop=image[y0+1:y1-1,x0+1:x1-1].astype(int);r,g,b=crop[:,:,0],crop[:,:,1],crop[:,:,2]
    mask=((g-b>23)&(r-b>12))|((r-g>40)&(r-b>40))
    mask[max(0,cb[1]-y0-3):cb[3]-y0+3,cb[0]-x0-3:cb[2]-x0+3]=False
    labels,n=ndimage.label(mask)
    for label in range(1,n+1):
        ys,xs=np.where(labels==label)
        groups=[np.arange(len(xs))] if len(xs)<13 else [np.where((xs//2==gx)&(ys//2==gy))[0] for gx,gy in set(zip(xs//2,ys//2))]
        for idx in groups:
            px=float(xs[idx].mean()+x0+1);py=float(ys[idx].mean()+y0+1)
            color=crop[ys[idx],xs[idx]].mean(axis=0)
            pointrows.append(dict(panel=panel['id'],x=lim[0]+(px-x0)/(x1-x0)*(lim[1]-lim[0]),y=lim[3]-(py-y0)/(y1-y0)*(lim[3]-lim[2]),red=round(color[0]),green=round(color[1]),blue=round(color[2]),pixel_x=px,pixel_y=py,provenance='estimated',uncertain_reason='raster marks may overlap; graphical detections are not recoverable original sample IDs'))
    for orientation,bbox in [('top',top),('right',right)]:
        a,b,c,d=bbox;pix=image[b:d,a:c].astype(int);r,g,bl=pix[:,:,0],pix[:,:,1],pix[:,:,2]
        m=(r>145)&(r<205)&(g>185)&(bl>185)&(abs(g-bl)<15)&(g-r>15)
        if orientation=='top':
            for x in range(c-a):
                v=np.flatnonzero(m[:,x]);height=0 if not len(v) else (d-b-v.min())/(d-b)*40
                histrows.append(dict(panel=panel['id'],orientation=orientation,position=lim[0]+(x+.5)/(c-a)*(lim[1]-lim[0]),height=height,width=(lim[1]-lim[0])/(c-a),provenance='estimated_graphic'))
        else:
            for y in range(d-b):
                v=np.flatnonzero(m[y]);height=0 if not len(v) else (v.max()+1)/(c-a)*40
                histrows.append(dict(panel=panel['id'],orientation=orientation,position=lim[3]-(y+.5)/(d-b)*(lim[3]-lim[2]),height=height,width=(lim[3]-lim[2])/(d-b),provenance='estimated_graphic'))
pd.DataFrame(pointrows).to_csv(density/'data/estimated_data.csv',index=False)
pd.DataFrame(histrows).to_csv(density/'data/estimated_histograms.csv',index=False)
spec1=dict(kind='density',canvas_px=[1080,649],panels=panels,data_provenance='estimated',calibration='linear axis mapping from main bbox; source image pixels retained in CSV',color='source raster RGB estimates; no KDE recomputation',annotations='transcribed source labels only, not metrics recomputed from graphical detections',caption_bbox=None,quality_flags=['raster_overlap','source_annotations_rounded','source_font_unknown'])
(density/'data/figure_spec.json').write_text(json.dumps(spec1,ensure_ascii=False,indent=2),encoding='utf-8')

# Values and drawing statistics are approximate readings of visible marks, not observations.
values={
'RMSE':{'ET':[6.58,8.46,9.32,9.35,9.94,10.35,10.48,10.83,10.98,12.66],'RF':[7.86,8.59,9.28,9.89,10.12,10.30,10.75,10.76,11.10,12.50],'XGB':[6.96,7.33,9.25,9.85,10.10,10.74,11.18,11.28,12.08,13.80],'MLP':[8.63,9.70,10.03,10.16,10.23,10.33,10.55,10.69,10.74,11.10],'GB':[7.80,8.34,9.42,9.96,10.21,10.54,10.83,11.55,11.86,12.12],'AdaBoost':[9.42,10.02,10.76,11.12,11.41,11.58,11.86,12.32,12.81,14.63]},
'MAE':{'ET':[5.52,6.05,6.21,6.25,6.54,6.73,7.09,7.40,7.53,7.98],'XGB':[5.46,5.68,6.00,6.36,6.41,7.23,7.38,7.84,7.86,8.80],'RF':[6.03,6.25,6.65,6.69,7.12,7.17,7.28,7.43,7.69,8.25],'GB':[6.03,6.43,6.47,6.57,7.08,7.18,7.52,7.59,8.32,8.47],'MLP':[6.39,6.63,7.32,7.34,7.60,7.65,7.71,7.75,7.81,8.26],'AdaBoost':[7.11,7.56,8.06,8.46,8.53,8.89,9.16,9.34,9.35,9.57]},
'R2':{'ET':[.798,.818,.845,.850,.859,.868,.891,.900,.906,.949],'RF':[.803,.826,.849,.852,.864,.866,.879,.888,.909,.927],'MLP':[.799,.813,.848,.853,.855,.862,.871,.875,.878,.910],'GB':[.788,.815,.827,.838,.856,.864,.875,.881,.910,.929],'XGB':[.760,.780,.839,.843,.857,.864,.871,.902,.930,.943],'AdaBoost':[.753,.780,.828,.834,.841,.851,.856,.860,.897,.896]}}
orders={'RMSE':['ET','RF','XGB','MLP','GB','AdaBoost'],'R2':['ET','RF','MLP','GB','XGB','AdaBoost'],'MAE':['ET','XGB','RF','GB','MLP','AdaBoost']}
means={'RMSE':[10.00,10.11,10.18,10.21,10.24,11.57],'R2':[.868,.865,.864,.859,.858,.821],'MAE':[6.81,6.90,7.05,7.16,7.46,8.56]}
stats={
'RMSE':[[9.3,10.2,10.75,8.45,12.65],[9.4,10.25,10.75,7.85,12.5],[9.4,10.05,11.25,6.95,13.8],[10.1,10.22,10.6,9.7,11.1],[9.55,10.35,11.35,7.8,12.1],[10.8,11.43,12.2,9.4,12.8]],
'R2':[[.846,.862,.898,.798,.949],[.849,.859,.886,.803,.927],[.853,.865,.874,.848,.878],[.831,.866,.879,.788,.929],[.841,.859,.894,.760,.943],[.788,.837,.856,.780,.897]],
'MAE':[[6.21,6.72,7.51,5.52,7.98],[6.09,6.82,7.72,5.46,8.80],[6.66,7.05,7.42,6.03,8.25],[6.48,7.15,7.58,6.03,8.47],[7.34,7.68,7.76,7.34,8.26],[8.18,8.64,9.25,7.11,9.57]]}
ps=[];data=[];rng=np.random.default_rng(20261021)
for i,metric in enumerate(['RMSE','R2','MAE']):
    st={}
    for j,model in enumerate(orders[metric]):
        q1,med,q3,lo,hi=stats[metric][j];st[model]=dict(q1=q1,med=med,q3=q3,lo=lo,hi=hi,mean=means[metric][j])
        for k,v in enumerate(values[metric][model]):data.append(dict(metric=metric,model=model,mark=k+1,value=v,jitter=float(rng.uniform(-.11,.11)),provenance='estimated_y_synthetic_jitter',uncertain_reason='visual estimates; model/metric values cannot be paired back to original folds'))
    ps.append(dict(id=chr(65+i),metric=metric,bbox=[54+361*i,26,351+361*i,257],order=orders[metric],stats=st,
                   limits=[5.9,15.3] if metric=='RMSE' else ([.75,1.] if metric=='R2' else [5.05,10.0]),
                   ticks=[6,7.5,9,10.5,12,13.5,15] if metric=='RMSE' else ([.76,.80,.84,.88,.92,.96,1.] if metric=='R2' else [5.6,6.4,7.2,8.,8.8,9.6]),
                   title={'RMSE':'Prediction error','R2':'Explained variance','MAE':'Absolute error'}[metric],ylabel={'RMSE':'Test RMSE (SR)','R2':'Test $R^2$','MAE':'Test MAE (SR)'}[metric]))
pd.DataFrame(data).to_csv(boxes/'data/estimated_data.csv',index=False)
spec2=dict(kind='boxplots',canvas_px=[1080,315],panels=ps,data_provenance='mixed',jitter_seed=20261021,caption_bbox=None,quality_flags=['estimated_values','independently_estimated_box_geometry','source_font_unknown'],note='Box summaries, dot y values and diamonds are independent graphical readings; synthetic x jitter only. They are not a statistically consistent recovered dataset.')
(boxes/'data/figure_spec.json').write_text(json.dumps(spec2,ensure_ascii=False,indent=2),encoding='utf-8')
for entry,spec in [(density,spec1),(boxes,spec2)]:
    shutil.copyfile(HERE/'replica.py',entry/'code/replica.py')
    shutil.copyfile(HERE/'prepare_entries.py',entry/'code/prepare_entries_archive.py')
    records=[]
    for b in meta['code_blocks']:
        name=f'block-{b["index"]:02}.{b["lang"]}.txt';raw=b['code'].encode('utf-8');(entry/'original_code'/name).write_bytes(raw)
        records.append(dict(file=name,sha256=hashlib.sha256(raw).hexdigest(),original_language=b['lang'],executed=False))
    (entry/'original_code/manifest.json').write_text(json.dumps(dict(disposition='archived_only',missing=['Excel data','plot_observed_predicted','plot_prediction_error','OOF/model evaluation generation'],blocks=records),ensure_ascii=False,indent=2),encoding='utf-8')
    m=json.loads((entry/'meta.json').read_text(encoding='utf-8'));m['data_provenance']=spec['data_provenance'];m['figure']['panel_map']={p['id']:m['figure']['chart_types'][0] for p in spec['panels']};m['figure']['caption']='图形复刻；估读数据与原帖标注，仅供个人研究参考，待作者目视签核。';m['files'].update(code='code/replica.py',data='data/estimated_data.csv',spec='data/figure_spec.json',replica='output/replica.png',pdf='output/replica.pdf',svg='output/replica.svg',compare='compare/side_by_side.png',thumbnail='thumb.png',readme='README.md');(entry/'meta.json').write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding='utf-8')
    kind='六模型预测密度散点（含边缘直方图）' if spec['kind']=='density' else 'RMSE、R²、MAE 三指标箱线图'
    (entry/'README.md').write_text(f'''# {kind}

来源：[Python机器学习AI，2026-10-19]({meta['url']})。原文位于帖子根目录 source.md / article.html；原图只读保存在 source/。作者本轮选择只复刻两张组图，不另建单图条目。

## 来源与状态

- status=draft（完成渲染与检查后进入 review）；仅作者签核后才可 approved。
- code_provenance=reconstructed：code/replica.py 为本次新写代码。original_code_provenance=archived_only：7段原帖代码按序与原语言标签归档，SHA-256 见 original_code/manifest.json，全部未执行。
- 缺少原始Excel、两个绘图函数、折外预测生成和六模型评估代码；没有训练模型，没有恢复原始观测。
- data_provenance={spec['data_provenance']}。散点坐标、颜色和直方图高度来自原图线性像素估读，遮挡点不能逐样本恢复。箱线图数据、箱体和均值菱形是独立视觉估读；横向抖动为固定种子合成。
- 所有数据仅供图形复刻，不能作为原始样本、折指标或统计推断。注释照录原图的舍入数值，不是根据估读点重新计算的结果。图形中原有 Frequency 色标保留，原始归一化未知，不能据其解释实际频数。

## 适用

连续结局回归任务，展示同一验证设计下多模型的预测一致性及逐折误差分布。真实课题应输入真实折外/留出预测和指标，详见知识库方法 regression-resampling-evaluation。

## 不适用

分类或生存结局、直接证明临床效用/外部泛化、把相关折作为独立实验、根据这些估读数据做显著性检验；没有验证预测时不能将训练回代图称为 OOF。

## 运行

专用 Python：C:/Users/86186/.codex/venvs/sci-figure-replica/Scripts/python.exe。运行 `python -X utf8 code/replica.py`（实际调用须使用前述绝对解释器）。参数、轴校准、图框、原图标注及数据分类位于 data/figure_spec.json；CSV 可审阅。

输出为 output/replica.png（600 dpi）、PDF、SVG，compare/side_by_side.png 为等高并排；运行命令和退出码见 run.log，版本/字体见 stdout.txt。制图使用 Arial，源字体文件未知。

## 关键限制

估读误差、点遮挡和合成抖动使本次只能作视觉近似。箱体统计与点读数分别保存，不能冒称精确恢复一致的10折数据。源图无 A-F / A-C 字母，元数据仅为面板路由分配逻辑编号；复刻不添加新字母。独立PDF/SVG视觉检查范围见 qa_report.md。未获得作者签核。
''',encoding='utf-8')
print('Prepared exactly two entries.',len(pointrows),'detected graphical scatter marks;',len(data),'boxplot dot estimates')
