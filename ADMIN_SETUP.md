# VIDYAMAP Admin Dashboard — Setup

## Scope

- The dashboard lives at `/admin.html` and is intentionally not linked from public navigation.
- The public website files are unchanged.
- Authentication uses Supabase Auth with email/password and password-reset flow.
- Dashboard access requires an authenticated user with an active `public.profiles` row whose role is `platform_admin`.
- Data operations rely on existing Supabase Row Level Security (RLS) policies. The browser uses only the Supabase publishable key; no service-role secret is shipped to the browser.
- Student enquiry personal data is intentionally excluded from this first dashboard.

## Add team administrators

Only an existing trusted project owner should provision admins:

1. In Supabase Dashboard, open **Authentication → Users** and invite the staff member by their work email. Do not enable public self-registration for staff.
2. After the user accepts/exists, use the SQL editor as a trusted project owner to assign the platform role. Replace the UUID with the invited user's Auth UID:
   ```sql
   update public.profiles
   set role = 'platform_admin'::platform_role,
       is_active = true,
       updated_at = now()
   where id = 'REPLACE-WITH-AUTH-USER-UUID'::uuid;
   ```
3. Confirm exactly one profile row was updated and verify the person can sign in at `/admin.html`.
4. To revoke access, set `is_active = false` and revoke/disable the Auth user as appropriate. Existing sessions may remain valid until refreshed/expired, so revoke sessions when promptly removing access.

Never grant `platform_admin` based on user-editable auth metadata or a client-side form. Keep role assignment restricted to trusted operators.

## Current dashboard capabilities

- Authenticated admin sign-in, sign-out, and password reset.
- Role verification against the database profile.
- Counts for institutions, verified institutions, pending registrations, and campaigns.
- Read-only recent campaign and college listings.
- Approve/reject pending college registration requests; database RLS checks the permission.

## Follow-up before production use

- Verify the deployment URL and configure Supabase Auth redirect URLs to include the final `/admin.html` origin.
- Add a dedicated staff invite/role management workflow using a server-side Edge Function that validates the caller's platform-admin role. Do not implement user provisioning from the browser with the service-role key.
- Extend campaign moderation with explicit audit events and require confirmed payment before paid ad eligibility.
- Add automated role/RLS tests for anonymous, student, college-admin, and platform-admin accounts.
- Test login, password reset, mobile layout, and moderation actions in the deployed environment.
