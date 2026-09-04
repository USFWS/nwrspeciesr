# Get valid NWRSpecies occurrence values

Queries the `SpeciesList/occurences` endpoint for the occurrence values
accepted by
[`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md).
Note the endpoint path is spelled "occurences" (single r) in the API and
is used as-is.

## Usage

``` r
get_species_occurrences(api_version = .nwrs_api_version)
```

## Arguments

- api_version:

  Character scalar. Required API version.

## Value

A tibble of occurrence values.

## Examples

``` r
if (FALSE) { # \dontrun{
get_species_occurrences()
} # }
```
