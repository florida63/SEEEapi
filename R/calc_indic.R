#' Calculate SEEE indicators
#'
#' @param indic the name of the indicator
#' @param version version number of the indicator. If not provided, the latest
#'   is used
#' @param file_paths character vector with the paths of the files used to
#'   calculate the indicator. The order must be the ones described in the
#'   documentation of the indicator
#' @param data a list of data.frames. Used if file_paths is not provided. The
#'   order must be the ones described in the documentation of the indicator
#'
#' @return a list with two elements:
#'
#' @importFrom dplyr '%>%' pull bind_cols filter if_else n as_tibble
#' @importFrom httr POST upload_file
#' @importFrom xml2 read_html
#' @importFrom rvest html_text
#' @importFrom readr read_delim write_delim
#' @importFrom purrr map map_lgl map_chr walk
#' @importFrom stringr str_match
#'
#' @export
calc_indic <- function(indic, version = NULL, file_paths = NULL, data = NULL) {
  find_latest_version <- function(x) {
    x_split <- strsplit(x, split = ".", fixed = TRUE) %>%
      map(as.numeric)                                 %>%
      map(as_tibble)                                  %>%
      bind_cols()                                     %>%
      t()                                             %>%
      as.data.frame()                                 %>%
      (function(df) {
        colnames(df) <- c("major", "minor", "dev")
        df
      })

    filter(x_split,
           major == max(major))   %>%
      filter(minor == max(minor)) %>%
      filter(dev   == max(dev))   %>%
      paste(collapse = ".")
  }

  if (is.null(version)) {
    version <- get_indic(indic = indic) %>%
      pull(Version)                     %>%
      find_latest_version()
  }

  body <- list(indicateur = indic,
               version = version)

  if (!is.null(file_paths)) {
    files <- map(file_paths, upload_file)
    names(files) <- paste0("file", seq(length(files)))
  } else {
    if (!is.null(data)) {
      delim <- if_else(grepl("EBio_", indic), ";", "\t")

      if (grepl("data.frame", class(data))) {
        file_paths <- tempfile(fileext = ".txt")

        write_delim(x = data, path = file_paths, delim = delim)

      } else {
        if (grepl("list", class(data)) &
            all(map_lgl(data,
                       function(df) {
                         any(grepl("data.frame", class(df)))
                       }))) {
          file_paths <- map_chr(seq(length(data)),
                               (function(i) tempfile(fileext = ".txt")))

          walk(seq(length(file_paths)),
               function(i) {
                 write_delim(x     = data[[i]],
                             path  = file_paths[i],
                             delim = delim)
               })
        }
      }

      files <- map(file_paths, upload_file)
      names(files) <- paste0("file", seq(length(files)))

    } else {
      stop("Either one of file_paths or data must be provided")
    }
  }

  body <- c(body, files)

  POST(url    = "http://seee.eaufrance.fr/api/calcul/",
       body   = body,
       encode = "multipart") %>%
    read_html()              %>%
    html_text()              %>%
    (function(x) {
      if (grepl("Calcul non réalisé", x)) {
        x
      } else {
        if (grepl("asynchrone", x)) {
          id_calcul <- str_match(string  = x,
                                 pattern = "\\{.*id_calcul\\\":\\\"(.*)\\\"\\}")[,2]

          cat("\nCalcul asynchrone\n")

          res <- "en cours"

          while (grepl(pattern = "en cours", x = res)) {
            Sys.sleep(5)

            res <- POST(url  = "http://seee.eaufrance.fr/api/resultat/",
                        body = list(id_calcul = id_calcul)) %>%
              read_html()                                   %>%
              html_text()

            cat(".")
            flush.console()
          }

          if (grepl("erreur", res)) {
            res
          } else {
            list(info = strsplit(res, split = "\n")[[1]][1] %>%
                   gsub(pattern = ";", replacement = " "),
                 result =  read_delim(res, delim = ";", skip = 1,
                                      col_type = cols(.default = "c")))

          }

        } else {
          list(info = strsplit(x, split = "\n")[[1]][1] %>%
                 gsub(pattern = ";", replacement = " "),
               result =  read_delim(x, delim = ";", skip = 1,
                                    col_type = cols(.default = "c")))

        }
      }
    })

}