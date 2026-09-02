# Get valid NWRSpecies taxonomic categories

Queries the `SpeciesList/categories` endpoint for the category names
accepted by
[`get_species_list()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_list.md).

## Usage

``` r
get_species_categories(api_version = .nwrs_api_version)
```

## Arguments

- api_version:

  Character scalar. Required API version.

## Value

A tibble of category names.

## Examples

``` r
if (FALSE) { # \dontrun{
get_species_categories()
} # }
```
