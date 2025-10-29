import { spawn } from 'node:child_process';

const DEFAULT_TIMEOUT = Number(process.env.MAPLE_TIMEOUT_MS || 2000);
const MAPLE_PATH = process.env.MAPLE_PATH || '/opt/maple/bin/maple';
const MAX_CODE_CHARS = Number(process.env.MAPLE_MAX_CODE_CHARS || 300);
const MAX_OUTPUT_BYTES = Number(process.env.MAPLE_MAX_OUTPUT_BYTES || 65536);

// Allowlist: elementary math + calculus + simple variables (x,y,z,n,...)
const ALLOWED_IDENTIFIERS = new Set([
  'pi', 'digits',
  'sin','cos','tan','sec','csc','cot',
  'arcsin','arccos','arctan',
  'exp','ln','log','sqrt',
  'simplify','factor','expand','evalf',
  'diff','int','limit','subs','solve'
]);

const IDENT_RE = /[A-Za-z][A-Za-z0-9_]*\b/g;

function isCodeSafe(mapleCode) {
  if (typeof mapleCode !== 'string') return false;
  const code = mapleCode.trim();
  if (code.length === 0 || code.length > MAX_CODE_CHARS) return false;

  // Block known-dangerous constructs and meta / IO features
  const forbiddenPatterns = [
    /`/,                  // backticks (name escapes)
    /\bwith\s*\(/i,       // loading packages into scope
    /\bread\b/i,          // reading files
    /\binterface\b/i,     // changing interface/kernel options
    /\bsystem\b/i,        // external commands
    /\bfopen\b/i,         // file IO
    /\bprintf?\b\s*\(/i,  // user-controlled printing (we add our own)
    /\bkernelopts?\b/i,
    /\breadlib\b/i,
    /\bimport\b/i,
    /\bLibraryTools\b/i,
    /\bFileTools\b/i
  ];
  if (forbiddenPatterns.some((re) => re.test(code))) return false;

//   const disallowedChars = /[^A-Za-z0-9_\s\t\n\r\(\)\[\]\{\}\+\-\*\/\^\.;:,]/;
//   if (disallowedChars.test(code)) return false;

//   const ids = code.match(IDENT_RE) || [];
//   for (const id of ids) {
//     const lower = id.toLowerCase();
//     if (/^[a-z]$/.test(lower)) continue; 
//     if (!ALLOWED_IDENTIFIERS.has(lower)) return false;
//   }

  return true;
}

export function evalMapleSafe(mapleCode) {
    console.log('Evaluating Maple code:', mapleCode);
    return new Promise((resolve, reject) => {
        if (!isCodeSafe(mapleCode)) {
            return reject(Object.assign(new Error('Unsafe or too-large Maple code.'), { code: 'UNSAFE_CODE' }));
        }

        const child = spawn(MAPLE_PATH, ['-z', '-q', '-s'], { stdio: ['pipe', 'pipe', 'pipe'] });
        const sentinel = '__DONE__';
        const sanitized = mapleCode.replace(/;$/, '');
        const input = `${sanitized};\nprintf(\"${sentinel}\\n\");\n`;

        let stdoutBuf = Buffer.alloc(0);
        let stderrBuf = Buffer.alloc(0);
        let finished = false;

        const finish = (err, out) => {
            if (finished) return;

            finished = true;
            try { 
                child.kill('SIGKILL'); 

            } catch {

            }

            if (err) return reject(err);
            resolve(out);
        };

        const timer = setTimeout(() => {
            finish(Object.assign(new Error('Maple evaluation timed out.'), { code: 'TIMEOUT' }));
            child.kill('SIGKILL');
        }, DEFAULT_TIMEOUT);

        child.stdout.on('data', (chunk) => {
            let text = chunk.toString('utf8');
            console.log('Maple stdout chunk:', text);

            // Clean up formatting
            text = text.replace(/^\s+/gm, '');
            text = text.replace(/\n\n+/g, '\n');

            // Reconvert to Buffer for accumulation
            const cleanedChunk = Buffer.from(text, 'utf8');
            stdoutBuf = Buffer.concat([stdoutBuf, cleanedChunk]);


            if (stdoutBuf.length > MAX_OUTPUT_BYTES) {
                clearTimeout(timer);
                return finish(Object.assign(new Error('Output too large.'), { code: 'TIMEOUT' }));
            }

            if (stdoutBuf.includes(sentinel) || stdoutBuf.includes("error,")) {
                clearTimeout(timer);
                const outStr = stdoutBuf.toString('utf8');
                const result = outStr.split(sentinel)[0].trim();
                return finish(null, { stdout: result, stderr: stderrBuf.toString('utf8').trim() });
            }
        });

        child.stderr.on('data', (chunk) => {
            console.log('Maple stderr chunk:', chunk.toString('utf8'));
            stderrBuf = Buffer.concat([stderrBuf, chunk]);
        });

        child.on('error', (err) => {
            clearTimeout(timer);
            finish(err);
            
        });

        child.stdin.end(input);
    });
}
