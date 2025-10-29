import mysql from 'mysql2/promise';


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
    const sql = `CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;`;
    await pool.query(sql);
}

export async function truncateUsers() {
    await pool.query('TRUNCATE TABLE users');
}

export async function createUser({ email, name }) {
    const [result] = await pool.query(
        'INSERT INTO users (email, name) VALUES (?, ?)',
        [email, name]
    );
    return { id: result.insertId, email, name };
}

export async function getUser(id) {
    const [rows] = await pool.query('SELECT id, email, name, created_at FROM users WHERE id = ?', [id]);
    return rows[0] || null;
}