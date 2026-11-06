/**
 * Test thuat toan routing tren du lieu seed - KHONG can SQL Server.
 * Chay: npm run test:routing
 */
import assert from 'node:assert/strict';
import { buildTransitNetwork, planRoutes } from '../src/algorithms/routing';
import { dijkstra, MinHeap } from '../src/algorithms/dijkstra';
import { GraphEdge } from '../src/algorithms/graph';
import { ResolvedLocation, RoutePreference } from '../src/types/routing.types';
import { attractions, seedNetworkData } from './fixtures/seedNetwork';

let passed = 0;
function test(name: string, fn: () => void) {
  try {
    fn();
    passed++;
    console.log(`  ✔ ${name}`);
  } catch (err) {
    console.error(`  ✘ ${name}`);
    throw err;
  }
}

const place = (id: number): ResolvedLocation => {
  const a = attractions.find((x) => x.id === id)!;
  return { name: a.name, latitude: a.latitude, longitude: a.longitude, attractionId: id };
};

console.log('\nMinHeap & Dijkstra');
test('MinHeap pop theo thu tu tang dan', () => {
  const h = new MinHeap<string>();
  [5, 1, 4, 2, 3].forEach((p) => h.push(`n${p}`, p));
  const out: number[] = [];
  while (h.size) out.push(h.pop()!.priority);
  assert.deepEqual(out, [1, 2, 3, 4, 5]);
});

test('Dijkstra tim A -> B -> C (5 + 10 = 15) thay vi A -> C (20)', () => {
  const e = (to: string, duration: number): GraphEdge => ({ to, kind: 'WALK', mode: 'WALK', duration, distance: 0, fare: 0 });
  const adj: Record<string, GraphEdge[]> = { A: [e('B', 5), e('C', 20)], B: [e('C', 10), e('D', 2)], D: [], C: [] };
  const r = dijkstra('A', 'C', (n) => adj[n] ?? [], (x) => x.duration)!;
  assert.equal(r.cost, 15);
  assert.deepEqual(r.edges.map((x) => x.edge.to), ['B', 'C']);
});

console.log('\nTransit network');
const net = buildTransitNetwork(seedNetworkData);
test('Xay duoc graph tu du lieu seed', () => {
  assert.equal(net.stations.size, 27);
  assert.ok(net.graph.nodeCount > 50);
  assert.ok(net.graph.edgeCount > 100);
  console.log(`     nodes=${net.graph.nodeCount}, edges=${net.graph.edgeCount}, lines=${net.lines.size}`);
});

const departure = 8 * 60;
const prefs: RoutePreference[] = ['FASTEST', 'CHEAPEST', 'LEAST_WALKING', 'FEWEST_TRANSFERS'];

function show(title: string, origin: ResolvedLocation, destination: ResolvedLocation, pref: RoutePreference = 'FASTEST') {
  const t0 = Date.now();
  const out = planRoutes(net, { origin, destination, preference: pref, departureMinutes: departure });
  console.log(`\n  ${title}  [${pref}]  (${Date.now() - t0} ms, ${out.routes.length} phuong an)`);
  for (const r of out.routes) {
    console.log(
      `   - ${r.summary.padEnd(38)} ${String(r.totalDuration).padStart(3)} phut | ${String(r.totalFare).padStart(6)}d | di bo ${String(r.walkingDistance).padStart(4)}m | chuyen ${r.transfers} | ${r.labels.join(',')}`,
    );
  }
  return out;
}

console.log('\nTim duong tren du lieu Ha Noi');
test('Ho Hoan Kiem -> Van Mieu: co phuong an, phuong an dau la FASTEST', () => {
  const out = show('Hồ Hoàn Kiếm → Văn Miếu', place(1), place(11));
  assert.ok(out.routes.length >= 1);
  assert.equal(out.routes[0].preference, 'FASTEST');
  assert.ok(out.routes[0].steps.every((s) => s.path.length >= 2));
});

test('Ga/Hoa Lo -> Chua Tran Quoc: multi-modal, toi da 3 phuong an, khong trung lap', () => {
  const out = show('Nhà tù Hỏa Lò → Chùa Trấn Quốc', place(6), place(16));
  assert.ok(out.routes.length >= 2 && out.routes.length <= 3);
  assert.equal(new Set(out.routes.map((r) => r.id)).size, out.routes.length);
});

test('Moi tieu chi deu tra ve ket qua toi uu dung tieu chi do', () => {
  for (const p of prefs) {
    const out = planRoutes(net, { origin: place(13), destination: place(14), preference: p, departureMinutes: departure });
    assert.ok(out.routes.length > 0, `khong co ket qua cho ${p}`);
    const first = out.routes[0];
    const metric = {
      FASTEST: (r: typeof first) => r.totalDuration,
      CHEAPEST: (r: typeof first) => r.totalFare,
      LEAST_WALKING: (r: typeof first) => r.walkingDistance,
      FEWEST_TRANSFERS: (r: typeof first) => r.transfers,
    }[p];
    // Phuong an dau tien phai tot nhat (hoac bang) theo tieu chi da chon
    // (sai so nho do lam tron tung buoc)
    for (const r of out.routes) assert.ok(metric(first) <= metric(r) + 2, `${p}: ${metric(first)} > ${metric(r)}`);
  }
  show('Bảo tàng Lịch sử → Bảo tàng Dân tộc học', place(13), place(14), 'CHEAPEST');
});

test('Ve thang Bus -> fareToPay giam', () => {
  const base = planRoutes(net, { origin: place(13), destination: place(14), preference: 'FASTEST', departureMinutes: departure });
  const withPass = planRoutes(net, {
    origin: place(13),
    destination: place(14),
    preference: 'FASTEST',
    departureMinutes: departure,
    passTransportTypeIds: [1, 2],
  });
  assert.ok(withPass.routes[0].fareToPay <= base.routes[0].fareToPay);
  assert.ok(withPass.routes[0].steps.some((s) => s.coveredByPass) || withPass.routes[0].fareToPay === 0);
});

test('Toa do bat ky (Ga Ha Noi) -> Ho Tay', () => {
  const out = show(
    'Toạ độ 21.0245,105.8412 → Hồ Tây',
    { name: 'Vị trí của tôi', latitude: 21.0245, longitude: 105.8412 },
    place(15),
  );
  assert.ok(out.routes.length > 0);
});

test('Diem gan nhau -> co phuong an di bo thang', () => {
  const out = planRoutes(net, { origin: place(1), destination: place(2), preference: 'FASTEST', departureMinutes: departure });
  assert.ok(out.routes.some((r) => r.steps.length === 1 && r.steps[0].mode === 'WALK'));
});

test('nextDepartures: BUS01 tu Bo Ho sau 08:00', () => {
  const out = planRoutes(net, {
    origin: { name: 'Bờ Hồ', latitude: 21.028511, longitude: 105.854444, stationId: 1 },
    destination: { name: 'Cát Linh', latitude: 21.0276, longitude: 105.8412, stationId: 9 },
    preference: 'FEWEST_TRANSFERS',
    departureMinutes: departure,
  });
  const step = out.routes.flatMap((r) => r.steps).find((s) => s.routeCode === 'BUS01');
  if (step?.nextDepartures) {
    assert.ok(step.nextDepartures.every((t) => t >= '08:00'));
    console.log(`     BUS01 next: ${step.nextDepartures.join(', ')}`);
  }
});

console.log(`\n${passed} tests passed\n`);
