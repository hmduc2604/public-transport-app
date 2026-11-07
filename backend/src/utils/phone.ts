/** So dien thoai Viet Nam: chuan hoa ve dang 0xxxxxxxxx (10 so) va E.164 +84xxxxxxxxx */

/** Dau so di dong hien hanh: 03, 05, 07, 08, 09 */
const VN_MOBILE = /^0(3|5|7|8|9)\d{8}$/;

export function normalizeVnPhone(input: string | null | undefined): string | null {
  if (!input) return null;
  let p = String(input).replace(/[\s.\-()]/g, '');
  if (p.startsWith('+84')) p = '0' + p.slice(3);
  else if (p.startsWith('84') && p.length === 11) p = '0' + p.slice(2);
  else if (/^[35789]\d{8}$/.test(p)) p = '0' + p; // thieu so 0 dau
  return VN_MOBILE.test(p) ? p : null;
}

export const toE164 = (phone0: string) => '+84' + phone0.slice(1);

/** 0901234567 -> 090****567 */
export const maskPhone = (p: string) => (p.length >= 7 ? p.slice(0, 3) + '****' + p.slice(-3) : p);

/** nguyenvana@gmail.com -> ng******@gmail.com */
export function maskEmail(e: string) {
  const [name, domain] = e.split('@');
  if (!domain) return e;
  return name.slice(0, Math.min(2, name.length)) + '*'.repeat(Math.max(3, name.length - 2)) + '@' + domain;
}
