# Package-level defaults. Update if the API base URL or version changes.
.nwrs_base_url <- "https://iris.fws.gov/APPS/SpeciesAPI/api/"
.nwrs_api_version <- "1.0"
.nwrs_user_agent <- "nwrspeciesr (https://github.com/USFWS/nwrspeciesr)"

#' Perform a GET request against the NWRSpecies API
#'
#' Internal helper that builds a request, drops empty query parameters,
#' sets a JSON Accept header, retries on transient failures, and returns the
#' parsed response body as a tibble. Handles either a bare JSON array or an
#' object that wraps the records under a single list element.
#'
#' @param path Character scalar. Path appended to `base_url`
#'   (e.g. "SpeciesList/items").
#' @param query Named list of query parameters. `NULL` elements are dropped.
#' @param base_url Character scalar. API base URL.
#'
#' @return A tibble of the parsed response body.
#' @keywords internal
#' @noRd
nwrs_get <- function(path, query = list(), base_url = .nwrs_base_url) {
  body <- httr2::request(base_url) |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!purrr::compact(query)) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_user_agent(.nwrs_user_agent) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  nwrs_as_tibble(body)
}

#' Coerce a parsed NWRSpecies body to a tibble
#'
#' Accepts a data frame (bare array), a list wrapping records under one
#' element (e.g. `items`), an empty result, or an atomic vector, and returns a
#' tibble.
#'
#' @param body Parsed JSON body from `nwrs_get()`.
#'
#' @return A tibble.
#' @keywords internal
#' @noRd
nwrs_as_tibble <- function(body) {
  if (is.data.frame(body)) {
    return(tibble::as_tibble(body))
  }
  if (is.list(body)) {
    if (length(body) == 0L) {
      return(tibble::tibble())
    }
    df <- purrr::detect(body, is.data.frame)
    if (!is.null(df)) {
      return(tibble::as_tibble(df))
    }
  }
  if (length(body) == 0L) {
    return(tibble::tibble())
  }
  tibble::tibble(value = body)
}
