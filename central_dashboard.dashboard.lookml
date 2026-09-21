# Section B — National Implementation Dashboard (CBC, unrestricted)
# Karmayogi Kartavya Karyakram
#
# Companion to the design mock. Every element name here matches the
# tile label shown by "Show LookML tile names" in the mock.
#
# Assumes the model/views from the blueprint:
#   explore: fact_batch_activity  (joined to dim_state, dim_district, dim_group, dim_designation, dim_date)
#   explore: fact_monthly_target  (joined to dim_state, dim_date)
#   explore: fact_assessment      (joined to dim_state, dim_date)
#
# This file lives in the CENTRAL model only. The state model never
# includes it, so a State Nodal Officer cannot reach these tiles even
# by URL. Row-level security is enforced in the state model's
# access_filter, not here.

- dashboard: central_dashboard
  title: National Implementation Dashboard
  description: "Capacity Building Commission — every State and UT, no access limits."
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
  # Filters — apply to every tile via listens_to_filters
  # ---------------------------------------------------------------
  filters:
  - name: zone
    title: "Zone"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: checkboxes
      display: popover
    model: central_dashboard
    explore: fact_batch_activity
    field: dim_state.zone

  - name: state
    title: "State / UT"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    model: central_dashboard
    explore: fact_batch_activity
    field: dim_state.state_name

  - name: programme
    title: "Programme"
    type: field_filter
    default_value: ""
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_toggles
      display: inline
    model: central_dashboard
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
    model: central_dashboard
    explore: fact_batch_activity
    field: dim_date.date

  elements:

  # ===============================================================
  # TAB 1 — NATIONAL OVERVIEW  (Box 1 of the spec)
  # ===============================================================

  - title: Programme at a glance
    name: section_header
    type: text
    body_text: |-
      **Programme at a glance** — every State and UT, read from the implementation Sheet.
      Status comes from the batch-details table alone; the counts beside it are read
      separately and never used to infer status.
    row: 0
    col: 0
    width: 24
    height: 2

  - title: State master trainers certified
    name: smt_trained
    model: central_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.smt_trained, fact_batch_activity.smt_batches]
    filters:
      fact_batch_activity.batch_type: "SMT"
    custom_color_enabled: true
    custom_color: "#12233B"
    show_single_value_title: true
    single_value_title: "State master trainers certified"
    comparison_label: "batches · 2-day programme"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
      date_range: dim_date.date
    row: 2
    col: 0
    width: 6
    height: 3

  - title: One-day participants trained
    name: one_day_participants
    model: central_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.one_day_trained, fact_batch_activity.one_day_batches]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    single_value_title: "One-day participants trained"
    comparison_label: "batches"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
      date_range: dim_date.date
    row: 2
    col: 6
    width: 6
    height: 3

  - title: States and UTs with trainers certified
    name: states_started
    model: central_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [dim_state.count_started, dim_state.count_all]
    single_value_title: "States and UTs with trainers certified"
    comparison_label: "of 36"
    comparison_type: progress_percentage
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      zone: dim_state.zone
      date_range: dim_date.date
    row: 2
    col: 12
    width: 6
    height: 3

  - title: Progress against the trainer requirement
    name: smt_vs_requirement
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.pct_smt_certified, fact_monthly_target.smt_outstanding]
    single_value_title: "Of the trainers the rollout needs"
    comparison_label: "still to certify"
    value_format: '0.0\%'
    custom_color_enabled: true
    custom_color: "#AD7C25"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 2
    col: 18
    width: 6
    height: 3

  # --- Point map from dim_state.location (latitude/longitude). To switch
  # --- to a filled choropleth later: add india_states.topojson + manifest,
  # --- then change fields to [dim_state.state_name, ...] and drop
  # --- map_plot_mode.
  - title: Implementation status
    name: implementation_status_by_state
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_map
    fields: [dim_state.location, dim_state.state_name, fact_batch_activity.implementation_status_rank]
    map_plot_mode: points
    map_position: fit_data
    map_scale_indicator: "off"
    map_value_colors: ["#D9D5C9", "#AD7C25", "#2F7D57"]
    hidden_pivots: {}
    note_state: collapsed
    note_display: below
    note_text: "Grey — not started · amber — trainers certified only · green — one-day training under way. Click a state to cross-filter the page."
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 5
    col: 0
    width: 11
    height: 10

  - title: Progress to 1.3 crore officials
    name: target_tracker
    model: central_dashboard
    explore: fact_batch_activity
    type: single_value
    fields: [fact_batch_activity.one_day_trained, fact_batch_activity.pct_of_programme_target]
    filters:
      fact_batch_activity.batch_type: "One-Day"
    single_value_title: "Progress to 1.3 crore officials"
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: "of 1,30,00,000"
    custom_color_enabled: true
    custom_color: "#D97B34"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
      date_range: dim_date.date
    row: 5
    col: 11
    width: 7
    height: 5

  - title: Zone comparison — trainers and participants
    name: zone_comparison
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_column
    fields: [dim_state.zone, fact_batch_activity.smt_trained, fact_batch_activity.one_day_trained]
    sorts: [dim_state.zone]
    series_colors:
      fact_batch_activity.smt_trained: "#1D3557"
      fact_batch_activity.one_day_trained: "#D97B34"
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    legend_position: center
    listen:
      state: dim_state.state_name
      date_range: dim_date.date
    row: 10
    col: 11
    width: 7
    height: 5

  - title: Top 10 · one-day participants
    name: top_10_states_participants
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_bar
    fields: [dim_state.state_name, fact_batch_activity.one_day_trained]
    filters:
      fact_batch_activity.batch_type: "One-Day"
      fact_batch_activity.one_day_trained: ">0"
    sorts: [fact_batch_activity.one_day_trained desc]
    limit: 10
    series_colors:
      fact_batch_activity.one_day_trained: "#1D3557"
    show_value_labels: true
    x_axis_gridlines: false
    hide_legend: true
    listen:
      zone: dim_state.zone
      date_range: dim_date.date
    row: 5
    col: 18
    width: 6
    height: 10

  # --- Two-series monthly trend (Box 1: "Certification Trend — split
  # --- by programme"). Driven by fact_batch_activity.batch_date.
  - title: Batches certified by month
    name: certification_trend_by_programme
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_line
    fields: [dim_date.month_name, fact_batch_activity.batch_count, fact_batch_activity.batch_type]
    pivots: [fact_batch_activity.batch_type]
    sorts: [dim_date.month_name]
    series_colors:
      SMT - fact_batch_activity.batch_count: "#1D3557"
      One-Day - fact_batch_activity.batch_count: "#D97B34"
    point_style: circle
    interpolation: linear
    y_axis_gridlines: true
    x_axis_gridlines: false
    note_state: expanded
    note_display: below
    note_text: "Batches by month of batch date. Dates are partly demo where the source had none."
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 15
    col: 0
    width: 14
    height: 7

  - title: By zone
    name: zone_summary
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_grid
    fields: [dim_state.zone, dim_state.count_all, dim_state.count_started,
             fact_batch_activity.smt_trained, fact_batch_activity.one_day_trained]
    sorts: [dim_state.zone]
    show_totals: true
    show_row_totals: false
    table_theme: transparent
    limit_displayed_rows: false
    listen:
      date_range: dim_date.date
    row: 15
    col: 14
    width: 10
    height: 7

  - title: Every State and UT
    name: every_state_detail
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_grid
    fields: [dim_state.state_name, dim_state.zone, dim_state.state_type,
             fact_batch_activity.smt_trained, fact_batch_activity.smt_batches,
             fact_batch_activity.one_day_trained, fact_batch_activity.one_day_batches,
             fact_monthly_target.smt_required, fact_batch_activity.implementation_status]
    sorts: [fact_batch_activity.one_day_trained desc]
    show_totals: true
    table_theme: editable
    limit_displayed_rows: false
    # conditional formatting mirrors the map's three states
    conditional_formatting:
    - type: equal to
      value: "One-day under way"
      background_color: "#CFE7D9"
      font_color: "#2F7D57"
      bold: false
      italic: false
      strikethrough: false
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
      zone: dim_state.zone
      state: dim_state.state_name
      programme: fact_batch_activity.batch_type
      date_range: dim_date.date
    row: 22
    col: 0
    width: 24
    height: 10

  # ===============================================================
  # TAB 2 — MONTHLY SMT TARGETS  (CBC only)
  # Put these on a second dashboard tab, or keep as a separate
  # dashboard file if your Looker version predates dashboard tabs.
  # ===============================================================

  - title: Monthly trainer targets
    name: targets_header
    type: text
    body_text: |-
      **Monthly trainer targets** — straight from the target tab of the Sheet.
      Columns are labelled exactly as the Sheet names them. The Sheet has no
      March 2027 column, so March is handled on the roadmap tab instead.
    row: 32
    col: 0
    width: 24
    height: 2

  - title: Trainers targeted in August
    name: august_target
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.smt_target]
    filters:
      dim_date.month: "2026-08"
    value_format: "#,##0"
    custom_color_enabled: true
    custom_color: "#12233B"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 34
    col: 0
    width: 6
    height: 3

  - title: Trained to end of August
    name: august_actual
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.smt_actual, fact_monthly_target.smt_target]
    filters:
      dim_date.month: "2026-08"
    comparison_type: progress_percentage
    comparison_label: "of the August target"
    custom_color_enabled: true
    custom_color: "#2F7D57"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 34
    col: 6
    width: 6
    height: 3

  - title: Targeted in September
    name: september_target
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.smt_target]
    filters:
      dim_date.month: "2026-09"
    custom_color_enabled: true
    custom_color: "#D97B34"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 34
    col: 12
    width: 6
    height: 3

  - title: Trainers required by Mar '27
    name: total_requirement
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.smt_required, fact_monthly_target.smt_outstanding]
    comparison_label: "outstanding"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 34
    col: 18
    width: 6
    height: 3

  - title: August · target against actual
    name: august_target_vs_actual
    model: central_dashboard
    explore: fact_monthly_target
    type: looker_bar
    fields: [dim_state.state_name, fact_monthly_target.smt_target, fact_monthly_target.smt_actual]
    filters:
      dim_date.month: "2026-08"
      fact_monthly_target.smt_target: ">0"
    sorts: [fact_monthly_target.smt_target desc]
    series_colors:
      fact_monthly_target.smt_target: "#1D3557"
      fact_monthly_target.smt_actual: "#D97B34"
    show_value_labels: true
    legend_position: center
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 37
    col: 0
    width: 10
    height: 10

  - title: Trainer targets by state and month
    name: monthly_target_pivot
    model: central_dashboard
    explore: fact_monthly_target
    type: looker_grid
    fields: [dim_state.state_name, dim_date.month_name, fact_monthly_target.smt_required, fact_monthly_target.smt_target]
    pivots: [dim_date.month_name]
    sorts: [fact_monthly_target.smt_required desc]
    limit_displayed_rows: false
    table_theme: white
    conditional_formatting:
    - type: along a scale...
      palette:
        name: Custom
        colors: ["#FAF8F3", "#1D3557"]
      applied_to_numbers_only: true
      fields: [fact_monthly_target.smt_target]
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 37
    col: 10
    width: 14
    height: 10

  # ===============================================================
  # TAB 3 — ROADMAP 2027
  # ===============================================================

  - title: Building capacity for March 2027
    name: roadmap_header
    type: text
    body_text: |-
      **Building capacity for March 2027** — lead trainers, master trainers and
      frontline reach required to finish the rollout, with what has been certified
      so far against each.
    row: 47
    col: 0
    width: 24
    height: 2

  - title: State lead trainers
    name: lead_trainers_required
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.slt_required]
    single_value_title: "State lead trainers required by Mar '27"
    value_format: "#,##0"
    note_state: expanded
    note_display: below
    note_text: "No column in the source tracks how many are certified — shown as required only, never as zero trained."
    listen:
      zone: dim_state.zone
    row: 49
    col: 0
    width: 8
    height: 4

  - title: State master trainers
    name: master_trainers_required
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.smt_required, fact_monthly_target.pct_smt_certified]
    comparison_label: "% certified so far"
    comparison_type: value
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
    row: 49
    col: 8
    width: 8
    height: 4

  - title: Frontline reach
    name: frontline_reach
    model: central_dashboard
    explore: fact_monthly_target
    type: single_value
    fields: [fact_monthly_target.frontline_target]
    single_value_title: "Officials in the state plans"
    custom_color_enabled: true
    custom_color: "#D97B34"
    value_format: "#,##0"
    listen:
      zone: dim_state.zone
    row: 49
    col: 16
    width: 8
    height: 4

  - title: Timeline
    name: roadmap_timeline
    type: text
    body_text: |-
      **Aug 2026** — trainers first.  **Sep–Dec 2026** — scale the cascade.
      **Jan–Feb 2027** — close the gap.  **Mar 2027** — full frontline reach.
    row: 53
    col: 0
    width: 24
    height: 3

  - title: Requirement by zone
    name: requirement_by_zone
    model: central_dashboard
    explore: fact_monthly_target
    type: looker_grid
    fields: [dim_state.zone, fact_monthly_target.slt_required,
             fact_monthly_target.smt_required, fact_monthly_target.frontline_target]
    sorts: [fact_monthly_target.frontline_target desc]
    show_totals: true
    table_theme: transparent
    series_cell_visualizations:
      fact_monthly_target.frontline_target:
        is_active: true
    row: 56
    col: 0
    width: 24
    height: 6

  # ===============================================================
  # TAB 4 — ASSESSMENTS  (Boxes 9 and 10 — deliberately separate)
  # ===============================================================

  - title: Assessment and analysis
    name: assessment_header
    type: text
    body_text: |-
      **Assessment and analysis** — the two programmes are assessed separately and
      never merged: a different audience and a different instrument.
    row: 62
    col: 0
    width: 24
    height: 2

  - title: One-day participants — baseline, day-1, improvement
    name: one_day_baseline_vs_day1
    model: central_dashboard
    explore: fact_assessment
    type: looker_column
    fields: [dim_state.state_name, fact_assessment.avg_baseline_score,
             fact_assessment.avg_day1_score, fact_assessment.avg_improvement]
    filters:
      fact_assessment.programme_type: "One-Day"
    sorts: [fact_assessment.avg_improvement desc]
    series_colors:
      fact_assessment.avg_baseline_score: "#D9D5C9"
      fact_assessment.avg_day1_score: "#1D3557"
      fact_assessment.avg_improvement: "#2F7D57"
    legend_position: center
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 64
    col: 0
    width: 12
    height: 7

  - title: Master trainer certification outcome
    name: smt_certification_outcome
    model: central_dashboard
    explore: fact_assessment
    type: looker_column
    fields: [dim_state.state_name, fact_assessment.certified_count, fact_assessment.not_certified_count]
    filters:
      fact_assessment.programme_type: "SMT"
    stacking: normal
    series_colors:
      fact_assessment.certified_count: "#2F7D57"
      fact_assessment.not_certified_count: "#B04435"
    legend_position: center
    note_state: expanded
    note_display: below
    note_text: "Kept on its own tile so participant numbers never dilute the trainer result."
    listen:
      zone: dim_state.zone
      state: dim_state.state_name
    row: 64
    col: 12
    width: 12
    height: 7

  # ===============================================================
  # TAB 5 — FULL DATA EXPORT  (Box 11)
  # One wide grid, no default filters, download enabled.
  # ===============================================================

  - title: Full data export
    name: export_header
    type: text
    body_text: |-
      **Full data export** — every state, department, district, group, designation
      and batch, both assessment types, and the monthly target sheet. No filter
      required first. Download as CSV, Excel or JSON, or schedule it to an inbox.
    row: 71
    col: 0
    width: 24
    height: 2

  - title: Full export
    name: full_export_preview
    model: central_dashboard
    explore: fact_batch_activity
    type: looker_grid
    fields: [dim_state.state_name, dim_state.zone, dim_state.state_type,
             dim_district.district_name, dim_group.group_name, dim_designation.designation_name,
             fact_batch_activity.batch_type, fact_batch_activity.batch_date,
             fact_batch_activity.participants_trained, fact_batch_activity.batch_count,
             fact_batch_activity.implementation_status,
             fact_monthly_target.smt_required, fact_monthly_target.frontline_target,
             fact_assessment.avg_baseline_score, fact_assessment.avg_day1_score]
    sorts: [dim_state.state_name, fact_batch_activity.batch_date desc]
    limit: 5000
    limit_displayed_rows: false
    table_theme: white
    show_row_numbers: true
    row: 73
    col: 0
    width: 24
    height: 12
