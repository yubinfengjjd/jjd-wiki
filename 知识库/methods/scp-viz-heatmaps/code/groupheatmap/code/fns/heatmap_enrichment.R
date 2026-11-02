# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7297-7539
# sha256(func-block)=7b01debc3c94e4d2bbce0acb9abd7efb1355ef6493457be3fabff7e555e6643e
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
heatmap_enrichment <- function(geneID, geneID_groups, feature_split_palette = "simspec", feature_split_palcolor = NULL, ha_right = NULL, flip = FALSE,
                               anno_terms = FALSE, anno_keys = FALSE, anno_features = FALSE,
                               terms_width = unit(4, "in"), terms_fontsize = 8,
                               keys_width = unit(2, "in"), keys_fontsize = c(6, 10),
                               features_width = unit(2, "in"), features_fontsize = c(6, 10),
                               IDtype = "symbol", species = "Homo_sapiens", db_update = FALSE, db_combine = FALSE, db_version = "latest", convert_species = FALSE, Ensembl_version = 103, mirror = NULL,
                               db = "GO_BP", TERM2GENE = NULL, TERM2NAME = NULL, minGSSize = 10, maxGSSize = 500,
                               GO_simplify = FALSE, GO_simplify_cutoff = "p.adjust < 0.05", simplify_method = "Wang", simplify_similarityCutoff = 0.7,
                               pvalueCutoff = NULL, padjustCutoff = 0.05, topTerm = 5, show_termid = FALSE, topWord = 20, words_excluded = NULL) {
  res <- NULL
  words_excluded <- words_excluded %||% words_excluded

  if (isTRUE(anno_keys) || isTRUE(anno_features) || isTRUE(anno_terms)) {
    if (isTRUE(flip)) {
      stop("anno_keys, anno_features and anno_terms can only be used when flip is FALSE.")
    }
    if (all(is.na(geneID_groups))) {
      geneID_groups <- rep(1, length(geneID))
    }
    if (!is.factor(geneID_groups)) {
      geneID_groups <- factor(geneID_groups, levels = unique(geneID_groups))
    }
    fill_split <- palette_scp(levels(geneID_groups), type = "discrete", palette = feature_split_palette, palcolor = feature_split_palcolor)[levels(geneID_groups) %in% geneID_groups]
    res <- RunEnrichment(
      geneID = geneID, geneID_groups = geneID_groups, IDtype = IDtype, species = species,
      db_update = db_update, db_version = db_version, db_combine = db_combine, convert_species = convert_species, Ensembl_version = Ensembl_version, mirror = mirror,
      db = db, TERM2GENE = TERM2GENE, TERM2NAME = TERM2NAME, minGSSize = minGSSize, maxGSSize = maxGSSize,
      GO_simplify = GO_simplify, GO_simplify_cutoff = GO_simplify_cutoff, simplify_method = simplify_method, simplify_similarityCutoff = simplify_similarityCutoff
    )
    if (isTRUE(db_combine)) {
      db <- "Combined"
    }
    if (isTRUE(GO_simplify) && any(db %in% c("GO_BP", "GO_CC", "GO_MF"))) {
      db[db %in% c("GO_BP", "GO_CC", "GO_MF")] <- paste0(db[db %in% c("GO_BP", "GO_CC", "GO_MF")], "_sim")
    }
    if (nrow(res$enrichment) == 0) {
      warning("No enrichment result found.", immediate. = TRUE)
    } else {
      metric <- ifelse(is.null(padjustCutoff), "pvalue", "p.adjust")
      metric_value <- ifelse(is.null(padjustCutoff), pvalueCutoff, padjustCutoff)
      pvalueCutoff <- ifelse(is.null(pvalueCutoff), 1, pvalueCutoff)
      padjustCutoff <- ifelse(is.null(padjustCutoff), 1, padjustCutoff)

      df <- res$enrichment
      df <- df[df[["Database"]] %in% db, , drop = FALSE]
      df <- df[df[[metric]] < metric_value, , drop = FALSE]
      df <- df[order(df[[metric]]), , drop = FALSE]
      if (nrow(df) == 0) {
        warning(
          "No term enriched using the threshold: ",
          paste0("pvalueCutoff = ", pvalueCutoff), "; ",
          paste0("padjustCutoff = ", padjustCutoff),
          immediate. = TRUE
        )
      } else {
        df_list <- split.data.frame(df, ~ Database + Groups)
        df_list <- df_list[lapply(df_list, nrow) > 0]

        for (enrich in db) {
          nm <- strsplit(names(df_list), "\\.")
          subdf_list <- df_list[unlist(lapply(nm, function(x) x[[1]])) %in% enrich]
          if (length(subdf_list) == 0) {
            warning(
              "No ", enrich, " term enriched using the threshold: ",
              paste0("pvalueCutoff = ", pvalueCutoff), "; ",
              paste0("padjustCutoff = ", padjustCutoff),
              immediate. = TRUE
            )
            next
          }
          nm <- strsplit(names(subdf_list), "\\.")

          ha_terms <- NULL
          if (isTRUE(anno_terms)) {
            terms_list <- lapply(subdf_list, function(df) {
              if (isTRUE(show_termid)) {
                terms <- paste(head(df$ID, topTerm), head(df$Description, topTerm))
              } else {
                terms <- head(df$Description, topTerm)
                terms <- capitalize(terms)
              }
              df_out <- data.frame(keyword = terms)
              df_out[["col"]] <- palette_scp(-log10(head(df[, metric], topTerm)), type = "continuous", palette = "Spectral", matched = TRUE)
              df_out[["col"]] <- sapply(df_out[["col"]], function(x) blendcolors(c(x, "black")))
              df_out[["fontsize"]] <- rep(terms_fontsize, nrow(df_out))
              return(df_out)
            })
            names(terms_list) <- unlist(lapply(nm, function(x) x[[2]]))
            if (length(intersect(geneID_groups, names(terms_list))) > 0) {
              ha_terms <- HeatmapAnnotation(
                "terms_empty" = anno_empty(width = unit(0.05, "in"), border = FALSE, which = "row"),
                "terms_split" = anno_block(
                  gp = gpar(fill = fill_split),
                  width = unit(0.1, "in"),
                  which = "row"
                ),
                "terms" = anno_textbox(
                  align_to = geneID_groups, text = terms_list, max_width = terms_width,
                  word_wrap = TRUE, add_new_line = TRUE,
                  background_gp = gpar(fill = "grey98", col = "black"), round_corners = TRUE,
                  which = "row"
                ),
                which = "row", gap = unit(0, "points")
              )
              names(ha_terms) <- paste0(names(ha_terms), "_", enrich)
            }
          }

          ha_keys <- NULL
          if (isTRUE(anno_keys)) {
            check_R("jokergoo/simplifyEnrichment")
            keys_list <- lapply(subdf_list, function(df) {
              if (all(df$Database %in% c("GO", "GO_BP", "GO_CC", "GO_MF"))) {
                df0 <- simplifyEnrichment::keyword_enrichment_from_GO(df[["ID"]])
                if (nrow(df0) > 0) {
                  df <- df0 %>%
                    reframe(
                      keyword = .data[["keyword"]],
                      score = -(log10(.data[["padj"]])),
                      count = .data[["n_term"]],
                      Database = df[["Database"]][1],
                      Groups = df[["Groups"]][1]
                    ) %>%
                    filter(!grepl(pattern = "\\[.*\\]", x = .data[["keyword"]])) %>%
                    filter(nchar(.data[["keyword"]]) >= 1) %>%
                    filter(!tolower(.data[["keyword"]]) %in% tolower(words_excluded)) %>%
                    distinct() %>%
                    mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
                    as.data.frame()
                  df <- df[head(order(df[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
                } else {
                  df <- NULL
                }
              } else {
                df <- df %>%
                  mutate(keyword = strsplit(tolower(as.character(.data[["Description"]])), " ")) %>%
                  unnest(cols = "keyword") %>%
                  group_by(.data[["keyword"]], Database, Groups) %>%
                  reframe(
                    keyword = .data[["keyword"]],
                    score = sum(-(log10(.data[[metric]]))),
                    count = n(),
                    Database = .data[["Database"]],
                    Groups = .data[["Groups"]],
                    .groups = "keep"
                  ) %>%
                  filter(!grepl(pattern = "\\[.*\\]", x = .data[["keyword"]])) %>%
                  filter(nchar(.data[["keyword"]]) >= 1) %>%
                  filter(!tolower(.data[["keyword"]]) %in% tolower(words_excluded)) %>%
                  distinct() %>%
                  mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
                  as.data.frame()
                df <- df[head(order(df[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
              }
              if (isTRUE(nrow(df) > 0)) {
                df[["col"]] <- palette_scp(df[, "score"], type = "continuous", palette = "Spectral", matched = TRUE)
                df[["col"]] <- sapply(df[["col"]], function(x) blendcolors(c(x, "black")))
                df[["fontsize"]] <- rescale(df[, "count"], to = keys_fontsize)
                return(df)
              } else {
                return(NULL)
              }
            })
            names(keys_list) <- unlist(lapply(nm, function(x) x[[2]]))
            keys_list <- keys_list[lapply(keys_list, length) > 0]
            if (length(intersect(geneID_groups, names(keys_list))) > 0) {
              ha_keys <- HeatmapAnnotation(
                "keys_empty" = anno_empty(width = unit(0.05, "in"), border = FALSE, which = "row"),
                "keys_split" = anno_block(
                  gp = gpar(fill = fill_split),
                  width = unit(0.1, "in"),
                  which = "row"
                ),
                "keys" = anno_textbox(
                  align_to = geneID_groups, text = keys_list, max_width = keys_width,
                  background_gp = gpar(fill = "grey98", col = "black"), round_corners = TRUE,
                  which = "row"
                ),
                which = "row", gap = unit(0, "points")
              )
              names(ha_keys) <- paste0(names(ha_keys), "_", enrich)
            }
          }

          ha_features <- NULL
          if (isTRUE(anno_features)) {
            features_list <- lapply(subdf_list, function(df) {
              df <- df %>%
                mutate(keyword = strsplit(as.character(.data[["geneID"]]), "/")) %>%
                unnest(cols = "keyword") %>%
                group_by(.data[["keyword"]], Database, Groups) %>%
                reframe(
                  keyword = .data[["keyword"]],
                  score = sum(-(log10(.data[[metric]]))),
                  count = n(),
                  Database = .data[["Database"]],
                  Groups = .data[["Groups"]],
                  .groups = "keep"
                ) %>%
                distinct() %>%
                mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(60, 40))) %>%
                as.data.frame()
              df <- df[head(order(df[["score"]], decreasing = TRUE), topWord), , drop = FALSE]
              df[["col"]] <- palette_scp(df[, "score"], type = "continuous", palette = "Spectral", matched = TRUE)
              df[["col"]] <- sapply(df[["col"]], function(x) blendcolors(c(x, "black")))
              df[["fontsize"]] <- rescale(df[, "count"], to = features_fontsize)
              return(df)
            })
            names(features_list) <- unlist(lapply(nm, function(x) x[[2]]))
            if (length(intersect(geneID_groups, names(features_list))) > 0) {
              ha_features <- HeatmapAnnotation(
                "features_empty" = anno_empty(width = unit(0.05, "in"), border = FALSE, which = "row"),
                "features_split" = anno_block(
                  gp = gpar(fill = fill_split),
                  width = unit(0.1, "in"),
                  which = "row"
                ),
                "features" = anno_textbox(
                  align_to = geneID_groups, text = features_list, max_width = features_width,
                  background_gp = gpar(fill = "grey98", col = "black"), round_corners = TRUE,
                  which = "row"
                ),
                which = "row", gap = unit(0, "points")
              )
              names(ha_features) <- paste0(names(ha_features), "_", enrich)
            }
          }

          ha_enrichment <- list(ha_terms, ha_keys, ha_features)
          ha_enrichment <- ha_enrichment[sapply(ha_enrichment, length) > 0]
          ha_enrichment <- do.call(c, ha_enrichment)

          if (is.null(ha_right)) {
            ha_right <- ha_enrichment
          } else {
            ha_right <- c(ha_right, ha_enrichment)
          }
        }
      }
    }
  }
  return(list(ha_right = ha_right, res = res))
}
