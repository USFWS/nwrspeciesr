# Replace multiple existing NWRSpecies records

Replacement is a full replacement and the batch is all-or-nothing. At
most 25 records are allowed.

## Usage

``` r
replace_species_records(
  records,
  api_key = NULL,
  base_url = .nwrs_upload_base_url
)
```

## Arguments

- records:

  List of named record lists. At most 25 records are allowed.

- api_key:

  Character scalar. API key, or `NULL` to read `NWRSPECIES_API_KEY`.

- base_url:

  Character scalar. Upload API base URL.

## Value

The parsed API response.

## Examples

``` r
if (FALSE) { # \dontrun{
replace_species_records(list(
  list(refugeCode = "FF02RNVO00", taxonCode = 93710, status = "Draft",
       refugeAccepted = "Undecided", isSensitive = "No")
))
} # }
```
