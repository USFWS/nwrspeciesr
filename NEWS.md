# nwrspeciesr 0.1.0

Initial release. Provides a read-only R interface to the U.S. Fish and
Wildlife Service NWRSpecies (formerly FWSpecies) occurrence database.

## Features

* `get_species_list()` retrieves refuge species occurrence records from the
  public `SpeciesList/items` endpoint, with optional filters for region,
  refuge, taxonomic category, occurrence, and ITIS TSN, plus sorting and
  pagination.
* `download_species_list()` retrieves records from the CSV `DownloadFile`
  endpoint, the documented way to pull all records in a single call when
  combined with a large `rows_per_page`.
* `get_species_categories()` and `get_species_occurrences()` return the valid
  category and occurrence values accepted by the API.
* `get_refuges()` retrieves a live refuge name / unit code crosswalk from the
  FWS Unit REST API via the suggested **fwsunitr** package.

## Refuge name resolution

* `get_species_list()` and `download_species_list()` accept a `refuge_name`
  argument as an alternative to `refuge_code`. Matching is case-insensitive
  and tolerant of common variants (e.g. "Kenai", "kenai nwr", "Kenai National
  Wildlife Refuge").
* Names that match more than one refuge (e.g. "Yukon", matching both Yukon
  Delta and Yukon Flats) return an informative error listing the candidates.
* A bundled `refuges` crosswalk is used by default; a custom or live table may
  be supplied via the `crosswalk` argument.

## Input validation

* `category_name`, `occurrence`, and `sort_by` are validated locally against
  their documented value sets before a request is sent. Matching is
  case-insensitive and values are normalized to the casing the API expects.