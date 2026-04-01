#    Copyright 2020 Bob Rudis
#    Copyright 2026 Greg Hunt

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#' Parse 'User-Agent' Strings
#'
#' Despite there being a section in RFC 7231
#' <https://tools.ietf.org/html/rfc7231#section-5.5.3> defining a suggested
#' structure for 'User-Agent' headers this data is notoriously difficult
#' to parse consistently. Tools are provided that will take in user agent
#' strings and return structured R objects. This is a 'V8'-backed package
#' based on the 'ua-parser' project <https://github.com/ua-parser>.
#' 
#' The package incorporates regular expressions and test data from the ua parser project 
#' that are copyrighted by Google and the UA Parser contributors and are used 
#' under an Apache 2 license.  See the UA parser project for details.
#'
#' @name uaparserjs
#' @author Bob Rudis (@@hrbrmstr)
#' @import V8 progress
"_PACKAGE"
