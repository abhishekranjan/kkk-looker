# ============================================================================
# Views over the kkk_dataset BigQuery dataset.
# Table names and column names match the load workbook exactly, so nothing
# here needs renaming once the sheets are uploaded.
#
# Replace `kkk_dataset` below if the dataset lands under a different name.
#
# MAPS: dim_state.location and dim_district.location are type: location, built
# from the latitude/longitude columns. That makes both map tiles work as point
# maps with nothing to upload.
#
# For a filled choropleth of India instead, add an India states TopoJSON to the
# project and declare it in manifest.lkml:
#
#   map_layer: india_states {
#     file: "india_states.topojson"
#     property_key: "ST_NM"          # whichever property holds the state name
#   }
#
# then put `map_layer_name: india_states` on dim_state.state_name and point the
# map tile at that dimension instead of location.
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
    # map_layer_name: india_states   # uncomment after uploading the TopoJSON
  }
  dimension: zone       { type: string sql: ${TABLE}.zone ;; }
  dimension: state_type { type: string sql: ${TABLE}.state_type ;; label: "State or UT" }
  dimension: programme_coordinator { type: string sql: ${TABLE}.programme_coordinator ;; }

  dimension: latitude  { type: number sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;; hidden: yes }
  dimension: longitude { type: number sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;; hidden: yes }
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "State location"
  }
  dimension: has_started { type: string sql: ${TABLE}.has_started ;; hidden: yes }

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
  dimension: district_id   { primary_key: yes hidden: yes type: string sql: ${TABLE}.district_id ;; }
  dimension: district_name { type: string sql: ${TABLE}.district_name ;; label: "District" }
  dimension: state_id      { type: string sql: ${TABLE}.state_id ;; hidden: yes }

  dimension: latitude  { type: number sql: SAFE_CAST(${TABLE}.latitude AS FLOAT64) ;; hidden: yes }
  dimension: longitude { type: number sql: SAFE_CAST(${TABLE}.longitude AS FLOAT64) ;; hidden: yes }
  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
    label: "District location"
  }
}

view: dim_group {
  sql_table_name: kkk_dataset.dim_group ;;
  dimension: group_id   { primary_key: yes hidden: yes type: string sql: ${TABLE}.group_id ;; }
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
  sql_table_name: kkk_dataset.dim_designation ;;
  dimension: designation_id   { primary_key: yes hidden: yes type: string sql: ${TABLE}.designation_id ;; }
  dimension: designation_name { type: string sql: ${TABLE}.designation_name ;; label: "Designation" }
  dimension: group_id         { type: string sql: ${TABLE}.group_id ;; hidden: yes }
  dimension: trainee_count    { type: number sql: SAFE_CAST(${TABLE}.trainee_count AS INT64) ;; }
}

view: dim_date {
  sql_table_name: kkk_dataset.dim_date ;;
  dimension: date {
    primary_key: yes
    type: date
    datatype: date
    # The CSV load typed these columns as STRING in BigQuery, so cast here.
    # If you later reload the tables as real DATE columns, the cast is a no-op.
    sql: SAFE_CAST(${TABLE}.date_day AS DATE) ;;
    label: "Date"
  }
  dimension: month       { type: string sql: ${TABLE}.month_id ;; label: "Month" }
  dimension: month_label { type: string sql: ${TABLE}.month_label ;; }
  dimension: month_name  { type: string sql: ${TABLE}.month_name ;; label: "Month name" }
  dimension: fiscal_phase { type: string sql: ${TABLE}.fiscal_phase ;; }
  dimension: quarter      { type: string sql: ${TABLE}.quarter ;; }
}

# ----------------------------------------------------------------------------

view: fact_batch_activity {
  sql_table_name: kkk_dataset.fact_batch_activity ;;

  dimension: activity_id { primary_key: yes hidden: yes type: string sql: ${TABLE}.activity_id ;; }
  dimension: state_id       { type: string sql: ${TABLE}.state_id ;; hidden: yes }
  dimension: district_id    { type: string sql: ${TABLE}.district_id ;; hidden: yes }
  dimension: designation_id { type: string sql: ${TABLE}.designation_id ;; hidden: yes }
  dimension: group_id       { type: string sql: ${TABLE}.group_id ;; hidden: yes }

  dimension: batch_type { type: string sql: ${TABLE}.batch_type ;; label: "Programme" }
  dimension: batch_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.batch_date AS DATE) ;;
  }
  dimension: month_id   { type: string sql: ${TABLE}.month_id ;; hidden: yes }
  dimension: implementation_status { type: string sql: ${TABLE}.implementation_status ;; label: "Status" }
  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
    label: "Data source"
    description: "REPORTED, REPORTED TOTAL DEMO SPLIT, or DEMO. Filter on this to show only real figures."
  }
  dimension: status_rank { type: number sql: SAFE_CAST(${TABLE}.implementation_status_rank AS INT64) ;; hidden: yes }

  measure: implementation_status_rank {
    type: max
    sql: ${status_rank} ;;
    label: "Status rank"
  }
  measure: participants_trained { type: sum sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;; label: "Participants trained" }
  measure: batch_count          { type: sum sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;          label: "Batches" }

  measure: smt_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "SMT"]
    label: "Master trainers certified"
  }
  measure: smt_batches {
    type: sum
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    filters: [batch_type: "SMT"]
    label: "Trainer batches"
  }
  measure: one_day_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "One-Day"]
    label: "One-day participants"
  }
  measure: one_day_batches {
    type: sum
    sql: SAFE_CAST(${TABLE}.batch_count AS INT64) ;;
    filters: [batch_type: "One-Day"]
    label: "One-day batches"
  }
  # DEMO. The source tracks no SLT certification at all - these rows carry
  # data_source = 'DEMO'. Delete them from the table to show SLT as pending.
  measure: slt_trained {
    type: sum
    sql: SAFE_CAST(${TABLE}.participants_trained AS INT64) ;;
    filters: [batch_type: "SLT"]
    label: "State lead trainers certified"
  }

  measure: pct_of_programme_target {
    type: number
    sql: ${one_day_trained} / 13000000.0 ;;
    value_format_name: percent_2
    label: "Share of the 1.3 crore target"
  }
}

view: fact_monthly_target {
  sql_table_name: kkk_dataset.fact_monthly_target ;;

  dimension: pk {
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.state_id, '-', ${TABLE}.month_id) ;;
  }
  dimension: state_id { type: string sql: ${TABLE}.state_id ;; hidden: yes }
  dimension: month_id { type: string sql: ${TABLE}.month_id ;; hidden: yes }
  dimension: target_basis { type: string sql: ${TABLE}.target_basis ;; }

  measure: smt_target { type: sum sql: SAFE_CAST(${TABLE}.smt_target AS INT64) ;; label: "Target" }
  measure: smt_actual { type: sum sql: SAFE_CAST(${TABLE}.smt_actual AS INT64) ;; label: "Actual" }

  # Non-zero on the 2026-04 row only, so SUM gives the true requirement.
  measure: smt_required     { type: sum sql: SAFE_CAST(${TABLE}.smt_required AS INT64) ;;     label: "Master trainers required" }
  measure: smt_batches_required { type: sum sql: SAFE_CAST(${TABLE}.smt_batches_required AS INT64) ;; label: "Trainer batches required" }
  measure: slt_batches_required { type: sum sql: SAFE_CAST(${TABLE}.slt_batches_required AS INT64) ;; label: "Lead trainer batches required" }
  measure: slt_required     { type: sum sql: SAFE_CAST(${TABLE}.slt_required AS INT64) ;;     label: "Lead trainers required" }
  measure: frontline_target { type: sum sql: SAFE_CAST(${TABLE}.frontline_target AS INT64) ;; label: "Frontline target" }

  measure: smt_outstanding {
    type: number
    sql: ${smt_required} - ${smt_actual} ;;
    label: "Still to certify"
  }
  measure: pct_smt_certified {
    type: number
    sql: SAFE_DIVIDE(${smt_actual}, NULLIF(${smt_required}, 0)) * 100 ;;
    label: "Percent certified"
  }
}

view: fact_assessment {
  sql_table_name: kkk_dataset.fact_assessment ;;

  dimension: assessment_id { primary_key: yes hidden: yes type: string sql: ${TABLE}.assessment_id ;; }
  dimension: state_id       { type: string sql: ${TABLE}.state_id ;; hidden: yes }
  dimension: programme_type { type: string sql: ${TABLE}.programme_type ;; label: "Programme" }
  dimension: assessment_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.assessment_date AS DATE) ;;
    hidden: yes
  }
  dimension: data_source { type: string sql: ${TABLE}.data_source ;; }

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
  measure: certified_count     { type: sum sql: SAFE_CAST(${TABLE}.certified_count AS INT64) ;;     label: "Certified" }
  measure: not_certified_count { type: sum sql: SAFE_CAST(${TABLE}.not_certified_count AS INT64) ;; label: "Not certified" }
  measure: participants_assessed { type: sum sql: SAFE_CAST(${TABLE}.participants_assessed AS INT64) ;; }
}
