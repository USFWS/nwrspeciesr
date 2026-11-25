# Add URL evidence to an NWRSpecies record

Add URL evidence to an NWRSpecies record

## Usage

``` r
add_species_evidence(
  evidence,
  api_key = NULL,
  base_url = .nwrs_upload_base_url
)
```

## Arguments

- evidence:

  Named list containing an evidence payload. Identify the record with
  `speciesId`, or with both `refugeCode` and `taxonCode`.

- api_key:

  Character scalar. API key, or `NULL` to read `NWRSPECIES_API_KEY`.

- base_url:

  Character scalar. Upload API base URL.

## Value

The parsed API response, including the `evidenceCode`.

## Examples

``` r
if (FALSE) { # \dontrun{
add_species_evidence(list(
  speciesId = 481922, url = "https://example.gov/report/123",
  observationDate = "2026-05-14", datePrecisionId = 1,
  photograph = TRUE
))
} # }
```
