# ============================================================================
# FILE: models/state_dashboard.model.lkml
# Section A — State model.
#
# NO ACCESS RESTRICTION for now: every user can open every state and every
# tab, including assessment. The state is chosen from the dashboard's
# State / UT filter (defaults to Odisha).
#
# To lock it down later, add this block inside each explore:
#   access_filter: {
#     field: dim_state.state_name
#     user_attribute: assigned_state
#   }
# and create the `assigned_state` user attribute under Admin > User Attributes.
# ============================================================================

connection: "prj-kb-prd-looker-gcp-1014"

include: "/**/*.view.lkml"
include: "/**/state_dashboard.dashboard.lookml"

explore: fact_batch_activity {
  label: "State activity"

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
  join: fact_monthly_target {
    type: left_outer
    relationship: many_to_many
    sql_on: ${fact_batch_activity.state_id} = ${fact_monthly_target.state_id} ;;
  }
}

explore: fact_monthly_target {
  label: "State targets"

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
