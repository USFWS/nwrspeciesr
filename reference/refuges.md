# USFWS refuge name / unit code crosswalk

A one-to-one crosswalk between refuge unit (cost center) codes and
refuge names, used by
[`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md)
and
[`download_species_list()`](https://usfws.github.io/nwrspeciesr/reference/download_species_list.md)
to resolve a `refuge_name` argument to the `RefugeCode` the NWRSpecies
API expects.

## Usage

``` r
refuges
```

## Format

A tibble with one row per refuge and columns:

- refuge_code:

  Cost center / unit code (e.g. "FF07RYKD00"). Matches the `RefugeCode`
  filter of the NWRSpecies API.

- refuge_name:

  Long refuge name (e.g. "Yukon Delta National Wildlife Refuge").

- region_number:

  USFWS region number (1-8), derived from the Unit API region code (e.g.
  "R0007" becomes 7). Note this reflects the Unit API's current region,
  whereas the NWRSpecies API's own `RegionNumber` field is documented as
  a legacy region; the two can differ for units affected by regional
  reorganization. This column is informational only and is not used when
  resolving `refuge_name`.

## Source

FWS Unit REST API (<https://iris.fws.gov/APPS/Unit>), retrieved via the
fwsunitr package. See `data-raw/refuges.R`.

## Details

This is a bundled snapshot. For a live table, use
[`get_refuges()`](https://usfws.github.io/nwrspeciesr/reference/get_refuges.md),
which pulls current refuge units from the FWS Unit REST API via the
fwsunitr package. Regenerate the snapshot with `data-raw/refuges.R`.
