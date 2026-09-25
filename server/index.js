const express = require('express');
const fs = require('fs');
const path = require('path');

const port = Number(process.env.PORT) || 8787;
const file = path.join(__dirname, 'data', 'db.json');

function empty() {
  return { users: {} };
}

function readDb() {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (error) {
    return empty();
  }
}

function writeDb(db) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(db, null, 2));
}

function userOf(db, installId) {
  if (!db.users[installId]) db.users[installId] = { chats: {}, operations: [] };
  if (!db.users[installId].operations) db.users[installId].operations = [];
  return db.users[installId];
}

function alreadyApplied(user, opId) {
  if (!opId) return false;
  return user.operations.some((op) => op.id === opId);
}

function remember(user, opId, kind, chatId) {
  if (!opId || alreadyApplied(user, opId)) return;
  user.operations.push({
    id: opId,
    kind: kind || 'put',
    chatId,
    at: new Date().toISOString(),
  });
}

function chatView(chat) {
  return {
    id: chat.id,
    title: chat.title,
    updatedAt: chat.updatedAt,
    isPinned: Boolean(chat.isPinned),
    messages: chat.messages || [],
  };
}

const app = express();
app.use(express.json({ limit: '2mb' }));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/users', (request, response) => {
  const db = readDb();
  const users = Object.entries(db.users).map(([installId, user]) => ({
    installId,
    chats: Object.keys(user.chats || {}).length,
  }));
  response.json(users);
});

app.get('/api/users/:installId', (request, response) => {
  const db = readDb();
  const user = db.users[request.params.installId];
  const chats = Object.values(user?.chats || {})
    .map(chatView)
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt));
  response.json({
    installId: request.params.installId,
    chats,
    operations: user?.operations || [],
  });
});

app.post('/api/users/:installId/chats', (request, response) => {
  const title = String(request.body?.title || '').trim();
  if (!title) {
    response.status(400).json({ error: 'Title is required' });
    return;
  }
  const db = readDb();
  const user = userOf(db, request.params.installId);
  const now = new Date().toISOString();
  const id = `c_${Date.now()}`;
  user.chats[id] = {
    id,
    title,
    updatedAt: now,
    isPinned: false,
    messages: [],
  };
  writeDb(db);
  response.status(201).json(chatView(user.chats[id]));
});

app.put('/api/users/:installId/chats/:chatId', (request, response) => {
  const body = request.body || {};
  const db = readDb();
  const user = userOf(db, request.params.installId);
  const opId = body.opId ? String(body.opId) : '';
  if (alreadyApplied(user, opId)) {
    response.json({ ok: true, duplicate: true });
    return;
  }
  const now = new Date().toISOString();
  const previous = user.chats[request.params.chatId];
  user.chats[request.params.chatId] = {
    id: request.params.chatId,
    title: String(body.title || previous?.title || 'Untitled').trim(),
    updatedAt: body.updatedAt || now,
    isPinned: Boolean(body.isPinned),
    messages: Array.isArray(body.messages) ? body.messages : previous?.messages || [],
  };
  remember(user, opId, body.opKind, request.params.chatId);
  writeDb(db);
  response.json(chatView(user.chats[request.params.chatId]));
});

app.post('/api/users/:installId/chats/:chatId/messages', (request, response) => {
  const content = String(request.body?.content || '').trim();
  if (!content) {
    response.status(400).json({ error: 'Message is required' });
    return;
  }
  const db = readDb();
  const user = userOf(db, request.params.installId);
  const chat = user.chats[request.params.chatId];
  if (!chat) {
    response.status(404).json({ error: 'Chat not found' });
    return;
  }
  const now = new Date().toISOString();
  chat.messages.push({
    id: `m_${Date.now()}`,
    conversationId: chat.id,
    role: 'user',
    content,
    status: 'complete',
    createdAt: now,
  });
  chat.updatedAt = now;
  writeDb(db);
  response.status(201).json(chatView(chat));
});

app.delete('/api/users/:installId/chats/:chatId', (request, response) => {
  const db = readDb();
  const user = userOf(db, request.params.installId);
  const opId = request.query.opId ? String(request.query.opId) : '';
  if (alreadyApplied(user, opId)) {
    response.json({ ok: true, duplicate: true });
    return;
  }
  if (user.chats) delete user.chats[request.params.chatId];
  remember(user, opId, 'delete', request.params.chatId);
  writeDb(db);
  response.json({ ok: true });
});

app.listen(port, () => {
  process.stdout.write(`history server on ${port}\n`);
});
