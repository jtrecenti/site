googlesheets4::gs4_auth("julio.trecenti@gmail.com")
link <- "https://docs.google.com/spreadsheets/d/1l5TJKgXJ7v1EElaxlp3k-ZyEUDOM_0eSAp04O7LFh8E/edit#gid=0"
dados <- googlesheets4::read_sheet(link, "software")


yaml_list <- dados |>
  dplyr::mutate(img = glue::glue("<img src='{logo}' style='position: absolute;right: 0px; top: 0px; width: 80px;'/>")) |>
  dplyr::arrange(importance) |>
  tibble::rowid_to_column() |>
  dplyr::group_split(rowid) |>
  purrr::map(\(x) {
    categ <- c(
      stringr::str_split(x$type, ";")[[1]],
      x$status,
      x$active
    )
    if (length(categ) == 1) categ <- list(categ)
    yaml::as.yaml(list(
      title = x$title,
      description = x$description,
      categories = categ,
      type = x$type,
      language = x$language,
      active = x$active,
      status = x$status,
      authors = x$authors,
      logo = x$logo,
      tem_img = ifelse(is.na(x$logo), "hide-img", "show-img"),
      institution = x$institution,
      link = x$link
    ))
  }) |>
  yaml::as.yaml() |>
  stringr::str_replace_all("  -", "    -") |>
  stringr::str_replace_all("\\|\n *", "")


cat(yaml_list, file = "software.yaml")

card_list <- dados |>
  dplyr::mutate(img = glue::glue("<img src='{logo}' style='position: absolute;right: 0px; top: 0px; width: 80px;'/>")) |>
  dplyr::arrange(importance) |>
  tibble::rowid_to_column() |>
  dplyr::group_split(rowid) |>
  purrr::map(\(x) bslib::card(
    shiny::markdown(
      glue::glue_data(x, template), extensions = TRUE
    )
  ))

bslib::layout_column_wrap(1/4, !!!card_list)

#cat(as.character(card_list[[1]]))

#as.character(bslib::layout_column_wrap(1/4, !!!card_list))
