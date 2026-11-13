# Monocle3 analysis core, extracted from SCP-local v0.5.6 RunMonocle3.
# GPL (>= 3). The clustering, graph-learning and ordering steps are kept;
# plotting, interactive partition/root selection and Seurat conversion are
# removed. use_partition and a root (root_pr_nodes or root_cells) are required.
#
# Copy this code/ directory only. No SCP-local bundle is required or read.

run_monocle3_core <- local({
  check_packages <- function(packages) {
    for (package in unique(packages)) {
      if (!requireNamespace(package, quietly = TRUE)) {
        stop("Missing R dependency: ", package, "; automatic installation is disabled", call. = FALSE)
      }
    }
  }
  restore_search <- function(before) {
    if (identical(search(), before)) return(TRUE)
    for (round in seq_len(5)) {
      added <- setdiff(search(), before)
      if (!length(added)) break
      for (package in rev(added)) {
        try(detach(package, character.only = TRUE, unload = FALSE), silent = TRUE)
      }
    }
    identical(search(), before)
  }
  function(expression_data, cell_metadata, gene_metadata = NULL,
           size_factor = NULL, reduced_dim = NULL, loadings = NULL, stdev = NULL,
           clusters = NULL, graph = NULL, partition_qval = 0.05, k = 50,
           cluster_method = "louvain", num_iter = 2, resolution = NULL,
           use_partition = NULL, close_loop = TRUE,
           root_pr_nodes = NULL, root_cells = NULL, seed = 11) {
    if (is.null(use_partition)) {
      stop("use_partition must be supplied explicitly (TRUE or FALSE); the core does not prompt",
           call. = FALSE)
    }
    if (is.null(root_pr_nodes) && is.null(root_cells)) {
      stop("root_pr_nodes or root_cells must be supplied explicitly; the core does not guess a root",
           call. = FALSE)
    }
    if (is.null(reduced_dim)) {
      stop("reduced_dim with one row per cell (the existing UMAP/embedding) is required; ",
           "the core does not run a dimensionality reduction", call. = FALSE)
    }
    if (nrow(reduced_dim) != ncol(expression_data)) {
      stop("reduced_dim must have one row per cell in expression_data", call. = FALSE)
    }
    if (!is.null(rownames(reduced_dim)) && !is.null(colnames(expression_data)) &&
        !identical(rownames(reduced_dim), colnames(expression_data))) {
      stop("reduced_dim row names must match expression_data cell names and order", call. = FALSE)
    }
    packages <- c("monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph", "Matrix")
    check_packages(packages)
    before <- search()
    on.exit(restore_search(before), add = TRUE)
    for (package in packages) {
      suppressPackageStartupMessages(library(package, character.only = TRUE, quietly = TRUE))
    }
    set.seed(seed)
    if (is.null(gene_metadata)) {
      gene_metadata <- data.frame(gene_short_name = rownames(expression_data),
                                  row.names = rownames(expression_data))
    }
    cds <- monocle3::new_cell_data_set(
      expression_data = expression_data,
      cell_metadata = as.data.frame(cell_metadata),
      gene_metadata = as.data.frame(gene_metadata)
    )
    if (!is.null(size_factor) && !"Size_Factor" %in% colnames(cds@colData)) {
      cds[["Size_Factor"]] <- size_factor
    }
    if (!is.null(reduced_dim)) {
      SingleCellExperiment::reducedDims(cds)[["UMAP"]] <- reduced_dim
    }
    if (!is.null(loadings) && length(loadings) > 0) {
      slot(object = cds, name = "reduce_dim_aux")[["gene_loadings"]] <- loadings
    }
    if (!is.null(stdev) && length(stdev) > 0) {
      slot(object = cds, name = "reduce_dim_aux")[["prop_var_expl"]] <- stdev
    }

    if (!is.null(clusters)) {
      if (!is.null(graph)) {
        g <- igraph::graph_from_adjacency_matrix(adjmatrix = graph, weighted = TRUE)
        cluster_result <- list(
          g = g, relations = NULL, distMatrix = "matrix", coord = NULL, edge_links = NULL,
          optim_res = list(membership = as.integer(as.factor(clusters)), modularity = NA_real_)
        )
        if (length(unique(cluster_result$optim_res$membership)) > 1) {
          cluster_graph_res <- monocle3:::compute_partitions(
            cluster_result$g, cluster_result$optim_res, partition_qval)
          partitions <- igraph::components(cluster_graph_res$cluster_g)$membership[
            cluster_result$optim_res$membership]
          partitions <- as.factor(partitions)
        } else {
          partitions <- rep(1, ncol(cds))
        }
        names(partitions) <- colnames(cds)
        cds@clusters[["UMAP"]] <- list(
          cluster_result = cluster_result, partitions = partitions,
          clusters = as.factor(clusters)
        )
        cds[["clusters"]] <- as.factor(clusters)
        cds <- monocle3:::add_citation(cds, "clusters")
        cds <- monocle3:::add_citation(cds, "partitions")
      } else {
        cds <- monocle3::cluster_cells(cds, reduction_method = "UMAP",
          partition_qval = partition_qval, k = k, cluster_method = cluster_method,
          num_iter = num_iter, resolution = resolution)
        cds[["clusters"]] <- cds@clusters[["UMAP"]]$clusters <- as.factor(clusters)
      }
    } else {
      cds <- monocle3::cluster_cells(cds, reduction_method = "UMAP",
        partition_qval = partition_qval, k = k, cluster_method = cluster_method,
        num_iter = num_iter, resolution = resolution)
      cds[["clusters"]] <- cds@clusters[["UMAP"]]$clusters
    }
    cds <- monocle3::learn_graph(cds = cds, use_partition = use_partition, close_loop = close_loop)
    cds <- monocle3::order_cells(cds, root_pr_nodes = root_pr_nodes, root_cells = root_cells)
    pseudotime <- cds@principal_graph_aux[["UMAP"]]$pseudotime
    pseudotime[is.infinite(pseudotime)] <- NA
    list(
      cds = cds,
      pseudotime = pseudotime,
      clusters = cds@clusters[["UMAP"]]$clusters,
      partitions = cds@clusters[["UMAP"]]$partitions,
      use_partition = use_partition,
      root_pr_nodes = root_pr_nodes,
      root_cells = root_cells
    )
  }
})
