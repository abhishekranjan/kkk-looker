# ============================================================================
# Core views over the kkk_dataset BigQuery dataset.
# Table and column names match the load files in bigquery_load/.
#
# Replace `kkk_dataset` below if the dataset lands under a different name.
#
# MAPS: dim_state.state_name carries map_layer_name: india_states. The
# national dashboard draws it with the Static Map (Regions) chart, which
# renders ONLY the TopoJSON (official Survey of India outline) and no
# third-party basemap, so no disputed-border lines appear.
#
# Every field used by the state model / state dashboard is kept as-is.
# ============================================================================

view: dim_state {
  sql_table_name: kkk_dataset.dim_state ;;

  dimension: state_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.state_id ;;
  }

  dimension: state_name {
    type: string
    sql: ${TABLE}.state_name ;;
    label: "State / UT"
    map_layer_name: india_states
    link: {
      label: "Open {{ value }} in the State Drill-down tab"
      url: "/dashboards/central_dashboard::central_dashboard?Drill-down+State={{ value | url_encode }}"
    }
  }

  dimension: zone {
    type: string
    sql: ${TABLE}.zone ;;
    label: "Zone"
    order_by_field: zone_sort
  }

  dimension: zone_sort {
    type: number
    hidden: yes
    sql: CASE ${TABLE}.zone WHEN 'North' THEN 1 WHEN 'South' THEN 2 WHEN 'East' THEN 3 WHEN 'West' THEN 4 ELSE 5 END ;;
  }

  dimension: state_type {
    type: string
    sql: ${TABLE}.state_type ;;
    label: "State or UT"
  }

  dimension: programme_coordinator {
    type: string
    sql: ${TABLE}.programme_coordinator ;;
    label: "Programme coordinator"
  }

  dimension: latitude {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;;
  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "State location"
  }

  dimension: has_started {
    type: string
    hidden: yes
    sql: ${TABLE}.has_started ;;
  }

  # State dashboard, "Download data" tab: one-click link to the full state
  # data in Explore (Download > Excel from there).
  dimension: download_full_state_data {
    type: string
    sql: ${state_name} ;;
    label: "Download full state data"
    html: <a href="/explore/state_dashboard/fact_batch_activity?fields=fact_batch_activity.activity_id,dim_state.state_name,district_map.district_label,district_map.reported_name,dim_group.group_name,dim_designation.designation_name,fact_batch_activity.batch_type,fact_batch_activity.batch_date,fact_batch_activity.batch_month,fact_batch_activity.implementation_status,fact_batch_activity.data_source,fact_batch_activity.participants_trained,fact_batch_activity.batch_count&amp;f[dim_state.state_name]={{ value | url_encode }}&amp;sorts=district_map.district_label,fact_batch_activity.batch_date&amp;limit=5000" target="_blank" style="color:#1D3557;font-weight:600;font-size:18px;">&#11015; Open full {{ value }} data in Explore</a> ;;
  }

  measure: count_all {
    type: count_distinct
    sql: ${state_id} ;;
    label: "States and UTs"
  }

  measure: count_started {
    type: count_distinct
    sql: ${state_id} ;;
    filters: [has_started: "Y"]
    label: "States and UTs started"
  }
}

view: dim_district {
  sql_table_name: kkk_dataset.dim_district ;;

  dimension: district_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.district_id ;;
  }

  dimension: district_name {
    type: string
    sql: COALESCE(${TABLE}.district_name, 'District not recorded') ;;
    label: "District"
    map_layer_name: india_districts
  }

  dimension: state_id {
    type: string
    hidden: yes
    sql: ${TABLE}.state_id ;;
  }

  dimension: latitude {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;;
  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "District location"
  }
}

view: dim_group {
  sql_table_name: kkk_dataset.dim_group ;;

  dimension: group_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.group_id ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}.group_name ;;
    label: "Service group"
    order_by_field: group_sort_order
  }

  dimension: group_sort_order {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.group_sort_order AS INT64) ;;
  }
}

view: dim_designation {
  sql_table_name: kkk_dataset.dim_designation ;;

  dimension: designation_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.designation_id ;;
  }

  dimension: designation_name {
    type: string
    sql: ${TABLE}.designation_name ;;
    label: "Designation"
  }

  dimension: group_id {
    type: string
    hidden: yes
    sql: ${TABLE}.group_id ;;
  }

  dimension: trainee_count {
    type: number
    sql: SAFE_CAST(${TABLE}.trainee_count AS INT64) ;;
  }
}

view: dim_date {
  sql_table_name: kkk_dataset.dim_date ;;

  dimension: date {
    primary_key: yes
    type: date
    datatype: date
    # The CSV load typed these columns as STRING in BigQuery, so cast here.
    sql: SAFE_CAST(${TABLE}.date_day AS DATE) ;;
    label: "Date"
  }

  dimension: month {
    type: string
    sql: ${TABLE}.month_id ;;
    label: "Month"
  }

  dimension: month_label {
    type: string
    sql: ${TABLE}.month_label ;;
    label: "Month label"
    order_by_field: month
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}.month_name ;;
    label: "Month name"
  }

  dimension: fiscal_phase {
    type: string
    sql: ${TABLE}.fiscal_phase ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}.quarter ;;
  }
}

# ----------------------------------------------------------------------------

view: fact_batch_activity {
  sql_table_name: kkk_dataset.fact_batch_activity ;;

  dimension: activity_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.activity_id ;;
  }

  dimension: state_id {
    type: string
    hidden: yes
    sql: ${TABLE}.state_id ;;
  }

  dimension: district_id {
    type: string
    hidden: yes
    sql: ${TABLE}.district_id ;;
  }

  dimension: designation_id {
    type: string
    hidden: yes
    sql: ${TABLE}.designation_id ;;
  }

  dimension: group_id {
    type: string
    hidden: yes
    sql: ${TABLE}.group_id ;;
  }

  dimension: batch_type {
    type: string
    sql: ${TABLE}.batch_type ;;
    label: "Programme"
  }

  dimension: batch_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.batch_date AS DATE) ;;
    label: "Batch date"
  }

  # State dashboard: month buckets for the "By month" table and the export.
  dimension: batch_month {
    type: date_month
    datatype: date
    sql: SAFE_CAST(${TABLE}.batch_date AS DATE) ;;
    label: "Batch month"
  }

  dimension: participants_value {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
  }

  dimension: month_id {
    type: string
    hidden: yes
    sql: ${TABLE}.month_id ;;
  }

  dimension: implementation_status {
    type: string
    sql: ${TABLE}.implementation_status ;;
    label: "Status"
  }

  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
    label: "Data source"
    description: "REPORTED, REPORTED TOTAL DEMO SPLIT, or DEMO. Filter on this to show only real figures."
  }

  dimension: status_rank {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.implementation_status_rank AS INT64) ;;
  }

  measure: implementation_status_rank {
    type: max
    sql: ${status_rank} ;;
    label: "Status rank"
  }

  measure: participants_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    label: "Participants trained"
    value_format_name: decimal_0
  }

  measure: batch_count {
    type: sum
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    label: "Batches"
    value_format_name: decimal_0
  }

  measure: smt_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "SMT"]
    label: "SMTs trained"
    value_format_name: decimal_0
  }

  measure: smt_batches {
    type: sum
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    filters: [batch_type: "SMT"]
    label: "SMT batches (2-day)"
    value_format_name: decimal_0
  }

  measure: one_day_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "One-Day"]
    label: "One-Day participants trained"
    value_format_name: decimal_0
  }

  measure: one_day_batches {
    type: sum
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    filters: [batch_type: "One-Day"]
    label: "One-Day batches"
    value_format_name: decimal_0
  }

  # The Sheet has no SLT certification feed. The demo SLT rows were removed
  # from the load, so this returns NULL (never a guessed number).
  measure: slt_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "SLT"]
    label: "State lead trainers certified"
  }

  # ---- State dashboard measures --------------------------------------------

  measure: avg_one_day_per_batch {
    type: number
    sql: SAFE_DIVIDE(${one_day_trained}, NULLIF(${one_day_batches}, 0)) ;;
    label: "One-Day participants per batch"
    value_format_name: decimal_1
  }

  measure: districts_with_one_day {
    type: count_distinct
    sql: CASE WHEN ${participants_value} > 0 THEN ${district_id} END ;;
    filters: [batch_type: "One-Day"]
    label: "Districts with One-Day training"
    value_format_name: decimal_0
  }

  # Respects whatever programme filter the tile / query applies.
  measure: designations_trained {
    type: count_distinct
    sql: CASE WHEN ${participants_value} > 0 THEN ${designation_id} END ;;
    label: "Designations trained"
    value_format_name: decimal_0
  }

  # Real SLT figures only - DEMO rows are never counted. Shows "Pending"
  # until a reported SLT feed exists (the sum is NULL with no rows).
  measure: slt_certified {
    type: sum
    sql: ${participants_value} ;;
    filters: [batch_type: "SLT", data_source: "-DEMO"]
    label: "State lead trainers certified"
    value_format_name: decimal_0
    html: {% if value == nil %}<span style="color:#707A88;">Pending</span>{% else %}{{ rendered_value }}{% endif %} ;;
  }

  # Count of DEMO SLT placeholder rows still in the load (should be 0).
  measure: slt_demo_placeholder {
    type: count
    filters: [batch_type: "SLT", data_source: "DEMO"]
    label: "SLT demo placeholder rows"
  }

  measure: pct_of_programme_target {
    type: number
    sql: ${one_day_trained} / 13000000.0 ;;
    value_format: "0.000%"
    label: "Share of the 1.3 crore target"
  }
}

view: fact_monthly_target {
  sql_table_name: kkk_dataset.fact_monthly_target ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.state_id, '-', ${TABLE}.month_id) ;;
  }

  dimension: state_id {
    type: string
    hidden: yes
    sql: ${TABLE}.state_id ;;
  }

  dimension: month_id {
    type: string
    hidden: yes
    sql: ${TABLE}.month_id ;;
  }

  dimension: month_label {
    type: string
    sql: ${TABLE}.month_label ;;
    label: "Month"
    order_by_field: month_id
  }

  dimension: target_basis {
    type: string
    sql: ${TABLE}.target_basis ;;
  }

  dimension: headcount_basis {
    type: string
    sql: ${TABLE}.headcount_basis ;;
    label: "SMT headcount target basis"
    description: "SHEET = the value written in the Sheet; DERIVED = batches x 35 (the Sheet's own ratio for Aug and Sep)."
  }

  # The Sheet's month columns are BATCH targets (Aug'26 = 3 for UP, etc.).
  measure: smt_target {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_target AS INT64) ;;
    label: "SMT batch target"
    value_format_name: decimal_0
  }

  measure: smt_target_headcount {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_target_headcount AS INT64) ;;
    label: "SMT headcount target"
    value_format_name: decimal_0
  }

  # DEMO split of the Sheet's single cumulative figure. Kept for the state
  # dashboard; the national dashboard uses fact_state_snapshot instead.
  measure: smt_actual {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_actual AS INT64) ;;
    label: "Actual (demo monthly split)"
    value_format_name: decimal_0
  }

  # Requirement columns are non-zero on the 2026-04 row only, so SUM is correct.
  measure: smt_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_required AS INT64) ;;
    label: "Minimum Total SMTs Reqd"
    value_format_name: decimal_0
  }

  measure: smt_batches_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_batches_required AS INT64) ;;
    label: "Minimum Total SMT Batches Reqd"
    value_format_name: decimal_0
  }

  measure: slt_batches_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.slt_batches_required AS INT64) ;;
    label: "Lead trainer batches required"
    value_format_name: decimal_0
  }

  measure: slt_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.slt_required AS INT64) ;;
    label: "Minimum Total SLTs Reqd"
    value_format_name: decimal_0
  }

  measure: frontline_target {
    type: sum
    sql: SAFE_CAST(${TABLE}.frontline_target AS INT64) ;;
    label: "Minimum Target Frontline Workers"
    value_format_name: decimal_0
  }

  measure: smt_outstanding {
    type: number
    sql: ${smt_required} - ${smt_actual} ;;
    label: "Still to certify"
    value_format_name: decimal_0
  }

  measure: pct_smt_certified {
    type: number
    sql: SAFE_DIVIDE(${smt_actual}, NULLIF(${smt_required}, 0)) * 100 ;;
    label: "Percent certified"
    value_format_name: decimal_1
  }
}

view: fact_assessment {
  sql_table_name: kkk_dataset.fact_assessment ;;

  dimension: assessment_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.assessment_id ;;
  }

  dimension: state_id {
    type: string
    hidden: yes
    sql: ${TABLE}.state_id ;;
  }

  dimension: programme_type {
    type: string
    sql: ${TABLE}.programme_type ;;
    label: "Programme"
  }

  dimension: assessment_date {
    type: date
    datatype: date
    hidden: yes
    sql: SAFE_CAST(${TABLE}.assessment_date AS DATE) ;;
  }

  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
    label: "Data source"
  }

  dimension: baseline_score_value {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.avg_baseline_score AS FLOAT64) ;;
  }

  dimension: day1_score_value {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.avg_day1_score AS FLOAT64) ;;
  }

  dimension: participants_value {
    type: number
    hidden: yes
    sql: SAFE_CAST(${TABLE}.participants_assessed AS INT64) ;;
  }

  measure: avg_baseline_score {
    type: average
    sql: ${baseline_score_value} ;;
    value_format_name: decimal_1
    label: "Baseline"
  }

  measure: avg_day1_score {
    type: average
    sql: ${day1_score_value} ;;
    value_format_name: decimal_1
    label: "Day 1"
  }

  measure: avg_improvement {
    type: average
    sql: ${day1_score_value} - ${baseline_score_value} ;;
    value_format_name: decimal_1
    label: "Improvement"
  }

  measure: improvement_pct {
    type: number
    sql: SAFE_DIVIDE(${avg_day1_score} - ${avg_baseline_score}, NULLIF(${avg_baseline_score}, 0)) ;;
    value_format_name: percent_1
    label: "Improvement (% of baseline)"
  }

  # Participant-weighted versions: a batch of 900 counts more than a batch of 40.
  measure: baseline_points {
    type: sum
    hidden: yes
    sql: ${baseline_score_value} * ${participants_value} ;;
  }

  measure: day1_points {
    type: sum
    hidden: yes
    sql: ${day1_score_value} * ${participants_value} ;;
  }

  measure: weighted_baseline_score {
    type: number
    sql: SAFE_DIVIDE(${baseline_points}, NULLIF(${participants_assessed}, 0)) ;;
    value_format_name: decimal_1
    label: "Baseline score (weighted)"
  }

  measure: weighted_day1_score {
    type: number
    sql: SAFE_DIVIDE(${day1_points}, NULLIF(${participants_assessed}, 0)) ;;
    value_format_name: decimal_1
    label: "Day-1 score (weighted)"
  }

  measure: weighted_improvement {
    type: number
    sql: ${weighted_day1_score} - ${weighted_baseline_score} ;;
    value_format: "+0.0;-0.0;0.0"
    label: "Improvement, baseline to day 1 (points)"
  }

  measure: certified_count {
    type: sum
    sql: SAFE_CAST(${TABLE}.certified_count AS INT64) ;;
    label: "Certified"
    value_format_name: decimal_0
  }

  measure: not_certified_count {
    type: sum
    sql: SAFE_CAST(${TABLE}.not_certified_count AS INT64) ;;
    label: "Not certified"
    value_format_name: decimal_0
  }

  measure: participants_assessed {
    type: sum
    sql: ${participants_value} ;;
    label: "Participants assessed"
    value_format_name: decimal_0
  }

  measure: certification_rate {
    type: number
    sql: SAFE_DIVIDE(${certified_count}, NULLIF(${certified_count} + ${not_certified_count}, 0)) ;;
    value_format_name: percent_1
    label: "Certification rate"
  }
}
