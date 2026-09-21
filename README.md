# Karmayogi Kartavya Karyakram - National Implementation Dashboard (Looker)

Section B, for the Capacity Building Commission. Every State and UT, no access limits.

## Files in this push

| File | Status | What it is |
|---|---|---|
| `central_dashboard.dashboard.lookml` | replaced | The national dashboard, 9 tabs. Needs Looker 26.4+ for tabs. |
| `central_dashboard.model.lkml` | replaced | Explores, fixed joins, map layers. |
| `kkk_views.view.lkml` | replaced | Core views. Every field the state dashboard uses is kept. |
| `kkk_national.view.lkml` | **new** | `fact_state_snapshot` (HTML parity) and `target_tracker`. |
| `india_states.topojson` | replaced | Official Survey of India outline, 36 States/UTs, names validated. |

`manifest.lkml`, `india_districts.topojson` and the state model and dashboard are unchanged.

## Tabs

1. **National Overview**: Box 1 plus every panel of the HTML Implementation tab.
2. **SMT (2-day)**: all State Master Trainer views.
3. **One-Day Programme**: all One-Day views, including the 1.3 crore tracker.
4. **SLT**: State Lead Trainer requirement. The trained figure reads "Data not available".
5. **State Drill-down**: Boxes 3, 4 and 5, plus the state record, districts, targets and assessment.
6. **Monthly SMT Targets**: the CBC target tab and the HTML Target Tracker.
7. **Roadmap 2027**: the HTML Roadmap tab.
8. **Assessments**: Box 9 (One-Day) and Box 10 (SMT), kept separate.
9. **Full Data Export**: Box 11. Use Download → CSV to get a zip of every tile.

## Maps

All maps use **Static Map (Regions)**. It draws only `india_states.topojson` and has no third-party basemap underneath. The interactive map type always draws basemap tiles, and those tiles carried the disputed-border lines. The maps always show all 36 States/UTs, so colours stay comparable across views.

## Data

The dashboard requires the tables in `bigquery_load/`. See `LOAD_NOTES.md` there. The national headline numbers read `fact_state_snapshot`, which holds exactly the figures in the client HTML (Sheet snapshot, 21 Aug 2026).
