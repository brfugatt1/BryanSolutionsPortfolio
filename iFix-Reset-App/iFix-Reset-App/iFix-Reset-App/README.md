# iFix Reset Request App

`ASP.NET Web Forms · C# · IIS · SMTP · Windows Authentication`

## Problem
Operators had to walk to the IS office to request HMI/iFix resets, causing 
production downtime and backlog across manufacturing areas.

## Solution
Built and deployed an internal web application on IIS that lets operators 
submit reset requests directly from the production floor. The form captures 
the area, affected machines, issue descriptions, and an optional photo 
attachment. Submissions are routed to the IS team via the internal SMTP relay 
and logged server-side for audit purposes.

## Features
- Area and machine selection with dynamic multi-screen support
- Optional photo upload with server-side storage and secure retrieval
- Email notifications to IS group via internal mail relay (no credentials required)
- Automatic cleanup of uploads older than 30 days
- Persistent request log for audit trail
- Anonymous authentication — works on iPads and non-domain browsers on the 
  production floor

## Impact
- Eliminated floor-to-office trips for reset requests
- Reduced IS response time with structured, consistent request format
- Photo attachment support improved diagnosis before technician dispatch
- In active use across multiple production areas at Nestlé Purina Flagstaff

## Tech Notes
- Hosted on IIS within the Nestlé internal network
- Sends via internal SMTP relay — no external mail service required
- Logs stored server-side with automatic date-based cleanup
- Built to run on .NET 4.5 within existing enterprise infrastructure constraints

> Source code is private per company policy.

---

**Author:** Bryan Fugatt — bryanfugatt1@gmail.com
