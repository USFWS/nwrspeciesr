# Shared helpers to build fake httr2 responses for offline testing.

# Build a mock JSON response with the given (already-serialized) body.
mock_json <- function(body, status = 200L) {
  httr2::response(
    status_code = status,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(body)
  )
}

# Build a mock CSV response.
mock_csv <- function(body, status = 200L) {
  httr2::response(
    status_code = status,
    headers = list(`Content-Type` = "text/csv"),
    body = charToRaw(body)
  )
}

# A minimal two-record SpeciesList payload (bare JSON array).
sample_species_json <- paste0(
  '[',
  '{"SpeciesID":1,"RegionNumber":1,"RefugeName":"Test NWR",',
  '"CategoryName":"Bird","ScientificName":"Branta canadensis",',
  '"Occurrence":"Present"},',
  '{"SpeciesID":2,"RegionNumber":1,"RefugeName":"Test NWR",',
  '"CategoryName":"Bird","ScientificName":"Anas platyrhynchos",',
  '"Occurrence":"Present"}',
  ']'
)

sample_categories_json <- '["Bird","Mammal","Fish"]'
sample_occurrences_json <- '["Present","ProbablyPresent","NotPresent"]'
sample_species_csv <- paste(
  "SpeciesID,RegionNumber,RefugeName,ScientificName,Occurrence",
  "1,1,Test NWR,Branta canadensis,Present",
  "2,1,Test NWR,Anas platyrhynchos,Present",
  sep = "\n"
)
