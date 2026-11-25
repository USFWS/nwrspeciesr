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


test_that("download_species_list can save the response to a file", {
  path <- file.path(tempdir(), "species-list.csv")
  httr2::local_mocked_responses(list(mock_csv(sample_species_csv)))

  result <- download_species_list(path = path)

  expect_identical(result, path)
  expect_true(file.exists(path))
  expect_identical(
    rawToChar(readBin(path, "raw", file.info(path)$size)),
    sample_species_csv
  )
})

test_that("download_species_list validates the output path", {
  expect_error(
    download_species_list(path = character()),
    "single non-missing file path"
  )
})
