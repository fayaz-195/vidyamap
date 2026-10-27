# VidyaMap — Full Product Roadmap

**Repository:** `fayaz-195/vidyamap`  
**Live site:** https://fayaz-195.github.io/vidyamap/  
**Backend:** Supabase project `taxlvccrinehasexgvhv`  
**Approach:** ship small, testable phases while preserving the current public design and working flows.

## Product principles

1. Preserve the existing VidyaMap logo, purple/navy visual language, navigation, responsive layout, public directory, student details gate, college registration flow, and AI counsellor unless a change is explicitly required.
2. Do not expose private student, college, campaign, or staff data to anonymous visitors.
3. Never display an unverified institution as verified; never display an ad unless its approval, payment, targeting, and schedule requirements are met.
4. Never claim a payment, message, email, deployment, or external integration succeeded until its provider confirms it.
5. Every phase must include acceptance criteria, regression checks, and a GitHub commit. Database changes require a migration and security review.
6. Keep secrets out of HTML and Git. Browser code may use only the Supabase publishable/anon key; privileged actions belong on secured server-side functions.

## Existing baseline discovered

- Public pages: Home, Explore Colleges, For Colleges, Marketing Services, About, Mission, What We Do, Vision, Why VidyaMap, and Founder.
- Supabase tables cover profiles/roles, states/districts/mandals/localities, colleges/courses, registration requests, student enquiries, lead assignments, contact lists, marketing campaigns, subscriptions, audit logs, paid ad campaigns, and public college callback leads.
- Active Edge Functions: `vidyamap-ai-counsellor`, `submit-college-callback`, and `notify-college-enquiry`.
- Existing homepage contains directory/search, student lead capture, college registration, college/staff portal entry points, ad approval UI, and AI counsellor.
- Public directory currently has only a small seed of college records; the directory must handle pagination and empty states rather than invent institution data.
- Supabase Security Advisor reported access warnings for three SECURITY DEFINER functions and a missing RLS policy on `college_enquiry_email_notifications`. These need deliberate policy/authorization review before production sign-off; do not blindly revoke public execution if a public form depends on it.

## Phases and acceptance criteria

### Phase 0 — Baseline, documentation, and safe delivery
- [x] Inspect repository pages, Supabase tables, migrations, and Edge Functions.
- [x] Document feature inventory, release gates, and known risks.
- [x] Extend automated checks from the homepage to all HTML pages.
- [x] Verify unique IDs, closed HTML/script tags, and inline JavaScript syntax.
- [ ] Capture a known-good baseline commit before larger refactors.
- **Done when:** the baseline and known risks are documented and CI checks every page without breaking existing functionality.

### Phase 1 — Public directory and discovery
- [ ] One shared search model for institution name, category, course, state, district, mandal, and locality.
- [ ] Filter, sort, reset, verified-only badge, admissions status, and useful empty/error/loading states.
- [ ] Server-side pagination or bounded queries for large districts (e.g. 100+ colleges).
- [ ] Stable deep links to search results and college profiles.
- [ ] Accessible mobile cards and keyboard-operable filters.
- **Done when:** searching and paging through 100+ seeded test records returns correct results without loading the entire directory into the browser.

### Phase 2 — Student onboarding and consent
- [ ] Keep the current student details gate, but show it only at intentional entry points.
- [ ] Validate name, phone, district, course, and consent on both client and server.
- [ ] Store consent text/version and timestamp; explain why contact details are collected.
- [ ] Avoid duplicate submissions and accidental repeat popups within a session.
- [ ] Provide clear success, retry, and error states.
- **Done when:** a valid lead is saved once, consent is recorded, and refresh/navigation does not cause an unexpected popup loop.

### Phase 3 — College profiles and enquiries
- [ ] College detail/profile with verified status, location, website/contact details, courses, admissions, and scholarships where supplied.
- [ ] Enquiry form with validation and explicit contact consent.
- [ ] Securely route each enquiry to the correct college only.
- [ ] Notification status, retry handling, and duplicate prevention.
- **Done when:** a test enquiry reaches the intended college workflow and no other college can read it.

### Phase 4 — Accounts, roles, and dashboards
- [ ] Supabase Auth sign-in/sign-out, password reset, and session expiry handling.
- [ ] Server-verified roles: platform admin/staff, college owner/member, and student/public visitor.
- [ ] College dashboard: profile, courses, enquiries assigned to that college, campaign status.
- [ ] Staff dashboard: pending registrations, ad reviews, audit trail, and safe moderation actions.
- [ ] Enforce every permission in database RLS/RPC/Edge Functions; hiding a button is not authorization.
- **Done when:** role-based access tests prove users cannot access another college's records or invoke admin actions.

### Phase 5 — College registration and verification
- [ ] Registration request validation, duplicate detection, and clear pending state.
- [ ] Admin review: approve, reject, or request changes with reviewer notes.
- [ ] Approval creates/links the institution and authorized membership safely.
- [ ] Public directory includes only approved/verified records.
- [ ] Audit all review decisions.
- **Done when:** the complete registration lifecycle works end-to-end with an audit record for each decision.

### Phase 6 — College advertising lifecycle
- [ ] College creates a campaign with poster/video, destination, dates, budget/duration, and geographic targeting.
- [ ] Validate allowed media types, size, URL, dates, and safe external destinations.
- [ ] Review queue with approve/reject notes; no self-approval.
- [ ] Payment confirmation is server-verified before paid placement becomes eligible.
- [ ] Slots have distinct placements: image poster carousel and video showcase, never covering the hero or critical content.
- [ ] Rotate multiple active ads; pause on hover/focus, support touch/keyboard, respect reduced motion.
- [ ] Apply verified-college, approval, paid status, schedule, and district/mandal targeting at serving time.
- [ ] Track impressions/clicks without exposing student personal data.
- **Done when:** test campaigns display only after all eligibility checks and stop at expiry/refund/rejection.

### Phase 7 — Marketing campaigns and contact safety
- [ ] Consent-based contacts and source/consent metadata.
- [ ] Opt-out/suppression list applied before any send.
- [ ] Template approval status, audience preview, scheduling, approval workflow, and campaign logs.
- [ ] Integrate WhatsApp/Meta/YouTube providers only after credentials, provider approval, and webhook verification are configured.
- [ ] Retry failed sends safely; never show a sent status without provider confirmation.
- **Done when:** test mode and provider sandbox pass; production sending respects consent, opt-outs, quotas, and provider rules.

### Phase 8 — Plans, subscriptions, and payments
- [ ] Plan comparison with accurate limits/features.
- [ ] Server-side order/session creation and signed webhook verification.
- [ ] Idempotent payment updates, refund handling, invoices/receipts, and expiry.
- [ ] Never trust an amount or paid status supplied by browser code.
- **Done when:** test payments and webhook replay tests pass without duplicate entitlements.

### Phase 9 — AI counsellor and help
- [ ] Preserve existing multilingual AI counsellor.
- [ ] Add grounded guidance from verified directory data where available.
- [ ] Handle unavailable/low-confidence information honestly; avoid fabricated colleges, fees, scholarships, or deadlines.
- [ ] Rate limiting, error recovery, privacy notices, and feedback.
- **Done when:** answers are useful, concise, language-aware, and do not invent current institution facts.

### Phase 10 — Analytics, notifications, and audit
- [ ] Admin dashboard metrics: verified institutions, pending reviews, active campaigns, enquiries, and provider outcomes.
- [ ] College dashboard metrics limited to that college.
- [ ] Audit security-sensitive actions and campaign status changes.
- [ ] Operational alerts for failed email/WhatsApp/webhook processing.
- **Done when:** each metric can be traced to its source and respects tenant boundaries.

### Phase 11 — Accessibility, performance, and launch readiness
- [ ] Responsive QA on mobile/tablet/desktop and keyboard/screen-reader basics.
- [ ] Optimize images, lazy-load below-the-fold media, avoid layout shifts.
- [ ] Validate links, forms, empty/error states, and page navigation.
- [ ] Review CSP/external resources, database policies, public RPC grants, and secrets.
- [ ] Run automated checks and manual smoke tests on the deployed URL.
- [ ] Prepare rollback instructions and deployment checklist.
- **Done when:** no critical security or functionality issue remains open and the deployment is verified.

## Release checklist for every phase

- [ ] Existing flows still work.
- [ ] Desktop and mobile layout checked.
- [ ] Loading, empty, success, and error states checked.
- [ ] RLS/authorization checked for any data change.
- [ ] No secrets or private data added to client code.
- [ ] GitHub Actions checks pass.
- [ ] Commit SHA and any deployment caveat recorded.

## Current execution status

The initial repository/backend audit is complete. The roadmap is the source of truth for implementation order. The all-page static quality workflow is deployed and passed on commit `52cb3073af3a1c256e054cde5cb7afb6a87956d9`. Security review is still open; later phases should be implemented in order, with the existing design preserved.
