# ============================================================================
# FILE: state_dashboard.dashboard.lookml
# Section A - State Dashboard - Karmayogi Kartavya Karyakram
#
# Built box by box from "KKK - State Dashboard Instructions":
#   Box 1 Header ............ State / UT filter in the filter bar; district
#                             map with SMT + 1-Day on "State overview";
#                             full state data on the "Download data" tab
#   Box 2 Detailed .......... tab "State overview"  (totals strip, state row,
#                             district table with Download + map beside it)
#   Box 3 Activity trend .... tab "1-Day programme and assessment"
#   Box 4 Group-wise ........ tab "1-Day programme and assessment"
#   Box 5 Designation-wise .. tab "1-Day programme and assessment"
#   Box 6 Assessment ........ tab "1-Day programme and assessment" (Box 6 is
#                             about the 1-day programme only, so it sits here)
# Extra (more than the doc asks, never less): large district map with a
# placement table on "State overview", "SMT and SLT programmes" tab,
# "Download data" tab.
# Looker allows at most 5 tabs per dashboard.
#
# NO ACCESS RESTRICTION: any user can pick any state; every tab is visible.
# Requires Looker 26.4+ for dashboard tabs, and the custom visualization in
# manifest.lkml deployed to production.
# ============================================================================

- dashboard: state_dashboard
  title: State Implementation Dashboard
  description: "Karmayogi Kartavya Karyakram - the selected State / UT's own view of the rollout."
  layout: newspaper
  preferred_viewer: dashboards-next
  refresh: 1 hour
  crossfilter_enabled: true
  enable_viz_full_screen: true
  filters_location_top: true
  embed_style:
    background_color: "#FAF8F3"
    tile_background_color: "#FFFFFF"
    tile_text_color: "#1C2430"
    title_color: "#12233B"
    show_title: true

  tabs:
  - name: State overview
    label: State overview
  - name: 1-Day programme and assessment
    label: 1-Day programme and assessment
  - name: SMT and SLT programmes
    label: SMT and SLT programmes
  - name: Download data
    label: Download data

  # ---------------------------------------------------------------
  # Filters (Box 1: "State dropdown - e.g. Odisha")
  # ---------------------------------------------------------------
  filters:
  - name: state
    title: "State / UT"
    type: field_filter
    default_value: "Odisha"
    allow_multiple_values: false
    required: true
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
    field: district_map.district_label
    listens_to_filters: [state]

  - name: batch_date
    title: "Date (as of)"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: state_dashboard
    explore: fact_batch_activity
    field: fact_batch_activity.batch_date

  elements:

  # =================================================================
  # TAB: STATE OVERVIEW  - Box 1 (header) and Box 2 (detailed), district map
  # =================================================================

  - name: ov_box2_header
    type: text
    tab_name: State overview
    title_text: "Detailed"
    body_text: |-
      The state's own numbers as they stand in the source. **Total SLT is not tracked yet, so it reads Pending** rather than a guessed number.
      The totals strip is the district table added up. **Total Batches = one-day batches taken by SMTs.**
    row: 0
    col: 0
    width: 24
    height: 4

  - name: ov_total_slt
    title: "Total SLT"
    type: single_value
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.slt_certified]
    show_single_value_title: true
    single_value_title: "Total SLT"
    show_comparison: false
    custom_color_enabled: true
    custom_color: "#707A88"
    note_state: collapsed
    note_display: hover
    note_text: "State lead trainers. No SLT feed exists in the source, so this shows Pending until reported rows arrive."
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 0
    width: 6
    height: 3

  - name: ov_total_smts
    title: "Total SMTs"
    type: single_value
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.smt_trained]
    show_single_value_title: true
    single_value_title: "Total SMTs"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#1D3557"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 6
    width: 6
    height: 3

  - name: ov_one_day_trained
    title: "1-Day Trained"
    type: single_value
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.one_day_trained]
    show_single_value_title: true
    single_value_title: "1-Day Trained"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 12
    width: 6
    height: 3

  - name: ov_total_batches
    title: "Total Batches"
    type: single_value
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.one_day_batches]
    show_single_value_title: true
    single_value_title: "Total Batches"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#D97B34"
    note_state: collapsed
    note_display: hover
    note_text: "One-day batches taken by SMTs. The SMTs' own 2-day training batches are on the SMT and SLT programmes tab."
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 18
    width: 6
    height: 3

  - name: ov_state_row
    title: "State summary"
    type: looker_grid
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_state.state_name, fact_batch_activity.slt_certified, fact_batch_activity.smt_trained,
             fact_batch_activity.one_day_trained, fact_batch_activity.one_day_batches]
    sorts: [dim_state.state_name]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    table_theme: white
    series_labels:
      dim_state.state_name: "State"
      fact_batch_activity.slt_certified: "Total SLT"
      fact_batch_activity.smt_trained: "Total SMTs"
      fact_batch_activity.one_day_trained: "1-Day Trained"
      fact_batch_activity.one_day_batches: "Total Batches"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 7
    col: 0
    width: 24
    height: 3

  - name: ov_district_map
    title: "District map · 1-Day Trained and SMTs (click a district to filter the table)"
    note_state: collapsed
    note_display: hover
    note_text: "Survey of India boundaries, no base map. Buttons switch between 1-Day Trained, SMTs and batches. Zoom with + / −, Ctrl/Cmd + scroll or double-click; drag to pan; ⤢ fits the state. Districts created after 2011 are drawn inside their parent district (see the placement table below)."
    type: central_dashboard::kkk_district_map
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_state.state_name, district_map.map_key, fact_batch_activity.one_day_trained,
             fact_batch_activity.smt_trained, fact_batch_activity.one_day_batches, district_map.reported_as]
    sorts: [district_map.map_key]
    limit: 1000
    default_measure: fact_batch_activity.one_day_trained
    color_low: "#DDEBE1"
    color_high: "#2F7D57"
    no_data_color: "#FFFFFF"
    show_labels: true
    label_mode: name_value
    show_metric_buttons: true
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 10
    col: 0
    width: 15
    height: 24

  - name: ov_district_table
    title: "District-wise"
    type: looker_grid
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_state.state_name, district_map.district_label, district_map.district_download,
             fact_batch_activity.smt_trained, fact_batch_activity.one_day_batches, fact_batch_activity.one_day_trained]
    sorts: [fact_batch_activity.one_day_trained desc, fact_batch_activity.smt_trained desc]
    limit: 500
    column_order: [district_map.district_label, fact_batch_activity.smt_trained, fact_batch_activity.one_day_batches,
                   fact_batch_activity.one_day_trained, district_map.district_download]
    hidden_fields: [dim_state.state_name]
    show_totals: true
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      district_map.district_label: "District"
      fact_batch_activity.smt_trained: "Total SMTs"
      fact_batch_activity.one_day_batches: "Batches taken by SMTs"
      fact_batch_activity.one_day_trained: "1-Day Trained"
      district_map.district_download: "Download"
    note_state: collapsed
    note_display: hover
    note_text: "Totals row = State Total. Each Download link opens that district's rows in an Explore (gear > Download > Excel)."
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 10
    col: 15
    width: 9
    height: 24

  # =================================================================
  # (District map is part of State overview)
  # =================================================================

  - name: dm_placement_table
    title: "How each reported district is placed on the map"
    type: looker_grid
    tab_name: State overview
    model: state_dashboard
    explore: fact_batch_activity
    fields: [district_map.district_label, district_map.reported_name, district_map.map_district, district_map.match_note,
             fact_batch_activity.smt_trained, fact_batch_activity.one_day_trained]
    sorts: [district_map.map_district, district_map.district_label]
    limit: 500
    show_totals: true
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      district_map.district_label: "District"
      district_map.reported_name: "As reported in source"
      district_map.map_district: "Drawn in (official district)"
      district_map.match_note: "Why"
      fact_batch_activity.smt_trained: "Total SMTs"
      fact_batch_activity.one_day_trained: "1-Day Trained"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 34
    col: 0
    width: 24
    height: 9

  # =================================================================
  # TAB: 1-DAY PROGRAMME AND ASSESSMENT - Box 3, 4, 5 (Box 6 further down)
  # =================================================================

  - name: od_header
    type: text
    tab_name: 1-Day programme and assessment
    title_text: "1-Day programme · this state only"
    body_text: |-
      One-day participant training, run by the state's master trainers (SMTs): activity trend, then the same participants by service group and by designation.
      The assessment of this programme (baseline against day-1) is at the bottom of this tab.
    row: 0
    col: 0
    width: 24
    height: 4

  - name: od_trained
    title: "1-Day Trained"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.one_day_trained]
    single_value_title: "1-Day Trained"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 0
    width: 6
    height: 3

  - name: od_batches
    title: "Batches taken by SMTs"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.one_day_batches]
    single_value_title: "Batches taken by SMTs"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#D97B34"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 6
    width: 6
    height: 3

  - name: od_per_batch
    title: "Participants per batch"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.avg_one_day_per_batch]
    single_value_title: "Participants per batch"
    show_comparison: false
    value_format: "#,##0.0"
    custom_color_enabled: true
    custom_color: "#1D3557"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 12
    width: 6
    height: 3

  - name: od_districts
    title: "Districts reached"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.districts_with_one_day, fact_batch_activity.designations_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    single_value_title: "Districts reached"
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "designations reached"
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#1D3557"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 18
    width: 6
    height: 3

  - name: od_box3_trend
    title: "Activity trend - Batches and 1-Day Trained, by date"
    type: looker_line
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.batch_date, fact_batch_activity.one_day_batches, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [fact_batch_activity.batch_date]
    limit: 1000
    series_colors:
      fact_batch_activity.one_day_batches: "#D97B34"
      fact_batch_activity.one_day_trained: "#2F7D57"
    series_labels:
      fact_batch_activity.one_day_batches: "Batches"
      fact_batch_activity.one_day_trained: "1-Day Trained"
    y_axes:
    - label: "Batches"
      orientation: left
      series:
      - id: fact_batch_activity.one_day_batches
        name: Batches
        axisId: fact_batch_activity.one_day_batches
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: "1-Day Trained"
      orientation: right
      series:
      - id: fact_batch_activity.one_day_trained
        name: 1-Day Trained
        axisId: fact_batch_activity.one_day_trained
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    point_style: circle
    interpolation: linear
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    note_state: collapsed
    note_display: hover
    note_text: "Each point is one batch date. Dates are partly demo where the source had none (see data source on the Download data tab)."
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 7
    col: 0
    width: 16
    height: 9

  - name: od_box3_monthly
    title: "By month"
    type: looker_grid
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.batch_month, fact_batch_activity.one_day_batches, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [fact_batch_activity.batch_month]
    limit: 50
    show_totals: true
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    series_labels:
      fact_batch_activity.batch_month: "Month"
      fact_batch_activity.one_day_batches: "Batches"
      fact_batch_activity.one_day_trained: "1-Day Trained"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 7
    col: 16
    width: 8
    height: 9

  - name: od_box4_group_bar
    title: "Group-wise - 1-Day Trained by service group"
    type: looker_bar
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_group.group_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [dim_group.group_name]
    limit: 50
    series_colors:
      fact_batch_activity.one_day_trained: "#1D3557"
    series_labels:
      fact_batch_activity.one_day_trained: "1-Day Trained"
    show_value_labels: true
    hide_legend: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 16
    col: 0
    width: 14
    height: 8

  - name: od_box4_group_list
    title: "Group-wise list"
    type: looker_grid
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_group.group_name, fact_batch_activity.one_day_trained, fact_batch_activity.designations_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    sorts: [dim_group.group_name]
    limit: 50
    show_totals: true
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    series_labels:
      dim_group.group_name: "Group"
      fact_batch_activity.one_day_trained: "1-Day Trained"
      fact_batch_activity.designations_trained: "Designations"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 16
    col: 14
    width: 10
    height: 8

  - name: od_box5_designation_bar
    title: "Designation-wise - top 20 by 1-Day Trained"
    type: looker_bar
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_designation.designation_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
      fact_batch_activity.one_day_trained: ">0"
    sorts: [fact_batch_activity.one_day_trained desc]
    limit: 20
    series_colors:
      fact_batch_activity.one_day_trained: "#2F7D57"
    series_labels:
      fact_batch_activity.one_day_trained: "1-Day Trained"
    show_value_labels: true
    hide_legend: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 24
    col: 0
    width: 14
    height: 11

  - name: od_box5_designation_list
    title: "Designation-wise list (all designations)"
    type: looker_grid
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_designation.designation_name, dim_group.group_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
      fact_batch_activity.one_day_trained: ">0"
    sorts: [fact_batch_activity.one_day_trained desc]
    limit: 1000
    show_totals: true
    show_row_numbers: true
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      dim_designation.designation_name: "Designation"
      dim_group.group_name: "Group"
      fact_batch_activity.one_day_trained: "1-Day Trained"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 24
    col: 14
    width: 10
    height: 11

  - name: od_group_by_designation
    title: "Group against designation - 1-Day Trained"
    type: looker_grid
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_designation.designation_name, dim_group.group_name, fact_batch_activity.one_day_trained]
    pivots: [dim_group.group_name]
    filters:
      fact_batch_activity.batch_type: "One-Day"
      fact_batch_activity.one_day_trained: ">0"
    sorts: [dim_group.group_name, dim_designation.designation_name]
    limit: 1000
    show_totals: true
    show_row_totals: true
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 35
    col: 0
    width: 24
    height: 9

  # =================================================================
  # TAB: SMT AND SLT PROGRAMMES - state master trainers
  # =================================================================

  - name: smt_header
    type: text
    tab_name: SMT and SLT programmes
    title_text: "SMT programme · state master trainers"
    body_text: |-
      Master trainers certified through the 2-day SMT programme, against the requirement to March 2027.
      Monthly actuals split a cumulative total across months (the split is demo; the total is reported).
    row: 0
    col: 0
    width: 24
    height: 4

  - name: smt_certified
    title: "Total SMTs certified"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.smt_trained]
    single_value_title: "Total SMTs certified"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#1D3557"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 0
    width: 6
    height: 3

  - name: smt_training_batches
    title: "SMT training batches (2-day)"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.smt_batches]
    single_value_title: "SMT training batches (2-day)"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 4
    col: 6
    width: 6
    height: 3

  - name: smt_required
    title: "SMTs required by Mar '27"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_monthly_target
    fields: [fact_monthly_target.smt_required, fact_monthly_target.smt_batches_required]
    single_value_title: "SMTs required by Mar '27"
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "trainer batches required"
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#AD7C25"
    listen:
      state: dim_state.state_name
    row: 4
    col: 12
    width: 6
    height: 3

  - name: smt_pct_certified
    title: "Progress against the requirement"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_monthly_target
    fields: [fact_monthly_target.pct_smt_certified, fact_monthly_target.smt_outstanding]
    single_value_title: "% of required SMTs certified"
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "still to certify"
    value_format: '0.0"%"'
    custom_color_enabled: true
    custom_color: "#2F7D57"
    listen:
      state: dim_state.state_name
    row: 4
    col: 18
    width: 6
    height: 3

  - name: smt_trend
    title: "SMTs certified and training batches, by date"
    type: looker_line
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.batch_date, fact_batch_activity.smt_batches, fact_batch_activity.smt_trained]
    filters:
      fact_batch_activity.batch_type: "SMT"
    sorts: [fact_batch_activity.batch_date]
    limit: 1000
    series_colors:
      fact_batch_activity.smt_batches: "#AD7C25"
      fact_batch_activity.smt_trained: "#1D3557"
    series_labels:
      fact_batch_activity.smt_batches: "SMT batches"
      fact_batch_activity.smt_trained: "SMTs certified"
    y_axes:
    - label: "Batches"
      orientation: left
      series:
      - id: fact_batch_activity.smt_batches
        name: SMT batches
        axisId: fact_batch_activity.smt_batches
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    - label: "SMTs certified"
      orientation: right
      series:
      - id: fact_batch_activity.smt_trained
        name: SMTs certified
        axisId: fact_batch_activity.smt_trained
      showLabels: true
      showValues: true
      unpinAxis: false
      tickDensity: default
      type: linear
    point_style: circle
    interpolation: linear
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 7
    col: 0
    width: 13
    height: 8

  - name: smt_target_vs_actual
    title: "Monthly SMT target against actual"
    type: looker_column
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_monthly_target
    fields: [dim_month.month_label, dim_month.month_id, fact_monthly_target.smt_target, fact_monthly_target.smt_actual]
    hidden_fields: [dim_month.month_id]
    sorts: [dim_month.month_id]
    limit: 24
    series_colors:
      fact_monthly_target.smt_target: "#1D3557"
      fact_monthly_target.smt_actual: "#D97B34"
    series_labels:
      fact_monthly_target.smt_target: "Target"
      fact_monthly_target.smt_actual: "Actual"
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    note_state: collapsed
    note_display: hover
    note_text: "Actual = monthly split of the cumulative SMT total (split is demo)."
    listen:
      state: dim_state.state_name
    row: 7
    col: 13
    width: 11
    height: 8

  - name: smt_by_district
    title: "SMTs by district"
    type: looker_bar
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [district_map.district_label, fact_batch_activity.smt_trained, fact_batch_activity.smt_batches]
    filters:
      fact_batch_activity.smt_trained: ">0"
    sorts: [fact_batch_activity.smt_trained desc]
    limit: 50
    series_colors:
      fact_batch_activity.smt_trained: "#1D3557"
      fact_batch_activity.smt_batches: "#AD7C25"
    series_labels:
      fact_batch_activity.smt_trained: "SMTs certified"
      fact_batch_activity.smt_batches: "SMT batches"
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 15
    col: 0
    width: 12
    height: 11

  - name: smt_by_designation
    title: "SMTs by designation"
    type: looker_grid
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_designation.designation_name, dim_group.group_name, fact_batch_activity.smt_trained]
    filters:
      fact_batch_activity.smt_trained: ">0"
    sorts: [fact_batch_activity.smt_trained desc]
    limit: 500
    show_totals: true
    show_row_numbers: true
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      dim_designation.designation_name: "Designation"
      dim_group.group_name: "Group"
      fact_batch_activity.smt_trained: "SMTs certified"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 15
    col: 12
    width: 12
    height: 11

  - name: smt_certification_outcome
    title: "SMT certification outcome"
    type: looker_column
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.programme_type, fact_assessment.certified_count, fact_assessment.not_certified_count]
    filters:
      fact_assessment.programme_type: "SMT"
    sorts: [fact_assessment.programme_type]
    limit: 10
    stacking: normal
    series_colors:
      fact_assessment.certified_count: "#2F7D57"
      fact_assessment.not_certified_count: "#B04435"
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    note_state: expanded
    note_display: below
    note_text: "Kept apart from the 1-day assessment so participant numbers never dilute the trainer result. Demo figures - no assessment feed exists yet."
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 26
    col: 0
    width: 24
    height: 7

  # =================================================================
  # TAB: SMT AND SLT PROGRAMMES (cont.) - state lead trainers
  # =================================================================

  - name: slt_header
    type: text
    tab_name: SMT and SLT programmes
    title_text: "SLT programme · state lead trainers"
    body_text: |-
      **Total SLT is not tracked yet** - the source has no SLT certification feed, so it reads **Pending** rather than a guessed number.
      The requirement to March 2027 comes from the state plan.
    row: 33
    col: 0
    width: 24
    height: 4

  - name: slt_certified
    title: "Total SLT"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.slt_certified]
    single_value_title: "State lead trainers certified"
    show_comparison: false
    custom_color_enabled: true
    custom_color: "#707A88"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 37
    col: 0
    width: 8
    height: 4

  - name: slt_required
    title: "SLTs required by Mar '27"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_monthly_target
    fields: [fact_monthly_target.slt_required]
    single_value_title: "Lead trainers required by Mar '27"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#AD7C25"
    listen:
      state: dim_state.state_name
    row: 37
    col: 8
    width: 8
    height: 4

  - name: slt_batches_required
    title: "SLT batches required"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_monthly_target
    fields: [fact_monthly_target.slt_batches_required]
    single_value_title: "Lead trainer batches required"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      state: dim_state.state_name
    row: 37
    col: 16
    width: 8
    height: 4

  - name: slt_demo_rows
    title: "Demo placeholder rows in the dataset (not an official figure)"
    type: single_value
    tab_name: SMT and SLT programmes
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.slt_demo_placeholder]
    single_value_title: "SLT demo placeholder - excluded everywhere"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#B04435"
    note_state: expanded
    note_display: below
    note_text: "The load file carries DEMO SLT rows. They are excluded from Total SLT. Delete them from fact_batch_activity once a real SLT feed exists."
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 41
    col: 0
    width: 24
    height: 4

  # =================================================================
  # TAB: 1-DAY PROGRAMME AND ASSESSMENT (cont.) - Box 6 (1-day programme only)
  # =================================================================

  - name: as_header
    type: text
    tab_name: 1-Day programme and assessment
    title_text: "Assessment and analysis - 1-Day participant programme"
    body_text: |-
      Covers **only the 1-day participant programme**, kept separate from master-trainer certification. Baseline = before the programme; Day-1 = end of the day; Improvement = Day-1 minus Baseline.
      Shown to everyone for now (no access restriction). Scores are demo until an assessment feed exists.
    row: 44
    col: 0
    width: 24
    height: 4

  - name: as_baseline
    title: "Baseline survey"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.avg_baseline_score]
    filters:
      fact_assessment.programme_type: "One-Day"
    single_value_title: "Average baseline score"
    show_comparison: false
    value_format: "0.0"
    custom_color_enabled: true
    custom_color: "#707A88"
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 48
    col: 0
    width: 6
    height: 3

  - name: as_day1
    title: "Day-1 assessment"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.avg_day1_score]
    filters:
      fact_assessment.programme_type: "One-Day"
    single_value_title: "Average day-1 score"
    show_comparison: false
    value_format: "0.0"
    custom_color_enabled: true
    custom_color: "#1D3557"
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 48
    col: 6
    width: 6
    height: 3

  - name: as_improvement
    title: "Baseline vs Day-1 improvement"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.avg_improvement, fact_assessment.improvement_pct]
    filters:
      fact_assessment.programme_type: "One-Day"
    single_value_title: "Improvement (points)"
    show_comparison: true
    comparison_type: value
    show_comparison_label: true
    comparison_label: "of the baseline score"
    value_format: "+0.0;-0.0;0.0"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 48
    col: 12
    width: 6
    height: 3

  - name: as_participants
    title: "Participants assessed"
    type: single_value
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.participants_assessed]
    filters:
      fact_assessment.programme_type: "One-Day"
    single_value_title: "Participants assessed"
    show_comparison: false
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 48
    col: 18
    width: 6
    height: 3

  - name: as_comparison_chart
    title: "Baseline vs Day-1 comparison"
    type: looker_column
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.assessment_date, fact_assessment.avg_baseline_score, fact_assessment.avg_day1_score, fact_assessment.avg_improvement]
    filters:
      fact_assessment.programme_type: "One-Day"
    sorts: [fact_assessment.assessment_date]
    limit: 100
    series_colors:
      fact_assessment.avg_baseline_score: "#C9CED6"
      fact_assessment.avg_day1_score: "#1D3557"
      fact_assessment.avg_improvement: "#2F7D57"
    series_labels:
      fact_assessment.avg_baseline_score: "Baseline"
      fact_assessment.avg_day1_score: "Day-1"
      fact_assessment.avg_improvement: "Improvement"
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    legend_position: center
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 51
    col: 0
    width: 14
    height: 9

  - name: as_detail
    title: "Assessment detail"
    type: looker_grid
    tab_name: 1-Day programme and assessment
    model: state_dashboard
    explore: fact_assessment
    fields: [fact_assessment.assessment_date, fact_assessment.participants_assessed, fact_assessment.avg_baseline_score,
             fact_assessment.avg_day1_score, fact_assessment.avg_improvement, fact_assessment.improvement_pct, fact_assessment.data_source]
    filters:
      fact_assessment.programme_type: "One-Day"
    sorts: [fact_assessment.assessment_date]
    limit: 100
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    series_labels:
      fact_assessment.assessment_date: "Date"
      fact_assessment.participants_assessed: "Assessed"
      fact_assessment.avg_baseline_score: "Baseline"
      fact_assessment.avg_day1_score: "Day-1"
      fact_assessment.avg_improvement: "Improvement"
      fact_assessment.improvement_pct: "Improvement %"
      fact_assessment.data_source: "Source"
    listen:
      state: dim_state.state_name
      batch_date: fact_assessment.assessment_date
    row: 51
    col: 14
    width: 10
    height: 9

  # =================================================================
  # TAB: DOWNLOAD DATA  - full state data for Excel
  # =================================================================

  - name: dl_header
    type: text
    tab_name: Download data
    title_text: "Download Full State Data (Excel)"
    body_text: |-
      **To download:** ⋮ menu on the **Full state data** tile > **Download** > **Excel Spreadsheet** > **All results**.
      The whole dashboard downloads from the dashboard ⋮ menu. Each district's own rows download from the **District summary** tile.
    row: 0
    col: 0
    width: 24
    height: 4

  - name: dl_explore_link
    title: "Open in Explore"
    type: single_value
    tab_name: Download data
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_state.download_full_state_data]
    sorts: [dim_state.download_full_state_data]
    limit: 1
    show_single_value_title: false
    show_comparison: false
    listen:
      state: dim_state.state_name
    row: 4
    col: 0
    width: 24
    height: 2

  - name: dl_district_summary
    title: "District summary"
    type: looker_grid
    tab_name: Download data
    model: state_dashboard
    explore: fact_batch_activity
    fields: [dim_state.state_name, district_map.district_label, district_map.reported_as, district_map.district_download,
             fact_batch_activity.smt_trained, fact_batch_activity.smt_batches, fact_batch_activity.one_day_batches,
             fact_batch_activity.one_day_trained]
    sorts: [district_map.district_label]
    limit: 500
    column_order: [dim_state.state_name, district_map.district_label, district_map.reported_as, fact_batch_activity.smt_trained,
                   fact_batch_activity.smt_batches, fact_batch_activity.one_day_batches, fact_batch_activity.one_day_trained,
                   district_map.district_download]
    show_row_numbers: false
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      dim_state.state_name: "State"
      district_map.district_label: "District"
      district_map.reported_as: "As reported"
      district_map.district_download: "Download"
      fact_batch_activity.smt_trained: "Total SMTs"
      fact_batch_activity.smt_batches: "SMT training batches"
      fact_batch_activity.one_day_batches: "Batches taken by SMTs"
      fact_batch_activity.one_day_trained: "1-Day Trained"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 6
    col: 0
    width: 24
    height: 9

  - name: dl_full_state_data
    title: "Full state data"
    type: looker_grid
    tab_name: Download data
    model: state_dashboard
    explore: fact_batch_activity
    fields: [fact_batch_activity.activity_id, dim_state.state_name, district_map.district_label, district_map.reported_name,
             dim_group.group_name, dim_designation.designation_name, fact_batch_activity.batch_type,
             fact_batch_activity.batch_date, fact_batch_activity.batch_month, fact_batch_activity.implementation_status,
             fact_batch_activity.data_source, fact_batch_activity.participants_trained, fact_batch_activity.batch_count]
    sorts: [district_map.district_label, fact_batch_activity.batch_date]
    limit: 5000
    show_row_numbers: true
    show_view_names: false
    table_theme: white
    limit_displayed_rows: false
    series_labels:
      fact_batch_activity.activity_id: "Record ID"
      dim_state.state_name: "State"
      district_map.district_label: "District"
      district_map.reported_name: "District as reported"
      dim_group.group_name: "Group"
      dim_designation.designation_name: "Designation"
      fact_batch_activity.batch_type: "Programme"
      fact_batch_activity.batch_date: "Batch date"
      fact_batch_activity.batch_month: "Month"
      fact_batch_activity.implementation_status: "Status"
      fact_batch_activity.data_source: "Data source"
      fact_batch_activity.participants_trained: "Participants"
      fact_batch_activity.batch_count: "Batches"
    listen:
      state: dim_state.state_name
      district: district_map.district_label
      batch_date: fact_batch_activity.batch_date
    row: 15
    col: 0
    width: 24
    height: 14
