% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/waiter.R
\name{waiterTheme}
\alias{waiterTheme}
\alias{waiter_set_theme}
\alias{waiter_get_theme}
\alias{waiter_unset_theme}
\title{Define a Theme}
\usage{
waiter_set_theme(html = spin_1(), color = "#333e48", logo = "")

waiter_get_theme()

waiter_unset_theme()
}
\arguments{
\item{html}{HTML content of waiter, generally a spinner, see \code{\link{spinners}}.}

\item{color}{Background color of loading screen.}

\item{logo}{Logo to display.}
}
\description{
Define a theme to be used by all waiter loading screens.
These can be overriden in individual loading screens.
}
