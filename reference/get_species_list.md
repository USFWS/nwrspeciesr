# Get refuge species occurrence records from NWRSpecies

Queries the NWRSpecies (formerly FWSpecies) `SpeciesList/items`
endpoint, which exposes the public `SpeciesListBasic` method. All
filters are optional and may be combined; `NULL` filters are omitted
from the request.

## Usage

``` r
get_species_list(
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
)
```

## Arguments

- region_number:

  Integer or character scalar. USFWS legacy region (1-8). Passed as
  `RegionNumber`.

- refuge_code:

  Character scalar. Cost center / unit code (e.g. "FF08RANH00"). Passed
  as `RefugeCode`.

- refuge_name:

  Character scalar. Refuge name in any common form (e.g. "Kenai", "kenai
  nwr", "Kenai National Wildlife Refuge"), resolved to a `refuge_code`
  via the
  [refuges](https://solid-lamp-km35j47.pages.github.io/reference/refuges.md)
  crosswalk. Supply either `refuge_code` or `refuge_name`, not both.

- crosswalk:

  Data frame with `refuge_code` and `refuge_name` columns used to
  resolve `refuge_name`. If `NULL` (default), the bundled
  [refuges](https://solid-lamp-km35j47.pages.github.io/reference/refuges.md)
  dataset is used.

- category_name:

  Character scalar. Taxonomic category (e.g. "Bird"). Validated against
  the documented category set; see
  [`get_species_categories()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_categories.md)
  for the live list.

- occurrence:

  Character scalar. One of "NotPresent", "Present", "ProbablyPresent",
  "Unconfirmed". See
  [`get_species_occurrences()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_occurrences.md).

- itis_tsn:

  Integer or character scalar. ITIS Taxonomic Serial Number.

- sort_by:

  Character scalar. One of "OrdFamSci", "FamSci", "Sci".

- rows_per_page:

  Integer scalar. Rows per page (API default 100).

- page_number:

  Integer scalar. Page to return (API default 1).

- api_version:

  Character scalar. Required API version.

## Value

A tibble of species occurrence records.

## Examples

``` r
if (FALSE) { # \dontrun{
get_species_list(region_number = 1, category_name = "Bird",
                 occurrence = "Present")
get_species_list(refuge_code = "FF08RANH00")
} # }
```
