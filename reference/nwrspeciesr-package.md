# nwrspeciesr: Interface to the FWS NWRSpecies Occurrence Database API

Provides an R interface to the U.S. Fish and Wildlife Service National
Wildlife Refuge System species occurrence database (NWRSpecies, formerly
FWSpecies). Functions retrieve refuge species lists and related lookup
values from the public web services.

## Retrieving species records

- [`get_species_list()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_list.md)
  queries the `SpeciesList/items` endpoint (paged JSON) with optional
  filters for region, refuge, category, occurrence, and ITIS TSN.

- [`download_species_list()`](https://solid-lamp-km35j47.pages.github.io/reference/download_species_list.md)
  queries the CSV `DownloadFile` endpoint, the documented way to
  retrieve all records in a single call when combined with a large
  `rows_per_page`.

## Lookup values

- [`get_species_categories()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_categories.md)
  returns valid taxonomic category names.

- [`get_species_occurrences()`](https://solid-lamp-km35j47.pages.github.io/reference/get_species_occurrences.md)
  returns valid occurrence values.

## API details

All functions target the public web services at
`https://iris.fws.gov/APPS/SpeciesAPI/api/` and require an `api_version`
(default "1.0"). Only the public `SpeciesListBasic` method is currently
available; sensitive and Draft records are never returned.

## See also

The API documentation (Swagger) at
`https://iris.fws.gov/APPS/SpeciesAPI/swagger/index.html`.

## Author

**Maintainer**: McCrea Cobb <mccrea_cobb@fws.gov>
([ORCID](https://orcid.org/0000-0001-9412-1468))

Authors:

- McCrea Cobb <mccrea_cobb@fws.gov>
  ([ORCID](https://orcid.org/0000-0001-9412-1468))
