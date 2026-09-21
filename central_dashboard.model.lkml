# ============================================================================
# FILE: central_dashboard.model.lkml  (project root)
# Section B — National model. Unrestricted, every State and UT.
# ============================================================================

connection: "prj-kb-prd-looker-gcp-1014"

include: "/**/*.view.lkml"
include: "/**/central_dashboard.dashboard.lookml"

# ---------------------------------------------------------------------------
# Map layers. Defined in the model (not only the manifest) with an absolute
# path, so they resolve no matter which folder this model file sits in.
# ---------------------------------------------------------------------------
map_layer: india_states {
  file: "/india_states.topojson"
  format: topojson
  property_key: "st_nm"
  property_label_key: "st_nm"
}

map_layer: india_districts {
  file: "/india_districts.topojson"
  format: topojson
  property_key: "district"
  property_label_key: "district"
}

# ============================================================================
# Explores the dashboard expects, joined on the surrogate keys from the
# kkk_dataset dataset.
# ============================================================================

explore: fact_batch_activity {
  label: "Batch activity"

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.state_id} = ${dim_state.state_id} ;;
  }

  join: dim_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.batch_date} = ${dim_date.date} ;;
  }

  join: dim_district {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.district_id} = ${dim_district.district_id} ;;
  }

  join: dim_group {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.group_id} = ${dim_group.group_id} ;;
  }

  join: dim_designation {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.designation_id} = ${dim_designation.designation_id} ;;
  }

  # The full-export and state-detail tiles pull target and assessment
  # measures from inside this explore, so both have to be joined here.
  join: fact_monthly_target {
    type: left_outer
    relationship: many_to_many
    sql_on: ${fact_batch_activity.state_id} = ${fact_monthly_target.state_id} ;;
  }

  join: fact_assessment {
    type: left_outer
    relationship: many_to_many
    sql_on: ${fact_batch_activity.state_id} = ${fact_assessment.state_id} ;;
  }
}

explore: fact_monthly_target {
  label: "Monthly targets"

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.state_id} = ${dim_state.state_id} ;;
  }

  join: dim_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.month_id} = ${dim_date.month} ;;
  }
}

explore: fact_assessment {
  label: "Assessments"

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_assessment.state_id} = ${dim_state.state_id} ;;
  }

  join: dim_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_assessment.assessment_date} = ${dim_date.date} ;;
  }
}
