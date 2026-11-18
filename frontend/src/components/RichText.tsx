/**
 * Hien thi van ban AI tra ve: **dam**, *nghieng*, gach dau dong, danh so.
 * Dung chung cho tro ly AI, tu van chon ve, hoi dap tren trang dia diem.
 */
import { ReactNode } from 'react';

export function inline(text: string): ReactNode[] {
  const out: ReactNode[] = [];
  const re = /\*\*([^*]+)\*\*|\*([^*\s][^*]*?)\*/g;
  let last = 0;
  let k = 0;
  let m: RegExpExecArray | null;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push(text.slice(last, m.index));
    out.push(m[1] !== undefined ? <strong key={k++}>{m[1]}</strong> : <em key={k++}>{m[2]}</em>);
    last = m.index + m[0].length;
  }
  if (last < text.length) out.push(text.slice(last));
  return out;
}

export function RichText({ text }: { text: string }) {
  const lines = text.replace(/\r/g, '').split('\n');
  const blocks: ReactNode[] = [];
  let list: { ordered: boolean; items: { sub: boolean; text: string }[] } | null = null;
  let para: string[] = [];
  const flushPara = () => {
    if (para.length) blocks.push(<p key={blocks.length}>{inline(para.join(' '))}</p>);
    para = [];
  };
  const flushList = () => {
    if (!list) return;
    const items = list.items.map((it, i) => (
      <li key={i} className={it.sub ? 'sub' : undefined}>
        {inline(it.text)}
      </li>
    ));
    blocks.push(list.ordered ? <ol key={blocks.length}>{items}</ol> : <ul key={blocks.length}>{items}</ul>);
    list = null;
  };
  for (const raw of lines) {
    const bullet = /^(\s*)[-*•]\s+(.*)$/.exec(raw);
    const numbered = /^(\s*)\d+[.)]\s+(.*)$/.exec(raw);
    if (bullet || numbered) {
      flushPara();
      const ordered = !bullet;
      const [, indent, body] = (bullet ?? numbered)!;
      if (!list || (list.ordered !== ordered && indent.length < 2)) {
        flushList();
        list = { ordered, items: [] };
      }
      list.items.push({ sub: indent.length >= 2, text: body });
    } else if (!raw.trim()) {
      flushPara();
      flushList();
    } else {
      flushList();
      para.push(raw.replace(/^#+\s*/, '').trim());
    }
  }
  flushPara();
  flushList();
  return <div className="ai-text">{blocks}</div>;
}
