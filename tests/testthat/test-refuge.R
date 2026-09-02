# Fixture crosswalk with Alaska duplicate-name edge cases.
# Codes are illustrative fixtures, not authoritative unit codes.
fx <- tibble::tibble(
  refuge_code = c(
    "FF07RKEN00",
    "FF07RYKD00",
    "FF07RYKF00",
    "FF07RARC00",
    "FF07RKOD00",
    "FF07RALP00",
    "FF07RALM00"
  ),
  refuge_name = c(
    "Kenai National Wildlife Refuge",
    "Yukon Delta National Wildlife Refuge",
    "Yukon Flats National Wildlife Refuge",
    "Arctic National Wildlife Refuge",
    "Kodiak National Wildlife Refuge",
    "Alaska Peninsula National Wildlife Refuge",
    "Alaska Maritime National Wildlife Refuge"
  ),
  region_number = 7L
)

test_that("exact full name resolves", {
  expect_equal(
    resolve_refuge_code("Kenai National Wildlife Refuge", fx),
    "FF07RKEN00"
  )
})

test_that("case and suffix variants all resolve to the same code", {
  variants <- c(
    "Kenai",
    "kenai",
    "Kenai Refuge",
    "kenai refuge",
    "Kenai NWR",
    "kenai nwr",
    "Kenai NWRS",
    "Kenai National Wildlife Refuge"
  )
  codes <- vapply(variants, resolve_refuge_code, character(1), crosswalk = fx)
  expect_true(all(codes == "FF07RKEN00"))
})

test_that("punctuation and extra whitespace are tolerated", {
  expect_equal(resolve_refuge_code("  KENAI,  NWR ", fx), "FF07RKEN00")
})

test_that("exact match wins over partial match", {
  expect_equal(resolve_refuge_code("Yukon Delta", fx), "FF07RYKD00")
  expect_equal(resolve_refuge_code("yukon flats nwr", fx), "FF07RYKF00")
})

test_that("ambiguous shared-token name errors and lists candidates", {
  expect_error(resolve_refuge_code("Yukon", fx), "multiple refuges")
  expect_error(resolve_refuge_code("Yukon", fx), "Yukon Delta")
  expect_error(resolve_refuge_code("Yukon", fx), "Yukon Flats")
})

test_that("ambiguous 'Alaska' lists both Peninsula and Maritime", {
  expect_error(resolve_refuge_code("Alaska", fx), "Alaska Peninsula")
  expect_error(resolve_refuge_code("Alaska", fx), "Alaska Maritime")
})

test_that("no match errors with suggestions", {
  expect_error(resolve_refuge_code("Kenia", fx), "Did you mean")
  expect_error(
    resolve_refuge_code("Nonexistent Swamp", fx),
    "No refuge matched"
  )
})

test_that("invalid refuge_name input errors", {
  expect_error(resolve_refuge_code(c("a", "b"), fx), "single non-missing")
  expect_error(resolve_refuge_code(NA_character_, fx), "single non-missing")
  expect_error(resolve_refuge_code("   ", fx), "empty after normalization")
})

test_that("crosswalk missing required columns errors", {
  bad <- tibble::tibble(code = "x", name = "y")
  expect_error(resolve_refuge_code("Kenai", bad), "refuge_code.*refuge_name")
})

test_that("get_species_list resolves refuge_name to RefugeCode in the URL", {
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    mock_json(sample_species_json)
  })

  get_species_list(refuge_name = "Kenai", crosswalk = fx)

  expect_match(captured$url, "RefugeCode=FF07RKEN00")
})

test_that("supplying both refuge_code and refuge_name errors", {
  expect_error(
    get_species_list(
      refuge_code = "FF07RKEN00",
      refuge_name = "Kenai",
      crosswalk = fx
    ),
    "not both"
  )
})
