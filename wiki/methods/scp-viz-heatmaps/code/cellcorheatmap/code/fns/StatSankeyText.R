# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:503-579
# sha256(func-block)=f1d4fde7fbbf1fa17569573d5254d5f7edd5fa5f32e122534cf6ee894985b875
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
delayedAssign("StatSankeyText", ggplot2::ggproto("StatSankeyText", ggplot2::Stat,
  extra_params = c("n_grid", "na.rm", "type", "width", "space"),
  setup_data = function(data, params) {
    purrr::map_dfr(
      unique(data$PANEL),
      ~ {
        data <- data %>% dplyr::filter(PANEL == .x)

        data <- data %>%
          dplyr::mutate(dplyr::across(c(x, next_x), ~ as.numeric(.), .names = ("n_{.col}")))

        if (!("value" %in% names(data))) {
          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node) %>%
            dplyr::group_by_all() %>%
            dplyr::reframe(freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()
        } else {
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

        data <- data %>%
          dplyr::mutate(
            x = n_x,
            y = ymin + (ymax - ymin) / 2
          )

        if ("shift" %in% names(data)) {
          data <- data %>%
            dplyr::mutate(dplyr::across(dplyr::contains("y"), ~ . + shift))
        }


        return(as.data.frame(data))
      }
    )
  },
  compute_group = function(data, scales) {
    data
  }
), assign.env = environment())
