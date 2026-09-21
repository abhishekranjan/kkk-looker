/*
 * KKK switch bars - custom Looker visualization (National dashboard)
 * ----------------------------------------------------------------------------
 * One category dimension + several measures. Each measure becomes a toggle
 * button at the top of the tile, so one tile replaces several near-identical
 * charts (SMT / One-Day / SLT, trained / batches ...).
 *
 * Layout is plain HTML (no chart library): long category names wrap onto a
 * second line instead of being cut with "...", and nothing is re-measured on
 * resize, so the axes never flicker. Long lists scroll inside the tile.
 * Numbers use the Indian digit grouping (1,30,00,000).
 *
 * Options (set in the dashboard tile):
 *   orientation : horizontal | vertical
 *   bar_order   : value (largest first) | data (query order, e.g. months)
 *   hide_zero   : drop rows that are zero / empty for the selected measure
 *   top_n       : 0 = all rows
 *   colors      : "smt:#AD7C25,one_day:#2F7D57"   (part of measure name : colour)
 *   labels      : "smt_trained=SMTs;one_day_trained=One-Day"  (button text)
 *   default_measure : measure the tile opens on
 * Click a bar to cross-filter the dashboard.
 */
(function () {
  'use strict';

  var PALETTE = ['#1D3557', '#2F7D57', '#AD7C25', '#D97B34', '#B04435'];
  var CSS = [
    '.ksb{display:flex;flex-direction:column;width:100%;height:100%;font-family:inherit;color:#1C2430;font-size:12px;box-sizing:border-box;}',
    '.ksb *{box-sizing:border-box;}',
    '.ksb .top{display:flex;align-items:center;justify-content:space-between;gap:8px;padding:4px 8px 6px;flex:0 0 auto;}',
    '.ksb .btns{display:flex;flex-wrap:wrap;gap:4px;}',
    '.ksb .btns button{font:inherit;font-size:12px;border:1px solid #C9CED6;background:#fff;color:#1C2430;border-radius:4px;padding:3px 9px;cursor:pointer;}',
    '.ksb .btns button.on{background:#12233B;color:#fff;border-color:#12233B;}',
    '.ksb .tot{color:#707A88;white-space:nowrap;}',
    '.ksb .tot b{color:#12233B;}',
    '.ksb .body{flex:1 1 auto;min-height:0;overflow:auto;padding:2px 8px 6px;}',
    '.ksb .row{display:grid;grid-template-columns:minmax(90px,36%) 1fr auto;align-items:center;gap:8px;padding:3px 0;cursor:pointer;border-radius:3px;}',
    '.ksb .row:hover{background:#F4F1EA;}',
    '.ksb .row .c{line-height:1.25;word-break:break-word;}',
    '.ksb .row .t{height:14px;background:#F1EEE6;border-radius:3px;overflow:hidden;}',
    '.ksb .row .f{height:100%;border-radius:3px;min-width:2px;}',
    '.ksb .row .v{font-weight:600;min-width:44px;text-align:right;white-space:nowrap;}',
    '.ksb .cols{display:flex;align-items:stretch;gap:6px;height:100%;min-width:100%;}',
    '.ksb .col{flex:1 0 46px;display:flex;flex-direction:column;cursor:pointer;border-radius:3px;}',
    '.ksb .col:hover{background:#F4F1EA;}',
    '.ksb .col .p{flex:1 1 auto;display:flex;flex-direction:column;justify-content:flex-end;align-items:stretch;min-height:0;padding:0 4px;}',
    '.ksb .col .v{text-align:center;font-weight:600;white-space:nowrap;padding-bottom:2px;}',
    '.ksb .col .f{border-radius:3px 3px 0 0;min-height:2px;}',
    '.ksb .col .c{flex:0 0 auto;text-align:center;line-height:1.2;padding-top:4px;border-top:1px solid #D9D5C9;min-height:30px;word-break:break-word;}',
    '.ksb .dim{opacity:.35;}',
    '.ksb .empty{color:#707A88;text-align:center;padding:24px 8px;}'
  ].join('\n');

  function num(c) {
    if (!c || c.value === null || c.value === undefined || c.value === '') return null;
    var v = Number(c.value); return isNaN(v) ? null : v;
  }
  function isNum(f) {
    var t = (f.type || '').toLowerCase();
    return ['string', 'list', 'date', 'time', 'yesno', 'location', 'tier', 'zipcode'].indexOf(t) < 0;
  }
  function fmt(n) {
    if (n === null || n === undefined || isNaN(n)) return '–';
    return (Math.round(n * 10) / 10).toLocaleString('en-IN', { maximumFractionDigits: 1 });
  }
  function esc(s) {
    return String(s === null || s === undefined ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  function pairs(s, sep, kv) {
    var out = [];
    String(s || '').split(sep).forEach(function (p) { var i = p.indexOf(kv); if (i > 0) out.push([p.slice(0, i).trim(), p.slice(i + 1).trim()]); });
    return out;
  }
  function pick(list, name) { for (var i = 0; i < list.length; i++) if (name.indexOf(list[i][0]) >= 0) return list[i][1]; return null; }

  var viz = {
    id: 'kkk_switch_bars',
    label: 'KKK switch bars (toggle between measures)',
    options: {
      orientation: { type: 'string', label: 'Orientation', display: 'select', values: [{ 'Horizontal bars': 'horizontal' }, { 'Vertical columns': 'vertical' }], default: 'horizontal', section: 'Chart', order: 1 },
      bar_order: { type: 'string', label: 'Order', display: 'select', values: [{ 'Largest first': 'value' }, { 'Query order': 'data' }], default: 'value', section: 'Chart', order: 2 },
      hide_zero: { type: 'boolean', label: 'Hide zero / empty rows', default: true, section: 'Chart', order: 3 },
      top_n: { type: 'number', label: 'Show top N (0 = all)', default: 0, section: 'Chart', order: 4 },
      show_total: { type: 'boolean', label: 'Show total', default: true, section: 'Chart', order: 5 },
      default_measure: { type: 'string', label: 'Open on (measure name)', default: '', section: 'Buttons', order: 6 },
      labels: { type: 'string', label: 'Button labels (name-part=Text; ...)', default: '', section: 'Buttons', order: 7 },
      colors: { type: 'string', label: 'Colours (name-part:#hex, ...)', default: '', section: 'Buttons', order: 8 }
    },
    create: function (element) {
      element.innerHTML = '';
      var style = document.createElement('style'); style.textContent = CSS; element.appendChild(style);
      var root = document.createElement('div'); root.className = 'ksb'; element.appendChild(root);
      root.innerHTML = '<div class="top"><div class="btns"></div><div class="tot"></div></div><div class="body"></div>';
      this._s = { root: root, btns: root.querySelector('.btns'), tot: root.querySelector('.tot'), body: root.querySelector('.body'), metric: null };
    },
    updateAsync: function (data, element, config, qr, details, done) {
      var self = this, st = this._s;
      this.clearErrors();
      var dims = qr.fields.dimension_like || [];
      var meas = ((qr.fields.measure_like || []).concat(qr.fields.table_calculations || [])).filter(isNum);
      if (!dims.length || !meas.length) {
        this.addError({ title: 'Needs one dimension and at least one measure', message: 'Each measure becomes a toggle button.' });
        done(); return;
      }
      var dim = dims[0];
      var labelPairs = pairs(config.labels, ';', '='), colorPairs = pairs(config.colors, ',', ':');
      function lab(m) { return pick(labelPairs, m.name) || m.label_short || m.label || m.name; }

      var metric = null;
      if (st.metric) meas.forEach(function (m) { if (m.name === st.metric) metric = m; });
      if (!metric && config.default_measure) meas.forEach(function (m) { if (!metric && m.name.indexOf(config.default_measure) >= 0) metric = m; });
      if (!metric) metric = meas[0];
      st.metric = metric.name;
      var color = pick(colorPairs, metric.name) || PALETTE[meas.indexOf(metric) % PALETTE.length];

      st.btns.innerHTML = '';
      if (meas.length > 1) meas.forEach(function (m) {
        var b = document.createElement('button'); b.type = 'button'; b.textContent = lab(m);
        if (m.name === metric.name) b.className = 'on';
        b.addEventListener('click', function (e) { e.stopPropagation(); st.metric = m.name; self.updateAsync(data, element, config, qr, details, function () {}); });
        st.btns.appendChild(b);
      });

      var pct = /%/.test(metric.value_format || '');
      var U = window.LookerCharts && LookerCharts.Utils;
      function text(row, v) { return pct && U && U.textForCell ? U.textForCell(row[metric.name]) : fmt(v); }

      var rows = data.map(function (row, i) {
        var c = row[dim.name] || {};
        var name = (U && U.textForCell) ? U.textForCell(c) : (c.rendered || c.value);
        return { row: row, i: i, name: (name === null || name === undefined || name === '') ? '(not recorded)' : name, v: num(row[metric.name]) };
      });
      if (config.hide_zero !== false) rows = rows.filter(function (r) { return r.v !== null && r.v > 0; });
      if (config.bar_order !== 'data') rows.sort(function (a, b) { return (b.v || 0) - (a.v || 0) || a.i - b.i; });
      var total = rows.reduce(function (s, r) { return s + (r.v || 0); }, 0);
      var n = Number(config.top_n) || 0;
      if (n > 0) rows = rows.slice(0, n);
      var maxV = rows.reduce(function (m, r) { return Math.max(m, r.v || 0); }, 0) || 1;

      st.tot.innerHTML = (config.show_total !== false && !pct && rows.length)
        ? (n > 0 ? 'Top ' + rows.length + ' · ' : '') + 'Total <b>' + esc(fmt(total)) + '</b>' : '';

      var anySel = details && details.crossfilterEnabled && details.crossfilters && details.crossfilters.length;
      function selClass(r) {
        if (!anySel || !U || !U.getCrossfilterSelection) return '';
        try { return U.getCrossfilterSelection(r.row) === 2 ? ' dim' : ''; } catch (e) { return ''; }
      }
      function onClick(r, e) {
        if (!U) return;
        if (details && details.crossfilterEnabled && U.toggleCrossfilter) U.toggleCrossfilter({ row: r.row, event: e });
        else if (U.openDrillMenu && r.row[metric.name] && r.row[metric.name].links) U.openDrillMenu({ links: r.row[metric.name].links, event: e });
      }

      st.body.innerHTML = '';
      if (!rows.length) {
        st.body.innerHTML = '<div class="empty">Nothing recorded yet for ' + esc(lab(metric)) + '.</div>';
        done(); return;
      }
      if (config.orientation === 'vertical') {
        var wrap = document.createElement('div'); wrap.className = 'cols'; st.body.appendChild(wrap);
        rows.forEach(function (r) {
          var h = Math.max(0, (r.v || 0) / maxV * 100);
          var col = document.createElement('div'); col.className = 'col' + selClass(r);
          col.title = r.name + ': ' + text(r.row, r.v);
          col.innerHTML = '<div class="p"><div class="v">' + esc(text(r.row, r.v)) + '</div><div class="f" style="height:max(2px,calc(' + h.toFixed(2) + '% - 18px));background:' + esc(color) + '"></div></div><div class="c">' + esc(r.name) + '</div>';
          col.addEventListener('click', function (e) { onClick(r, e); });
          wrap.appendChild(col);
        });
      } else {
        rows.forEach(function (r) {
          var w = Math.max(0, (r.v || 0) / maxV * 100);
          var d = document.createElement('div'); d.className = 'row' + selClass(r);
          d.title = r.name + ': ' + text(r.row, r.v);
          d.innerHTML = '<div class="c">' + esc(r.name) + '</div><div class="t"><div class="f" style="width:' + w.toFixed(2) + '%;background:' + esc(color) + '"></div></div><div class="v">' + esc(text(r.row, r.v)) + '</div>';
          d.addEventListener('click', function (e) { onClick(r, e); });
          st.body.appendChild(d);
        });
      }
      done();
    }
  };
  looker.plugins.visualizations.add(viz);
})();
