import { TransportMode } from '../types';
import { MODE_META } from '../utils/modes';

export function ModeBadge({ mode, text, small }: { mode: TransportMode; text?: string; small?: boolean }) {
  const m = MODE_META[mode];
  return (
    <span className={`mode-badge${small ? ' mode-badge-sm' : ''}`} style={{ background: m.color }}>
      <span aria-hidden>{m.icon}</span> {text ?? m.short}
    </span>
  );
}
