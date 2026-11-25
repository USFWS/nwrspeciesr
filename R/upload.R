# Upload API defaults and allowed values.
.nwrs_upload_base_url <- "https://staging-iris.fws.gov/APPS/SpeciesAPI/api/"
.nwrs_upload_key_env <- "NWRSPECIES_API_KEY"

.nwrs_upload_fields <- c(
  "refugeCode", "taxonCode", "commonNames", "refugeSynonyms", "occurrence",
  "occurrenceNote", "occurrenceTags", "origin", "originNote", "originTags",
  "abundance", "abundanceNote", "springAbundance", "summerAbundance",
  "fallAbundance", "winterAbundance", "springAbundanceNote",
  "summerAbundanceNote", "fallAbundanceNote", "winterAbundanceNote",
  "status", "refugeAccepted", "isSensitive", "sensitivityNote", "speciesNote",
  "refugeTags", "managementTags", "seasonalityTags", "priorityLevel",
  "updateSpeciesPostEdits"
)

.nwrs_upload_occurrences <- c(
  "Present", "Probably Present", "Unconfirmed", "Not Present In Refuge",
  "Present-Adjacent", "Probably Present-Adjacent",
  "Probably Present-Historical", "Unconfirmed-Adjacent",
  "Unconfirmed-Historical", "Unconfirmed-False Report",
  "Not Present In Refuge-Adjacent", "Not Present In Refuge-Historical",
  "Not Present In Refuge-False Report"
)
.nwrs_upload_occurrence_tags <- c("Adjacent", "Historical", "False Report")
.nwrs_upload_origins <- c(
  "Native", "Non-native", "Vagrant", "Origin Uncertain", "NonNative-Cultivated",
  "NonNative-Invasive", "NonNative-Noxious", "NonNative-Introduced",
  "Native-Cultivated", "Native-Restoration", "Native-Reintroduced",
  "Vagrant-Invasive", "Vagrant-Noxious", "Vagrant-Introduced",
  "Origin Uncertain-Cultivated", "Origin Uncertain-Noxious"
)
.nwrs_upload_origin_tags <- c(
  "Restoration", "Reintroduced", "Cultivated", "Invasive", "Introduced",
  "Noxious"
)
.nwrs_upload_abundance <- c(
  "Abundant", "Common", "Uncommon", "Occasional", "Rare", "Unknown"
)
.nwrs_upload_seasonal_abundance <- c(.nwrs_upload_abundance, "None")
.nwrs_upload_management_tags <- c(
  "Exploitation Concern", "Management Priority", "Resource of Concern",
  "Priority Resource of Concern"
)
.nwrs_upload_seasonality_tags <- c(
  "Resident", "Breeding Season", "Non-breeding Season", "Migratory",
  "Seasonal Occurrence Uncertain"
)
.nwrs_upload_status <- c("Draft", "InReview", "Approved")
.nwrs_upload_refuge_accepted <- c("Yes", "No", "Accepted", "Undecided")
.nwrs_upload_sensitive <- c("Yes", "No")

nwrs_upload_abort <- function(message, class = "nwrspeciesr_upload_validation_error") {
  rlang::abort(message, class = class, call = rlang::caller_env())
}

nwrs_upload_key <- function(api_key) {
  if (is.null(api_key)) {
    api_key <- Sys.getenv(.nwrs_upload_key_env, unset = "")
  }
  if (!is.character(api_key) || length(api_key) != 1L || !nzchar(api_key)) {
    nwrs_upload_abort(
      sprintf(
        "An API key is required. Supply `api_key` or set `%s`.",
        .nwrs_upload_key_env
      ),
      "nwrspeciesr_upload_auth_error"
    )
  }
  api_key
}

nwrs_upload_response_body <- function(response) {
  tryCatch(
    httr2::resp_body_json(response, simplifyVector = TRUE),
    error = function(error) NULL
  )
}

nwrs_upload_perform <- function(request) {
  response <- tryCatch(
    httr2::req_perform(request),
    error = function(error) {
      rlang::abort(
        "The NWRSpecies upload API request failed.",
        class = "nwrspeciesr_upload_api_error",
        parent = error,
        call = rlang::caller_env()
      )
    }
  )
  status <- httr2::resp_status(response)
  if (status < 200L || status >= 300L) {
    error_class <- switch(
      as.character(status),
      `401` = "nwrspeciesr_upload_auth_error",
      `403` = "nwrspeciesr_upload_permission_error",
      `404` = "nwrspeciesr_upload_not_found_error",
      `409` = "nwrspeciesr_upload_conflict_error",
      `422` = "nwrspeciesr_upload_unprocessable_error",
      "nwrspeciesr_upload_api_error"
    )
    rlang::abort(
      sprintf("NWRSpecies upload API returned HTTP status %s.", status),
      class = error_class,
      status_code = status,
      response_body = nwrs_upload_response_body(response),
      call = rlang::caller_env()
    )
  }
  response
}

nwrs_upload_request <- function(
  method,
  path,
  body = NULL,
  api_key = NULL,
  base_url = .nwrs_upload_base_url
) {
  api_key <- nwrs_upload_key(api_key)
  if (!is.character(base_url) || length(base_url) != 1L || !nzchar(base_url)) {
    nwrs_upload_abort("`base_url` must be a non-empty character scalar.")
  }

  request <- httr2::request(base_url) |>
    httr2::req_url_path_append(path) |>
    httr2::req_method(method) |>
    httr2::req_headers(
      Accept = "application/json",
      `X-Api-Key` = api_key
    ) |>
    httr2::req_error(is_error = function(response) FALSE) |>
    httr2::req_user_agent(.nwrs_user_agent) |>
    httr2::req_timeout(120)

  if (!is.null(body)) {
    request <- httr2::req_body_json(request, body, auto_unbox = TRUE)
  }
  nwrs_upload_perform(request)
}

nwrs_upload_json <- function(response) {
  body <- nwrs_upload_response_body(response)
  if (is.null(body)) {
    nwrs_upload_abort(
      "The NWRSpecies upload API returned an invalid JSON response.",
      "nwrspeciesr_upload_schema_error"
    )
  }
  body
}

nwrs_upload_check_scalar <- function(record, field, type = "character") {
  if (!field %in% names(record)) {
    return(invisible(NULL))
  }
  value <- record[[field]]
  valid <- switch(
    type,
    character = is.character(value) && length(value) == 1L &&
      !is.na(value) && nzchar(value),
    numeric = is.numeric(value) && length(value) == 1L &&
      !is.na(value) && is.finite(value),
    logical = is.logical(value) && length(value) == 1L && !is.na(value),
    FALSE
  )
  if (!valid) {
    nwrs_upload_abort(sprintf("`%s` must be a single non-missing %s value.", field, type))
  }
  invisible(NULL)
}

nwrs_upload_check_enum <- function(record, field, choices) {
  if (field %in% names(record)) {
    nwrs_upload_check_scalar(record, field)
    if (!record[[field]] %in% choices) {
      nwrs_upload_abort(sprintf("Invalid `%s` value: %s.", field, record[[field]]))
    }
  }
}

nwrs_upload_check_tags <- function(record, field, choices) {
  if (!field %in% names(record)) {
    return(invisible(NULL))
  }
  nwrs_upload_check_scalar(record, field)
  values <- trimws(strsplit(record[[field]], ",", fixed = TRUE)[[1L]])
  if (any(!nzchar(values)) || any(!values %in% choices)) {
    invalid <- values[!nzchar(values) | !values %in% choices]
    nwrs_upload_abort(
      sprintf("Invalid `%s` value(s): %s.", field, paste(invalid, collapse = ", "))
    )
  }
  invisible(NULL)
}

nwrs_upload_validate_record <- function(record, replace = FALSE) {
  if (!is.list(record) || is.null(names(record)) || anyNA(names(record)) ||
      any(!nzchar(names(record)))) {
    nwrs_upload_abort("Each upload record must be a named list.")
  }
  unknown <- setdiff(names(record), .nwrs_upload_fields)
  if (length(unknown) > 0L) {
    nwrs_upload_abort(sprintf("Unknown upload field(s): %s.", paste(unknown, collapse = ", ")))
  }
  for (field in names(record)) {
    if (is.character(record[[field]]) && length(record[[field]]) == 1L &&
        identical(record[[field]], "")) {
      nwrs_upload_abort(sprintf("`%s` must be omitted instead of empty text.", field))
    }
  }

  nwrs_upload_check_scalar(record, "refugeCode")
  nwrs_upload_check_scalar(record, "taxonCode", "numeric")
  if (!"refugeCode" %in% names(record) || !"taxonCode" %in% names(record)) {
    nwrs_upload_abort("Upload records require `refugeCode` and `taxonCode`.")
  }
  if (record$taxonCode != floor(record$taxonCode)) {
    nwrs_upload_abort("`taxonCode` must be an integer.")
  }
  if (replace && any(!c("status", "refugeAccepted", "isSensitive") %in% names(record))) {
    nwrs_upload_abort(
      "Replacement records require `status`, `refugeAccepted`, and `isSensitive`.",
      "nwrspeciesr_upload_validation_error"
    )
  }

  nwrs_upload_check_enum(record, "occurrence", .nwrs_upload_occurrences)
  nwrs_upload_check_tags(record, "occurrenceTags", .nwrs_upload_occurrence_tags)
  nwrs_upload_check_enum(record, "origin", .nwrs_upload_origins)
  nwrs_upload_check_tags(record, "originTags", .nwrs_upload_origin_tags)
  nwrs_upload_check_enum(record, "abundance", .nwrs_upload_abundance)
  for (field in c("springAbundance", "summerAbundance", "fallAbundance", "winterAbundance")) {
    nwrs_upload_check_enum(record, field, .nwrs_upload_seasonal_abundance)
  }
  nwrs_upload_check_tags(record, "managementTags", .nwrs_upload_management_tags)
  nwrs_upload_check_tags(record, "seasonalityTags", .nwrs_upload_seasonality_tags)
  nwrs_upload_check_enum(record, "status", .nwrs_upload_status)
  nwrs_upload_check_enum(record, "refugeAccepted", .nwrs_upload_refuge_accepted)
  nwrs_upload_check_enum(record, "isSensitive", .nwrs_upload_sensitive)

  if ("priorityLevel" %in% names(record) &&
      (!is.numeric(record$priorityLevel) || length(record$priorityLevel) != 1L ||
       !record$priorityLevel %in% c(1, 3) ||
       is.na(record$priorityLevel) || !is.finite(record$priorityLevel))) {
    nwrs_upload_abort("`priorityLevel` must be 1 or 3.")
  }
  if ("updateSpeciesPostEdits" %in% names(record)) {
    nwrs_upload_check_scalar(record, "updateSpeciesPostEdits", "logical")
  }
  seasons <- c("springAbundance", "summerAbundance", "fallAbundance", "winterAbundance")
  present <- seasons %in% names(record)
  if (any(present) && !all(present)) {
    nwrs_upload_abort("Supply all four seasonal abundance fields or none of them.")
  }
  if ("abundance" %in% names(record) && "occurrence" %in% names(record) &&
      !record$occurrence %in% c("Present", "Present-Adjacent")) {
    nwrs_upload_abort("`abundance` is only valid when `occurrence` is Present.")
  }
  invisible(record)
}

nwrs_upload_create_record <- function(record) {
  nwrs_upload_validate_record(record)
  defaults <- list(
    status = "Draft",
    refugeAccepted = "Undecided",
    isSensitive = "No",
    priorityLevel = 3,
    updateSpeciesPostEdits = TRUE
  )
  for (field in names(defaults)) {
    if (!field %in% names(record)) {
      record[[field]] <- defaults[[field]]
    }
  }
  record
}

#' Get refuges writable with the NWRSpecies upload API key
#'
#' @param api_key Character scalar. API key, or `NULL` to read
#'   `NWRSPECIES_API_KEY`.
#' @param base_url Character scalar. Upload API base URL. Defaults to the
#'   development server while the upload API is under testing.
#' @return A tibble containing the API response.
#' @export
#' @examples
#' \dontrun{get_upload_permissions()}
get_upload_permissions <- function(api_key = NULL, base_url = .nwrs_upload_base_url) {
  response <- nwrs_upload_request("GET", "SpeciesUpload/permissions", api_key = api_key, base_url = base_url)
  nwrs_as_tibble(nwrs_upload_json(response))
}

#' Create one NWRSpecies record
#'
#' @param record Named list containing API field names. `refugeCode` and
#'   `taxonCode` are required; omitted creation fields receive documented API
#'   defaults.
#' @param api_key Character scalar. API key, or `NULL` to read
#'   `NWRSPECIES_API_KEY`.
#' @param base_url Character scalar. Upload API base URL.
#' @return The parsed API response, including the created `speciesId`.
#' @export
#' @examples
#' \dontrun{
#' create_species_record(list(refugeCode = "FF02RNVO00", taxonCode = 93710))
#' }
create_species_record <- function(record, api_key = NULL, base_url = .nwrs_upload_base_url) {
  response <- nwrs_upload_request(
    "POST", "SpeciesUpload/records",
    body = nwrs_upload_create_record(record), api_key = api_key, base_url = base_url
  )
  nwrs_upload_json(response)
}

#' Create multiple NWRSpecies records
#'
#' @param records List of named record lists. At most 200 records are allowed.
#' @inheritParams create_species_record
#' @return The parsed batch response. Individual failures are returned in its
#'   `results` element; a successful HTTP response can contain failed records.
#' @export
#' @examples
#' \dontrun{
#' create_species_records(list(
#'   list(refugeCode = "FF02RNVO00", taxonCode = 93710),
#'   list(refugeCode = "FF02RNVO00", taxonCode = 93711)
#' ))
#' }
create_species_records <- function(records, api_key = NULL, base_url = .nwrs_upload_base_url) {
  if (!is.list(records) || length(records) == 0L || length(records) > 200L) {
    nwrs_upload_abort("`records` must contain between 1 and 200 records.")
  }
  records <- purrr::map(records, nwrs_upload_create_record)
  response <- nwrs_upload_request(
    "POST", "SpeciesUpload/records/batch", body = list(records = records),
    api_key = api_key, base_url = base_url
  )
  nwrs_upload_json(response)
}

#' Replace one existing NWRSpecies record
#'
#' Replacement is a full replacement, not a merge. Include every field that
#' should remain on the record.
#'
#' @inheritParams create_species_record
#' @return The parsed API response.
#' @export
#' @examples
#' \dontrun{
#' replace_species_record(list(
#'   refugeCode = "FF02RNVO00", taxonCode = 93710, status = "Draft",
#'   refugeAccepted = "Undecided", isSensitive = "No"
#' ))
#' }
replace_species_record <- function(record, api_key = NULL, base_url = .nwrs_upload_base_url) {
  nwrs_upload_validate_record(record, replace = TRUE)
  response <- nwrs_upload_request(
    "PUT", "SpeciesUpload/records", body = record,
    api_key = api_key, base_url = base_url
  )
  nwrs_upload_json(response)
}

#' Replace multiple existing NWRSpecies records
#'
#' Replacement is a full replacement and the batch is all-or-nothing. At most
#' 25 records are allowed.
#'
#' @param records List of named record lists. At most 25 records are allowed.
#' @inheritParams create_species_record
#' @return The parsed API response.
#' @export
#' @examples
#' \dontrun{
#' replace_species_records(list(
#'   list(refugeCode = "FF02RNVO00", taxonCode = 93710, status = "Draft",
#'        refugeAccepted = "Undecided", isSensitive = "No")
#' ))
#' }
replace_species_records <- function(records, api_key = NULL, base_url = .nwrs_upload_base_url) {
  if (!is.list(records) || length(records) == 0L || length(records) > 25L) {
    nwrs_upload_abort("`records` must contain between 1 and 25 records.")
  }
  purrr::walk(records, nwrs_upload_validate_record, replace = TRUE)
  response <- nwrs_upload_request(
    "PUT", "SpeciesUpload/records/batch", body = list(records = records),
    api_key = api_key, base_url = base_url
  )
  nwrs_upload_json(response)
}

#' Add URL evidence to an NWRSpecies record
#'
#' @param evidence Named list containing an evidence payload. Identify the
#'   record with `speciesId`, or with both `refugeCode` and `taxonCode`.
#' @inheritParams create_species_record
#' @return The parsed API response, including the `evidenceCode`.
#' @export
#' @examples
#' \dontrun{
#' add_species_evidence(list(
#'   speciesId = 481922, url = "https://example.gov/report/123",
#'   observationDate = "2026-05-14", datePrecisionId = 1,
#'   photograph = TRUE
#' ))
#' }
add_species_evidence <- function(evidence, api_key = NULL, base_url = .nwrs_upload_base_url) {
  if (!is.list(evidence) || is.null(names(evidence)) || anyNA(names(evidence)) ||
      any(!nzchar(names(evidence)))) {
    nwrs_upload_abort("`evidence` must be a named list.")
  }
  allowed_fields <- c(
    "speciesId", "refugeCode", "taxonCode", "url", "observationDate",
    "datePrecisionId", "visualReport", "auralReport", "specimen",
    "photograph", "audioRecording", "videoRecording", "other"
  )
  unknown <- setdiff(names(evidence), allowed_fields)
  if (length(unknown) > 0L) {
    nwrs_upload_abort(
      sprintf("Unknown evidence field(s): %s.", paste(unknown, collapse = ", "))
    )
  }
  has_id <- "speciesId" %in% names(evidence)
  has_key <- all(c("refugeCode", "taxonCode") %in% names(evidence))
  if (has_id == has_key) {
    nwrs_upload_abort("Supply either `speciesId` or both `refugeCode` and `taxonCode`.")
  }
  if (!"url" %in% names(evidence) || !is.character(evidence$url) ||
      length(evidence$url) != 1L || !grepl("^https?://[^ ]+$", evidence$url) ||
      nchar(evidence$url) > 256L) {
    nwrs_upload_abort("`url` must be an http(s) URL of at most 256 characters.")
  }
  if (!"observationDate" %in% names(evidence) ||
      !is.character(evidence$observationDate) ||
      length(evidence$observationDate) != 1L ||
      is.na(evidence$observationDate) ||
      !grepl("^\\d{4}-\\d{2}-\\d{2}$", evidence$observationDate) ||
      is.na(tryCatch(
        suppressWarnings(as.Date(evidence$observationDate)),
        error = function(error) as.Date(NA_character_)
      )) ||
      !identical(
        format(tryCatch(
          suppressWarnings(as.Date(evidence$observationDate)),
          error = function(error) as.Date(NA_character_)
        )),
        evidence$observationDate
      )) {
    nwrs_upload_abort("`observationDate` must be a valid ISO date.")
  }
  if (!"datePrecisionId" %in% names(evidence) ||
      !is.numeric(evidence$datePrecisionId) || length(evidence$datePrecisionId) != 1L ||
      is.na(evidence$datePrecisionId) ||
      !is.finite(evidence$datePrecisionId) ||
      evidence$datePrecisionId != floor(evidence$datePrecisionId) ||
      !evidence$datePrecisionId %in% 1:7) {
    nwrs_upload_abort("`datePrecisionId` must be an integer from 1 through 7.")
  }
  evidence_fields <- c(
    "visualReport", "auralReport", "specimen", "photograph", "audioRecording",
    "videoRecording", "other"
  )
  supplied <- intersect(evidence_fields, names(evidence))
  if (length(supplied) == 0L || !any(vapply(evidence[supplied], isTRUE, logical(1)))) {
    nwrs_upload_abort("At least one evidence type must be TRUE.")
  }
  for (field in supplied) {
    if (!is.logical(evidence[[field]]) || length(evidence[[field]]) != 1L ||
        is.na(evidence[[field]])) {
      nwrs_upload_abort(sprintf("`%s` must be a single non-missing logical value.", field))
    }
  }
  response <- nwrs_upload_request(
    "POST", "SpeciesUpload/evidence", body = evidence,
    api_key = api_key, base_url = base_url
  )
  nwrs_upload_json(response)
}
