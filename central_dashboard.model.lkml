# ============================================================================
# FILE: central_dashboard.model.lkml
# Section B - National Implementation Dashboard (CBC). Unrestricted: every
# State and UT, every tab, no access filter.
# ============================================================================

connection: "prj-kb-prd-looker-gcp-1014"

include: "/**/*.view.lkml"
include: "/**/central_dashboard.dashboard.lookml"

# ---------------------------------------------------------------------------
# Map layers. Official Survey of India outline (J&K and Ladakh include PoK,
# Gilgit-Baltistan and Aksai Chin; Arunachal Pradesh is complete). The national
# dashboard draws these with Static Map (Regions), which has no basemap, so
# no third-party disputed-border lines are ever drawn.
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
# 1. State snapshot - one row per State/UT, identical to the client HTML.
#    Drives Box 1 headline numbers, the maps, zones, lists, targets and roadmap.
# ============================================================================
explore: state_snapshot {
  label: "National - State snapshot (matches the HTML)"
  view_name: fact_state_snapshot

  join: dim_state {
    type: left_outer
    relationship: one_to_one
    sql_on: ${fact_state_snapshot.state_id} = ${dim_state.state_id} ;;
  }
}

# ============================================================================
# 2. Batch activity - batch grain. Trends, Box 3 / 4 / 5, districts, export.
#    Target and assessment facts are NOT joined here any more: joining them on
#    state alone multiplied rows and slowed every tile.
# ============================================================================
explore: fact_batch_activity {
  label: "National - Batch activity"

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
}

# ============================================================================
# 3. Monthly SMT targets - state x month. The month lives on the fact itself,
#    so dim_date is no longer joined (the old daily join repeated each target
#    row ~30 times).
# ============================================================================
explore: fact_monthly_target {
  label: "National - Monthly SMT targets"

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.state_id} = ${dim_state.state_id} ;;
  }

  join: fact_state_snapshot {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_monthly_target.state_id} = ${fact_state_snapshot.state_id} ;;
  }
}

# ============================================================================
# 4. Target tracker - achieved / not achieved / in progress / upcoming.
# ============================================================================
explore: target_tracker {
  label: "National - SMT target tracker"

  join: dim_state {
    type: left_outer
    relationship: many_to_one
    sql_on: ${target_tracker.state_id} = ${dim_state.state_id} ;;
  }
}

# ============================================================================
# 5. Assessments - Box 9 (One-Day) and Box 10 (SMT).
# ============================================================================
explore: fact_assessment {
  label: "National - Assessments"

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
