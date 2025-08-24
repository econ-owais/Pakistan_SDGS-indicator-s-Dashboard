# app.R
# ==============================================================================
# SDG Insights: Pakistan's Sustainable Development Journey
# Developed by: Owais Ali Shah
# Description: This R Shiny app provides an interactive dashboard to explore
#              Sustainable Development Goals (SDG) data for Pakistan and other
#              countries. It features an overview, trend analysis for specific
#              goals, country comparisons, and a raw data explorer.
# ==============================================================================

# ======================
# 1. Load Required Libraries
# ======================
library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr) # For pivot_longer
library(readr) # For read_csv
library(highcharter) # For interactive charts
library(DT) # For interactive tables
library(waiter) # For loading screens
library(shinycssloaders) # For loading spinners
library(shinyWidgets) # For switchInput
library(stringr) # For string manipulation
library(shinyjs) # Added for consistency with the macro app

# ======================
# 2. Global Data & Translation Setup
# ======================

# --- Translation Dictionary ---
translations <- list(
  en = list(
    dashboard_title = "SDG Insights: Pakistan's Sustainable Development Journey",
    dashboard_author = "by Owais Ali Shah",
    visit_full_dashboard = "Visit Full Dashboard",
    overview_details = "Overview & Details",
    trends = "Trend Analysis", # New key for Trend Analysis tab
    explorer = "Data Explorer",
    about = "About", # New key for About section title
    select_indicator = "Select SDG Indicator:", # Renamed for clarity with SDG data
    select_countries = "Select Countries:",
    select_year_range = "Select Year Range:",
    latest_data = "Latest Data",
    total_indicators = "Total Indicators",
    time_period_covered = "Time Period Covered",
    total_data_points = "Total Data Points",
    pakistan_progress = "Pakistan's Progress (Avg. Value)", # Adapted for SDG context
    key_insights_pakistan = "Key Insights: Pakistan's SDG Progress",
    pakistan_overview_text_1 = "This section provides a high-level overview of Pakistan's performance across various Sustainable Development Goals. Analyzing key indicators helps us understand the nation's journey towards sustainable development.",
    pakistan_overview_text_2 = "Utilize the interactive charts and tables within the app to delve deeper into specific goals and compare Pakistan's progress with other countries.",
    sdg_goal_overview = "SDG Goal Overview: {goal_name}", # Retained but unused in simplified UI
    trend_analysis_for = "Trend Analysis for {indicator}",
    comparison_of_indicator = "Comparison of '{indicator}' Across Countries", # Retained but unused in simplified UI
    raw_data_explorer = "Raw Data Explorer",
    no_data_available = "No data available for the selected criteria.",
    series_name = "Series Name",
    country_name = "Country Name",
    year = "Year",
    value = "Value",
    unit = "Unit",
    description = "Description",
    context = "Context",
    trend_options = "Trend Analysis Options", # From macro app
    statistical_summary = "Statistical Summary", # From macro app
    about_project_details = "This dashboard provides a comprehensive view of Pakistan's key Sustainable Development Goal (SDG) indicators, enabling analysis of vital trends over time. It's designed to facilitate data-driven policy decisions and research related to sustainable development.", # Adapted from macro app
    about_author_details = "This dashboard is a data visualization project by Owais Ali Shah, an economics graduate and a data analyst with a passion for using data to understand and solve real-world problems. This dashboard is a reflection of that commitment.", # From macro app
    footer_text = "&copy; 2025 Owais Ali Shah - All rights reserved. Built with ❤️ for data-driven insights.",
    quick_insights = "Quick Insights (Cooking Fuels Access)", # Added
    download_data = "Download Data" # Added
  ),
  ur = list(
    dashboard_title = "ایس ڈی جی بصیرت: پاکستان کا پائیدار ترقیاتی سفر",
    dashboard_author = "اویس علی شاہ کی طرف سے",
    visit_full_dashboard = "مکمل ڈیش بورڈ ملاحظہ کریں",
    overview_details = "جائزہ اور تفصیلات",
    trends = "رجحان کا تجزیہ",
    explorer = "ڈیٹا ایکسپلورر",
    about = "کے بارے میں",
    select_indicator = "ایس ڈی جی اشارہ منتخب کریں:",
    select_countries = "ممالک منتخب کریں:",
    select_year_range = "سال کی حد منتخب کریں:",
    latest_data = "تازہ ترین ڈیٹا",
    total_indicators = "کل اشارے",
    time_period_covered = "احاطہ شدہ مدت",
    total_data_points = "کل ڈیٹا پوائنٹس",
    pakistan_progress = "پاکستان کی ترقی (اوسط قدر)",
    key_insights_pakistan = "اہم بصیرت: پاکستان کی ایس ڈی جی ترقی",
    pakistan_overview_text_1 = "یہ سیکشن پاکستان کی پائیدار ترقیاتی اہداف کے مختلف شعبوں میں کارکردگی کا اعلیٰ سطحی جائزہ فراہم کرتا ہے۔ اہم اشاروں کا تجزیہ ہمیں ملک کے پائیدار ترقی کی طرف سفر کو سمجھنے میں مدد کرتا ہے۔",
    pakistan_overview_text_2 = "مخصوص اہداف کا گہرا مطالعہ کرنے اور پاکستان کی ترقی کا دوسرے ممالک سے موازنہ کرنے کے لیے ایپ میں موجود انٹرایکٹو چارٹس اور ٹیبلز کا استعمال کریں۔",
    sdg_goal_overview = "ایس ڈی جی مقصد کا جائزہ: {goal_name}",
    trend_analysis_for = "{indicator} کے لیے رجحان کا تجزیہ",
    comparison_of_indicator = "'{indicator}' کا ممالک کے درمیان موازنہ",
    raw_data_explorer = "خام ڈیٹا ایکسپلورر",
    no_data_available = "منتخب کردہ معیار کے لیے کوئی ڈیٹا دستیاب نہیں ہے۔",
    series_name = "سیریز کا نام",
    country_name = "ملک کا نام",
    year = "سال",
    value = "قدر",
    unit = "یونٹ",
    description = "تفصیل",
    context = "سیاق و سباق",
    trend_options = "رجحان کے تجزیہ کے اختیارات",
    statistical_summary = "اعداد و شمار کا خلاصہ",
    about_project_details = "یہ ڈیش بورڈ پاکستان کے اہم پائیدار ترقیاتی اہداف (ایس ڈی جی) کے اشاروں کا ایک جامع نظریہ فراہم کرتا ہے، جو وقت کے ساتھ اہم رجحانات کا تجزیہ کرنے کے قابل بناتا ہے۔ یہ ڈیٹا پر مبنی پالیسی فیصلوں اور پائیدار ترقی سے متعلق تحقیق کو آسان بنانے کے لیے ڈیزائن کیا گیا ہے۔",
    about_author_details = "یہ ڈیش بورڈ اویس علی شاہ کا ایک ڈیٹا ویژولائزیشن پراجیکٹ ہے، جو ایک اقتصادیات کا گریجویٹ اور ڈیٹا تجزیہ کار ہے اور حقیقی دنیا کے مسائل کو سمجھنے اور حل کرنے کے لیے ڈیٹا کا استعمال کرنے کا جذبہ رکھتا ہے۔ یہ ڈیش بورڈ اسی عزم کا عکاس ہے۔",
    footer_text = "&copy; 2025 اویس علی شاہ - تمام حقوق محفوظ ہیں۔ ڈیٹا پر مبنی بصیرت کے لیے ❤️ سے بنایا گیا ہے۔",
    quick_insights = "فوری بصیرت (کھانا پکانے کے ایندھن تک رسائی)", # Added
    download_data = "ڈیٹا ڈاؤن لوڈ کریں" # Added
  )
)

# --- Data Loading and Initial Pre-processing ---
sdg_data_raw <- read_csv("sdg-data.csv")

sdg_data_long <- sdg_data_raw %>%
  select(`Country Name`, `Series Name`, `Series Code`, starts_with("20")) %>%
  pivot_longer(
    cols = starts_with("20"),
    names_to = "Year_Raw",
    values_to = "Value_Char" # Store as character first
  ) %>%
  mutate(
    Year = as.numeric(str_extract(Year_Raw, "^\\d{4}")),
    Value = as.numeric(Value_Char) # Explicitly convert to numeric
  ) %>%
  select(-Year_Raw, -Value_Char) %>% # Remove raw and character value columns
  filter(!is.na(Value)) %>% # Filter out NA numeric values
  arrange(`Country Name`, `Series Name`, Year)

# Get unique values for filters
available_countries <- sort(unique(sdg_data_long$`Country Name`))
available_series <- sort(unique(sdg_data_long$`Series Name`)) # Used as 'Indicator'
min_year <- min(sdg_data_long$Year, na.rm = TRUE)
max_year <- max(sdg_data_long$Year, na.rm = TRUE)


# ======================
# 3. Custom CSS for "Vibrant Purples & Golds" Theme
# ======================
custom_css <- "
/* Main styling */
body {
  font-family: 'Inter', sans-serif;
  background-color: #f3e5f5; /* Light Lavender */
  color: #4a148c; /* Dark Purple */
}

/* Header styling with vibrant gradient */
.skin-blue .main-header .navbar {
  background: linear-gradient(135deg, #673ab7 0%, #512da8 100%) !important; /* Deep Purple gradient */
}

/* Ensure the default logo area is minimized/hidden, but the toggle button remains */
.skin-blue .main-header .logo {
  width: auto !important; /* Allow width to shrink */
  padding: 0 15px !important; /* Adjust padding as needed */
  background-color: transparent !important;
  color: transparent !important; /* Hide default text */
  border-bottom: none !important; /* Remove border */
  display: flex;
  align-items: center;
  justify-content: center;
}
.skin-blue .main-header .logo .logo-lg,
.skin-blue .main-header .logo .logo-mini {
  display: none !important; /* Hide logo text entirely */
}


/* Custom Right Header Content Container */
.main-header .custom-right-header-content {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-end; /* Push content to the right */
  width: 100%; /* Take full width of the navbar */
  padding-right: 15px; /* Spacing from right edge */
  z-index: 1000;
  float: right; /* Ensure it floats right */
}

/* Header Title Block (for Project Name and Author) */
.main-header .header-title-block {
  display: flex;
  flex-direction: column;
  align-items: flex-end; /* Align text right within its block */
  margin-right: 20px; /* Space between title and language toggle */
  color: white; /* Ensure text is white */
}

.main-header .header-title-block h4 {
  color: white;
  margin: 0;
  padding: 0;
  font-weight: 800;
  font-size: 1.8rem; /* Larger project title */
  text-align: right; /* Explicitly align text right */
}
.main-header .header-title-block h6 {
  color: #ffeb3b; /* Bright Yellow/Gold for author name */
  margin: 0;
  padding: 0;
  font-weight: 600;
  font-size: 1.2rem; /* Larger author name */
  text-align: right; /* Explicitly align text right */
}

/* Language Toggle Container in Header */
.main-header .language-toggle-container {
  display: flex;
  align-items: center;
}
.main-header .language-toggle-container span {
  color: white;
  font-weight: bold;
}


/* Sidebar Styling */
.skin-blue .main-sidebar {
  background-color: #512da8 !important; /* Medium Purple */
}

.skin-blue .sidebar-menu > li > a {
  border-left: 3px solid transparent;
  color: #e1bee7; /* Light Purple for sidebar text */
}

.skin-blue .sidebar-menu > li.active > a,
.skin-blue .sidebar-menu > li > a:hover {
  border-left-color: #ffc107; /* Amber accent */
  background-color: #673ab7 !important; /* Deep Purple */
  color: #fff;
}
.skin-blue .sidebar-menu .treeview-menu > li > a {
  color: #E0E0E0; /* Lighter grey for sub-items */
}
.skin-blue .sidebar-menu .treeview-menu > li.active > a,
.skin-blue .sidebar-menu .treeview-menu > li > a:hover {
  background-color: #673ab7 !important;
  color: #ffc107; /* Amber for active sub-items */
}

/* Enhanced boxes with subtle shadows */
.box {
  border-top: 3px solid #ffc107; /* Amber top border */
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08) !important;
  transition: transform 0.2s, box-shadow 0.2s;
  margin-bottom: 20px; /* Standard spacing for boxes */
  padding: 20px; /* Standard internal padding */
}

.box:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.12) !important;
}

.box-header {
  border-bottom: 1px solid #e0e0e0;
  padding: 15px;
  font-weight: 600;
  color: #4a148c; /* Dark Purple for headers */
  font-size: 1.25rem; /* Standard box header titles */
}
.box-title {
    color: #4a148c; /* Darker title for readability */
}

/* Professional value boxes */
.small-box {
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
  background-color: #fff; /* White background for all boxes */
  color: #4a148c; /* Dark Purple text for all boxes */
}

.small-box:hover {
  transform: translateY(-3px);
}

.small-box h3 {
  font-size: 24px;
  font-weight: 700;
  color: #4a148c; /* Dark Purple */
}

.small-box p {
  font-size: 14px; /* Standard subtitle size */
}

.small-box .icon {
  font-size: 70px;
  top: -10px;
  color: rgba(74, 20, 140, 0.2); /* Semi-transparent dark purple */
}

/* Specific colors for value box backgrounds (matching shinydashboard statuses) */
.small-box.bg-purple { background-color: #673ab7 !important; color: white !important; } /* Deep Purple */
.small-box.bg-light-blue { background-color: #03a9f4 !important; color: white !important; } /* Light Blue */
.small-box.bg-maroon { background-color: #d81b60 !important; color: white !important; } /* Maroon */
.small-box.bg-orange { background-color: #ff9800 !important; color: white !important; } /* Orange */
.small-box.bg-yellow { background-color: #ffc107 !important; color: #4a148c !important; } /* Amber */
.small-box.bg-aqua { background-color: #00bcd4 !important; color: white !important; } /* Cyan */
.small-box.bg-green { background-color: #4caf50 !important; color: white !important; } /* Green */


/* Enhanced buttons */
.btn {
  border-radius: 4px;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-primary {
  background-color: #ffc107; /* Amber */
  border-color: #ffc107;
  color: #4a148c; /* Dark Purple */
}

.btn-primary:hover,
.btn-primary:focus {
  background-color: #ffb300; /* Slightly darker amber */
  border-color: #ffb300;
  color: #4a148c;
}

/* Switch styling for language toggle */
.form-switch .form-check-input {
  width: 2.5em;
  height: 1.25em;
  background-color: #ccc;
  border-radius: 1.25em;
  transition: all 0.2s ease-in-out;
  cursor: pointer;
}

.form-switch .form-check-input:checked {
  background-color: #ffc107; /* Amber when checked */
}

/* DT table styling */
.dataTables_wrapper .dataTables_filter input {
  border-radius: 4px;
  border: 1px solid #ccc;
  padding: 6px 12px;
}

/* Custom spinners */
.waiter-overlay-content .fa-spinner {
  font-size: 3em;
  color: #fff;
}

/* Footer styling */
.main-footer {
  background-color: #512da8; /* Medium Purple */
  color: #e1bee7; /* Light Purple */
  padding: 15px;
  text-align: center;
  border-top: 4px solid #ffc107; /* Amber top border */
}

/* --- Responsive & Header Positioning Adjustments (from Macro App) --- */

/* Revert navbar to default shinydashboard flex behavior or rely on floats */
.main-header .navbar {
  display: flex; /* Use flexbox for navbar content */
  justify-content: space-between; /* Space out left and right content */
  position: relative;
  height: 100%;
  padding: 0;
  background: linear-gradient(135deg, #673ab7 0%, #512da8 100%) !important; /* Keep gradient */
}

/* Ensure the sidebar toggle is on the left of the navbar */
.main-header .navbar > .sidebar-toggle {
  float: none; /* Remove float */
  display: flex; /* Use flex to center icon */
  align-items: center;
  padding: 0 15px; /* Add padding for clickable area */
  height: 100%;
}

/* For wide screens (desktop) */
@media (min-width: 768px) {
  /* Force sidebar to be always open */
  body:not(.sidebar-collapse) .main-sidebar, /* If not collapsed (normal state) */
  body.sidebar-collapse .main-sidebar /* If somehow collapsed (override) */
  {
    transform: translate(0, 0) !important; /* Keep it open */
    width: 250px !important; /* Set its width (matching SDG app's current width) */
    left: 0 !important; /* Ensure it's visible */
  }

  /* Adjust content area for the open sidebar */
  .content-wrapper,
  .main-footer,
  .main-header .navbar {
    margin-left: 250px !important;
  }

  /* Hide the sidebar toggle button on desktop when sidebar is open */
  .main-header .navbar > .sidebar-toggle {
    display: none !important;
  }

  /* Adjust the logo title (project name/author) width for desktop to avoid overlap with language toggle */
  .skin-blue .main-header .logo {
    width: auto !important; /* Allow width to shrink */
    max-width: none !important; /* Override any max-width */
    overflow: hidden; /* Hide overflow if text is too long */
    text-overflow: ellipsis; /* Add ellipsis */
  }
}

/* For small screens (mobile) */
@media (max-width: 767px) {
  /* Ensure toggle button is visible on mobile */
  .main-header .navbar > .sidebar-toggle {
    display: flex !important; /* Re-enable default display for mobile */
    float: none; /* Remove float */
  }
  /* Re-enable the collapse behavior on mobile */
  body.sidebar-mini.sidebar-collapse .main-sidebar {
    transform: translate(-100%, 0) !important; /* Collapse it off-screen */
  }
  /* Adjust the logo text size on mobile for better fit */
  .skin-blue .main-header .header-title-block h4 {
    font-size: 1.2rem; /* Smaller title on mobile */
    white-space: normal; /* Allow wrapping on mobile */
    text-overflow: clip; /* No ellipsis when wrapping */
  }
  .skin-blue .main-header .header-title-block h6 {
    font-size: 0.8rem; /* Smaller author name on mobile */
    white-space: normal;
    text-overflow: clip;
  }
  /* Adjust language toggle container for mobile responsiveness */
  .main-header .custom-right-header-content {
    padding-right: 5px; /* Less padding on mobile */
  }
}

/* Reset the body's sidebar-collapse margin to fix initial rendering issues */
.content-wrapper, .right-side, .main-footer {
    transition: margin-left .3s ease-in-out;
    margin-left: 0; /* Reset default to allow our media queries to control */
}
.sidebar-mini.sidebar-collapse .content-wrapper,
.sidebar-mini.sidebar-collapse .right-side,
.sidebar-mini.sidebar-collapse .main-footer {
  margin-left: 0 !important; /* Explicitly reset when collapsed, handled by JS normally */
}

/* Ensure initial sidebar state */
body:not(.sidebar-collapse) .main-sidebar {
    left: 0 !important;
}

body.sidebar-collapse .main-sidebar {
    left: -230px !important; /* Default collapsed state */
}

/* Override the default shinydashboard behavior that adds sidebar-collapse class on page load */
body.sidebar-mini {
  /* This prevents the body from starting with sidebar-collapse on desktop */
  /* This is a common point of conflict with shinyapps.io's iframe behavior */
}
"

# ======================
# 4. User Interface (UI) Definition
# ======================
ui <- dashboardPage(
  skin = "blue", # Uses the 'blue' skin for our custom purple/gold theme
  dashboardHeader(
    title = "", # Empty title, as custom title is now on the right
    titleWidth = 0, # Minimize left header area
    tags$li(
      class = "dropdown custom-right-header-content", # New class for all right-aligned header content
      # Project and Author name (moved to the right)
      div(
        class = "header-title-block",
        h4(textOutput("app_title")),
        h6(textOutput("app_author"))
      ),
      # Language Toggle (kept on the right, removed "Visit Full Dashboard" button)
      div(
        style = "display: flex; align-items: center; margin-left: 20px;", # Added margin-left for spacing
        span(style = "color:white; font-weight: bold;", "EN"),
        switchInput(
          inputId = "lang_toggle",
          value = FALSE,
          size = "mini",
          onStatus = "warning", # Maps to Amber/Gold in new theme
          offStatus = "default" # Maps to Neutral Gray
        ),
        span(style = "color:white; font-weight: bold;", "UR")
      )
    )
  ),
  dashboardSidebar(
    width = 250, # Match titleWidth for consistency
    sidebarMenu(
      id = "tabs",
      # Reordered tabs: Trend Analysis first, then Overview, then Explorer
      menuItem(textOutput("trends"), tabName = "trends", icon = icon("chart-line")),
      menuItem(textOutput("overview_details"), tabName = "overview_details", icon = icon("tachometer-alt")),
      menuItem(textOutput("explorer"), tabName = "explorer", icon = icon("table"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"),
      tags$style(HTML(custom_css))
    ),
    use_waiter(),
    useShinyjs(),
    
    tabItems(
      # Reordered tabs to match sidebar: Trend Analysis first
      # --- Trend Analysis Tab ---
      tabItem(
        tabName = "trends",
        fluidRow(
          box(
            title = textOutput("trend_options"), # From macro app
            status = "warning", # Maps to Amber top border
            solidHeader = TRUE,
            width = 12,
            column(
              width = 6, # Simplified: removed element_select for SDG data
              selectInput("sdg_indicator_select", textOutput("select_indicator"), # Renamed ID
                          choices = available_series,
                          selected = "Access to electricity (% of population)") # Default SDG indicator
            ),
            column(
              width = 6,
              sliderInput("sdg_year_range", textOutput("select_year_range"), # Renamed ID
                          min = min_year, max = max_year,
                          value = c(min_year, max_year), sep = "")
            ),
            column(
              width = 12, # Full width for chart type buttons
              radioButtons("trend_chart_type", "Select Chart Type:", # Renamed ID
                           choices = c("Line" = "line", "Area" = "area", "Bar" = "column"),
                           selected = "line", inline = TRUE)
            )
          )
        ),
        fluidRow(
          box(
            title = textOutput("trend_analysis_chart_title"), # Reactive title for chart
            status = "primary", # Maps to Deep Purple top border
            solidHeader = TRUE,
            width = 8,
            highchartOutput("sdgTrendChart", height = "400px") %>% withSpinner(color = "#ffc107") # Renamed ID, Amber spinner
          ),
          box(
            title = textOutput("statistical_summary"), # From macro app
            status = "info", # Maps to Light Blue top border
            solidHeader = TRUE,
            width = 4,
            verbatimTextOutput("sdg_trend_summary") # Renamed ID
          )
        )
      ),
      # --- Overview & Details Tab ---
      tabItem(
        tabName = "overview_details",
        fluidRow(
          valueBoxOutput("totalIndicatorsBox", width = 3),
          valueBoxOutput("timePeriodBox", width = 3),
          valueBoxOutput("totalDataPointsBox", width = 3),
          valueBoxOutput("pakistanProgressBox", width = 3)
        ),
        fluidRow(
          box(
            title = textOutput("key_insights_pakistan"),
            status = "primary", # Maps to Deep Purple top border
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            fluidRow(
              column(
                width = 7, # Adjusted width
                highchartOutput("overviewChart", height = "400px") %>% withSpinner(color = "#ffc107") # Amber spinner
              ),
              column(
                width = 5, # Adjusted width
                h4(textOutput("quick_insights")), # From macro app
                htmlOutput("insights_text", class = "insights-box"), # From macro app
                br(),
                downloadButton("download_overview_data", textOutput("download_data"), class = "btn-primary") # From macro app
              )
            )
          )
        ),
        fluidRow(
          box(
            title = textOutput("latest_data"), # From macro app
            status = "info", # Maps to Light Blue top border
            solidHeader = TRUE,
            width = 12,
            DTOutput("latestDataTable") %>% withSpinner(color = "#ffc107") # From macro app
          )
        ),
        fluidRow(
          box(
            title = textOutput("about"), # From macro app (Using 'about' key now)
            status = "primary", # Maps to Deep Purple top border
            solidHeader = TRUE,
            width = 12,
            h4(strong("Project Details")),
            HTML(paste0("<h4>", textOutput("about_project_details"), "</h4>")),
            br(),
            h4(strong("About the Author")),
            HTML(paste0("<h4>", textOutput("about_author_details"), "</h4>"))
          )
        )
      ),
      
      # --- Data Explorer Tab ---
      tabItem(
        tabName = "explorer",
        fluidRow(
          box(
            title = textOutput("raw_data_explorer"), # From macro app
            status = "primary", # Maps to Deep Purple top border
            solidHeader = TRUE,
            width = 12,
            DTOutput("sdgDataTable") %>% withSpinner(color = "#ffc107") # Amber spinner
          )
        )
      )
    ),
    # --- Footer moved inside dashboardBody ---
    tags$footer(
      class = "main-footer", # Apply custom CSS for footer
      textOutput("footer_text_ui")
    )
  )
)

# ======================
# 5. Server Logic
# ======================
server <- function(input, output, session) {
  
  # Reactive value for current language (default: English)
  current_language <- reactiveVal("en")
  
  # --- Hide initial global loading screen after server starts ---
  observeEvent(session, {
    req(sdg_data_long)
  }, once = TRUE) # Important: run only once
  
  # --- Language Toggle Observation ---
  observeEvent(input$lang_toggle, {
    if (input$lang_toggle) { # If switch is ON (TRUE), set to Urdu
      current_language("ur")
      showNotification("زبان اردو میں تبدیل ہو گئی", type = "message", duration = 3)
    } else { # If switch is OFF (FALSE), set to English
      current_language("en")
      showNotification("Language switched to English", type = "message", duration = 3)
    }
  })
  
  # --- Translation Function ---
  t <- function(key, ...) {
    text <- translations[[current_language()]][[key]]
    if (is.null(text)) return(key) # Fallback to key if not translated
    
    # Simple string replacement for dynamic parts
    args <- list(...)
    if (length(args) > 0) {
      for (name in names(args)) {
        text <- str_replace_all(text, fixed(paste0("{", name, "}")), as.character(args[[name]]))
      }
    }
    return(text)
  }
  
  # --- Reactive UI Text Elements ---
  output$app_title <- renderText({ t("dashboard_title") })
  output$app_author <- renderText({ t("dashboard_author") })
  output$visit_full_dashboard <- renderText({ t("visit_full_dashboard") }) # This output is no longer used in UI
  output$overview_details <- renderText({ t("overview_details") })
  output$trends <- renderText({ t("trends") }) # New text output
  output$explorer <- renderText({ t("explorer") }) # New text output
  output$about <- renderText({ t("about") }) # New text output
  output$select_indicator <- renderText({ t("select_indicator") })
  output$select_countries <- renderText({ t("select_countries") }) # Retained but unused
  output$select_year_range <- renderText({ t("select_year_range") })
  output$latest_data <- renderText({ t("latest_data") })
  output$total_indicators <- renderText({ t("total_indicators") })
  output$time_period_covered <- renderText({ t("time_period_covered") })
  output$total_data_points <- renderText({ t("total_data_points") })
  output$pakistan_progress <- renderText({ t("pakistan_progress") })
  output$key_insights_pakistan <- renderText({ t("key_insights_pakistan") })
  output$pakistan_overview_text_1 <- renderText({ t("pakistan_overview_text_1") })
  output$pakistan_overview_text_2 <- renderText({ t("pakistan_overview_text_2") })
  output$sdg_goal_overview <- renderText({ t("sdg_goal_overview") }) # Retained but unused
  output$trend_analysis_for <- renderText({ t("trend_analysis_for") })
  output$comparison_of_indicator <- renderText({ t("comparison_of_indicator") }) # Retained but unused
  output$raw_data_explorer <- renderText({ t("raw_data_explorer") })
  output$footer_text_ui <- renderText({ t("footer_text") })
  output$trend_options <- renderText({ t("trend_options") }) # New text output
  output$statistical_summary <- renderText({ t("statistical_summary") }) # New text output
  output$about_project_details <- renderText({ t("about_project_details") }) # New text output
  output$about_author_details <- renderText({ t("about_author_details") }) # New text output
  output$quick_insights <- renderText({ t("quick_insights") }) # New text output
  output$trend_analysis_chart_title <- renderText({ t("trend_analysis_for", indicator = input$sdg_indicator_select) })
  
  # --- Dashboard Overview Tab Logic ---
  
  # Value Boxes
  output$totalIndicatorsBox <- renderValueBox({
    valueBox(
      value = length(available_series),
      subtitle = t("total_indicators"),
      icon = icon("list-ol"),
      color = "purple", # Matched to 'bg-purple' in custom CSS
      width = 3
    )
  })
  
  output$timePeriodBox <- renderValueBox({
    valueBox(
      value = paste(min_year, "-", max_year),
      subtitle = t("time_period_covered"),
      icon = icon("calendar-alt"),
      color = "light-blue", # Matched to 'bg-light-blue' in custom CSS
      width = 3
    )
  })
  
  output$totalDataPointsBox <- renderValueBox({
    valueBox(
      value = format(nrow(sdg_data_long), big.mark = ","),
      subtitle = t("total_data_points"),
      icon = icon("database"),
      color = "maroon", # Matched to 'bg-maroon' in custom CSS
      width = 3
    )
  })
  
  output$pakistanProgressBox <- renderValueBox({
    # Example: Average value for a key indicator for Pakistan (using Access to electricity as a default)
    pak_sdg_progress_data <- sdg_data_long %>%
      filter(`Country Name` == "Pakistan", `Series Name` == "Access to electricity (% of population)")
    
    pak_sdg_progress <- NA
    if (nrow(pak_sdg_progress_data) > 0 && is.numeric(pak_sdg_progress_data$Value)) {
      pak_sdg_progress <- mean(pak_sdg_progress_data$Value, na.rm = TRUE)
    }
    
    valueBox(
      value = if (!is.na(pak_sdg_progress)) paste0(round(pak_sdg_progress, 2), "%") else "N/A",
      subtitle = paste(t("pakistan_progress"), "(Electricity Access)"),
      icon = icon("flag"),
      color = "orange", # Matched to 'bg-orange' in custom CSS
      width = 3
    )
  })
  
  # Overview Chart (Pakistan's progress across a few key SDGs)
  output$overviewChart <- renderHighchart({
    # Filter for Pakistan and specific SDG codes, then get the latest value for each series
    pakistan_key_sdgs <- sdg_data_long %>%
      filter(
        `Country Name` == "Pakistan",
        `Series Code` %in% c(
          "EG.ELC.ACCS.ZS", # Access to electricity
          "SP.URB.TOTL.IN.ZS", # Urban population
          "ER.H2O.INTR.K3" # Renewable internal freshwater resources, total
        )
      ) %>%
      group_by(`Series Code`, `Series Name`) %>%
      slice_max(order_by = Year, n = 1, with_ties = FALSE) %>% # Get latest year for each series
      ungroup() %>%
      mutate(`Series Name` = str_wrap(`Series Name`, width = 20)) # Wrap long series names
    
    if (nrow(pakistan_key_sdgs) == 0) {
      return(highchart() %>% hc_title(text = t("no_data_available")))
    }
    
    highchart() %>%
      hc_chart(type = "bar") %>%
      hc_title(text = t("key_insights_pakistan"), align = "left") %>%
      hc_xAxis(categories = pakistan_key_sdgs$`Series Name`, title = list(text = "")) %>%
      hc_yAxis(title = list(text = t("value"))) %>%
      hc_add_series(
        name = "Latest Value",
        data = pakistan_key_sdgs$Value,
        colorByPoint = TRUE, # Different color for each bar
        colors = c("#673ab7", "#ffc107", "#03a9f4") # Deep Purple, Amber, Light Blue
      ) %>%
      hc_tooltip(valueDecimals = 2, pointFormat = paste0("<b>{point.y:,.2f}</b>")) %>%
      hc_legend(enabled = FALSE) %>%
      hc_exporting(enabled = TRUE)
  })
  
  # Latest Data Table for Overview
  output$latestDataTable <- renderDT({
    # Filter for Pakistan, then get the latest value for each series
    pakistan_latest_data <- sdg_data_long %>%
      filter(`Country Name` == "Pakistan") %>%
      group_by(`Series Code`, `Series Name`) %>%
      slice_max(order_by = Year, n = 1, with_ties = FALSE) %>% # Get latest year for each series
      ungroup() %>%
      select(`Series Name`, Value, Year) %>%
      distinct()
    
    if (nrow(pakistan_latest_data) == 0) {
      return(datatable(data.frame(
        !!t("series_name") := character(0),
        !!t("value") := numeric(0),
        !!t("year") := numeric(0)
      ), options = list(dom = 't'), rownames = FALSE))
    }
    
    pakistan_latest_data %>%
      rename(
        !!t("series_name") := `Series Name`,
        !!t("value") := Value,
        !!t("year") := Year
      ) %>%
      datatable(
        options = list(dom = 't', pageLength = 5, scrollX = TRUE),
        rownames = FALSE
      ) %>%
      formatRound(columns = t("value"), digits = 2)
  })
  
  # Quick Insights text for Overview tab (similar to macro app)
  output$insights_text <- renderUI({
    # Insights based on 'Access to clean fuels and technologies for cooking (% of population)'
    sdg_data_filtered <- sdg_data_long %>%
      filter(`Country Name` == "Pakistan", `Series Name` == "Access to clean fuels and technologies for cooking (% of population)")
    
    if (nrow(sdg_data_filtered) == 0 || !is.numeric(sdg_data_filtered$Value)) {
      return(HTML("<div style='font-size: 14px;'><p>No sufficient numeric data available for Access to clean fuels and technologies for cooking to generate insights.</p></div>"))
    }
    
    avg_value <- mean(sdg_data_filtered$Value, na.rm = TRUE)
    min_value <- min(sdg_data_filtered$Value, na.rm = TRUE)
    max_value <- max(sdg_data_filtered$Value, na.rm = TRUE)
    
    sdg_data_by_year <- sdg_data_filtered %>%
      group_by(Year) %>%
      summarize(Avg_Value = mean(Value, na.rm = TRUE), .groups = "drop") %>%
      arrange(Year)
    
    trend_text <- "stable"
    if(nrow(sdg_data_by_year) >= 2) {
      first_val <- sdg_data_by_year$Avg_Value[1]
      last_val <- sdg_data_by_year$Avg_Value[nrow(sdg_data_by_year)]
      
      if (!is.na(first_val) && !is.na(last_val)) {
        if (last_val > (first_val * 1.05)) { # 5% increase considered significant
          trend_text <- "increasing"
        } else if (last_val < (first_val * 0.95)) { # 5% decrease considered significant
          trend_text <- "decreasing"
        }
      } else {
        trend_text <- "undetermined" # Handle cases with NA in first/last values
      }
    } else if (nrow(sdg_data_by_year) == 1) {
      trend_text <- "no clear trend (single year data)"
    } else {
      trend_text <- "no clear trend (insufficient data)"
    }
    
    # Ensure max_year is not NA before using it
    latest_year_data <- max(sdg_data_by_year$Year, na.rm = TRUE)
    latest_value_data <- last(sdg_data_by_year$Avg_Value)
    
    HTML(paste0(
      "<div style='font-size: 14px; line-height: 1.6'>",
      "<p><strong>Indicator:</strong> Access to clean fuels and technologies for cooking</p>",
      "<p><strong>Trend:</strong> <span style='color:", ifelse(trend_text == "increasing", "#4caf50", ifelse(trend_text == "decreasing", "#d81b60", "#673ab7")), "'>", trend_text, "</span></p>", # Green for increasing, Red for decreasing
      "<p><strong>Range (%):</strong> ", round(min_value, 2), "% to ", round(max_value, 2), "%</p>",
      "<p><strong>Average (%):</strong> ", round(avg_value, 2), "%</p>",
      "<p><strong>Latest Value (", ifelse(!is.na(latest_year_data), latest_year_data, "N/A"), "):</strong> ",
      ifelse(!is.na(latest_value_data), round(latest_value_data, 2), "N/A"),
      "%</p>",
      "</div>"
    ))
  })
  
  # Download handler for raw data in Overview (from macro app)
  output$download_overview_data <- downloadHandler(
    filename = function() {
      paste0("pakistan_sdg_insights_overview_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      # Filter for key overview data, or provide the full SDG data
      overview_data_to_download <- sdg_data_long %>%
        filter(`Country Name` == "Pakistan") # Example: filter for Pakistan's data
      
      write.csv(overview_data_to_download, file, row.names = FALSE)
    }
  )
  
  
  # --- Trend Analysis Tab Logic (Simplified from macro app logic) ---
  
  # Reactive data based on filters for Trend Analysis
  filtered_trend_data <- reactive({
    req(input$sdg_indicator_select, input$sdg_year_range) # Ensure an indicator and year range are selected
    
    # Filter for Pakistan only in the trends tab
    data_filtered <- sdg_data_long %>%
      filter(
        `Country Name` == "Pakistan",
        `Series Name` == input$sdg_indicator_select,
        Year >= input$sdg_year_range[1],
        Year <= input$sdg_year_range[2]
      )
    
    # Explicitly check for numeric values
    if (!is.numeric(data_filtered$Value)) {
      data_filtered$Value <- as.numeric(data_filtered$Value) # Attempt conversion
    }
    
    req(nrow(data_filtered) > 0 && any(!is.na(data_filtered$Value))) # Ensure there's valid numeric data after filtering
    return(data_filtered)
  })
  
  # Trend chart for selected indicator
  output$sdgTrendChart <- renderHighchart({
    # Use req() directly here to prevent running if no valid data is available
    current_data <- filtered_trend_data()
    
    plot_data <- current_data %>%
      group_by(Year) %>%
      summarize(Aggregated_Value = mean(Value, na.rm = TRUE), .groups = 'drop') %>%
      arrange(Year)
    
    # Ensure plot_data is not empty and has numeric values for plotting
    req(nrow(plot_data) > 0 && any(!is.na(plot_data$Aggregated_Value)))
    
    # Safely get the selected unit
    selected_unit <- tryCatch({
      unit_val <- unique(current_data$Unit)[1]
      if (is.null(unit_val) || is.na(unit_val)) "" else as.character(unit_val)
    }, error = function(e) "")
    
    hc_title_text <- t("trend_analysis_for", indicator = input$sdg_indicator_select)
    
    highchart() %>%
      hc_chart(type = input$trend_chart_type) %>% # Dynamic chart type
      hc_title(text = hc_title_text, align = "left") %>%
      hc_xAxis(categories = plot_data$Year, title = list(text = t("year"))) %>%
      hc_yAxis(title = list(text = paste("Value (", selected_unit, ")"))) %>%
      hc_add_series(
        name = paste(input$sdg_indicator_select, " (", selected_unit, ")"),
        data = plot_data$Aggregated_Value,
        color = "#673ab7" # Deep Purple for trend line
      ) %>%
      hc_tooltip(
        valueDecimals = 2,
        shared = TRUE,
        crosshairs = TRUE,
        pointFormat = paste0('<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:,.2f} ', selected_unit, '</b><br/>')
      ) %>%
      hc_exporting(enabled = TRUE)
  })
  
  # Trend summary for selected item and element
  output$sdg_trend_summary <- renderPrint({
    # Use req() directly here to prevent running if no valid data is available
    current_data <- filtered_trend_data()
    
    # Ensure current_data is not empty and has numeric values for summary
    req(nrow(current_data) > 0 && any(!is.na(current_data$Value)))
    
    summary(current_data$Value)
  })
  
  # --- Data Explorer Tab Logic (from macro app) ---
  output$sdgDataTable <- renderDT({
    datatable(
      sdg_data_long,
      extensions = c('Buttons', 'Scroller', 'Responsive'),
      options = list(
        dom = 'Bfrtip',
        buttons = list(
          list(extend = 'copy', className = 'btn-sm'),
          list(extend = 'csv', className = 'btn-sm'),
          list(extend = 'excel', className = 'btn-sm'),
          list(extend = 'pdf', className = 'btn-sm')
        ),
        scrollX = TRUE,
        scrollY = "500px",
        scroller = TRUE,
        pageLength = 10,
        responsive = TRUE,
        autoWidth = TRUE,
        language = list(
          search = t("filter"), # Placeholder - need specific translation for filter
          paginate = list(
            `first` = t("first"), `last` = t("last"), `next` = t("next"), `previous` = t("previous")
          )
        )
      ),
      class = "cell-border stripe hover",
      rownames = FALSE,
      filter = 'top', # Column filters at the top
      colnames = c(t("country_name"), t("series_name"), t("series_code"), t("value"), t("year"))
    ) %>%
      formatRound(columns = c("Value"), digits = 2)
  })
  
}

# Run the application
shinyApp(ui, server)
