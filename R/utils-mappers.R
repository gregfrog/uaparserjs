#   Copyright 2020 Bob Rudis

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
bind_rows <- function(..., .id = NULL) {

  res <- list(...)

  if (length(res) == 1) res <- res[[1]]

  cols <- unique(unlist(lapply(res, names), use.names = FALSE))

  if (!is.null(.id)) {
    inthere <- cols[.id %in% cols]
    if (length(inthere) > 0) {
      .id <- make.unique(c(inthere, .id))[2]
    }
  }

  id_vals <- if (is.null(names(res))) 1:length(res) else names(res)

  idx <- 1
  do.call(
    rbind.data.frame,
    lapply(res, function(.x) {
      x_names <- names(.x)
      moar_names <- setdiff(cols, x_names)
      if (length(moar_names) > 0) {
        for (i in 1:length(moar_names)) {
          .x[[moar_names[i]]] <- rep(NA, length(.x[[1]]))
        }
      }
      if (!is.null(.id)) {
        .x[[.id]] <- id_vals[idx]
        idx <<- idx + 1
      }
      .x
    })
  ) -> out

  rownames(out) <- NULL

  class(out) <- c("tbl_df", "tbl", "data.frame")

  out

}
