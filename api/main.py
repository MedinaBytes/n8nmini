from fastapi import FastAPI, Request
import sqlite3
import os

app = FastAPI(title="AIPhoneServer API", version="1.0.0")

DB_PATH = "memory/memory.db"

def get_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

@app.on_event("startup")
def startup():
    conn = get_db()
    conn.execute('''CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, content TEXT)''')
    conn.commit()
    conn.close()

@app.get("/")
def root():
    return {"status": "AIPhoneServer is running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/notes")
async def add_note(request: Request):
    data = await request.json()
    content = data.get("content", "")
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO notes (content) VALUES (?)", (content,))
    conn.commit()
    note_id = cursor.lastrowid
    conn.close()
    return {"id": note_id, "content": content}

@app.get("/notes")
def get_notes():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, content FROM notes")
    notes = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return {"notes": notes}
