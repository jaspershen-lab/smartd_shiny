library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyBS)
library(shinyWidgets)
library(patchwork)
library(markdown)
# if(!require(massdataset)){
#   remotes::install_github("tidymass/massdataset")
# }
# if(!require(mapa)){
#   remotes::install_github("jaspershen/mapa")
# }
# library(mapa)

ui <- dashboardPage(
  skin = "purple",
  dashboardHeader(title = "SmartD"),
  ###sidebar of the app
  dashboardSidebar(sidebarMenu(
    id = "tabs",
    menuItem(
      "Introduction",
      tabName = "introduction",
      icon = icon("info-circle")
    ),
    menuItem(
      "Data Visualization",
      tabName = "data_visualization",
      icon = icon("chart-line")
    )
  )),
  
  ##dashboard body code
  
  dashboardBody(
    shinyjs::useShinyjs(),
    div(
      id = "loading",
      hidden = TRUE,
      class = "loading-style",
      "",
      tags$img(src = "loading.gif", height = "200px")
    ),
    tags$style(
      HTML(
        "
      .content-wrapper {
        padding-bottom: 120px;
      }
      .loading-style {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        z-index: 100;
      }
    "
      )
    ),
    
    tabItems(
      ####introduction tab
      tabItem(tabName = "introduction", fluidPage(
        titlePanel("Introduction of MAPA"), fluidRow(column(
          12, includeHTML("files/introduction.html")
        ))
      )),
      ####tutorial tab
      tabItem(tabName = "tutorial", fluidPage(
        titlePanel("Tutorials of MAPA"), fluidRow(column(12, includeHTML(
          "files/tutorials.html"
        )))
      )),
      ####upload data tab
      tabItem(tabName = "upload_data", fluidPage(
        titlePanel("Upload Data"), fluidRow(
          column(
            4,
            fileInput(
              "variable_info",
              "Choose file",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv",
                ".xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "application/vnd.ms-excel"
              )
            ),
            checkboxInput(
              inputId = "use_example",
              label = "Use example",
              value = FALSE
            ),
            radioButtons(
              "id_type",
              "ID type:",
              choices = list(
                "ENSEMBL" = "ensembl",
                "UniProt" = "uniprot",
                "EntrezID" = "entrezid"
              ),
              selected = "ensembl"
            ),
            
            actionButton("map_id", "Submit", class = "btn-primary", style = "background-color: #d83428; color: white;"),
            
            actionButton(
              inputId = "go2enrich_pathways",
              label = "Next",
              class = "btn-primary",
              style = "background-color: #d83428; color: white;"
            ),
            actionButton(
              inputId = "show_upload_data_code",
              label = "Code",
              class = "btn-primary",
              style = "background-color: #d83428; color: white;"
            ),
            style = "border-right: 1px solid #ddd; padding-right: 20px;"
          ),
          column(
            8,
            shiny::dataTableOutput("variable_info"),
            br(),
            shinyjs::useShinyjs(),
            downloadButton(
              "download_variable_info",
              "Download",
              class = "btn-primary",
              style = "background-color: #d83428; color: white;"
            )
          )
        )
      )),
      
      
      #### Data visualization tab
      tabItem(tabName = "data_visualization", fluidPage(
        titlePanel("Data Visualization"),
        tabsetPanel(
          tabPanel(title = "Barplot", fluidRow(
            column(
              4,
              br(),
              fluidRow(column(
                12,
                fileInput(
                  inputId = "upload_enriched_functional_module",
                  label = tags$span(
                    "Upload functional module",
                    shinyBS::bsButton(
                      "upload_functional_module_info",
                      label = "",
                      icon = icon("info"),
                      style = "info",
                      size = "extra-small"
                    )
                  ),
                  accept = ".rda"
                ),
                bsPopover(
                  id = "upload_functional_module_info",
                  title = "",
                  content = "You can upload the functional module file here for data visualization only.",
                  placement = "right",
                  trigger = "hover",
                  options = list(container = "body")
                )
              )),
              fluidRow(
                column(
                  4,
                  selectInput(
                    inputId = "barplot_level",
                    label = "Level",
                    choices = c(
                      "Pathway" = "pathway",
                      "Module" = "module",
                      "Functional module" = "functional_module"
                    ),
                    selected = "functional_module"
                  )
                ),
                column(
                  4,
                  numericInput(
                    inputId = "barplot_top_n",
                    label = "Top N:",
                    value = 5,
                    min = 1,
                    max = 1000
                  )
                ),
                column(4, selectInput(
                  "line_type",
                  "Line type",
                  choices = c("Straight" = "straight", "Meteor" = "meteor")
                ))
              ),
              fluidRow(
                column(
                  4,
                  numericInput(
                    "barplot_y_lable_width",
                    "Y label width",
                    value = 50,
                    min = 20,
                    max = 100
                  )
                ),
                column(
                  4,
                  numericInput(
                    "barplot_p_adjust_cutoff",
                    "P-adjust cutoff",
                    value = 0.05,
                    min = 0,
                    max = 0.5
                  ),
                ),
                column(
                  4,
                  numericInput(
                    "barplot_count_cutoff",
                    "Count cutoff:",
                    value = 5,
                    min = 1,
                    max = 1000
                  )
                )
              ),
              fluidRow(column(
                12,
                checkboxGroupInput(
                  "barplot_database",
                  "Database",
                  choices = c(
                    "GO" = "go",
                    "KEGG" = "kegg",
                    "Reactome" = "reactome"
                  ),
                  selected = c("go", "kegg", "reactome"),
                  inline = TRUE
                )
              )),
              h4("Database color"),
              fluidRow(
                column(
                  4,
                  shinyWidgets::colorPickr(
                    inputId = "barplot_go_color",
                    label = "GO",
                    selected = "#1F77B4FF",
                    theme = "monolith",
                    width = "100%"
                  )
                ),
                column(
                  4,
                  shinyWidgets::colorPickr(
                    inputId = "barplot_kegg_color",
                    label = "KEGG",
                    selected = "#FF7F0EFF",
                    theme = "monolith",
                    width = "100%"
                  )
                ),
                column(
                  4,
                  shinyWidgets::colorPickr(
                    inputId = "barplot_reactome_color",
                    label = "Reactome",
                    selected = "#2CA02CFF",
                    theme = "monolith",
                    width = "100%"
                  )
                )
              ),
              fluidRow(
                column(4, selectInput(
                  "barplot_type", "Type", choices = c("pdf", "png", "jpeg")
                )),
                column(
                  4,
                  numericInput(
                    "barplot_width",
                    "Width",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                ),
                column(
                  4,
                  numericInput(
                    "barplot_height",
                    "Height",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                )
              ),
              fluidRow(
                column(
                  12,
                  shinyjs::useShinyjs(),
                  downloadButton(
                    "download_barplot",
                    "Download",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  ),
                  actionButton(
                    "go2llm_interpretation_1",
                    "Next",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  )
                )
              ),
              style = "border-right: 1px solid #ddd; padding-right: 20px;"
            ),
            column(
              8,
              shinyWidgets::dropdownButton(
                sliderInput(
                  "barplot_width_show",
                  "Plot Width (pixels):",
                  min = 300,
                  max = 1000,
                  value = 800
                ),
                # Input: Slider for height
                sliderInput(
                  "barplot_height_show",
                  "Plot Height (pixels):",
                  min = 300,
                  max = 1000,
                  value = 600
                ),
                circle = TRUE,
                status = "danger",
                icon = icon("gear"),
                width = "200px"
              ),
              shiny::plotOutput("barplot", width = "auto", height = "auto"),
              br(),
              actionButton(
                "generate_barplot",
                "Generate plot",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              ),
              
              actionButton(
                "refresh_barplot",
                "Refresh",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              ),
              
              actionButton(
                "show_barplot_code",
                "Code",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              )
            )
          )),
          tabPanel(title = "Module Similarity Network", fluidRow(
            column(
              4,
              br(),
              fluidRow(column(
                6,
                selectInput(
                  "module_similarity_network_database",
                  "Database:",
                  choices = c(
                    "GO" = "go",
                    "KEGG" = "kegg",
                    "Reactome" = "reactome"
                  ),
                  selected = "go"
                )
              ), column(
                6,
                numericInput(
                  "module_similarity_network_degree_cutoff",
                  "Degree cutoff:",
                  value = 0,
                  min = 0,
                  max = 1000
                )
              )),
              fluidRow(
                column(
                  6,
                  selectInput(
                    "module_similarity_network_level",
                    "Level:",
                    choices = c("Module" = "module", "Functional module" = "functional_module"),
                    selected = "functional_module"
                  )
                ),
                column(
                  3,
                  checkboxInput("module_similarity_network_text", "Text", FALSE)
                ),
                column(
                  3,
                  checkboxInput("module_similarity_network_text_all", "Text all", FALSE)
                )
              ),
              fluidRow(
                column(
                  4,
                  selectInput(
                    "module_similarity_network_type",
                    "Type",
                    choices = c("pdf", "png", "jpeg")
                  )
                ),
                column(
                  4,
                  numericInput(
                    "module_similarity_network_width",
                    "Width",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                ),
                column(
                  4,
                  numericInput(
                    "module_similarity_network_height",
                    "Height",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                )
              ),
              fluidRow(
                column(
                  12,
                  shinyjs::useShinyjs(),
                  downloadButton(
                    "download_module_similarity_network",
                    "Download",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  ),
                  actionButton(
                    "go2llm_interpretation_2",
                    "Next",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  )
                )
              ),
              style = "border-right: 1px solid #ddd; padding-right: 20px;"
            ),
            column(
              8,
              shiny::plotOutput("module_similarity_network"),
              br(),
              actionButton(
                "generate_module_similarity_network",
                "Generate plot",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              ),
              actionButton(
                "show_module_similarity_network_code",
                "Code",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              )
            )
          )),
          tabPanel(title = "Module Information", fluidRow(
            column(
              4,
              br(),
              fluidRow(column(
                6,
                selectInput(
                  "module_information_level",
                  "Level:",
                  choices = c("Module" = "module", "Functional module" = "functional_module"),
                  selected = "functional_module"
                )
              ), column(
                6,
                selectInput(
                  "module_information_database",
                  "Database:",
                  choices = c(
                    "GO" = "go",
                    "KEGG" = "kegg",
                    "Reactome" = "reactome"
                  ),
                  selected = "go"
                )
              )),
              fluidRow(column(
                12,
                selectInput("module_information_module_id", "Module ID:", choices = NULL)
              )),
              fluidRow(
                column(4, selectInput(
                  "module_information_type",
                  "Type",
                  choices = c("pdf", "png", "jpeg")
                )),
                column(
                  4,
                  numericInput(
                    "module_information_width",
                    "Width",
                    value = 21,
                    min = 4,
                    max = 30
                  )
                ),
                column(
                  4,
                  numericInput(
                    "module_information_height",
                    "Height",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                )
              ),
              fluidRow(
                column(
                  12,
                  shinyjs::useShinyjs(),
                  downloadButton(
                    "download_module_information",
                    "Download",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  ),
                  actionButton(
                    "go2llm_interpretation_3",
                    "Next",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  )
                )
              ),
              style = "border-right: 1px solid #ddd; padding-right: 20px;"
            ),
            column(
              8,
              shiny::plotOutput("module_information"),
              br(),
              actionButton(
                "generate_module_information",
                "Generate plot",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              ),
              actionButton(
                "show_module_information_code",
                "Code",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              )
            )
          )),
          tabPanel(title = "Relationship network", fluidRow(
            column(
              4,
              br(),
              fluidRow(column(
                6,
                checkboxInput(
                  "relationship_network_circular_plot",
                  "Circular layout",
                  FALSE
                )
              ), column(
                6,
                checkboxInput("relationship_network_filter", "Filter", FALSE)
              )),
              fluidRow(column(
                6,
                selectInput(
                  "relationship_network_level",
                  "Filter Level:",
                  choices = c("Module" = "module", "Functional module" = "functional_module"),
                  selected = "functional_module"
                )
              ), column(
                6,
                selectInput(
                  "relationship_network_module_id",
                  "Module ID:",
                  choices = NULL,
                  multiple = TRUE
                )
              )),
              h4("Includes"),
              fluidRow(
                column(
                  3,
                  checkboxInput(
                    "relationship_network_include_functional_modules",
                    label = tags$span(
                      "FM",
                      shinyBS::bsButton(
                        "functional_module_info",
                        label = "",
                        icon = icon("info"),
                        style = "info",
                        size = "extra-small"
                      )
                    ),
                    TRUE
                  )
                ),
                bsPopover(
                  id = "functional_module_info",
                  title = "",
                  content = "FM is functional module",
                  placement = "right",
                  trigger = "hover",
                  options = list(container = "body")
                ),
                column(
                  3,
                  checkboxInput("relationship_network_include_modules", "Modules", TRUE)
                ),
                column(
                  3,
                  checkboxInput("relationship_network_include_pathways", "Pathways", TRUE)
                ),
                column(
                  3,
                  checkboxInput("relationship_network_include_molecules", "Molecules", TRUE)
                )
              ),
              h4("Colors"),
              fluidRow(
                column(
                  3,
                  shinyWidgets::colorPickr(
                    inputId = "relationship_network_functional_module_color",
                    label = "FM",
                    selected = "#F05C3BFF",
                    theme = "monolith",
                    width = "100%"
                  )
                ),
                column(
                  3,
                  shinyWidgets::colorPickr(
                    inputId = "relationship_network_module_color",
                    label = "Module",
                    selected = "#46732EFF",
                    theme = "monolith",
                    width = "100%"
                  )
                ),
                column(
                  3,
                  shinyWidgets::colorPickr(
                    inputId = "relationship_network_pathway_color",
                    label = "Pathway",
                    selected = "#197EC0FF",
                    theme = "monolith",
                    width = "100%"
                  )
                ),
                column(
                  3,
                  shinyWidgets::colorPickr(
                    inputId = "relationship_network_molecule_color",
                    label = "Molecule",
                    selected = "#3B4992FF",
                    theme = "monolith",
                    width = "100%"
                  )
                )
              ),
              h4("Text"),
              fluidRow(
                column(
                  3,
                  checkboxInput("relationship_network_functional_module_text", "FM", TRUE)
                ),
                column(
                  3,
                  checkboxInput("relationship_network_module_text", "Module", TRUE)
                ),
                column(
                  3,
                  checkboxInput("relationship_network_pathway_text", "Pathway", TRUE)
                ),
                column(
                  3,
                  checkboxInput("relationship_network_molecule_text", "Molecules", FALSE)
                )
              ),
              h4("Text size"),
              fluidRow(
                column(
                  3,
                  numericInput(
                    "relationship_network_functional_module_text_size",
                    "FM",
                    value = 3,
                    min = 0.3,
                    max = 10
                  )
                ),
                column(
                  3,
                  numericInput(
                    "relationship_network_module_text_size",
                    "Module",
                    value = 3,
                    min = 0.3,
                    max = 10
                  )
                ),
                column(
                  3,
                  numericInput(
                    "relationship_network_pathway_text_size",
                    "Pathway",
                    value = 3,
                    min = 0.3,
                    max = 10
                  )
                ),
                column(
                  3,
                  numericInput(
                    "relationship_network_molecule_text_size",
                    "Molecule",
                    value = 3,
                    min = 0.3,
                    max = 10
                  )
                )
              ),
              h4("Arrange posision"),
              fluidRow(
                column(
                  3,
                  checkboxInput(
                    "relationship_network_functional_module_arrange_position",
                    "FM",
                    TRUE
                  )
                ),
                column(
                  3,
                  checkboxInput(
                    "relationship_network_module_arrange_position",
                    "Module",
                    TRUE
                  )
                ),
                column(
                  3,
                  checkboxInput(
                    "relationship_network_pathway_arrange_position",
                    "Pathway",
                    TRUE
                  )
                ),
                column(
                  3,
                  checkboxInput(
                    "relationship_network_molecule_arrange_position",
                    "Molecules",
                    FALSE
                  )
                )
              ),
              h4("Posision limits"),
              fluidRow(column(
                6,
                sliderInput(
                  "relationship_network_functional_module_position_limits",
                  "Functional module",
                  min = 0,
                  max = 1,
                  value = c(0, 1)
                )
              ), column(
                6,
                sliderInput(
                  "relationship_network_module_position_limits",
                  "Module",
                  min = 0,
                  max = 1,
                  value = c(0, 1)
                )
              )),
              fluidRow(column(
                6,
                sliderInput(
                  "relationship_network_pathway_position_limits",
                  "Pathway",
                  min = 0,
                  max = 1,
                  value = c(0, 1)
                )
              ), column(
                6,
                sliderInput(
                  "relationship_network_molecule_position_limits",
                  "Molecule",
                  min = 0,
                  max = 1,
                  value = c(0, 1)
                )
              )),
              fluidRow(
                column(
                  4,
                  selectInput(
                    "relationship_network_type",
                    "Type",
                    choices = c("pdf", "png", "jpeg")
                  )
                ),
                column(
                  4,
                  numericInput(
                    "relationship_network_width",
                    "Width",
                    value = 21,
                    min = 4,
                    max = 30
                  )
                ),
                column(
                  4,
                  numericInput(
                    "relationship_network_height",
                    "Height",
                    value = 7,
                    min = 4,
                    max = 20
                  )
                )
              ),
              fluidRow(
                column(
                  12,
                  shinyjs::useShinyjs(),
                  downloadButton(
                    "download_relationship_network",
                    "Download",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  ),
                  actionButton(
                    "go2llm_interpretation_4",
                    "Next",
                    class = "btn-primary",
                    style = "background-color: #d83428; color: white;"
                  )
                )
              ),
              style = "border-right: 1px solid #ddd; padding-right: 20px;"
            ),
            column(
              8,
              shiny::plotOutput("relationship_network"),
              br(),
              actionButton(
                "generate_relationship_network",
                "Generate plot",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              ),
              actionButton(
                "show_relationship_network_code",
                "Code",
                class = "btn-primary",
                style = "background-color: #d83428; color: white;"
              )
            )
          ))
        )
      ))
    ),
    tags$footer(
      div(
        style = "background-color: #ecf0f4; display: flex; align-items: center; justify-content: left; padding: 10px; height: 80px; position: fixed; bottom: 0; width: 100%; z-index: 100; border-top: 1px solid #ccc;",
        tags$img(
          src = "ntu_logo.png",
          height = "80px",
          style = "margin-right: 15px;"
        ),
        # Add vertical line
        div(
          style = "border-left: 1px solid #ccc; height: 50px; margin-right: 15px;"
        ),
        tags$img(
          src = "SUSig_Red_Stree_Stacked_Left.png",
          height = "80px",
          style = "margin-right: 15px;"
        ),
        # Add vertical line
        div(
          style = "border-left: 1px solid #ccc; height: 50px; margin-right: 15px;"
        ),
        tags$img(
          src = "ucsf_logo.png",
          height = "50px",
          style = "margin-right: 15px;"
        ),
        # Add vertical line
        div(
          style = "border-left: 1px solid #ccc; height: 50px; margin-right: 15px;"
        ),
        div(
          # HTML("The Shen Lab at Nanyang Technological University Singapore"),
          # HTML("<br>"),
          tags$a(
            href = "http://www.shen-lab.org",
            target = "_blank",
            tags$i(class = "fa fa-house", style = "color: purple;"),
            " Shen Lab",
            style = "text-align: left; margin-left: 10px;"
          ),
          tags$a(
            href = "https://www.shen-lab.org/#contact",
            target = "_blank",
            tags$i(class = "fa fa-envelope", style = "color: purple;"),
            " Email",
            style = "text-align: left; margin-left: 10px;"
          ),
          tags$a(
            href = "https://github.com/jaspershen/mapa",
            target = "_blank",
            tags$i(class = "fa fa-github", style = "color: purple;"),
            " GitHub",
            style = "text-align: left; margin-left: 10px;"
          ),
          style = "text-align: left;"
        )
      )
    )
  )
)
