import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';


const pool = mysql.createPool({
    host: process.env.MYSQL_HOST || 'localhost',
    port: process.env.MYSQL_PORT || 3306,
    user: process.env.MYSQL_USER || 'maple_user',
    password: process.env.MYSQL_PASSWORD || 'maple_pass',
    database: process.env.MYSQL_DATABASE || 'maple_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

export async function initDb() {
    // Run each CREATE TABLE separately to avoid multiple-statement errors
    const usersSql = `CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB`;

    const chapterSql = `CREATE TABLE IF NOT EXISTS chapter_states (
    user_id INT NOT NULL,
    chapter_id INT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    content TEXT,
    PRIMARY KEY (user_id, chapter_id)
) ENGINE=InnoDB`;

    await pool.query(usersSql);
    await pool.query(chapterSql);
}

export async function truncateUsers() {
    await pool.query('DROP TABLE users');
}

export async function truncateChapterStates() {
    await pool.query('DROP TABLE chapter_states');
}


export async function createUser({ username, password = null }) {
    // If password provided, hash it
    let hashed = null;
    if (password && typeof password === 'string') {
        const salt = await bcrypt.genSalt(10);
        hashed = await bcrypt.hash(password, salt);
    }

    const [result] = await pool.query(
        'INSERT INTO users (name, password) VALUES (?, ?)',
        [username, hashed]
    );
    return { id: result.insertId, username };
}

export async function getUserByUsername(username) {
    const [rows] = await pool.query('SELECT id, name, password, created_at FROM users WHERE name = ?', [username]);
    return rows[0] || null;
}

export async function verifyCredentials(username, password) {
    const user = await getUserByUsername(username);
    if (!user || !user.password) return null;
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return null;
    // Don't expose password
    return { id: user.id, name: user.name };
}

export async function getUser(id) {
    const [rows] = await pool.query('SELECT id, name, created_at FROM users WHERE id = ?', [id]);
    return rows[0] || null;
}

export async function saveChapterState({ user_id, chapter_id, content, completed = false }) {
    // Upsert into chapter_states using primary key (user_id, chapter_id)
    const sql = `INSERT INTO chapter_states (user_id, chapter_id, completed, content)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE completed = VALUES(completed), content = VALUES(content)`;
    await pool.query(sql, [user_id, chapter_id, completed ? 1 : 0, content]);
    return { user_id, chapter_id, completed: Boolean(completed), content };
}

export async function getChapterState({ user_id, chapter_id }) {
    const [rows] = await pool.query(
        'SELECT user_id, chapter_id, completed, content FROM chapter_states WHERE user_id = ? AND chapter_id = ?',
        [user_id, chapter_id]
    );
    if (!rows || rows.length === 0) return null;
    const r = rows[0];
    return { user_id: r.user_id, chapter_id: r.chapter_id, completed: !!r.completed, content: r.content };
}