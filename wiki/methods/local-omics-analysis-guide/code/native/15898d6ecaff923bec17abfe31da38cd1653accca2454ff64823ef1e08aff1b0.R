analyze_gene_set <- function(seurat_obj, genes, score_var = "Scoreing", phenotype_var = "phenotype",
														 p_threshold = 0.05, cor_threshold = 0.2) {
	# Extract expression matrix with drop=FALSE to preserve matrix structure
	expr <- GetAssayData(seurat_obj, slot = "data")[genes, , drop = FALSE]

	# Get scores and phenotype
	scores <- FetchData(seurat_obj, vars = score_var)[,1]
	phenotype <- FetchData(seurat_obj, vars = phenotype_var)[,1]
	phenotype_binary <- ifelse(phenotype == "AA", 1, 0)

	# Initialize results dataframe
	results <- data.frame(
		Gene = rownames(expr),
		Correlation_scores = numeric(nrow(expr)),
		Correlation_phenotype = numeric(nrow(expr)),
		P_Value_scores = numeric(nrow(expr)),
		P_Value_phenotype = numeric(nrow(expr)),
		stringsAsFactors = FALSE
	)

	# Calculate correlations per gene
	for (i in 1:nrow(expr)) {
		gene_expr <- as.numeric(expr[i, ])

		# Skip constant genes
		if (sd(gene_expr) == 0) {
			results[i, -1] <- NA
			next
		}

		# Calculate correlation with scores
		cor_scores <- suppressWarnings(cor.test(gene_expr, scores, method = "spearman", exact = FALSE))
		results$Correlation_scores[i] <- cor_scores$estimate
		results$P_Value_scores[i] <- cor_scores$p.value

		# Calculate correlation with phenotype
		cor_pheno <- suppressWarnings(cor.test(gene_expr, phenotype_binary, method = "spearman", exact = FALSE))
		results$Correlation_phenotype[i] <- cor_pheno$estimate
		results$P_Value_phenotype[i] <- cor_pheno$p.value
	}

	# Filter significant genes
	sig_genes <- results %>%
		filter(P_Value_scores < p_threshold & abs(Correlation_scores) > cor_threshold) %>%
		arrange(desc(abs(Correlation_scores)))

	return(list(results = results, sig_genes = sig_genes))
}
