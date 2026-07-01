#   Copyright 2020 Bob Rudis
#   portions Copyright 2026 Greg Hunt

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# this has limitations and is more like 75% of dplyr::bind_rows()
# this is also orders of magnitude slower than dplyr::bind_rows()

bind_rows <- function(...) {

  res <- list(...)

  if (length(res) == 1) res <- res[[1]]

  cols <- unique(unlist(lapply(res, names), use.names = FALSE))

  do.call(
    rbind.data.frame,
    lapply(res, function(.x) {
        if(is.data.frame(.x) && nrow(.x))
        {
          x_names <- names(.x)
          moar_names <- setdiff(cols, x_names)
          for (i in seq_along(moar_names)) {
            .x[[moar_names[i]]] <- rep(NA, length(.x[[1]]))
          }
        }
      .x
    })
  ) -> out

  rownames(out) <- NULL

  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

}

internal_as_tibble <- function(.x) {

  out <- as.data.frame(.x, stringsAsFactors = FALSE)
  class(out) <- c("tbl_df", "tbl", "data.frame")
  out
}

nullToNA <- function(x) {
  lapply(x, function(x) {
    if (is.list(x)){
      nullToNA(x)
    } else{
      if(is.null(x)) NA else(x)
    }
  })
}

get_cache <- function() { .pkgenv$cache }

cache_reset <- function() { .pkgenv$cache = list() }
