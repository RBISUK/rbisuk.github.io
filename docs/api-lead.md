# POST /api/lead
Accepts application/json. Returns 201 with { ok, id, receivedAt }.

## Fields
- name (string, required)
- source (string, required)
- campaign (string, required)
- email (email) OR phone (string) — at least one required
- channel, utm.{source,medium,campaign,term,content}, tenantId, module, leadType, consent.{contact,store}

## Auth
Optional x-api-key header if API_KEY is set in environment.

## Rate limiting
60 requests per minute per IP (429 on exceed).
