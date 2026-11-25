test_that("upload permissions uses the API key header", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json('[{"refugeCode":"FF02RNVO00"}]')
  })
  result <- get_upload_permissions(api_key = "test-key")
  expect_s3_class(result, "tbl_df")
  expect_match(captured$url, "SpeciesUpload/permissions")
  expect_match(paste(httr2::req_headers(captured), collapse = " "), "test-key")
})

test_that("creating a record applies documented defaults", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json('{"speciesId":481922,"status":"Draft"}', status = 201L)
  })
  result <- create_species_record(
    list(refugeCode = "FF02RNVO00", taxonCode = 93710),
    api_key = "test-key"
  )
  body <- captured$body$data
  expect_equal(result$speciesId, 481922)
  expect_identical(body$status, "Draft")
  expect_identical(body$refugeAccepted, "Undecided")
  expect_identical(body$isSensitive, "No")
  expect_identical(body$priorityLevel, 3)
  expect_identical(body$updateSpeciesPostEdits, TRUE)
})

test_that("batch functions enforce their different limits", {
  records <- rep(list(list(refugeCode = "FF02RNVO00", taxonCode = 1)), 201)
  expect_error(create_species_records(records, api_key = "test-key"), "200")
  records <- rep(list(list(
    refugeCode = "FF02RNVO00", taxonCode = 1, status = "Draft",
    refugeAccepted = "Undecided", isSensitive = "No"
  )), 26)
  expect_error(replace_species_records(records, api_key = "test-key"), "25")
})

test_that("replacement requires full-replacement control fields", {
  expect_error(
    replace_species_record(
      list(refugeCode = "FF02RNVO00", taxonCode = 93710),
      api_key = "test-key"
    ),
    "status.*refugeAccepted.*isSensitive"
  )
})

test_that("evidence validates the record identifier and evidence type", {
  evidence <- list(
    speciesId = 481922, url = "https://example.gov/report/123",
    observationDate = "2026-05-14", datePrecisionId = 1, photograph = TRUE
  )
  httr2::local_mocked_responses(list(mock_json('{"evidenceCode":"e.481922.1"}', 201L)))
  result <- add_species_evidence(evidence, api_key = "test-key")
  expect_identical(result$evidenceCode, "e.481922.1")
  expect_error(
    add_species_evidence(evidence[names(evidence) != "photograph"], api_key = "test-key"),
    "evidence type"
  )
  expect_error(
    add_species_evidence(c(evidence, list(refugeCode = "FF02RNVO00", taxonCode = 93710)), api_key = "test-key"),
    "either `speciesId`"
  )
})

test_that("upload API errors retain a package-specific class without the key", {
  httr2::local_mocked_responses(list(mock_json('{"detail":"bad key"}', 401L)))
  expect_error(
    get_upload_permissions(api_key = "secret-key"),
    class = "nwrspeciesr_upload_auth_error"
  )
})

test_that("upload functions require an API key", {
  withr::local_envvar(NWRSPECIES_API_KEY = NA_character_)
  expect_error(get_upload_permissions(), "API key")
})

test_that("record validation rejects missing numeric values and invalid priority", {
  expect_error(
    create_species_record(
      list(refugeCode = "FF02RNVO00", taxonCode = NA_real_),
      api_key = "test-key"
    ),
    "taxonCode"
  )
  expect_error(
    create_species_record(
      list(refugeCode = "FF02RNVO00", taxonCode = 93710, priorityLevel = NA_real_),
      api_key = "test-key"
    ),
    "priorityLevel"
  )
})

test_that("evidence validation rejects invalid dates and unknown fields", {
  evidence <- list(
    speciesId = 481922, url = "https://example.gov/report/123",
    observationDate = "2026-99-99", datePrecisionId = 1, photograph = TRUE
  )
  expect_error(
    add_species_evidence(evidence, api_key = "test-key"),
    "valid ISO date"
  )
  evidence$observationDate <- "2026-05-14"
  expect_error(
    add_species_evidence(c(evidence, list(unexpectedField = TRUE)), api_key = "test-key"),
    "Unknown evidence field"
  )
})
