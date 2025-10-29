import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { initDb, createUser, getUser } from './db.js';
import { evalMapleSafe } from './mapleSandbox.js';

const app = express();
const PORT = Number(process.env.PORT || 3000);
const API_KEY = process.env.API_KEY;


app.use(helmet());
app.use(cors({
  origin: (origin, cb) => cb(null, true),
  credentials: false
}));
app.use(express.json({ limit: '32kb' }));

const globalLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: 'Too many requests, slow down.'
});

app.use(globalLimiter);

const mapleLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: 'Too many evals, try later.'
});

function requireKey(req, res, next) {
  if (!API_KEY) return res.status(500).json({ error: 'Server API key not configured.' });
  const key = req.get('x-api-key');
  if (key !== API_KEY) return res.status(401).json({ error: 'Unauthorized' });
  next();
}

await initDb();

// --- Routes ---
app.get('/health', async (_req, res) => {
  res.json({ ok: true, uptime: process.uptime(), time: new Date().toISOString() });
});

// Create user
app.post('/users', requireKey, async (req, res) => {
  try {
    const { email, name } = req.body || {};

    if (typeof email !== 'string' || typeof name !== 'string') {
      return res.status(400).json({ error: 'Invalid body' });
    }

    const trimmedEmail = email.trim();
    const trimmedName = name.trim();

    if (!/^\S+@\S+\.\S+$/.test(trimmedEmail)) {
      return res.status(400).json({ error: 'Invalid email' });
    }
    if (trimmedName.length < 1 || trimmedName.length > 100) {
      return res.status(400).json({ error: 'Invalid name length' });
    }

    const user = await createUser({ email: trimmedEmail, name: trimmedName });
    res.status(201).json({ user });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    console.error('Create user error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

app.get('/users/:id', requireKey, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) return res.status(400).json({ error: 'Invalid id' });

    const user = await getUser(id);
    if (!user) return res.status(404).json({ error: 'Not found' });
    res.json({ user });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/maple/eval', requireKey, mapleLimiter, async (req, res) => {
  try {
    const { code } = req.body || {};

    if (typeof code !== 'string' || code.trim().length === 0) {
      return res.status(400).json({ error: 'Missing code' });
    }

    const result = await evalMapleSafe(code);
    res.json({ ok: true, stdout: result.stdout, stderr: result.stderr });

  } catch (err) {
    if (err && err.code === 'UNSAFE_CODE') {
      return res.status(400).json({ error: 'Rejected: code not allowed by sandbox.' });
    }

    if (err && err.code === 'TIMEOUT') {
      return res.status(408).json({ error: 'Evaluation timed out.' });
    }

    console.error('Maple eval error:', err);
    res.status(500).json({ error: 'Evaluation failed.' });
  }
});

app.listen(PORT, () => {
  console.log(`API listening on http://0.0.0.0:${PORT}`);
});
