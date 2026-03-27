#' Parse 'User-Agent' Strings
#'
#' Despite there being a section in RFC 7231
#' <https://tools.ietf.org/html/rfc7231#section-5.5.3> defining a suggested
#' structure for 'User-Agent' headers this data is notoriously difficult
#' to parse consistently. Tools are provided that will take in user agent
#' strings and return structured R objects. This is a 'V8'-backed package
#' based on the 'ua-parser' project <https://github.com/ua-parser>.
#'
#' @name uaparserjs
#' @author Bob Rudis (@@hrbrmstr)
#' @import V8 progress
"_PACKAGE"
