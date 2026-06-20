/**
 * SMS yuborish servisi (Eskiz.uz)
 *
 * Sozlash (.env / Render Environment):
 *   ESKIZ_TOKEN  - Eskiz.uz API tokeni (oldindan olingan)
 *   ESKIZ_FROM   - jo'natuvchi (default 4546 - test)
 *
 * Agar ESKIZ_TOKEN bo'lmasa - SMS yuborilmaydi, kod konsolga yoziladi
 * va API javobida qaytariladi (faqat test/dev uchun).
 */
async function sendSms(phone, text) {
  const token = process.env.ESKIZ_TOKEN;

  // SMS provider sozlanmagan - dev rejim
  if (!token) {
    console.log(`[SMS DEV] ${phone}: ${text}`);
    return { sent: false, dev: true };
  }

  try {
    const body = new URLSearchParams();
    body.append('mobile_phone', phone.replace('+', ''));
    body.append('message', text);
    body.append('from', process.env.ESKIZ_FROM || '4546');

    const res = await fetch('https://notify.eskiz.uz/api/message/sms/send', {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body,
    });

    return { sent: res.ok };
  } catch (e) {
    console.error('SMS error:', e.message);
    return { sent: false };
  }
}

module.exports = { sendSms };
