# KKK Dashboards — LookML project (`central_dashboard`)

Looker project for the **Karmayogi Kartavya Karyakram** rollout on BigQuery.
This release rebuilds the **State Dashboard (Section A)**. The central dashboard is unchanged apart from one map-layer key.

## Files

| File | Status | What it is |
|---|---|---|
| `manifest.lkml` | changed | Project name, `kkk_dataset` constant, custom map visualization |
| `kkk_views.view.lkml` | changed | Shared views. Every field the central dashboard uses is kept |
| `kkk_state_views.view.lkml` | **new** | `district_map` (district clean-up + map key), `dim_month`, `current_user_access` |
| `models/state_dashboard.model.lkml` | changed | State model: explores, joins, map layers |
| `state_dashboard.dashboard.lookml` | rewritten | 7-tab State Dashboard |
| `central_dashboard.model.lkml` | 1 line | `india_districts` layer now keyed `key` |
| `central_dashboard.dashboard.lookml` | unchanged | |
| `india_districts.topojson` | replaced | All-India districts (was 4 states), keyed `State\|District` |
| `india_states.topojson` | unchanged | |
| `visualizations/kkk_district_map.js` | **new** | Tile-free district map (boundaries embedded) |

## Deploy

1. Copy these files into the repo keeping this folder layout (the state model lives in `models/`, everything else at the root), commit, push.
   Keep only one copy of each file: a second `state_dashboard.model.lkml` anywhere else in the repo would clash.
2. In Looker: **Validate LookML**, then **Deploy to production**.
   The custom map only appears after deploying to production. Saving in Development Mode is not enough.
3. Open *LookML dashboards > State Implementation Dashboard*.

**Requirements:** dashboard tabs need Looker **26.4 or later**. The BigQuery dataset must contain the tables `sec_user_state_access` and `dim_role` for the *Logged-in role* tile. If the dataset is not called `kkk_dataset`, change the constant in `manifest.lkml`.

## The State Dashboard, box by box

| Requirement | Where | How |
|---|---|---|
| Box 1 · State dropdown | Filter bar | `State / UT`, single select, default Odisha |
| Box 1 · Logged-in role | State overview | Signed-in email looked up in `sec_user_state_access` (display only) |
| Box 1 · District map, SMT + 1-Day | State overview, District map | Custom map with a 1-Day / SMT / batches toggle and numbers inside districts |
| Box 1 · Download Full State Data (Excel) | State overview | Button to the *Download data* tab, plus a link that opens the state in an Explore |
| Box 2 · Total SLT / SMTs / 1-Day / Batches | State overview | Totals strip and state row. Total SLT reads **Pending** |
| Box 2 · District table + Download | State overview | District, Total SMTs, Batches taken by SMTs, 1-Day Trained, ⬇ Download. Totals row = State Total |
| Box 2 · Map beside table, click to filter | State overview | Clicking a district cross-filters the table |
| Box 3 · Batches & 1-Day Trained by date | 1-Day programme | Dual-axis line, plus a monthly table |
| Box 4 · 1-Day Trained by group | 1-Day programme | Bar and list |
| Box 5 · 1-Day Trained by designation | 1-Day programme | Top-20 bar and full list, plus group × designation grid |
| Box 6 · Baseline, Day-1, improvement (1-Day only) | Assessment | KPIs, comparison chart, detail table |
| Extra | SMT programme, SLT programme, District map, Download data | Targets, trends, placement audit, row-level export |

"Total Batches" and "Batches taken by SMTs" mean **one-day batches** (Odisha: 87 SMTs / 30 trained / 1 batch, matching the brief). The SMTs' own 2-day training batches are on the SMT tab.

## The map

* **No base-map tiles.** Looker's built-in maps draw third-party tiles that show J&K, Ladakh and Arunachal Pradesh as disputed, and no Looker setting turns them off. The custom visualization draws only the embedded boundaries, which follow the Government of India depiction (J&K includes Muzaffarabad and Mirpur; Ladakh includes Gilgit-Baltistan and Aksai Chin).
* **Numbers match the table.** The map and the district table use the same explore, filters and district key, so every number on the map adds up to the totals strip.
* **Keyed `State|District`.** Same-name districts in different states (Aurangabad, Bilaspur, Balrampur, Hamirpur, Pratapgarh …) no longer collide.
* **Navigation.** Zoom with + / − buttons, Ctrl/⌘ + scroll or double-click. Drag to pan. ⤢ fits the state. Hover shows all figures; click filters the dashboard.
* **Source.** Boundaries come from `udit-001/india-maps-data` on GitHub, the same dataset the previous TopoJSON files used. It has no formal licence and is community-curated. For formal publication, swap in Survey of India files with the build tools shipped alongside this repo.

### District clean-up (`district_map`)

`dim_district` holds 211 rows. 129 already match an official district name and are used as-is. The other 82 are listed in `kkk_state_views.view.lkml` with the reason for each:

* spelling fixes (`Srinagr`, `Shopian`, `Siaha`, `Kanker` …)
* offices or training centres recorded instead of a district (all 27 Uttarakhand rows, Tripura CMOs); the district is taken from the address
* districts created after the 2011 boundary set (Andhra Pradesh's new districts, Maihar, Mauganj, Chumoukedima, Saitual), drawn inside their parent district
* 8 rows with no mappable district (state-level offices, plus the source errors listed below); they appear in the table but not on the map, and the map notes how many

**To fix a new mismatch**, add one `STRUCT` line to the list in `district_map`. The *District map* tab's placement table shows how every reported name was placed.

## Access

No data restriction is applied for now: every user can pick any state and see every tab, including Assessment (marked CBC-only in the brief). The `access_filter` to add later is written out in `models/state_dashboard.model.lkml`.

## Source data issues to fix upstream

* `MH-D001` "Srinagar" is filed under Maharashtra. It is not mapped.
* `PB-D001`, `PB-D002` "Chandigarh" and `PB-D003` "Chd. / Mohali" are filed under Punjab. They are not mapped.
* `MN-D001` "Imphal" does not say East or West. It is mapped to Imphal West as an assumption.
* 236 activity rows have no district. They show as *District not recorded*.
* All SLT rows are DEMO placeholders. They are excluded, so Total SLT reads Pending (the SLT tab shows how many).
* `fact_monthly_target.slt_trained` totals 434 although the workbook README says it is always 0. It is not used.
* The workbook calls the dataset `kkk_dashboard`; the views use `kkk_dataset` (set in `manifest.lkml`).
