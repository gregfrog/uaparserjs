as_tibble <- function(.x) {

  out <- as.data.frame(.x, stringsAsFactors = FALSE)
  class(out) <- c("tbl_df", "tbl", "data.frame")
  out

}

#' Parse a vector of user agents into a data frame
#'
#' Takes in a character vector of user agent strings and returns a data frame classed as tibble.
#' of parsed user agents.
#'
#' @param user_agents a character vector of user agents
#' @param .progress if `TRUE`  will display a progress bar in interactive mode
#' @export
#' @return a data frame classed as tibble with columns for user agent family, major & minor versions
#'     plus patch level along with OS family and major & minor versions plus
#'     device brand and model.
#' @references <https://github.com/ua-parser/uap-core/>
#' @note The regex YAML is now updated when the package is rebuilt.  The effective date is that of the package submission.
#' @examples
#' ua_parse(paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
#'                 "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
#'                 "Chrome/15.0.874.106 Safari/535.2", collapse=""))
ua_parse <- function(user_agents, .progress=FALSE) {

  if (.progress) pb <- progress::progress_bar$new(length(user_agents))
  if (.progress) pb$tick(0)

  lapply(user_agents, function(x) {

    if (.progress) pb$tick()$print()

    res <- .pkgenv$cache[[x]]

    if (length(res) > 0) {

      res

    } else {

      .pkgenv$cache[[x]] <- as_tibble(as.list(unlist(.pkgenv$ctx$call("parser.parse", x))))
      .pkgenv$cache[[x]]

    }

  }) -> out

  out <- bind_rows(out)

  as_tibble(out)

}

#' @rdname ua_parse
#' @export
get_cache <- function() { .pkgenv$cache }
