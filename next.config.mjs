{
  source: '/(hdr|main|faqs|how|legal|thank-you)(.*)',
  headers: [{ key: 'Cache-Control', value: 'public, max-age=600, s-maxage=86400, stale-while-revalidate=604800' }]
}
