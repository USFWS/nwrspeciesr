test_that("download_species_list parses CSV into a tibble", {
  httr2::local_mocked_responses(list(mock_csv(sample_species_csv)))

  res <- download_species_list(
    refuge_code = "FF08RANH00",
    rows_per_page = 130000
  )

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2L)
  expect_equal(res$ScientificName[[2]], "Anas platyrhynchos")
})

test_that("download_species_list uses the DownloadFile path", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_csv(sample_species_csv)
  })

  download_species_list()

  expect_match(captured$url, "SpeciesList/items/DownloadFile")
})
