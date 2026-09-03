#' Normalize a refuge name for matching
#'
#' Lower-cases the input and strips common refuge suffixes and punctuation so
#' that variants such as "Kenai National Wildlife Refuge", "Kenai NWR",
#' "kenai refuge", and "Kenai" all reduce to the same key ("kenai").
#'
#' @param x Character vector of refuge names.
#'
#' @return A character vector of normalized keys.
#' @keywords internal
#' @noRd
normalize_refuge <- function(x) {
  x |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("national wildlife refuge", " ") |>
    stringr::str_replace_all("wildlife refuge", " ") |>
    stringr::str_replace_all("\\bnwrs?\\b", " ") |>
    stringr::str_replace_all("\\brefuge\\b", " ") |>
    stringr::str_replace_all("[^a-z0-9]+", " ") |>
    stringr::str_squish()
}

#' Build an "ambiguous match" error message
#'
#' @param input The user-supplied refuge name.
#' @param candidates Character vector of matched refuge names.
#'
#' @return A character scalar.
#' @keywords internal
#' @noRd
refuge_ambiguous_msg <- function(input, candidates) {
  sprintf(
    "'%s' matched multiple refuges: %s. Please be more specific.",
    input,
    paste(candidates, collapse = ", ")
  )
}

#' Load the bundled refuge crosswalk
#'
#' Retrieves the packaged `refuges` dataset across installed and development
#' contexts. Returns `NULL` if the dataset cannot be found.
#'
#' @return A tibble, or `NULL`.
#' @keywords internal
#' @noRd
bundled_refuges <- function() {
  out <- tryCatch(
    get("refuges", envir = asNamespace("nwrspeciesr")),
    error = function(err) NULL
  )
  if (!is.null(out)) {
    return(out)
  }
  e <- new.env(parent = emptyenv())
  ok <- tryCatch(
    {
      utils::data("refuges", package = "nwrspeciesr", envir = e)
      TRUE
    },
    error = function(err) FALSE
  )
  if (!ok) {
    return(NULL)
  }
  get0("refuges", envir = e, inherits = FALSE)
}

#' Resolve a refuge name to its unit (cost center) code
#'
#' Matches a flexibly-entered refuge name to a single `refuge_code` using the
#' package [refuges] crosswalk. Matching is case-insensitive and tolerant of
#' common suffixes (e.g. "NWR", "Refuge", "National Wildlife Refuge"). An exact
#' normalized match is tried first, then a whole-token partial match; if neither
#' yields a single result, an informative error is raised with the closest
#' candidates.
#'
#' @param refuge_name Character scalar. Refuge name in any common form
#'   (e.g. "Kenai", "kenai nwr", "Kenai National Wildlife Refuge").
#' @param crosswalk Data frame with `refuge_code` and `refuge_name` columns.
#'   If `NULL` (default), the bundled [refuges] dataset is used.
#'
#' @return A character scalar: the matching `refuge_code`.
#' @keywords internal
#' @noRd
resolve_refuge_code <- function(refuge_name, crosswalk = NULL) {
  if (
    !is.character(refuge_name) ||
      length(refuge_name) != 1L ||
      is.na(refuge_name)
  ) {
    stop("`refuge_name` must be a single non-missing string.", call. = FALSE)
  }

  if (is.null(crosswalk)) {
    crosswalk <- tryCatch(bundled_refuges(), error = function(e) NULL)
    if (is.null(crosswalk)) {
      stop(
        "No refuge crosswalk is available. Supply one via `crosswalk`.",
        call. = FALSE
      )
    }
  }
  if (!all(c("refuge_code", "refuge_name") %in% names(crosswalk))) {
    stop(
      "`crosswalk` must have `refuge_code` and `refuge_name` columns.",
      call. = FALSE
    )
  }

  key <- normalize_refuge(refuge_name)
  if (!nzchar(key)) {
    stop("`refuge_name` is empty after normalization.", call. = FALSE)
  }

  norm <- normalize_refuge(crosswalk$refuge_name)

  # 1. Exact normalized match.
  hit <- which(norm == key)
  if (length(hit) == 1L) {
    return(crosswalk$refuge_code[hit])
  }
  if (length(hit) > 1L) {
    stop(
      refuge_ambiguous_msg(refuge_name, crosswalk$refuge_name[hit]),
      call. = FALSE
    )
  }

  # 2. Whole-token partial match (key appears as a full token sequence).
  padded_norm <- ifelse(is.na(norm), NA_character_, paste0(" ", norm, " "))
  padded_key <- paste0(" ", key, " ")
  part <- which(stringr::str_detect(padded_norm, stringr::fixed(padded_key)))
  if (length(part) == 1L) {
    return(crosswalk$refuge_code[part])
  }
  if (length(part) > 1L) {
    stop(
      refuge_ambiguous_msg(refuge_name, crosswalk$refuge_name[part]),
      call. = FALSE
    )
  }

  # 3. No match: suggest the closest names by edit distance.
  d <- utils::adist(key, norm)[1, ]
  near <- crosswalk$refuge_name[order(d)][seq_len(min(3L, length(d)))]
  stop(
    sprintf(
      "No refuge matched '%s'. Did you mean: %s?",
      refuge_name,
      paste(near, collapse = ", ")
    ),
    call. = FALSE
  )
}
