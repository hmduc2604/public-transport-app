// Kiem tra do on dinh backend dang chay (node stability-test.js, can Node 18+)
//  1. Tai dong thoi: doc du lieu, tim lo trinh, API can dang nhap, tao / huy / thanh toan don cung luc
//  2. Mat ket noi database: dung SQL Server 10 giay roi bat lai
//     -> backend phai tra 503 (khong treo, khong sap) va tu ket noi lai khi DB chay lai
// Luu y: buoc 2 tam dung container pta-sql - chi chay tren may dang thu nghiem.
const { exec } = require('child_process');
const { promisify } = require('util');
const execP = promisify(exec);

const B = 'http://localhost:5000/api/v1';
const CONTAINER = 'pta-sql';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const now = () => new Date().toTimeString().slice(0, 8);
let pass = 0, fail = 0;
function check(name, cond, info = '') { cond ? pass++ : fail++; console.log(`${cond ? 'PASS' : 'FAIL'}  ${name} ${info}`); }
const tally = (arr) => arr.reduce((a, s) => ((a[s] = (a[s] || 0) + 1), a), {});

async function req(method, path, body, token) {
  const t0 = performance.now();
  try {
    const r = await fetch(B + path, {
      method,
      headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) },
      body: body ? JSON.stringify(body) : undefined,
      signal: AbortSignal.timeout(20000),
    });
    const text = await r.text();
    let j = null;
    try { j = JSON.parse(text); } catch { /* khong phai JSON */ }
    return { status: r.status, ms: performance.now() - t0, j };
  } catch (e) {
    return { status: 'ERR_' + (e.cause?.code || e.name), ms: performance.now() - t0, j: null };
  }
}

/** Gui `total` request voi `conc` request chay song song; gen(k) -> [method, path, body?, token?] */
async function load(name, total, conc, gen) {
  const lat = [], statuses = [];
  let next = 0;
  const t0 = performance.now();
  const worker = async () => {
    while (next < total) {
      const k = next++;
      const [m, p, b, tok] = gen(k);
      const r = await req(m, p, b, tok);
      lat.push(r.ms);
      statuses.push(r.status);
    }
  };
  await Promise.all(Array.from({ length: conc }, worker));
  const sec = (performance.now() - t0) / 1000;
  lat.sort((a, b) => a - b);
  const pc = (q) => Math.round(lat[Math.min(lat.length - 1, Math.floor(q * lat.length))]);
  const ok = statuses.filter((s) => s >= 200 && s < 300).length;
  console.log(`      ${name}: ${total} request, ${conc} song song, ${sec.toFixed(1)} s (${Math.round(total / sec)} req/s) | p50 ${pc(0.5)} ms, p95 ${pc(0.95)} ms, max ${Math.round(lat[lat.length - 1])} ms | ${JSON.stringify(tally(statuses))}`);
  return { ok, total, p95: pc(0.95) };
}

/** RAM (MB) cua tien trinh dang lang nghe cong 5000 */
async function backendMemMB() {
  try {
    const ps = '$p=(Get-NetTCPConnection -LocalPort 5000 -State Listen -ErrorAction Stop | Select-Object -First 1).OwningProcess; [math]::Round((Get-Process -Id $p).WorkingSet64/1MB)';
    const { stdout } = await execP(`powershell -NoProfile -Command "${ps}"`);
    return Number(stdout.trim()) || null;
  } catch {
    return null;
  }
}

(async () => {
  console.log(`[${now()}] KIEM TRA DO ON DINH BACKEND`);
  let r = await req('GET', '/health');
  check('backend dang chay', r.status === 200, String(r.status));
  if (r.status !== 200) return console.log('Hay chay run-all.bat truoc.');
  r = await req('POST', '/auth/login', { email: 'an@example.com', password: '123456' });
  const tok = r.j?.data?.token;
  check('dang nhap tai khoan thu', !!tok, String(r.status));
  const mem0 = await backendMemMB();

  // ------------------------------------------------------------------
  console.log(`\n[${now()}] 1. TAI DONG THOI`);
  const reads = [
    () => ['GET', '/attractions'],
    (k) => ['GET', `/attractions/${(k % 20) + 1}`],
    () => ['GET', '/stations/nearby?lat=21.0285&lng=105.8542&radius=1'],
    (k) => ['GET', `/stations/${(k % 400) + 1}`],
    (k) => ['GET', `/routes/${(k % 5) + 1}`],
    () => ['GET', '/ticket-types'],
    () => ['GET', '/attractions/recommend?categories=' + encodeURIComponent('Di tích') + '&lat=21.0285&lng=105.8542'],
  ];
  let L = await load('Doc du lieu (dia diem, tram, tuyen, gia ve)', 2000, 50, (k) => reads[k % reads.length](k));
  check('doc du lieu: 100% thanh cong', L.ok === L.total, `${L.ok}/${L.total}`);
  check('doc du lieu: 95% request duoi 1 giay', L.p95 < 1000, `p95 = ${L.p95} ms`);

  const prefs = ['FASTEST', 'CHEAPEST', 'LEAST_WALKING', 'FEWEST_TRANSFERS'];
  L = await load('Tim lo trinh giua 2 dia diem', 200, 20, (k) => {
    const a = ((k * 7) % 20) + 1;
    let b = ((k * 13 + 5) % 20) + 1;
    if (b === a) b = (b % 20) + 1;
    const dep = `${String(6 + (k % 15)).padStart(2, '0')}:${k % 2 ? '30' : '00'}`;
    return ['POST', '/routing/search', { origin: { attractionId: a }, destination: { attractionId: b }, preference: prefs[k % 4], departureTime: dep }];
  });
  check('tim lo trinh: 100% thanh cong', L.ok === L.total, `${L.ok}/${L.total}`);
  check('tim lo trinh: 95% request duoi 3 giay', L.p95 < 3000, `p95 = ${L.p95} ms`);

  const authed = ['/users/me', '/tickets/me', '/trip-histories', '/orders/me'];
  L = await load('API can dang nhap (ho so, ve, don, lich su)', 600, 30, (k) => ['GET', authed[k % authed.length], null, tok]);
  check('API can dang nhap: 100% thanh cong', L.ok === L.total, `${L.ok}/${L.total}`);

  const created = await Promise.all(Array.from({ length: 20 }, () => req('POST', '/orders', { items: [{ ticketTypeId: 1, quantity: 1 }] }, tok)));
  const oids = created.map((x) => x.j?.data?.orderId).filter(Boolean);
  const codes = created.map((x) => x.j?.data?.orderCode).filter(Boolean);
  check('tao 20 don cung luc: du 20 don, ma khong trung', oids.length === 20 && new Set(oids).size === 20 && new Set(codes).size === codes.length, JSON.stringify(tally(created.map((x) => x.status))));
  const cancelled = await Promise.all(oids.map((id) => req('POST', `/orders/${id}/cancel`, null, tok)));
  check('huy 20 don cung luc', cancelled.length === 20 && cancelled.every((x) => x.status === 200), JSON.stringify(tally(cancelled.map((x) => x.status))));

  r = await req('POST', '/orders', { items: [{ ticketTypeId: 1, quantity: 1 }] }, tok);
  const po = r.j?.data?.orderId;
  const card = { orderId: po, cardKind: 'INTERNATIONAL', cardNumber: '4242424242424242', cardHolder: 'NGUYEN VAN AN', expiry: '12/30', cvv: '123' };
  const pays = await Promise.all(Array.from({ length: 5 }, () => req('POST', '/payments/card', card, tok)));
  r = await req('GET', `/orders/${po}`, null, tok);
  const paidOk = pays.filter((x) => x.status === 201).length;
  check('5 lan thanh toan cung luc 1 don -> chi 1 lan tru tien, 1 ve', paidOk === 1 && pays.every((x) => x.status === 201 || x.status === 409) && r.j?.data?.tickets?.length === 1,
    `ket qua: ${pays.map((x) => x.status + (x.j?.errorCode ? ' ' + x.j.errorCode : '')).join(', ')}; so ve: ${r.j?.data?.tickets?.length}`);

  const mem1 = await backendMemMB();
  console.log(`      RAM backend: truoc ${mem0 ?? '?'} MB, sau khi chiu tai ${mem1 ?? '?'} MB`);

  // ------------------------------------------------------------------
  console.log(`\n[${now()}] 2. MAT KET NOI DATABASE (dung ${CONTAINER} 10 giay roi bat lai)`);
  const t0 = Date.now();
  const sec = () => (Date.now() - t0) / 1000;
  const events = [];
  const downStatus = [];
  let wentDown = false, recoveredAt = null, startedAt = null, health = null;
  const poller = (async () => {
    while (sec() < 240) {
      const x = await req('GET', '/attractions/1');
      const label = x.status + (x.j?.errorCode ? ` ${x.j.errorCode}` : '');
      if (!events.length || events[events.length - 1][1] !== label) events.push([sec().toFixed(1), label]);
      if (x.status !== 200) { wentDown = true; downStatus.push(x.status); }
      else if (wentDown && startedAt !== null) { recoveredAt = sec(); break; }
      await sleep(500);
    }
  })();
  try {
    await sleep(1000);
    await execP(`docker stop ${CONTAINER}`);
    events.push([sec().toFixed(1), '(SQL Server da dung)']);
    await sleep(10000);
    health = await req('GET', '/health');
  } finally {
    await execP(`docker start ${CONTAINER}`); // luon bat lai DB ke ca khi buoc tren loi
    startedAt = sec();
    events.push([startedAt.toFixed(1), '(SQL Server da bat lai)']);
  }
  await poller;
  console.log(`      Dien bien GET /attractions/1: ${events.map(([s, l]) => `${s}s ${l}`).join('  ->  ')}`);
  const st = tally(downStatus);
  check('khi DB tat: tra 503 DB_UNAVAILABLE (khong loi 500, khong treo, khong sap)', wentDown && Object.keys(st).every((s) => s === '503'), JSON.stringify(st));
  check('khi DB tat: API khong can DB van tra loi (/health)', health?.status === 200, String(health?.status));
  check('DB bat lai: backend tu ket noi lai (duoi 60 giay)', recoveredAt !== null && recoveredAt - startedAt < 60,
    recoveredAt !== null ? `sau ${(recoveredAt - startedAt).toFixed(1)} s` : 'khong phuc hoi sau 4 phut');

  r = await req('POST', '/auth/login', { email: 'an@example.com', password: '123456' });
  check('sau khi phuc hoi: dang nhap', r.status === 200, String(r.status));
  r = await req('POST', '/routing/search', { origin: { attractionId: 6 }, destination: { attractionId: 16 }, preference: 'FASTEST', departureTime: '08:00' });
  check('sau khi phuc hoi: tim lo trinh', r.status === 200 && r.j?.data?.routes?.length > 0, String(r.status));
  L = await load('Doc du lieu sau khi phuc hoi', 300, 30, (k) => reads[k % reads.length](k));
  check('sau khi phuc hoi: 100% thanh cong', L.ok === L.total, `${L.ok}/${L.total}`);

  console.log(`\n[${now()}] ${pass} PASS, ${fail} FAIL`);
})().catch((e) => console.log('CRASH', e));
