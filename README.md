# VidyaMap

VidyaMap is an education directory and digital marketing platform for students, parents, and educational institutions in Telangana and Andhra Pradesh.

- **Live website:** https://fayaz-195.github.io/vidyamap/
- **Roadmap:** [ROADMAP.md](./ROADMAP.md)
- **Repository:** https://github.com/fayaz-195/vidyamap

## Existing application

The repository currently contains the public Home, Explore Colleges, For Colleges, Marketing Services, About/Mission/Vision/What We Do/Why VidyaMap, and Founder pages. Supabase powers the institution directory, registration/enquiry workflows, advertising campaigns, and the AI counsellor.

## Development approach

Implementation follows the phased roadmap. Existing page design and functioning flows should be preserved unless a change is explicitly scoped. All data access must be enforced by Supabase RLS and server-side authorization; client-side visibility alone is not security. Never commit service-role keys, provider secrets, or personal student data.

## Quality checks

GitHub Actions runs static checks for HTML structure, duplicate IDs, closed script tags, and inline JavaScript syntax. Review the latest workflow run before treating a change as production-ready.

## Current focus

Phase 0: baseline validation, cross-page checks, and the documented security review. See [ROADMAP.md](./ROADMAP.md) for the full implementation plan and acceptance criteria.
