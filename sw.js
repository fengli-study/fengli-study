// Service Worker v4 — 每次都检查更新，不缓存 HTML/JS/CSS
const CACHE = 'fp-workbench-v31';

// install 时跳过缓存（不再预缓存任何文件）
self.addEventListener('install', e => {
  self.skipWaiting();
});

// activate 时清空所有旧缓存
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.map(k => caches.delete(k))))
  );
  self.clients.claim();
});

// 所有请求都走网络，不做任何缓存
self.addEventListener('fetch', e => {
  e.respondWith(fetch(e.request));
});
