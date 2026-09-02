#' Get valid NWRSpecies taxonomic categories
#'
#' Queries the `SpeciesList/categories` endpoint for the category names
#' accepted by [get_species_list()].
#'
#' @param api_version Character scalar. Required API version.
#'
#' @return A tibble of category names.
#' @export
#'
#' @examples
#' \dontrun{
#' get_species_categories()
#' }
get_species_categories <- function(api_version = .nwrs_api_version) {
  nwrs_get(
    path = "SpeciesList/categories",
    query = list(`api-version` = api_version)
  )
}

#' Get valid NWRSpecies occurrence values
#'
#' Queries the `SpeciesList/occurences` endpoint for the occurrence values
#' accepted by [get_species_list()]. Note the endpoint path is spelled
#' "occurences" (single r) in the API and is used as-is.
#'
#' @param api_version Character scalar. Required API version.
#'
#' @return A tibble of occurrence values.
#' @export
#'
#' @examples
#' \dontrun{
#' get_species_occurrences()
#' }
get_species_occurrences <- function(api_version = .nwrs_api_version) {
  nwrs_get(
    path = "SpeciesList/occurences",
    query = list(`api-version` = api_version)
  )
}
