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
  r = await call('POST', '/auth/login', { identifier: '0901000001', password: '123456' });
  check('login bang so dien thoai', r.status === 200 && r.j.data.user.email === 'an@example.com', r.status);
  r = await call('GET', '/auth/verification-channels');
  check('kenh nhan ma xac nhan', r.status === 200 && 'email' in r.j.data && 'sms' in r.j.data, JSON.stringify(r.j?.data));
  r = await call('POST', '/auth/register', { fullName: 'Test', email: 'an@example.com', phone: '0911222333', password: '123456', channel: 'EMAIL' });
  check('dang ky email trung -> 409', r.status === 409 && r.j.errorCode === 'EMAIL_EXISTS', r.j?.errorCode);
  r = await call('POST', '/auth/register', { fullName: 'Test', email: 'moi@example.com', phone: '0901000002', password: '123456', channel: 'SMS' });
  check('dang ky SDT trung -> 409', r.status === 409 && r.j.errorCode === 'PHONE_EXISTS', r.j?.errorCode);
  r = await call('POST', '/auth/register/verify', { verificationId: 'khong-ton-tai', code: '123456' });
  check('xac nhan ma phien khong ton tai -> 404', r.status === 404, r.j?.errorCode);
  r = await call('GET', '/users/me', null, tok); check('users/me', r.status === 200, r.j?.data?.fullName);
  r = await call('GET', '/stations'); check('stations (453 bus + 20 metro + 49 xe dap + 49 xe dien)', r.j?.data?.length === 571, r.j?.data?.length);
  r = await call('GET', '/stations/nearby?lat=21.0285&lng=105.8542&radius=1'); check('stations/nearby', r.status === 200 && r.j.data.length > 0, r.j?.data?.length);
  r = await call('GET', '/stations/1'); check('station detail', r.status === 200 && r.j.data.routes.length > 0, `routes=${r.j?.data?.routes?.length}`);
  r = await call('GET', '/routes/1'); check('route detail (tuyen 23: 34 diem dung)', r.status === 200 && r.j.data.stations.length === 34, r.j?.data?.stations?.length);
  r = await call('GET', '/routes/1/trips?upcoming=true'); check('route trips', r.status === 200, `trips=${r.j?.data?.length}`);
  r = await call('GET', '/attractions?category=' + encodeURIComponent('Bảo tàng')); check('attractions filter', r.j?.data?.length === 3, r.j?.data?.length);
  r = await call('GET', '/attractions/11'); check('attraction detail', r.status === 200 && Array.isArray(r.j.data.highlights), r.j?.data?.name);
  { // Trang chi tiet: thong tin nhanh, moc lich su, tuyen dung tai tram gan, dia diem lan can
    const d = r.j?.data;
    check('chi tiet: thong tin nhanh + moc lich su', d?.facts?.length >= 3 && d.facts.every((f) => f.label && f.value) && d?.timeline?.length >= 2 && d.timeline.every((t) => t.year && t.event), `facts=${d?.facts?.length} timeline=${d?.timeline?.length}`);
    const na = d?.nearbyAttractions ?? [];
    check('chi tiet: toi da 4 dia diem lan can trong 3 km, gan nhat truoc', na.length > 0 && na.length <= 4 && na.every((n, i) => n.attractionId !== 11 && n.distanceMeters <= 3000 && n.walkingMinutes >= 1 && (i === 0 || na[i - 1].distanceMeters <= n.distanceMeters)), na.map((n) => `${n.name} ${n.distanceMeters}m`).join(', '));
    check('chi tiet: tram gan kem cac tuyen dung tai tram', d?.nearbyStations?.length > 0 && d.nearbyStations.every((s) => Array.isArray(s.routes)) && d.nearbyStations.some((s) => s.routes.length > 0), d?.nearbyStations?.map((s) => `${s.stationName}[${s.routes.map((x) => x.routeCode).join(' ')}]`).join(', '));
    // Du lieu day du: ca 20 dia diem deu co >= 4 thong tin nhanh va >= 2 moc lich su
    r = await call('GET', '/attractions');
    const thin = [];
    for (const it of r.j?.data ?? []) {
      const x = (await call('GET', `/attractions/${it.attractionId}`)).j?.data;
      if (!(x?.facts?.length >= 4 && x?.timeline?.length >= 2 && x?.images?.length >= 5)) thin.push(`${it.name} f=${x?.facts?.length} t=${x?.timeline?.length} i=${x?.images?.length}`);
    }
    check('20 dia diem: du thong tin nhanh, moc lich su, 5 anh', (r.j?.data?.length ?? 0) === 20 && thin.length === 0, thin.join('; ') || `${r.j?.data?.length} dia diem`);
  }
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
  // ---- Thanh toan THE (cong mo phong) ----
  r = await call('GET', '/payments/methods'); check('payment methods (the + chuyen khoan, ' + (r.j?.data?.banks?.length) + ' ngan hang)', r.status === 200 && r.j.data.card.enabled && r.j.data.banks.length >= 10);
  const intl = (num, extra = {}) => ({ orderId, cardKind: 'INTERNATIONAL', cardNumber: num, cardHolder: 'NGUYEN VAN AN', expiry: '12/30', cvv: '123', ...extra });
  r = await call('POST', '/payments', { orderId, method: 'MOCK' }, tok); check('API MOCK cu da bo -> 404', r.status === 404, r.j?.errorCode);
  r = await call('POST', '/payments/card', intl('4242424242424241'), tok); check('so the sai Luhn -> 400', r.status === 400 && r.j.errorCode === 'CARD_INVALID' && !!r.j.details.cardNumber, JSON.stringify(r.j?.details));
  r = await call('POST', '/payments/card', intl('4242424242424242', { expiry: '01/20', cvv: '1' }), tok); check('the het han + CVV sai -> 400', r.status === 400 && !!r.j.details.expiry && !!r.j.details.cvv);
  r = await call('POST', '/payments/card', intl('4000000000000002'), tok); check('the bi tu choi -> FAILED', r.status === 200 && r.j.data.status === 'FAILED' && r.j.data.ticketIds.length === 0, r.j?.data?.message);
  r = await call('POST', '/payments/card', intl('4242 4242 4242 4242'), tok); check('the Visa -> SUCCESS, 3 ve', r.status === 201 && r.j.data.ticketIds.length === 3 && r.j.data.cardLast4 === '4242', r.j?.data?.cardBrand);
  const ticketId = r.j?.data?.ticketIds?.[0];
  r = await call('POST', '/payments/card', intl('4242424242424242'), tok); check('thanh toan lai -> 409', r.status === 409, r.j?.errorCode);
  r = await call('GET', `/orders/${orderId}`, null, tok); check('chi luu 4 so cuoi the', r.j?.data?.payments?.every((p) => !JSON.stringify(p).includes('4242424242424242')) && r.j.data.payments[0].cardLast4 === '4242');
  // ---- Chuyen khoan QR: PENDING cho toi khi tien ve ----
  r = await call('POST', '/auth/login', { email: 'admin@example.com', password: '123456' }); const adm = r.j?.data?.token;
  r = await call('GET', '/admin/payment-settings', null, adm); const hadAccount = !!r.j?.data?.accountNo;
  if (!hadAccount) { r = await call('PUT', '/admin/payment-settings', { bankBin: '970423', accountNo: '0123456789', accountName: 'Nguyễn Văn Test', transferExpiryMinutes: 30 }, adm);
    check('admin cai tai khoan nhan (ten -> in hoa khong dau)', r.status === 200 && r.j.data.accountName === 'NGUYEN VAN TEST', r.j?.data?.bankName); }
  r = await call('PUT', '/admin/payment-settings', { bankBin: '999999', accountNo: '1', accountName: 'X' }, adm); check('cai dat sai -> 400', r.status === 400);
  r = await call('POST', '/orders', { items: [{ ticketTypeId: 1, quantity: 1 }] }, tok); const o2 = r.j?.data?.orderId;
  r = await call('POST', '/payments/bank-transfer', { orderId: o2 }, tok); const tr = r.j?.data;
  const crc = (s) => { let c = 0xffff; for (const ch of s) { c ^= ch.charCodeAt(0) << 8; for (let i = 0; i < 8; i++) c = c & 0x8000 ? ((c << 1) ^ 0x1021) & 0xffff : (c << 1) & 0xffff; } return c.toString(16).toUpperCase().padStart(4, '0'); };
  check('tao QR chuyen khoan -> PENDING', r.status === 201 && tr.status === 'PENDING' && /^HNG\d+[A-Z]{4}$/.test(tr.transferContent) && tr.qrImage.startsWith('data:image/png'), tr?.transferContent);
  check('VietQR payload hop le (so tien, noi dung, CRC)', tr?.qrPayload?.startsWith('000201010212') && tr.qrPayload.includes('A000000727') && tr.qrPayload.includes('54047000') && tr.qrPayload.includes(tr.transferContent) && crc(tr.qrPayload.slice(0, -4)) === tr.qrPayload.slice(-4));
  r = await call('POST', '/payments/bank-transfer', { orderId: o2 }, tok); check('tao lai -> dung lai ma cu', r.j?.data?.paymentId === tr?.paymentId && r.j.data.transferContent === tr.transferContent);
  r = await call('POST', `/payments/${tr?.paymentId}/transferred`, null, tok); check('khach bao da chuyen -> VAN PENDING', r.status === 200 && r.j.data.status === 'PENDING' && !!r.j.data.customerNotifiedAt);
  r = await call('GET', `/orders/${o2}`, null, tok); check('chua co tien -> don chua PAID, chua co ve', r.j?.data?.status === 'PENDING' && r.j.data.tickets.length === 0);
  r = await call('POST', `/admin/payments/${tr?.paymentId}/confirm`, {}, tok); check('user tu xac nhan -> 403', r.status === 403);
  r = await call('POST', '/payments/webhooks/sepay', { transferType: 'in', content: tr?.transferContent, transferAmount: 7000 }); check('webhook khong co API key -> bi chan', r.status === 401 || r.status === 403, r.j?.errorCode);
  r = await call('GET', '/admin/payments?method=BANK_TRANSFER&status=PENDING&search=' + tr?.transferContent, null, adm); check('admin thay giao dich cho doi soat', r.j?.data?.items?.[0]?.paymentId === tr?.paymentId);
  r = await call('POST', `/admin/payments/${tr?.paymentId}/confirm`, { bankReference: 'FT-TEST-' + SUF }, adm); check('admin xac nhan da nhan tien -> SUCCESS', r.status === 200 && r.j.data.status === 'SUCCESS', r.j?.data?.confirmedBy);
  r = await call('GET', `/payments/${tr?.paymentId}`, null, tok); check('khach thay SUCCESS + ve phat hanh', r.j?.data?.status === 'SUCCESS' && r.j.data.ticketIds.length === 1);
  r = await call('POST', `/admin/payments/${tr?.paymentId}/confirm`, {}, adm); check('xac nhan lan 2 -> 409', r.status === 409, r.j?.errorCode);
  r = await call('POST', '/orders', { items: [{ ticketTypeId: 1, quantity: 1 }] }, tok); const o3 = r.j?.data?.orderId;
  r = await call('POST', '/payments/bank-transfer', { orderId: o3 }, tok); const tr3 = r.j?.data;
  r = await call('POST', `/admin/payments/${tr3?.paymentId}/reject`, { note: 'Khong thay tien' }, adm); check('admin tu choi -> FAILED', r.j?.data?.status === 'FAILED');
  r = await call('POST', '/payments/bank-transfer', { orderId: o3 }, tok); check('tao ma moi sau khi bi tu choi', r.status === 201 && r.j.data.paymentId !== tr3?.paymentId); const tr4 = r.j?.data;
  r = await call('POST', `/orders/${o3}/cancel`, null, tok); r = await call('GET', `/payments/${tr4?.paymentId}`, null, tok); check('huy don -> huy ma chuyen khoan', r.j?.data?.status === 'CANCELLED');
  if (!hadAccount) { r = await call('DELETE', '/admin/payment-settings', null, adm); check('tra lai cai dat (tat chuyen khoan)', r.status === 200 && !r.j.data.accountNo); }
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
  r = await call('GET', '/admin/attractions/18', null, at); const tl0 = r.j?.data?.timeline ?? null;
  const tlCount0 = String(tl0 ?? '').split('\n').filter((l) => l.includes('|')).length;
  r = await call('PUT', '/admin/attractions/18', { timeline: '2017 | Phố sách khai trương\n2024 | Mốc thử nghiệm ' + SUF }, at);
  r = await call('GET', '/attractions/18'); check('admin sua moc lich su -> trang chi tiet cap nhat', r.j?.data?.timeline?.length === 2 && r.j.data.timeline[0].year === '2017', JSON.stringify(r.j?.data?.timeline?.[1]));
  r = await call('PUT', '/admin/attractions/18', { facts: 'Nhãn | ' + 'x'.repeat(4000) }, at); check('thong tin nhanh qua 4000 ky tu -> 400', r.status === 400 && r.j.errorCode === 'VALIDATION_ERROR', r.j?.errorCode);
  r = await call('PUT', '/admin/attractions/18', { timeline: null }, at); r = await call('GET', '/attractions/18');
  check('xoa moc lich su -> mang rong, trang van hien', r.status === 200 && Array.isArray(r.j.data.timeline) && r.j.data.timeline.length === 0 && r.j.data.facts.length >= 4, r.j?.data?.name);
  r = await call('PUT', '/admin/attractions/18', { timeline: tl0 }, at); r = await call('GET', '/attractions/18'); check('tra lai moc lich su cu', r.status === 200 && tlCount0 >= 2 && r.j.data.timeline.length === tlCount0, `${r.j?.data?.timeline?.length}/${tlCount0}`);
  r = await call('GET', '/admin/trips?routeId=1', null, at); const busyTrip = r.j?.data?.[0];
  r = await call('DELETE', `/admin/vehicles/${busyTrip?.vehicleId}`, null, at); check('xoa xe dang co chuyen -> 409', r.status === 409, r.j?.errorCode);
  r = await call('POST', '/admin/trips', { routeId: 1, vehicleId: busyTrip?.vehicleId, tripCode: 'BUSTEST' + SUF + '-X', departureTime: busyTrip?.departureTime, arrivalTime: busyTrip?.arrivalTime }, at);
  check('xe da co chuyen trung gio -> 409', r.status === 409 && r.j.errorCode === 'VEHICLE_SCHEDULE_CONFLICT', r.j?.message);
  r = await call('POST', '/admin/trips', { routeId: 1, vehicleId: busyTrip?.vehicleId, tripCode: 'BUSTEST' + SUF + '-Y', departureTime: '10:00', arrivalTime: '09:00' }, at);
  check('gio den truoc gio di -> 400', r.status === 400 && r.j.errorCode === 'INVALID_TRIP_TIME', r.j?.errorCode);
  r = await call('GET', '/admin/trips', null, at); check('lich trinh tra du chuyen (> 500)', r.j?.data?.length > 1000, r.j?.data?.length);
  // ---- Cac truong hop bien / bao mat ----
  r = await call('GET', '/attractions?sort=constructor'); check('sort la -> mac dinh, khong loi 500', r.status === 200, r.status);
  r = await call('GET', '/stations/99999999999'); check('id qua lon -> 400', r.status === 400, r.j?.errorCode);
  r = await call('PUT', '/users/me', { fullName: '' }, tok); check('ho ten rong -> 400 (khong loi 500)', r.status === 400, r.j?.errorCode);
  r = await call('POST', '/routing/search', { origin: { latitude: 10.77, longitude: 106.70 }, destination: { attractionId: 1 } }); check('diem ngoai Ha Noi -> 400', r.status === 400 && r.j.errorCode === 'OUT_OF_SERVICE_AREA', r.j?.message);
  r = await call('POST', '/routing/search', { origin: { attractionId: 2 }, destination: { attractionId: 1 }, departureTime: '25:99' }); check('gio khoi hanh sai -> 400', r.status === 400 && r.j.errorCode === 'INVALID_TIME', r.j?.errorCode);
  r = await call('POST', '/admin/tickets/verify', { qrData: 'PTA|TK-X|ÀÀÀÀ' }, at); check('QR chu ky ky tu la -> khong hop le (khong loi 500)', r.status === 200 && r.j.data.valid === false, r.status);
  r = await call('POST', '/auth/login', { email: 'cuong@example.com', password: '123456' }); const ct = r.j?.data?.token;
  r = await call('PUT', '/admin/users/3', { status: 'LOCKED' }, at);
  r = await call('GET', '/users/me', null, ct); check('khoa tai khoan -> token cu bi chan ngay', r.status === 401 && r.j.errorCode === 'ACCOUNT_INACTIVE', r.j?.errorCode);
  r = await call('PUT', '/admin/users/3', { status: 'ACTIVE' }, at);
  r = await call('GET', '/users/me', null, ct); check('mo khoa -> dung lai binh thuong', r.status === 200, r.status);
  r = await call('PUT', '/admin/users/4', { status: 'LOCKED' }, at); check('admin tu khoa minh -> 400', r.status === 400, r.j?.errorCode);
  r = await call('POST', '/admin/routing/rebuild', null, at); check('rebuild graph', r.status === 200, JSON.stringify(r.j?.data));
  console.log(`\n${pass} PASS, ${fail} FAIL`);
})().catch((e) => console.log('CRASH', e));
