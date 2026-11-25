## Build the `refuges` crosswalk shipped with nwrspeciesr.
## Pulls current refuge units from the FWS Unit REST API via fwsunitr.
## Snapshot generated 2026-09-02. Run when the refuge roster changes to
## regenerate data/refuges.rda.

# install.packages("pak"); pak::pak("USFWS/fwsunitr")
u <- fwsunitr::get_unit(type = "refuge")

refuges <- tibble::tibble(
  refuge_code = u$unit_code,
  refuge_name = u$unit_name,
  region_number = as.integer(gsub("\\D", "", u$region_code))
)

refuges <- refuges[order(refuges$region_number, refuges$refuge_name), ]

usethis::use_data(refuges, overwrite = TRUE)
