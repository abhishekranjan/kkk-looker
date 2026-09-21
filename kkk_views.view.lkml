# ============================================================================
# FILE: kkk_views.view.lkml
# Views over the kkk BigQuery dataset. Shared by BOTH models
# (central_dashboard and state_dashboard) - every field the central dashboard
# uses is kept with the same name.
#
# Dataset name comes from the manifest constant @{kkk_dataset}.
#
# MAPS
#   dim_state.state_name  -> map layer india_states   (property st_nm)
#   district_map.map_key  -> map layer india_districts (property key, "State|District")
#   The State Dashboard itself uses the tile-free custom visualization
#   declared in manifest.lkml, so no base-map tiles are drawn.
# ============================================================================

view: dim_state {
  sql_table_name: @{kkk_dataset}.dim_state ;;

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
  }
  dimension: zone {
    type: string
    sql: ${TABLE}.zone ;;
  }
  dimension: state_type {
    type: string
    sql: ${TABLE}.state_type ;;
    label: "State or UT"
  }
  dimension: programme_coordinator {
    type: string
    sql: ${TABLE}.programme_coordinator ;;
    label: "CBC programme coordinator"
  }
  dimension: implementation_status {
    type: string
    sql: ${TABLE}.implementation_status ;;
    label: "Implementation stage"
    description: "Not started / Trainers only / One-day under way - from dim_state."
  }

  dimension: latitude {
    type: number
    sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;;
    hidden: yes
  }
  dimension: longitude {
    type: number
    sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;;
    hidden: yes
  }
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "State location"
  }
  dimension: has_started {
    type: string
    sql: ${TABLE}.has_started ;;
    hidden: yes
  }

  # Box 1 - "Download Full State Data (Excel)". Opens the selected state's
  # row-level data in an Explore; use the gear menu > Download > Excel there.
  dimension: download_full_state_data {
    type: string
    sql: ${state_name} ;;
    label: "Download full state data"
    html: <a href="/explore/state_dashboard/fact_batch_activity?fields=dim_state.state_name,district_map.district_label,district_map.reported_name,dim_group.group_name,dim_designation.designation_name,fact_batch_activity.batch_type,fact_batch_activity.batch_date,fact_batch_activity.batch_month,fact_batch_activity.implementation_status,fact_batch_activity.data_source,fact_batch_activity.participants_trained,fact_batch_activity.batch_count&amp;f[dim_state.state_name]={{ value | url_encode }}&amp;sorts=district_map.district_label,fact_batch_activity.batch_date&amp;limit=5000" target="_blank" style="display:inline-block;padding:8px 14px;border-radius:4px;background:#12233B;color:#FFFFFF;font-weight:600;text-decoration:none;">&#11015; Download Full {{ value }} Data (Excel)</a> ;;
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
  sql_table_name: @{kkk_dataset}.dim_district ;;

  dimension: district_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.district_id ;;
  }
  dimension: district_name {
    type: string
    sql: ${TABLE}.district_name ;;
    label: "District (as reported)"
    description: "Raw value from the source. Use District (district_map.district_label) for clean, map-matched names."
  }
  dimension: state_id {
    type: string
    sql: ${TABLE}.state_id ;;
    hidden: yes
  }
  dimension: latitude {
    type: number
    sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;;
    hidden: yes
  }
  dimension: longitude {
    type: number
    sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;;
    hidden: yes
  }
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "District location"
  }
}

view: dim_group {
  sql_table_name: @{kkk_dataset}.dim_group ;;

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
    sql: SAFE_CAST(${TABLE}.group_sort_order AS INT64) ;;
    hidden: yes
  }
}

view: dim_designation {
  sql_table_name: @{kkk_dataset}.dim_designation ;;

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
    sql: ${TABLE}.group_id ;;
    hidden: yes
  }
  dimension: trainee_count {
    type: number
    sql: SAFE_CAST(${TABLE}.trainee_count AS INT64) ;;
  }
}

view: dim_date {
  sql_table_name: @{kkk_dataset}.dim_date ;;

  dimension: date {
    primary_key: yes
    type: date
    datatype: date
    # The CSV load typed these columns as STRING in BigQuery, so cast here.
    # If the tables are reloaded with real DATE columns, the cast is a no-op.
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
  sql_table_name: @{kkk_dataset}.fact_batch_activity ;;

  dimension: activity_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.activity_id ;;
    label: "Record ID"
  }
  dimension: state_id {
    type: string
    sql: ${TABLE}.state_id ;;
    hidden: yes
  }
  dimension: district_id {
    type: string
    sql: ${TABLE}.district_id ;;
    hidden: yes
  }
  dimension: designation_id {
    type: string
    sql: ${TABLE}.designation_id ;;
    hidden: yes
  }
  dimension: group_id {
    type: string
    sql: ${TABLE}.group_id ;;
    hidden: yes
  }

  dimension: batch_type {
    type: string
    sql: ${TABLE}.batch_type ;;
    label: "Programme"
    description: "SMT (2-day master trainer programme), One-Day, or SLT."
  }
  dimension: batch_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.batch_date AS DATE) ;;
    label: "Batch date"
  }
  dimension: month_id {
    type: string
    sql: ${TABLE}.month_id ;;
    hidden: yes
  }
  dimension: batch_month {
    type: string
    sql: ${TABLE}.month_id ;;
    label: "Batch month (YYYY-MM)"
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
    description: "REPORTED, 'REPORTED TOTAL, DEMO SPLIT' or 'DEMO - no SLT feed in source'. Rows starting with DEMO are placeholders, not reported figures."
  }
  dimension: is_demo_row {
    type: yesno
    sql: STARTS_WITH(UPPER(COALESCE(${TABLE}.data_source, '')), 'DEMO') ;;
    label: "Is demo placeholder row"
  }
  dimension: status_rank {
    type: number
    sql: SAFE_CAST(${TABLE}.implementation_status_rank AS INT64) ;;
    hidden: yes
  }
  dimension: participants_raw {
    type: number
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    hidden: yes
  }
  dimension: batch_count_raw {
    type: number
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    hidden: yes
  }

  measure: implementation_status_rank {
    type: max
    sql: ${status_rank} ;;
    label: "Status rank"
  }

  # All programmes together (includes SLT demo rows) - use the
  # programme-specific measures below on dashboards.
  measure: participants_trained {
    type: sum
    sql: ${participants_raw} ;;
    label: "Participants trained (all programmes)"
  }
  measure: batch_count {
    type: sum
    sql: ${batch_count_raw} ;;
    label: "Batches (all programmes)"
  }

  # --- SMT: state master trainers (2-day programme) ---
  measure: smt_trained {
    type: sum
    sql: ${participants_raw} ;;
    filters: [batch_type: "SMT"]
    label: "Master trainers certified"
    description: "Total SMTs - participants of SMT batches."
  }
  measure: smt_batches {
    type: sum
    sql: ${batch_count_raw} ;;
    filters: [batch_type: "SMT"]
    label: "Trainer batches"
    description: "Batches of the 2-day SMT programme itself."
  }

  # --- One-day programme (run by SMTs) ---
  measure: one_day_trained {
    type: sum
    sql: ${participants_raw} ;;
    filters: [batch_type: "One-Day"]
    label: "One-day participants"
    description: "1-Day Trained."
  }
  measure: one_day_batches {
    type: sum
    sql: ${batch_count_raw} ;;
    filters: [batch_type: "One-Day"]
    label: "One-day batches"
    description: "Batches taken by SMTs (one-day programme). This is 'Total Batches' in the State Dashboard."
  }
  measure: avg_one_day_per_batch {
    type: number
    sql: ${one_day_trained} / NULLIF(${one_day_batches}, 0) ;;
    value_format_name: decimal_1
    label: "Participants per one-day batch"
  }
  measure: districts_with_one_day {
    type: count_distinct
    sql: ${district_id} ;;
    filters: [batch_type: "One-Day", participants_raw: ">0"]
    label: "Districts with one-day training"
  }
  measure: districts_with_smt {
    type: count_distinct
    sql: ${district_id} ;;
    filters: [batch_type: "SMT", participants_raw: ">0"]
    label: "Districts with certified SMTs"
  }
  measure: designations_trained {
    type: count_distinct
    sql: ${designation_id} ;;
    filters: [batch_type: "One-Day", participants_raw: ">0"]
    label: "Designations reached"
  }

  # --- SLT: state lead trainers ---
  # The source has no SLT feed. The load file carries DEMO placeholder rows;
  # they are EXCLUDED here so the figure reads "Pending", never a guess.
  measure: slt_trained {
    type: sum
    sql: ${participants_raw} ;;
    filters: [batch_type: "SLT"]
    label: "State lead trainers (all rows incl. demo)"
    description: "Kept for the central dashboard. Includes DEMO placeholder rows."
  }
  measure: slt_trained_reported {
    type: sum
    sql: ${participants_raw} ;;
    filters: [batch_type: "SLT", is_demo_row: "no"]
    hidden: yes
  }
  measure: slt_certified {
    type: number
    sql: COALESCE(${slt_trained_reported}, 0) ;;
    value_format_name: decimal_0
    label: "Total SLT"
    description: "State lead trainers certified from reported (non-demo) rows. Shows Pending until a real SLT feed exists."
    html: {% if value > 0 %}{{ rendered_value }}{% else %}<span style="color:#707A88;">Pending</span>{% endif %} ;;
  }
  measure: slt_demo_placeholder {
    type: sum
    sql: ${participants_raw} ;;
    filters: [batch_type: "SLT", is_demo_row: "yes"]
    label: "SLT demo placeholder (not official)"
  }

  measure: pct_of_programme_target {
    type: number
    sql: ${one_day_trained} / 13000000.0 ;;
    value_format_name: percent_2
    label: "Share of the 1.3 crore target"
  }
}

view: fact_monthly_target {
  sql_table_name: @{kkk_dataset}.fact_monthly_target ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.state_id, '-', ${TABLE}.month_id) ;;
  }
  dimension: state_id {
    type: string
    sql: ${TABLE}.state_id ;;
    hidden: yes
  }
  dimension: month_id {
    type: string
    sql: ${TABLE}.month_id ;;
    hidden: yes
  }
  dimension: target_basis {
    type: string
    sql: ${TABLE}.target_basis ;;
  }

  measure: smt_target {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_target AS INT64) ;;
    label: "Target"
  }
  measure: smt_actual {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_actual AS INT64) ;;
    label: "Actual"
    description: "Monthly split of the cumulative SMT total (split is DEMO; the total is real)."
  }

  # Written on the 2026-04 row only, so SUM gives the true requirement.
  measure: smt_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_required AS INT64) ;;
    label: "Master trainers required"
  }
  measure: smt_batches_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.smt_batches_required AS INT64) ;;
    label: "Trainer batches required"
  }
  measure: slt_batches_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.slt_batches_required AS INT64) ;;
    label: "Lead trainer batches required"
  }
  measure: slt_required {
    type: sum
    sql: SAFE_CAST(${TABLE}.slt_required AS INT64) ;;
    label: "Lead trainers required"
  }
  measure: frontline_target {
    type: sum
    sql: SAFE_CAST(${TABLE}.frontline_target AS INT64) ;;
    label: "Frontline target"
  }

  measure: smt_outstanding {
    type: number
    sql: GREATEST(COALESCE(${smt_required}, 0) - COALESCE(${smt_actual}, 0), 0) ;;
    value_format_name: decimal_0
    label: "Still to certify"
  }
  measure: pct_smt_certified {
    type: number
    sql: SAFE_DIVIDE(${smt_actual}, NULLIF(${smt_required}, 0)) * 100 ;;
    value_format_name: decimal_1
    label: "Percent certified"
  }
}

view: fact_assessment {
  sql_table_name: @{kkk_dataset}.fact_assessment ;;

  dimension: assessment_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.assessment_id ;;
  }
  dimension: state_id {
    type: string
    sql: ${TABLE}.state_id ;;
    hidden: yes
  }
  dimension: programme_type {
    type: string
    sql: ${TABLE}.programme_type ;;
    label: "Programme"
  }
  dimension: assessment_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.assessment_date AS DATE) ;;
    label: "Assessment date"
  }
  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
  }

  measure: avg_baseline_score {
    type: average
    sql: SAFE_CAST(${TABLE}.avg_baseline_score AS FLOAT64) ;;
    value_format_name: decimal_1
    label: "Baseline"
  }
  measure: avg_day1_score {
    type: average
    sql: SAFE_CAST(${TABLE}.avg_day1_score AS FLOAT64) ;;
    value_format_name: decimal_1
    label: "Day 1"
  }
  measure: avg_improvement {
    type: average
    sql: SAFE_CAST(${TABLE}.avg_day1_score AS FLOAT64) - SAFE_CAST(${TABLE}.avg_baseline_score AS FLOAT64) ;;
    value_format_name: decimal_1
    label: "Improvement"
  }
  measure: improvement_pct {
    type: number
    sql: SAFE_DIVIDE(${avg_day1_score} - ${avg_baseline_score}, NULLIF(${avg_baseline_score}, 0)) ;;
    value_format_name: percent_1
    label: "Improvement (% of baseline)"
  }
  measure: certified_count {
    type: sum
    sql: SAFE_CAST(${TABLE}.certified_count AS INT64) ;;
    label: "Certified"
  }
  measure: not_certified_count {
    type: sum
    sql: SAFE_CAST(${TABLE}.not_certified_count AS INT64) ;;
    label: "Not certified"
  }
  measure: participants_assessed {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_assessed AS INT64) ;;
    label: "Participants assessed"
  }
}
