#' Get the refuge name / unit code crosswalk from the FWS Unit API
#'
#' Retrieves current national wildlife refuge units from the FWS Unit REST API
#' via the \pkg{fwsunitr} package and returns a crosswalk suitable for the
#' `crosswalk` argument of [get_species_list()] and [download_species_list()],
#' or as a live alternative to the bundled [refuges] dataset.
#'
#' @details
#' Requires the suggested \pkg{fwsunitr} package. The returned `refuge_code`
#' values are the unit (cost center) codes the NWRSpecies API expects as
#' `RefugeCode`. `region_number` is derived from the Unit API region code
#' (e.g. "R0007" becomes 7).
#'
#' @return A tibble with columns `refuge_code`, `refuge_name`, and
#'   `region_number`.
#' @export
#'
#' @examples
#' \dontrun{
#' get_refuges()
#' get_species_list(refuge_name = "Kenai", crosswalk = get_refuges())
#' }
get_refuges <- function() {
  rlang::check_installed(
    "fwsunitr",
    reason = "to retrieve the refuge crosswalk."
  )

  u <- fwsunitr::get_unit(type = "refuge")

  tibble::tibble(
    refuge_code = u$unit_code,
    refuge_name = u$unit_name,
    region_number = as.integer(gsub("\\D", "", u$region_code))
  )
}
