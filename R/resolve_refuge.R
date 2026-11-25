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
    stringr::str_replace_all("[^[:alnum:]]+", " ") |>
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
    paste(unique(candidates), collapse = ", ")
  )
}

#' Load the bundled refuge crosswalk
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
#' common suffixes. Exact normalized matches are tried before whole-token
#' partial matches. Ambiguous and unmatched inputs produce informative errors.
#'
#' @param refuge_name Character scalar. Refuge name in any common form.
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
    rlang::abort(
      "`refuge_name` must be a single non-missing character value.",
      call = rlang::caller_env()
    )
  }

  if (is.null(crosswalk)) {
    crosswalk <- bundled_refuges()
    if (is.null(crosswalk)) {
      rlang::abort(
        "No refuge crosswalk is available. Supply one via `crosswalk`.",
        call = rlang::caller_env()
      )
    }
  }

  if (
    !is.data.frame(crosswalk) ||
      !all(c("refuge_code", "refuge_name") %in% names(crosswalk))
  ) {
    rlang::abort(
      paste0(
        "`crosswalk` must be a data frame with `refuge_code` and ",
        "`refuge_name` columns."
      ),
      call = rlang::caller_env()
    )
  }

  if (
    !is.character(crosswalk$refuge_code) ||
      !is.character(crosswalk$refuge_name)
  ) {
    rlang::abort(
      "`crosswalk$refuge_code` and `crosswalk$refuge_name` must be character.",
      call = rlang::caller_env()
    )
  }

  key <- normalize_refuge(refuge_name)
  if (is.na(key) || !nzchar(key)) {
    rlang::abort(
      "`refuge_name` is empty after normalization.",
      call = rlang::caller_env()
    )
  }

  valid <- !is.na(crosswalk$refuge_code) &
    nzchar(trimws(crosswalk$refuge_code)) &
    !is.na(crosswalk$refuge_name) &
    nzchar(trimws(crosswalk$refuge_name))
  crosswalk <- crosswalk[valid, , drop = FALSE]

  if (nrow(crosswalk) == 0L) {
    rlang::abort(
      "`crosswalk` has no rows with non-missing refuge codes and names.",
      call = rlang::caller_env()
    )
  }

  norm <- normalize_refuge(crosswalk$refuge_name)
  exact <- which(!is.na(norm) & norm == key)

  if (length(exact) > 0L) {
    codes <- unique(crosswalk$refuge_code[exact])
    if (length(codes) == 1L) {
      return(codes[[1L]])
    }
    rlang::abort(
      refuge_ambiguous_msg(refuge_name, crosswalk$refuge_name[exact]),
      call = rlang::caller_env()
    )
  }

  padded_norm <- paste0(" ", norm, " ")
  padded_key <- paste0(" ", key, " ")
  partial <- which(
    !is.na(norm) &
      stringr::str_detect(padded_norm, stringr::fixed(padded_key))
  )

  if (length(partial) > 0L) {
    codes <- unique(crosswalk$refuge_code[partial])
    if (length(codes) == 1L) {
      return(codes[[1L]])
    }
    rlang::abort(
      refuge_ambiguous_msg(refuge_name, crosswalk$refuge_name[partial]),
      call = rlang::caller_env()
    )
  }

  valid_norm <- !is.na(norm) & nzchar(norm)
  if (!any(valid_norm)) {
    rlang::abort(
      sprintf("No refuge matched '%s'.", refuge_name),
      call = rlang::caller_env()
    )
  }

  distances <- utils::adist(key, norm[valid_norm])[1, ]
  candidates <- crosswalk$refuge_name[valid_norm]
  nearest <- order(distances, candidates)
  nearest <- nearest[seq_len(min(3L, length(nearest)))]

  rlang::abort(
    sprintf(
      "No refuge matched '%s'. Did you mean: %s?",
      refuge_name,
      paste(candidates[nearest], collapse = ", ")
    ),
    call = rlang::caller_env()
  )
}
