console.log("app.js loaded ✅");

const API_BASE = "http://localhost:8080";
const $ = (id) => document.getElementById(id);

function esc(s) {
  return String(s).replace(/[&<>"']/g, (m) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[m]));
}

function toQuery(params) {
  return Object.entries(params)
    .filter(([k, v]) => v !== null && v !== undefined && v !== '')
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join("&");
}

/* ---------- CROPS UI (chips) ---------- */
function renderCropsUI(data) {
  if (!data) return `<div class="muted">No response</div>`;
  if (data.error) return `<div class="err">❌ ${esc(data.error)}</div>`;

  const crops = data.crops || [];
  const chips = crops.length
    ? crops.map((c) => `<span class="chip">${esc(c)}</span>`).join("")
    : `<span class="muted">No crops found for this month.</span>`;

  return `
    <div class="meta">
      <div><b>Month:</b> ${esc(data.month)}</div>
      <div><b>Season:</b> ${esc(data.season)}</div>
    </div>
    <div class="chips">${chips}</div>
  `;
}

async function showCrops() {
  const month = $("month1").value.trim().toLowerCase();

  // UI output
  const cropsUI = $("cropsUI");
  const outCrops = $("outCrops");

  if (cropsUI) cropsUI.innerHTML = `<div class="muted">⏳ Loading...</div>`;
  if (outCrops) outCrops.textContent = "";

  try {
    const url = `${API_BASE}/api/crops?` + toQuery({ month });
    console.log("Fetching crops:", url);

    const res = await fetch(url);
    const data = await res.json();

    if (cropsUI) cropsUI.innerHTML = renderCropsUI(data);
    if (outCrops) outCrops.textContent = JSON.stringify(data, null, 2);
  } catch (e) {
    console.error(e);
    if (cropsUI) cropsUI.innerHTML = `<div class="err">❌ ${esc(e)}</div>`;
    if (outCrops) outCrops.textContent = String(e);
  }
}

/* ---------- RECOMMENDATION TABLE WITH FERTILIZER ---------- */
function renderTable(items) {
  if (!items || items.length === 0) return "<p class='muted'>No items</p>";

  const rows = items.map((it, idx) => {
    // Fertilizer breakdown
    let fertInfo = '';
    if (it.fertilizer && !it.fertilizer.error) {
      const f = it.fertilizer;
      fertInfo = `
        <div class="fert-breakdown">
          <div class="fert-title">💊 Fertilizer Costs:</div>
          <div class="fert-item">Urea: ${esc(f.urea_cost)} BDT</div>
          <div class="fert-item">TSP: ${esc(f.tsp_cost)} BDT</div>
          <div class="fert-item">MoP: ${esc(f.mop_cost)} BDT</div>
          <div class="fert-total">Total: ${esc(f.total)} BDT</div>
        </div>
      `;
    }

    return `
    <tr>
      <td>${idx + 1}</td>
      <td><b>${esc(it.crop)}</b></td>
      <td><span class="risk-badge risk-${esc(it.risk)}">${esc(it.risk)}</span></td>
      <td>${esc(it.yield_per_acre_kg)}</td>
      <td>${esc(it.revenue_bdt)}</td>
      <td>${esc(it.cost_bdt)}</td>
      <td><b class="profit">${esc(it.profit_bdt)}</b></td>
      <td>${esc((it.reasons || []).join(", "))}</td>
    </tr>
    <tr class="fert-row">
      <td colspan="8">${fertInfo}</td>
    </tr>
  `}).join("");

  return `
    <table>
      <thead>
        <tr>
          <th>#</th><th>Crop</th><th>Risk</th>
          <th>Yield/acre (kg)</th><th>Revenue (BDT)</th><th>Cost (BDT)</th>
          <th>Profit (BDT)</th><th>Reasons</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>
  `;
}

async function recommend() {
  const month  = $("month2").value.trim().toLowerCase();
  const soil   = $("soil").value;
  const water  = $("water").value;
  const budget = $("budget").value;
  const area   = $("area").value.trim();
  const previousCrop = $("previousCrop").value;
  const district = $("district").value;

  const outRec = $("outRec");
  const tableWrap = $("tableWrap");

  if (outRec) outRec.textContent = "Loading...";
  if (tableWrap) tableWrap.innerHTML = `<div class="muted">⏳ Loading recommendations...</div>`;

  try {
    const params = { month, soil, water, budget, area };
    
    // Add optional smart features
    if (previousCrop && previousCrop !== 'none') {
      params.previous_crop = previousCrop;
    }
    if (district && district !== 'none') {
      params.district = district;
    }

    const url = `${API_BASE}/api/recommend?` + toQuery(params);
    console.log("Fetching recommend:", url);

    const res = await fetch(url);
    const data = await res.json();

    if (outRec) outRec.textContent = JSON.stringify(data, null, 2);
    if (data.top3 && tableWrap) {
      // Show input summary
      let summary = `<div class="input-summary">`;
      summary += `<div><b>📍 Input:</b> ${esc(data.input.month)} | ${esc(data.input.soil)} soil | ${esc(data.input.water)} water | ${esc(data.input.budget)} budget | ${esc(data.input.area)} acre</div>`;
      
      if (data.input.previous_crop && data.input.previous_crop !== 'none') {
        summary += `<div><b>🔄 Rotation Bonus:</b> Previous crop was ${esc(data.input.previous_crop)}</div>`;
      }
      if (data.input.district && data.input.district !== 'none') {
        summary += `<div><b>💰 Regional Pricing:</b> ${esc(data.input.district)} district</div>`;
      }
      summary += `</div>`;
      
      tableWrap.innerHTML = summary + renderTable(data.top3);
    }
  } catch (e) {
    console.error(e);
    if (outRec) outRec.textContent = String(e);
    if (tableWrap) tableWrap.innerHTML = `<div class="err">❌ ${esc(e)}</div>`;
  }
}

/* ---------- PEST & DISEASE DIAGNOSIS ---------- */
async function diagnose() {
  const crop = $("diagnoseCrop").value;
  const symptom = $("symptom").value;
  const resultDiv = $("diagnoseResult");

  if (resultDiv) resultDiv.innerHTML = `<div class="muted">⏳ Diagnosing...</div>`;

  try {
    const url = `${API_BASE}/api/diagnose?` + toQuery({ crop, symptom });
    console.log("Fetching diagnosis:", url);

    const res = await fetch(url);
    const data = await res.json();

    if (data.status === 'success') {
      resultDiv.innerHTML = `
        <div class="diagnosis-success">
          <div class="diag-header">
            <span class="diag-icon">✅</span>
            <h3>Disease Identified</h3>
          </div>
          <div class="diag-info">
            <div><b>Crop:</b> ${esc(data.crop)}</div>
            <div><b>Symptom:</b> ${esc(data.symptom)}</div>
            <div><b>Disease:</b> <span class="disease-name">${esc(data.disease)}</span></div>
          </div>
          <div class="treatment-box">
            <div class="treatment-title">💊 Treatment Recommendation:</div>
            <div class="treatment-text">${esc(data.treatment)}</div>
          </div>
        </div>
      `;
    } else if (data.status === 'not_found') {
      resultDiv.innerHTML = `
        <div class="err">
          <div><b>❌ No Match Found</b></div>
          <div>No disease found for crop "${esc(data.crop)}" with symptom "${esc(data.symptom)}".</div>
          <div class="muted" style="margin-top: 8px;">Please try a different combination.</div>
        </div>
      `;
    } else {
      resultDiv.innerHTML = `
        <div class="muted">
          <div><b>⚠️ Partial Result</b></div>
          <div>Disease: ${esc(data.disease)}</div>
          <div>Treatment information not available.</div>
        </div>
      `;
    }
  } catch (e) {
    console.error(e);
    if (resultDiv) resultDiv.innerHTML = `<div class="err">❌ ${esc(e)}</div>`;
  }
}

/* ---------- Attach events safely ---------- */
window.addEventListener("DOMContentLoaded", () => {
  const btnCrops = $("btnCrops");
  const btnRec = $("btnRec");
  const btnDiagnose = $("btnDiagnose");

  if (btnCrops) {
    btnCrops.addEventListener("click", showCrops);
    console.log("btnCrops listener attached ✅");
  } else {
    console.error("btnCrops not found ❌");
  }

  if (btnRec) {
    btnRec.addEventListener("click", recommend);
    console.log("btnRec listener attached ✅");
  } else {
    console.error("btnRec not found ❌");
  }

  if (btnDiagnose) {
    btnDiagnose.addEventListener("click", diagnose);
    console.log("btnDiagnose listener attached ✅");
  } else {
    console.error("btnDiagnose not found ❌");
  }
});
