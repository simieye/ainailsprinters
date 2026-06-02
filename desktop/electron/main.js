const { app, BrowserWindow, shell, Menu, dialog, globalShortcut } = require('electron');
const path = require('path');

let mainWindow = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1024,
    minHeight: 680,
    title: 'AI NAILS Desktop',
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 12, y: 12 },
    backgroundColor: '#08080f',
    vibrancy: 'dark',
    visualEffectState: 'active',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false
    },
    show: false
  });

  mainWindow.loadFile(path.join(__dirname, '../../preview/index.html'));

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
  });

  // 在外部浏览器打开链接
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // 菜单栏
  const template = [
    {
      label: 'AI NAILS',
      submenu: [
        { label: '关于 AI NAILS', role: 'about' },
        { type: 'separator' },
        { label: '设置...', accelerator: 'Cmd+,', click: () => mainWindow.webContents.send('navigate', 'settings') },
        { type: 'separator' },
        { label: '退出 AI NAILS', accelerator: 'Cmd+Q', role: 'quit' }
      ]
    },
    {
      label: '文件',
      submenu: [
        { label: '新建创作', accelerator: 'Cmd+N', click: () => mainWindow.webContents.send('navigate', 'create') },
        { type: 'separator' },
        { label: '关闭窗口', accelerator: 'Cmd+W', role: 'close' }
      ]
    },
    {
      label: '视图',
      submenu: [
        { label: '创作舱', accelerator: 'Cmd+1', click: () => mainWindow.webContents.send('navigate', 'create') },
        { label: '龙虾智控', accelerator: 'Cmd+2', click: () => mainWindow.webContents.send('navigate', 'device') },
        { label: '社区', accelerator: 'Cmd+3', click: () => mainWindow.webContents.send('navigate', 'community') },
        { label: '支付中心', accelerator: 'Cmd+4', click: () => mainWindow.webContents.send('navigate', 'payment') },
        { label: '智能体集群', accelerator: 'Cmd+5', click: () => mainWindow.webContents.send('navigate', 'agents') },
        { label: '模型提供商', accelerator: 'Cmd+6', click: () => mainWindow.webContents.send('navigate', 'providers') },
        { label: 'OpenClaw控制台', accelerator: 'Cmd+7', click: () => mainWindow.webContents.send('navigate', 'openclaw') },
        { type: 'separator' },
        { label: '管理后台', accelerator: 'Cmd+8', click: () => mainWindow.webContents.send('navigate', 'admin') },
        { type: 'separator' },
        { label: '切换侧边栏', accelerator: 'Cmd+\\', click: () => mainWindow.webContents.send('toggle-sidebar') },
        { label: '命令面板', accelerator: 'Cmd+K', click: () => mainWindow.webContents.send('command-palette') },
        { type: 'separator' },
        { label: '开发者工具', accelerator: 'Cmd+Option+I', role: 'toggleDevTools' },
        { label: '重新加载', accelerator: 'Cmd+R', role: 'reload' }
      ]
    },
    {
      label: '帮助',
      submenu: [
        { label: 'OpenClaw 控制台', click: () => shell.openExternal('http://127.0.0.1:18789/chat?session=main') },
        { label: 'ClawSkill Hub', click: () => shell.openExternal('https://clawskill.hub') },
        { type: 'separator' },
        { label: 'GitHub 仓库', click: () => shell.openExternal('https://github.com/simieye/ainailsprinters') }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);

  // 注册全局快捷键
  app.on('ready', () => {
    globalShortcut.register('CommandOrControl+K', () => {
      mainWindow.webContents.send('command-palette');
    });
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  globalShortcut.unregisterAll();
  app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
