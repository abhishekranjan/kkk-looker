# Section A — State Dashboard (row-level secured to one state)
# Karmayogi Kartavya Karyakram
#
# Companion to the Section A design mock. Every element name here
# matches the tile label shown by "Show LookML tile names".
#
# THIS FILE LIVES IN THE STATE MODEL ONLY.
# SECURITY IS CURRENTLY OFF for testing (access_filter commented out in
# the model, state filter defaults to Odisha and is not required).
# When it is switched back on, the security lives in the model's explore:
#
#   explore: fact_batch_activity {
#     access_filter: {
#       field: dim_state.state_name
#       user_attribute: assigned_state
#     }
#   }
#
# Because the filter sits on the explore, a nodal officer cannot widen
# it from the dashboard, cannot reach another state by editing the URL,
# and cannot total the nation. The `state` filter below exists only so
# the state name can be shown in titles and so a CBC user opening the
# same dashboard can switch states.
#
# Box 6 of the spec (assessment) is marked CBC-only, so fact_assessment
# is NOT joined into the state model at all. The assessment tab here is
# a text tile explaining where the analysis lives.

- dashboard: state_dashboard
  title: State Implementation Dashboard
  description: "Your state's own view of the Karmayogi Kartavya Karyakram rollout."
  layout: newspaper
  preferred_viewer: dashboards-next
  refresh: 1 hour
  crossfilter_enabled: true
  embed_style:
    background_color: "#FAF8F3"
    tile_background_color: "#FFFFFF"
    tile_text_color: "#1C2430"
    title_color: "#12233B"
    show_title: true
    text_tile_text_color: "#707A88"

  # ---------------------------------------------------------------
  # Filters
  # ---------------------------------------------------------------
  filters:
  - name: state
    title: "State / UT"
    type: field_filter
    # Testing: fixed default instead of the user attribute, and not required.
    # Restore to:  default_value: "Your state"
    #              required: true
    default_value: "Odisha"
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: state_dashboard
    explore: fact_batch_activity
    field: dim_state.state_name

  - name: district
    title: "District"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: state_dashboard
    explore: fact_batch_activity
    field: dim_district.district_name

  - name: programme
    title: "Programme"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_toggles
      display: inline
    model: state_dashboard
    explore: fact_batch_activity
    field: fact_batch_activity.batch_type

  - name: date_range
    title: "As of"
    type: field_filter
    default_value: "before 2027/04/01"
    allow_multiple_values: false
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
    model: state_dashboard
    explore: fact_batch_activity
    field: dim_date.date

  elements:

  # ===============================================================
  # BOX 1 + BOX 2 — header, totals strip, district map and table
  # ===============================================================

  - title: At a glance
    name: state_header
    type: text
    body_text: |-
      **Your state at a glance** — this state's own numbers
      as they stand in the source. Total state lead trainers is not tracked anywhere,
      so it reads as pending rather than as a guessed figure. The strip below is simply
      the district table added up.
    row: 0
    col: 0
    width: 24
    height: 2

  - title: State master trainers certified
    name: smt_trained
    model: state_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.smt_trained, fact_batch_activity.smt_batches]
    filters:
      fact_batch_activity.batch_type: "SMT"
    single_value_title: "State master trainers certified"
    comparison_label: "batches · 2-day programme"
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      date_range: dim_date.date
    row: 2
    col: 0
    width: 6
    height: 3

  - title: One-day participants trained
    name: one_day_trained
    model: state_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.one_day_trained, fact_batch_activity.one_day_batches]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    single_value_title: "One-day participants trained"
    comparison_label: "batches"
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      date_range: dim_date.date
    row: 2
    col: 6
    width: 6
    height: 3

  # --- Deliberately NOT a count of zero. slt_trained is a nullable
  # --- measure; value_format_name renders null as the word Pending so
  # --- an untracked figure never reads as "none certified".
  - title: State lead trainers certified
    name: slt_trained
    model: state_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.slt_trained]
    single_value_title: "State lead trainers certified"
    value_format: '#,##0;;"Pending"'
    custom_color_enabled: true
    custom_color: "#707A88"
    note_state: expanded
    note_display: below
    note_text: "No SLT feed in the source — current figures are demo. Shows Pending when zero."
    listen:
      state: dim_state.state_name
      date_range: dim_date.date
    row: 2
    col: 12
    width: 6
    height: 3

  - title: Progress against the trainer requirement
    name: smt_vs_requirement
    model: state_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.pct_smt_certified, fact_monthly_target.smt_outstanding]
    single_value_title: "Of the trainers this state needs"
    comparison_label: "still to certify by Mar '27"
    value_format: '0.0\%'
    custom_color_enabled: true
    custom_color: "#AD7C25"
    listen:
      state: dim_state.state_name
    row: 2
    col: 18
    width: 6
    height: 3

  # --- Point map from dim_district.location. Real coordinates for the
  # --- four showcase states; other states fall back near the centroid.
  - title: Districts
    name: district_activity
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_map
    fields: [dim_district.location, dim_district.district_name, fact_batch_activity.one_day_trained]
    map_plot_mode: points
    map_position: fit_data
    map_scale_indicator: "off"
    map_value_colors: ["#F2EFE6", "#2F7D57"]
    note_state: collapsed
    note_display: below
    note_text: "Coloured by one-day participants. Click a district to filter every tile on the page."
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 5
    col: 0
    width: 9
    height: 10

  - title: By district
    name: district_detail
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_grid
    fields: [dim_district.district_name,
             fact_batch_activity.smt_trained, fact_batch_activity.smt_batches,
             fact_batch_activity.one_day_trained, fact_batch_activity.one_day_batches,
             fact_batch_activity.implementation_status]
    sorts: [fact_batch_activity.one_day_trained desc, fact_batch_activity.smt_trained desc]
    show_totals: true
    limit_displayed_rows: false
    table_theme: editable
    conditional_formatting:
    - type: equal to
      value: "One-day under way"
      background_color: "#CFE7D9"
      font_color: "#2F7D57"
      fields: [fact_batch_activity.implementation_status]
    - type: equal to
      value: "Trainers only"
      background_color: "#F0E0BC"
      font_color: "#AD7C25"
      fields: [fact_batch_activity.implementation_status]
    - type: equal to
      value: "Not started"
      background_color: "#F1D4CE"
      font_color: "#B04435"
      fields: [fact_batch_activity.implementation_status]
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 5
    col: 9
    width: 15
    height: 10

  # ===============================================================
  # BOX 3 — activity trend, this state only
  # ===============================================================

  - title: Activity by month
    name: activity_trend
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_line
    fields: [dim_date.month_name, fact_batch_activity.batch_count, fact_batch_activity.participants_trained]
    sorts: [dim_date.month_name]
    series_colors:
      fact_batch_activity.batch_count: "#1D3557"
      fact_batch_activity.participants_trained: "#D97B34"
    y_axes:
    - label: "Batches"
      orientation: left
      series: [{id: fact_batch_activity.batch_count, axisId: left}]
    - label: "People trained"
      orientation: right
      series: [{id: fact_batch_activity.participants_trained, axisId: right}]
    point_style: circle
    interpolation: linear
    x_axis_gridlines: false
    y_axis_gridlines: true
    legend_position: center
    note_state: expanded
    note_display: below
    note_text: "Batches and people trained by month. Dates are partly demo where the source had none."
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 15
    col: 0
    width: 15
    height: 7

  - title: Ranked districts
    name: district_ranking
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_bar
    fields: [dim_district.district_name, fact_batch_activity.smt_trained, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.participants_trained: ">0"
    sorts: [fact_batch_activity.one_day_trained desc]
    limit: 15
    series_colors:
      fact_batch_activity.smt_trained: "#1D3557"
      fact_batch_activity.one_day_trained: "#D97B34"
    show_value_labels: true
    legend_position: center
    note_state: collapsed
    note_display: below
    note_text: "Top 15 districts by one-day participants."
    listen:
      state: dim_state.state_name
      date_range: dim_date.date
    row: 15
    col: 15
    width: 9
    height: 7

  # ===============================================================
  # BOX 4 + BOX 5 — group-wise and designation-wise
  # Second dashboard tab: "Groups and designations"
  # ===============================================================

  - title: Who has been trained
    name: people_header
    type: text
    body_text: |-
      **Who has been trained** — both tiles split the same one-day participants, first
      by service group, then by designation.
    row: 22
    col: 0
    width: 24
    height: 2

  - title: By group
    name: one_day_by_group
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_bar
    fields: [dim_group.group_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [dim_group.group_name]
    series_colors:
      fact_batch_activity.one_day_trained: "#1D3557"
    show_value_labels: true
    hide_legend: true
    x_axis_gridlines: false
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      date_range: dim_date.date
    row: 24
    col: 0
    width: 12
    height: 7

  - title: By designation
    name: one_day_by_designation
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_bar
    fields: [dim_designation.designation_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [fact_batch_activity.one_day_trained desc]
    limit: 20
    series_colors:
      fact_batch_activity.one_day_trained: "#2F7D57"
    show_value_labels: true
    hide_legend: true
    x_axis_gridlines: false
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      date_range: dim_date.date
    row: 24
    col: 12
    width: 12
    height: 7

  - title: Group against designation
    name: group_by_designation
    model: state_dashboard
    explore: fact_batch_activity
    type: looker_grid
    fields: [dim_designation.designation_name, dim_group.group_name, fact_batch_activity.one_day_trained]
    pivots: [dim_group.group_name]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [dim_group.group_name, fact_batch_activity.one_day_trained desc]
    show_totals: true
    show_row_totals: true
    table_theme: white
    limit_displayed_rows: false
    note_state: expanded
    note_display: below
    note_text: "One-day participants by designation, split across service groups."
    listen:
      state: dim_state.state_name
      district: dim_district.district_name
      date_range: dim_date.date
    row: 31
    col: 0
    width: 24
    height: 8

  # ===============================================================
  # BOX 6 — assessment. CBC only, so no explore is granted here.
  # Third tab carries an explanation rather than a missing page.
  # ===============================================================

  - title: Assessment and analysis
    name: assess_header
    type: text
    body_text: |-
      **Assessment and analysis** — covered by Box 6 of the specification, which is
      marked for the Capacity Building Commission only.
    row: 39
    col: 0
    width: 24
    height: 2

  - title: Baseline, day-1 and improvement
    name: assessment_restricted
    type: text
    body_text: |-
      🔒 **Held by the Capacity Building Commission**

      Baseline results, day-1 results and the improvement between them are analysed
      centrally for the one-day participant programme. `fact_assessment` is not joined
      into the state model, so these numbers are not available on this dashboard.
      Your CBC programme contact can share this state's extract.

      If the Commission later opens this up, the same three measures drop into this tab
      filtered by the same `assigned_state` attribute that governs every other tile.
    row: 41
    col: 0
    width: 24
    height: 6
