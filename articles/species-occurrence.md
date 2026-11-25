# Getting species occurrence data

## Overview

`nwrspeciesr` provides an R interface to the public U.S. Fish and
Wildlife Service National Wildlife Refuge System species occurrence
database. This article demonstrates a typical workflow using Kodiak
National Wildlife Refuge:

1.  identify the refuge by name;
2.  retrieve species occurrence records;
3.  apply filters for taxonomic group and occurrence status;
4.  inspect and summarize the returned data; and
5.  download a larger extract when needed.

The examples below use live API requests when run interactively. They
are not evaluated while the package website is built, because API
availability and response times should not determine whether the
documentation builds.

## Load the package

``` r

library(nwrspeciesr)
```

## Retrieve Kodiak Refuge records

The `refuge_name` argument accepts common forms of a refuge name. The
package resolves the name to the refuge unit code required by the
NWRSpecies API. Matching is case-insensitive and tolerant of common
suffixes such as `NWR` and `National Wildlife Refuge`.

``` r

kodiak <- get_species_list(refuge_name = "Kodiak National Wildlife Refuge")
kodiak
```

The result is a tibble containing the species occurrence records
returned by the API. To inspect its structure and column names, use
standard R functions:

``` r

nrow(kodiak)
names(kodiak)
str(kodiak)
```

The API returns one row per species-refuge occurrence record. The
available fields include taxonomic information, occurrence status,
refuge information, and notes supplied by the source database. The exact
columns may change as the API evolves, so inspect `names(kodiak)` before
writing a long-term workflow that depends on a particular field.

## Filter the request at the API

Filters can be supplied to
[`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md)
so that the API returns only the records needed for an analysis. For
example, retrieve bird records marked as present at Kodiak Refuge:

``` r

kodiak_birds <- get_species_list(
  refuge_name = "Kodiak",
  category_name = "Bird",
  occurrence = "Present"
)

kodiak_birds
```

Filtering at the API is preferable to downloading all records and
filtering afterward when the requested subset is well defined. It
reduces the amount of data transferred and makes the request more
explicit and reproducible.

Other useful filters include:

``` r

# All records for a specific refuge code
get_species_list(refuge_code = "FF07RKDK00")

# Present records in a taxonomic category
get_species_list(
  refuge_name = "Kodiak",
  category_name = "Mammal",
  occurrence = "Present"
)

# A single taxon by its ITIS Taxonomic Serial Number
get_species_list(
  refuge_name = "Kodiak",
  itis_tsn = 180092
)
```

The valid category and occurrence values can be retrieved from the API
with
[`get_species_categories()`](https://usfws.github.io/nwrspeciesr/reference/get_species_categories.md)
and
[`get_species_occurrences()`](https://usfws.github.io/nwrspeciesr/reference/get_species_occurrences.md):

``` r

get_species_categories()
get_species_occurrences()
```

## Inspect and summarize the returned data

Once the data are local, use your preferred R tools to inspect and
summarize them. For example, base R can count records by occurrence
value:

``` r

table(kodiak$occurrence, useNA = "ifany")
```

If the returned column names include `categoryName`, a taxonomic summary
can be created with [`table()`](https://rdrr.io/r/base/table.html):

``` r

table(kodiak$categoryName, useNA = "ifany")
```

Column names can vary with API response changes. If either example
refers to a column that is not present in the current response, inspect
`names(kodiak)` and substitute the current field name.

## Use the current refuge crosswalk

By default, name matching uses a crosswalk snapshot bundled with the
package. That makes the default behavior reproducible, but the snapshot
may not include recent refuge name or code changes. To use the current
refuge list from the FWS Unit API, retrieve it with
[`get_refuges()`](https://usfws.github.io/nwrspeciesr/reference/get_refuges.md)
and pass it through `crosswalk`:

``` r

current_refuges <- get_refuges()

kodiak_current <- get_species_list(
  refuge_name = "Kodiak",
  crosswalk = current_refuges
)
```

The live crosswalk requires a network connection and the `fwsunitr`
package. Store the crosswalk used for an analysis if the exact
name-to-code mapping needs to be reproduced later.

## Download a larger extract

[`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md)
returns one API page. For a larger extract, use
[`download_species_list()`](https://usfws.github.io/nwrspeciesr/reference/download_species_list.md),
which calls the CSV download endpoint. The `rows_per_page` value should
be set deliberately for the size of the extract:

``` r

kodiak_download <- download_species_list(
  refuge_name = "Kodiak",
  rows_per_page = 130000
)

kodiak_download
```

For large responses, write the CSV directly to a file instead of keeping
a second copy in memory:

``` r

download_species_list(
  refuge_name = "Kodiak",
  rows_per_page = 130000,
  path = "kodiak-species-list.csv"
)
```

The package uses a conservative one-page default for
[`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md).
Requesting a large page does not guarantee that an API maximum will not
be applied, so check the number of returned rows and the API response
when a complete extract is important.

## Reproducibility and responsible use

Record the date of retrieval, filters, package version, and any live
crosswalk used for an analysis. For example:

``` r

list(
  retrieved = format(Sys.time(), tz = "UTC"),
  package_version = as.character(utils::packageVersion("nwrspeciesr")),
  refuge_name = "Kodiak National Wildlife Refuge",
  category_name = "Bird",
  occurrence = "Present"
)
```

The public endpoint does not return sensitive species or records with a
Draft status. Treat downloaded wildlife information according to
applicable agency policies and do not infer absence solely from a record
not appearing in a filtered result.
