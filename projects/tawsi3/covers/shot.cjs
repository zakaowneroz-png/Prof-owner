const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: +(process.argv[4]||1) });
  await p.goto('file://' + __dirname + '/cover.html?bg=' + process.argv[2]); await p.waitForFunction(() => document.body.dataset.ready); await p.waitForTimeout(500);
  await p.screenshot({ path: process.argv[3], type: process.argv[3].endsWith('jpg') ? 'jpeg' : 'png', ...(process.argv[3].endsWith('jpg') ? { quality: 92 } : {}) }); await b.close(); })();
