import { Link } from 'react-router-dom';
import { Empty } from '../components/Feedback';

export default function NotFoundPage() {
  return (
    <div className="page">
      <Empty icon="🧭" title="Không tìm thấy trang">
        <Link to="/" className="btn btn-primary">
          Về trang chủ
        </Link>
      </Empty>
    </div>
  );
}
