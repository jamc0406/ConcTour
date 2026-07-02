# 作業場所濃度分佈圖繪製工具 / Workplace Concentration Contour Tool

以瀏覽器內 Python（Pyodide + numpy / scipy）進行空間插值，繪製作業場所危害物質暴露濃度分佈圖的純前端單頁工具。無後端、無建置流程，可直接部署於 GitHub Pages。

A pure-frontend, single-page tool for mapping workplace hazardous-substance exposure concentrations. All scientific computing (numpy / scipy spatial interpolation) runs **inside the browser** via Pyodide — no backend, no build step, deployable straight to GitHub Pages.

![Screenshot placeholder / 畫面截圖（待補）](docs/screenshot.png)

## ✨ 功能特色 / Features

- **5 種空間插值方法 / 5 interpolation methods**：IDW、線性 Linear、RBF（薄板樣條）、Spline（雙三次樣條）、Kriging（普通克利金）
- **場域尺寸固定繪圖 / Field-size-based plotting**：以場域寬高（公尺）固定圖面範圍與長寬比例，插值網格涵蓋整個場域
- **資料 QAQC / Built-in QA/QC**：自動排除 0 值、負值與超出場域之測點；疑似異常高值（> Q3+3×IQR）以 ⚠ 標記並預設納入，**可由使用者點擊自行決定排除或納入計算**
- **數理統計 / Descriptive statistics**：獨立統計框顯示樣本數、最小／最大值、平均、中位數、標準差、GM、GSD 與超過 OEL 點數
- **OEL 超標視覺化 / OEL exceedance visualization**：輸入容許暴露標準後，以粗紅等值線與紅色半透明區標示超標範圍
- **平面圖底圖 / Floor plan overlay**：上傳廠房平面圖（PNG/JPG），自動縮放至場域大小，並可直接在圖面上拖移與縮放；**可調整分佈圖不透明度**讓底圖更清楚
- **圖表設定 / Chart settings**：標題、色階圖示選擇、分佈圖不透明度、標註字體顏色與大小、濃度點大小
- **平順縮放 / Smooth zoom**：滑鼠滾輪以游標為中心平順縮放，雙擊回到完整場域；輸入面板可由右緣**拉寬／拉窄**
- **獨立使用說明頁 / Standalone guide page**（`guide.html`，中英雙語），並內建關於我們與免責聲明
- **中英文介面切換 / Bilingual UI (ZH/EN)**，行動裝置側欄收合為底部面板

## 🚀 使用步驟 / Usage Guide

1. **開啟網頁並等待載入** — 首次載入需下載約 40 MB 的運算環境（約 15–30 秒），之後由瀏覽器快取加速。
   **Open the page and wait for loading** — the first visit downloads ~40 MB of runtime (~15–30 s); later visits are cached.
2. **設定場域尺寸** — 輸入作業場所寬（X）與高（Y），單位公尺；分佈圖固定以此範圍與比例繪製，原點 (0,0) 在左下角。
   **Set the field size** — enter the workplace width (X) and height (Y) in meters; the map always uses this extent and aspect ratio, with the origin (0,0) at bottom-left.
3. **輸入測點資料** — 在表格輸入各測點的 X、Y 座標與濃度值，或點「上傳 CSV」匯入（自動辨識 `x`、`y`、`c`／`concentration`／`濃度` 欄位），也可先按「載入範例資料」試用。系統自動執行 QAQC 並更新統計框；疑似異常高值會以 ⚠ 標記，**點該 ⚠ 圖示即可決定是否納入計算**。
   **Enter measurement data** — type X, Y and concentration into the table, upload a CSV (columns `x`, `y`, `c`/`concentration`/`濃度` are auto-detected), or click "Load Sample Data". QA/QC and the statistics box update automatically; suspected outliers are flagged with ⚠ — **click that ⚠ to include or exclude each one from the computation**.
4. **選擇插值方法、參數與圖表設定** — 選擇插值方法、網格解析度、濃度單位與 OEL 閾值；於「圖表設定」自訂標題、色階、分佈圖不透明度、標註字體與點大小。
   **Choose method, parameters & chart settings** — interpolation method, grid resolution, unit, OEL threshold; customize title, color scale, contour opacity, label font, and marker size under "Chart Settings".
5. **（選用）套用平面圖** — 上傳平面圖後自動縮放至場域大小；點「調整位置與大小」可直接在圖面上拖移藍框與拉動四角縮放。
   **(Optional) Apply a floor plan** — the uploaded plan is scaled to the field size; click "Adjust position & size" to drag and resize it directly on the plot.
6. **產生與匯出** — 點「產生分佈圖」繪製結果，再以「下載 PNG」或「下載網格 CSV」匯出。
   **Generate & export** — click "Generate Map", then export via "Download PNG" or "Download Grid CSV".

## 📐 插值方法比較 / Interpolation Methods Comparison

| 方法 Method | 優點 Strengths | 限制 Limitations | 建議使用情境 Recommended Use |
|---|---|---|---|
| **IDW**（反距離加權） | 快速、穩定、不會產生離譜外推值；結果必落在實測值範圍內 | 易出現「靶心」同心圓假象；無法估計低於／高於所有測點的值 | 測點少（4–10 點）、需要快速概覽，或其他方法不穩定時的保底選擇 |
| **線性 Linear**（三角網格） | 簡單直觀、測點處完全吻合、不外推 | 凸包外無定義（以最近值填補成平台）；曲面有稜角、不平滑 | 測點分佈均勻且涵蓋全區、希望保守呈現實測值之間的變化 |
| **RBF**（薄板樣條） | 曲面平滑美觀、適合不規則散佈測點 | 可能過衝（產生超出實測範圍甚至負值）；測點很多時較耗時 | 測點 10–100 點、濃度場預期連續平滑（如通風混合良好的廠房） |
| **Spline**（雙三次樣條） | 對較密的網格狀佈點可產生非常平滑的曲面 | 需先將測點彙整成規則網格（資訊損失）；少於 16 點自動改用 RBF；可能過衝 | 系統性網格佈點（如逐格巡檢量測）且點數較多時 |
| **Kriging**（普通克利金） | 地統計最佳線性無偏估計，考慮空間自相關結構，學理依據最強 | 點數過少時半變異圖擬合不可靠；計算量較大；本工具未安裝 pykrige 時使用內建基礎實作 | 測點 ≥ 15 點且具空間相關性，需要正式報告等級的估計時 |

> 注：瀏覽器版 Pyodide 無法安裝含 C 擴充的 `pykrige` 時，工具會自動改用內建的純 Python 普通克利金（球型半變異模型），並於介面標示「Kriging（基礎實作 / basic implementation）」。
> Note: when `pykrige` (which ships C extensions) cannot be installed under Pyodide, the tool falls back to a built-in pure-Python Ordinary Kriging (spherical variogram) and labels it "Kriging (basic implementation)" in the UI.

## 📄 CSV 格式 / CSV Format

```csv
x,y,c
2,2,520
5,2,310
5,5,240
```

欄位名稱可為 `x`/`X`、`y`/`Y`、`c`/`C`/`concentration`/`濃度`（不分大小寫）；無標題列時依序取前三欄為 x、y、c。
Column headers may be `x`/`X`, `y`/`Y`, `c`/`C`/`concentration`/`濃度` (case-insensitive); header-less files use the first three columns as x, y, c.

## 🌐 部署到 GitHub Pages / Deploying to GitHub Pages

1. **建立儲存庫並推送 / Create a repo and push:**
   ```bash
   git init
   git add index.html guide.html README.md .github
   git commit -m "Workplace concentration contour tool"
   git branch -M main
   git remote add origin https://github.com/<your-account>/<your-repo>.git
   git push -u origin main
   ```
2. **啟用 Pages / Enable Pages:** 到儲存庫 **Settings → Pages**，將 **Source** 設為 **GitHub Actions**。
   In the repository go to **Settings → Pages** and set **Source** to **GitHub Actions**.
3. **自動部署 / Auto deploy:** 之後每次推送到 `main`，`.github/workflows/pages.yml` 會自動將整個儲存庫發佈為靜態網站（無建置步驟）。網址為 `https://<your-account>.github.io/<your-repo>/`。
   Every push to `main` triggers the workflow, which publishes the repository root as a static site (no build step). The site appears at `https://<your-account>.github.io/<your-repo>/`.

> 本工具所有運算皆在使用者瀏覽器內完成，量測資料不會上傳到任何伺服器。
> All computation happens in the user's browser; measurement data never leaves the machine.

## 🛠 技術架構 / Tech Stack

- [Pyodide](https://pyodide.org) v0.29 — 瀏覽器內 Python 3.13 runtime（numpy、scipy、pandas）
- [Plotly.js](https://plotly.com/javascript/) — 等值線圖渲染
- [Papa Parse](https://www.papaparse.com/) — CSV 解析
- [Tailwind CSS](https://tailwindcss.com/) — 介面樣式
- 主程式為單一 `index.html`（所有程式碼內嵌），另含獨立說明頁 `guide.html`；函式庫皆由 CDN 載入

## ⚠️ 注意事項 / Disclaimer

插值結果僅為實測點之間的數學估計，僅供作業環境監測規劃與風險溝通參考，不能取代法規要求之採樣策略與合規性判定。
Interpolated surfaces are mathematical estimates between measured points. They are intended for monitoring planning and risk communication, not as a substitute for regulatory sampling strategies or compliance determinations.
