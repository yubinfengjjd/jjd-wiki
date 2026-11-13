# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:346-500
# sha256(func-block)=caafe17d273d3664af663286803ad757a01ef81ed00d097b0731a5492cacfc32
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
delayedAssign("StatSankeyBumpFlow", ggplot2::ggproto("StatSankeyBumpFlow", ggplot2::Stat,
  extra_params = c("na.rm", "type", "space", "smooth"),
  setup_data = function(data, params) {
    purrr::map_dfr(
      unique(data$PANEL),
      ~ {
        data <- data %>% dplyr::filter(PANEL == .x)

        data <- data %>%
          dplyr::mutate(nodes = paste(node, x)) %>%
          dplyr::arrange(x, -value) %>%
          dplyr::mutate(bbb = dplyr::row_number()) %>%
          dplyr::arrange(bbb) %>%
          dplyr::mutate(nodes = fct_reorder(nodes, value, mean)) %>%
          dplyr::arrange(node, x) %>%
          dplyr::group_by(node) %>%
          dplyr::mutate(
            next_x = dplyr::lead(x),
            node = nodes,
            next_node = dplyr::lead(nodes)
          ) %>%
          dplyr::ungroup() %>%
          dplyr::arrange(x, node)

        data <- data %>%
          dplyr::mutate(dplyr::across(c(x, next_x), ~ as.numeric(.), .names = ("n_{.col}")))

        if (!("value" %in% names(data))) {
          flow_data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::group_by(n_x, node, n_next_x, next_node) %>%
            dplyr::reframe(flow_freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()

          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node) %>%
            dplyr::group_by_all() %>%
            dplyr::reframe(freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()
        } else {
          flow_data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::group_by(n_x, node, n_next_x, next_node) %>%
            dplyr::reframe(flow_freq = sum(value, na.rm = TRUE), .groups = "keep") %>%
            dplyr::ungroup()

          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node) %>%
            dplyr::group_by_at(dplyr::vars(dplyr::everything(), -value)) %>%
            dplyr::reframe(freq = sum(value, na.rm = TRUE), .groups = "keep") %>%
            dplyr::ungroup()
        }

        if (is.null(params$space)) {
          params$space <- find_default_space(data)
        }

        data <- data %>%
          dplyr::group_by(n_x) %>%
          dplyr::arrange(node) %>%
          dplyr::mutate(
            ymax = cumsum(freq) + (dplyr::row_number() - 1) * params$space,
            ymin = ymax - freq
          ) %>%
          dplyr::ungroup()

        if (params$type == "sankey") {
          data <- data %>%
            dplyr::group_by(n_x) %>%
            dplyr::mutate(
              ymin = ymin - max(ymax) / 2,
              ymax = ymax - max(ymax) / 2
            ) %>%
            dplyr::ungroup()
        } else if (params$type == "alluvial") {
          data <- data
        }

        data <- data %>%
          dplyr::mutate(
            xmin = n_x,
            xmax = n_x
          )

        df <- data %>%
          dplyr::left_join(flow_data, by = c("n_x", "node"))

        flows <- df %>%
          dplyr::left_join(
            df %>%
              dplyr::select(n_x, node, ymin_end = ymin, ymax_end = ymax, xmin_end = xmin, xmax_end = xmax, flow_freq_end = flow_freq) %>%
              dplyr::distinct(),
            by = c("n_next_x" = "n_x", "next_node" = "node")
          ) %>%
          tidyr::drop_na(n_x, node, next_node, n_next_x, ymax_end, ymin_end, xmax_end, xmin_end) %>%
          dplyr::mutate(r = dplyr::row_number()) %>%
          dplyr::arrange(n_x, -r) %>%
          dplyr::select(-r) %>%
          dplyr::group_by(n_x, node) %>%
          dplyr::mutate(cum_flow_freq = cumsum(flow_freq) - flow_freq) %>%
          dplyr::ungroup() %>%
          dplyr::group_by(n_x, n_next_x, node, next_node) %>%
          dplyr::mutate(
            flow_start_ymax = ymax - cum_flow_freq,
            flow_start_ymin = flow_start_ymax - flow_freq
          )

        flows <- flows %>%
          dplyr::arrange(n_x, n_next_x, next_node) %>%
          dplyr::group_by(n_next_x, next_node) %>%
          dplyr::mutate(cum_flow_freq_end = cumsum(flow_freq_end) - flow_freq_end) %>%
          dplyr::mutate(
            flow_end_ymax = ymax_end - cum_flow_freq_end,
            flow_end_ymin = flow_end_ymax - flow_freq_end
          ) %>%
          dplyr::ungroup()

        flows <- flows %>%
          dplyr::select(-n_x, -node, -freq, -ymax, -ymin, -xmin, -n_next_x, -next_node, -flow_freq, -ymin_end, -ymax_end, -xmax_end, -cum_flow_freq, -cum_flow_freq_end) %>%
          dplyr::mutate(group = dplyr::row_number())

        flows %>%
          rowwise() %>%
          dplyr::mutate(..groupqq = stringr::str_remove(nodes, as.character(x))) %>%
          dplyr::ungroup() %>%
          dplyr::group_by(..groupqq) %>%
          dplyr::mutate(group = dplyr::cur_group_id()) %>%
          dplyr::ungroup() %>%
          dplyr::select(-..groupqq) %>%
          dplyr::mutate(smooth = params$smooth) %>%
          as.data.frame()
      }
    )
  },
  compute_group = function(data, scales) {
    out1 <- purrr::map_dfr(1:nrow(data), ~ {
      datat <- data %>% dplyr::slice(.x)
      sigmoid(datat$xmax, datat$xmin_end, datat$flow_start_ymax, datat$flow_end_ymax,
        smooth = datat$smooth
      )
    }) %>%
      dplyr::arrange(x)
    out2 <- purrr::map_dfr(1:nrow(data), ~ {
      datat <- data %>% dplyr::slice(.x)
      sigmoid(datat$xmin_end, datat$xmax, datat$flow_end_ymin, datat$flow_start_ymin,
        smooth = datat$smooth
      )
    }) %>%
      dplyr::arrange(-x)

    dplyr::bind_rows(out1, out2)
  }
), assign.env = environment())
