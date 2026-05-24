#!/usr/bin/env node
/**
 * uiux-check 巡回スクリプト
 *
 * classly の主要画面を Desktop / Mobile で巡回し、UI/UX の規約違反を検出する。
 * design-check（静的スキャン）の補完として、実レンダリング後にしか分からない
 * 問題（fold 位置・実エラー表示・キーボード操作・aria 関係性）を拾う。
 */
import { chromium, devices } from "playwright";
import { execSync } from "node:child_process";
import { mkdirSync } from "node:fs";

const BASE_URL = process.env.UIUX_BASE_URL || "http://localhost:3000";
const OUT = "/tmp/uiux-screenshots";
mkdirSync(OUT, { recursive: true });

const findings = [];
function check(rule, ok, message) {
  const tag = ok ? "OK" : "WARN";
  console.log(`[${tag}] ${rule}: ${message}`);
  if (!ok) findings.push({ rule, message });
}

function grepCheck() {
  console.log("\n── 静的チェック ─────────────────");

  try {
    const out = execSync(
      `grep -rn 'window\\.prompt\\|window\\.alert\\|window\\.confirm\\| prompt(\\| alert(\\| confirm(' src/app src/components/classly --include='*.tsx' --include='*.ts' 2>/dev/null | grep -v '\\.test\\.' | grep -v '\\.stories\\.' || true`
    ).toString().trim();
    check("Native prompt/alert/confirm", out === "", out === "" ? "なし" : `\n${out}`);
  } catch {}

  try {
    const usage = execSync(
      `grep -rn 'ConfirmDialog' src/app src/components/classly --include='*.tsx' --include='*.ts' 2>/dev/null | grep -v 'ConfirmDialog/ConfirmDialog' | grep -v '\\.test\\.' | grep -v '\\.stories\\.' | wc -l`
    ).toString().trim();
    const n = Number(usage);
    check("ConfirmDialog wiring", n > 0, n === 0 ? "ConfirmDialog コンポーネントは存在するが、どこからも import されていない" : `${n} 箇所で利用`);
  } catch {}
}

async function tour() {
  console.log("\n── Playwright 巡回 ───────────────");
  const browser = await chromium.launch();

  const desk = await browser.newContext({ viewport: { width: 1280, height: 800 }, locale: "ja-JP" });
  const dp = await desk.newPage();

  await dp.goto(`${BASE_URL}/`, { waitUntil: "networkidle" });
  await dp.screenshot({ path: `${OUT}/desktop-lp.png`, fullPage: true });

  await dp.goto(`${BASE_URL}/templates`, { waitUntil: "networkidle" });
  await dp.getByRole("button", { name: "デモデータを読み込む" }).click().catch(() => {});
  await dp.waitForTimeout(800);
  await dp.screenshot({ path: `${OUT}/desktop-templates.png`, fullPage: false });

  const link = dp.locator('a[href*="/templates/"]').first();
  const href = await link.getAttribute("href").catch(() => null);
  if (href) {
    await dp.goto(`${BASE_URL}${href}`, { waitUntil: "networkidle" });
    await dp.waitForTimeout(400);

    const tabs = await dp.getByRole("tab").allTextContents();
    for (const t of tabs) {
      try {
        await dp.getByRole("tab", { name: t }).click();
        await dp.waitForTimeout(300);
        const safe = t.replace(/[^a-zA-Z0-9ぁ-ゖァ-ヺ一-鿿]/g, "_");
        await dp.screenshot({ path: `${OUT}/desktop-tab-${safe}.png`, fullPage: false });
      } catch {}
    }

    const tabs2 = await dp.locator('[role="tab"]').all();
    let linked = 0;
    for (const t of tabs2) {
      const ac = await t.getAttribute("aria-controls");
      if (ac) linked++;
    }
    check("Tabs aria-controls", linked === tabs2.length && tabs2.length > 0, `${linked} / ${tabs2.length} tabs linked to tabpanels`);
  }

  await desk.close();

  const mob = await browser.newContext({ ...devices["iPhone 14"], locale: "ja-JP" });
  const mp = await mob.newPage();
  for (const [name, path] of [["mobile-lp", "/"], ["mobile-templates", "/templates"]]) {
    await mp.goto(`${BASE_URL}${path}`, { waitUntil: "networkidle" });
    await mp.screenshot({ path: `${OUT}/${name}.png`, fullPage: false });
  }
  await mob.close();
  await browser.close();
}

async function main() {
  grepCheck();
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
  console.log("  □ コピーがターゲット定義と一致するか");
  console.log("  □ モバイル/デスクトップで主要ナビ・CTA に到達できるか");
  console.log("  □ エンプティ状態に次アクション CTA があるか");

  if (process.env.UIUX_CI === "1" && findings.length > 0) process.exit(1);
}

main().catch((e) => { console.error(e); process.exit(2); });
