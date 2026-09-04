# nwrspeciesr

> **Note:** This project was developed with the assistance of Claude, a
> generative AI tool developed by Anthropic. AI-generated content has
> been reviewed and edited by the package maintainer, who takes
> responsibility for the final content.

## Overview

**nwrspeciesr** is an R interface to the U.S. Fish and Wildlife Service
National Wildlife Refuge System species occurrence database (NWRSpecies,
formerly FWSpecies). It provides functions to retrieve refuge species
lists and related lookup values from the public NWRSpecies web services.

Current functionality (read-only) includes:

- [`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md):
  retrieve species occurrence records, with optional filters for region,
  refuge, taxonomic category, occurrence, and ITIS TSN.
- [`download_species_list()`](https://usfws.github.io/nwrspeciesr/reference/download_species_list.md):
  retrieve the full species list via the CSV download endpoint (useful
  for pulling all records in a single call).
- [`get_species_categories()`](https://usfws.github.io/nwrspeciesr/reference/get_species_categories.md):
  list valid taxonomic category values.
- [`get_species_occurrences()`](https://usfws.github.io/nwrspeciesr/reference/get_species_occurrences.md):
  list valid occurrence values.

Only the public `SpeciesListBasic` method is currently exposed by the
API. Sensitive species and records with a Draft status are never
returned. Functions to create and edit records are planned for a future
release, pending availability of the corresponding web service.

## Installation

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("USFWS/nwrspeciesr")
```

## Usage

``` r

library(nwrspeciesr)

# All bird species recorded as Present across Region 7 refuges
get_species_list(region_number = 7, category_name = "Bird",
                 occurrence = "Present")

# A single refuge by unit (cost center) code
get_species_list(refuge_code = "FF07RKDK00")

# Look up valid filter values
get_species_categories()
get_species_occurrences()

# Retrieve all records for a refuge via the CSV download endpoint
download_species_list(refuge_code = "FF07RKDK00", rows_per_page = 130000)
```

### Filtering by refuge name

You can filter by refuge name instead of unit code. Matching is
case-insensitive and tolerant of common variants (e.g. “Kenai”, “kenai
nwr”, “Kenai National Wildlife Refuge”):

``` r

get_species_list(refuge_name = "kenai nwr")
```

Because the API filters on unit code rather than name, name matching
relies on a refuge crosswalk. A bundled snapshot (the `refuges` dataset)
is used by default. For a current table, use
[`get_refuges()`](https://usfws.github.io/nwrspeciesr/reference/get_refuges.md),
which pulls live from the FWS Unit REST API via the
[fwsunitr](https://github.com/USFWS/fwsunitr) package, and pass it via
the `crosswalk` argument:

``` r

get_species_list(refuge_name = "Kenai", crosswalk = get_refuges())
```

Names that match more than one refuge (e.g. “Yukon”, which matches both
Yukon Delta and Yukon Flats) return an informative error listing the
candidates, so you can supply a more specific name.

## Getting help

Contact the [project maintainer](mailto:mccrea_cobb@fws.gov) for help
with this repository. If you have general questions on creating
repositories in the USFWS DGEC, reach out to a USFWS DGEC
[owner](https://github.com/orgs/USFWS/people?query=role%3Aowner).

## Contribute

Contact the project maintainer for information about contributing to
this repository. Submit a [GitHub
Issue](https://github.com/USFWS/nwrspeciesr/issues) to report a bug or
request a feature or enhancement.

------------------------------------------------------------------------

![](https://i.creativecommons.org/l/zero/1.0/88x31.png) This work is
licensed under a [Creative Commons Zero Universal v1.0
License](https://creativecommons.org/publicdomain/zero/1.0/).
