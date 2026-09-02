test_that("get_species_categories returns a tibble of values", {
  httr2::local_mocked_responses(list(mock_json(sample_categories_json)))

  res <- get_species_categories()

  expect_s3_class(res, "tbl_df")
  expect_true("Bird" %in% res[[1]])
})

test_that("get_species_occurrences hits the (misspelled) occurences path", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json(sample_occurrences_json)
  })

  res <- get_species_occurrences()

  expect_match(captured$url, "SpeciesList/occurences")
  expect_s3_class(res, "tbl_df")
})
