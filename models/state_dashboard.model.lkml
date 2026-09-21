# ============================================================================
# FILE: state_dashboard.model.lkml
# Sits in the models/ folder, where Looker created it when the model was
# registered. Do not delete and recreate it - that would unregister the model.
# The include paths below start with "/" so they resolve from the project
# root regardless of which folder this file lives in.
# ============================================================================

connection: "prj-kb-prd-looker-gcp-1014"

include: "/**/*.view.lkml"
include: "/**/state_dashboard.dashboard.lookml"

# ============================================================================
# Section A — State model.
#
# Same views as the central model. The difference is the access_filter on
# every explore: it pins each query to the one state named in the user's
# `assigned_state` user attribute.
#
# Because the filter sits on the explore rather than on the dashboard, a
# nodal officer cannot widen it from a tile, cannot reach another state by
# editing the URL, and cannot total the nation.
#
# SECURITY IS CURRENTLY OFF so the dashboard can be tested by anyone.
# Both access_filter blocks below are commented out. Turn them back on
# before this goes to real users.
#
# SETUP REQUIRED WHEN SECURITY IS TURNED BACK ON
#   1. Admin > User Attributes > Create:
#        name: assigned_state
#        data type: string
#        user access: View
#        hide values: No
#   2. Set each nodal officer's value to the exact dim_state.state_name
#      spelling — sec_user_state_access.state_name carries it.
#   3. CBC users who should see every state get the attribute left blank
#      AND need `access_filter` bypassed — give them the central model
#      instead. Do not blank the attribute on a state user; a blank value
#      returns no rows, which is the safe failure.
#
# fact_assessment is deliberately NOT joined here. The client marked the
# assessment boxes CBC-only, so the data must not be reachable from this
# model at all.
# ============================================================================

explore: fact_batch_activity {
  label: "State activity"

  # ---- SECURITY OFF FOR TESTING ----------------------------------------
  # Uncomment this block to pin each user to their own state. Requires the
  # `assigned_state` user attribute to exist and to be set per user.
  #
  # access_filter: {
  #   field: dim_state.state_name
  #   user_attribute: assigned_state
  # }
  #
  # Table-driven alternative, no per-user attribute needed:
  # sql_always_where:
  #   EXISTS (SELECT 1 FROM kkk_dataset.sec_user_state_access a
  #           WHERE LOWER(a.user_email) = LOWER('{% raw %}{{ _user_attributes["email"] }}{% endraw %}')
  #             AND (a.state_id = ${dim_state.state_id} OR a.state_id = 'ALL')) ;;
  # -----------------------------------------------------------------------

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

  # Needed for the trainer-requirement tile in Box 2.
  join: fact_monthly_target {
    type: left_outer
    relationship: many_to_many
    sql_on: ${fact_batch_activity.state_id} = ${fact_monthly_target.state_id} ;;
  }
}

explore: fact_monthly_target {
  label: "State targets"

  # ---- SECURITY OFF FOR TESTING ----------------------------------------
  # Uncomment this block to pin each user to their own state. Requires the
  # `assigned_state` user attribute to exist and to be set per user.
  #
  # access_filter: {
  #   field: dim_state.state_name
  #   user_attribute: assigned_state
  # }
  #
  # Table-driven alternative, no per-user attribute needed:
  # sql_always_where:
  #   EXISTS (SELECT 1 FROM kkk_dataset.sec_user_state_access a
  #           WHERE LOWER(a.user_email) = LOWER('{% raw %}{{ _user_attributes["email"] }}{% endraw %}')
  #             AND (a.state_id = ${dim_state.state_id} OR a.state_id = 'ALL')) ;;
  # -----------------------------------------------------------------------

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
