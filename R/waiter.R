#' Waiter
#' 
#' Programatically show and hide loading screens.
#' 
#' @param html HTML content of waiter, generally a spinner, see \code{\link{spinners}}.
#' @param color Background color of loading screen.
#' @param logo Logo to display.
#' @param id Id of element to hide or element on which to show waiter over.
#' @param hide_on_render Set to \code{TRUE} to automatically hide the waiter
#' when the plot in \code{id} is drawn. Note the latter will only work with
#' shiny plots, tables, htmlwidgets, etc. but will not work with arbitrary
#' elements.
#' @param spinners Spinners to include. By default all the CSS files for 
#' all spinners are included you can customise this only that which you 
#' need in order to reduce the amount of CSS that needs to be loaded and
#' improve page loading speed. There are 7 spinner kits. The spinner kit
#' required for the spinner you use is printed in the R console when 
#' using the spinner. You can specify a single spinner kit e.g.: \code{1}
#' or multiple spinner kits as a vector e.g.: \code{c(1,3,6)}.
#' @param include_js Deprecated argument, no longer needed.
#' 
#' @section Functions:
#' \itemize{
#'  \item{\code{use_waiter} and \code{waiter_use}: waiter dependencies to include anywhere in your UI but ideally at the top.}
#'  \item{\code{waiter_show_on_load}: Show a waiter on page load, before the session is even loaded, include in UI \emph{after} \code{use_waiter}.}
#'  \item{\code{waiter_show}: Show waiting screen.}
#'  \item{\code{waiter_hide}: Hide any waiting screen.}
#'  \item{\code{waiter_on_busy}: Automatically shows the waiting screen when the server is busy, and hides it when it goes back to idle.}
#'  \item{\code{waiter_update}: Update the content \code{html} of the waiting screen.}
#'  \item{\code{waiter_hide_on_render}: Hide any waiting screen when the output is drawn, useful for outputs that take a long time to draw, \emph{use in \code{ui}}.}
#' }
#' 
#' @examples
#' library(shiny)
#' 
#' ui <- fluidPage(
#'   use_waiter(), # dependencies
#'   waiter_show_on_load(spin_fading_circles()), # shows before anything else 
#'   actionButton("show", "Show loading for 5 seconds")
#' )
#' 
#' server <- function(input, output, session){
#'   waiter_hide() # will hide *on_load waiter
#'   
#'   observeEvent(input$show, {
#'     waiter_show(
#'       html = tagList(
#'         spin_fading_circles(),
#'         "Loading ..."
#'       )
#'     )
#'     Sys.sleep(3)
#'     waiter_hide()
#'   })
#' }
#' 
#' if(interactive()) shinyApp(ui, server)
#' 
#' @import shiny
#' @name waiter
#' @export
use_waiter <- function(spinners = 1:7, include_js = TRUE){

  if(!isTRUE(include_js))
    warning("include_js argument is deprecated, it is no longer needed")

  # must haves
  header <- tags$head(
    tags$link(
      href = "waiter-assets/waiter/waiter.css",
      rel="stylesheet",
      type="text/css"
    )
  )

  # spinner kits
  if(1 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/spinkit.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(2 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/css-spinners.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(3 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/devloop.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(4 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/spinners.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(5 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/spinbolt.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(6 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/loaders.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  if(7 %in% spinners)
    header <- shiny::tagAppendChildren(
      header,
      tags$link(
        href = "waiter-assets/waiter/custom.css",
        rel="stylesheet",
        type="text/css"
      )
    )

  # add js
  header <- shiny::tagAppendChildren(
    header,
    tags$script(
      src = "waiter-assets/waiter/waiter.js"
    ),
    tags$script(
      src = "waiter-assets/waiter/custom.js"
    )
  )

  # singleton it
  singleton(header)

}

#' @rdname waiter
#' @export
waiter_use <- use_waiter

#' @rdname waiter
#' @export
waiter_show <- function(id = NULL, html = spin_1(), color = "#333e48", logo = "", 
  hide_on_render = !is.null(id)){
  
  html <- as.character(html)
  html <- gsub("\n", "", html)

  if(hide_on_render && is.null(id))
    stop("Cannot `hide_on_render` when `id` is not specified")

  opts <- list(
    id = id,
    html = html,
    color = color,
    logo = logo,
    hide_on_render = hide_on_render
  )
  session <- shiny::getDefaultReactiveDomain()
  .check_session(session)
  session$sendCustomMessage("waiter-show", opts)
}


#' @rdname waiter
#' @export
waiter_show_on_load <- function(html = spin_1(), color = "#333e48", logo = ""){

  if(logo != "")
    .Deprecated(
      package = "waiter",
      msg = "The `logo` argument is deprecated, include it in `html`"
    )
  
  html <- as.character(html)
  html <- gsub("\n", "", html)

  script <- paste0(
    "show_waiter(
      id = null,
      html = '", html, "', 
      color = '", color, "'
    );"
  )

  HTML(paste0("<script>", script, "</script>"))
}

#' @rdname waiter
#' @export
waiter_hide_on_render <- function(id){
  if(missing(id))
    stop("Missing id", call. = FALSE)
  
  script <- paste0(
    "hide_waiter('", id, "');"
  )

  singleton(
    tags$head(
      tags$script(script)
    )
  )
}

#' @rdname waiter
#' @export
waiter_on_busy <- function(html = spin_1(), color = "#333e48", logo = ""){

  html <- as.character(html)
  html <- gsub("\n", "", html)

  script <- paste0(
    "$(document).on('shiny:busy', function(event) {
      show_waiter(
        id = null,
        html = '", html, "', 
        color = '", color, "'
      );
    });
    
    $(document).on('shiny:idle', function(event) {
      hide_waiter(null);
    });"
  )

  singleton(HTML(paste0("<script>", script, "</script>")))
}

#' @rdname waiter
#' @export
waiter_hide <- function(id = NULL){
  session <- shiny::getDefaultReactiveDomain()
  .check_session(session)
  session$sendCustomMessage("waiter-hide", list(id = id))
}

#' @rdname waiter
#' @export
waiter_update <- function(id = NULL, html = NULL){
  # default to NULL clearer to the user
  if(is.null(html))
    html <- span()
  
  # wrap in a span if character string passed
  # otherwise breaks JavaScript.innerHTML
  if(is.character(html))
    html <- span(html)
  
  html <- as.character(html)
  html <- gsub("\n", "", html)
  session <- shiny::getDefaultReactiveDomain()
  .check_session(session)
  session$sendCustomMessage("waiter-update", list(html = html, id = id))
}

#' Waiter R6 Class
#' 
#' Create a waiter to then show, hide or update its content.
#' 
#' @details
#' Create an object to show a waiting screen on either the entire application
#' or just a portion of the app by specifying the \code{id}. Then \code{show},
#' then \code{hide} or meanwhile \code{update} the content of the waiter. 
#' 
#' @name waiterClass
#' @export
Waiter <- R6::R6Class(
  "waiter",
  public = list(
#' @details
#' Create a waiter.
#' 
#' @param html HTML content of waiter, generally a spinner, see \code{\link{spinners}} or a list of the latter.
#' @param color Background color of loading screen.
#' @param logo Logo to display.
#' @param id Id, or vector of ids, of element on which to overlay the waiter, if \code{NULL} the waiter is
#' applied to the entire body.
#' @param hide_on_render Set to \code{TRUE} to automatically hide the waiter
#' when the element in \code{id} is drawn. Note the latter will work with
#' shiny plots, tables, htmlwidgets, etc. but will not work with arbitrary
#' elements.
#' @param hide_on_error,hide_on_silent_error Whether to hide the waiter when the underlying element throws an error.
#' Silent error are thrown by \link[shiny]{req} and  \link[shiny]{validate}.
#' 
#' @examples
#' \dontrun{Waiter$new()}
    initialize = function(id = NULL, html = NULL, color = NULL, logo = NULL, 
      hide_on_render = !is.null(id), hide_on_error = !is.null(id),
      hide_on_silent_error = !is.null(id)){

      # get theme
      html <- .theme_or_value(html, "WAITER_HTML")
      color <- .theme_or_value(color, "WAITER_COLOR")
      logo <- .theme_or_value(logo, "WAITER_LOGO")
      
      # process inputs
      if(inherits(html, "shiny.tag.list") || inherits(html, "shiny.tag"))
        html <- list(html)
      
      if(inherits(html, "list"))
        html <- lapply(html, as.character)

      if(!is.null(id))
        if(!is.character(id))
          stop("`id` must be of class `character`", call. = FALSE)

      if(hide_on_render && is.null(id))
        stop("Cannot `hide_on_render` when `id` is not specified")

      if(length(id) > 0)
        if(length(html) != length(id))
          html <- as.list(rep(html, length(id)))

      if(is.null(id))
        id <- list(NULL)
      else
        id <- as.list(id)

      private$.id <- id
      private$.html <- html
      private$.color <- color
      private$.logo <- logo
      private$.hide_on_render <- hide_on_render
      private$.hide_on_silent_error <- hide_on_silent_error
      private$.hide_on_error <- hide_on_error
    },
#' @details
#' Show the waiter.
    show = function(){
      private$get_session()
      for(i in 1:length(private$.id)){
        opts <- list(
          id = private$.id[[i]],
          html = private$.html[[i]],
          color = private$.color,
          logo = private$.logo,
          hide_on_render = private$.hide_on_render,
          hide_on_silent_error = private$.hide_on_silent_error,
          hide_on_error = private$.hide_on_error
        )
        private$.session$sendCustomMessage("waiter-show", opts)
      }
      invisible(self)
    },
#' @details
#' Hide the waiter.
    hide = function(){
      private$get_session()
      for(i in 1:length(private$.id)){
        private$.session$sendCustomMessage("waiter-hide", list(id = private$.id[[i]]))
      }
      invisible(self)
    },
#' @details
#' Update the waiter's html content.
#' @param html HTML content of waiter, generally a spinner, see \code{\link{spinners}}.
    update = function(html = NULL){

      private$get_session()

      # force span to ensure JavaScript.innerHTML does not break
      if(is.null(html))
        html <- span()

      html <- as.character(html)
      html <- gsub("\n", "", html)
     
      for(i in 1:length(private$.id)){
        private$.session$sendCustomMessage("waiter-update", list(html = html, id = private$.id[[i]]))
      }
      invisible(self)
    },
#' @details
#' print the waiter
		print = function(){
      if(!is.null(private$.id))
		    cat("A waiter on", paste0(private$.id, collapse = ","), "\n")
      else
        cat("A waiter\n")
		}
  ),
  private = list(
    .html = list(),
    .color = "#333e48",
    .logo = "",
    .id = NULL,
    .session = NULL,
    .hide_on_render = FALSE,
    .hide_on_silent_error = FALSE,
    .hide_on_error = FALSE,
		get_session = function(){
			private$.session <- shiny::getDefaultReactiveDomain()
			.check_session(private$.session)
		}
  )
)

#' Define a Theme
#' 
#' Define a theme to be used by all waiter loading screens. 
#' These can be overriden in individual loading screens.
#' 
#' @inheritParams waiter
#' 
#' @name waiterTheme
#' @export
waiter_set_theme <- function(html = spin_1(), color = "#333e48", logo = ""){
  options(
    WAITER_HTML = html,
    WAITER_COLOR = color,
    WAITER_LOGO = logo
  )
  invisible()
}

#' @rdname waiterTheme
#' @export
waiter_get_theme <- function(){
  list(
    html = .get_html(),
    color = .get_color(),
    logo = .get_logo()
  )
}

#' @rdname waiterTheme
#' @export
waiter_unset_theme <- function(){
  options(
    WAITER_HTML = NULL,
    WAITER_COLOR = NULL,
    WAITER_LOGO = NULL
  )
  invisible()
}

#' Transparency 
#' 
#' A convenience function to create a waiter with transparent background.
#' 
#' @param alpha Alpha channel where \code{0} is completely transparent
#' and \code{1} is opaque.
#' 
#' @examples transparent()
#' 
#' @export
transparent <- function(alpha = 0){
  correct <- alpha >= 0 && alpha <= 1
  if(!correct)
    stop("`alpha` must be between 0 and 1", call. = FALSE)
  paste0("rgba(255,255,255,", alpha, ")")
}
