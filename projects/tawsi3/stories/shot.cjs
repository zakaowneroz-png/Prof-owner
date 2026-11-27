const { chromium } = require('playwright');
(async () => { const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  for (const s of ['1','2','3']) { await p.goto('file://' + __dirname + '/story.html?s=' + s); await p.waitForFunction(() => document.body.dataset.ready); await p.waitForTimeout(300);
    await p.screenshot({ path: __dirname + '/story-' + s + '.jpg', type: 'jpeg', quality: 93 }); }
  await b.close(); })();
