# Error catalogue

Error codes are part of the contract: stable, documented, and never redefined.
Add a row when an endpoint introduces a code.

| Code | HTTP status | Meaning | Caller should |
|---|---|---|---|
|  |  |  |  |

## House error model
Record the shape once (RFC 9457 problem details, or the existing in-house
model) so every endpoint matches it.

```json
{
  "type": "",
  "title": "",
  "status": 0,
  "code": "",
  "detail": "",
  "correlationId": "",
  "errors": [{ "field": "", "code": "", "message": "" }]
}
```

## Rules
- Never leak stack traces, SQL, internal hostnames, or raw vendor errors.
- Validation failures carry field-level detail; business rejections carry a code.
- The correlation ID is always present.
