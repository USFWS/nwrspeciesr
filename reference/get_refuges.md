# Get the refuge name / unit code crosswalk from the FWS Unit API

Retrieves current national wildlife refuge units from the FWS Unit REST
API via the fwsunitr package and returns a crosswalk suitable for the
`crosswalk` argument of
[`get_species_list()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_list.md)
and
[`download_species_list()`](https://solid-lamp-km35j47.pages.github.io/reference/download_species_list.md),
or as a live alternative to the bundled
[refuges](https://solid-lamp-km35j47.pages.github.io/reference/refuges.md)
dataset.

## Usage

``` r
get_refuges()
```

## Value

A tibble with columns `refuge_code`, `refuge_name`, and `region_number`.

## Details

Requires the suggested fwsunitr package. The returned `refuge_code`
values are the unit (cost center) codes the NWRSpecies API expects as
`RefugeCode`. `region_number` is derived from the Unit API region code
(e.g. "R0007" becomes 7).

## Examples

``` r
if (FALSE) { # \dontrun{
get_refuges()
get_species_list(refuge_name = "Kenai", crosswalk = get_refuges())
} # }
```
