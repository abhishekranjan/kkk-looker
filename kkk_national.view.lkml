# ============================================================================
# National-dashboard views.
#
# fact_state_snapshot  - one row per State/UT. The client's Sheet exactly as the
#                        HTML reads it: Table 1 (status), Table 2 (counts) and
#                        the Target tab. Every national headline number comes
#                        from here, so Looker and the HTML always agree.
# target_tracker       - one row per State/UT per target month (Aug'26-Feb'27)
#                        with the achieved / not achieved / in progress /
#                        upcoming status the HTML's Target Tracker computes.
#
# Counts use Indian digit grouping (1,30,00,000) via value_format.
# ============================================================================

view: fact_state_snapshot {
  sql_table_name: kkk_dataset.fact_state_snapshot ;;

  # ---------------------------------------------------------------- keys
  dimension: state_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.state_id ;;
  }

  dimension: all_india {
    type: string
    # Not a bare literal: BigQuery refuses GROUP BY on literal values.
    sql: IF(${TABLE}.state_id IS NULL, 'All India', 'All India') ;;
    label: "All India"
    description: "Constant, used to draw national gauges."
  }

  dimension: snapshot_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.snapshot_date AS DATE) ;;
    label: "Implementation snapshot date"
  }

  dimension: target_snapshot_date {
    type: date
    datatype: date
    sql: SAFE_CAST(${TABLE}.target_snapshot_date AS DATE) ;;
    label: "Target sheet snapshot date"
  }

  dimension: source_note {
    type: string
    sql: ${TABLE}.source_note ;;
    label: "Source"
  }

  # ------------------------------------------------ Table 1: status fields
  dimension: smt_status {
    type: string
    sql: ${TABLE}.smt_status ;;
    label: "SMT status (Table 1)"
  }

  dimension: one_day_status {
    type: string
    sql: ${TABLE}.one_day_status ;;
    label: "One-Day status (Table 1)"
  }

  # Colour logic copied from the HTML's deriveStatus(): One-Day Completed wins,
  # then SMT Completed, otherwise Not Completed. Counts never drive colour.
  dimension: stage {
    type: string
    label: "Implementation status"
    sql: CASE
           WHEN ${one_day_status} = 'Completed' THEN 'One-Day Completed'
           WHEN ${smt_status} = 'Completed' THEN 'SMT Completed'
           ELSE 'Not Completed'
         END ;;
    order_by_field: stage_rank
    html:
      {% if value == 'One-Day Completed' %}<span style="background:#CFE7D9;color:#2F7D57;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>
      {% elsif value == 'SMT Completed' %}<span style="background:#F0E0BC;color:#AD7C25;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>
      {% else %}<span style="background:#F1D4CE;color:#B04435;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>{% endif %} ;;
  }

  dimension: stage_rank {
    type: number
    hidden: yes
    sql: CASE
           WHEN ${one_day_status} = 'Completed' THEN 3
           WHEN ${smt_status} = 'Completed' THEN 2
           ELSE 1
         END ;;
  }

  dimension: has_started {
    type: yesno
    sql: ${stage_rank} >= 2 ;;
    label: "Implementation started"
  }

  dimension: is_small_state {
    type: yesno
    label: "Smaller State / UT"
    description: "The eight States/UTs the HTML lists separately because they are hard to click on the map."
    sql: ${TABLE}.state_name IN ('Delhi', 'Chandigarh', 'Goa', 'Puducherry', 'Lakshadweep',
                                 'Dadra and Nagar Haveli and Daman and Diu', 'Sikkim', 'Tripura') ;;
  }

  # HTML tableMismatchFor(): Table 1 status and Table 2 count disagree.
  dimension: mismatch_note {
    hidden: yes
    type: string
    label: "Data quality note"
    sql: NULLIF(CONCAT(
           CASE WHEN ${one_day_status} = 'Completed' AND COALESCE(${one_day_value}, 0) = 0
                THEN 'Table 1 marks One-Day as Completed, but Table 2 shows no One-Day count. ' ELSE '' END,
           CASE WHEN ${one_day_status} != 'Completed' AND COALESCE(${one_day_value}, 0) > 0
                THEN CONCAT('Table 1 marks One-Day as Not Completed, but Table 2 shows ', CAST(${one_day_value} AS STRING), ' One-Day trained. ') ELSE '' END,
           CASE WHEN ${smt_status} = 'Completed' AND COALESCE(${smt_value}, 0) = 0
                THEN 'Table 1 marks SMT as Completed, but Table 2 shows no SMT count. ' ELSE '' END,
           CASE WHEN ${smt_status} != 'Completed' AND COALESCE(${smt_value}, 0) > 0
                THEN CONCAT('Table 1 marks SMT as Not Completed, but Table 2 shows ', CAST(${smt_value} AS STRING), ' SMTs trained.') ELSE '' END
         ), '') ;;
  }

  dimension: has_mismatch {
    hidden: yes
    type: yesno
    sql: ${mismatch_note} IS NOT NULL ;;
    label: "Has Table 1 / Table 2 mismatch"
  }

  # ------------------------------------ Table 2 + Target tab, row level
  # Row-level copies of each count so they can sit in map tooltips and tables.
  dimension: smt_value {
    type: number
    sql: SAFE_CAST(${TABLE}.smt_trained AS INT64) ;;
    label: "SMTs trained"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: smt_batches_value {
    type: number
    sql: SAFE_CAST(${TABLE}.smt_batches AS INT64) ;;
    label: "SMT batches conducted"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: one_day_value {
    type: number
    sql: SAFE_CAST(${TABLE}.one_day_trained AS INT64) ;;
    label: "One-Day participants trained"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: one_day_batches_value {
    type: number
    sql: SAFE_CAST(${TABLE}.one_day_batches AS INT64) ;;
    label: "One-Day batches conducted"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: frontline_value {
    type: number
    sql: SAFE_CAST(${TABLE}.frontline_target AS INT64) ;;
    label: "Minimum Target Frontline Workers"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: slt_required_value {
    type: number
    sql: SAFE_CAST(${TABLE}.slt_required AS INT64) ;;
    label: "Minimum Total SLTs Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: smt_required_value {
    type: number
    sql: SAFE_CAST(${TABLE}.smt_required AS INT64) ;;
    label: "Minimum Total SMTs Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: smt_batches_required_value {
    type: number
    sql: SAFE_CAST(${TABLE}.smt_batches_required AS INT64) ;;
    label: "Minimum Total SMT Batches Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: slt_batches_required_value {
    type: number
    sql: SAFE_CAST(${TABLE}.slt_batches_required AS INT64) ;;
    label: "SLT batches required"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: smt_till_aug_value {
    type: number
    sql: SAFE_CAST(${TABLE}.smt_trained_till_aug AS INT64) ;;
    label: "SMT Trained till Aug'26 (actual)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: slt_trained_text {
    type: string
    sql: IF(${TABLE}.state_id IS NULL, 'Data not available', 'Data not available') ;;
    label: "SLTs trained"
    description: "The Sheet has no SLT certification column, so this is never shown as a number."
  }

  # ------------------------------------------------------------ measures
  measure: state_count {
    type: count
    label: "States / UTs"
  }

  measure: states_started {
    type: count
    filters: [has_started: "yes"]
    label: "States / UTs with implementation started"
  }

  measure: states_one_day {
    type: count
    filters: [stage: "One-Day Completed"]
    label: "States / UTs running One-Day training"
  }

  measure: states_smt_only {
    type: count
    filters: [stage: "SMT Completed"]
    label: "States / UTs with SMT completed (One-Day pending)"
  }

  measure: states_not_started {
    type: count
    filters: [stage: "Not Completed"]
    label: "States / UTs yet to start"
  }

  measure: states_with_mismatch {
    hidden: yes
    type: count
    filters: [has_mismatch: "yes"]
    label: "States / UTs with a data quality note"
  }

  measure: stage_code {
    type: max
    sql: ${stage_rank} ;;
    label: "Implementation status code"
    description: "1 = Not Completed, 2 = SMT Completed, 3 = One-Day Completed. Drives map colour."
    value_format: "[=3]\"One-Day Completed\";[=2]\"SMT Completed\";\"Not Completed\""
  }

  measure: smt_trained {
    type: sum
    sql: ${smt_value} ;;
    label: "SMTs trained"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: smt_batches {
    type: sum
    sql: ${smt_batches_value} ;;
    label: "SMT batches conducted"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: one_day_trained {
    type: sum
    sql: ${one_day_value} ;;
    label: "One-Day participants trained"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: one_day_batches {
    type: sum
    sql: ${one_day_batches_value} ;;
    label: "One-Day batches conducted"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: frontline_target {
    type: sum
    sql: ${frontline_value} ;;
    label: "Minimum Target Frontline Workers"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: slt_required {
    type: sum
    sql: ${slt_required_value} ;;
    label: "Minimum Total SLTs Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: smt_required {
    type: sum
    sql: ${smt_required_value} ;;
    label: "Minimum Total SMTs Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: smt_batches_required {
    type: sum
    sql: ${smt_batches_required_value} ;;
    label: "Minimum Total SMT Batches Reqd"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: slt_batches_required {
    type: sum
    sql: ${slt_batches_required_value} ;;
    label: "SLT batches required"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: smt_trained_till_aug {
    type: sum
    sql: ${smt_till_aug_value} ;;
    label: "SMT Trained till Aug'26 (actual)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: slt_trained {
    type: string
    sql: MAX('Data not available') ;;
    label: "SLTs trained"
    description: "No SLT-trained figure exists in the source Sheet."
  }

  measure: programme_target {
    type: max
    sql: 13000000 ;;
    label: "Overall programme target (officials)"
    description: "1,30,00,000 officials (1.3 crore), per the programme roadmap."
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: pct_of_programme_target {
    type: number
    sql: SAFE_DIVIDE(${one_day_trained}, ${programme_target}) ;;
    label: "Progress to 1.3 crore"
    value_format: "0.000%"
  }

  measure: pct_of_programme_target_points {
    type: number
    sql: SAFE_DIVIDE(${one_day_trained}, ${programme_target}) * 100 ;;
    label: "Progress to 1.3 crore (%)"
    value_format: "0.000"
  }

  measure: programme_still_to_reach {
    type: number
    sql: GREATEST(${programme_target} - ${one_day_trained}, 0) ;;
    label: "Still to reach (1.3 crore)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  # National dashboard headline card: officials reached, % of 1.3 crore, a
  # progress bar and the number still to reach. Put programme_still_to_reach
  # in the same query.
  measure: programme_progress {
    type: number
    sql: ${one_day_trained} ;;
    label: "Officials reached against 1.3 crore"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
    html:
      <div style="display:flex;align-items:center;gap:28px;padding:6px 20px;text-align:left;font-size:14px;line-height:1.3;">
        <div style="min-width:210px;">
          <div style="font-size:13px;color:#707A88;">Officials reached (One-Day)</div>
          <div style="font-size:34px;font-weight:600;color:#D97B34;">{{ rendered_value }}</div>
        </div>
        <div style="flex:1;min-width:0;">
          <div style="display:flex;justify-content:space-between;flex-wrap:wrap;gap:6px 18px;font-size:13px;color:#1C2430;">
            <span><b>{{ value | times: 100.0 | divided_by: 13000000 | round: 3 }}%</b> of the 1.3 crore target (1,30,00,000)</span>
            <span style="color:#707A88;">Still to reach <b style="color:#12233B;">{{ fact_state_snapshot.programme_still_to_reach._rendered_value }}</b></span>
          </div>
          <div style="height:10px;background:#F1EEE6;border-radius:5px;margin-top:8px;overflow:hidden;">
            <div style="height:100%;width:max(0.6%, {{ value | times: 100.0 | divided_by: 13000000 }}%);background:#D97B34;border-radius:5px;"></div>
          </div>
        </div>
      </div> ;;
  }

  measure: pct_frontline_reached {
    type: number
    sql: SAFE_DIVIDE(${one_day_trained}, NULLIF(${frontline_target}, 0)) ;;
    label: "Frontline target reached"
    value_format: "0.00%"
  }

  measure: pct_smt_requirement {
    type: number
    sql: SAFE_DIVIDE(${smt_trained}, NULLIF(${smt_required}, 0)) ;;
    label: "SMT requirement met"
    value_format: "0.0%"
  }

  measure: smt_still_required {
    type: number
    sql: ${smt_required} - ${smt_trained} ;;
    label: "SMTs still to train"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: frontline_still_to_reach {
    type: number
    sql: ${frontline_target} - ${one_day_trained} ;;
    label: "Frontline officials still to reach"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: total_batches {
    type: number
    sql: ${smt_batches} + ${one_day_batches} ;;
    label: "Batches conducted (both programmes)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }
}

# ----------------------------------------------------------------------------

view: target_tracker {
  derived_table: {
    sql:
      SELECT
        t.state_id,
        t.month_id,
        t.month_label,
        SAFE_CAST(t.smt_target AS INT64)           AS target_batches,
        SAFE_CAST(t.smt_target_headcount AS INT64) AS target_smts,
        t.headcount_basis,
        SAFE_CAST(s.smt_trained_till_aug AS INT64) AS smt_trained
      FROM ${fact_monthly_target.SQL_TABLE_NAME} AS t
      LEFT JOIN ${fact_state_snapshot.SQL_TABLE_NAME} AS s
        ON s.state_id = t.state_id
      WHERE t.month_id BETWEEN '2026-08' AND '2027-02' ;;
  }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.state_id, '-', ${TABLE}.month_id) ;;
  }

  dimension: state_id {
    type: string
    hidden: yes
    sql: ${TABLE}.state_id ;;
  }

  dimension: month_id {
    type: string
    hidden: yes
    sql: ${TABLE}.month_id ;;
  }

  dimension: month_label {
    type: string
    sql: ${TABLE}.month_label ;;
    label: "Target month"
    order_by_field: month_id
  }

  dimension: month_phase {
    type: string
    label: "Month phase"
    description: "Concluded, Current or Upcoming, relative to today's date in India."
    sql: CASE
           WHEN ${month_id} < FORMAT_DATE('%Y-%m', CURRENT_DATE('Asia/Kolkata')) THEN 'Concluded'
           WHEN ${month_id} = FORMAT_DATE('%Y-%m', CURRENT_DATE('Asia/Kolkata')) THEN 'Current'
           ELSE 'Upcoming'
         END ;;
  }

  dimension: month_window {
    type: string
    label: "Month window"
    description: "This month / Last month / Other - lets tiles follow the calendar without a month filter."
    sql: CASE
           WHEN ${month_id} = FORMAT_DATE('%Y-%m', CURRENT_DATE('Asia/Kolkata')) THEN 'This month'
           WHEN ${month_id} = FORMAT_DATE('%Y-%m', DATE_SUB(CURRENT_DATE('Asia/Kolkata'), INTERVAL 1 MONTH)) THEN 'Last month'
           ELSE 'Other'
         END ;;
  }

  dimension: target_batches_value {
    type: number
    sql: ${TABLE}.target_batches ;;
    label: "SMT batch target"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: target_smts_value {
    type: number
    sql: ${TABLE}.target_smts ;;
    label: "SMT target (headcount)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: smt_trained_value {
    type: number
    sql: ${TABLE}.smt_trained ;;
    label: "SMTs trained (live actual)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  dimension: headcount_basis {
    type: string
    sql: ${TABLE}.headcount_basis ;;
    label: "Headcount basis"
  }

  # HTML targetStatusFor(): achieved at any month wins; a concluded month that
  # missed is red; the current month is in progress; later months are upcoming.
  dimension: target_status {
    type: string
    label: "Target status"
    sql: CASE
           WHEN COALESCE(${target_smts_value}, 0) <= 0 THEN 'Not Applicable'
           WHEN COALESCE(${smt_trained_value}, 0) >= ${target_smts_value} THEN 'Target Achieved'
           WHEN ${month_phase} = 'Concluded' THEN 'Target Not Achieved'
           WHEN ${month_phase} = 'Current' THEN 'In Progress'
           ELSE 'Upcoming'
         END ;;
    html:
      {% if value == 'Target Achieved' %}<span style="background:#CFE7D9;color:#2F7D57;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>
      {% elsif value == 'Target Not Achieved' %}<span style="background:#F1D4CE;color:#B04435;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>
      {% elsif value == 'In Progress' %}<span style="background:#F0E0BC;color:#AD7C25;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>
      {% else %}<span style="background:#E9E5D8;color:#707A88;padding:2px 10px;border-radius:10px;font-weight:600;">{{ value }}</span>{% endif %} ;;
  }

  dimension: status_rank {
    type: number
    hidden: yes
    sql: CASE ${target_status}
           WHEN 'Target Achieved' THEN 3
           WHEN 'In Progress' THEN 2
           WHEN 'Target Not Achieved' THEN 1
           ELSE 0
         END ;;
  }

  # Status matrix cell (State x month): status pill plus the month's batch
  # target. Encoded as status * 1,000,000 + batches so a pivoted table can
  # show both in one cell.
  dimension: status_order {
    type: number
    hidden: yes
    sql: CASE ${target_status}
           WHEN 'Target Achieved' THEN 4
           WHEN 'In Progress' THEN 3
           WHEN 'Target Not Achieved' THEN 2
           WHEN 'Upcoming' THEN 1
           ELSE 0
         END ;;
  }

  measure: status_cell {
    type: max
    label: "Target status"
    sql: ${status_order} * 1000000 + COALESCE(${target_batches_value}, 0) ;;
    html:
      {% assign s = value | divided_by: 1000000 | floor %}{% assign b = value | modulo: 1000000 | round %}
      {% if s == 4 %}<span style="background:#CFE7D9;color:#2F7D57;padding:2px 8px;border-radius:10px;font-weight:600;white-space:nowrap;">Achieved</span>
      {% elsif s == 3 %}<span style="background:#F0E0BC;color:#AD7C25;padding:2px 8px;border-radius:10px;font-weight:600;white-space:nowrap;">In progress</span>
      {% elsif s == 2 %}<span style="background:#F1D4CE;color:#B04435;padding:2px 8px;border-radius:10px;font-weight:600;white-space:nowrap;">Missed</span>
      {% elsif s == 1 %}<span style="background:#EEEBE3;color:#707A88;padding:2px 8px;border-radius:10px;white-space:nowrap;">Upcoming</span>
      {% else %}<span style="color:#B7B2A6;">–</span>{% endif %}
      {% if s > 0 %}<span style="color:#707A88;font-size:11px;white-space:nowrap;"> {{ b }} batches</span>{% endif %} ;;
  }

  measure: status_code {
    type: max
    sql: ${status_rank} ;;
    label: "Target status code"
    description: "0 = Upcoming / Not Applicable, 1 = Not Achieved, 2 = In Progress, 3 = Achieved. Drives map colour."
    value_format: "[=3]\"Target Achieved\";[=2]\"In Progress\";\"Not achieved / upcoming / n.a.\""
  }

  measure: state_count {
    type: count
    label: "States / UTs"
  }

  measure: states_applicable {
    type: count
    filters: [target_status: "-Not Applicable"]
    label: "States / UTs with a target"
  }

  measure: states_achieved {
    type: count
    filters: [target_status: "Target Achieved"]
    label: "Target achieved"
  }

  measure: states_not_achieved {
    type: count
    filters: [target_status: "Target Not Achieved"]
    label: "Target not achieved"
  }

  measure: states_in_progress {
    type: count
    filters: [target_status: "In Progress"]
    label: "In progress"
  }

  measure: states_upcoming {
    type: count
    filters: [target_status: "Upcoming"]
    label: "Upcoming"
  }

  measure: states_not_applicable {
    type: count
    filters: [target_status: "Not Applicable"]
    label: "No target set"
  }

  measure: target_batches {
    type: sum
    sql: ${target_batches_value} ;;
    label: "SMT batch target"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  measure: target_smts {
    type: sum
    sql: ${target_smts_value} ;;
    label: "SMT target (headcount)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }

  # Use with ONE target month selected (the dashboard filter enforces this);
  # the actual is a per-state figure repeated on every month row.
  measure: smt_trained {
    type: sum
    sql: ${smt_trained_value} ;;
    label: "SMTs trained (live actual)"
    value_format: "[>=10000000]##\,##\,##\,##0;[>=100000]##\,##\,##0;##,##0"
  }
}
