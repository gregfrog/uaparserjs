
  #  Copyright 2020 Bob Rudis
  #  Copyright 2026 Greg Hunt

  #  Licensed under the Apache License, Version 2.0 (the "License");
  #  you may not use this file except in compliance with the License.
  #  You may obtain a copy of the License at

  #      http://www.apache.org/licenses/LICENSE-2.0

  #  Unless required by applicable law or agreed to in writing, software
  #  distributed under the License is distributed on an "AS IS" BASIS,
  #  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  #  See the License for the specific language governing permissions and
  #  limitations under the License.


as_tibble <- function(.x) {

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

ua_parse <- function(user_agents, .progress=FALSE, useNA=FALSE) {

  if(useNA) {
    return(parseWithNA(user_agents, .progress=FALSE))
  }
  else
  {
    if (.progress) pb <- progress::progress_bar$new(length(user_agents))
    if (.progress) pb$tick(0)

    lapply(user_agents, function(x) {

      cacheKey = paste0("1", x)

      if (.progress) pb$tick()$print()

      res <- .pkgenv$cache[[cacheKey]]

      if (length(res) > 0) {

       res

      } else {

# ghastly thing below to maintin compatibility with an existing bug where a zero length string returns an empty data frame
# regardless of how it parsed, adding a prefix to distingush the different code paths changed that behaviour.

        if(!is.na(x) && !is.null(x) && x == "")
        {
          return(as_tibble(list()))
        }

        .pkgenv$cache[[x]] <- as_tibble(as.list(unlist(.pkgenv$ctx$call("parser.parse", x))))
        return(.pkgenv$cache[[x]])

      }

    }) -> out

    out <- bind_rows(out)

    return(as_tibble(out))
  }
}

parseWithNA <- function(user_agents, .progress=FALSE)
{
  if (.progress) pb <- progress::progress_bar$new(length(user_agents))
  if (.progress) pb$tick(0)

  if (is.null(user_agents))
  {
    user_agents = list(NULL)
  }

  lapply(user_agents, function(x) {

    cacheKey = paste0("0", x)

    if (.progress) pb$tick()$print()

    cacheable = x != "" && !is.null(x) && !is.na(x)

    if(is.null(x))
    {
      x = NA
    }

    if(cacheable)
    {
      res <- .pkgenv$cache[[cacheKey]]
      if (length(res) > 0)
      {
        return(res)
      }
    }

    wk2 = as.list(unlist(nullToNA(.pkgenv$ctx$call("parser.parse", x))))
    if(cacheable)
    {
      .pkgenv$cache[[cacheKey]] = wk2
    }
    return(wk2)
  }
  ) -> out

  out3 <- bind_rows(out)
  return(as_tibble(out3))

}

get_cache <- function() { .pkgenv$cache }

cache_reset <- function() { .pkgenv$cache = list() }


