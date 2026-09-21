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
