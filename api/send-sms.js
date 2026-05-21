// api/send-sms.js — Vercel Serverless Function

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { mobile, message } = req.body;
  if (!mobile || !message) return res.status(400).json({ error: 'mobile et message requis' });

  let tel = mobile.replace(/\D/g, '');
  if (!tel.startsWith('216')) tel = '216' + tel;

  const now = new Date();
  const dd   = String(now.getDate()).padStart(2,'0');
  const mm   = String(now.getMonth()+1).padStart(2,'0');
  const yyyy = now.getFullYear();
  const hh   = String(now.getHours()).padStart(2,'0');
  const mn   = String(now.getMinutes()).padStart(2,'0');
  const myDate = `${dd}/${mm}/${yyyy}`;
  const myTime = `${hh}:${mn}:00`;

  // Clé sans encodeURIComponent — l'API attend la clé brute
  const KEY    = 'R9RlGnP/mR/64YtCWfA5IBSqHR1aSGyBaQUzHM4tELRuZy1rkVMiu/4mtm8GULwHvhXFy/AZ/pCzCAlvDUb6kNXub5Detypa';
  const SENDER = 'ALLTEC';

  // Construire l'URL sans encoder la clé
  const url = `https://app.tunisiesms.tn/Api/Api.aspx?fct=sms&key=${KEY}&mobile=${tel}&sms=${encodeURIComponent(message)}&sender=${SENDER}&date=${myDate}&heure=${myTime}`;

  console.log('Calling URL:', url);

  try {
    const response = await fetch(url);
    const text = await response.text();
    console.log('TunisieSMS response:', text);

    // Vérifier si succès dans le XML
    const success = text.includes('<status_code>200</status_code>') || 
                    text.includes('success') ||
                    !text.includes('erreur');

    return res.status(200).json({ success, response: text });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
}
