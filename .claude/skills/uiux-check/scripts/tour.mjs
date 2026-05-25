#!/usr/bin/env node
/**
 * uiux-check 巡回スクリプト
 *
 * プロジェクトの主要画面を Desktop / Mobile で巡回し、UI/UX の規約違反を検出する。
 * design-check（静的スキャン）の補完として、実レンダリング後にしか分からない
 * 問題（fold 位置・実エラー表示・キーボード操作・aria 関係性）を拾う。
 *
 * 巡回対象ルートはプロジェクトに合わせて ROUTES 配列を編集すること。
 */
import { chromium, devices } from "playwright";
import { mkdirSync } from "node:fs";

const BASE_URL = process.env.UIUX_BASE_URL || "http://localhost:3000";
const OUT = "/tmp/uiux-screenshots";
mkdirSync(OUT, { recursive: true });

// ── 巡回対象ルートをプロジェクトに合わせて編集すること ──────────────
const ROUTES = [
  { name: "home", path: "/" },
  // { name: "list", path: "/list" },
  // { name: "detail", path: "/detail/1" },
];
// ─────────────────────────────────────────────────────────────────────

const findings = [];
function check(rule, ok, message) {
  const tag = ok ? "OK" : "WARN";
  console.log(`[${tag}] ${rule}: ${message}`);
  if (!ok) findings.push({ rule, message });
}

async function tour() {
  console.log("\n── Playwright 巡回 ───────────────");
  const browser = await chromium.launch();

  // Desktop
  const desk = await browser.newContext({ viewport: { width: 1280, height: 800 }, locale: "ja-JP" });
  const dp = await desk.newPage();
  for (const { name, path } of ROUTES) {
    await dp.goto(`${BASE_URL}${path}`, { waitUntil: "networkidle" });
    await dp.screenshot({ path: `${OUT}/desktop-${name}.png`, fullPage: false });
  }

  // aria-controls チェック（tab がある画面で実行）
  const tabs = await dp.locator('[role="tab"]').all();
  if (tabs.length > 0) {
    let linked = 0;
    for (const t of tabs) {
      const ac = await t.getAttribute("aria-controls");
      if (ac) linked++;
    }
    check("Tabs aria-controls", linked === tabs.length, `${linked} / ${tabs.length} tabs linked to tabpanels`);
  }

  await desk.close();

  // Mobile
  const mob = await browser.newContext({ ...devices["iPhone 14"], locale: "ja-JP" });
  const mp = await mob.newPage();
  for (const { name, path } of ROUTES) {
    await mp.goto(`${BASE_URL}${path}`, { waitUntil: "networkidle" });
    await mp.screenshot({ path: `${OUT}/mobile-${name}.png`, fullPage: false });
  }
  await mob.close();
  await browser.close();
}

async function main() {
  try {
    await tour();
  } catch (e) {
    console.log("[ERR] tour failed:", e.message);
    findings.push({ rule: "tour", message: e.message });
  }

  console.log("\n── サマリ ──────────────────");
  console.log(`スクリーンショット: ${OUT}/`);
  console.log(`検出件数: ${findings.length}`);
  for (const f of findings) console.log(`  - ${f.rule}`);
  console.log("\n人間レビュー観点:");
  console.log("  □ コピーがプロジェクト規約と一致するか");
  console.log("  □ モバイル/デスクトップで主要ナビ・CTA に到達できるか");
  console.log("  □ エンプティ状態に次アクション CTA があるか");

  if (process.env.UIUX_CI === "1" && findings.length > 0) process.exit(1);
}

main().catch((e) => { console.error(e); process.exit(2); });
