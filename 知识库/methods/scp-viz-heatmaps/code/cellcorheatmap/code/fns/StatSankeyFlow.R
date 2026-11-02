# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:214-342
# sha256(func-block)=1a97f41327e9c8ac8b7c396fb15ae10ecc64a5d6a070c525dc3bb156e72ffd69
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
delayedAssign("StatSankeyFlow", ggplot2::ggproto("StatSankeyFlow", ggplot2::Stat,
  extra_params = c("n_grid", "na.rm", "type", "width", "space", "smooth"),
  setup_data = function(data, params) {
    purrr::map_dfr(
      unique(data$PANEL),
      ~ {
        data <- data %>% dplyr::filter(PANEL == .x)

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
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
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
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
            dplyr::group_by_at(dplyr::vars(dplyr::everything(), -value)) %>%
            dplyr::reframe(freq = sum(value, na.rm = TRUE), , .groups = "keep") %>%
            dplyr::ungroup()
        }

        if (is.null(params$space)) {
          params$space <- find_default_space(data)
        }

        data <- data %>%
          dplyr::group_by(n_x) %>%
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
            xmin = n_x - params$width / 2,
            xmax = n_x + params$width / 2
          )

        if ("shift" %in% names(data)) {
          data <- data %>%
            dplyr::mutate(dplyr::across(dplyr::contains("y"), ~ . + shift))
        }

        df <- data %>%
          dplyr::left_join(flow_data, by = c("n_x", "node"))



        flows <- df %>%
          dplyr::left_join(
            df %>%
              dplyr::select(n_x, node, ymin_end = ymin, ymax_end = ymax, xmin_end = xmin, xmax_end = xmax) %>%
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
          dplyr::mutate(cum_flow_freq_end = cumsum(flow_freq) - flow_freq) %>%
          dplyr::mutate(
            flow_end_ymax = ymax_end - cum_flow_freq_end,
            flow_end_ymin = flow_end_ymax - flow_freq
          ) %>%
          dplyr::ungroup()

        flows <- flows %>%
          dplyr::select(-n_x, -node, -freq, -ymax, -ymin, -xmin, -n_next_x, -next_node, -flow_freq, -ymin_end, -ymax_end, -xmax_end, -cum_flow_freq, -cum_flow_freq_end) %>%
          dplyr::mutate(group = dplyr::row_number())

        flows %>%
          dplyr::mutate(smooth = params$smooth) %>%
          as.data.frame()
      }
    )
  },
  compute_group = function(data, scales) {
    out1 <- sigmoid(data$xmax, data$xmin_end, data$flow_start_ymax, data$flow_end_ymax,
      smooth = data$smooth
    )
    out2 <- sigmoid(data$xmin_end, data$xmax, data$flow_end_ymin, data$flow_start_ymin,
      smooth = data$smooth
    )
    dplyr::bind_rows(out1, out2)
  }
), assign.env = environment())
