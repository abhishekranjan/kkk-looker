# ============================================================================
# FILE: models/state_dashboard.model.lkml
# Section A - State model.
#
# NO ACCESS RESTRICTION for now: every user can open every state and every
# tab, including assessment. The state is chosen from the dashboard's
# State / UT filter (defaults to Odisha).
#
# To lock it down later, add this block inside each data explore:
#   access_filter: {
#     field: dim_state.state_name
#     user_attribute: assigned_state
#   }
# and create the `assigned_state` user attribute under Admin > User Attributes
# (source: sec_user_state_access.state_name).
# ============================================================================

connection: "prj-kb-prd-looker-gcp-1014"

include: "/**/*.view.lkml"
include: "/**/state_dashboard.dashboard.lookml"

# ---------------------------------------------------------------------------
# Map layers (for Explore users). The dashboard map itself is the tile-free
# custom visualization declared in manifest.lkml.
# india_districts is keyed "State|District" so districts that share a name in
# different states (Aurangabad, Bilaspur, Balrampur, Hamirpur ...) never mix.
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
  property_key: "key"
  property_label_key: "district"
}

explore: fact_batch_activity {
  label: "State activity"
  description: "SMT, one-day and SLT activity by district, group and designation."

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.state_id} = ${dim_state.state_id} ;;
  }
  join: district_map {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.district_id} = ${district_map.district_id} ;;
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
  join: dim_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_batch_activity.batch_date} = ${dim_date.date} ;;
  }
}

explore: fact_monthly_target {
  label: "State targets"
  description: "Monthly SMT targets and the Mar '27 requirements (SMT, SLT, frontline)."

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.state_id} = ${dim_state.state_id} ;;
  }
  # One row per month - joining the daily dim_date here would repeat each
  # target ~30 times.
  join: dim_month {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.month_id} = ${dim_month.month_id} ;;
  }
}

explore: fact_assessment {
  label: "State assessments"

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

explore: current_user_access {
  label: "Logged-in user"
  description: "The signed-in user's role from sec_user_state_access (display only)."
}
