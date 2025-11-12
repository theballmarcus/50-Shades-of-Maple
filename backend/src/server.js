import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import {
    initDb,
    createUser,
    getUser,
    verifyCredentials,
    saveChapterState,
    getChapterState,
    truncateChapterStates,
    truncateUsers
} from './db.js';
import jwt from 'jsonwebtoken';
import {
    evalMapleSafe
} from './mapleSandbox.js';

const app = express();
const PORT = Number(process.env.PORT || 3000);
const API_KEY = process.env.API_KEY;
const JWT_SECRET = process.env.JWT_SECRET || API_KEY || 'dev-secret';


app.use(helmet());
app.use(cors({
    origin: (origin, cb) => cb(null, true),
    credentials: false
}));
app.use(express.json({
    limit: '32kb'
}));

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
    if (!API_KEY) return res.status(500).json({
        error: 'Server API key not configured.'
    });
    const key = req.get('x-api-key');
    if (key !== API_KEY) return res.status(401).json({
        error: 'Unauthorized'
    });
    next();
}

await initDb();

// --- Routes ---
app.get('/health', async (_req, res) => {
    res.json({
        ok: true,
        uptime: process.uptime(),
        time: new Date().toISOString()
    });
});

// Create user
app.post('/users', requireKey, async (req, res) => {
    try {
        const {
            username,
            password
        } = req.body || {};
        console.log(username)
        if (typeof username !== 'string') {
            return res.status(400).json({
                error: 'Invalid body'
            });
        }

        const trimmedName = username.trim();

        if (trimmedName.length < 1 || trimmedName.length > 100) {
            return res.status(400).json({
                error: 'Invalid name length'
            });
        }

        const user = await createUser({
            username: trimmedName,
            password
        });
        res.status(201).json({
            user
        });
    } catch (err) {
        if (err && err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                error: 'Username already exists'
            });
        }
        console.error('Create user error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

app.get('/users/:id', requireKey, async (req, res) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id) || id < 1) return res.status(400).json({
            error: 'Invalid id'
        });

        const user = await getUser(id);
        if (!user) return res.status(404).json({
            error: 'Not found'
        });
        res.json({
            user
        });
    } catch (err) {
        console.error('Get user error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

// Login (returns JWT)
app.post('/login', async (req, res) => {
    try {
        const {
            username,
            password
        } = req.body || {};
        if (typeof username !== 'string' || typeof password !== 'string') {
            return res.status(400).json({
                error: 'Invalid body'
            });
        }

        const user = await verifyCredentials(username.trim(), password);
        if (!user) return res.status(401).json({
            error: 'Invalid credentials'
        });

        const token = jwt.sign({
            id: user.id
        }, JWT_SECRET, {
            expiresIn: '14d'
        });
        res.json({
            token,
            user
        });
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

// Auth middleware: expects Authorization: Bearer <token>
function requireAuth(req, res, next) {
    const auth = req.get('authorization') || '';
    const parts = auth.split(' ');
    if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
        return res.status(401).json({
            error: 'Missing or invalid authorization header'
        });
    }
    const token = parts[1];
    try {
        const payload = jwt.verify(token, JWT_SECRET);
        req.user = {
            id: payload.id
        };
        return next();
    } catch (err) {
        return res.status(401).json({
            error: 'Invalid token'
        });
    }
}

// Save chapter state for logged-in user
app.post('/chapter_states', requireAuth, async (req, res) => {
    try {
        const {
            chapter_id,
            content,
            completed
        } = req.body || {};
        const userId = Number(req.user && req.user.id);
        const chapterId = Number(chapter_id);

        if (!Number.isInteger(userId) || userId < 1) return res.status(401).json({
            error: 'Invalid user'
        });
        if (!Number.isInteger(chapterId) || chapterId < 1) return res.status(400).json({
            error: 'Invalid chapter_id'
        });
        if (typeof content !== 'string') return res.status(400).json({
            error: 'Invalid content'
        });

        const state = await saveChapterState({
            user_id: userId,
            chapter_id: chapterId,
            content,
            completed: !!completed
        });
        res.json({
            state
        });
    } catch (err) {
        console.error('Save chapter state error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

// Get chapter state for logged-in user
app.get('/chapter_states/:chapter_id', requireAuth, async (req, res) => {
    try {
        const chapterId = Number(req.params.chapter_id);
        const userId = Number(req.user && req.user.id);
        if (!Number.isInteger(chapterId) || chapterId < 1) return res.status(400).json({
            error: 'Invalid chapter id'
        });
        if (!Number.isInteger(userId) || userId < 1) return res.status(401).json({
            error: 'Invalid user'
        });

        const state = await getChapterState({
            user_id: userId,
            chapter_id: chapterId
        });
        if (!state) return res.status(404).json({
            error: 'Not found'
        });
        res.json({
            state
        });
    } catch (err) {
        console.error('Get chapter state error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

app.post('/maple/eval', requireKey, mapleLimiter, async (req, res) => {
    try {
        const {
            code
        } = req.body || {};

        if (typeof code !== 'string' || code.trim().length === 0) {
            return res.status(400).json({
                error: 'Missing code'
            });
        }

        const result = await evalMapleSafe(code);
        res.json({
            ok: true,
            stdout: result.stdout,
            stderr: result.stderr
        });

    } catch (err) {
        if (err && err.code === 'UNSAFE_CODE') {
            return res.status(400).json({
                error: 'Rejected: code not allowed by sandbox.'
            });
        }

        if (err && err.code === 'TIMEOUT') {
            return res.status(408).json({
                error: 'Evaluation timed out.'
            });
        }

        console.error('Maple eval error:', err);
        res.status(500).json({
            error: 'Evaluation failed.'
        });
    }
});

app.post('/truncate_db', requireKey, async (req, res) => {
    try {
        await truncateChapterStates();
        await truncateUsers();
        await initDb();

        res.json({
            ok: true
        });
    } catch (err) {
        console.error('Truncate DB error:', err);
        res.status(500).json({
            error: 'Server error'
        });
    }
});

app.listen(PORT, () => {
    console.log(`API listening on http://0.0.0.0:${PORT}`);
});