# iFix Reset Request App

##  Problem
Operators had to walk to the IS office to request HMI/iFix resets, causing avoidable production downtime and backlog.

##  Solution
A lightweight internal web app that lets operators submit reset requests digitally:
- **Frontend:** React (simple form)
- **Backend:** FastAPI (validates request, logs, optionally forwards to a webhook/email/queue)
- **Hosting:** IIS (serves frontend) + FastAPI via `uvicorn` (or behind IIS reverse proxy)

##  Impact
- Reduced operator downtime by ~25%
- Faster IS response and clearer tracking
- Reusable internal pattern for future tools

---

##  Repo Layout
- `/frontend` — React app (instructions below)
- `/backend` — FastAPI service (ready to run)

---

##  Quick Start — Backend (FastAPI)
    cd backend
    python -m venv .venv && . .venv/Scripts/activate   # Windows PowerShell
    pip install -r requirements.txt
    uvicorn main:app --host 0.0.0.0 --port 8001 --reload

Health check:
- Open: `http://localhost:8001/health` → `{"status":"ok"}`

**Env (optional):**
- Copy `.env.example` to `.env` and set `WEBHOOK_URL=` (Teams/Slack/etc.).  
  The `/request-reset` endpoint will forward messages if configured.

---

##  Quick Start — Frontend (React via Vite)
1) Scaffold and install:
    npm create vite@latest frontend -- --template react
    cd frontend
    npm install

2) Create `.env` in `/frontend`:
    VITE_BACKEND_URL=http://localhost:8001

3) Replace `src/App.jsx` with this minimal form:

```jsx
import { useState } from 'react'

function App() {
  const [line, setLine] = useState('')
  const [station, setStation] = useState('')
  const [operator, setOperator] = useState('')
  const [reason, setReason] = useState('')
  const [resp, setResp] = useState(null)

  const submit = async (e) => {
    e.preventDefault()
    const url = import.meta.env.VITE_BACKEND_URL + '/request-reset'
    const r = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ line, station, operator, reason })
    })
    const data = await r.json()
    setResp(data)
  }

  return (
    <div style={{maxWidth: 480, margin: '2rem auto', fontFamily: 'system-ui'}}>
      <h1>iFix Reset Request</h1>
      <form onSubmit={submit}>
        <label>
          Line
          <input value={line} onChange={e=>setLine(e.target.value)} required/>
        </label><br/>
        <label>
          Station
          <input value={station} onChange={e=>setStation(e.target.value)} required/>
        </label><br/>
        <label>
          Operator
          <input value={operator} onChange={e=>setOperator(e.target.value)} />
        </label><br/>
        <label>
          Reason
          <textarea value={reason} onChange={e=>setReason(e.target.value)} />
        </label><br/>
        <button type="submit">Submit</button>
      </form>
      {resp && <pre>{JSON.stringify(resp, null, 2)}</pre>}
    </div>
  )
}

export default App


4) Run the dev server:
    npm run dev

---

## Security Notes
- **Do not** commit real `.env`, webhook URLs, API keys, internal hostnames.
- Add a `.gitignore` to exclude `.venv/`, `node_modules/`, `.env`.

Example `.gitignore` entries:
    .venv/
    __pycache__/
    *.pyc
    node_modules/
    .env

---

## Next Steps
- Add screenshots (form + example alert)
- Document IIS reverse-proxy notes for FastAPI (if used in production)
- Optional: add basic auth or AD auth for the form

---

**Author:** Bryan Fugatt  
**Focus:** Automation • Workflow Optimization • Creative Solution Design
