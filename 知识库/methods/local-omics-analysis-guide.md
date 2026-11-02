---
type: method
id: local-omics-analysis-guide
title: 组学课题方法去重与选择
status: draft
tags:
- single-cell
- transcriptomics
- multi-omics
inputs: []
outputs: []
source:
  kind: written
license: LicenseRef-Project-Unresolved
cite:
- 作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256
  账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
favorite: false
method_kind: technical
summary: 保留原算法的原生函数、显式依赖调用与逐用例运行清单；知识分类、科学验证和独立迁移分别记录。
keywords:
- '%||%'
- .element_line_compat
- .element_rect_compat
- .rename_last_col
- .unit
- Addsingscore
- Augur
- CalPredictScore
- CellChat
- ConsensusClusterPlus
- DotPlotScores
- DynamicPlotMonocle2
- ExtractVar
- GMM-LR
- MBDs
- Mclust
- PTMD
- PredictClass
- RRA
- RunEnet
- RunEval
- RunGBM
- RunLDA
- RunLasso
- RunML
- RunNaiveBayes
- RunRF
- RunRidge
- RunSVM
- RunStepglm
- RunXGBoost
- RunglmBoost
- RunplsRglm
- SimpleHeatmap
- UC-20种修饰
- WGCNA
- align_meta_to_expr
- analyze_gene_set
- analyze_module
- analyze_single_sample
- as_dgC
- assign_epi_high_low
- bin_by_quantile
- bootstrap_ci_auc
- broad_class
- build_domain_plot
- build_focal_spatial_panel
- build_focal_spatial_plot
- build_focal_spatial_specs
- build_group_palette
- build_high_low_diff_table
- build_summary_plot
- calc_p_value
- center_focus_levels
- compute_domain_display_spec
- compute_focal_limits
- compute_meanExpr
- compute_neighborhood
- compute_nhood
- compute_spatial_lr
- create_cellchat
- create_optimized_corr_plot
- detect_annotation_column
- detect_assay
- detect_sample_column
- detect_weight_columns
- display.progress
- display_ct
- draw_confusion_matrix
- ensure_output_dirs
- estimate_density
- eval_binary
- evaluate_quality
- extract_epithelial_from_seurat
- extract_feature_values
- extract_input
- extract_scale_factors
- extract_tables_from_cellchat
- fcex
- fcolor
- filter_and_select_genes
- find_cell_type
- find_celltype_column
- generate_combinations
- generate_formulas
- generate_plot
- generate_violin_with_p
- get_expr_matrix
- get_spatial_xy
- gini_index
- guess_cat
- guess_genes_by_cells
- guide_colorbar_paper
- guide_legend_paper
- hdWGCNA
- infer_species
- irGSEA
- is_hit
- is_integerish
- is_seurat_obj
- is_valid_combination
- label_wrap_paper
- log_message
- log_msg
- make_corrected_group_map
- make_custom_bubble
- make_feature_map
- make_group_map
- make_heatmap_plot
- make_reference_bubble
- make_samplewise_pathway_plot
- make_term2gene
- mfuzz_plot
- native_combinations
- native_gini
- native_gmt
- native_normalize
- normalize
- normalize_diffreg
- normalize_weight_table
- panel_label
- panel_output_root
- parse_ratio_to_numeric
- pick
- pick_col
- pick_focal_celltypes
- pick_ko_gene
- pick_matrix
- pick_seurat
- plot_bubble_refined
- plot_cluster_auc_with_density
- plot_compact_linket
- plot_correlation
- plot_gene_expression_state
- plot_guard
- plot_premium_bubble
- plot_ptm_bubble
- plot_spatial_aggregate_spots
- plot_spatial_pathway_premium
- plot_state_violin
- plot_subtype_pathways
- plot_with_statistics
- pred_fun
- preprocess_data
- process_alignment
- process_exprset
- process_single_file
- qc_feature_labels
- qc_feature_param
- quiet
- read_folder_gmt
- read_spatial_sample
- recover_rctd_weight_exports
- render_spatial_pathway_literal
- required_pkgs
- run_knk
- run_local_r_function
- run_models_and_calculate_auc
- run_models_caret
- safe_capture
- safe_md5
- save_base_plot
- save_fig
- save_figure
- save_gg
- save_gg_to_dir
- save_heatmap_to_dir
- save_pdf_only
- scTenifoldKnk
- scaleData
- scale_mse_to_r2
- scale_r2_to_mse
- scale_size_summary_paper
- select_hvgs
- select_top10_paths
- seurat_to_monocle
- short_celltype_label
- split_id
- split_one
- standarize.fun
- start_phase_log
- summary_breaks_paper
- theme_paper
- time_it
- triangle
- try_adjust_nc_q
- tune_signaling_role_heatmap
- wf_binary_group
- wf_copy_pdf_png
- wf_copy_single_panel_pdf_png
- wf_detect_celltype_cols
- wf_display_label
- wf_export_spatial_composites
- wf_format_p_value
- wf_get_spacexr_export
- wf_group_palette
- wf_heatmap_save
- wf_local_root
- wf_make_simple_network_plot
- wf_manifest_add
- wf_manifest_init
- wf_manifest_write
- wf_md5
- wf_named_palette
- wf_order_discrete_levels
- wf_pdf_info_safe
- wf_plot_scatter_ref1_style
- wf_plot_spatial_binary
- wf_plot_spatial_continuous
- wf_plot_spatial_discrete
- wf_plot_spatial_feature_ref1_style
- wf_plot_spatial_structure_ref2_style
- wf_prepare_spacexr_vendor
- wf_pretty_breaks
- wf_pretty_limits
- wf_project_palette
- wf_read_gmt
- wf_ref2_bubble_palette
- wf_sample_label
- wf_sanitize_stem
- wf_scale01
- wf_scale_fill_ref2_bubble
- wf_scatter_ref1_palette
- wf_scatter_stats_label
- wf_set_seed
- wf_spatial_backdrop_df
- wf_spatial_celltype_palette
- wf_spatial_df
- wf_spatial_domain_palette
- wf_spatial_ref1_spec
- wf_spatial_ref2_spec
- wf_step_dirs
- wf_step_root
- wf_theme_bubble_ref2
- wf_theme_scatter_ref1
- wf_with_subplot_title
- wf_wrap_grouped_panel
- write_csv_safe
- write_json_safe
- write_lines_safe
- write_text
- youden_threshold
- 五分数求和
- 哮喘乳酸化单细胞开篇
- 语义去重
data_contract:
  input: 原函数显式 arguments/bindings、真实 Seurat/结果对象，或上游预计算曲线与 AUC；文件/输出目录由调用者给定。
  output: 原生计算/绘图值和诊断，或明确阶段的原生工作流；各实现仅以自己的当前收据授予运行证据。
implementations:
- id: native-library
  title: 原生函数目录与显式绑定入口
  language: R
  entrypoint: code/native.R:run_local_r_function
  dependencies: []
  verification: verification/native-library-algorithm.json
- id: native-normalize
  title: 原生函数 normalize
  language: R
  entrypoint: code/native_cases.R:native_normalize
  dependencies: []
  verification: verification/native-normalize-algorithm.json
- id: native-gini
  title: 原生函数 gini_index
  language: R
  entrypoint: code/native_cases.R:native_gini
  dependencies: []
  verification: verification/native-gini-algorithm.json
- id: native-combinations
  title: 原生函数 generate_combinations
  language: R
  entrypoint: code/native_cases.R:native_combinations
  dependencies: []
  verification: verification/native-combinations-algorithm.json
- id: native-gmt
  title: 原生函数 wf_read_gmt
  language: R
  entrypoint: code/native_cases.R:native_gmt
  dependencies: []
  verification: verification/native-gmt-algorithm.json
- id: native-dynamic
  title: 原生函数 DynamicPlotMonocle2
  language: R
  entrypoint: code/native_cases.R:native_dynamic
  dependencies:
  - Seurat
  - SeuratObject
  - ggplot2
  - rlang
  - mgcv
  - patchwork
  - ggnewscale
  - RColorBrewer
  verification: verification/native-dynamic-algorithm.json
- id: native-score-dot
  title: 原生函数 DotPlotScores
  language: R
  entrypoint: code/native_cases.R:native_score_dot
  dependencies:
  - Seurat
  - SeuratObject
  - ggplot2
  - rlang
  - cowplot
  verification: verification/native-score-dot-algorithm.json
- id: native-cellchat
  title: 原生函数 create_cellchat
  language: R
  entrypoint: code/native_cases.R:native_cellchat
  dependencies:
  - CellChat
  verification: verification/native-cellchat-algorithm.json
- id: native-singscore
  title: 原生函数 Addsingscore
  language: R
  entrypoint: code/native_cases.R:native_singscore
  dependencies:
  - Seurat
  - singscore
  - dplyr
  - purrr
  - stringr
  - magrittr
  verification: verification/native-singscore-algorithm.json
- id: irgsea-score
  title: 依赖分析调用 irgsea_score
  language: R
  entrypoint: code/dependency_analysis.R:run_omics_dependency_analysis
  dependencies:
  - irGSEA
  verification: verification/irgsea-score-algorithm.json
- id: irgsea-integrate
  title: 依赖分析调用 irgsea_integrate
  language: R
  entrypoint: code/dependency_analysis.R:run_omics_dependency_analysis
  dependencies:
  - irGSEA
  verification: verification/irgsea-integrate-algorithm.json
- id: consensus-cluster
  title: 依赖分析调用 consensus_cluster
  language: R
  entrypoint: code/dependency_analysis.R:run_omics_dependency_analysis
  dependencies:
  - ConsensusClusterPlus
  verification: verification/consensus-cluster-algorithm.json
- id: cellchat-create
  title: 依赖分析调用 cellchat_create
  language: R
  entrypoint: code/dependency_analysis.R:run_omics_dependency_analysis
  dependencies:
  - CellChat
  verification: verification/cellchat-create-algorithm.json
- id: gsva-call
  title: 依赖分析调用 gsva
  language: R
  entrypoint: code/dependency_analysis.R:run_omics_dependency_analysis
  dependencies:
  - GSVA
  verification: verification/gsva-call-algorithm.json
- id: py-eval-binary
  title: 原生模型评价 eval_binary
  language: Python
  entrypoint: code/binary_evaluation.py:eval_binary
  dependencies:
  - numpy
  - scikit-learn
  verification: verification/py-eval-binary-algorithm.json
- id: py-compute-specificity
  title: 原生模型评价 compute_specificity
  language: Python
  entrypoint: code/binary_evaluation.py:compute_specificity
  dependencies:
  - numpy
  - scikit-learn
  verification: verification/py-compute-specificity-algorithm.json
- id: py-youden-threshold
  title: 原生模型评价 youden_threshold
  language: Python
  entrypoint: code/binary_evaluation.py:youden_threshold
  dependencies:
  - numpy
  - scikit-learn
  verification: verification/py-youden-threshold-algorithm.json
- id: py-bootstrap-ci-auc
  title: 原生模型评价 bootstrap_ci_auc
  language: Python
  entrypoint: code/binary_evaluation.py:bootstrap_ci_auc
  dependencies:
  - numpy
  - scikit-learn
  verification: verification/py-bootstrap-ci-auc-algorithm.json
- id: py-get-proba
  title: 原生模型评价 get_proba
  language: Python
  entrypoint: code/binary_evaluation.py:get_proba
  dependencies:
  - numpy
  - scikit-learn
  verification: verification/py-get-proba-algorithm.json
- id: stacking-cli
  title: 显式文件与阶段的原生模型工作流
  language: Python
  entrypoint: code/stacking_runner.py:run_stacking_cli
  dependencies:
  - numpy
  - pandas
  - scikit-learn
  - joblib
  - matplotlib
  - scikit-optimize
  verification: verification/stacking-cli-algorithm.json
---
# 组学课题方法去重与选择

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：LicenseRef-Project-Unresolved
- 引用：作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256 账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
- 标签：single-cell、transcriptomics、multi-omics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/local-omics-analysis-guide/code/binary_evaluation.py](/files/wiki/methods/local-omics-analysis-guide/code/binary_evaluation.py) · [methods/local-omics-analysis-guide/code/dependency_analysis.R](/files/wiki/methods/local-omics-analysis-guide/code/dependency_analysis.R) · [methods/local-omics-analysis-guide/code/native/005e3b6e0da31c6fce6fec8edb8cfe9da746809a9330fcdd6891da934fc03d69.R](/files/wiki/methods/local-omics-analysis-guide/code/native/005e3b6e0da31c6fce6fec8edb8cfe9da746809a9330fcdd6891da934fc03d69.R) · [methods/local-omics-analysis-guide/code/native/015dce1b17c37f520b68f403a37b24fcfe60e4c2a23e307a0ef345b71c44e8e6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/015dce1b17c37f520b68f403a37b24fcfe60e4c2a23e307a0ef345b71c44e8e6.R) · [methods/local-omics-analysis-guide/code/native/022a1442147525175c1ad454b1eb39d7398a397d6f8a758df5e12fb5386eb90f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/022a1442147525175c1ad454b1eb39d7398a397d6f8a758df5e12fb5386eb90f.R) · [methods/local-omics-analysis-guide/code/native/0242c861726a7ba77f8d153415da6ed2656802955e792074e3834a80259f873a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0242c861726a7ba77f8d153415da6ed2656802955e792074e3834a80259f873a.R) · [methods/local-omics-analysis-guide/code/native/03c9807bf161adf246059efda7c80b493f6f942c53eb811b551c37331c58a717.R](/files/wiki/methods/local-omics-analysis-guide/code/native/03c9807bf161adf246059efda7c80b493f6f942c53eb811b551c37331c58a717.R) · [methods/local-omics-analysis-guide/code/native/04c061f09053c0ec35ffb48c388aa8dbfff2f5803597ae70a9a886bb63542ac8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/04c061f09053c0ec35ffb48c388aa8dbfff2f5803597ae70a9a886bb63542ac8.R) · [methods/local-omics-analysis-guide/code/native/0560f296814ded7f7253a154fff450a6f94e8402c08bd3b42c6242894d5ed523.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0560f296814ded7f7253a154fff450a6f94e8402c08bd3b42c6242894d5ed523.R) · [methods/local-omics-analysis-guide/code/native/064b033d0b091aecb331da6056eb1d829ada45a8daaa48c4599bde9335a8ac59.R](/files/wiki/methods/local-omics-analysis-guide/code/native/064b033d0b091aecb331da6056eb1d829ada45a8daaa48c4599bde9335a8ac59.R) · [methods/local-omics-analysis-guide/code/native/06562e21736039850bfabea89170ff9dd2330619c4f72913acd8000af5481712.R](/files/wiki/methods/local-omics-analysis-guide/code/native/06562e21736039850bfabea89170ff9dd2330619c4f72913acd8000af5481712.R) · [methods/local-omics-analysis-guide/code/native/089a256d38b54f3621454c4cd99822f342bffe18a50aa5d6113bcee1b3195f35.R](/files/wiki/methods/local-omics-analysis-guide/code/native/089a256d38b54f3621454c4cd99822f342bffe18a50aa5d6113bcee1b3195f35.R) · [methods/local-omics-analysis-guide/code/native/0b8ac3af35bfa352d2c4eeeb26eefcc8bbb73ae1ef23259493ffa49c9001ed6d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0b8ac3af35bfa352d2c4eeeb26eefcc8bbb73ae1ef23259493ffa49c9001ed6d.R) · [methods/local-omics-analysis-guide/code/native/0c184a19805434270b9ca2e3d9b70fb2f43249ba42404471df594098c69b7fa6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0c184a19805434270b9ca2e3d9b70fb2f43249ba42404471df594098c69b7fa6.R) · [methods/local-omics-analysis-guide/code/native/0c233a3f33517de54bb91d675cfa040b6939ff1a2ad9d53aa9008dae54157ae7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0c233a3f33517de54bb91d675cfa040b6939ff1a2ad9d53aa9008dae54157ae7.R) · [methods/local-omics-analysis-guide/code/native/0c364778b96d3d4d22993861240f0795f55686bd979f318856d1378f0cc06398.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0c364778b96d3d4d22993861240f0795f55686bd979f318856d1378f0cc06398.R) · [methods/local-omics-analysis-guide/code/native/0eb46fdc1bc75ad3290cd0b827ff5117dbed7fb4908b50049cf71c37ea3dce67.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0eb46fdc1bc75ad3290cd0b827ff5117dbed7fb4908b50049cf71c37ea3dce67.R) · [methods/local-omics-analysis-guide/code/native/0f084bf1693533a333e62e936fef0e13e190fa8d4da3af67c97756d915d7a07c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0f084bf1693533a333e62e936fef0e13e190fa8d4da3af67c97756d915d7a07c.R) · [methods/local-omics-analysis-guide/code/native/0f5be904cfcf82cffeb282b8e87e53ba94e74847e1b41299a276a90cb715922b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/0f5be904cfcf82cffeb282b8e87e53ba94e74847e1b41299a276a90cb715922b.R) · [methods/local-omics-analysis-guide/code/native/11e5371144a140ea63da535d1b2c9b4d0a8808923ee2794fb9670c72ac2d8075.R](/files/wiki/methods/local-omics-analysis-guide/code/native/11e5371144a140ea63da535d1b2c9b4d0a8808923ee2794fb9670c72ac2d8075.R) · [methods/local-omics-analysis-guide/code/native/11e60624eac938f607d8d12eedde494df5949ecaf1e5afc3cb326938119ce287.R](/files/wiki/methods/local-omics-analysis-guide/code/native/11e60624eac938f607d8d12eedde494df5949ecaf1e5afc3cb326938119ce287.R) · [methods/local-omics-analysis-guide/code/native/12781c7c74fa39acf9e2e2d2438a848162897d5031904026e6692eeec2b55bf4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/12781c7c74fa39acf9e2e2d2438a848162897d5031904026e6692eeec2b55bf4.R) · [methods/local-omics-analysis-guide/code/native/131151df47776a5dd75db24825d275902619b42d83bb4def8174afd4b006e538.R](/files/wiki/methods/local-omics-analysis-guide/code/native/131151df47776a5dd75db24825d275902619b42d83bb4def8174afd4b006e538.R) · [methods/local-omics-analysis-guide/code/native/138f91cca60e41b7fbd4c9be561a7997fd9b632878bad9c752350b41a5db5147.R](/files/wiki/methods/local-omics-analysis-guide/code/native/138f91cca60e41b7fbd4c9be561a7997fd9b632878bad9c752350b41a5db5147.R) · [methods/local-omics-analysis-guide/code/native/147160dfe91feac3d4d9b3942b3a2478d89fc2cd9b8e6f1ab20e2aab6e8cf51a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/147160dfe91feac3d4d9b3942b3a2478d89fc2cd9b8e6f1ab20e2aab6e8cf51a.R) · [methods/local-omics-analysis-guide/code/native/15898d6ecaff923bec17abfe31da38cd1653accca2454ff64823ef1e08aff1b0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/15898d6ecaff923bec17abfe31da38cd1653accca2454ff64823ef1e08aff1b0.R) · [methods/local-omics-analysis-guide/code/native/1617dabb88b3836075dd9bceba9a2256bc73f43b59d603d5e3c3a9ea6b2f6ada.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1617dabb88b3836075dd9bceba9a2256bc73f43b59d603d5e3c3a9ea6b2f6ada.R) · [methods/local-omics-analysis-guide/code/native/16684ed2c1d3c84b9495d058336d3578c9e4eca267d5df12ac6a71ab17e36a1e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/16684ed2c1d3c84b9495d058336d3578c9e4eca267d5df12ac6a71ab17e36a1e.R) · [methods/local-omics-analysis-guide/code/native/1722fd1e7d2b82b6e8cbf345d57b4310990079812d7fbe3bcd32c4e29e2082d2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1722fd1e7d2b82b6e8cbf345d57b4310990079812d7fbe3bcd32c4e29e2082d2.R) · [methods/local-omics-analysis-guide/code/native/17cfb35d919667817e7ee7a12c0fe4de793299061a159a7fccdf30741fab4ed8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/17cfb35d919667817e7ee7a12c0fe4de793299061a159a7fccdf30741fab4ed8.R) · [methods/local-omics-analysis-guide/code/native/1813962b31575ec079a76df03628a60d3dfd3a24bc296b9744424c49b860b994.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1813962b31575ec079a76df03628a60d3dfd3a24bc296b9744424c49b860b994.R) · [methods/local-omics-analysis-guide/code/native/18c3734d54835bcf2b94aa6a11b336a1ca36717c67fb05f3dfdd7de5946237b4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/18c3734d54835bcf2b94aa6a11b336a1ca36717c67fb05f3dfdd7de5946237b4.R) · [methods/local-omics-analysis-guide/code/native/1905c57ce8cfe131e6a4c69960f49b9ede4ce2d3483395a1e6cd0de0cb3dbed1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1905c57ce8cfe131e6a4c69960f49b9ede4ce2d3483395a1e6cd0de0cb3dbed1.R) · [methods/local-omics-analysis-guide/code/native/1a013c329dfe2052da07554a679acdb3f8a447dcc996a0a533025d81c198c0b8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1a013c329dfe2052da07554a679acdb3f8a447dcc996a0a533025d81c198c0b8.R) · [methods/local-omics-analysis-guide/code/native/1bff60fcb6ea63e914f0ae7ecfb5e2d821759d32de364ed39f6ac97dab748966.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1bff60fcb6ea63e914f0ae7ecfb5e2d821759d32de364ed39f6ac97dab748966.R) · [methods/local-omics-analysis-guide/code/native/1c542e2459c0c9f996b0c485239b792f5b1a671ee1bf55023de6dc657f5f9b91.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1c542e2459c0c9f996b0c485239b792f5b1a671ee1bf55023de6dc657f5f9b91.R) · [methods/local-omics-analysis-guide/code/native/1ca615892b2b5f4db85322ee69e25a8afdbf1c6c993b33e73a3c4d2cea7f4aef.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1ca615892b2b5f4db85322ee69e25a8afdbf1c6c993b33e73a3c4d2cea7f4aef.R) · [methods/local-omics-analysis-guide/code/native/1d09d5e713f25fbabc0fecdd956268979dd7af96a682225a5a1587ee8ba51d26.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1d09d5e713f25fbabc0fecdd956268979dd7af96a682225a5a1587ee8ba51d26.R) · [methods/local-omics-analysis-guide/code/native/1d3e3383eeca9e27539e2e993cfd9bb1840a936b6fd145642da5158fb0b0a415.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1d3e3383eeca9e27539e2e993cfd9bb1840a936b6fd145642da5158fb0b0a415.R) · [methods/local-omics-analysis-guide/code/native/1d71ee7280fdfb228fd56119af9b46ce286b502089b233b5fe00854d15694bdb.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1d71ee7280fdfb228fd56119af9b46ce286b502089b233b5fe00854d15694bdb.R) · [methods/local-omics-analysis-guide/code/native/1d88144d842ae3eb085e102af8b0c95395d8708999ae843682c6a289c9d7795d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1d88144d842ae3eb085e102af8b0c95395d8708999ae843682c6a289c9d7795d.R) · [methods/local-omics-analysis-guide/code/native/1dba6b74c2332441d59f27fbb63a76179e774e6e7fc158ed175feef11bc2e6ba.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1dba6b74c2332441d59f27fbb63a76179e774e6e7fc158ed175feef11bc2e6ba.R) · [methods/local-omics-analysis-guide/code/native/1e33418c986a30eaef8935fc31643c1161af7001991ad7c9e3d8369873132a51.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1e33418c986a30eaef8935fc31643c1161af7001991ad7c9e3d8369873132a51.R) · [methods/local-omics-analysis-guide/code/native/1e576440bd6f0f7a7eaaf5937a82c9bb4bf35e12037e54d54a5e3086ef820c3c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/1e576440bd6f0f7a7eaaf5937a82c9bb4bf35e12037e54d54a5e3086ef820c3c.R) · [methods/local-omics-analysis-guide/code/native/204658cc6934ed231559ffb93b828a81cc0f20a5cb93e8166964e73df3847c4c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/204658cc6934ed231559ffb93b828a81cc0f20a5cb93e8166964e73df3847c4c.R) · [methods/local-omics-analysis-guide/code/native/209b0d7f55a5e824e509f192e71d02369c265f984ddcaa4f41d04e86789d85b6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/209b0d7f55a5e824e509f192e71d02369c265f984ddcaa4f41d04e86789d85b6.R) · [methods/local-omics-analysis-guide/code/native/20a96f88c0080f99d159e8a51d767111fd23436106f78c2c1254cec2a39266b0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/20a96f88c0080f99d159e8a51d767111fd23436106f78c2c1254cec2a39266b0.R) · [methods/local-omics-analysis-guide/code/native/21476f89016f4816f6ba05bc740545521ae8093c91c37c74b96921bf5db94f2b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/21476f89016f4816f6ba05bc740545521ae8093c91c37c74b96921bf5db94f2b.R) · [methods/local-omics-analysis-guide/code/native/21cf5263528a3830cae1f79ab29d8df59087694075b60ab2b1dabc737c3ff375.R](/files/wiki/methods/local-omics-analysis-guide/code/native/21cf5263528a3830cae1f79ab29d8df59087694075b60ab2b1dabc737c3ff375.R) · [methods/local-omics-analysis-guide/code/native/221dd2eb9eea04e85f488f65471349d05b8c27b5f195134411b9bbfc83026c31.R](/files/wiki/methods/local-omics-analysis-guide/code/native/221dd2eb9eea04e85f488f65471349d05b8c27b5f195134411b9bbfc83026c31.R) · [methods/local-omics-analysis-guide/code/native/230e658705d0eabe161088b5e94a739b78bd0df96953d5de7a9c170fb8f283fc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/230e658705d0eabe161088b5e94a739b78bd0df96953d5de7a9c170fb8f283fc.R) · [methods/local-omics-analysis-guide/code/native/2415b901fb77a52fb99996c0b41a4a9a49b9de677cd8fedcc973a7e54d2f7c67.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2415b901fb77a52fb99996c0b41a4a9a49b9de677cd8fedcc973a7e54d2f7c67.R) · [methods/local-omics-analysis-guide/code/native/254d39a51eaf8705fec0384dc9a33dc67b3cd189f54c85912ab17ae9fe5e3606.R](/files/wiki/methods/local-omics-analysis-guide/code/native/254d39a51eaf8705fec0384dc9a33dc67b3cd189f54c85912ab17ae9fe5e3606.R) · [methods/local-omics-analysis-guide/code/native/26015c3647c3125bf056def90fe423d632c4f90e9059827744a153bc8d7de42c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/26015c3647c3125bf056def90fe423d632c4f90e9059827744a153bc8d7de42c.R) · [methods/local-omics-analysis-guide/code/native/262707869de1d893b9ee92ba56f7625923ffe7b4521dd04282f386fb525f1b3b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/262707869de1d893b9ee92ba56f7625923ffe7b4521dd04282f386fb525f1b3b.R) · [methods/local-omics-analysis-guide/code/native/2675bfb272163716e36b2730c009fc5803a94a49dd17f426e29ce25699e8758c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2675bfb272163716e36b2730c009fc5803a94a49dd17f426e29ce25699e8758c.R) · [methods/local-omics-analysis-guide/code/native/270aad55f00e01dee5df2a7eb59088de3098b398954760ea8b0370c2f4616118.R](/files/wiki/methods/local-omics-analysis-guide/code/native/270aad55f00e01dee5df2a7eb59088de3098b398954760ea8b0370c2f4616118.R) · [methods/local-omics-analysis-guide/code/native/28fc32bbd1226eee23dc3bf3058d4937831507c34f94eb54a4227b6601c56492.R](/files/wiki/methods/local-omics-analysis-guide/code/native/28fc32bbd1226eee23dc3bf3058d4937831507c34f94eb54a4227b6601c56492.R) · [methods/local-omics-analysis-guide/code/native/2912eba493941bc6feeeb2d59bc366243de956b0f5fed3c5ecdd4565d8196a6f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2912eba493941bc6feeeb2d59bc366243de956b0f5fed3c5ecdd4565d8196a6f.R) · [methods/local-omics-analysis-guide/code/native/294aa9471a3cbcb5697d70aaad6691b0315bce76a3aa1a77f2fafa898b520d05.R](/files/wiki/methods/local-omics-analysis-guide/code/native/294aa9471a3cbcb5697d70aaad6691b0315bce76a3aa1a77f2fafa898b520d05.R) · [methods/local-omics-analysis-guide/code/native/2953bb4d85c77cf7d7fb9e1e1ca5efd43f3d330b72f3dcc52b27cf38cec7174a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2953bb4d85c77cf7d7fb9e1e1ca5efd43f3d330b72f3dcc52b27cf38cec7174a.R) · [methods/local-omics-analysis-guide/code/native/2a8c09a35aabcbb7840c70b5bb933badc6cbe7c969254b12357f88df14013611.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2a8c09a35aabcbb7840c70b5bb933badc6cbe7c969254b12357f88df14013611.R) · [methods/local-omics-analysis-guide/code/native/2b6b0f898b340d3e78243f04f03c793387f304efe3420074d97efb14ffa30c8d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2b6b0f898b340d3e78243f04f03c793387f304efe3420074d97efb14ffa30c8d.R) · [methods/local-omics-analysis-guide/code/native/2ceb09b7b7f3f351d3ece6f22f79488e30b162c6155adfc811dc8efd2c9f9bfe.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2ceb09b7b7f3f351d3ece6f22f79488e30b162c6155adfc811dc8efd2c9f9bfe.R) · [methods/local-omics-analysis-guide/code/native/2edfb77678ff8621f7b0960c7252abd20a63face1970ff16f60f1dcb1e6769ae.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2edfb77678ff8621f7b0960c7252abd20a63face1970ff16f60f1dcb1e6769ae.R) · [methods/local-omics-analysis-guide/code/native/2ef0f02f48976fc89026fb030a054d5c88b34b3e9c922fa15e27260bfdf2cff2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2ef0f02f48976fc89026fb030a054d5c88b34b3e9c922fa15e27260bfdf2cff2.R) · [methods/local-omics-analysis-guide/code/native/2ef7abc722f3b28cac2dab206768b4f6568bc78fd8f5a53b005ce7317d820a6e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2ef7abc722f3b28cac2dab206768b4f6568bc78fd8f5a53b005ce7317d820a6e.R) · [methods/local-omics-analysis-guide/code/native/2f0b0c62defc869918ba28f1d3a0ab6ecac66a79e5365fef94621d68f48b4858.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2f0b0c62defc869918ba28f1d3a0ab6ecac66a79e5365fef94621d68f48b4858.R) · [methods/local-omics-analysis-guide/code/native/2f2828420839d9260954139b08b2b7016afd9edd7e8a5a425f5d156ceb35821b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2f2828420839d9260954139b08b2b7016afd9edd7e8a5a425f5d156ceb35821b.R) · [methods/local-omics-analysis-guide/code/native/2fc285fc68dc6b537977ad7ccfb8bfc38b02ba41181da06682834e896bcd84e1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/2fc285fc68dc6b537977ad7ccfb8bfc38b02ba41181da06682834e896bcd84e1.R) · [methods/local-omics-analysis-guide/code/native/30038a91542b784e8052fcb6dafb4b35a7f9399cac1859d3deef5f7ce0e980f6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/30038a91542b784e8052fcb6dafb4b35a7f9399cac1859d3deef5f7ce0e980f6.R) · [methods/local-omics-analysis-guide/code/native/308f1706d3684137ea6fc599bcbca308d4ea3f126bd999d5f1f67dc355ce7416.R](/files/wiki/methods/local-omics-analysis-guide/code/native/308f1706d3684137ea6fc599bcbca308d4ea3f126bd999d5f1f67dc355ce7416.R) · [methods/local-omics-analysis-guide/code/native/31854cf2d6bf16f049f7f0989b143671b2e95f8d31c892cb2b158757f297e0ca.R](/files/wiki/methods/local-omics-analysis-guide/code/native/31854cf2d6bf16f049f7f0989b143671b2e95f8d31c892cb2b158757f297e0ca.R) · [methods/local-omics-analysis-guide/code/native/3296c867cc50527264ed69d439b75a302be18bf6ef8548a1daecc0b53bd1b635.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3296c867cc50527264ed69d439b75a302be18bf6ef8548a1daecc0b53bd1b635.R) · [methods/local-omics-analysis-guide/code/native/3422650d515acc5e9ff42662541177edbedc2c18cb106f96a19a3916116928e0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3422650d515acc5e9ff42662541177edbedc2c18cb106f96a19a3916116928e0.R) · [methods/local-omics-analysis-guide/code/native/363a068dc70768490a0ac2909ff9f8167ef0d4d9473b5ade5733904b4f61eb5b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/363a068dc70768490a0ac2909ff9f8167ef0d4d9473b5ade5733904b4f61eb5b.R) · [methods/local-omics-analysis-guide/code/native/36d9d9216bd1640250ff6aace701faab3d6dd54a4396977c928715d90ec547ac.R](/files/wiki/methods/local-omics-analysis-guide/code/native/36d9d9216bd1640250ff6aace701faab3d6dd54a4396977c928715d90ec547ac.R) · [methods/local-omics-analysis-guide/code/native/3799ef5c6e9a3249f19614e83635c9b3cbeb7141daa6aae8a6f0085a983bf5b1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3799ef5c6e9a3249f19614e83635c9b3cbeb7141daa6aae8a6f0085a983bf5b1.R) · [methods/local-omics-analysis-guide/code/native/37f4a52a2a660ab7109cfe2d313eaa738eaf8227fc9d1265f854fb211dad084b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/37f4a52a2a660ab7109cfe2d313eaa738eaf8227fc9d1265f854fb211dad084b.R) · [methods/local-omics-analysis-guide/code/native/38efd566f4b9159ffdddc861a54cc9156403e872cf3005ae3d0adc503444dd4e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/38efd566f4b9159ffdddc861a54cc9156403e872cf3005ae3d0adc503444dd4e.R) · [methods/local-omics-analysis-guide/code/native/398c7c6e612e561a1f80d9039a2c8ce938369ec03ac89942d2cd41815fc52e2c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/398c7c6e612e561a1f80d9039a2c8ce938369ec03ac89942d2cd41815fc52e2c.R) · [methods/local-omics-analysis-guide/code/native/39a7387880a79cc2bbaefb6d2a868e3a3d645caf6e5503fb6235ed5dd369d25e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/39a7387880a79cc2bbaefb6d2a868e3a3d645caf6e5503fb6235ed5dd369d25e.R) · [methods/local-omics-analysis-guide/code/native/39c2856c70d6c66f400578239018a44848116da9f8a09f68c61856564c3d2e3f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/39c2856c70d6c66f400578239018a44848116da9f8a09f68c61856564c3d2e3f.R) · [methods/local-omics-analysis-guide/code/native/3a5c55bca5eb97a83783271ed5413a0ded97dd0ea3f6a468ebb5ca9e387ee3d8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3a5c55bca5eb97a83783271ed5413a0ded97dd0ea3f6a468ebb5ca9e387ee3d8.R) · [methods/local-omics-analysis-guide/code/native/3b22436d0d7f69212d719249915cc9e715333a6061829fbb297923ce614a1be3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3b22436d0d7f69212d719249915cc9e715333a6061829fbb297923ce614a1be3.R) · [methods/local-omics-analysis-guide/code/native/3c8664231b75c3aeb591d2f2c2911ee21b99cecb89a01632fd2a774da0ca90f5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3c8664231b75c3aeb591d2f2c2911ee21b99cecb89a01632fd2a774da0ca90f5.R) · [methods/local-omics-analysis-guide/code/native/3c9a885dd7271d73291a87237ef5edd1b09c347cd5927fda6998de2d81583bff.R](/files/wiki/methods/local-omics-analysis-guide/code/native/3c9a885dd7271d73291a87237ef5edd1b09c347cd5927fda6998de2d81583bff.R) · [methods/local-omics-analysis-guide/code/native/41455138db62b72ca4ad9443b172d7f54c63b5a9c484888b71f4618ebbba5797.R](/files/wiki/methods/local-omics-analysis-guide/code/native/41455138db62b72ca4ad9443b172d7f54c63b5a9c484888b71f4618ebbba5797.R) · [methods/local-omics-analysis-guide/code/native/41b9e7fb06e17ce7c2e65c096083563fcb0081de87fab8d60819e69a503afa0c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/41b9e7fb06e17ce7c2e65c096083563fcb0081de87fab8d60819e69a503afa0c.R) · [methods/local-omics-analysis-guide/code/native/4268bce527239eea7952e5fc2177c016a9565c6d411dc285dbe7e6479c0fcef0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4268bce527239eea7952e5fc2177c016a9565c6d411dc285dbe7e6479c0fcef0.R) · [methods/local-omics-analysis-guide/code/native/440b58fb08b4a00be4d809c37fbf2306233ff7ebc915d7d77ff7356d0791bc02.R](/files/wiki/methods/local-omics-analysis-guide/code/native/440b58fb08b4a00be4d809c37fbf2306233ff7ebc915d7d77ff7356d0791bc02.R) · [methods/local-omics-analysis-guide/code/native/44417b292a410ce9ab9de6437d32f8437b7d32fef97f1f5bc27260afef425b75.R](/files/wiki/methods/local-omics-analysis-guide/code/native/44417b292a410ce9ab9de6437d32f8437b7d32fef97f1f5bc27260afef425b75.R) · [methods/local-omics-analysis-guide/code/native/4507de3a017f866e3e323bb693d44b2b0885f30b7a8e5e15ae47a2a52b3dd2d7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4507de3a017f866e3e323bb693d44b2b0885f30b7a8e5e15ae47a2a52b3dd2d7.R) · [methods/local-omics-analysis-guide/code/native/454b586b32781d70263c107521f1353dfb98b64dab58d18863bd82e4b5e66457.R](/files/wiki/methods/local-omics-analysis-guide/code/native/454b586b32781d70263c107521f1353dfb98b64dab58d18863bd82e4b5e66457.R) · [methods/local-omics-analysis-guide/code/native/47144037d9bbd9f7f2fc6e3707097b2a5c58c82288bed3241df5f9ae248ea300.R](/files/wiki/methods/local-omics-analysis-guide/code/native/47144037d9bbd9f7f2fc6e3707097b2a5c58c82288bed3241df5f9ae248ea300.R) · [methods/local-omics-analysis-guide/code/native/47af414c02f7eb0e6cdd6f98112d909f179b577d7098aba253bb626505b57da9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/47af414c02f7eb0e6cdd6f98112d909f179b577d7098aba253bb626505b57da9.R) · [methods/local-omics-analysis-guide/code/native/47edcb8a74ff52393afe8c44b3e631c2fb46514e0be1f3da1797b30ae8276428.R](/files/wiki/methods/local-omics-analysis-guide/code/native/47edcb8a74ff52393afe8c44b3e631c2fb46514e0be1f3da1797b30ae8276428.R) · [methods/local-omics-analysis-guide/code/native/483eb638ade1c008d5cbeacc6a72619a77cf3fcba5c4c6531ec7f8659740dec1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/483eb638ade1c008d5cbeacc6a72619a77cf3fcba5c4c6531ec7f8659740dec1.R) · [methods/local-omics-analysis-guide/code/native/489f8231202a3aa00d090fc0169b0fadb5da19c61e35f6c32bb3808b67bc77e4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/489f8231202a3aa00d090fc0169b0fadb5da19c61e35f6c32bb3808b67bc77e4.R) · [methods/local-omics-analysis-guide/code/native/49182e49b6e48f750fd0b9dcd3eebfa8c54621898aea6d1fbf1d11c4985fae20.R](/files/wiki/methods/local-omics-analysis-guide/code/native/49182e49b6e48f750fd0b9dcd3eebfa8c54621898aea6d1fbf1d11c4985fae20.R) · [methods/local-omics-analysis-guide/code/native/4b293f1ee5145a6e1426bdbf9306a7bfa163f48569c1b0457ae370995eb31922.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4b293f1ee5145a6e1426bdbf9306a7bfa163f48569c1b0457ae370995eb31922.R) · [methods/local-omics-analysis-guide/code/native/4b9567c026d2c43379eeb9bb39d36ec98d89e7bbeb77fe4f33fec6012b70f758.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4b9567c026d2c43379eeb9bb39d36ec98d89e7bbeb77fe4f33fec6012b70f758.R) · [methods/local-omics-analysis-guide/code/native/4c57bdc18dd070064e05c730a055113994be80279b4a13c09133a3007d61c322.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4c57bdc18dd070064e05c730a055113994be80279b4a13c09133a3007d61c322.R) · [methods/local-omics-analysis-guide/code/native/4c72507941b0bd4b8cd9ee73a7d8dadc3fc25195cb495a16b5227886a8247d5d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4c72507941b0bd4b8cd9ee73a7d8dadc3fc25195cb495a16b5227886a8247d5d.R) · [methods/local-omics-analysis-guide/code/native/4cc58a07ffc92b6fc953d13b8fb7f901b21991adb9f170a2e78c443b3c628ad8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4cc58a07ffc92b6fc953d13b8fb7f901b21991adb9f170a2e78c443b3c628ad8.R) · [methods/local-omics-analysis-guide/code/native/4d1e59508adb95fb507b6037d5bfb56955ff4d88b3fafcb4c7f30474c2c92621.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4d1e59508adb95fb507b6037d5bfb56955ff4d88b3fafcb4c7f30474c2c92621.R) · [methods/local-omics-analysis-guide/code/native/4d22fb5809843a08ab49de8121e827b6f25f9c955fbba90673b08ec085b3e14f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4d22fb5809843a08ab49de8121e827b6f25f9c955fbba90673b08ec085b3e14f.R) · [methods/local-omics-analysis-guide/code/native/4d4cd85294144d0280151345f49d72780f89f5481281cee26df72b1cd3f9454e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4d4cd85294144d0280151345f49d72780f89f5481281cee26df72b1cd3f9454e.R) · [methods/local-omics-analysis-guide/code/native/4e5f105c8515f60f812546f2e50725a042a811b8f57b4f8cea0484ecceb2b2e8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4e5f105c8515f60f812546f2e50725a042a811b8f57b4f8cea0484ecceb2b2e8.R) · [methods/local-omics-analysis-guide/code/native/4e7dda5e56b396cda75f902634e4a32428ad6e161b1493c73a296ce0d88a6d15.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4e7dda5e56b396cda75f902634e4a32428ad6e161b1493c73a296ce0d88a6d15.R) · [methods/local-omics-analysis-guide/code/native/4f3e869aacbd13cbdcd30e3c7963bb61339e164d6b98aadf5dcff5cf7dc951fe.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4f3e869aacbd13cbdcd30e3c7963bb61339e164d6b98aadf5dcff5cf7dc951fe.R) · [methods/local-omics-analysis-guide/code/native/4f57ef93eab8aa0652c45930105eb3933a0a1f5029b02509abcd1d0a5dbd80c9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4f57ef93eab8aa0652c45930105eb3933a0a1f5029b02509abcd1d0a5dbd80c9.R) · [methods/local-omics-analysis-guide/code/native/4fd54c4e63569ebf202197901d39c279d165527c1deeb135c0c1c93d344ef0ba.R](/files/wiki/methods/local-omics-analysis-guide/code/native/4fd54c4e63569ebf202197901d39c279d165527c1deeb135c0c1c93d344ef0ba.R) · [methods/local-omics-analysis-guide/code/native/51222279816b0b65bb983249c479f64f7f8f685a5925f2ad2fede8a1d5f9a56b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/51222279816b0b65bb983249c479f64f7f8f685a5925f2ad2fede8a1d5f9a56b.R) · [methods/local-omics-analysis-guide/code/native/51961e377a46a01fe7467d2cac6880e254c542bc2db61ff114513ca81c791de9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/51961e377a46a01fe7467d2cac6880e254c542bc2db61ff114513ca81c791de9.R) · [methods/local-omics-analysis-guide/code/native/520fb5fa3a5fe734e88f125f2a03ad727e18b03e225856fd92e6d5f8b75d9f65.R](/files/wiki/methods/local-omics-analysis-guide/code/native/520fb5fa3a5fe734e88f125f2a03ad727e18b03e225856fd92e6d5f8b75d9f65.R) · [methods/local-omics-analysis-guide/code/native/524af17fe06d616ecccf0818ca00821a22eb717a03c1851512c19f1c372fed43.R](/files/wiki/methods/local-omics-analysis-guide/code/native/524af17fe06d616ecccf0818ca00821a22eb717a03c1851512c19f1c372fed43.R) · [methods/local-omics-analysis-guide/code/native/52e949bb605b7d432c8b4e55aeb7010e5829def37d80cc36ec61f542f5aa6c29.R](/files/wiki/methods/local-omics-analysis-guide/code/native/52e949bb605b7d432c8b4e55aeb7010e5829def37d80cc36ec61f542f5aa6c29.R) · [methods/local-omics-analysis-guide/code/native/532e0c8a2f4bd5ea38f4f75623c1849eb356b8fd1c75e7407ccf34e6922a3c0f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/532e0c8a2f4bd5ea38f4f75623c1849eb356b8fd1c75e7407ccf34e6922a3c0f.R) · [methods/local-omics-analysis-guide/code/native/534fc5b1f3e763d287bd3b9f454a915b65bacb6335cecd9e38f0c8f66a70eb8d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/534fc5b1f3e763d287bd3b9f454a915b65bacb6335cecd9e38f0c8f66a70eb8d.R) · [methods/local-omics-analysis-guide/code/native/536af2e7b1b65d319df6b6715f21926f89ab04d4b9ab9bb2b6ff2b3997fc0ac8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/536af2e7b1b65d319df6b6715f21926f89ab04d4b9ab9bb2b6ff2b3997fc0ac8.R) · [methods/local-omics-analysis-guide/code/native/537c535f330880c84943541c164241c1d8550c2da461430e847f1425bc8a8514.R](/files/wiki/methods/local-omics-analysis-guide/code/native/537c535f330880c84943541c164241c1d8550c2da461430e847f1425bc8a8514.R) · [methods/local-omics-analysis-guide/code/native/53aadb39f5955b7ee62425824b28c9c984561ebd5ad3d04049a2e643007f3a2b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/53aadb39f5955b7ee62425824b28c9c984561ebd5ad3d04049a2e643007f3a2b.R) · [methods/local-omics-analysis-guide/code/native/5433709fd19a5860df86012913b4fb184d06efa5f6d56224887503a4f880010b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5433709fd19a5860df86012913b4fb184d06efa5f6d56224887503a4f880010b.R) · [methods/local-omics-analysis-guide/code/native/549d95ab6132e57e02cb6f1b143cbf60d9901236d0d8456cc9624f6240d946de.R](/files/wiki/methods/local-omics-analysis-guide/code/native/549d95ab6132e57e02cb6f1b143cbf60d9901236d0d8456cc9624f6240d946de.R) · [methods/local-omics-analysis-guide/code/native/54f9c8c1a7d1c56fb111c5bd6e3d22709afb8228618a5a2eea788aa1e2d1af8a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/54f9c8c1a7d1c56fb111c5bd6e3d22709afb8228618a5a2eea788aa1e2d1af8a.R) · [methods/local-omics-analysis-guide/code/native/557fb7f854d80ca1ef4eaae401b9d8a14c7f6ba28aa77e1c7b3f5b9f1a19edcd.R](/files/wiki/methods/local-omics-analysis-guide/code/native/557fb7f854d80ca1ef4eaae401b9d8a14c7f6ba28aa77e1c7b3f5b9f1a19edcd.R) · [methods/local-omics-analysis-guide/code/native/55b767ed0e52ff11d588c7c44e733dd9ba0b51fe0f6e14459a1e8bb5265d98e5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/55b767ed0e52ff11d588c7c44e733dd9ba0b51fe0f6e14459a1e8bb5265d98e5.R) · [methods/local-omics-analysis-guide/code/native/5679b69c54a80142568cd5505553dcbaa0539dc367f4a595609c55a2fd7acc03.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5679b69c54a80142568cd5505553dcbaa0539dc367f4a595609c55a2fd7acc03.R) · [methods/local-omics-analysis-guide/code/native/575d6df8e50a604c9b9e7c1db16035d8ad31448cd8ae4e39d3573fa3fcbe84c3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/575d6df8e50a604c9b9e7c1db16035d8ad31448cd8ae4e39d3573fa3fcbe84c3.R) · [methods/local-omics-analysis-guide/code/native/5a4fa77336c4c2b41b3a0aa38539bb6fa50a481092259c25e4bab3777cd2a4bb.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5a4fa77336c4c2b41b3a0aa38539bb6fa50a481092259c25e4bab3777cd2a4bb.R) · [methods/local-omics-analysis-guide/code/native/5cdb722422d0cdace0ab2d3e14d830266172af0d39ee71cfe9ebed04ca1e87a1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5cdb722422d0cdace0ab2d3e14d830266172af0d39ee71cfe9ebed04ca1e87a1.R) · [methods/local-omics-analysis-guide/code/native/5cf9bb3102fe650a649809b32944cb231119860b9d83b83282f71f45df5d5d8e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5cf9bb3102fe650a649809b32944cb231119860b9d83b83282f71f45df5d5d8e.R) · [methods/local-omics-analysis-guide/code/native/5d1233555df1897faa088395ef496e99e16fa59959bd57f560b1354d2399ec3d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5d1233555df1897faa088395ef496e99e16fa59959bd57f560b1354d2399ec3d.R) · [methods/local-omics-analysis-guide/code/native/5d6a5f19fad18793ef49355aa894d989984620ddda9e7d6ab88a4d07ddd13ed4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5d6a5f19fad18793ef49355aa894d989984620ddda9e7d6ab88a4d07ddd13ed4.R) · [methods/local-omics-analysis-guide/code/native/5f0253e790dc8c6d0e52b8d4f8d730928138dbdfb543077ebb9d89c4009b49e2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/5f0253e790dc8c6d0e52b8d4f8d730928138dbdfb543077ebb9d89c4009b49e2.R) · [methods/local-omics-analysis-guide/code/native/6064f605966498e0f1b62fbc3e0370754361ac8481e4283f8466b5c1224f13ce.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6064f605966498e0f1b62fbc3e0370754361ac8481e4283f8466b5c1224f13ce.R) · [methods/local-omics-analysis-guide/code/native/60acaf91df7f02f91aab8aa0bc8f58e5b30c8619f652c29fa6eaa1d7ec93adc3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/60acaf91df7f02f91aab8aa0bc8f58e5b30c8619f652c29fa6eaa1d7ec93adc3.R) · [methods/local-omics-analysis-guide/code/native/61df79fd456cfb500b4c1e3e7580e240532abc320c2930ea72f40394133e54df.R](/files/wiki/methods/local-omics-analysis-guide/code/native/61df79fd456cfb500b4c1e3e7580e240532abc320c2930ea72f40394133e54df.R) · [methods/local-omics-analysis-guide/code/native/627197c95c254f1c1773f34e8171b0f2924456df1c6961750919c983fc2b4530.R](/files/wiki/methods/local-omics-analysis-guide/code/native/627197c95c254f1c1773f34e8171b0f2924456df1c6961750919c983fc2b4530.R) · [methods/local-omics-analysis-guide/code/native/63fc772d2bc8b1c1711f51550019a5e4473d94078b471f89c98285f8a403f5a1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/63fc772d2bc8b1c1711f51550019a5e4473d94078b471f89c98285f8a403f5a1.R) · [methods/local-omics-analysis-guide/code/native/65dcdb544e0c5d24362b1978ad98989561cfd4a333952c53271cedb5526e6395.R](/files/wiki/methods/local-omics-analysis-guide/code/native/65dcdb544e0c5d24362b1978ad98989561cfd4a333952c53271cedb5526e6395.R) · [methods/local-omics-analysis-guide/code/native/664762f662bd7536966ef88e85b55d5df03a5fbb4207b44811b08cacddb33a3d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/664762f662bd7536966ef88e85b55d5df03a5fbb4207b44811b08cacddb33a3d.R) · [methods/local-omics-analysis-guide/code/native/66a371bad077e1956d5cfb4e1e5fcc0a0e04f499055c0f5c33efc822e62aefe6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/66a371bad077e1956d5cfb4e1e5fcc0a0e04f499055c0f5c33efc822e62aefe6.R) · [methods/local-omics-analysis-guide/code/native/6803ea4c393afec8d60e387bca385012b9b723953e488482be28638460494f22.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6803ea4c393afec8d60e387bca385012b9b723953e488482be28638460494f22.R) · [methods/local-omics-analysis-guide/code/native/688244e2913b7617ff5234b9baafa41f15d618d941485eeda0c32e31ce16917c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/688244e2913b7617ff5234b9baafa41f15d618d941485eeda0c32e31ce16917c.R) · [methods/local-omics-analysis-guide/code/native/68d02c19802a71b492bf359f83572c4a1322540da035174c0e01e6f1b12cc791.R](/files/wiki/methods/local-omics-analysis-guide/code/native/68d02c19802a71b492bf359f83572c4a1322540da035174c0e01e6f1b12cc791.R) · [methods/local-omics-analysis-guide/code/native/68d92c4b0bdf541c1e13578d1e9258679493b69895ae0dc3dda8d45555d3b91d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/68d92c4b0bdf541c1e13578d1e9258679493b69895ae0dc3dda8d45555d3b91d.R) · [methods/local-omics-analysis-guide/code/native/68ff76e80e9660d7e5276bb8df67904b5ad4321cd354c36acac10ba9cb5e4c12.R](/files/wiki/methods/local-omics-analysis-guide/code/native/68ff76e80e9660d7e5276bb8df67904b5ad4321cd354c36acac10ba9cb5e4c12.R) · [methods/local-omics-analysis-guide/code/native/6961af7f43f1281fcff62338329665a9d6281bfd5d9cd87c1acae8fa2aabbc59.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6961af7f43f1281fcff62338329665a9d6281bfd5d9cd87c1acae8fa2aabbc59.R) · [methods/local-omics-analysis-guide/code/native/69b7c53a825928432162311cbd09d6caa03d0f8b94f5886fcc5c256d6c1f46e5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/69b7c53a825928432162311cbd09d6caa03d0f8b94f5886fcc5c256d6c1f46e5.R) · [methods/local-omics-analysis-guide/code/native/6d25bea574dc8ea646fa96cebefe8c50ebcd602b24c0055d90872a43ee6ebe40.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6d25bea574dc8ea646fa96cebefe8c50ebcd602b24c0055d90872a43ee6ebe40.R) · [methods/local-omics-analysis-guide/code/native/6d62479b16694b182fecc97d371b9eddbb2200d4cbfcd59e28d72ce5691c7922.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6d62479b16694b182fecc97d371b9eddbb2200d4cbfcd59e28d72ce5691c7922.R) · [methods/local-omics-analysis-guide/code/native/6da3f958e75bd7092047593d63b3fccd4dbd4cbf34c91acb9f5e6bb6f0c2f9f6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6da3f958e75bd7092047593d63b3fccd4dbd4cbf34c91acb9f5e6bb6f0c2f9f6.R) · [methods/local-omics-analysis-guide/code/native/6e04922e413e5e0f01a6cef148e546dbb27e1546a277ecd23c9518725d7560e9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/6e04922e413e5e0f01a6cef148e546dbb27e1546a277ecd23c9518725d7560e9.R) · [methods/local-omics-analysis-guide/code/native/7083a1f402721560ff9df7366ba079649dbd1e1d85851acbca7753cefd55666d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7083a1f402721560ff9df7366ba079649dbd1e1d85851acbca7753cefd55666d.R) · [methods/local-omics-analysis-guide/code/native/70d7554dfcbbee9ceaeee8e3ceae53288d4b25ee755706752d6e84d4615a1b74.R](/files/wiki/methods/local-omics-analysis-guide/code/native/70d7554dfcbbee9ceaeee8e3ceae53288d4b25ee755706752d6e84d4615a1b74.R) · [methods/local-omics-analysis-guide/code/native/7145921b1fdbf547151473743d44145e7de3b7a60726bc2b257c451125eb5aaf.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7145921b1fdbf547151473743d44145e7de3b7a60726bc2b257c451125eb5aaf.R) · [methods/local-omics-analysis-guide/code/native/725897172e78dceb5ef5f6cd603e865901631c5ac04c72ae848490ae0958b57a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/725897172e78dceb5ef5f6cd603e865901631c5ac04c72ae848490ae0958b57a.R) · [methods/local-omics-analysis-guide/code/native/74154017c9fb670b6c2a3b55ad812cc304d0c64200c09e8643095c7611e79b5f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/74154017c9fb670b6c2a3b55ad812cc304d0c64200c09e8643095c7611e79b5f.R) · [methods/local-omics-analysis-guide/code/native/745f4bbf9205cf4cb2cc52ed38dc1e2337ff17186264695e0335093de55e80ef.R](/files/wiki/methods/local-omics-analysis-guide/code/native/745f4bbf9205cf4cb2cc52ed38dc1e2337ff17186264695e0335093de55e80ef.R) · [methods/local-omics-analysis-guide/code/native/7593aa9f47f2c7f3e60d8ee93ca1abbb30fee048ad8bbcfc20dd150661011def.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7593aa9f47f2c7f3e60d8ee93ca1abbb30fee048ad8bbcfc20dd150661011def.R) · [methods/local-omics-analysis-guide/code/native/76e4e916392ab1e06bf06394f86c96c10f0df5650a8716397f1795bdf78b6f8d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/76e4e916392ab1e06bf06394f86c96c10f0df5650a8716397f1795bdf78b6f8d.R) · [methods/local-omics-analysis-guide/code/native/78b7f60bfdadc9dc1dd862a9ef05f4839cf560eadf394a774f859eec0f6c610b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/78b7f60bfdadc9dc1dd862a9ef05f4839cf560eadf394a774f859eec0f6c610b.R) · [methods/local-omics-analysis-guide/code/native/790c85455224ffbbde49d79b0be69deb4e7725051e87c0c118f65ba3b2f51d45.R](/files/wiki/methods/local-omics-analysis-guide/code/native/790c85455224ffbbde49d79b0be69deb4e7725051e87c0c118f65ba3b2f51d45.R) · [methods/local-omics-analysis-guide/code/native/797cfd39de6e72386ca80960d34b2fd03b7e972c7ce182d183ae254b0e6c49c8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/797cfd39de6e72386ca80960d34b2fd03b7e972c7ce182d183ae254b0e6c49c8.R) · [methods/local-omics-analysis-guide/code/native/79b1345a8c863ce8e477770720f146ff1c3e66c7359c2a1d46bc8c1f22a585fb.R](/files/wiki/methods/local-omics-analysis-guide/code/native/79b1345a8c863ce8e477770720f146ff1c3e66c7359c2a1d46bc8c1f22a585fb.R) · [methods/local-omics-analysis-guide/code/native/79c35b75450d529cc00868d80c65d1a4e53cd2ab42e9562dcbe8ee107ed38919.R](/files/wiki/methods/local-omics-analysis-guide/code/native/79c35b75450d529cc00868d80c65d1a4e53cd2ab42e9562dcbe8ee107ed38919.R) · [methods/local-omics-analysis-guide/code/native/7a9919f9587f3c7e4f389af8ab03c86d0c2d2f307c8b6f84c74e935b9f63d593.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7a9919f9587f3c7e4f389af8ab03c86d0c2d2f307c8b6f84c74e935b9f63d593.R) · [methods/local-omics-analysis-guide/code/native/7bdff16edf6f286713afb2c632d40240a893f072d0ed93627a60bdb8443bd087.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7bdff16edf6f286713afb2c632d40240a893f072d0ed93627a60bdb8443bd087.R) · [methods/local-omics-analysis-guide/code/native/7ea69214895d5cb4a2600060daa5edeac5416adaa0dd2fbbed07da0584a6061b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7ea69214895d5cb4a2600060daa5edeac5416adaa0dd2fbbed07da0584a6061b.R) · [methods/local-omics-analysis-guide/code/native/7edd97f7065d86f40d910b548d5164968a872461fc5d8ef1e1fad6487175aa7f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/7edd97f7065d86f40d910b548d5164968a872461fc5d8ef1e1fad6487175aa7f.R) · [methods/local-omics-analysis-guide/code/native/81b287ef5dc40ccd258db3e2d7b12d034e6882b25235181b683685784a1fcdd6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/81b287ef5dc40ccd258db3e2d7b12d034e6882b25235181b683685784a1fcdd6.R) · [methods/local-omics-analysis-guide/code/native/81ecf9d0c14c83abf763e9a0934a78b9ef1ba16ee7eb694c82bc35c00205ccc6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/81ecf9d0c14c83abf763e9a0934a78b9ef1ba16ee7eb694c82bc35c00205ccc6.R) · [methods/local-omics-analysis-guide/code/native/8412f5970b049a3a9b0171a6bab360ea10565c040f8f295c8b310c9b714980dc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8412f5970b049a3a9b0171a6bab360ea10565c040f8f295c8b310c9b714980dc.R) · [methods/local-omics-analysis-guide/code/native/854cab977868c80c0fe6274208e4bf6429a14651b5c8fc05c9bcc5c0baf98b7a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/854cab977868c80c0fe6274208e4bf6429a14651b5c8fc05c9bcc5c0baf98b7a.R) · [methods/local-omics-analysis-guide/code/native/857ae7452a1fadfda32e509256826d0680f5c901e54ffe8d05ed254335a74aa1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/857ae7452a1fadfda32e509256826d0680f5c901e54ffe8d05ed254335a74aa1.R) · [methods/local-omics-analysis-guide/code/native/87000f6c54c30d25cf722c1b2b5cfc3aa597270dae78b287509ccff187850dcc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/87000f6c54c30d25cf722c1b2b5cfc3aa597270dae78b287509ccff187850dcc.R) · [methods/local-omics-analysis-guide/code/native/8772f757f2e7e3bb3decd215b4977743ebf18c2cf3f685fe3b29b7b83a088d97.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8772f757f2e7e3bb3decd215b4977743ebf18c2cf3f685fe3b29b7b83a088d97.R) · [methods/local-omics-analysis-guide/code/native/880f0da841e49b21c68978cc6a6c32a0f44c0d5e1df3e7727e956c1a578b96a1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/880f0da841e49b21c68978cc6a6c32a0f44c0d5e1df3e7727e956c1a578b96a1.R) · [methods/local-omics-analysis-guide/code/native/88e02c3abdcf79d1b4b41471d8ea20ece327f1ac0797299eef5ef82acb668d6f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/88e02c3abdcf79d1b4b41471d8ea20ece327f1ac0797299eef5ef82acb668d6f.R) · [methods/local-omics-analysis-guide/code/native/891d5261e7fa060c03295a90d5fb5e37777d2ef1f2adddbb911443d063e29660.R](/files/wiki/methods/local-omics-analysis-guide/code/native/891d5261e7fa060c03295a90d5fb5e37777d2ef1f2adddbb911443d063e29660.R) · [methods/local-omics-analysis-guide/code/native/89c23f26057eafeaa0c7d3b14c967aa96c5b612e732d6dc7b6e5f77f957c7f13.R](/files/wiki/methods/local-omics-analysis-guide/code/native/89c23f26057eafeaa0c7d3b14c967aa96c5b612e732d6dc7b6e5f77f957c7f13.R) · [methods/local-omics-analysis-guide/code/native/8a4577f34e924f12ce7779e5d15fce3e5ecb812f78ccc653154469bb078599ea.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8a4577f34e924f12ce7779e5d15fce3e5ecb812f78ccc653154469bb078599ea.R) · [methods/local-omics-analysis-guide/code/native/8ae255ea525f2d04e19d75287e4a3d6adfccf441d68520d04c4dd7183d7b392e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8ae255ea525f2d04e19d75287e4a3d6adfccf441d68520d04c4dd7183d7b392e.R) · [methods/local-omics-analysis-guide/code/native/8b1943c9985aa9f93a156ea574ec50538f51861c672c55f2dc8ea638e96cf53c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8b1943c9985aa9f93a156ea574ec50538f51861c672c55f2dc8ea638e96cf53c.R) · [methods/local-omics-analysis-guide/code/native/8b5bdcfe4b9e993f372528a9623240004e57e72bb23a025eec66cef4d294fc16.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8b5bdcfe4b9e993f372528a9623240004e57e72bb23a025eec66cef4d294fc16.R) · [methods/local-omics-analysis-guide/code/native/8b9165079855694e52920e686947748e61f784b2122512ca6ee7597614ac1d35.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8b9165079855694e52920e686947748e61f784b2122512ca6ee7597614ac1d35.R) · [methods/local-omics-analysis-guide/code/native/8ca88e4f02d074155741e03f3d7992aa7e08cd8eb2add6e29770c03c9075b3c3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8ca88e4f02d074155741e03f3d7992aa7e08cd8eb2add6e29770c03c9075b3c3.R) · [methods/local-omics-analysis-guide/code/native/8d26730cfc4e1b1d4365ae150f9f6eefd50c6c03173005183d17d03a22972ca3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8d26730cfc4e1b1d4365ae150f9f6eefd50c6c03173005183d17d03a22972ca3.R) · [methods/local-omics-analysis-guide/code/native/8d68e710c7892b68c951386099c869ba419ca2b858b9f59f59cacfefc417f742.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8d68e710c7892b68c951386099c869ba419ca2b858b9f59f59cacfefc417f742.R) · [methods/local-omics-analysis-guide/code/native/8f973bdf6706e00180286e1dc91bb076d99c3c4f32aae04a0f87a6e554717677.R](/files/wiki/methods/local-omics-analysis-guide/code/native/8f973bdf6706e00180286e1dc91bb076d99c3c4f32aae04a0f87a6e554717677.R) · [methods/local-omics-analysis-guide/code/native/908197e85eb4ebfdcd4dbca233118a17a258223ef44b77441abc8433c5cc5fa7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/908197e85eb4ebfdcd4dbca233118a17a258223ef44b77441abc8433c5cc5fa7.R) · [methods/local-omics-analysis-guide/code/native/90afa5d49301ce7552782cdaef17d4320bc55a26716c4628d8f17cd493ca4c45.R](/files/wiki/methods/local-omics-analysis-guide/code/native/90afa5d49301ce7552782cdaef17d4320bc55a26716c4628d8f17cd493ca4c45.R) · [methods/local-omics-analysis-guide/code/native/90f0bd5e4502d0cda2f460aa0b26854e3a264ae3029898ad47dfcba9b0eca529.R](/files/wiki/methods/local-omics-analysis-guide/code/native/90f0bd5e4502d0cda2f460aa0b26854e3a264ae3029898ad47dfcba9b0eca529.R) · [methods/local-omics-analysis-guide/code/native/9121f398973f45c71642b1327a1782d1e2550c9c1d73cf0199e73b05553e12bc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9121f398973f45c71642b1327a1782d1e2550c9c1d73cf0199e73b05553e12bc.R) · [methods/local-omics-analysis-guide/code/native/91fda9c3af929c10167a81cb8eadca62918df471f69aa8476f8d83c8dfaec810.R](/files/wiki/methods/local-omics-analysis-guide/code/native/91fda9c3af929c10167a81cb8eadca62918df471f69aa8476f8d83c8dfaec810.R) · [methods/local-omics-analysis-guide/code/native/93e5638b26f7b41c09ac97ccba09ceb4ef16ce233433589f26ab575ffc52b391.R](/files/wiki/methods/local-omics-analysis-guide/code/native/93e5638b26f7b41c09ac97ccba09ceb4ef16ce233433589f26ab575ffc52b391.R) · [methods/local-omics-analysis-guide/code/native/9436d3e58e00303aa2b599b7ff9b315d673888a845de4ca852b675e6813ce171.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9436d3e58e00303aa2b599b7ff9b315d673888a845de4ca852b675e6813ce171.R) · [methods/local-omics-analysis-guide/code/native/965777468519734f24d32ace7038ba963bc741b379756330f4527deb3908ac48.R](/files/wiki/methods/local-omics-analysis-guide/code/native/965777468519734f24d32ace7038ba963bc741b379756330f4527deb3908ac48.R) · [methods/local-omics-analysis-guide/code/native/9673ab0955f08408794895cf0bb98749ab931e5c91b8e2cd81603aec3c764b52.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9673ab0955f08408794895cf0bb98749ab931e5c91b8e2cd81603aec3c764b52.R) · [methods/local-omics-analysis-guide/code/native/975c6f410ef117f65f0ee8fed70bad328c98e94f44784aeaf3031fa9da7a737a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/975c6f410ef117f65f0ee8fed70bad328c98e94f44784aeaf3031fa9da7a737a.R) · [methods/local-omics-analysis-guide/code/native/986f56ee9b3da654f30b9137d8515c29a3597c5ec3c898952a867e429eb74d5a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/986f56ee9b3da654f30b9137d8515c29a3597c5ec3c898952a867e429eb74d5a.R) · [methods/local-omics-analysis-guide/code/native/9b4f13f8baa6149a24ee74104ee884e37f22c99ad317780ad94fe6dcbe5ad48c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9b4f13f8baa6149a24ee74104ee884e37f22c99ad317780ad94fe6dcbe5ad48c.R) · [methods/local-omics-analysis-guide/code/native/9c61967562e3215b1478e36a99e967b8e0d6521dff66452739bee2a0420ee4ca.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9c61967562e3215b1478e36a99e967b8e0d6521dff66452739bee2a0420ee4ca.R) · [methods/local-omics-analysis-guide/code/native/9ceb729f0a9c5649e737989262eb9aa619e4b63ec6044ce215502acc167e75ed.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9ceb729f0a9c5649e737989262eb9aa619e4b63ec6044ce215502acc167e75ed.R) · [methods/local-omics-analysis-guide/code/native/9d5f190cb9ee443c61d6599ef89076764661d82688caaf37f92ef1f681818bfd.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9d5f190cb9ee443c61d6599ef89076764661d82688caaf37f92ef1f681818bfd.R) · [methods/local-omics-analysis-guide/code/native/9d77c2fe9c617c0ac4cd70ca1fbe2af91cfd2a6ed465942d19d98aad59172375.R](/files/wiki/methods/local-omics-analysis-guide/code/native/9d77c2fe9c617c0ac4cd70ca1fbe2af91cfd2a6ed465942d19d98aad59172375.R) · [methods/local-omics-analysis-guide/code/native/a14604ee32c464a2d9e1264cfc220a8d6a9f652bb6b33aa11a8b6fa9ac0e42a3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a14604ee32c464a2d9e1264cfc220a8d6a9f652bb6b33aa11a8b6fa9ac0e42a3.R) · [methods/local-omics-analysis-guide/code/native/a1f24a9ea92b6b67516945f9f0ca998c844404b6622ee5db62178eca420e3f48.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a1f24a9ea92b6b67516945f9f0ca998c844404b6622ee5db62178eca420e3f48.R) · [methods/local-omics-analysis-guide/code/native/a207b22b9794f89d9ca2afe1fe0b2bf45464fa15b37ce7ecf7898950fb0cbc72.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a207b22b9794f89d9ca2afe1fe0b2bf45464fa15b37ce7ecf7898950fb0cbc72.R) · [methods/local-omics-analysis-guide/code/native/a39f18d7526f4014cdd5bacfd12ba91b2864928dbf8311b9bd1e05779a16433a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a39f18d7526f4014cdd5bacfd12ba91b2864928dbf8311b9bd1e05779a16433a.R) · [methods/local-omics-analysis-guide/code/native/a4124ba3090c2f56fb5b44695475e446d8b32cb438d4d33b25bc9520ec95b439.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a4124ba3090c2f56fb5b44695475e446d8b32cb438d4d33b25bc9520ec95b439.R) · [methods/local-omics-analysis-guide/code/native/a436e053b9d85978282286bc382bc38c72b32b26fc75013e90b921c37cb53648.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a436e053b9d85978282286bc382bc38c72b32b26fc75013e90b921c37cb53648.R) · [methods/local-omics-analysis-guide/code/native/a4eb2854d98293d5b96bafeaab478974acdc06082d298ab632fa743873894fdc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a4eb2854d98293d5b96bafeaab478974acdc06082d298ab632fa743873894fdc.R) · [methods/local-omics-analysis-guide/code/native/a558cf7fa487c688c27d8d9abcc7d322a5f77911bbf983b5a01df2f3e8c730f5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a558cf7fa487c688c27d8d9abcc7d322a5f77911bbf983b5a01df2f3e8c730f5.R) · [methods/local-omics-analysis-guide/code/native/a5a658b2fe4bbeb000707ef15c7521b923a03b9c6f27f3e31413984907cac82f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a5a658b2fe4bbeb000707ef15c7521b923a03b9c6f27f3e31413984907cac82f.R) · [methods/local-omics-analysis-guide/code/native/a65e57b0e65105044873b6dbfa22efde054cf3937ea481d5d3b5dcc7bd5e79b2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a65e57b0e65105044873b6dbfa22efde054cf3937ea481d5d3b5dcc7bd5e79b2.R) · [methods/local-omics-analysis-guide/code/native/a70c4850f759cc436f7b2ba960fc3f5a932cc0cadc59ea9317882b7c4f3951b2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a70c4850f759cc436f7b2ba960fc3f5a932cc0cadc59ea9317882b7c4f3951b2.R) · [methods/local-omics-analysis-guide/code/native/a8afb04e61e9d828ef84adf35f0e7bade5e6a5d4a9d96ede8991bf1e50b1623d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a8afb04e61e9d828ef84adf35f0e7bade5e6a5d4a9d96ede8991bf1e50b1623d.R) · [methods/local-omics-analysis-guide/code/native/a9af4bd18d8e8e607db2d9b0c4e4e565c40603ae1c782f90bc3fa08b542c43cf.R](/files/wiki/methods/local-omics-analysis-guide/code/native/a9af4bd18d8e8e607db2d9b0c4e4e565c40603ae1c782f90bc3fa08b542c43cf.R) · [methods/local-omics-analysis-guide/code/native/abcff4de577832c30b1a98903ebc1a9539d63a80f3a02c58c2d3ac19e5fb9e00.R](/files/wiki/methods/local-omics-analysis-guide/code/native/abcff4de577832c30b1a98903ebc1a9539d63a80f3a02c58c2d3ac19e5fb9e00.R) · [methods/local-omics-analysis-guide/code/native/abead36f893862994895a2c4367f0733ec4d8148a4906fdcd909799eeeacf7bf.R](/files/wiki/methods/local-omics-analysis-guide/code/native/abead36f893862994895a2c4367f0733ec4d8148a4906fdcd909799eeeacf7bf.R) · [methods/local-omics-analysis-guide/code/native/ac68d8d6247791f127c0efd913d4abd2d148a4bd154e138e33bae1b58bd9fdd5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ac68d8d6247791f127c0efd913d4abd2d148a4bd154e138e33bae1b58bd9fdd5.R) · [methods/local-omics-analysis-guide/code/native/ad5d6959a76b02f5f3b38047cf7a9b859fd4c43f6bc480296420529c9f20bccc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ad5d6959a76b02f5f3b38047cf7a9b859fd4c43f6bc480296420529c9f20bccc.R) · [methods/local-omics-analysis-guide/code/native/ad6c3a89127d24eece90cbb388ce4de494fda61b08fd01995e57ae3c2eae8f82.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ad6c3a89127d24eece90cbb388ce4de494fda61b08fd01995e57ae3c2eae8f82.R) · [methods/local-omics-analysis-guide/code/native/ad819521615540e74d86276758186ce32adc591507de92744d9fd6e7265c854f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ad819521615540e74d86276758186ce32adc591507de92744d9fd6e7265c854f.R) · [methods/local-omics-analysis-guide/code/native/ae028de6edab8a39e7ebbf0a5f1f94cd8a7858b225ea31964b7c9d857621d0b1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ae028de6edab8a39e7ebbf0a5f1f94cd8a7858b225ea31964b7c9d857621d0b1.R) · [methods/local-omics-analysis-guide/code/native/ae62c3bde2dffdb21d0484b54030a6fef32d953945846d3e72f354111caa77f5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ae62c3bde2dffdb21d0484b54030a6fef32d953945846d3e72f354111caa77f5.R) · [methods/local-omics-analysis-guide/code/native/af13b573d2ee276cafb9ce4c2a5d35e8e28eb03b9e9c62e6f19d884e03f6c2e8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/af13b573d2ee276cafb9ce4c2a5d35e8e28eb03b9e9c62e6f19d884e03f6c2e8.R) · [methods/local-omics-analysis-guide/code/native/af1541e18a816ad13b5630c4be47b87f70031f6764e26d4745e5fee7f74edc76.R](/files/wiki/methods/local-omics-analysis-guide/code/native/af1541e18a816ad13b5630c4be47b87f70031f6764e26d4745e5fee7f74edc76.R) · [methods/local-omics-analysis-guide/code/native/afc186606359765945e251251db837367a29654181d082037b689355eaceb5fa.R](/files/wiki/methods/local-omics-analysis-guide/code/native/afc186606359765945e251251db837367a29654181d082037b689355eaceb5fa.R) · [methods/local-omics-analysis-guide/code/native/afebf2a2c55dcc9bb295b7854c11e0607e8eabe5aca171d7707a88f868406b94.R](/files/wiki/methods/local-omics-analysis-guide/code/native/afebf2a2c55dcc9bb295b7854c11e0607e8eabe5aca171d7707a88f868406b94.R) · [methods/local-omics-analysis-guide/code/native/b17a8dea966636c0e699e94edcdbefb9d210fda46f0caf976a39b96828abe306.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b17a8dea966636c0e699e94edcdbefb9d210fda46f0caf976a39b96828abe306.R) · [methods/local-omics-analysis-guide/code/native/b19e1f5b66f4382c7314e1444f2d94cc38d898b3816181cf45c90bb4cbe1af06.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b19e1f5b66f4382c7314e1444f2d94cc38d898b3816181cf45c90bb4cbe1af06.R) · [methods/local-omics-analysis-guide/code/native/b1de673abe6ec6c35be29b887bc2c2f2604570f2ffe2f15ee92ff0395ec5d9f0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b1de673abe6ec6c35be29b887bc2c2f2604570f2ffe2f15ee92ff0395ec5d9f0.R) · [methods/local-omics-analysis-guide/code/native/b2ab55e065b17a33e350cb7c15eaf8d50fd6f2c28226f4e6d20fe0f43c87fba2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b2ab55e065b17a33e350cb7c15eaf8d50fd6f2c28226f4e6d20fe0f43c87fba2.R) · [methods/local-omics-analysis-guide/code/native/b304a14a8f99478e9a3bedbe92a6c7d2a39ee935dc7adb902f53ca0326ac9e52.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b304a14a8f99478e9a3bedbe92a6c7d2a39ee935dc7adb902f53ca0326ac9e52.R) · [methods/local-omics-analysis-guide/code/native/b4da25d9924ce70693e3115f75cbb27c29b3dc54f9eac049da29a8f9ab79e4dd.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b4da25d9924ce70693e3115f75cbb27c29b3dc54f9eac049da29a8f9ab79e4dd.R) · [methods/local-omics-analysis-guide/code/native/b4f987ae7b09986879913b76adfaab21e6940e4a334afca25e9d821f9479fe0e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b4f987ae7b09986879913b76adfaab21e6940e4a334afca25e9d821f9479fe0e.R) · [methods/local-omics-analysis-guide/code/native/b4fc2dc650973399e7fb9054131ba300a19422087bd0602b55ff803c452f9fb4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b4fc2dc650973399e7fb9054131ba300a19422087bd0602b55ff803c452f9fb4.R) · [methods/local-omics-analysis-guide/code/native/b582ac67a8897c29699974041f4bc250549ca37966a23e7e025536f34e425d6d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b582ac67a8897c29699974041f4bc250549ca37966a23e7e025536f34e425d6d.R) · [methods/local-omics-analysis-guide/code/native/b58e4cf990852463b55d3be33f0c389e0acf3365900a824863c9c69fce0e7e5b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b58e4cf990852463b55d3be33f0c389e0acf3365900a824863c9c69fce0e7e5b.R) · [methods/local-omics-analysis-guide/code/native/b61e633984417fccadb6e770b0b73e8dd6b5ac86e683997d94a822c9ea52a1f4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b61e633984417fccadb6e770b0b73e8dd6b5ac86e683997d94a822c9ea52a1f4.R) · [methods/local-omics-analysis-guide/code/native/b65ad6ccbe7372e2226db612df3063e8be45ab7207870bae034c8dad07c59e7b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b65ad6ccbe7372e2226db612df3063e8be45ab7207870bae034c8dad07c59e7b.R) · [methods/local-omics-analysis-guide/code/native/b66078d76031782935cab033a7a9b9d6960ec10699341b3c2bc75453838afe35.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b66078d76031782935cab033a7a9b9d6960ec10699341b3c2bc75453838afe35.R) · [methods/local-omics-analysis-guide/code/native/b6aea9259cf1e6348824afbf5aa62504cf43b01914cf06b7d7d211254776c529.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b6aea9259cf1e6348824afbf5aa62504cf43b01914cf06b7d7d211254776c529.R) · [methods/local-omics-analysis-guide/code/native/b6b3cf0b346d807e2231ef4c8e9b7c3a8f8725a974ac393f35069dcb092cbd3c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b6b3cf0b346d807e2231ef4c8e9b7c3a8f8725a974ac393f35069dcb092cbd3c.R) · [methods/local-omics-analysis-guide/code/native/b6c90be6dfb85d26b32db3b176253d11f2b38c873df772f13cb060268819ed4a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b6c90be6dfb85d26b32db3b176253d11f2b38c873df772f13cb060268819ed4a.R) · [methods/local-omics-analysis-guide/code/native/b7196a9c54c22cca376af0697e915923d4db839b960fdf78af174703cca648df.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b7196a9c54c22cca376af0697e915923d4db839b960fdf78af174703cca648df.R) · [methods/local-omics-analysis-guide/code/native/b7560a9ac038aaeb09f84d4c2c23c691c89219e64a4c30e431a496674be4f667.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b7560a9ac038aaeb09f84d4c2c23c691c89219e64a4c30e431a496674be4f667.R) · [methods/local-omics-analysis-guide/code/native/b79cc717702553d0560eb401e88026f21fe8d1fa28a15d815b166d773b92625a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b79cc717702553d0560eb401e88026f21fe8d1fa28a15d815b166d773b92625a.R) · [methods/local-omics-analysis-guide/code/native/b817bdfa8808491731f0a2f0d05b4c5f57542d6270205d1838345bee002f43d7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b817bdfa8808491731f0a2f0d05b4c5f57542d6270205d1838345bee002f43d7.R) · [methods/local-omics-analysis-guide/code/native/b8558a3655480d81d00b76bbb9298e74b2b0397c72ab06af2a7f4c6e3e1f99b2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b8558a3655480d81d00b76bbb9298e74b2b0397c72ab06af2a7f4c6e3e1f99b2.R) · [methods/local-omics-analysis-guide/code/native/b9a1fd30d09bb1acb49b2e9f761dfc61e05a11dfa0dd8f31f16662fa8e059dbf.R](/files/wiki/methods/local-omics-analysis-guide/code/native/b9a1fd30d09bb1acb49b2e9f761dfc61e05a11dfa0dd8f31f16662fa8e059dbf.R) · [methods/local-omics-analysis-guide/code/native/ba625f864535ea623b1e4c109e1f66fa6be30f7154550c7428c495fccd6839e4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ba625f864535ea623b1e4c109e1f66fa6be30f7154550c7428c495fccd6839e4.R) · [methods/local-omics-analysis-guide/code/native/bab02ed1c8c073ddefbba7662884134c19797b1dc5737e75414475dc8573d820.R](/files/wiki/methods/local-omics-analysis-guide/code/native/bab02ed1c8c073ddefbba7662884134c19797b1dc5737e75414475dc8573d820.R) · [methods/local-omics-analysis-guide/code/native/bb29ec8647950667e04e87a87de5d343ff726cb3e2014acf19f9871051c7dff7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/bb29ec8647950667e04e87a87de5d343ff726cb3e2014acf19f9871051c7dff7.R) · [methods/local-omics-analysis-guide/code/native/bbb3fe040c5e10102fbd24da607afa14249b28e9363c3f5e182e252e7e3f84e0.R](/files/wiki/methods/local-omics-analysis-guide/code/native/bbb3fe040c5e10102fbd24da607afa14249b28e9363c3f5e182e252e7e3f84e0.R) · [methods/local-omics-analysis-guide/code/native/bd473c50544534365e2a90ba7d777f6d1b2a612d099be4faf703d2590430b366.R](/files/wiki/methods/local-omics-analysis-guide/code/native/bd473c50544534365e2a90ba7d777f6d1b2a612d099be4faf703d2590430b366.R) · [methods/local-omics-analysis-guide/code/native/be97b05d73f95a74ac293dbf98abd4dfff9a05ff385908af13504f7d53c0af75.R](/files/wiki/methods/local-omics-analysis-guide/code/native/be97b05d73f95a74ac293dbf98abd4dfff9a05ff385908af13504f7d53c0af75.R) · [methods/local-omics-analysis-guide/code/native/c0263fc0c55ce75c6c8c325e4519a72ace4d8cfbad0b9ee27f5b909803516a5a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c0263fc0c55ce75c6c8c325e4519a72ace4d8cfbad0b9ee27f5b909803516a5a.R) · [methods/local-omics-analysis-guide/code/native/c083cbd50817bd60ab8f70c5e4f85169389c9085233f2f6499f009ff73b945fc.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c083cbd50817bd60ab8f70c5e4f85169389c9085233f2f6499f009ff73b945fc.R) · [methods/local-omics-analysis-guide/code/native/c0a95fb2144031fbe2175356589e94aa4b80155a5a2aafdf6f97d3a07b048ba3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c0a95fb2144031fbe2175356589e94aa4b80155a5a2aafdf6f97d3a07b048ba3.R) · [methods/local-omics-analysis-guide/code/native/c0cb08de971d9e4e6f83c0cfb28821b4bbe8197401af39832324e0f14aa5678a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c0cb08de971d9e4e6f83c0cfb28821b4bbe8197401af39832324e0f14aa5678a.R) · [methods/local-omics-analysis-guide/code/native/c1bc3b50c84b361e61ac7d1d30adfb31979a9a3bb11e0b4baa45469e033f64cd.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c1bc3b50c84b361e61ac7d1d30adfb31979a9a3bb11e0b4baa45469e033f64cd.R) · [methods/local-omics-analysis-guide/code/native/c1d207aa05572e19e0523b155df54ce6780817aa70285a5c56e98fba250cd024.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c1d207aa05572e19e0523b155df54ce6780817aa70285a5c56e98fba250cd024.R) · [methods/local-omics-analysis-guide/code/native/c1d945d324dce9d74420feb916a31fe0ca8b5ce7262adb8e1a335b7702411568.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c1d945d324dce9d74420feb916a31fe0ca8b5ce7262adb8e1a335b7702411568.R) · [methods/local-omics-analysis-guide/code/native/c20bc7ad027360a3795cbb3678e77087d6218447617e3e108b7533b8db794627.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c20bc7ad027360a3795cbb3678e77087d6218447617e3e108b7533b8db794627.R) · [methods/local-omics-analysis-guide/code/native/c65d897eaff4db1c9423eba1f4351ac66c5a30b34d28ab97278963704972c9f8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c65d897eaff4db1c9423eba1f4351ac66c5a30b34d28ab97278963704972c9f8.R) · [methods/local-omics-analysis-guide/code/native/c6fa00247ead9593cb8e38d72949f8318f76a0f672f19d8cf11a2050178de761.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c6fa00247ead9593cb8e38d72949f8318f76a0f672f19d8cf11a2050178de761.R) · [methods/local-omics-analysis-guide/code/native/c799ae73c9dec19363c7f1e4f95de6148753d4c50d8a0038ff0dfad5c9fc562f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c799ae73c9dec19363c7f1e4f95de6148753d4c50d8a0038ff0dfad5c9fc562f.R) · [methods/local-omics-analysis-guide/code/native/c823f5bcff96506c73f6c99bb00e8ba221b645c695c739701cf7ddda2603f8d8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c823f5bcff96506c73f6c99bb00e8ba221b645c695c739701cf7ddda2603f8d8.R) · [methods/local-omics-analysis-guide/code/native/c879929cd9bccb52d764ec61cf188909adb634d302298253f95bef05b99b83a1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c879929cd9bccb52d764ec61cf188909adb634d302298253f95bef05b99b83a1.R) · [methods/local-omics-analysis-guide/code/native/c90e1ddb84807d27c844563ac25a95b26fcd2031be00d02ea62f73e54b214b46.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c90e1ddb84807d27c844563ac25a95b26fcd2031be00d02ea62f73e54b214b46.R) · [methods/local-omics-analysis-guide/code/native/c939a2edb80ebae20bedbc2f561f24a96d7f7b82febbc36dbe5bad431ca0363f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c939a2edb80ebae20bedbc2f561f24a96d7f7b82febbc36dbe5bad431ca0363f.R) · [methods/local-omics-analysis-guide/code/native/c96b3874987d7c5b0023f623d1630fa8a37afd43f57ab8aaaa226923acc5446c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c96b3874987d7c5b0023f623d1630fa8a37afd43f57ab8aaaa226923acc5446c.R) · [methods/local-omics-analysis-guide/code/native/c9988eaac03c09465bebfda5becf7d02ddbd5ef21e02269e1a045a7563a6d996.R](/files/wiki/methods/local-omics-analysis-guide/code/native/c9988eaac03c09465bebfda5becf7d02ddbd5ef21e02269e1a045a7563a6d996.R) · [methods/local-omics-analysis-guide/code/native/ca27b7a0d87984550fb7ff3af66cf13b40601eb9c1e48f48542c7973d2a6bf5d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ca27b7a0d87984550fb7ff3af66cf13b40601eb9c1e48f48542c7973d2a6bf5d.R) · [methods/local-omics-analysis-guide/code/native/cb0c09e0a5f090f2fb89acbfe71261d46ba38169b1ce3f0691d16cb35a406416.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cb0c09e0a5f090f2fb89acbfe71261d46ba38169b1ce3f0691d16cb35a406416.R) · [methods/local-omics-analysis-guide/code/native/cc191fc9fdab45c242de8ded77006a00ff75359268293e453a3af171d874aeee.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cc191fc9fdab45c242de8ded77006a00ff75359268293e453a3af171d874aeee.R) · [methods/local-omics-analysis-guide/code/native/cc8cba73403907bdf5d3d8e10644325a5d20991aa413e17a416f267d7b22be1f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cc8cba73403907bdf5d3d8e10644325a5d20991aa413e17a416f267d7b22be1f.R) · [methods/local-omics-analysis-guide/code/native/ceadc432deb5677e56b926ea67800e028fccd77f6fab82cde152358417926d26.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ceadc432deb5677e56b926ea67800e028fccd77f6fab82cde152358417926d26.R) · [methods/local-omics-analysis-guide/code/native/cf0ebee5bd30fa79bf163404eaae09b61f1693e9068211dcc52af800ca3f164c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cf0ebee5bd30fa79bf163404eaae09b61f1693e9068211dcc52af800ca3f164c.R) · [methods/local-omics-analysis-guide/code/native/cf42635fd1ee11c2bbee1a16af7302b676d9a48a9321729cb4838007b6ac1720.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cf42635fd1ee11c2bbee1a16af7302b676d9a48a9321729cb4838007b6ac1720.R) · [methods/local-omics-analysis-guide/code/native/cfa9513b6437656c38413b21f3995c64ce86f19afcd501332c4d529d498aa26a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cfa9513b6437656c38413b21f3995c64ce86f19afcd501332c4d529d498aa26a.R) · [methods/local-omics-analysis-guide/code/native/cfb2bf8c5ef594f42d7ed0956795f65d377df108a1378b7bfbdc351e3542d845.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cfb2bf8c5ef594f42d7ed0956795f65d377df108a1378b7bfbdc351e3542d845.R) · [methods/local-omics-analysis-guide/code/native/cfb8aecc2bd35089a6b708d360c7eb28d6366adfc93ce4e61eed41dbee510be1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cfb8aecc2bd35089a6b708d360c7eb28d6366adfc93ce4e61eed41dbee510be1.R) · [methods/local-omics-analysis-guide/code/native/cfe7e2e7f4d3b2cb0bce1fc39693b91758697246596278582a706243844cd838.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cfe7e2e7f4d3b2cb0bce1fc39693b91758697246596278582a706243844cd838.R) · [methods/local-omics-analysis-guide/code/native/cffc13e86129db1af157346896ca282058944d4bc258ca4942b6262c54b4a152.R](/files/wiki/methods/local-omics-analysis-guide/code/native/cffc13e86129db1af157346896ca282058944d4bc258ca4942b6262c54b4a152.R) · [methods/local-omics-analysis-guide/code/native/d07c32f15699c6136e556a8e646eae193ab91ec9d9d6248b6091548a096110ea.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d07c32f15699c6136e556a8e646eae193ab91ec9d9d6248b6091548a096110ea.R) · [methods/local-omics-analysis-guide/code/native/d0f0adce298f3f97fbc0c84359bbcdffd34c333f94be74882115c5e9727bc755.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d0f0adce298f3f97fbc0c84359bbcdffd34c333f94be74882115c5e9727bc755.R) · [methods/local-omics-analysis-guide/code/native/d0f93c9815e970c556b2cfdf522b3d3aebb1f2fda34d37e1836c3ba381efac42.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d0f93c9815e970c556b2cfdf522b3d3aebb1f2fda34d37e1836c3ba381efac42.R) · [methods/local-omics-analysis-guide/code/native/d18f5f1ed2bf4d7464d491ed1bd9dd7546cab237ffc2d6245dd3f6509e87f133.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d18f5f1ed2bf4d7464d491ed1bd9dd7546cab237ffc2d6245dd3f6509e87f133.R) · [methods/local-omics-analysis-guide/code/native/d1a58a8b3d32a86c077271dfc181ce103bb15109defbf657f4e05af0c9324ebe.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d1a58a8b3d32a86c077271dfc181ce103bb15109defbf657f4e05af0c9324ebe.R) · [methods/local-omics-analysis-guide/code/native/d1edb6b16038d6135b56e1580521d55ecb809d3d5c75571ed8a7be40c956c72f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d1edb6b16038d6135b56e1580521d55ecb809d3d5c75571ed8a7be40c956c72f.R) · [methods/local-omics-analysis-guide/code/native/d31de9edba206fbdd719e81d5c5a59098e9f6ffc60bb8697a009fe3be5535e90.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d31de9edba206fbdd719e81d5c5a59098e9f6ffc60bb8697a009fe3be5535e90.R) · [methods/local-omics-analysis-guide/code/native/d39df8b549e7bd01a10557cc4c2daa4e06e386aa82460493cc3679643f508878.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d39df8b549e7bd01a10557cc4c2daa4e06e386aa82460493cc3679643f508878.R) · [methods/local-omics-analysis-guide/code/native/d3bf85b7c44e2b2d226e092b76443d636b34dd5769675d43a4a31201a9d86fd2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d3bf85b7c44e2b2d226e092b76443d636b34dd5769675d43a4a31201a9d86fd2.R) · [methods/local-omics-analysis-guide/code/native/d73ee7c25a9a35dfc318f2e7ebae6c21d3e40fdd25fe354f5a226d45b1fe268e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d73ee7c25a9a35dfc318f2e7ebae6c21d3e40fdd25fe354f5a226d45b1fe268e.R) · [methods/local-omics-analysis-guide/code/native/d8fb6e25748f95bedbf1b5024979a3295dbc79425878cc29314197336264bb38.R](/files/wiki/methods/local-omics-analysis-guide/code/native/d8fb6e25748f95bedbf1b5024979a3295dbc79425878cc29314197336264bb38.R) · [methods/local-omics-analysis-guide/code/native/dc08bb441e98640d1b557554af85e34163b2314fde22e8455ca060f497e6bff3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dc08bb441e98640d1b557554af85e34163b2314fde22e8455ca060f497e6bff3.R) · [methods/local-omics-analysis-guide/code/native/dccc770a9c99162fe4bde51e3d1eecfef596947596a6333631140c7ea8b1efa3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dccc770a9c99162fe4bde51e3d1eecfef596947596a6333631140c7ea8b1efa3.R) · [methods/local-omics-analysis-guide/code/native/dd11f1370d882bc0868283661c7348a2a4f0bf8e38796140df080cb518d48f9a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dd11f1370d882bc0868283661c7348a2a4f0bf8e38796140df080cb518d48f9a.R) · [methods/local-omics-analysis-guide/code/native/dd568956d4c7a37c20fdb5d79f7171e382dc44aa498a8cf1c6bb012f14ac62d9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dd568956d4c7a37c20fdb5d79f7171e382dc44aa498a8cf1c6bb012f14ac62d9.R) · [methods/local-omics-analysis-guide/code/native/dd58fcfb4f0202fee65be4d30eed32cc18065f892216af6d1bcd8df26c667e79.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dd58fcfb4f0202fee65be4d30eed32cc18065f892216af6d1bcd8df26c667e79.R) · [methods/local-omics-analysis-guide/code/native/ddcf390eac871d9cd82a15eac1429535cc42597868b1339f7ddd76e702fbc239.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ddcf390eac871d9cd82a15eac1429535cc42597868b1339f7ddd76e702fbc239.R) · [methods/local-omics-analysis-guide/code/native/ddd832c7e8d394469c98d716389362e06ca65e195ec2df8b3538b07e4cc1d55a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ddd832c7e8d394469c98d716389362e06ca65e195ec2df8b3538b07e4cc1d55a.R) · [methods/local-omics-analysis-guide/code/native/df425f3f2c297f8b7e068f6d0c0b1398668bb19acb85d5e3d6be6480d895bb55.R](/files/wiki/methods/local-omics-analysis-guide/code/native/df425f3f2c297f8b7e068f6d0c0b1398668bb19acb85d5e3d6be6480d895bb55.R) · [methods/local-omics-analysis-guide/code/native/df53c9744118a2a60535288e220e38f18495a48b8c206778badea44b21f8da4b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/df53c9744118a2a60535288e220e38f18495a48b8c206778badea44b21f8da4b.R) · [methods/local-omics-analysis-guide/code/native/dfa94d3b31ee6fd591ccc751e43532692066b968c0ea61e35e01132e790353c9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dfa94d3b31ee6fd591ccc751e43532692066b968c0ea61e35e01132e790353c9.R) · [methods/local-omics-analysis-guide/code/native/dfbc2f458e563d83a1289594b6d23f7658f4a460f9a932ee0dd1f9217722175b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/dfbc2f458e563d83a1289594b6d23f7658f4a460f9a932ee0dd1f9217722175b.R) · [methods/local-omics-analysis-guide/code/native/e003e60346ee69bd36f8f45848ddebc790bc56279d38f8f0ec891ba53f9a85ef.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e003e60346ee69bd36f8f45848ddebc790bc56279d38f8f0ec891ba53f9a85ef.R) · [methods/local-omics-analysis-guide/code/native/e12432afe99c5157455d255bebe7c61bd4727bcb5b309be1fcf948c7cabb5de6.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e12432afe99c5157455d255bebe7c61bd4727bcb5b309be1fcf948c7cabb5de6.R) · [methods/local-omics-analysis-guide/code/native/e26316d7e591d9b41b0eb30a69ff04938b75e7005e7fa96fbae2ac22462ca58b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e26316d7e591d9b41b0eb30a69ff04938b75e7005e7fa96fbae2ac22462ca58b.R) · [methods/local-omics-analysis-guide/code/native/e33d26b29576596042d18863be9ea78776633e5516c11803564b9cfcbfad91e5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e33d26b29576596042d18863be9ea78776633e5516c11803564b9cfcbfad91e5.R) · [methods/local-omics-analysis-guide/code/native/e347b1a5ffd7ac641cb530df01f91786233a7dbf1b735f36960c8b1358b877b4.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e347b1a5ffd7ac641cb530df01f91786233a7dbf1b735f36960c8b1358b877b4.R) · [methods/local-omics-analysis-guide/code/native/e3ab135cbc9e5937a131ff721336e62f9728e44d559237defebf1b4c0a1b919c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e3ab135cbc9e5937a131ff721336e62f9728e44d559237defebf1b4c0a1b919c.R) · [methods/local-omics-analysis-guide/code/native/e3eb44dba5d1824dd08b23e2da6c056bd5e48cb319038700f443d347d98baea7.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e3eb44dba5d1824dd08b23e2da6c056bd5e48cb319038700f443d347d98baea7.R) · [methods/local-omics-analysis-guide/code/native/e58f963a0db56956600b9e6c353675580247c4a18d59766e9db761f2b1249d39.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e58f963a0db56956600b9e6c353675580247c4a18d59766e9db761f2b1249d39.R) · [methods/local-omics-analysis-guide/code/native/e65b59c6e57a518f4e6382bbb52f37f23840d66cd552f92301069d8841afdc5e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e65b59c6e57a518f4e6382bbb52f37f23840d66cd552f92301069d8841afdc5e.R) · [methods/local-omics-analysis-guide/code/native/e779648040352849467cc823445a5f86bfc2ef0fff9938dbc57d6957f37e5463.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e779648040352849467cc823445a5f86bfc2ef0fff9938dbc57d6957f37e5463.R) · [methods/local-omics-analysis-guide/code/native/e78320348c2f34efef34debb4d1fc566c758276160b5ddf4f0d4fbe712668b76.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e78320348c2f34efef34debb4d1fc566c758276160b5ddf4f0d4fbe712668b76.R) · [methods/local-omics-analysis-guide/code/native/e7f5749ae87396fadf4ee9affac617fae2c41ea3bba7b1121159b90bbbc49962.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e7f5749ae87396fadf4ee9affac617fae2c41ea3bba7b1121159b90bbbc49962.R) · [methods/local-omics-analysis-guide/code/native/e982330a94344eaea695c00334dc7b743641f4700804f8834df28ba32f37fd20.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e982330a94344eaea695c00334dc7b743641f4700804f8834df28ba32f37fd20.R) · [methods/local-omics-analysis-guide/code/native/e9af6fab405246bdb60192a8b36fa93962ecfec1944e641a12e17c6ea3841b29.R](/files/wiki/methods/local-omics-analysis-guide/code/native/e9af6fab405246bdb60192a8b36fa93962ecfec1944e641a12e17c6ea3841b29.R) · [methods/local-omics-analysis-guide/code/native/ea03ee25f4798dbfeae1a001bd4d7f3bb59d282ce00bbf5138fde7e131f3e34b.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ea03ee25f4798dbfeae1a001bd4d7f3bb59d282ce00bbf5138fde7e131f3e34b.R) · [methods/local-omics-analysis-guide/code/native/ec00902912e10592334acf13d97d2101f5f2165b733613a636b2ec9ed122aaff.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ec00902912e10592334acf13d97d2101f5f2165b733613a636b2ec9ed122aaff.R) · [methods/local-omics-analysis-guide/code/native/ed8e526e6641d2d4aa415ef2509852d38391c24a03456abd6c3b622ed82b3de1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ed8e526e6641d2d4aa415ef2509852d38391c24a03456abd6c3b622ed82b3de1.R) · [methods/local-omics-analysis-guide/code/native/edc32b06a21c74b6b044856f45abe608bfc62a87ff3019ff625a04e5d8b0d713.R](/files/wiki/methods/local-omics-analysis-guide/code/native/edc32b06a21c74b6b044856f45abe608bfc62a87ff3019ff625a04e5d8b0d713.R) · [methods/local-omics-analysis-guide/code/native/edf4aa2af043f743db87e3e7295f4b4a7d1b8021bf2ce93e5351f13637db4ae9.R](/files/wiki/methods/local-omics-analysis-guide/code/native/edf4aa2af043f743db87e3e7295f4b4a7d1b8021bf2ce93e5351f13637db4ae9.R) · [methods/local-omics-analysis-guide/code/native/eeb312bd4fa8d644a8b690be9987246dc3733bef5ebee99a63dc509feaba3303.R](/files/wiki/methods/local-omics-analysis-guide/code/native/eeb312bd4fa8d644a8b690be9987246dc3733bef5ebee99a63dc509feaba3303.R) · [methods/local-omics-analysis-guide/code/native/ef5f2b84a90eae6f8e81c09794d2d16a92248ee09bb7f35d412b9ef91f598f21.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ef5f2b84a90eae6f8e81c09794d2d16a92248ee09bb7f35d412b9ef91f598f21.R) · [methods/local-omics-analysis-guide/code/native/f07495479586b84c64916ca9d253feb726094644a72688613a7c590b659df4f5.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f07495479586b84c64916ca9d253feb726094644a72688613a7c590b659df4f5.R) · [methods/local-omics-analysis-guide/code/native/f213782cac868c8f9d8c95dfee44f201f210cfc1eca712735ce6d89bd05d94fa.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f213782cac868c8f9d8c95dfee44f201f210cfc1eca712735ce6d89bd05d94fa.R) · [methods/local-omics-analysis-guide/code/native/f447294645eb478ea09d1c94d174271be37fe21acc948581c1300cfe4ce04c5d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f447294645eb478ea09d1c94d174271be37fe21acc948581c1300cfe4ce04c5d.R) · [methods/local-omics-analysis-guide/code/native/f49aef5a2396fa9fd0f8c53a8566140343ac07d6a603ce2128d72e8e4d9b8439.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f49aef5a2396fa9fd0f8c53a8566140343ac07d6a603ce2128d72e8e4d9b8439.R) · [methods/local-omics-analysis-guide/code/native/f4a6e18c119dcc03870dbd16bcfb06897417ddbcdd1a825a088e6ac245c53f0d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f4a6e18c119dcc03870dbd16bcfb06897417ddbcdd1a825a088e6ac245c53f0d.R) · [methods/local-omics-analysis-guide/code/native/f5c7c408e2c34e34dd5ce214df98b33d576bdd9578e0632e56b8cd65270a8559.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f5c7c408e2c34e34dd5ce214df98b33d576bdd9578e0632e56b8cd65270a8559.R) · [methods/local-omics-analysis-guide/code/native/f65eea97cd16c84f09b86c14c808fa02ad67a9de6965376148e4480e47b53a52.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f65eea97cd16c84f09b86c14c808fa02ad67a9de6965376148e4480e47b53a52.R) · [methods/local-omics-analysis-guide/code/native/f663506f8df900f7020da324c806ae2fa03881169156effa4ceaffa8fc6c084e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f663506f8df900f7020da324c806ae2fa03881169156effa4ceaffa8fc6c084e.R) · [methods/local-omics-analysis-guide/code/native/f7163f226ab375adc011a9cb58212684822603b10dedd8bbc9a0039d67588297.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f7163f226ab375adc011a9cb58212684822603b10dedd8bbc9a0039d67588297.R) · [methods/local-omics-analysis-guide/code/native/f741696076c9997d8ffb3eeb181e011737addd6dd96a70a79a4731dbde7cf5ef.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f741696076c9997d8ffb3eeb181e011737addd6dd96a70a79a4731dbde7cf5ef.R) · [methods/local-omics-analysis-guide/code/native/f88613d2d8827c9788db861307dd66e2c64f3d6ef7afa5df4d7037427fe91e8a.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f88613d2d8827c9788db861307dd66e2c64f3d6ef7afa5df4d7037427fe91e8a.R) · [methods/local-omics-analysis-guide/code/native/f8f2900008c2d0e5344d85935395ace8b90c572e1772c2ed632583bf4db8843e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f8f2900008c2d0e5344d85935395ace8b90c572e1772c2ed632583bf4db8843e.R) · [methods/local-omics-analysis-guide/code/native/f93138a0516c395f2ed4af438e08fb863393395dd068d433617622e44fc9d00c.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f93138a0516c395f2ed4af438e08fb863393395dd068d433617622e44fc9d00c.R) · [methods/local-omics-analysis-guide/code/native/f9dd3622443e0d55028b13ca6478634fb93818c0cc31e06ef72c73695aa9209f.R](/files/wiki/methods/local-omics-analysis-guide/code/native/f9dd3622443e0d55028b13ca6478634fb93818c0cc31e06ef72c73695aa9209f.R) · [methods/local-omics-analysis-guide/code/native/fa88cb7666fa6488cc92d02a54b64cf2637ae1209d1ba9bb2c3ea5d8835d4784.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fa88cb7666fa6488cc92d02a54b64cf2637ae1209d1ba9bb2c3ea5d8835d4784.R) · [methods/local-omics-analysis-guide/code/native/facc4185d80331d685c06e69711ffcd04d825fdc5aa6aee990257b8264a73b23.R](/files/wiki/methods/local-omics-analysis-guide/code/native/facc4185d80331d685c06e69711ffcd04d825fdc5aa6aee990257b8264a73b23.R) · [methods/local-omics-analysis-guide/code/native/fb0cb35c684ecaef241a74ce2cbadf02d74e9e9c2cc96192f9fcc6eb9185e7b8.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fb0cb35c684ecaef241a74ce2cbadf02d74e9e9c2cc96192f9fcc6eb9185e7b8.R) · [methods/local-omics-analysis-guide/code/native/fd5d7807e2c5f256ef9e9e4af3d45a181e5553a91aef3e61a3a685c34c54078d.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fd5d7807e2c5f256ef9e9e4af3d45a181e5553a91aef3e61a3a685c34c54078d.R) · [methods/local-omics-analysis-guide/code/native/fdace1d4d400dd6305bfea772e48c03a00b4027cfd22e0d21a50d844c4f6be23.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fdace1d4d400dd6305bfea772e48c03a00b4027cfd22e0d21a50d844c4f6be23.R) · [methods/local-omics-analysis-guide/code/native/fde44f4273f78052aeab2e7bb982f0badfdb5b040a7aaaa680f8a3795dc9f38e.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fde44f4273f78052aeab2e7bb982f0badfdb5b040a7aaaa680f8a3795dc9f38e.R) · [methods/local-omics-analysis-guide/code/native/fe91c6b765003e4a807564e4911db8fbae287555bfd5fb3560333a4a886c22a2.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fe91c6b765003e4a807564e4911db8fbae287555bfd5fb3560333a4a886c22a2.R) · [methods/local-omics-analysis-guide/code/native/fea9747e4d20e80d706bc6294aa5f81fde3eababeb11f1ee97ee1ea5db578cc3.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fea9747e4d20e80d706bc6294aa5f81fde3eababeb11f1ee97ee1ea5db578cc3.R) · [methods/local-omics-analysis-guide/code/native/ffcf17c56a73ff6e751cc33e20c2baa30a85aa36ef8dedff9327e69d634f5de1.R](/files/wiki/methods/local-omics-analysis-guide/code/native/ffcf17c56a73ff6e751cc33e20c2baa30a85aa36ef8dedff9327e69d634f5de1.R) · [methods/local-omics-analysis-guide/code/native/fffe578e5d5378d2780d45901bc5afbe50cb39a41471306588fc0bc535b4d5ed.R](/files/wiki/methods/local-omics-analysis-guide/code/native/fffe578e5d5378d2780d45901bc5afbe50cb39a41471306588fc0bc535b4d5ed.R) · [methods/local-omics-analysis-guide/code/native.R](/files/wiki/methods/local-omics-analysis-guide/code/native.R) · [methods/local-omics-analysis-guide/code/native_cases.R](/files/wiki/methods/local-omics-analysis-guide/code/native_cases.R) · [methods/local-omics-analysis-guide/code/registry.json](/files/wiki/methods/local-omics-analysis-guide/code/registry.json) · [methods/local-omics-analysis-guide/code/registry.rds](/files/wiki/methods/local-omics-analysis-guide/code/registry.rds) · [methods/local-omics-analysis-guide/code/stacking_original.py](/files/wiki/methods/local-omics-analysis-guide/code/stacking_original.py) · [methods/local-omics-analysis-guide/code/stacking_runner.py](/files/wiki/methods/local-omics-analysis-guide/code/stacking_runner.py)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

按研究问题、输入语义、统计单位、估计目标和算法边界整理来源；文件名和包名只作线索。规范 analysis 家族数量保持不变。

## 适用

需要从两个课题找方法、判断同义条目、辨别 irGSEA 打分/整合和五分数求和、选择模型/轨迹/网络分支时。

## 不适用

代码存在、成功 use、source 或 --help 均不授予科学或完整流程验证。只有各实现当前收据覆盖的用例有运行证据；其余为 not_run，页面保持 draft。禁止将少数用例通过扩展为整库、整个函数所有参数或真实课题有效性已验证。

## 输入

来源账本含逐文件相对路径、原语言、SHA-256、角色、调用位置及语法检查。数据语义按上游 Seurat、表达矩阵、样本预测、CellChat、空间对象分别阅读；没有因相近列名新造接口。

## 怎么做

`rwiki use local-omics-analysis-guide --project <已存在课题目录>`，再在副本中选择已明确的入口。先读 function-catalog.json 的原签名、变量候选、来源位置、闭包、blocked 和逐用例状态；arguments 对应原函数形参，bindings 显式提供原全局参数/资源/函数。数据掩码列名候选不自动当成应补值的全局变量。不要把整份原课题脚本 source 执行。

## 来源到规范家族对照

| 分析目的 | 来源/实现 | 规范去向 | 判断 |
|---|---|---|---|
| 质控、整合与降维聚类 | 两目录 Seurat/Harmony 单细胞步骤 | cell-quality-control / batch-integration / dimensionality-reduction / cell-clustering | 保留过滤、assay/slot、批次列和 PC/聚类参数；不是新家族，现有实现验证不授予本来源 |
| marker 与参考注释 | UC 15、哮喘 3 | cell-type-annotation | marker 手工标签与 SingleR 参考预测不同实现；绘图不能替代注释证据 |
| bulk/单细胞差异 | limma、FindMarkers/FindAllMarkers | differential-expression | 模型、比较、样本/细胞单位不同；不把 p 值列相同当统计等价 |
| 基因集/通路签名 | UC SCORE/PTMD/空间、哮喘 lactylation/114/MBDs | gene-set-scoring | AddModuleScore/AUCell/UCell/singscore/ssGSEA 是不同实现；五分数求和为特定后处理 |
| irGSEA 多算法打分 | UC 功能/轨迹、哮喘 RCC2/轨迹 | gene-set-scoring | irGSEA.score 为打分入口；不是因为最后出热图就只记作绘图 |
| irGSEA 组间整合与 RRA | 同上 irGSEA.integrate→irGSEA.heatmap | gene-set-enrichment（候选技术来源） | 按 group/Monocle2_State 组织结果；RRA 与五分数直接求和不同；热图消费整合结果 |
| ORA / ranked GSEA | clusterProfiler/GSVA/GseaVis | gene-set-enrichment / gene-set-scoring | 按真实调用区分过度富集、排名富集与逐样本/细胞分数，不能笼统合并 |
| Monocle2 轨迹 | SCP RunMonocle2 / monocle orderCells | trajectory-inference | 新来源的参数/选细胞版本；不继承已验证的 Slingshot 分支 |
| 动态拟合/显示 | DynamicPlotMonocle2、SCP 动态入口 | dynamic-feature-analysis + scp-viz-model-overlays | 自定义 GAM 会重拟合；依赖原图也要逐选项核对是否触发 RunDynamicFeatures |
| 训练/模型组合与评价 | UC/哮喘 GMM-LR、ROC/CV、stacking/DNN | regression-resampling-evaluation（上游来源） | Mclust 对模型 AUC 分组不是细胞聚类；训练与指标汇总是不同范围 |
| 模型解释 | kernelshap/shapviz/LIME、Python explain | shap-explanation | 解释具体模型与数据；SHAP 来源不继承既有线性模型验证，LIME 不当成 SHAP |
| 共表达网络 | bulk WGCNA 与 hdWGCNA metacells | 本页技术导航；尚无规范家族 | 同为共表达目的但输入/单位/聚合不同；两个来源版本不拆成多个同义算法 |
| 一致性分型 | 两目录 ConsensusClusterPlus | 本页技术导航；尚无规范家族 | bulk/签名矩阵样本亚型不等于单细胞图聚类；参数差别是配置 |
| CellChat 通信 | 单细胞主线与 RCTD spot 分支 | 本页技术导航 + uc-spatial-workflows | 共同通信目标，单细胞/spot 输入假设不同；netVisual 是依赖绘图 |
| Augur / scTenifoldKnk | UC 17 原版 / 整理版 | 本页技术导航；尚无规范家族 | 前者细胞类型状态可分性，后者虚拟敲除；不同目标，不能合并或声称实验验证 |
| 免疫推断 / 代谢物 | UC IOBR；哮喘 metabolism.R | 本页技术导航；尚无规范家族 | 免疫分数、比例、代谢物丰度与 RNA 通路分数分别记录 |
| 空间反卷积/域/邻域 | UC 原目录与整理版空间分支 | uc-spatial-workflows | RCTD、BayesSpace、Moran’s I 与 CellTrek 不互换，旧伪超分辨分支保留历史标识 |

逐文件候选映射见 [family-map.json](/files/wiki/methods/local-omics-analysis-guide/family-map.json)。该表保留全部来源及其去向；subset 等通用调用只提供候选线索，不单凭调用自动认定科学目的。

## 字节与语义去重

291 份代码文件共有 242 个不同 SHA-256，49 份冗余字节引用；相同内容只存一个外部快照对象，原目录与各副本路径都保留。不是删除 49 个原文件，也不意味着 242 个方法。现有 Wiki methods/templates 的 .R/.py/.Rmd 未发现与这批完全相同的字节；这不排除语义重复或外部快照已有相同文件。

跨目录完全相同的两组：UC `16.20种修饰量化/1.R`（含整理副本）与哮喘 `4.乳酸化评分/dotplot.R`；UC 整理版 `18.拟时序分析/code/DynamicPlot.R` 与哮喘 `16.细胞轨迹/DynamicPlot.R`。非同字节的整理/投稿版本均保留，并不自动选其为最新版。全部重复组见 [dedup-map.json](/files/wiki/methods/local-omics-analysis-guide/dedup-map.json)。

## 静态核查与明确缺口

130 个可可靠解码的非历史不同字节 R 文件做 parse/getParseData，只解析不求值：129 个语法可解析，1 个 parse_error（哮喘 `8.百种机器学习/14.MLdata/3个/geoML14.MLdata.R` 第 5 行非法反斜杠转义）。`8.百种机器学习/15.ML/refer2.ML.R` 不能可靠解码，保留原字节、不猜编码修稿。Python 只做 AST 解析；notebook 不执行，含输出不当证据。上述检查不是运行或算法验证。

## 代码

代码通过 use 复制到课题。R 基础用例：

```r
mod <- new.env(parent = baseenv())
source(file.path(copy_dir, "code", "native_cases.R"), local = mod)
result <- mod$native_normalize(x = actual_numeric_vector)
result$value
result$diagnostics
```

更一般的原函数调用：source 副本的 `code/native.R` 后，`run_local_r_function(function_id, arguments=list(...), bindings=list(...))`；function_id 由 function-catalog.json 精确选择，不按相同函数名合并源码版本。无包装前缀的原函数名不向调用环境泄漏。入口通过当前模块 ofile 定位，必须用 source(file, local=...)；无 ofile 的 sys.source 不受支持。运行前后恢复 search/options/.libPaths/RNG，新增 namespace 可保留，未覆盖的原函数副作用仍需逐用例核验。

Python：`code/binary_evaluation.py` 的 eval_binary、compute_specificity、youden_threshold、bootstrap_ci_auc、get_proba 保持原函数体。标签必须明确为 0/1，不能把表达值猜作概率。`code/stacking_runner.py:run_stacking_cli` 要求显式 data_path、label_col、gene_list_path、outdir 和 step，调用未改写的原 CLI；--help 成功不代表模型训练通过。

irGSEA.score / irGSEA.integrate、ConsensusClusterPlus、CellChat createCellChat、GSVA 的调用适配在 `code/dependency_analysis.R`。`run_omics_dependency_analysis(branch, arguments)` 原样转交显式参数，不安装包、不重实现算法；缺参数对象或依赖时不得执行推荐。

## 输出

返回原函数值及必要诊断，或依赖原生绘图结果；Python ROC 返回 figure/axes。实际数据与成图由调用者留在课题目录。本页为 technical，不新增同义 analysis 家族或 L2 单 panel 模板。

## 知识关联检查

关联 [[methods/cell-quality-control]]、[[methods/batch-integration]]、[[methods/dimensionality-reduction]]、[[methods/cell-clustering]]、[[methods/cell-type-annotation]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/trajectory-inference]]、[[methods/dynamic-feature-analysis]]、[[methods/regression-resampling-evaluation]]、[[methods/shap-explanation]]；SCP 图形保留 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-heatmaps]]、[[methods/scp-viz-model-overlays]]，详见 [[methods/local-omics-visualization-guide]]。无图关系的原因：本批只有来源知识，无新可执行分析输出或验证模板接口，不凭格式相似建立 direct。

## 使用记录

2026-11-02：方法语义审查与来源合并。现有实现、收据、作者块和 ready 状态不改；本页 draft。

## 代码复用层覆盖（2026-11-02）

532 处顶层 R 函数定义保留各自源码上下文，448 处允许通过私有入口选取，按原函数声明字节去重后有 355 个定义文件；84 处安装、清理、外部进程、硬编码路径或连带相关 helper 被隔离。数字是代码出现次数/文件数，不是分析方法数。重复定义、源脚本改写版和原包调用不被压成一个科学实现。

原声明按已识别编码提取，派生文件采用 UTF-8，source/ 保留原字节；转码版本不宣称原字节一致。依赖同名 helper 默认取同版文件末次定义；分阶段重定义的原流程需要按实际调用时点另核对，未给等价性保证。

原文件以原语言、原字节进入 ignored source/，提取/适配进入 ignored code/；原项目、外部来源快照、作者区块不改。code-manifest.json、source-manifest.json、function-catalog.json 和 reuse-coverage.json 给出逐文件去向及代码哈希。来源整个脚本的执行状态仍不因一个函数通过而提升。

没有顶层函数的脚本、未可靠解码脚本、notebook、历史材料及依赖原工作树/外部样式资源的流程，保留逐项 disposition。原函数目录可复制不等于整条原工作流已经函数化；WGCNA/hdWGCNA 的完整建网、全模型训练、空间整流程等没有冒充通过。

## 当前运行证据与缺口

已完成原版对照和“只复制声明文件→异目录→新进程→不提供原代码路径”的 9 个本页用例：native-normalize、native-gini、native-combinations、native-gmt，以及 5 个 py-* 评价函数。R 用例使用原项目真实表达向量、基因名单或 GMT；Python 使用原项目固定 290 例训练、124 例测试数据，单一 LR 只生成验证输入，不代表原 stacking 流程或无泄漏验收。图形页另有 1 个预计算 ROC 用例通过。

irGSEA、SCP 包本体、CellChat、ConsensusClusterPlus、singscore/AUCell/UCell、WGCNA/hdWGCNA/scTenifoldKnk 等未安装，不自动装包。本环境还独立复现 R 4.5.0 加载 rlang 后退出码 3221225477（有符号 -1073741819）；需要该依赖栈的分支不能因中途输出图或数值就标通过。

DynamicPlotMonocle2 实际调用触发 SeuratObject 5 的 GetAssayData(slot=...) defunct；未偷偷替换为 layer 或改拟合。DotPlotScores 的全局比例计算保留，原版参照还缺调用上下文的 ggplot 绑定，本例未通过；缺依赖/失败和输入缺口详见各自 not_run 收据。Addsingscore 的 assay=null 默认拼写及签名方向处理保留。完整 stacking 的 scikit-optimize 等环境缺口与选模/切分边界未验收。

## 本次复用整理记录

作者明确要求继续代码复用层整理。补入可复制函数/适配器、闭包清单、逐文件去向和受限真实数据用例证据；没有安装包、修改原统计逻辑、合成科研数据或改变作者状态。`rwiki use` 已在独立目录实际执行，成功复制不授予全部依赖齐备或全部分支可运行。

<!-- user:start -->
<!-- user:end -->
