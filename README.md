# Bryan Fugatt – Solutions Portfolio

IT professional with hands-on experience across networking, infrastructure, and web development.  
This repo documents selected projects and solutions I've built to solve real workplace problems.

📧 bryanfugatt1@gmail.com · [LinkedIn](https://www.linkedin.com/in/bryan-fugatt-221506233/) · [HantaHotMap.com](https://hantahotmap.com) · [NationalGasCost.com](https://nationalgascost.com)

---

## Projects

### iFix Reset Request App
`ASP.NET · C# · IIS · SMTP · Windows Auth`

**Problem:** Operators had to walk to the IS office to request HMI resets, causing production downtime across manufacturing areas.

**Solution:** Built an internal web application hosted on IIS that lets operators submit reset requests directly from the floor. Captures area, affected machines, issue descriptions, and optional photo attachments. Submissions are logged server-side and routed to the IS team via the internal SMTP relay.

**Impact:** Eliminated floor-to-office trips, reduced IS response time, and created a repeatable internal app model now in active use across production areas at Nestlé Purina.

> Source code is private per company policy.

---

### PowerShell AD Compliance Automation
`PowerShell · Active Directory`

**Problem:** An HQ audit flagged a large number of inactive AD accounts exceeding the 90-day threshold.

**Solution:** Wrote a PowerShell script to automatically identify and disable inactive accounts based on last logon date, with logging for audit documentation.

**Impact:** Restored compliance, eliminated manual review work, and established a repeatable process saving approximately 40 labor hours per month.

---

### Arduino iPad Drop Box Alert System
`Arduino · Hardware Prototyping`

**Problem:** iPads dropped into the IT service box went unnoticed for days or weeks, delaying repairs and frustrating staff.

**Solution:** Prototyped an Arduino-based analog sensor system that detects when a device is deposited and triggers an alert to IT staff.

**Impact:** Enabled same-day device awareness and improved service workflow reliability.

---

### Python SSL Health Checker
`Python · SMTP`

**Problem:** SSL certificate expirations across internal and external environments risked unexpected outages with no proactive monitoring in place.

**Solution:** Built a Python script that checks SSL certificate health across a list of domains and sends alert emails before expiry.

**Impact:** Prevented certificate-related downtime and simplified monitoring across environments.

---

## Live Web Projects

| Project | Description |
|---|---|
| [HantaHotMap.com](https://hantahotmap.com) | Live hantavirus outbreak tracker pulling data from WHO, CDC, and ECDC |
| [EbolaHotMap.com](https://ebolahotmap.com) | Global Ebola outbreak surveillance, updated daily |
| [NationalGasCost.com](https://nationalgascost.com) | National fuel price aggregation site |

---

## About

IT professional with experience across network infrastructure, security, and web development.  
Based in Arizona. Open to roles in networking, GRC, and web development.
