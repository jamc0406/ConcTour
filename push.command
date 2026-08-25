#!/bin/bash
# 將本次 ConcTour 修改提交並推送至 GitHub。
# 用法：於 Finder 中雙擊本檔，或於終端機執行 bash push.command
set -e
cd "$(dirname "$0")"

# 清除先前殘留之 git 鎖檔（若存在）
[ -f .git/index.lock ] && rm -f .git/index.lock && echo "已清除殘留的 .git/index.lock"

git add -A
git status --short

git commit -F - <<'MSG'
固定克利金參數、標準資料表匯入匯出、圖面旋轉與多項修正

- 插值方法固定為普通克利金（線性變異函數 slope=1、nugget=0、異方性比 1），
  移除方法選擇；改用純 numpy 實作，啟動不再載入 scipy／pandas／pykrige
- 新增標準資料表（xlsx）匯入與匯出；重複量測 c1–c3 可選平均／單次／最大值
- 新增圖面旋轉 90° 按鈕；旋轉僅改變呈現，座標刻度與匯出 CSV 維持原值
- 網格改依場域長寬比配置，格點為正方形；解析度範圍 40–400
- 預設色階改為 Jet；新增測點濃度值顯示開關；圖表標題移至側欄最上方
- PNG 匯出改為沿用預覽版面自動計算尺寸
- 移除 OEL 紅色半透明填色，僅保留等值線，避免與色階疊合致判讀錯誤
- 修正匯入標準資料表誤報讀取失敗（呼叫未定義之 onDataChanged）
- 更新使用說明與免責聲明
MSG

git push origin main
echo
echo "已推送完成。GitHub Pages 通常需 1–2 分鐘更新："
echo "  https://jamc0406.github.io/ConcTour/"
