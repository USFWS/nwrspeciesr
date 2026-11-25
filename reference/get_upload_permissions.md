# Get refuges writable with the NWRSpecies upload API key

Get refuges writable with the NWRSpecies upload API key

## Usage

``` r
get_upload_permissions(api_key = NULL, base_url = .nwrs_upload_base_url)
```

## Arguments

- api_key:

  Character scalar. API key, or `NULL` to read `NWRSPECIES_API_KEY`.

- base_url:

  Character scalar. Upload API base URL. Defaults to the development
  server while the upload API is under testing.

## Value

A tibble containing the API response.

## Examples

``` r
if (FALSE) get_upload_permissions() # \dontrun{}
```
