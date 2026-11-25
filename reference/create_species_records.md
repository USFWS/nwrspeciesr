# Create multiple NWRSpecies records

Create multiple NWRSpecies records

## Usage

``` r
create_species_records(
  records,
  api_key = NULL,
  base_url = .nwrs_upload_base_url
)
```

## Arguments

- records:

  List of named record lists. At most 200 records are allowed.

- api_key:

  Character scalar. API key, or `NULL` to read `NWRSPECIES_API_KEY`.

- base_url:

  Character scalar. Upload API base URL.

## Value

The parsed batch response. Individual failures are returned in its
`results` element; a successful HTTP response can contain failed
records.

## Examples

``` r
if (FALSE) { # \dontrun{
create_species_records(list(
  list(refugeCode = "FF02RNVO00", taxonCode = 93710),
  list(refugeCode = "FF02RNVO00", taxonCode = 93711)
))
} # }
```
