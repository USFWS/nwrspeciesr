test_that("get_species_list parses a bare JSON array into a tibble", {
  httr2::local_mocked_responses(list(mock_json(sample_species_json)))

  res <- get_species_list(region_number = 1, category_name = "Bird")

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2L)
  expect_true(all(
    c("SpeciesID", "ScientificName", "Occurrence") %in% names(res)
  ))
  expect_equal(res$ScientificName[[1]], "Branta canadensis")
})

test_that("get_species_list drops NULL query parameters", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json(sample_species_json)
  })

  get_species_list(refuge_code = "FF08RANH00")

  # RefugeCode and api-version present; unused filters absent.
  expect_match(captured$url, "RefugeCode=FF08RANH00")
  expect_match(captured$url, "api-version=1\\.0")
  expect_no_match(captured$url, "RegionNumber")
  expect_no_match(captured$url, "CategoryName")
})

test_that("get_species_list hits the correct path", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json(sample_species_json)
  })

  get_species_list()

  expect_match(captured$url, "SpeciesList/items")
})

test_that("empty result set returns a 0-row tibble without a spurious column", {
  httr2::local_mocked_responses(list(mock_json("[]")))

  res <- get_species_list(refuge_code = "FF00RNONE0")

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 0L)
  expect_false("value" %in% names(res))
})

test_that("invalid enumerated arguments error locally before any request", {
  # No mocked response registered; a request would error differently.
  expect_error(get_species_list(category_name = "Birds"), "Birds")
  expect_error(get_species_list(occurrence = "Maybe"), "Maybe")
  expect_error(get_species_list(sort_by = "Scientific"), "Scientific")
})

test_that("enumerated arguments match case-insensitively and normalize", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json(sample_species_json)
  })

  get_species_list(
    category_name = "bird",
    occurrence = "present",
    sort_by = "sci"
  )

  # Normalized to the API's canonical casing.
  expect_match(captured$url, "CategoryName=Bird")
  expect_match(captured$url, "Occurrence=Present")
  expect_match(captured$url, "SortBy=Sci")
})
