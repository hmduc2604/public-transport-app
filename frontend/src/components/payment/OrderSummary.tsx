/** Tom tat don hang dung chung cho cac trang thanh toan */
import { Order } from '../../types';
import { StatusBadge } from '../Feedback';
import { formatDateTime, formatMoney } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';

export function OrderSummary({ order, compact = false }: { order: Order; compact?: boolean }) {
  return (
    <div className={`card order-summary${compact ? ' compact' : ''}`}>
      <div className="row space-between">
        <strong>Đơn hàng #{order.orderId}</strong>
        <StatusBadge status={order.status} label={STATUS_LABEL[order.status]} />
      </div>
      <div className="muted small">Tạo lúc {formatDateTime(order.createdAt)}</div>
      <ul className="order-lines">
        {order.items?.map((it) => (
          <li key={it.orderDetailId}>
            <span>
              {it.ticketTypeName} × {it.quantity}
            </span>
            <span>{formatMoney(it.subtotal)}</span>
          </li>
        ))}
      </ul>
      <div className="order-total">
        <span>Tổng thanh toán</span>
        <strong>{formatMoney(order.totalAmount)}</strong>
      </div>
    </div>
  );
}
