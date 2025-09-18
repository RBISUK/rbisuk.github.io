export const runtime = 'edge';
export async function GET() {
  const data = {
    updated: new Date().toISOString(),
    metrics: {
      sla: { label: 'SLA Breach Rate', unit: '%', value: 18, series: [22,21,20,19,19,18,18] },
      seo: { label: 'SEO Visibility', unit: '/100', value: 62, series: [55,57,59,60,61,62,62] },
      comp:{ label: 'Open Compliance Issues', unit: '', value: 7, series: [10,9,9,8,8,7,7] },
    }
  };
  return new Response(JSON.stringify(data), { status: 200, headers: { 'content-type': 'application/json' } });
}
