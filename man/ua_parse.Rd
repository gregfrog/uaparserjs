\name{ua_parse}
\alias{ua_parse}
\alias{get_cache}
\title{Parse a vector of user agents into a data frame}
\usage{
ua_parse(user_agents, .progress = FALSE, useNA=FALSE)

get_cache()
}
\arguments{
\item{user_agents}{a character vector of user agents}

\item{.progress}{if `TRUE`  will display a progress bar in interactive mode}

\item{useNA}{If `TRUE` will ensure that for each user agent passed in a parsed result is returned and NA values will be returned for
all attributes.  The default value is FALSE for compatibility with existing behaviour.  TRUE is recommended.  When FALSE, NULL or zero length string user agent strings are not parsed and are not returned 
in the data frame and under some circumstances not all attributes are returned. 
}
}
\value{
a data frame classed as tibble with columns for:
\itemize{
\item{}user agent string (note that with useNA=TRUE a null string is returned as an NA value not a null)
\item{}user agent family (ua.family)
\item{}major & minor versions (ua.major, ua.minor)
\item{}patch level (ua.patch)
\item{}OS family (os.family)
\item{}major & minor OS versions (os.major, os.minor) 
\item{}OS patch (os.patch)
\item{}device family (device.family)
\item{}device brand (device.brand) device model (device.model)
}
The Family values are identified as "Other" for unrecognised or unparseable user agent strings.

When \code{useNA} is true and the \link[tibble]{tibble} package is available, an actual tibble is returned.   
}
\description{
Takes in a character vector of user agent strings and returns a data frame (classed as tibble) 
of parsed user agent attributes.
}
\note{
The regex YAML from uap-core is updated when the package is rebuilt.  The date amd abbreviated hash of the last uap-core commit can be found in the NEWS file.
}
\examples{
ua_parse(paste0("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, ",
                "like Gecko) Ubuntu/11.10 Chromium/15.0.874.106 ",
                "Chrome/15.0.874.106 Safari/535.2", collapse=""))
}
\references{
<https://github.com/ua-parser/uap-core/>
}
