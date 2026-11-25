# Changelog

## nwrspeciesr 0.2.0

- Fix package metadata and update README documentation for the
  experimental authenticated upload API.
- Harden upload record and evidence validation for missing numeric
  values, invalid dates, and unknown evidence fields.
- Add experimental authenticated upload and edit functions for the
  internal `SpeciesUpload` API, including permissions, single-record and
  batch create and replace operations, and evidence URLs.
- [`get_species_categories()`](https://usfws.github.io/nwrspeciesr/reference/get_species_categories.md)
  and
  [`get_species_occurrences()`](https://usfws.github.io/nwrspeciesr/reference/get_species_occurrences.md)
  document their API-version-specific lookup values.
- [`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md)
  now reports mutual `refuge_code`/`refuge_name` errors with a
  package-specific class.
- Add file-backed downloads through the `path` argument of
  [`download_species_list()`](https://usfws.github.io/nwrspeciesr/reference/download_species_list.md).
- Add structured API and response-schema errors for programmatic error
  handling.
- Improve validation, refuge-name matching, API timeouts, and retry
  handling.
- Add automated R CMD check coverage for release and development R on
  Linux and Windows.
- Add test coverage reporting and a reproducible README source document.

## nwrspeciesr 0.1.0

Initial release. Provides a read-only R interface to the U.S. Fish &
Wildlife Service NWRSpecies (formerly FWSpecies) occurrence database.

### Features

- [`get_species_list()`](https://usfws.github.io/nwrspeciesr/reference/get_species_list.md)
  retrieves refuge species occurrence records from the public
  `SpeciesList/items` endpoint, with optional filters for region,
  refuge, taxonomic category, occurrence, and ITIS TSN, plus sorting and
  pagination.
- [`download_species_list()`](https://usfws.github.io/nwrspeciesr/reference/download_species_list.md)
  retrieves records from the CSV `DownloadFile` endpoint.
- [`get_species_categories()`](https://usfws.github.io/nwrspeciesr/reference/get_species_categories.md)
  and
  [`get_species_occurrences()`](https://usfws.github.io/nwrspeciesr/reference/get_species_occurrences.md)
  return the valid category and occurrence values accepted by the API.
- [`get_refuges()`](https://usfws.github.io/nwrspeciesr/reference/get_refuges.md)
  retrieves a live refuge name / unit code crosswalk from the FWS Unit
  REST API via the **fwsunitr** package.
