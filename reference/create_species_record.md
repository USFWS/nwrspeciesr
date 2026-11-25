# Create one NWRSpecies record

Create one NWRSpecies record

## Usage

``` r
create_species_record(record, api_key = NULL, base_url = .nwrs_upload_base_url)
```

## Arguments

- record:

  Named list containing API field names. `refugeCode` and `taxonCode`
  are required; omitted creation fields receive documented API defaults.

- api_key:

  Character scalar. API key, or `NULL` to read `NWRSPECIES_API_KEY`.

- base_url:

  Character scalar. Upload API base URL.

## Value

The parsed API response, including the created `speciesId`.

## Examples

``` r
if (FALSE) { # \dontrun{
create_species_record(list(refugeCode = "FF02RNVO00", taxonCode = 93710))
} # }
```
