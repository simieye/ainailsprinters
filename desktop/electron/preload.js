const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  navigate: (page) => ipcRenderer.send('navigate', page),
  onNavigate: (callback) => ipcRenderer.on('navigate', (event, page) => callback(page)),
  onToggleSidebar: (callback) => ipcRenderer.on('toggle-sidebar', () => callback()),
  onCommandPalette: (callback) => ipcRenderer.on('command-palette', () => callback()),
  openExternal: (url) => ipcRenderer.send('open-external', url),
  platform: process.platform,
  version: process.env.npm_package_version || '4.0.0'
});
