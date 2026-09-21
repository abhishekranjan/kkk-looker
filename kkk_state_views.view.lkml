# ============================================================================
# FILE: kkk_state_views.view.lkml
# Views used by the State Dashboard (Section A). Self-contained derived
# tables - nothing to load into BigQuery beyond the kkk tables already there.
#
#   district_map         clean district names + the "State|District" key that
#                        matches the official-boundary map (india_districts)
#   dim_month            one row per month (joining the daily dim_date on
#                        month_id would multiply every target by ~30)
# ============================================================================

view: district_map {
  # Every dim_district row that is NOT listed below already carries the
  # official district name of its own state and is used as-is.
  # Rows listed below are spelling fixes, offices recorded instead of a
  # district, or districts created after the 2011 boundary set (drawn inside
  # their parent district). To fix a new mismatch, add one STRUCT row.
  derived_table: {
    sql:
      SELECT
        d.district_id,
        s.state_name,
        d.district_name AS reported_name,
        COALESCE(x.district_label, d.district_name) AS district_label,
        IF(x.district_id IS NULL, d.district_name, x.map_district) AS map_district,
        COALESCE(x.match_note, 'Exact match') AS match_note
      FROM @{kkk_dataset}.dim_district AS d
      LEFT JOIN @{kkk_dataset}.dim_state AS s
        ON s.state_id = d.state_id
      LEFT JOIN (
        SELECT * FROM UNNEST([
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D001', 'Alluri Sitharama Raju', 'Visakhapatnam', 'New district - drawn inside parent Visakhapatnam'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D002', 'Anakapalli', 'Visakhapatnam', 'New district - drawn inside parent Visakhapatnam'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D003', 'Anantapuramu', 'Anantapur', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D004', 'Annamayya', 'Y.S.R. Kadapa', 'New district - drawn inside parent Y.S.R. Kadapa'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D005', 'Bapatla', 'Guntur', 'New district - drawn inside parent Guntur'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D007', 'Dr. B.R. Ambedkar Konaseema', 'East Godavari', 'New district - drawn inside parent East Godavari'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D009', 'Eluru', 'West Godavari', 'New district - drawn inside parent West Godavari'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D011', 'Kakinada', 'East Godavari', 'New district - drawn inside parent East Godavari'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D014', 'Markapuram', 'Prakasam', 'New district - drawn inside parent Prakasam'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D015', 'Nandyal', 'Kurnool', 'New district - drawn inside parent Kurnool'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D016', 'NTR', 'Krishna', 'New district - drawn inside parent Krishna'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D017', 'Palnadu', 'Guntur', 'New district - drawn inside parent Guntur'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D018', 'Polavaram', 'West Godavari', 'New district - drawn inside parent West Godavari'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D020', 'SPSR Nellore', 'S.P.S. Nellore', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D021', 'Sri Sathya Sai', 'Anantapur', 'New district - drawn inside parent Anantapur'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D023', 'State Head Office (HOD)', CAST(NULL AS STRING), 'State-level office - no district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D024', 'Tirupati', 'Chittoor', 'New district - drawn inside parent Chittoor'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('AP-D028', 'YSR Kadapa', 'Y.S.R. Kadapa', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('CG-C12', 'Kanker', 'Uttar Bastar Kanker', 'Official name'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('DL-D001', 'West', 'Delhi', 'Delhi is one polygon on the map'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('DL-D002', 'West-A', 'Delhi', 'Delhi is one polygon on the map'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('JK-D012', 'Shopian', 'Shopiyan', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('JK-D014', 'Srinagar', 'Srinagar', 'Typo in source (Srinagr)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('KL-D001', 'Ernakulam (Kochi)', 'Ernakulam', 'City recorded - district is Ernakulam'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('KL-D004', 'Thiruvananthapuram', 'Thiruvananthapuram', 'City recorded (Trivandrum)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MP-D015', 'Maihar', 'Satna', 'New district - drawn inside parent Satna'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MP-D017', 'Mauganj', 'Rewa', 'New district - drawn inside parent Rewa'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MH-D001', 'Srinagar (as recorded - check source)', CAST(NULL AS STRING), 'Source error - Srinagar is not a Maharashtra district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MN-D001', 'Imphal', 'Imphal West', 'Assumed Imphal West - source says only \'Imphal\''),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MN-D003', 'Lamphelpat (Imphal)', 'Imphal West', 'Lamphelpat is in Imphal West'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MZ-D009', 'Saitual', 'Aizawl', 'New district - drawn inside parent Aizawl'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('MZ-D011', 'Siaha', 'Saiha', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('NL-D001', 'Kohima', 'Kohima', 'Chiechama is in Kohima district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('NL-D002', 'Chumoukedima', 'Dimapur', 'New district - drawn inside parent Dimapur'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('NL-D005', 'Kohima', 'Kohima', 'Kohima/Chiechama recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('NL-D008', 'Phek', 'Phek', 'Pfutsero is in Phek district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('NL-D011', 'Phek', 'Phek', 'Pfutsero, Phek recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D001', 'Chandigarh (Punjab HQ)', CAST(NULL AS STRING), 'State HQ in Chandigarh - not a Punjab district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D002', 'Chandigarh (Punjab HQ)', CAST(NULL AS STRING), 'State HQ in Chandigarh - not a Punjab district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D003', 'Chandigarh / Mohali', CAST(NULL AS STRING), 'Ambiguous - Chandigarh or S.A.S. Nagar'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D006', 'S.A.S. Nagar (Mohali)', 'S.A.S. Nagar', 'Mohali = S.A.S. Nagar'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D008', 'Rupnagar', 'Rupnagar', 'Ropar = Rupnagar'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D009', 'S.A.S. Nagar (Mohali)', 'S.A.S. Nagar', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('PB-D010', 'S.A.S. Nagar (Mohali)', 'S.A.S. Nagar', 'Spelling'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D001', 'Dhalai', 'Dhalai', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D002', 'Khowai', 'Khowai', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D003', 'North Tripura', 'North Tripura', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D004', 'South Tripura', 'South Tripura', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D005', 'Unakoti', 'Unokoti', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D006', 'West Tripura', 'West Tripura', 'CMO office recorded'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D007', 'Directorate of Urban Development', CAST(NULL AS STRING), 'State-level office - no district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D008', 'West Tripura', 'West Tripura', 'ICDS project, West District'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D009', 'Office of the DGP', CAST(NULL AS STRING), 'State-level office - no district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D010', 'Panchayat Department', CAST(NULL AS STRING), 'State-level office - no district'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('TR-D011', 'West Tripura', 'West Tripura', 'ICDS project, West District'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D001', 'Pithoragarh', 'Pithoragarh', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D002', 'Udham Singh Nagar', 'Udham Singh Nagar', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D003', 'Dehradun', 'Dehradun', 'Office address (Ranipokhri)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D004', 'Pauri Garhwal', 'Pauri Garhwal', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D005', 'Haridwar', 'Haridwar', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D006', 'Haridwar', 'Haridwar', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D007', 'Nainital', 'Nainital', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D008', 'Nainital', 'Nainital', 'Office address (Haldwani)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D009', 'Uttarkashi', 'Uttarkashi', 'Office address (Purola)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D010', 'Almora', 'Almora', 'Office address (Hawalbag)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D011', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D012', 'Nainital', 'Nainital', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D013', 'Champawat', 'Champawat', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D014', 'Pauri Garhwal', 'Pauri Garhwal', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D015', 'Chamoli', 'Chamoli', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D016', 'Udham Singh Nagar', 'Udham Singh Nagar', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D017', 'Champawat', 'Champawat', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D018', 'Chamoli', 'Chamoli', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D019', 'Tehri Garhwal', 'Tehri Garhwal', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D020', 'Almora', 'Almora', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D021', 'Nainital', 'Nainital', 'Office address (Ramnagar)'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D022', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D023', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D024', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D025', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D026', 'Dehradun', 'Dehradun', 'Office address'),
          STRUCT<district_id STRING, district_label STRING, map_district STRING, match_note STRING>('UK-D027', 'Udham Singh Nagar', 'Udham Singh Nagar', 'Office address')
        ])
      ) AS x
        ON x.district_id = d.district_id ;;
  }

  dimension: district_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.district_id ;;
  }
  dimension: district_label {
    type: string
    sql: COALESCE(${TABLE}.district_label, 'District not recorded') ;;
    label: "District"
    description: "Clean district name. Offices are placed in their district; rows with no district read 'District not recorded'."
  }
  dimension: reported_name {
    type: string
    sql: COALESCE(${TABLE}.reported_name, '(blank in source)') ;;
    label: "District as reported"
  }
  dimension: map_district {
    type: string
    sql: ${TABLE}.map_district ;;
    label: "District on map (official name)"
  }
  dimension: map_key {
    type: string
    sql: CASE WHEN ${TABLE}.map_district IS NOT NULL THEN CONCAT(${TABLE}.state_name, '|', ${TABLE}.map_district) END ;;
    label: "District map key"
    description: "State|District - matches the india_districts map layer and the KKK district map."
    map_layer_name: india_districts
  }
  dimension: match_note {
    type: string
    sql: COALESCE(${TABLE}.match_note, 'No district recorded') ;;
    label: "How the district was placed on the map"
  }
  # Box 2 - per-district "Download" link. Needs dim_state.state_name in the
  # same query (it can be a hidden column).
  dimension: district_download {
    type: string
    sql: ${district_label} ;;
    label: "Download"
    html: <a href="/explore/state_dashboard/fact_batch_activity?fields=dim_state.state_name,district_map.district_label,district_map.reported_name,dim_group.group_name,dim_designation.designation_name,fact_batch_activity.batch_type,fact_batch_activity.batch_date,fact_batch_activity.data_source,fact_batch_activity.participants_trained,fact_batch_activity.batch_count&amp;f[dim_state.state_name]={{ dim_state.state_name._value | url_encode }}&amp;f[district_map.district_label]={{ value | url_encode }}&amp;sorts=fact_batch_activity.batch_date&amp;limit=5000" target="_blank" style="color:#1D3557;font-weight:600;">&#11015; Download</a> ;;
  }

  measure: reported_as {
    type: string
    sql: STRING_AGG(DISTINCT ${TABLE}.reported_name, ', ' ORDER BY ${TABLE}.reported_name) ;;
    label: "Reported as"
  }
}

view: dim_month {
  derived_table: {
    sql:
      SELECT
        month_id,
        ANY_VALUE(month_label) AS month_label,
        ANY_VALUE(month_name) AS month_name,
        ANY_VALUE(fiscal_phase) AS fiscal_phase,
        ANY_VALUE(quarter) AS quarter
      FROM @{kkk_dataset}.dim_date
      GROUP BY month_id ;;
  }

  dimension: month_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.month_id ;;
    label: "Month (YYYY-MM)"
  }
  dimension: month_label {
    type: string
    sql: ${TABLE}.month_label ;;
    label: "Month"
    order_by_field: month_id
  }
  dimension: month_name {
    type: string
    sql: ${TABLE}.month_name ;;
    hidden: yes
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
