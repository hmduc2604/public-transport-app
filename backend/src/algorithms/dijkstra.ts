/**
 * ==========================================================================
 *  DIJKSTRA + MIN-HEAP (Priority Queue)
 * ==========================================================================
 * Do phuc tap: O((V + E) log V)
 *
 * Ham dijkstra KHONG biet gi ve "nhanh nhat" hay "re nhat".
 * No chi nhan 1 ham weight(edge) -> so khong am.
 * routing.ts se truyen vao weight khac nhau cho tung tieu chi:
 *   FASTEST          weight = thoi gian
 *   CHEAPEST         weight = gia ve (+ chut thoi gian de pha hoa)
 *   LEAST_WALKING    weight = met di bo (+ chut thoi gian)
 *   FEWEST_TRANSFERS weight = thoi gian + phat moi lan len xe
 * ==========================================================================
 */
import { GraphEdge } from './graph';

/** Min-heap nho gon: luon lay ra phan tu co priority nho nhat trong O(log n) */
export class MinHeap<T> {
  private items: { priority: number; value: T }[] = [];

  get size(): number {
    return this.items.length;
  }

  push(value: T, priority: number): void {
    this.items.push({ priority, value });
    this.bubbleUp(this.items.length - 1);
  }

  pop(): { priority: number; value: T } | undefined {
    if (this.items.length === 0) return undefined;
    const top = this.items[0];
    const last = this.items.pop()!;
    if (this.items.length > 0) {
      this.items[0] = last;
      this.sinkDown(0);
    }
    return top;
  }

  private bubbleUp(i: number): void {
    while (i > 0) {
      const parent = (i - 1) >> 1;
      if (this.items[parent].priority <= this.items[i].priority) break;
      [this.items[parent], this.items[i]] = [this.items[i], this.items[parent]];
      i = parent;
    }
  }

  private sinkDown(i: number): void {
    const n = this.items.length;
    for (;;) {
      const l = 2 * i + 1;
      const r = l + 1;
      let smallest = i;
      if (l < n && this.items[l].priority < this.items[smallest].priority) smallest = l;
      if (r < n && this.items[r].priority < this.items[smallest].priority) smallest = r;
      if (smallest === i) break;
      [this.items[smallest], this.items[i]] = [this.items[i], this.items[smallest]];
      i = smallest;
    }
  }
}

export interface PathEdge {
  from: string;
  edge: GraphEdge;
}

export interface DijkstraResult {
  cost: number;
  /** danh sach canh tu start -> goal theo thu tu */
  edges: PathEdge[];
  /** so node da duoc "chot" (de bao cao hieu nang) */
  visited: number;
}

export function dijkstra(
  start: string,
  goal: string,
  getNeighbors: (node: string) => GraphEdge[],
  weight: (edge: GraphEdge) => number,
): DijkstraResult | null {
  const dist = new Map<string, number>([[start, 0]]);
  const prev = new Map<string, PathEdge>();
  const done = new Set<string>();
  const heap = new MinHeap<string>();
  heap.push(start, 0);

  while (heap.size > 0) {
    const { value: node, priority: d } = heap.pop()!;
    if (done.has(node)) continue; // ban ghi cu trong heap (lazy deletion)
    done.add(node);

    if (node === goal) {
      // Truy vet nguoc tu goal ve start
      const edges: PathEdge[] = [];
      let cur = goal;
      while (cur !== start) {
        const p = prev.get(cur)!;
        edges.push(p);
        cur = p.from;
      }
      edges.reverse();
      return { cost: d, edges, visited: done.size };
    }

    for (const edge of getNeighbors(node)) {
      if (done.has(edge.to)) continue;
      const w = weight(edge);
      if (!Number.isFinite(w) || w < 0) continue; // Dijkstra yeu cau trong so khong am
      const nd = d + w;
      if (nd < (dist.get(edge.to) ?? Infinity)) {
        dist.set(edge.to, nd);
        prev.set(edge.to, { from: node, edge });
        heap.push(edge.to, nd);
      }
    }
  }
  return null; // khong co duong
}
