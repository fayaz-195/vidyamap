# VIDYAMAP — Product Experience Blueprint

**Goal:** Make VidyaMap the most useful education-discovery and institution-growth platform for students, parents, colleges, and counsellors across Telangana and Andhra Pradesh.

This blueprint extends the existing roadmap. It does not replace working features or authorize fabricated college facts, intrusive advertising, unsafe access, or unverified claims.

## Product promise

- **Students:** Find the right-fit college and make a confident, trackable admission decision.
- **Parents:** Understand costs, location, facilities, safety information, and next steps in clear language.
- **Colleges:** Turn genuine interest into organized enquiries, admissions follow-up, and measurable growth.
- **Counsellors:** Work from one prioritized queue with context and follow-up history.
- **Platform administrators:** Operate a trusted, measurable, auditable education marketplace.

## Signature experiences to build

### 1. College Fit Studio
A guided, multi-step college discovery experience that captures course interest, preferred districts, budget range, travel/hostel preference, and eligibility inputs. It returns a shortlist with transparent reasons for each match. Never imply guaranteed admission or invent fees, cutoffs, placements, or facilities.

### 2. Side-by-side Decision Room
Compare up to four verified institutions across only supplied fields: courses, published fee information, location, facilities, admission status/deadline, scholarships, and verified outcome information. Highlight missing data rather than treating it as a negative or filling gaps with guesses. Save and share a shortlist.

### 3. Parent View
A simple, low-jargon view of a student's shortlist, comparison, key dates, enquiry status, and questions to ask a college. Sharing must be initiated by the student and revocable; do not expose private contact or enquiry details by default.

### 4. Campus Stories
A mobile-first, accessible gallery of institution photos, short videos, facilities, events, and campus updates. Media must be uploaded/approved by an authorized institution member and moderated where required. Do not autoplay audio; respect reduced motion and data-conscious loading.

### 5. Admission Journey
A clear tracker for saved colleges, enquiries, application checklist items, upcoming deadlines, and follow-up reminders. Start with user-entered or institution-confirmed status; do not claim VidyaMap submits an official application unless an actual integration exists.

### 6. Scholarship & Deadline Radar
A searchable catalogue of scholarships, entrance exams, and admission dates with source, eligibility, last-verified date, and official destination link. Expired or stale items must be visibly marked; alerts require user opt-in.

### 7. Trust & Verification Layer
A visible profile completeness and verification status, verified contact channels, last-updated date, moderated reviews, and a correction/report flow. Verification must represent a documented admin review, not a decorative badge.

### 8. College Growth Command Center
A tenant-isolated workspace for institution owners and authorized staff: profile completeness, enquiry pipeline, response-time trends, campaign delivery, ad performance, and actionable recommendations. Every metric must be traceable to real data and scoped to that college.

### 9. Counsellor Workbench
A prioritized lead queue with assignment, follow-up due dates, notes, contact-consent status, duplicate detection, and outcome tracking. Keep student personal data role-restricted and log sensitive actions.

### 10. Regional Language & Accessibility
Consistent Telugu and English first, with Hindi only when translations are reviewed. Add keyboard navigation, screen-reader labels, readable contrast, responsive layouts, and low-bandwidth media behavior. Never unexpectedly switch the chat language.

## Admin-only control plane

- Verification and correction review queue.
- Institution profile and logo/media moderation.
- Campaign approval and placement schedule controls.
- Ad eligibility checks for approval, payment confirmation, targeting, and schedule.
- Audit log with actor, action, entity, timestamp, and outcome.
- Data-quality queue for missing/stale college information.
- Analytics with date filters, source definitions, export, and role-safe aggregation.
- Operational health for failed notifications, Edge Functions, and integration webhooks.
- Feature permissions and staff access review.

## Build order and release gates

1. **Trust and baseline:** Resolve authentication defects, confirm RLS and staff permissions, establish test fixtures, preserve a known-good baseline.
2. **Discovery quality:** Shared search/filter/pagination, profile completeness, reliable empty/loading/error states, stable shareable search URLs.
3. **Decision tools:** College Fit Studio, side-by-side comparison, shortlist and Parent View with explicit sharing controls.
4. **Admission utility:** Admission Journey, deadlines, scholarship catalogue, opt-in reminders.
5. **College workspace:** Tenant-isolated Growth Command Center and Counsellor Workbench.
6. **Rich profiles:** Moderated Campus Stories and verification/correction workflows.
7. **Regional polish:** Telugu/English consistency, accessibility, performance, low-bandwidth experience.
8. **Scale and launch:** Observability, abuse controls, privacy review, mobile QA, load tests, rollback plan.

## Non-negotiable quality rules

- Use real Supabase data; do not seed production with invented colleges, reviews, fees, rankings, placement figures, or scholarships.
- Enforce permissions in RLS and trusted server-side functions, not just hidden buttons.
- Never expose student personal data across institutions or to anonymous visitors.
- Keep all external messaging, payments, and integrations in a truthful pending/confirmed/failed state based on provider responses.
- Do not add disruptive hero ads or deceptive sponsored placements. Clearly label sponsored content and enforce eligibility at serving time.
- Prefer additive, reversible migrations. Never drop or rewrite production data as a shortcut.
- Test mobile, desktop, keyboard access, errors, empty states, and tenant boundaries before release.
- Do not deploy to production until the release checks pass and deployment is explicitly approved.

## Success measures

Track only measurable, source-backed metrics: search-to-profile engagement, shortlist creation, comparison usage, consented enquiry completion, college response time, enquiry-to-admission outcome where confirmed, profile completeness, campaign-qualified enquiries, and repeat usage. Show denominators and date ranges so percentages are interpretable.
