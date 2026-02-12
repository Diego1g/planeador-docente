# Release Guide

This project does not require formal versioned releases, but use this checklist for safe publication updates.

## Pre-Release Checklist

- Update docs (`README.md`, templates, agent docs) for behavior changes.
- Validate scripts:

```bash
bash -n scripts/*.sh
```

- Validate JSON template:

```bash
jq . .lesson/templates/.lesson-config.json >/dev/null
```

- Ensure no secrets/tokens are present in files or logs.

## GitHub Metadata

- Verify repository description and topics are up to date.
- Verify license file exists and README links to it.

## Publish Steps

1. Open PR with scoped changes.
2. Complete PR checklist.
3. Merge to `main`.
4. Optionally create a GitHub Release note summarizing:
   - workflow updates
   - script changes
   - template changes
   - agent behavior changes
