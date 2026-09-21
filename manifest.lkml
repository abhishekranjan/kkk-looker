# ============================================================================
# FILE: manifest.lkml  (project root)
# ============================================================================

project_name: "central_dashboard"

# BigQuery dataset that holds the kkk_* tables. Change it here once and every
# view follows. (The load workbook calls it kkk_dashboard; the deployed
# connection currently uses kkk_dataset.)
constant: kkk_dataset {
  value: "kkk_dataset"
}

# Tile-free district map. It draws only the embedded Survey of India
# boundaries, so no base-map "disputed" lines or labels can appear.
# Used by the State Dashboard as  type: central_dashboard::kkk_district_map
# NOTE: a custom visualization appears only after this is deployed to production.
visualization: {
  id: "kkk_district_map"
  label: "KKK district map (official boundaries)"
  file: "visualizations/kkk_district_map.js"
}

# National dashboard: toggle-button charts (one tile switches between SMT /
# One-Day / SLT measures instead of repeating near-identical charts).
# Used as  type: central_dashboard::kkk_switch_bars
visualization: {
  id: "kkk_switch_bars"
  label: "KKK switch bars (toggle between measures)"
  file: "visualizations/kkk_switch_bars.js"
}

# National dashboard: tile-free India map with toggle buttons
# (Status / SMTs / One-Day / SLTs). Official boundaries only, no base map.
# Used as  type: central_dashboard::kkk_state_map
visualization: {
  id: "kkk_state_map"
  label: "KKK state map (official boundaries)"
  file: "visualizations/kkk_state_map.js"
}
