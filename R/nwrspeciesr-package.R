#' nwrspeciesr: Interface to the FWS NWRSpecies Occurrence Database API
#'
#' Provides an R interface to the U.S. Fish and Wildlife Service National
#' Wildlife Refuge System species occurrence database (NWRSpecies, formerly
#' FWSpecies). Functions retrieve refuge species lists and related lookup
#' values from the public web services.
#'
#' @section Retrieving species records:
#' \itemize{
#'   \item [get_species_list()] queries the `SpeciesList/items` endpoint
#'     (paged JSON) with optional filters for region, refuge, category,
#'     occurrence, and ITIS TSN.
#'   \item [download_species_list()] queries the CSV `DownloadFile` endpoint,
#'     the documented way to retrieve all records in a single call when
#'     combined with a large `rows_per_page`.
#' }
#'
#' @section Lookup values:
#' \itemize{
#'   \item [get_species_categories()] returns valid taxonomic category names.
#'   \item [get_species_occurrences()] returns valid occurrence values.
#' }
#'
#' @section API details:
#' All functions target the public web services at
#' `https://iris.fws.gov/APPS/SpeciesAPI/api/` and require an `api_version`
#' (default "1.0"). Only the public `SpeciesListBasic` method is currently
#' available; sensitive and Draft records are never returned.
#'
#' @seealso The API documentation (Swagger) at
#'   `https://iris.fws.gov/APPS/SpeciesAPI/swagger/index.html`.
#'
"_PACKAGE"
