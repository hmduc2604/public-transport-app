/**
 * ==========================================================================
 *  TRANSIT GRAPH (do thi giao thong da phuong thuc)
 * ==========================================================================
 *
 * Y tuong: "do thi trang thai" (state-expanded graph).
 * Moi tram duoc tach thanh nhieu NODE theo trang thai cua hanh khach:
 *
 *   W:{stationId}            dang dung o tram (di bo / cho xe)
 *   R:{lineKey}:{stationId}  dang ngoi tren xe cua tuyen lineKey tai tram do
 *   ORIGIN / DEST            diem di / diem den (them vao luc tim duong)
 *
 * Cac loai CANH (edge):
 *
 *   WALK   W:a -> W:b                 di bo chuyen tram (khoang cach ngan)
 *   BOARD  W:a -> R:k:a               len xe tuyen k  (cong thoi gian cho + gia ve)
 *   RIDE   R:k:a -> R:k:b             ngoi tren xe tu tram a sang tram ke tiep b
 *   ALIGHT R:k:a -> W:a               xuong xe
 *
 * Nho tach trang thai nhu vay, Dijkstra dem duoc chinh xac:
 *   - so lan chuyen tuyen  = so canh BOARD - 1
 *   - gia ve               = cong tai moi lan BOARD (khong cong o tung tram)
 *   - thoi gian cho xe     = cong tai moi lan BOARD
 *
 *    W:A ──BOARD──> R:BUS01:A ──RIDE──> R:BUS01:B ──ALIGHT──> W:B ──WALK──> W:C
 * ==========================================================================
 */
import { TransportMode } from '../types/transport.types';

export type EdgeKind = 'WALK' | 'BOARD' | 'RIDE' | 'ALIGHT';

export interface GraphEdge {
  to: string;
  kind: EdgeKind;
  mode: TransportMode;
  /** phut */
  duration: number;
  /** met */
  distance: number;
  /** VND (chi co o canh BOARD) */
  fare: number;
  lineKey?: string;
  fromStationId?: number;
  toStationId?: number;
}

export const NodeId = {
  ORIGIN: 'ORIGIN',
  DEST: 'DEST',
  station: (stationId: number) => `W:${stationId}`,
  onLine: (lineKey: string, stationId: number) => `R:${lineKey}:${stationId}`,

  /** Lay stationId tu node id (null voi ORIGIN/DEST) */
  stationOf(node: string): number | null {
    if (node.startsWith('W:')) return Number(node.slice(2));
    if (node.startsWith('R:')) return Number(node.slice(node.lastIndexOf(':') + 1));
    return null;
  },
};

export class Graph {
  private adjacency = new Map<string, GraphEdge[]>();
  private edges = 0;

  addNode(id: string): void {
    if (!this.adjacency.has(id)) this.adjacency.set(id, []);
  }

  addEdge(from: string, edge: GraphEdge): void {
    this.addNode(from);
    this.addNode(edge.to);
    this.adjacency.get(from)!.push(edge);
    this.edges++;
  }

  neighbors(id: string): GraphEdge[] {
    return this.adjacency.get(id) ?? [];
  }

  hasNode(id: string): boolean {
    return this.adjacency.has(id);
  }

  get nodeCount(): number {
    return this.adjacency.size;
  }

  get edgeCount(): number {
    return this.edges;
  }
}
