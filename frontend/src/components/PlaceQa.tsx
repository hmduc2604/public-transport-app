/**
 * HOI DAP NGAY TREN TRANG DIA DIEM (AI) -> POST /attractions/:id/ask
 * AI chi tra loi tu thong tin HanoiGo co ve dia diem (gio mo cua, gia ve, lich su, kinh nghiem, tram gan...).
 * Moi cau tra loi kem 2 - 3 cau hoi goi y tiep theo.
 */
import { FormEvent, useEffect, useRef, useState } from 'react';
import { aiApi } from '../services/aiApi';
import { errorMessage } from '../services/api';
import { Icon } from './Icon';
import { RichText } from './RichText';

interface QaItem {
  id: number;
  question: string;
  answer?: string;
  notice?: string;
  error?: string;
}

const DEFAULT_QUESTIONS = ['Bây giờ còn mở cửa không?', 'Giá vé bao nhiêu?', 'Có phù hợp với trẻ em không?', 'Đi xe buýt đến đây thế nào?'];

export function PlaceQa({ attractionId, name }: { attractionId: number; name: string }) {
  const [items, setItems] = useState<QaItem[]>([]);
  const [suggested, setSuggested] = useState<string[]>(DEFAULT_QUESTIONS);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);
  const seq = useRef(0);
  const threadRef = useRef<HTMLDivElement>(null);

  // Sang dia diem khac -> bat dau lai
  useEffect(() => {
    setItems([]);
    setSuggested(DEFAULT_QUESTIONS);
    setInput('');
  }, [attractionId]);

  useEffect(() => {
    const last = threadRef.current?.lastElementChild as HTMLElement | null;
    last?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }, [items]);

  const ask = async (text: string) => {
    const question = text.trim();
    if (question.length < 2 || busy) return;
    const id = ++seq.current;
    const history = items.filter((it) => it.answer).slice(-3).map((it) => ({ question: it.question, answer: it.answer! }));
    setItems((xs) => [...xs, { id, question }]);
    setInput('');
    setBusy(true);
    try {
      const r = await aiApi.askPlace(attractionId, question, history);
      setItems((xs) => xs.map((x) => (x.id === id ? { ...x, answer: r.answer, notice: r.notice } : x)));
      if (r.followUps.length) setSuggested(r.followUps);
    } catch (e) {
      setItems((xs) => xs.map((x) => (x.id === id ? { ...x, error: errorMessage(e) } : x)));
    } finally {
      setBusy(false);
    }
  };

  const retry = (it: QaItem) => {
    setItems((xs) => xs.filter((x) => x.id !== it.id));
    ask(it.question);
  };

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    ask(input);
  };

  return (
    <section className="place-section place-qa" id="hoi-dap" data-spy aria-labelledby="h-qa">
      <h2 id="h-qa">
        <Icon name="sparkles" size={22} /> Hỏi nhanh về {name} <span className="ai-badge">AI</span>
      </h2>
      <p className="muted small">Trả lời dựa trên thông tin HanoiGo có về địa điểm này: giờ mở cửa, giá vé, lịch sử, kinh nghiệm tham quan và trạm xe gần nhất.</p>

      {items.length > 0 && (
        <div className="qa-thread" ref={threadRef} aria-live="polite">
          {items.map((it) => (
            <div key={it.id} className="qa-item">
              <div className="qa-q">{it.question}</div>
              {it.answer ? (
                <div className="qa-a">
                  <RichText text={it.answer} />
                  {it.notice && <p className="muted small qa-notice">{it.notice}</p>}
                </div>
              ) : it.error ? (
                <div className="qa-a qa-error">
                  <span>{it.error}</span>
                  <button className="btn btn-ghost btn-sm" onClick={() => retry(it)} disabled={busy}>
                    Thử lại
                  </button>
                </div>
              ) : (
                <div className="qa-a ai-typing">
                  <span className="ai-dots" aria-hidden>
                    <i />
                    <i />
                    <i />
                  </span>
                  <span className="muted small">Đang trả lời…</span>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      <div className="qa-chips" aria-label="Câu hỏi gợi ý">
        {suggested.map((q) => (
          <button key={q} className="chip chip-btn" onClick={() => ask(q)} disabled={busy}>
            {q}
          </button>
        ))}
      </div>
      <form className="qa-form" onSubmit={onSubmit}>
        <input
          className="input"
          placeholder={`Hỏi gì đó về ${name}…`}
          maxLength={300}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          disabled={busy}
          aria-label={`Câu hỏi về ${name}`}
        />
        <button className="btn btn-primary" disabled={busy || input.trim().length < 2} aria-label="Gửi câu hỏi">
          <Icon name="send" size={18} />
        </button>
      </form>
    </section>
  );
}
