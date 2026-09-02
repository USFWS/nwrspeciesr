#' USFWS refuge name / unit code crosswalk
#'
#' A one-to-one crosswalk between refuge unit (cost center) codes and refuge
#' names, used by [get_species_list()] and [download_species_list()] to resolve
#' a `refuge_name` argument to the `RefugeCode` the NWRSpecies API expects.
#'
#' This is a bundled snapshot. For a live table, use [get_refuges()], which
#' pulls current refuge units from the FWS Unit REST API via the \pkg{fwsunitr}
#' package. Regenerate the snapshot with `data-raw/refuges.R`.
#'
#' @format A tibble with one row per refuge and columns:
#' \describe{
#'   \item{refuge_code}{Cost center / unit code (e.g. "FF07RYKD00"). Matches the
#'     `RefugeCode` filter of the NWRSpecies API.}
#'   \item{refuge_name}{Long refuge name (e.g. "Yukon Delta National Wildlife
#'     Refuge").}
#'   \item{region_number}{USFWS region number (1-8), derived from the Unit API
#'     region code (e.g. "R0007" becomes 7). Note this reflects the Unit API's
#'     current region, whereas the NWRSpecies API's own `RegionNumber` field is
#'     documented as a legacy region; the two can differ for units affected by
#'     regional reorganization. This column is informational only and is not
#'     used when resolving `refuge_name`.}
#' }
#' @source FWS Unit REST API (\url{https://iris.fws.gov/APPS/Unit}), retrieved
#'   via the \pkg{fwsunitr} package. See `data-raw/refuges.R`.
"refuges"
