# ============================================================================
# FILE: manifest.lkml  (project root — the file must be named exactly this)
#
# Declares the two custom map layers. Looker reads the .topojson files from
# the project itself, so both files must sit in the project root alongside
# this manifest.
#
# property_key must name the property inside the TopoJSON that holds the
# label, and the values in that property must match the LookML dimension's
# values character for character. Both have been verified:
#   - all 36 st_nm values match dim_state.state_name exactly
#   - all 48 showcase district values match dim_district.district_name exactly
# ============================================================================

project_name: "central_dashboard"

map_layer: india_states {
  file: "india_states.topojson"
  property_key: "st_nm"
  property_label_key: "st_nm"
  format: topojson
}

map_layer: india_districts {
  file: "india_districts.topojson"
  property_key: "district"
  property_label_key: "district"
  format: topojson
}
