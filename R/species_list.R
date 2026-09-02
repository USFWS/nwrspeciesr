# Valid values for enumerated SpeciesList parameters.
.nwrs_categories <- c(
  "Amphibian",
  "Bacteria",
  "Bird",
  "Chromista",
  "CrabLobsterShrimp",
  "Fish",
  "Fungi",
  "Insect",
  "Mammal",
  "NonVascularPlant",
  "OtherNonVertebrates",
  "Protozoa",
  "Reptile",
  "SlugSnail",
  "SpiderScorpion",
  "VascularPlant"
)

.nwrs_occurrences <- c(
  "NotPresent",
  "Present",
  "ProbablyPresent",
  "Unconfirmed"
)

.nwrs_sort_by <- c("OrdFamSci", "FamSci", "Sci")

#' Match a scalar against a valid set, case-insensitively
#'
#' Normalizes `x` to the canonical casing of `choices` when it matches
#' case-insensitively, then defers to [rlang::arg_match()] so that unmatched
#' values still produce a clear error with suggestions.
#'
#' @param x Character scalar.
#' @param choices Character vector of valid values (canonical casing).
#'
#' @return The canonical-cased value.
#' @keywords internal
#' @noRd
match_enum_ci <- function(x, choices) {
  hit <- match(tolower(x), tolower(choices))
  if (!is.na(hit)) {
    x <- choices[hit]
  }
  rlang::arg_match0(x, choices)
}

#' Validate enumerated SpeciesList arguments
#'
#' Checks `category_name`, `occurrence`, and `sort_by` against their documented
#' value sets when supplied, giving a clear local error rather than an opaque
#' HTTP failure. Matching is case-insensitive and values are normalized to the
#' casing the API expects. `NULL` values pass through unchecked.
#'
#' @param category_name,occurrence,sort_by Scalars or `NULL`.
#'
#' @return A named list with the validated, canonical-cased values.
#' @keywords internal
#' @noRd
validate_enums <- function(
  category_name = NULL,
  occurrence = NULL,
  sort_by = NULL
) {
  if (!is.null(category_name)) {
    category_name <- match_enum_ci(category_name, .nwrs_categories)
  }
  if (!is.null(occurrence)) {
    occurrence <- match_enum_ci(occurrence, .nwrs_occurrences)
  }
  if (!is.null(sort_by)) {
    sort_by <- match_enum_ci(sort_by, .nwrs_sort_by)
  }
  list(
    category_name = category_name,
    occurrence = occurrence,
    sort_by = sort_by
  )
}

#' Resolve a refuge_name to refuge_code, enforcing mutual exclusivity
#'
#' Internal helper shared by the query functions. Returns `refuge_code`
#' unchanged when `refuge_name` is `NULL`; otherwise resolves `refuge_name`
#' via the crosswalk, erroring if both were supplied.
#'
#' @param refuge_code Character scalar or `NULL`.
#' @param refuge_name Character scalar or `NULL`.
#' @param crosswalk Data frame or `NULL`.
#'
#' @return A character scalar refuge code, or `NULL`.
#' @keywords internal
#' @noRd
resolve_refuge_arg <- function(refuge_code, refuge_name, crosswalk) {
  if (is.null(refuge_name)) {
    return(refuge_code)
  }
  if (!is.null(refuge_code)) {
    stop(
      "Supply either `refuge_code` or `refuge_name`, not both.",
      call. = FALSE
    )
  }
  resolve_refuge_code(refuge_name, crosswalk = crosswalk)
}

#' Get refuge species occurrence records from NWRSpecies
#'
#' Queries the NWRSpecies (formerly FWSpecies) `SpeciesList/items` endpoint,
#' which exposes the public `SpeciesListBasic` method. All filters are
#' optional and may be combined; `NULL` filters are omitted from the request.
#'
#' @param region_number Integer or character scalar. USFWS legacy region
#'   (1-8). Passed as `RegionNumber`.
#' @param refuge_code Character scalar. Cost center / unit code
#'   (e.g. "FF08RANH00"). Passed as `RefugeCode`.
#' @param refuge_name Character scalar. Refuge name in any common form
#'   (e.g. "Kenai", "kenai nwr", "Kenai National Wildlife Refuge"), resolved
#'   to a `refuge_code` via the [refuges] crosswalk. Supply either
#'   `refuge_code` or `refuge_name`, not both.
#' @param crosswalk Data frame with `refuge_code` and `refuge_name` columns
#'   used to resolve `refuge_name`. If `NULL` (default), the bundled [refuges]
#'   dataset is used.
#' @param category_name Character scalar. Taxonomic category (e.g. "Bird").
#'   Validated against the documented category set; see
#'   [get_species_categories()] for the live list.
#' @param occurrence Character scalar. One of "NotPresent", "Present",
#'   "ProbablyPresent", "Unconfirmed". See [get_species_occurrences()].
#' @param itis_tsn Integer or character scalar. ITIS Taxonomic Serial Number.
#' @param sort_by Character scalar. One of "OrdFamSci", "FamSci", "Sci".
#' @param rows_per_page Integer scalar. Rows per page (API default 100).
#' @param page_number Integer scalar. Page to return (API default 1).
#' @param api_version Character scalar. Required API version.
#'
#' @return A tibble of species occurrence records.
#' @export
#'
#' @examples
#' \dontrun{
#' get_species_list(region_number = 1, category_name = "Bird",
#'                  occurrence = "Present")
#' get_species_list(refuge_code = "FF08RANH00")
#' }
get_species_list <- function(
  region_number = NULL,
  refuge_code = NULL,
  refuge_name = NULL,
  crosswalk = NULL,
  category_name = NULL,
  occurrence = NULL,
  itis_tsn = NULL,
  sort_by = NULL,
  rows_per_page = NULL,
  page_number = NULL,
  api_version = .nwrs_api_version
) {
  refuge_code <- resolve_refuge_arg(refuge_code, refuge_name, crosswalk)
  enums <- validate_enums(category_name, occurrence, sort_by)

  nwrs_get(
    path = "SpeciesList/items",
    query = list(
      RegionNumber = region_number,
      RefugeCode = refuge_code,
      CategoryName = enums$category_name,
      Occurrence = enums$occurrence,
      ITIS_TSN = itis_tsn,
      SortBy = enums$sort_by,
      RowsPerPage = rows_per_page,
      PageNumber = page_number,
      `api-version` = api_version
    )
  )
}

#' Download the NWRSpecies species list as a data frame
#'
#' Queries the CSV-only `SpeciesList/items/DownloadFile` endpoint. Combined
#' with a large `rows_per_page`, this is the documented way to retrieve all
#' records in a single call. Accepts the same filters as [get_species_list()].
#'
#' @inheritParams get_species_list
#'
#' @return A tibble parsed from the returned CSV.
#' @export
#'
#' @examples
#' \dontrun{
#' download_species_list(refuge_code = "FF08RANH00", rows_per_page = 130000)
#' }
download_species_list <- function(
  region_number = NULL,
  refuge_code = NULL,
  refuge_name = NULL,
  crosswalk = NULL,
  category_name = NULL,
  occurrence = NULL,
  itis_tsn = NULL,
  sort_by = NULL,
  rows_per_page = NULL,
  page_number = NULL,
  api_version = .nwrs_api_version
) {
  refuge_code <- resolve_refuge_arg(refuge_code, refuge_name, crosswalk)
  enums <- validate_enums(category_name, occurrence, sort_by)

  query <- purrr::compact(list(
    RegionNumber = region_number,
    RefugeCode = refuge_code,
    CategoryName = enums$category_name,
    Occurrence = enums$occurrence,
    ITIS_TSN = itis_tsn,
    SortBy = enums$sort_by,
    RowsPerPage = rows_per_page,
    PageNumber = page_number,
    `api-version` = api_version
  ))

  csv <- httr2::request(.nwrs_base_url) |>
    httr2::req_url_path_append("SpeciesList/items/DownloadFile") |>
    httr2::req_url_query(!!!query) |>
    httr2::req_headers(Accept = "text/csv") |>
    httr2::req_user_agent(.nwrs_user_agent) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_perform() |>
    httr2::resp_body_string()

  readr::read_csv(I(csv), show_col_types = FALSE)
}
