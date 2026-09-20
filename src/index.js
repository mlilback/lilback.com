// lilback.com -- serves the built Jekyll site and collects its own pageview
// beacon. No cookies, no storage, no third party.
//
// Design note: record generously, filter at query time. Analytics Engine
// writes are cheap and a WHERE clause is revisable; a filter applied at write
// time is a decision you can never revisit.

const BEACON_PATH = '/beacon';
const MAX_FIELD = 256;

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === BEACON_PATH) return handleBeacon(request, env);
    return env.ASSETS.fetch(request);
  },
};

async function handleBeacon(request, env) {
  if (request.method !== 'POST') return new Response(null, { status: 405 });

  // Same-origin only. Not a security boundary -- anyone can forge this -- but
  // it costs nothing and turns away casual noise.
  const origin = request.headers.get('Origin');
  if (origin) {
    try {
      if (new URL(origin).host !== new URL(request.url).host) {
        return new Response(null, { status: 403 });
      }
    } catch {
      return new Response(null, { status: 400 });
    }
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return new Response(null, { status: 400 });
  }

  const path = str(body.p);
  if (!path.startsWith('/')) return new Response(null, { status: 400 });

  const cf = request.cf || {};
  const ua = str(request.headers.get('User-Agent'));

  env.HITS.writeDataPoint({
    // Keep these positions stable -- queries address blobs by index.
    blobs: [
      path,                       // blob1  page path, no query string
      refHost(body.r),            // blob2  referrer host only
      str(cf.country),            // blob3
      ua,                         // blob4  kept so bots can be excluded later
      await visitorHash(request), // blob5  rotates daily, not an identity
      str(cf.colo),               // blob6  which edge served it
    ],
    doubles: [1],
    indexes: [path.slice(0, 96)],
  });

  return new Response(null, { status: 204 });
}

function str(v) {
  return typeof v === 'string' ? v.slice(0, MAX_FIELD) : '';
}

// Referrer host only. The full URL can carry search terms and private paths,
// and it explodes cardinality for no analytical gain.
function refHost(r) {
  if (typeof r !== 'string' || !r) return '';
  try {
    return new URL(r).host.slice(0, MAX_FIELD);
  } catch {
    return '';
  }
}

// A per-day, per-visitor value derived from IP + UA. It lets a query count
// uniques without anything being stored client-side, and because the date is
// in the hash it cannot be correlated across days.
async function visitorHash(request) {
  const ip = request.headers.get('CF-Connecting-IP') || '';
  const ua = request.headers.get('User-Agent') || '';
  const day = new Date().toISOString().slice(0, 10);
  const data = new TextEncoder().encode(`${day}|${ip}|${ua}`);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return [...new Uint8Array(digest).slice(0, 8)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}
