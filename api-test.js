// Test toan luong API tren backend dang chay (node api-test.js)
const B = 'http://localhost:5000/api/v1';
let pass = 0, fail = 0;
async function call(method, path, body, token) {
  const r = await fetch(B + path, { method, headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) }, body: body ? JSON.stringify(body) : undefined });
  const j = await r.json().catch(() => null);
  return { status: r.status, j };
}
function check(name, cond, info = '') { cond ? pass++ : fail++; console.log(`${cond ? 'PASS' : 'FAIL'}  ${name} ${info}`); }
(async () => {
  const SUF = Date.now().toString(36).toUpperCase(); // ma test khong trung giua cac lan chay
  let r = await call('POST', '/auth/login', { email: 'an@example.com', password: '123456' });
  check('login user', r.status === 200 && r.j.data.token, r.status);
  const tok = r.j?.data?.token;
  r = await call('POST', '/auth/login', { email: 'an@example.com', password: 'sai' });
  check('login sai mat khau -> 401', r.status === 401, r.j?.errorCode);
  r = await call('GET', '/users/me', null, tok); check('users/me', r.status === 200, r.j?.data?.fullName);
  r = await call('GET', '/stations'); check('stations (453 bus + 20 metro + 49 xe dap + 49 xe dien)', r.j?.data?.length === 571, r.j?.data?.length);
  r = await call('GET', '/stations/nearby?lat=21.0285&lng=105.8542&radius=1'); check('stations/nearby', r.status === 200 && r.j.data.length > 0, r.j?.data?.length);
  r = await call('GET', '/stations/1'); check('station detail', r.status === 200 && r.j.data.routes.length > 0, `routes=${r.j?.data?.routes?.length}`);
  r = await call('GET', '/routes/1'); check('route detail (tuyen 23: 34 diem dung)', r.status === 200 && r.j.data.stations.length === 34, r.j?.data?.stations?.length);
  r = await call('GET', '/routes/1/trips?upcoming=true'); check('route trips', r.status === 200, `trips=${r.j?.data?.length}`);
  r = await call('GET', '/attractions?category=' + encodeURIComponent('Bảo tàng')); check('attractions filter', r.j?.data?.length === 3, r.j?.data?.length);
  r = await call('GET', '/attractions/11'); check('attraction detail', r.status === 200 && Array.isArray(r.j.data.highlights), r.j?.data?.name);
  r = await call('GET', '/attractions/recommend?categories=' + encodeURIComponent('Di tích') + '&lat=21.0285&lng=105.8542'); check('recommend', r.status === 200, r.j?.data?.[0]?.name);
  for (const pref of ['FASTEST', 'CHEAPEST', 'LEAST_WALKING', 'FEWEST_TRANSFERS']) {
    r = await call('POST', '/routing/search', { origin: { attractionId: 6 }, destination: { attractionId: 16 }, preference: pref, departureTime: '08:00' }, tok);
    check('routing ' + pref, r.status === 200 && r.j.data.routes.length > 0, r.j?.data?.routes?.map((x) => `${x.summary} ${x.totalDuration}' ${x.totalFare}d`).join(' | '));
  }
  r = await call('POST', '/routing/search', { origin: { latitude: 21.0285, longitude: 105.8542 }, destination: { stationId: 457 }, preference: 'FASTEST' });
  check('routing toa do -> Ga Metro Lang', r.status === 200, r.j?.data?.routes?.[0]?.summary);
  r = await call('GET', '/ticket-types'); check('ticket-types', r.j?.data?.length === 6);
  r = await call('POST', '/orders', { items: [{ ticketTypeId: 1, quantity: 2 }, { ticketTypeId: 5, quantity: 1 }] }, tok);
  check('create order (2 x 7000 + 5000)', r.status === 201 && r.j.data.totalAmount === 19000, r.j?.data?.totalAmount);
  const orderId = r.j?.data?.orderId;
  r = await call('POST', '/payments', { orderId, method: 'MOCK', simulate: 'FAILED' }, tok); check('payment FAILED', r.j?.data?.status === 'FAILED');
  r = await call('POST', '/payments', { orderId, method: 'MOCK' }, tok); check('payment SUCCESS -> 3 ve', r.status === 201 && r.j.data.ticketIds.length === 3, r.j?.data?.ticketIds);
  const ticketId = r.j?.data?.ticketIds?.[0];
  r = await call('POST', '/payments', { orderId, method: 'MOCK' }, tok); check('thanh toan lai -> 409', r.status === 409, r.j?.errorCode);
  r = await call('GET', '/tickets/me', null, tok); check('tickets/me', r.status === 200, `so ve=${r.j?.data?.length}`);
  r = await call('GET', `/tickets/${ticketId}/qr`, null, tok); check('ticket QR', r.j?.data?.image?.startsWith('data:image/png'), r.j?.data?.payload);
  const payload = r.j?.data?.payload;
  r = await call('POST', '/trip-histories', { origin: 'Hỏa Lò', destination: 'Trấn Quốc', routeData: { route: '09A > BIKE-SHARE' } }, tok); check('save trip', r.status === 201);
  r = await call('GET', '/trip-histories', null, tok); check('trip histories', r.status === 200, r.j?.data?.length);
  r = await call('GET', '/admin/statistics', null, tok); check('user vao admin -> 403', r.status === 403);
  r = await call('POST', '/auth/login', { email: 'admin@example.com', password: '123456' }); const at = r.j?.data?.token; check('login admin', !!at);
  r = await call('GET', '/admin/statistics?days=14', null, at); check('admin statistics', r.status === 200, `revenue=${r.j?.data?.overview?.totalRevenue}`);
  r = await call('POST', '/admin/tickets/verify', { qrData: payload }, at); check('soat ve hop le -> USED', r.j?.data?.valid === true && r.j.data.ticket.status === 'USED', r.j?.data?.reason);
  r = await call('POST', '/admin/tickets/verify', { qrData: payload }, at); check('soat lai -> khong hop le', r.j?.data?.valid === false, r.j?.data?.reason);
  r = await call('POST', '/admin/tickets/verify', { qrData: payload.slice(0, -2) + 'ZZ' }, at); check('QR gia -> sai chu ky', r.j?.data?.valid === false, r.j?.data?.reason);
  r = await call('GET', '/admin/users?page=1&pageSize=10', null, at); check('admin users', r.j?.data?.total === 4);
  r = await call('GET', '/admin/orders?status=PAID', null, at); check('admin orders', r.status === 200, r.j?.data?.total);
  r = await call('POST', '/admin/stations', { stationCode: 'BUS-TEST-' + SUF, stationName: 'Tram test', latitude: 21.03, longitude: 105.85, transportTypeId: 1 }, at);
  check('admin create station', r.status === 201, r.j?.data?.stationId); const sid = r.j?.data?.stationId;
  r = await call('POST', '/admin/routes', { routeCode: 'BUSTEST' + SUF, routeName: 'Tuyen test', transportTypeId: 1, stations: [{ stationId: 1 }, { stationId: sid }] }, at);
  check('admin create route + stations', r.status === 201 && r.j.data.stations.length === 2); const rid = r.j?.data?.routeId;
  r = await call('POST', '/admin/trips', { routeId: rid, vehicleId: 1, tripCode: 'BUSTEST' + SUF + '-T1', departureTime: '09:00', arrivalTime: '09:20' }, at);
  check('admin create trip + stoptimes', r.status === 201 && r.j.data.stopTimes.length === 2, r.j?.data?.stopTimes?.map((s) => s.arrivalTime).join(','));
  r = await call('DELETE', `/admin/trips/${r.j?.data?.tripId}`, null, at); check('admin delete trip', r.status === 200);
  r = await call('DELETE', `/admin/routes/${rid}`, null, at); check('admin soft delete route', r.status === 200);
  r = await call('DELETE', `/admin/stations/${sid}`, null, at); check('admin soft delete station', r.status === 200);
  r = await call('DELETE', '/admin/vehicles/1', null, at); check('xoa xe dang co chuyen -> 409', r.status === 409, r.j?.errorCode);
  r = await call('PUT', '/admin/users/4', { status: 'LOCKED' }, at); check('admin tu khoa minh -> 400', r.status === 400, r.j?.errorCode);
  r = await call('POST', '/admin/routing/rebuild', null, at); check('rebuild graph', r.status === 200, JSON.stringify(r.j?.data));
  console.log(`\n${pass} PASS, ${fail} FAIL`);
})().catch((e) => console.log('CRASH', e));
