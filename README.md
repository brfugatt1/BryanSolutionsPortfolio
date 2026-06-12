# Bryan Fugatt – Solutions Portfolio

Welcome!   
This repo showcases selected projects I’ve built that combine **problem-solving, automation, and creative solution design.**  
They demonstrate how I approach real-world IT and business challenges — the same mindset I bring to consulting engagements.

---

##  Featured Projects

iFix Reset Request App
Problem: Operators had to walk to the IS office to request HMI resets, causing production downtime across manufacturing areas.
Solution: Built an internal web application hosted on IIS that lets operators submit reset requests directly from the floor. The form captures the area, affected machines, issue descriptions, and an optional photo attachment. Submissions are logged server-side and routed to the IS team via the internal SMTP relay.
Tech Stack: ASP.NET Web Forms (C#), IIS, Windows Authentication, internal SMTP relay, server-side file logging
Features:

Area and machine selection with dynamic multi-screen support
Optional photo upload with server-side storage and secure retrieval handler
Email notifications to IS group via internal mail relay
Automatic cleanup of uploads older than 30 days
Persistent request log for audit trail

Impact: Eliminated floor-to-office trips for reset requests, reduced response time, and created a repeatable internal app model now in active use across production areas.

---

### [Arduino iPad Drop Box Alert System](./Arduino-iPad-DropBox-Alert)
- **Problem**: iPads dropped into service box went unnoticed for weeks, delaying repairs.  
- **Solution**: Prototyped an Arduino-based sensor that alerts IT when devices are deposited.  
- **Impact**: Enabled same-day device awareness and improved service workflow reliability.  

---

### [PowerShell AD Compliance Automation](./PowerShell-AD-Compliance)
- **Problem**: HQ audit flagged inactive AD accounts (>90 days).  
- **Solution**: Automated AD account identification and disabling via PowerShell.  
- **Impact**: Restored compliance, saved ~40 labor hours/month, and established repeatable process.  

---

### [Python SSL Health Checker](./Python-SSL-HealthChecker)
- **Problem**: SSL certificate expirations risked outages if unnoticed.  
- **Solution**: Script that checks SSL health and sends alert emails before expiry.  
- **Impact**: Prevented downtime and simplified monitoring across environments.  

---

##  About Me
- **Role**: IT Technician → Solutions Consultant  
- **Focus**: Automation, data workflows, IT/OT integration, and creative prototyping.  
- **Location**: Arizona, USA  

For professional inquiries, connect with me on [LinkedIn](your-linkedin-url) or reach out at **bryanfugatt1@gmail.com**.
