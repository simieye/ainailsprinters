// AI NAILS Desktop v4.0 — 完整 JavaScript 功能
// ================================================================
let isLoggedIn = false, currentPage = 'create', authMode = 'login';
let authLoginMode = 'email', authRegMode = 'email', sidebarCollapsed = false;
let payScene = 'recharge', selectedAmount = 1000, selectedCurrency = 'CNY';
let selectedPayment = 'wechat', selectedSubTier = 'pro', cmdSelectedIdx = 0;
let defaultProvider = 'openai';

// AUTH
function switchAuthTab(tab){authMode=tab;document.getElementById('auth-login-card').classList.toggle('hidden',tab!=='login');document.getElementById('auth-register-card').classList.toggle('hidden',tab!=='register')}
function switchAuthLoginMode(mode){authLoginMode=mode;document.querySelectorAll('#auth-login-card .auth-tab').forEach(el=>{el.classList.toggle('active',(mode==='email'&&el.textContent.includes('邮箱'))||(mode==='phone'&&el.textContent.includes('手机')))});document.getElementById('auth-login-email').classList.toggle('hidden',mode!=='email');document.getElementById('auth-login-phone').classList.toggle('hidden',mode!=='phone')}
function switchAuthRegMode(mode){authRegMode=mode;document.querySelectorAll('#auth-register-card .auth-tab').forEach(el=>{el.classList.toggle('active',(mode==='email'&&el.textContent.includes('邮箱'))||(mode==='phone'&&el.textContent.includes('手机')))});document.getElementById('auth-reg-email').classList.toggle('hidden',mode!=='email');document.getElementById('auth-reg-phone').classList.toggle('hidden',mode!=='phone')}
function togglePassword(id){const i=document.getElementById(id);i.type=i.type==='password'?'text':'password'}
function checkAuthPasswordStrength(){const p=document.getElementById('auth-reg-password').value,b=document.getElementById('auth-strength-bar'),t=document.getElementById('auth-strength-text');let s=0;if(p.length>=8){s++;document.getElementById('auth-req-length').classList.add('met')}else document.getElementById('auth-req-length').classList.remove('met');if(/[A-Z]/.test(p)){s++;document.getElementById('auth-req-upper').classList.add('met')}else document.getElementById('auth-req-upper').classList.remove('met');if(/\d/.test(p)){s++;document.getElementById('auth-req-digit').classList.add('met')}else document.getElementById('auth-req-digit').classList.remove('met');if(/[^A-Za-z0-9]/.test(p))s++;b.className='strength-bar-fill';if(s===0){b.style.width='0%';t.textContent='请输入密码'}else if(s===1){b.style.width='25%';b.classList.add('strength-weak');t.textContent='弱'}else if(s===2){b.style.width='50%';b.classList.add('strength-fair');t.textContent='一般'}else if(s===3){b.style.width='75%';b.classList.add('strength-good');t.textContent='强'}else{b.style.width='100%';b.classList.add('strength-strong');t.textContent='非常强'}}

function handleAppLogin(){
  if(authLoginMode==='email'){const e=document.getElementById('auth-login-email-input').value,p=document.getElementById('auth-login-password').value;if(!e||!p){showToast('请填写完整信息','error');return}if(!e.includes('@')){showToast('请输入有效的邮箱地址','error');return}}
  else{const p=document.getElementById('auth-login-phone-input').value,c=document.getElementById('auth-login-code').value;if(!p||!c){showToast('请填写完整信息','error');return}if(c.length!==6){showToast('请输入6位验证码','error');return}}
  showToast('登录成功！欢迎回来 👋','success');enterDesktop();
}
function socialAppLogin(pr){const n={wechat:'微信',apple:'Apple ID',google:'Google'};showToast(`正在跳转${n[pr]}授权...`,'info');setTimeout(()=>{showToast(`${n[pr]}登录成功！`,'success');enterDesktop()},1500)}
function biometricAppLogin(){showToast('正在验证生物识别...','info');setTimeout(()=>{showToast('面容识别成功！👋','success');enterDesktop()},1200)}
function handleAppRegister(){
  if(!document.getElementById('auth-reg-agree').checked){showToast('请先同意服务条款和隐私政策','error');return}
  if(authRegMode==='email'){const u=document.getElementById('auth-reg-username').value,em=document.getElementById('auth-reg-email').value,pw=document.getElementById('auth-reg-password').value;if(!u||!em||!pw){showToast('请填写完整信息','error');return}if(pw.length<8){showToast('密码至少8个字符','error');return}document.getElementById('sidebar-username').textContent=u}
  else{const ph=document.getElementById('auth-reg-phone-input').value,co=document.getElementById('auth-reg-code').value,pw=document.getElementById('auth-reg-phone-password').value;if(!ph||!co||!pw){showToast('请填写完整信息','error');return}document.getElementById('sidebar-username').textContent='用户 '+ph.slice(-4)}
  const inv=document.getElementById('auth-reg-invite').value;showToast('注册成功！'+(inv?' 邀请码已确认！':''),'success');setTimeout(()=>enterDesktop(),1000)
}
function sendAuthLoginCode(){const b=document.getElementById('auth-login-code-btn');if(b.disabled)return;showToast('验证码已发送','success');startCountdown(b)}
function sendAuthRegCode(){const b=document.getElementById('auth-reg-code-btn');if(b.disabled)return;showToast('验证码已发送','success');startCountdown(b)}
function startCountdown(btn){let s=60;btn.disabled=true;btn.textContent=`${s}s后重试`;const t=setInterval(()=>{s--;btn.textContent=`${s}s后重试`;if(s<=0){clearInterval(t);btn.disabled=false;btn.textContent='获取验证码'}},1000)}
function enterDesktop(){isLoggedIn=true;document.getElementById('auth-overlay').classList.add('hidden');document.getElementById('desktop-shell').classList.add('visible');updateStatusTime();setInterval(updateStatusTime,30000)}
function handleLogout(){isLoggedIn=false;document.getElementById('desktop-shell').classList.remove('visible');document.getElementById('auth-overlay').classList.remove('hidden');switchAuthTab('login');navigateTo('create');showToast('已安全退出','info')}

// NAVIGATION
function navigateTo(page){
  currentPage=page;
  document.querySelectorAll('.sidebar-nav-item').forEach(el=>el.classList.toggle('active',el.dataset.page===page));
  document.querySelectorAll('.content-page').forEach(el=>el.classList.remove('active'));
  const t=document.getElementById('page-'+page);if(t)t.classList.add('active');
  const names={create:'创作舱 · TALK TO CREATE',medialibrary:'媒体资源库 · 图库管理',device:'龙虾智控 · 设备仪表盘',community:'全球创作者社区',payment:'支付中心',agents:'智能体集群 · Skill 管理',providers:'AI 大模型提供商',openclaw:'OpenClaw 控制台',admin:'管理后台',settings:'设置'};
  document.getElementById('titlebar-page-name').textContent=names[page]||page;
  // 进入创作舱时刷新 Skill 快速安装状态
  if (page === 'create' && typeof refreshQuickAddChips === 'function') {
    setTimeout(() => refreshQuickAddChips(), 100);
  }
  // 进入资源库时刷新
  if (page === 'medialibrary') {
    setTimeout(() => {
      renderMediaLibraryStandalone();
      updateMediaCountsStandalone();
      renderTagFiltersStandalone();
    }, 50);
  }
}
function toggleSidebar(){sidebarCollapsed=!sidebarCollapsed;document.getElementById('sidebar').classList.toggle('collapsed',sidebarCollapsed);document.querySelector('.sidebar-collapse-btn').textContent=sidebarCollapsed?'▶':'◀ 收起菜单'}

// DEVICE
function switchDeviceMode(mode){document.querySelectorAll('#page-device .auth-tab').forEach(el=>{el.classList.toggle('active',(mode==='b2c'&&el.textContent.includes('B2C'))||(mode==='b2b'&&el.textContent.includes('B2B')))});document.getElementById('device-b2c').classList.toggle('hidden',mode!=='b2c');document.getElementById('device-b2b').classList.toggle('hidden',mode!=='b2b')}

// ========== 蓝牙连接管理 ==========
let bluetoothEnabled = false;
let bluetoothConnected = false;
let bluetoothDeviceName = '';
let btScanning = false;

function toggleBluetooth(enabled) {
  bluetoothEnabled = enabled;
  const statusEl = document.getElementById('bt-status-text');
  const scanArea = document.getElementById('bt-scan-area');
  const scanBtn = document.getElementById('bt-scan-btn');
  const disconnectBtn = document.getElementById('bt-disconnect-btn');
  const connectedInfo = document.getElementById('bt-connected-info');

  if (!enabled) {
    bluetoothConnected = false;
    bluetoothDeviceName = '';
    statusEl.textContent = '未连接';
    statusEl.className = 'conn-card-status';
    scanArea.classList.add('hidden');
    disconnectBtn.classList.add('hidden');
    connectedInfo.classList.add('hidden');
    scanBtn.classList.remove('hidden');
    showToast('蓝牙已关闭', 'info');
  } else {
    statusEl.textContent = '蓝牙已开启 · 等待连接';
    statusEl.className = 'conn-card-status';
    scanBtn.classList.remove('hidden');
    showToast('蓝牙已开启，请扫描设备', 'info');
  }
}

function scanBluetooth() {
  if (!bluetoothEnabled) {
    showToast('请先开启蓝牙', 'warning');
    return;
  }
  if (btScanning) return;
  btScanning = true;

  const scanArea = document.getElementById('bt-scan-area');
  const deviceList = document.getElementById('bt-device-list');
  const statusEl = document.getElementById('bt-status-text');

  scanArea.classList.remove('hidden');
  statusEl.textContent = '正在扫描...';
  statusEl.className = 'conn-card-status scanning';
  deviceList.innerHTML = '<div style="display:flex;align-items:center;gap:8px;font-size:12px;color:var(--text-secondary)"><div class="spinner" style="width:16px;height:16px;border-width:2px"></div> 正在扫描蓝牙设备...</div>';

  // 模拟扫描过程
  setTimeout(() => {
    const mockDevices = [
      { name: 'AI NAILS Pro #001', id: 'ANP-BT-001', signal: 4, paired: true },
      { name: 'AI NAILS Pro #002', id: 'ANP-BT-002', signal: 3, paired: false },
      { name: 'AI NAILS Mini #005', id: 'ANP-BT-005', signal: 2, paired: false },
      { name: 'AI NAILS Pro #008', id: 'ANP-BT-008', signal: 1, paired: false },
    ];
    renderBtDeviceList(mockDevices);
    statusEl.textContent = `发现 ${mockDevices.length} 台设备`;
    statusEl.className = 'conn-card-status';
    btScanning = false;
  }, 1800);
}

function renderBtDeviceList(devices) {
  const deviceList = document.getElementById('bt-device-list');
  deviceList.innerHTML = devices.map(d => `
    <div class="conn-device-item" onclick="connectBluetooth('${d.id}','${d.name}')">
      <div class="conn-device-info">
        <div class="conn-device-name">${d.paired ? '✓ ' : ''}${d.name}</div>
        <div class="conn-device-id">${d.id}${d.paired ? ' · 已配对' : ''}</div>
      </div>
      <div class="conn-device-signal">${[1,2,3,4].map(i => `<div class="signal-bar${i <= d.signal ? ' active' : ''}"></div>`).join('')}</div>
    </div>
  `).join('');
}

function connectBluetooth(deviceId, deviceName) {
  const statusEl = document.getElementById('bt-status-text');
  statusEl.textContent = '正在连接...';
  statusEl.className = 'conn-card-status scanning';

  setTimeout(() => {
    bluetoothConnected = true;
    bluetoothDeviceName = deviceName;
    document.getElementById('bt-connected-info').classList.remove('hidden');
    document.getElementById('bt-dev-name').textContent = deviceName;
    document.getElementById('bt-dev-meta').textContent = `ID: ${deviceId} | 信号: 强 | 已连接`;
    document.getElementById('bt-scan-area').classList.add('hidden');
    document.getElementById('bt-scan-btn').classList.add('hidden');
    document.getElementById('bt-disconnect-btn').classList.remove('hidden');
    statusEl.textContent = '已连接';
    statusEl.className = 'conn-card-status connected';
    document.getElementById('bt-toggle').checked = true;
    bluetoothEnabled = true;
    showToast(`蓝牙已连接: ${deviceName}`, 'success');
  }, 1200);
}

function disconnectBluetooth() {
  const statusEl = document.getElementById('bt-status-text');
  bluetoothConnected = false;
  bluetoothDeviceName = '';
  document.getElementById('bt-connected-info').classList.add('hidden');
  document.getElementById('bt-disconnect-btn').classList.add('hidden');
  document.getElementById('bt-scan-btn').classList.remove('hidden');
  statusEl.textContent = '蓝牙已开启 · 等待连接';
  statusEl.className = 'conn-card-status';
  showToast('蓝牙已断开连接', 'info');
}

// ========== WiFi 连接管理 ==========
let wifiEnabled = false;
let wifiConnected = false;
let wifiDeviceName = '';
let wifiScanning = false;
let selectedWifiSSID = '';

function toggleWifi(enabled) {
  wifiEnabled = enabled;
  const statusEl = document.getElementById('wifi-status-text');
  const scanArea = document.getElementById('wifi-scan-area');
  const scanBtn = document.getElementById('wifi-scan-btn');
  const disconnectBtn = document.getElementById('wifi-disconnect-btn');
  const connectedInfo = document.getElementById('wifi-connected-info');

  if (!enabled) {
    wifiConnected = false;
    wifiDeviceName = '';
    statusEl.textContent = '未连接';
    statusEl.className = 'conn-card-status';
    scanArea.classList.add('hidden');
    disconnectBtn.classList.add('hidden');
    connectedInfo.classList.add('hidden');
    scanBtn.classList.remove('hidden');
    showToast('WiFi 已关闭', 'info');
  } else {
    statusEl.textContent = 'WiFi 已开启 · 等待连接';
    statusEl.className = 'conn-card-status';
    scanBtn.classList.remove('hidden');
    showToast('WiFi 已开启，请扫描设备', 'info');
  }
}

function scanWifiDevices() {
  if (!wifiEnabled) {
    showToast('请先开启 WiFi', 'warning');
    return;
  }
  if (wifiScanning) return;
  wifiScanning = true;

  const scanArea = document.getElementById('wifi-scan-area');
  const deviceList = document.getElementById('wifi-device-list');
  const statusEl = document.getElementById('wifi-status-text');

  scanArea.classList.remove('hidden');
  statusEl.textContent = '正在扫描...';
  statusEl.className = 'conn-card-status scanning';
  deviceList.innerHTML = '<div style="display:flex;align-items:center;gap:8px;font-size:12px;color:var(--text-secondary)"><div class="spinner" style="width:16px;height:16px;border-width:2px"></div> 正在扫描局域网设备...</div>';

  setTimeout(() => {
    const mockDevices = [
      { name: 'AI NAILS Pro #001', id: 'ANP-WF-001', ip: '192.168.1.100', signal: 4 },
      { name: 'AI NAILS Pro #003', id: 'ANP-WF-003', ip: '192.168.1.103', signal: 2 },
      { name: 'AI NAILS Pro #007', id: 'ANP-WF-007', ip: '192.168.1.107', signal: 3 },
    ];
    renderWifiDeviceList(mockDevices);
    statusEl.textContent = `发现 ${mockDevices.length} 台设备`;
    statusEl.className = 'conn-card-status';
    wifiScanning = false;
  }, 2000);
}

function renderWifiDeviceList(devices) {
  const deviceList = document.getElementById('wifi-device-list');
  deviceList.innerHTML = devices.map(d => `
    <div class="conn-device-item" onclick="openWifiConfigForDevice('${d.id}','${d.name}','${d.ip}')">
      <div class="conn-device-info">
        <div class="conn-device-name">${d.name}</div>
        <div class="conn-device-id">${d.id} · IP: ${d.ip}</div>
      </div>
      <div class="conn-device-signal">${[1,2,3,4].map(i => `<div class="signal-bar${i <= d.signal ? ' active' : ''}"></div>`).join('')}</div>
    </div>
  `).join('');
}

function openWifiConfigForDevice(deviceId, deviceName, deviceIp) {
  document.getElementById('wifi-config-device-name').textContent = `为 ${deviceName} (${deviceIp}) 配置网络`;
  document.getElementById('wifi-config-overlay').dataset.deviceId = deviceId;
  document.getElementById('wifi-config-overlay').dataset.deviceName = deviceName;
  document.getElementById('wifi-config-overlay').dataset.deviceIp = deviceIp;
  document.getElementById('wifi-config-overlay').classList.remove('hidden');
  document.getElementById('wifi-pass-input').classList.remove('visible');
  document.getElementById('wifi-password').value = '';
  selectedWifiSSID = '';
  // 清除之前的选择
  document.querySelectorAll('#wifi-networks-list .wifi-network-item').forEach(el => el.classList.remove('selected'));
}

function selectWifiNetwork(el, ssid) {
  document.querySelectorAll('#wifi-networks-list .wifi-network-item').forEach(e => e.classList.remove('selected'));
  el.classList.add('selected');
  selectedWifiSSID = ssid;
  // 显示密码输入（除了开放网络）
  const passInput = document.getElementById('wifi-pass-input');
  if (ssid === 'AI_NAILS_Guest') {
    passInput.classList.remove('visible');
  } else {
    passInput.classList.add('visible');
    setTimeout(() => document.getElementById('wifi-password').focus(), 100);
  }
}

function toggleWifiPassVisibility() {
  const input = document.getElementById('wifi-password');
  input.type = input.type === 'password' ? 'text' : 'password';
}

function closeWifiConfig() {
  document.getElementById('wifi-config-overlay').classList.add('hidden');
}

function connectWifiNetwork() {
  if (!selectedWifiSSID) {
    showToast('请选择一个 WiFi 网络', 'warning');
    return;
  }
  const password = document.getElementById('wifi-password').value;
  if (selectedWifiSSID !== 'AI_NAILS_Guest' && !password) {
    showToast('请输入 WiFi 密码', 'warning');
    return;
  }

  const deviceId = document.getElementById('wifi-config-overlay').dataset.deviceId;
  const deviceName = document.getElementById('wifi-config-overlay').dataset.deviceName;
  const deviceIp = document.getElementById('wifi-config-overlay').dataset.deviceIp;

  // 显示连接中
  showToast(`正在为 ${deviceName} 配置 WiFi: ${selectedWifiSSID}...`, 'info');
  document.getElementById('wifi-config-overlay').classList.add('hidden');

  const statusEl = document.getElementById('wifi-status-text');
  statusEl.textContent = '正在连接...';
  statusEl.className = 'conn-card-status scanning';

  setTimeout(() => {
    wifiConnected = true;
    wifiDeviceName = deviceName;
    document.getElementById('wifi-connected-info').classList.remove('hidden');
    document.getElementById('wifi-dev-name').textContent = deviceName;
    document.getElementById('wifi-dev-meta').textContent = `IP: ${deviceIp} | SSID: ${selectedWifiSSID} | 已连接`;
    document.getElementById('wifi-scan-area').classList.add('hidden');
    document.getElementById('wifi-scan-btn').classList.add('hidden');
    document.getElementById('wifi-disconnect-btn').classList.remove('hidden');
    statusEl.textContent = '已连接';
    statusEl.className = 'conn-card-status connected';
    document.getElementById('wifi-toggle').checked = true;
    wifiEnabled = true;
    showToast(`WiFi 已连接: ${deviceName} → ${selectedWifiSSID}`, 'success');
  }, 1500);
}

function disconnectWifi() {
  const statusEl = document.getElementById('wifi-status-text');
  wifiConnected = false;
  wifiDeviceName = '';
  document.getElementById('wifi-connected-info').classList.add('hidden');
  document.getElementById('wifi-disconnect-btn').classList.add('hidden');
  document.getElementById('wifi-scan-btn').classList.remove('hidden');
  statusEl.textContent = 'WiFi 已开启 · 等待连接';
  statusEl.className = 'conn-card-status';
  showToast('WiFi 已断开连接', 'info');
}

// ========== 快速连接 ==========
function quickConnectDevice(sn, name) {
  // 根据设备SN判断连接方式
  if (sn === 'ANP-2026-0001') {
    // 双模设备 - 同时连接蓝牙和WiFi
    if (!bluetoothEnabled) {
      document.getElementById('bt-toggle').checked = true;
      toggleBluetooth(true);
    }
    if (!wifiEnabled) {
      document.getElementById('wifi-toggle').checked = true;
      toggleWifi(true);
    }
    setTimeout(() => {
      connectBluetooth('ANP-BT-001', name);
    }, 600);
    setTimeout(() => {
      openWifiConfigForDevice('ANP-WF-001', name, '192.168.1.100');
    }, 800);
  } else if (sn === 'ANP-2026-0002') {
    // 仅蓝牙设备
    if (!bluetoothEnabled) {
      document.getElementById('bt-toggle').checked = true;
      toggleBluetooth(true);
    }
    setTimeout(() => {
      connectBluetooth('ANP-BT-002', name);
    }, 600);
  } else if (sn === 'ANP-2026-0003') {
    // 仅WiFi设备
    if (!wifiEnabled) {
      document.getElementById('wifi-toggle').checked = true;
      toggleWifi(true);
    }
    setTimeout(() => {
      openWifiConfigForDevice('ANP-WF-003', name, '192.168.1.103');
    }, 600);
  }
  showToast(`正在连接 ${name}...`, 'info');
}

// ========== Toast 提示 ==========
function showToast(msg, type) {
  let toast = document.getElementById('global-toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'global-toast';
    toast.style.cssText = 'position:fixed;top:60px;left:50%;transform:translateX(-50%);z-index:9999;padding:10px 20px;border-radius:8px;font-size:13px;font-weight:600;transition:all 0.3s;pointer-events:none;opacity:0;';
    document.body.appendChild(toast);
  }
  const colors = { success: 'var(--success)', warning: 'var(--warning)', error: 'var(--danger)', info: 'var(--accent)' };
  toast.style.background = 'var(--bg-elevated)';
  toast.style.border = `1px solid ${colors[type] || colors.info}`;
  toast.style.color = 'var(--text-primary)';
  toast.textContent = msg;
  toast.style.opacity = '1';
  toast.style.transform = 'translateX(-50%) translateY(0)';
  clearTimeout(toast._timeout);
  toast._timeout = setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(-50%) translateY(-10px)';
  }, 2500);
}

// PAYMENT
function switchPayScene(scene){payScene=scene;document.querySelectorAll('#page-payment .auth-tab').forEach((el,i)=>{el.classList.toggle('active',['recharge','subscribe','device'][i]===scene)});document.getElementById('pay-scene-recharge').classList.toggle('hidden',scene!=='recharge');document.getElementById('pay-scene-subscribe').classList.toggle('hidden',scene!=='subscribe');document.getElementById('pay-scene-device').classList.toggle('hidden',scene!=='device');const t={recharge:'账户充值',subscribe:'套餐订阅',device:'设备购买'};document.getElementById('payment-title').textContent=t[scene];if(scene==='device')selectedAmount=29900;else if(scene==='subscribe')selectedAmount=299;else selectedAmount=1000;updatePaymentSummary()}
function selectAmount(amt,btn){selectedAmount=amt;document.querySelectorAll('#pay-scene-recharge .amount-btn').forEach(el=>el.classList.remove('selected'));if(btn)btn.classList.add('selected');updatePaymentSummary()}
function selectSub(tier,btn){selectedSubTier=tier;document.querySelectorAll('#pay-scene-subscribe .sub-card').forEach(el=>el.classList.remove('selected'));if(btn)btn.classList.add('selected');const p={basic:99,pro:299,business:999,enterprise:0};selectedAmount=p[tier];updatePaymentSummary()}
function selectCurrency(cur,el){selectedCurrency=cur;document.querySelectorAll('#currency-select .currency-chip').forEach(c=>c.classList.remove('selected'));if(el)el.classList.add('selected');const m=document.getElementById('payment-methods');m.querySelectorAll('.payment-method').forEach(pm=>{const method=pm.dataset.method;if(cur==='USDT'||cur==='BTC'){pm.style.display=method==='crypto'?'flex':'none';if(method==='crypto')selectPayment('crypto',pm)}else if(cur==='USD'||cur==='EUR'){pm.style.display=['stripe','paypal','crypto'].includes(method)?'flex':'none';if(method==='stripe')selectPayment('stripe',pm)}else{pm.style.display='flex'}});updatePaymentSummary()}
function selectPayment(method,el){selectedPayment=method;document.querySelectorAll('#payment-methods .payment-method').forEach(m=>m.classList.remove('selected'));if(el)el.classList.add('selected');updatePaymentSummary()}
function updatePaymentSummary(){const sym={CNY:'¥',USD:'$',EUR:'€',USDT:'₮',BTC:'₿'};const s=sym[selectedCurrency]||'¥';const mn={wechat:'微信支付',alipay:'支付宝',stripe:'Visa/Mastercard',paypal:'PayPal',crypto:'数字货币',bank:'对公转账'};let item='账户充值';if(payScene==='subscribe'){const tn={basic:'基础版订阅',pro:'专业版订阅',business:'商业版订阅',enterprise:'企业版订阅'};item=tn[selectedSubTier]||'套餐订阅'}else if(payScene==='device')item='AI NAILS 智能美甲打印机';document.getElementById('summary-item').textContent=item;document.getElementById('summary-amount').textContent=s+selectedAmount.toLocaleString();document.getElementById('summary-method').textContent=mn[selectedPayment]||'微信支付';document.getElementById('summary-total').textContent=s+selectedAmount.toLocaleString()}
function customAmount(){const a=prompt('输入自定义金额 (¥):','200');if(a&&!isNaN(a)&&Number(a)>0){selectedAmount=Number(a);document.querySelectorAll('#pay-scene-recharge .amount-btn').forEach(el=>el.classList.remove('selected'));updatePaymentSummary()}}
function handlePay(){const p=document.getElementById('processing-modal');p.classList.remove('hidden');setTimeout(()=>{p.classList.add('hidden');if(selectedPayment==='wechat'||selectedPayment==='alipay'){document.getElementById('qr-method-name').textContent=selectedPayment==='wechat'?'微信':'支付宝';const s={CNY:'¥',USD:'$',EUR:'€'}[selectedCurrency]||'¥';document.getElementById('qr-amount').textContent=s+selectedAmount.toLocaleString();document.getElementById('qr-modal').classList.remove('hidden');setTimeout(()=>{document.getElementById('qr-modal').classList.add('hidden');showPaymentSuccess()},3000)}else if(selectedPayment==='crypto'){showToast('钱包地址: 0xAI_Nails_7F3a...9B2c（已复制）','info');setTimeout(()=>showPaymentSuccess(),2000)}else if(selectedPayment==='bank'){showToast('银行信息已复制','info');setTimeout(()=>showPaymentSuccess(),2000)}else setTimeout(()=>showPaymentSuccess(),1500)},2000)}
function showPaymentSuccess(){const s={CNY:'¥',USD:'$',EUR:'€'}[selectedCurrency]||'¥';document.getElementById('success-msg').textContent='已成功支付 '+s+selectedAmount.toLocaleString();document.getElementById('success-modal').classList.remove('hidden')}
function closeSuccessModal(){document.getElementById('success-modal').classList.add('hidden');showToast('支付完成！','success')}
function closeQrModal(){document.getElementById('qr-modal').classList.add('hidden');showToast('支付已取消','error')}

// COMMUNITY
function switchCommunityTab(tab){document.querySelectorAll('#page-community .page-tab').forEach((el,i)=>{el.classList.toggle('active',['feed','market','leaderboard'][i]===tab)});document.getElementById('comm-feed').classList.toggle('hidden',tab!=='feed');document.getElementById('comm-market').classList.toggle('hidden',tab!=='market');document.getElementById('comm-leaderboard').classList.toggle('hidden',tab!=='leaderboard')}

// AGENTS
function switchAgentTab(tab){document.querySelectorAll('#page-agents .page-tab').forEach((el,i)=>{el.classList.toggle('active',['installed','hub','custom','chat'][i]===tab)});document.getElementById('agent-installed').classList.toggle('hidden',tab!=='installed');document.getElementById('agent-hub').classList.toggle('hidden',tab!=='hub');document.getElementById('agent-custom').classList.toggle('hidden',tab!=='custom');document.getElementById('agent-chat').classList.toggle('hidden',tab!=='chat');if(tab==='hub'&&typeof renderSkillHub==='function')renderSkillHub();if(tab==='installed'&&typeof renderInstalledSkills==='function')renderInstalledSkills()}

function installSkillFromHub(name){
  showToast(`正在从 ClawSkill Hub 安装 "${name}"...`,'info');
  setTimeout(()=>{
    const grid=document.getElementById('installed-skills-grid');
    const card=document.createElement('div');
    card.className='skill-card';
    card.innerHTML=`<div class="skill-header"><span class="skill-icon">📦</span><div><div class="skill-name">${name}</div><div class="skill-version">v1.0.0 · 新安装</div></div></div><div class="skill-desc">从 ClawSkill Hub 官方市场安装</div><div class="skill-tags"><span class="tag tag-gold">Hub</span><span class="tag tag-success">已安装</span></div><div class="skill-actions"><button class="btn btn-xs btn-secondary" onclick="showToast('Skill 配置已打开','info')">⚙</button><label class="toggle-switch"><input type="checkbox" checked><span class="toggle-slider"></span></label></div>`;
    grid.appendChild(card);
    showToast(`✅ "${name}" 安装成功！`,'success');
  },800)
}

function addCustomSkill(){
  const name=document.getElementById('custom-skill-name').value;
  const version=document.getElementById('custom-skill-version').value||'v1.0.0';
  const desc=document.getElementById('custom-skill-desc').value;
  const tags=document.getElementById('custom-skill-tags').value;
  if(!name||!desc){showToast('请填写 Skill 名称和描述','error');return}
  const grid=document.getElementById('installed-skills-grid');
  const card=document.createElement('div');
  card.className='skill-card';
  const tagHtml=tags?tags.split(',').map(t=>`<span class="tag tag-accent">${t.trim()}</span>`).join(''):'<span class="tag tag-accent">自定义</span>';
  card.innerHTML=`<div class="skill-header"><span class="skill-icon">🔧</span><div><div class="skill-name">${name}</div><div class="skill-version">${version}</div></div></div><div class="skill-desc">${desc}</div><div class="skill-tags">${tagHtml}<span class="tag" style="background:rgba(180,76,255,0.12);color:var(--accent2)">自定义</span></div><div class="skill-actions"><button class="btn btn-xs btn-danger" onclick="this.closest('.skill-card').remove();showToast('Skill 已移除','info')">🗑</button><label class="toggle-switch"><input type="checkbox" checked><span class="toggle-slider"></span></label></div>`;
  grid.appendChild(card);
  document.getElementById('custom-skill-name').value='';document.getElementById('custom-skill-version').value='';document.getElementById('custom-skill-desc').value='';document.getElementById('custom-skill-tags').value='';document.getElementById('custom-skill-prompt').value='';document.getElementById('custom-skill-triggers').value='';
  showToast(`✅ Skill "${name}" 已添加！`,'success');
}

function sendSkillChat(){
  const input=document.getElementById('skill-chat-input');
  const msg=input.value.trim();
  if(!msg)return;
  const msgs=document.getElementById('skill-chat-msgs');
  msgs.innerHTML+=`<div class="chat-msg user"><div class="msg-avatar user-av">👤</div><div class="msg-bubble">${msg}</div></div>`;
  input.value='';
  msgs.scrollTop=msgs.scrollHeight;
  setTimeout(()=>{
    msgs.innerHTML+=`<div class="chat-msg agent"><div class="msg-avatar agent-av">🧠</div><div class="msg-bubble">已理解你的需求。我为你创建了以下 Skill 配置：<br><br><b>名称：</b>${msg.slice(0,30)}...<br><b>触发词：</b>自动识别<br><b>配置：</b>已生成 SKILL.md 模板<br><br>点击下方按钮安装 👇<br><button class="btn btn-xs btn-primary" onclick="installSkillFromHub('${msg.slice(0,20)}')" style="margin-top:8px">📥 安装此 Skill</button></div></div>`;
    msgs.scrollTop=msgs.scrollHeight;
  },1000)
}

// AI PROVIDERS
function setDefaultProvider(provider){
  defaultProvider=provider;
  const names={openai:'OpenAI',anthropic:'Anthropic',google:'Google Gemini',deepseek:'DeepSeek',qwen:'通义千问',custom:'自定义端点',nanobanana:'Nano Banana Pro',ollama:'Ollama 本地模型'};
  document.getElementById('default-provider-name').textContent=names[provider]||provider;
  document.getElementById('status-provider').textContent=provider==='openai'?'GPT-4o':provider==='anthropic'?'Claude':provider==='google'?'Gemini':provider==='deepseek'?'DeepSeek':provider==='qwen'?'Qwen':provider==='nanobanana'?'Nano Banana':provider==='ollama'?'Ollama':'Custom';
  document.querySelectorAll('.provider-card').forEach(c=>c.classList.remove('active-provider'));
  const card=document.getElementById('provider-'+provider);
  if(card)card.classList.add('active-provider');
  if(provider==='nanobanana' && !NanoBananaService.isConfigured()){
    setTimeout(()=>openNanoBananaSettings(),500);
  }
  showToast(`默认提供商已切换至 ${names[provider]}`,'success');
}

// Nano Banana Pro 配置管理
function openNanoBananaSettings(){
  document.getElementById('nanobanana-modal').classList.remove('hidden');
  const key = NanoBananaService.getApiKey();
  if(key) document.getElementById('nanobanana-api-key').value = key;
  updateNanoBananaUI();
}
function closeNanoBananaSettings(){document.getElementById('nanobanana-modal').classList.add('hidden')}
function saveNanoBananaSettings(){
  const key = document.getElementById('nanobanana-api-key').value.trim();
  if(!key){showToast('请输入 API Key','error');return}
  NanoBananaService.setApiKey(key);
  localStorage.setItem('nanobanana_resolution', nanobananaResolution);
  localStorage.setItem('nanobanana_ratio', nanobananaRatio);
  closeNanoBananaSettings();
  updateNanoBananaUI();
  showToast('✅ Nano Banana Pro 配置已保存！','success');
}
function selectNanoBananaRes(res, btn){
  nanobananaResolution = res;
  document.querySelectorAll('.nanobanana-res-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function selectNanoBananaRatio(ratio, btn){
  nanobananaRatio = ratio;
  document.querySelectorAll('.nanobanana-ratio-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function updateNanoBananaUI(){
  const status = document.getElementById('nanobanana-status');
  const statusText = document.getElementById('nanobanana-status-text');
  if(NanoBananaService.isConfigured()){
    status.className = 'status-dot status-online';
    statusText.textContent = '已配置 · Gemini 3 Pro Image';
  } else {
    status.className = 'status-dot status-idle';
    statusText.textContent = '未配置API Key · 点击设置';
  }
}
async function testNanoBananaConnection(){
  if(!NanoBananaService.isConfigured()){
    showToast('⚠️ 请先配置 API Key','error');
    openNanoBananaSettings();
    return;
  }
  showToast('🔌 正在测试 Nano Banana Pro 连接...','info');
  try {
    const images = await NanoBananaService.generateImage('A simple test image: a tiny cute pink heart icon on white background, minimal', {aspectRatio:'1:1',imageSize:'1K'});
    if(images.length>0){showToast('✅ Nano Banana Pro 连接成功！API 正常响应','success');updateNanoBananaUI();}
  } catch(err){
    let msg='连接失败';
    if(err.message==='API_KEY_INVALID') msg='API Key 无效';
    else if(err.message==='API_RATE_LIMIT') msg='API 频率限制';
    showToast('❌ '+msg,'error');
  }
}

// OpenClaw
function openOpenClawConsole(){
  window.open('http://127.0.0.1:18789/chat?session=main','_blank');
  showToast('🚀 正在打开 OpenClaw 控制台...','success');
}
function openOpenClawSession(session){
  window.open(`http://127.0.0.1:18789/chat?session=${session}`,'_blank');
  showToast(`正在打开 ${session} 会话...`,'info');
}

// CREATE - AI generation (真实 Nano Banana Pro API)
let nanobananaResolution = localStorage.getItem('nanobanana_resolution') || '2K';
let nanobananaRatio = localStorage.getItem('nanobanana_ratio') || '1:1';

async function generateNailArt(){
  const prompt=document.getElementById('create-prompt').value;
  if(!prompt){showToast('请先描述你想要的甲面设计','error');return}
  // 清除上次的Canvas缓存
  window._lastCanvasImages = [];
  window._lastGeneratedImages = null;
  const resultGrid=document.getElementById('result-grid');
  resultGrid.style.display='grid';
  const loadingHTML = '<div class="result-item"><div class="loading-spinner"><div class="spinner"></div></div></div>';
  resultGrid.innerHTML = loadingHTML.repeat(4);
  const preview=document.getElementById('prompt-preview-card');
  preview.style.display='block';

  // ====== Ollama 本地优化提示词 ======
  let ollamaAvailable = false;
  let enhancedPrompt = prompt;
  
  try {
    ollamaAvailable = await OllamaService.checkAvailability();
  } catch(e) { ollamaAvailable = false; }

  if (ollamaAvailable) {
    showToast('🦙 Ollama 本地模型正在优化提示词...','info');
    document.getElementById('optimized-prompt').textContent = `"${prompt}" — 🦙 Ollama 优化中...`;
    document.getElementById('prompt-tags').innerHTML='<span class="tag tag-accent">🦙 Ollama 本地</span><span class="tag tag-info">优化中...</span>';
    
    try {
      const variantPrompts = await OllamaService.generateVariantPrompts(prompt, 4);
      enhancedPrompt = variantPrompts[0];
      
      // 显示优化后的提示词
      document.getElementById('optimized-prompt').textContent = `"${prompt}" → 🦙 Ollama 优化: "${enhancedPrompt.substring(0, 80)}..."`;
      document.getElementById('prompt-tags').innerHTML = 
        '<span class="tag tag-accent">🦙 Ollama 优化</span>' +
        '<span class="tag tag-success">提示词已增强</span>' +
        '<span class="tag tag-accent2">' + OllamaService.model + '</span>';
      
      // 显示变体提示词
      console.log('[Ollama] 生成了 ' + variantPrompts.length + ' 个变体提示词:');
      variantPrompts.forEach((p, i) => console.log(`  [${i+1}] ${p.substring(0, 80)}...`));
      
      showToast('✅ Ollama 提示词优化完成！','success');
    } catch(e) {
      console.warn('[Ollama] 优化失败，使用本地增强:', e.message);
      enhancedPrompt = OllamaService.localEnhance(prompt);
      document.getElementById('optimized-prompt').textContent = `"${prompt}" → 本地增强: "${enhancedPrompt}"`;
      document.getElementById('prompt-tags').innerHTML = 
        '<span class="tag tag-accent">📝 本地增强</span>' +
        '<span class="tag tag-warning">Ollama 不可用</span>';
    }
  } else {
    // Ollama 不可用，使用本地增强
    enhancedPrompt = OllamaService.localEnhance(prompt);
    document.getElementById('optimized-prompt').textContent = `"${prompt}" → 本地增强: "${enhancedPrompt}"`;
    document.getElementById('prompt-tags').innerHTML = 
      '<span class="tag tag-accent">📝 本地增强</span>' +
      '<span class="tag tag-warning">Ollama 未运行</span>';
  }

  // ====== 尝试 Nano Banana Pro 生图 ======
  if(defaultProvider==='nanobanana'){
    if(!NanoBananaService.isConfigured()){
      showToast('⚠️ 请先配置 Nano Banana Pro API Key（点击提供商页面的设置按钮）','error');
      // 回退到 Canvas 本地生成
      generateNailArtCanvas(enhancedPrompt);
      return;
    }
    showToast('🍌 Nano Banana Pro 正在生成... Gemini 图片引擎 · '+nanobananaResolution+'分辨率','info');
    try {
      const images = await NanoBananaService.generateVariants(enhancedPrompt, 4, {aspectRatio:nanobananaRatio,imageSize:nanobananaResolution});
      // 存储当前生成结果用于一键保存
      window._lastGeneratedImages = images;
      window._lastGeneratedPrompt = enhancedPrompt;
      window._lastGeneratedProvider = 'NanoBanana';
      resultGrid.innerHTML = images.map((img,i)=>`
        <div class="result-item" style="position:relative">
          <img src="data:${img.mimeType};base64,${img.base64}" alt="AI Nail Design ${i+1}" loading="lazy">
          <div class="download-overlay" onclick="downloadNailImage('${img.base64}','${img.mimeType}','nail-design-${i+1}')">⬇ 下载</div>
        </div>
      `).join('') + `
        <div class="result-item" style="background:linear-gradient(135deg,rgba(0,240,255,0.1),rgba(180,76,255,0.1));border:1px dashed var(--accent);cursor:pointer;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;font-size:11px;color:var(--accent)" onclick="saveAllGeneratedToLibrary(window._lastGeneratedImages, window._lastGeneratedPrompt, window._lastGeneratedProvider);showToast('✅ 已保存全部生成结果到资源库','success')">
          <span style="font-size:24px">💾</span>
          <span>一键保存</span>
          <span style="font-size:10px;opacity:0.7">全部到资源库</span>
        </div>`;
      showToast(`✅ 成功生成 ${images.length} 张美甲设计！`,'success');
      document.getElementById('prompt-tags').innerHTML='<span class="tag tag-accent">🍌 Nano Banana Pro</span><span class="tag tag-success">真实AI生图</span><span class="tag tag-accent2">'+images.length+'张</span>';
    } catch(err){
      console.error('[NanoBanana] 生图失败:', err);
      let errMsg='生图失败';
      let isNetworkError = false;
      if(err.message==='API_KEY_MISSING') errMsg='请先配置 API Key';
      else if(err.message==='API_KEY_INVALID') errMsg='API Key 无效，请检查';
      else if(err.message.includes('API_RATE_LIMIT')) errMsg='图片生成配额已用完，请稍后重试';
      else if(err.message.includes('fetch failed') || err.message.includes('NetworkError') || err.message.includes('Failed to fetch')) {
        errMsg='Gemini API 网络不可达（需科学上网），已切换到 Canvas 本地渲染';
        isNetworkError = true;
      }
      else if(err.message.startsWith('NO_IMAGE')) errMsg='提示词可能被安全过滤，请修改描述';
      showToast('❌ '+errMsg,'error');
      document.getElementById('prompt-tags').innerHTML='<span class="tag tag-accent">🍌 Nano Banana Pro</span><span class="tag tag-danger">生图失败</span>';
      // 回退到 Canvas 本地生成
      generateNailArtCanvas(enhancedPrompt, isNetworkError);
    }
  } else {
    // 非 nanobanana provider，使用 Canvas 本地生成
    generateNailArtCanvas(enhancedPrompt);
  }
}

/**
 * Canvas 本地渲染美甲图案（Gemini 不可用时的回退方案）
 * 根据 Ollama 优化后的英文提示词，提取颜色/风格关键词生成图案
 */
function generateNailArtCanvas(prompt, isNetworkError = false) {
  const resultGrid = document.getElementById('result-grid');
  const colorMap = {
    'pink': ['#FFB6C1', '#FF69B4', '#FF1493', '#DB7093'],
    'red': ['#FF6B6B', '#DC143C', '#CD5C5C', '#B22222'],
    'blue': ['#87CEEB', '#4169E1', '#1E90FF', '#000080'],
    'purple': ['#DDA0DD', '#9370DB', '#8A2BE2', '#4B0082'],
    'green': ['#90EE90', '#3CB371', '#2E8B57', '#006400'],
    'gold': ['#FFD700', '#DAA520', '#B8860B', '#8B6914'],
    'black': ['#555', '#333', '#1a1a2e', '#000'],
    'white': ['#FFF', '#F5F5F5', '#E8E8E8', '#DCDCDC'],
    'orange': ['#FFB347', '#FF8C00', '#FF6600', '#E65100'],
    'silver': ['#E8E8E8', '#C0C0C0', '#A9A9A9', '#808080'],
    'cyan': ['#00FFFF', '#00CED1', '#008B8B', '#006666'],
    'yellow': ['#FFFACD', '#FFD700', '#FFA500', '#FF8C00'],
  };

  const styleKeywords = {
    'gradient': true, 'ombre': true, 'glitter': true, 'metallic': true,
    'matte': true, 'glossy': true, 'holographic': true, 'neon': true,
    'pastel': true, 'dark': true, 'floral': true, 'geometric': true,
    'marble': true, 'chrome': true, 'pearl': true, 'crystal': true,
  };

  // 从提示词中提取颜色
  const promptLower = prompt.toLowerCase();
  let colors = ['#FFB6C1', '#DDA0DD', '#87CEEB', '#FFD700']; // 默认柔和色
  for (const [colorName, palette] of Object.entries(colorMap)) {
    if (promptLower.includes(colorName)) {
      colors = palette;
      break;
    }
  }

  // 检测风格特征
  const hasGradient = styleKeywords.gradient && promptLower.includes('gradient');
  const hasGlitter = styleKeywords.glitter && (promptLower.includes('glitter') || promptLower.includes('sparkle'));
  const hasMetallic = styleKeywords.metallic && promptLower.includes('metallic');
  const isDark = promptLower.includes('dark') || promptLower.includes('black');
  const isPastel = promptLower.includes('pastel');

  const bgColor = isDark ? '#1a1a2e' : '#faf8f5';

  resultGrid.innerHTML = '';
  resultGrid.style.display = 'grid';

  for (let i = 0; i < 4; i++) {
    const canvas = document.createElement('canvas');
    canvas.width = 400;
    canvas.height = 400;
    const ctx = canvas.getContext('2d');

    // 背景
    ctx.fillStyle = bgColor;
    ctx.fillRect(0, 0, 400, 400);

    // 绘制5个指甲形状
    const nailPositions = [
      { x: 60, y: 180, w: 55, h: 120 },
      { x: 130, y: 140, w: 55, h: 130 },
      { x: 200, y: 120, w: 55, h: 140 },
      { x: 270, y: 140, w: 55, h: 130 },
      { x: 340, y: 180, w: 55, h: 120 },
    ];

    nailPositions.forEach((pos, idx) => {
      const nailColor = colors[(i + idx) % colors.length];
      
      ctx.save();
      ctx.beginPath();
      const cx = pos.x + pos.w / 2;
      const cy = pos.y + pos.h / 2;
      // 指甲形状
      const rx = pos.w / 2;
      const ry = pos.h / 2;
      ctx.ellipse(cx, cy, rx, ry, 0, Math.PI, 0);
      ctx.closePath();

      if (hasGradient) {
        const grad = ctx.createLinearGradient(pos.x, pos.y, pos.x, pos.y + pos.h);
        grad.addColorStop(0, colors[(idx) % colors.length]);
        grad.addColorStop(0.5, colors[(idx + 1) % colors.length]);
        grad.addColorStop(1, colors[(idx + 2) % colors.length]);
        ctx.fillStyle = grad;
      } else {
        ctx.fillStyle = nailColor;
      }
      ctx.fill();

      // 光泽高光
      const highlightGrad = ctx.createLinearGradient(pos.x, pos.y, pos.x + pos.w / 3, pos.y);
      highlightGrad.addColorStop(0, 'rgba(255,255,255,0.35)');
      highlightGrad.addColorStop(1, 'rgba(255,255,255,0)');
      ctx.fillStyle = highlightGrad;
      ctx.fill();

      // 闪光点
      if (hasGlitter) {
        for (let g = 0; g < 8; g++) {
          const gx = pos.x + Math.random() * pos.w;
          const gy = pos.y + Math.random() * pos.h;
          ctx.beginPath();
          ctx.arc(gx, gy, 1.5, 0, Math.PI * 2);
          ctx.fillStyle = 'rgba(255,255,255,0.8)';
          ctx.fill();
        }
      }

      // 金属质感线条
      if (hasMetallic) {
        ctx.beginPath();
        ctx.moveTo(pos.x + 5, pos.y + pos.h * 0.3);
        ctx.lineTo(pos.x + pos.w - 5, pos.y + pos.h * 0.3);
        ctx.strokeStyle = 'rgba(255,255,255,0.4)';
        ctx.lineWidth = 1;
        ctx.stroke();
      }

      ctx.restore();

      // 指甲轮廓
      ctx.beginPath();
      ctx.ellipse(cx, cy, rx, ry, 0, Math.PI, 0);
      ctx.closePath();
      ctx.strokeStyle = 'rgba(0,0,0,0.15)';
      ctx.lineWidth = 1.5;
      ctx.stroke();
    });

    const dataUrl = canvas.toDataURL('image/png');
    const variantLabel = ['主设计', '变体 A', '变体 B', '变体 C'][i];
    
    resultGrid.innerHTML += `
      <div class="result-item" style="position:relative">
        <img src="${dataUrl}" alt="Canvas Nail Design ${i+1}" loading="lazy">
        <div class="download-overlay" onclick="downloadCanvasImage('result-item-canvas-${i}')">⬇ 下载</div>
      </div>
    `;
    canvas.id = 'result-item-canvas-' + i;
    canvas.style.display = 'none';
    document.getElementById('result-grid').appendChild(canvas);
    
    // 收集Canvas生成的dataUrl用于一键保存
    if (!window._lastCanvasImages) window._lastCanvasImages = [];
    window._lastCanvasImages.push({ base64: dataUrl.split(',')[1], mimeType: 'image/png' });
  }
  
  // 添加"一键保存到资源库"按钮
  window._lastGeneratedPrompt = prompt;
  window._lastGeneratedProvider = 'Canvas';
  resultGrid.innerHTML += `
    <div class="result-item" style="background:linear-gradient(135deg,rgba(0,240,255,0.1),rgba(180,76,255,0.1));border:1px dashed var(--accent);cursor:pointer;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;font-size:11px;color:var(--accent)" onclick="if(window._lastCanvasImages){saveAllGeneratedToLibrary(window._lastCanvasImages, window._lastGeneratedPrompt, window._lastGeneratedProvider);showToast('✅ 已保存全部Canvas渲染结果到资源库','success')}">
      <span style="font-size:24px">💾</span>
      <span>一键保存</span>
      <span style="font-size:10px;opacity:0.7">全部到资源库</span>
    </div>`;

  const engineLabel = isNetworkError ? 'Canvas 本地渲染（网络受限）' : 'Canvas 本地渲染';
  document.getElementById('prompt-tags').innerHTML = 
    '<span class="tag tag-accent">🎨 ' + engineLabel + '</span>' +
    '<span class="tag tag-success">Ollama 提示词优化</span>' +
    '<span class="tag tag-accent2">4张变体</span>';
  showToast('🎨 Canvas 本地渲染完成！基于 Ollama 优化的提示词','success');
}

function downloadCanvasImage(canvasId) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const link = document.createElement('a');
  link.href = canvas.toDataURL('image/png');
  link.download = 'nail-design.png';
  link.click();
  showToast('📥 图片已下载','success');
}

function downloadNailImage(base64, mimeType, filename) {
  const ext = mimeType.split('/')[1] || 'png';
  const link = document.createElement('a');
  link.href = `data:${mimeType};base64,${base64}`;
  link.download = `${filename}.${ext}`;
  link.click();
  showToast('📥 图片已下载','success');
}

// ====== 语音输入 (Web Speech API + ElevenLabs) ======
let voiceRecognition = null;
let isVoiceListening = false;

function startVoiceInput() {
  const btn = document.querySelector('[onclick="startVoiceInput()"]');
  
  if (isVoiceListening) {
    stopVoiceInput();
    return;
  }
  
  // 检查 Web Speech API 支持
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (SpeechRecognition) {
    voiceRecognition = new SpeechRecognition();
    voiceRecognition.lang = 'zh-CN';
    voiceRecognition.interimResults = true;
    voiceRecognition.continuous = false;
    voiceRecognition.maxAlternatives = 1;
    
    voiceRecognition.onstart = () => {
      isVoiceListening = true;
      if (btn) { btn.textContent = '🔴 录音中...'; btn.style.background = 'rgba(255,82,82,0.2)'; btn.style.color = 'var(--danger)'; }
      showToast('🎤 正在聆听...请说话','info');
    };
    
    voiceRecognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      const promptEl = document.getElementById('create-prompt');
      promptEl.value = transcript;
      // 实时更新
      const interim = Array.from(event.results).map(r => r[0].transcript).join('');
      if (event.results[0].isFinal) {
        promptEl.value = interim;
      }
    };
    
    voiceRecognition.onerror = (event) => {
      console.warn('[Voice] 语音识别错误:', event.error);
      stopVoiceInput();
      if (event.error === 'not-allowed') {
        showToast('⚠️ 请允许麦克风权限后重试','error');
      } else if (event.error === 'no-speech') {
        showToast('⚠️ 未检测到语音，请重试','warning');
      } else {
        showToast('⚠️ 语音识别失败: ' + event.error,'error');
      }
    };
    
    voiceRecognition.onend = () => {
      const promptEl = document.getElementById('create-prompt');
      if (promptEl.value) {
        showToast('✅ 语音识别完成！已填入输入框','success');
        // 自动发送到AI对话框
        setTimeout(() => {
          const chatInput = document.getElementById('create-chat-input');
          if (chatInput) {
            chatInput.value = promptEl.value;
            sendCreateChat();
          }
        }, 500);
      }
      resetVoiceButton();
    };
    
    voiceRecognition.start();
  } else {
    // 降级：使用模拟演示
    showToast('🎤 浏览器不支持语音识别，使用模拟模式...','info');
    setTimeout(() => {
      document.getElementById('create-prompt').value = '赛博朋克风格，深蓝色微光渐变，蝴蝶翅膀纹理，金属质感';
      showToast('✅ 语音识别完成（模拟）！','success');
      resetVoiceButton();
    }, 2000);
  }
}

function stopVoiceInput() {
  if (voiceRecognition) {
    try { voiceRecognition.stop(); } catch(e) {}
    voiceRecognition = null;
  }
  isVoiceListening = false;
  resetVoiceButton();
}

function resetVoiceButton() {
  isVoiceListening = false;
  voiceRecognition = null;
  const btn = document.querySelector('[onclick="startVoiceInput()"]');
  if (btn) { btn.textContent = '🎤 语音输入'; btn.style.background = ''; btn.style.color = ''; }
}

// ElevenLabs TTS（文本转语音朗读）
async function speakWithElevenLabs(text, voiceId) {
  const apiKey = localStorage.getItem('elevenlabs_api_key') || '7536957d31333c76024911ef47932af9382188547101ffcabf1e33a106e21525';
  if (!apiKey) {
    showToast('⚠️ 请先配置 ElevenLabs API Key','warning');
    return;
  }
  
  try {
    const resp = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId || '21m00Tcm4TlvDq8ikWAM'}`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey
      },
      body: JSON.stringify({
        text: text,
        model_id: 'eleven_multilingual_v2',
        voice_settings: { stability: 0.5, similarity_boost: 0.75 }
      })
    });
    
    if (!resp.ok) throw new Error('TTS API error: ' + resp.status);
    
    const blob = await resp.blob();
    const url = URL.createObjectURL(blob);
    const audio = new Audio(url);
    audio.play();
    showToast('🔊 正在朗读...','info');
  } catch(e) {
    console.warn('[ElevenLabs TTS] 失败:', e.message);
    showToast('⚠️ ElevenLabs 朗读失败: ' + e.message,'error');
  }
}

function triggerImageUpload(){document.getElementById('image-upload-input').click()}
function handleImageUpload(e){const file=e.target.files[0];if(file){const reader=new FileReader();reader.onload=function(ev){document.getElementById('upload-preview-img').src=ev.target.result;document.getElementById('upload-preview').style.display='block'};reader.readAsDataURL(file);showToast('图片已上传，AI 将以此作为参考','success')}}
function clearImageUpload(){document.getElementById('upload-preview').style.display='none';document.getElementById('image-upload-input').value=''}

function showStylePicker(){document.getElementById('style-modal').classList.remove('hidden')}
function closeStyleModal(){document.getElementById('style-modal').classList.add('hidden')}
function selectStyle(style){document.getElementById('create-prompt').value=style+'风格美甲设计';closeStyleModal();showToast(`已选择风格: ${style}`,'success')}

// ====== 提示词模板 ======
const promptTemplates = [
  { name: '赛博朋克', prompt: '赛博朋克风格，深蓝色微光渐变，霓虹灯效，蝴蝶翅膀纹理，金属质感，全息投影效果' },
  { name: '花卉春意', prompt: '春日花卉风格，粉色樱花花瓣，柔和渐变底色，金箔点缀，3D立体花朵，浪漫温柔' },
  { name: '极简几何', prompt: '极简几何风格，黑白对比色，线条感设计，哑光质感，现代简约，法式优雅' },
  { name: '星空银河', prompt: '星空银河风格，深紫到蓝渐变，星空闪粉，月亮星星点缀，珠光质感，梦幻璀璨' },
  { name: '海洋之心', prompt: '海洋主题，蓝绿渐变，贝壳纹理，珍珠镶嵌，波光粼粼效果，人鱼姬光泽' },
  { name: '暗黑哥特', prompt: '暗黑哥特风格，黑色为主调，暗红点缀，蕾丝纹理，银色金属装饰，神秘高贵' },
  { name: '糖果马卡龙', prompt: '糖果马卡龙风格，粉嫩多彩配色，磨砂质感，可爱圆点，果冻透明感，甜美少女' },
  { name: '大理石纹', prompt: '大理石纹理风格，白色底配金色纹理，高级感，哑光封层，天然石材质感' },
  { name: '新年喜庆', prompt: '新年喜庆风格，中国红为主，金色福字，烟花图案，亮片闪粉，节日氛围' },
  { name: '樱花和风', prompt: '和风樱花风格，淡粉底色，金箔樱花图案，日式庭院元素，珠光质感，典雅温婉' },
  { name: '渐变落日', prompt: '落日渐变风格，橙红到紫渐变，夕阳余晖色调，金色微光，温暖浪漫' },
  { name: '水晶钻石', prompt: '水晶钻石风格，透明底加钻石切面效果，闪耀光泽，3D水钻镶嵌，奢华高级' }
];

function showPromptTemplates() {
  const modal = document.getElementById('prompt-template-modal');
  if (modal) modal.classList.remove('hidden');
  renderPromptTemplates();
}

function closePromptTemplates() {
  const modal = document.getElementById('prompt-template-modal');
  if (modal) modal.classList.add('hidden');
}

function renderPromptTemplates() {
  const grid = document.getElementById('prompt-template-grid');
  if (!grid) return;
  grid.innerHTML = promptTemplates.map(t => `
    <div class="prompt-tmpl-card" onclick="usePromptTemplate('${escHtml(t.prompt)}')" title="${escHtml(t.name)}">
      <div class="prompt-tmpl-name">${escHtml(t.name)}</div>
      <div class="prompt-tmpl-preview">${escHtml(t.prompt.substring(0, 40))}...</div>
    </div>
  `).join('');
}

function usePromptTemplate(prompt) {
  document.getElementById('create-prompt').value = prompt;
  closePromptTemplates();
  showToast('✅ 已应用提示词模板','success');
  // 自动发送到AI对话框
  const chatInput = document.getElementById('create-chat-input');
  if (chatInput) {
    chatInput.value = prompt;
    sendCreateChat();
  }
}

function sendCreateChat(){
  const input=document.getElementById('create-chat-input');
  const msg=input.value.trim();
  if(!msg)return;
  const msgs=document.getElementById('create-chat-msgs');
  msgs.innerHTML+=`<div class="chat-msg user"><div class="msg-avatar user-av">👤</div><div class="msg-bubble">${escHtml(msg)}</div></div>`;
  input.value='';msgs.scrollTop=msgs.scrollHeight;
  
  // 智能风格识别
  let detectedStyle = '自定义';
  const styleChecks = [
    { keys: ['赛博','cyber','霓虹','金属'], style: '赛博朋克' },
    { keys: ['花','樱花','floral','bloom'], style: '花卉' },
    { keys: ['简约','极简','几何','法式'], style: '极简' },
    { keys: ['星空','银河','star','space'], style: '星空银河' },
    { keys: ['海洋','海','ocean','sea'], style: '海洋' },
    { keys: ['暗黑','哥特','黑色','goth'], style: '暗黑哥特' },
    { keys: ['糖果','马卡龙','粉色','可爱'], style: '糖果马卡龙' },
    { keys: ['大理石','marble','stone'], style: '大理石纹' },
    { keys: ['新年','春节','红色','福'], style: '新年喜庆' },
    { keys: ['渐变','落日','黄昏','日落'], style: '渐变落日' },
    { keys: ['水晶','钻石','diamond','水钻'], style: '水晶钻石' },
  ];
  for (const sc of styleChecks) {
    if (sc.keys.some(k => msg.includes(k))) { detectedStyle = sc.style; break; }
  }
  
  setTimeout(()=>{
    document.getElementById('create-prompt').value=msg;
    msgs.innerHTML+=`<div class="chat-msg agent"><div class="msg-avatar agent-av">🤖</div><div class="msg-bubble">已理解！为你优化提示词并准备生成...<br>风格识别: ${detectedStyle} · 甲型: 通用适配<br>
    <button class="btn btn-xs btn-primary" style="margin-top:8px;margin-right:4px" onclick="generateNailArt()">✨ 立即生成</button>
    <button class="btn btn-xs btn-accent" style="margin-top:8px" onclick="speakWithElevenLabs('${escHtml(msg.replace(/'/g,"\\'"))}')">🔊 朗读</button>
    </div></div>`;
    msgs.scrollTop=msgs.scrollHeight;
  },800)
}

// MODALS
function showForgotModal(){document.getElementById('forgot-modal').classList.remove('hidden')}
function closeForgotModal(){document.getElementById('forgot-modal').classList.add('hidden')}
function handleForgotPassword(){const e=document.getElementById('forgot-email').value;if(!e){showToast('请输入邮箱地址','error');return}showToast('重置链接已发送至您的邮箱','success');closeForgotModal()}

// COMMAND PALETTE
const commands=[
  {section:'导航',name:'创作舱',shortcut:'⌘1',action:()=>navigateTo('create')},
  {section:'导航',name:'资源库',shortcut:'⌘2',action:()=>navigateTo('medialibrary')},
  {section:'导航',name:'龙虾智控',shortcut:'⌘3',action:()=>navigateTo('device')},
  {section:'导航',name:'社区',shortcut:'⌘4',action:()=>navigateTo('community')},
  {section:'导航',name:'支付中心',shortcut:'⌘5',action:()=>navigateTo('payment')},
  {section:'导航',name:'智能体集群',shortcut:'⌘6',action:()=>navigateTo('agents')},
  {section:'导航',name:'模型提供商',shortcut:'⌘7',action:()=>navigateTo('providers')},
  {section:'导航',name:'OpenClaw控制台',shortcut:'⌘8',action:()=>navigateTo('openclaw')},
  {section:'导航',name:'管理后台',shortcut:'⌘9',action:()=>navigateTo('admin')},
  {section:'导航',name:'设置',shortcut:'⌘,',action:()=>navigateTo('settings')},
  {section:'操作',name:'切换侧边栏',shortcut:'⌘\\',action:()=>toggleSidebar()},
  {section:'操作',name:'打开OpenClaw',shortcut:'',action:()=>openOpenClawConsole()},
  {section:'操作',name:'退出登录',shortcut:'⌘⇧Q',action:()=>handleLogout()},
];
function openCommandPalette(){document.getElementById('command-palette').classList.remove('hidden');document.getElementById('cmd-input').value='';document.getElementById('cmd-input').focus();cmdSelectedIdx=0;filterCommands()}
function closeCommandPalette(){document.getElementById('command-palette').classList.add('hidden')}
function filterCommands(){const q=document.getElementById('cmd-input').value.toLowerCase();const f=q?commands.filter(c=>c.name.toLowerCase().includes(q)||c.section.toLowerCase().includes(q)):commands;const l=document.getElementById('cmd-list');let h='',ls='';f.forEach((c,i)=>{if(c.section!==ls){h+=`<div class="cmd-section">${c.section}</div>`;ls=c.section}h+=`<div class="cmd-item${i===cmdSelectedIdx?' selected':''}" onclick="executeCommand(${i})"><span>${c.name}</span><span class="cmd-shortcut">${c.shortcut}</span></div>`});l.innerHTML=h}
function handleCmdKey(e){if(e.key==='Escape'){closeCommandPalette();return}if(e.key==='ArrowDown'){cmdSelectedIdx=Math.min(cmdSelectedIdx+1,document.querySelectorAll('#cmd-list .cmd-item').length-1);filterCommands();e.preventDefault()}if(e.key==='ArrowUp'){cmdSelectedIdx=Math.max(cmdSelectedIdx-1,0);filterCommands();e.preventDefault()}if(e.key==='Enter'){const items=document.querySelectorAll('#cmd-list .cmd-item');if(items[cmdSelectedIdx])items[cmdSelectedIdx].click()}}
function executeCommand(idx){const q=document.getElementById('cmd-input').value.toLowerCase();const f=q?commands.filter(c=>c.name.toLowerCase().includes(q)||c.section.toLowerCase().includes(q)):commands;if(f[idx]){closeCommandPalette();f[idx].action()}}

// ========== 媒体资源库系统 ==========
// 数据结构: {id, name, type('image'|'video'), source('ai-generated'|'uploaded'|'cloud'|'link'), url, thumbnailUrl, tags:[], createdAt, size, width, height, fromProvider}
let mediaLibrary = [];
let mediaFilterTab = 'all';
let mediaFilterTag = 'all';
let mediaPreviewIdx = -1;
let mediaUploadQueue = [];
let currentUploadTab = 'local';
let mlSearchQuery = '';

// 从 localStorage 加载
function loadMediaLibrary() {
  try {
    const saved = localStorage.getItem('ai_nails_media_library');
    if (saved) mediaLibrary = JSON.parse(saved);
  } catch(e) { mediaLibrary = []; }
}
function saveMediaLibrary() {
  try {
    localStorage.setItem('ai_nails_media_library', JSON.stringify(mediaLibrary));
  } catch(e) { console.warn('媒体库存储失败:', e); }
}

// 初始化
loadMediaLibrary();
renderMediaLibrary();

// 添加资源到媒体库
function addToMediaLibrary(item) {
  item.id = 'ml_' + Date.now() + '_' + Math.random().toString(36).substr(2,6);
  item.createdAt = item.createdAt || new Date().toISOString();
  item.tags = item.tags || [];
  mediaLibrary.unshift(item);
  saveMediaLibrary();
  renderMediaLibrary();
  showToast('✅ 已保存到媒体资源库','success');
}

// AI生成结果一键保存
function saveGeneratedToLibrary(imageData, prompt, provider) {
  const isVideo = imageData.mimeType && imageData.mimeType.startsWith('video/');
  const mimeType = imageData.mimeType || 'image/png';
  const item = {
    name: (prompt || 'AI生成').substring(0, 30) + (isVideo ? ' (视频)' : ''),
    type: isVideo ? 'video' : 'image',
    source: 'ai-generated',
    url: `data:${mimeType};base64,${imageData.base64}`,
    thumbnailUrl: isVideo ? null : `data:${mimeType};base64,${imageData.base64}`,
    tags: ['AI生成', provider || 'AI', '美甲设计'],
    size: Math.round(imageData.base64.length * 0.75),
    fromProvider: provider || 'AI'
  };
  addToMediaLibrary(item);
}

// 批量保存AI生成结果
function saveAllGeneratedToLibrary(images, prompt, provider) {
  if (!images || images.length === 0) return;
  images.forEach((img, i) => {
    const item = {
      name: (prompt || 'AI生成').substring(0, 25) + ` #${i+1}`,
      type: 'image',
      source: 'ai-generated',
      url: `data:${img.mimeType || 'image/png'};base64,${img.base64}`,
      thumbnailUrl: `data:${img.mimeType || 'image/png'};base64,${img.base64}`,
      tags: ['AI生成', provider || 'AI', '美甲设计'],
      size: Math.round((img.base64 || '').length * 0.75),
      fromProvider: provider || 'AI'
    };
    item.id = 'ml_' + Date.now() + '_' + i + '_' + Math.random().toString(36).substr(2,4);
    item.createdAt = new Date().toISOString();
    mediaLibrary.unshift(item);
  });
  saveMediaLibrary();
  renderMediaLibrary();
  showToast(`✅ 已保存 ${images.length} 张AI生成图片到资源库`,'success');
}

// 渲染媒体库
function renderMediaLibrary() {
  const grid = document.getElementById('ml-grid');
  if (!grid) return;
  
  // 筛选
  let filtered = mediaLibrary;
  if (mediaFilterTab !== 'all') {
    if (mediaFilterTab === 'ai-generated' || mediaFilterTab === 'uploaded' || mediaFilterTab === 'cloud') {
      filtered = filtered.filter(m => m.source === mediaFilterTab);
    } else {
      filtered = filtered.filter(m => m.type === mediaFilterTab);
    }
  }
  if (mediaFilterTag !== 'all') {
    filtered = filtered.filter(m => m.tags && m.tags.includes(mediaFilterTag));
  }
  if (mlSearchQuery) {
    const q = mlSearchQuery.toLowerCase();
    filtered = filtered.filter(m => m.name.toLowerCase().includes(q) || (m.tags && m.tags.some(t => t.toLowerCase().includes(q))));
  }
  
  // 更新计数
  updateMediaCounts();
  
  if (filtered.length === 0) {
    grid.innerHTML = `
      <div class="ml-empty" style="display:block;grid-column:1/-1">
        <div class="ml-empty-icon">📭</div>
        <p>资源库为空</p>
        <p style="font-size:11px">AI生成的图片/视频将自动保存到这里<br>也可以上传本地文件或识别在线链接</p>
      </div>`;
  } else {
    grid.innerHTML = filtered.map((m) => {
      const idx = mediaLibrary.indexOf(m);
      const thumb = m.thumbnailUrl || m.url;
      const isVideo = m.type === 'video';
      return `
        <div class="ml-item" onclick="openMediaPreview(${idx})" title="${escHtml(m.name)}">
          ${isVideo 
            ? `<video src="${m.url}" muted preload="metadata"></video><div class="ml-type-badge">🎬</div>`
            : `<img src="${thumb}" alt="${escHtml(m.name)}" loading="lazy" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
               <div class="ml-placeholder" style="display:none;position:absolute;inset:0;align-items:center;justify-content:center">🖼️</div>`
          }
          ${m.source === 'ai-generated' ? '<div class="ml-save-badge">AI</div>' : ''}
          <div class="ml-item-info">${escHtml(m.name.substring(0, 20))}</div>
          <button class="ml-item-menu" onclick="event.stopPropagation();showMediaContextMenu(event,'${m.id}')">⋯</button>
        </div>`;
    }).join('');
  }
  
  // 更新标签筛选器
  renderTagFilters();
}

function updateMediaCounts() {
  const total = mediaLibrary.length;
  const images = mediaLibrary.filter(m => m.type === 'image').length;
  const videos = mediaLibrary.filter(m => m.type === 'video').length;
  const aiGen = mediaLibrary.filter(m => m.source === 'ai-generated').length;
  const uploaded = mediaLibrary.filter(m => m.source === 'uploaded').length;
  const cloud = mediaLibrary.filter(m => m.source === 'cloud').length;
  
  document.getElementById('ml-total-count').textContent = total + ' 个资源';
  document.getElementById('ml-count-all').textContent = total;
  document.getElementById('ml-count-image').textContent = images;
  document.getElementById('ml-count-video').textContent = videos;
  document.getElementById('ml-count-ai').textContent = aiGen;
  document.getElementById('ml-count-uploaded').textContent = uploaded;
  document.getElementById('ml-count-cloud').textContent = cloud;
}

function renderTagFilters() {
  const allTags = new Set();
  mediaLibrary.forEach(m => {
    if (m.tags) m.tags.forEach(t => allTags.add(t));
  });
  const container = document.getElementById('ml-tag-filters');
  let html = '<span class="ml-filter-tag active" onclick="filterMediaTag(\'all\',this)">全部</span>';
  allTags.forEach(tag => {
    html += `<span class="ml-filter-tag" onclick="filterMediaTag('${escHtml(tag)}',this)">${escHtml(tag)}</span>`;
  });
  container.innerHTML = html;
}

// Tab筛选
function filterMediaTab(tab) {
  mediaFilterTab = tab;
  document.querySelectorAll('#ml-tabs .ml-tab').forEach(el => el.classList.remove('active'));
  const tabs = document.querySelectorAll('#ml-tabs .ml-tab');
  const tabMap = { 'all': 0, 'image': 1, 'video': 2, 'ai-generated': 3, 'uploaded': 4, 'cloud': 5 };
  if (tabs[tabMap[tab]]) tabs[tabMap[tab]].classList.add('active');
  renderMediaLibrary();
}

function filterMediaTag(tag, el) {
  mediaFilterTag = tag;
  document.querySelectorAll('#ml-tag-filters .ml-filter-tag').forEach(e => e.classList.remove('active'));
  if (el) el.classList.add('active');
  renderMediaLibrary();
}

function searchMedia() {
  mlSearchQuery = document.getElementById('ml-search').value;
  renderMediaLibrary();
}

// ====== 上传弹窗 ======
function openMediaUpload() {
  document.getElementById('ml-upload-overlay').classList.remove('hidden');
  mediaUploadQueue = [];
  currentUploadTab = 'local';
  switchUploadTab('local', document.querySelector('.ml-upload-tab'));
  updateUploadConfirmBtn();
}

function closeMediaUpload() {
  document.getElementById('ml-upload-overlay').classList.add('hidden');
  mediaUploadQueue = [];
  document.getElementById('ml-upload-preview-list').innerHTML = '';
  document.getElementById('ml-upload-file-input').value = '';
  document.getElementById('ml-url-input').value = '';
}

function switchUploadTab(tab, el) {
  currentUploadTab = tab;
  document.querySelectorAll('.ml-upload-tab').forEach(e => e.classList.remove('active'));
  if (el) el.classList.add('active');
  document.getElementById('ml-upload-drop-area').style.display = tab === 'local' ? 'flex' : 'none';
  document.getElementById('ml-url-area').style.display = tab === 'url' ? 'flex' : 'none';
  document.getElementById('ml-cloud-area').style.display = tab === 'cloud' ? 'block' : 'none';
}

// 本地上传
function handleLocalFileSelect(e) {
  const files = Array.from(e.target.files);
  processUploadFiles(files);
}

function handleUploadDrop(e) {
  e.preventDefault();
  e.target.classList.remove('drag-over');
  const files = Array.from(e.dataTransfer.files);
  processUploadFiles(files);
}

function processUploadFiles(files) {
  files.forEach(file => {
    if (file.size > 50 * 1024 * 1024) {
      showToast(`文件 ${file.name} 超过50MB限制`,'warning');
      return;
    }
    const isImage = file.type.startsWith('image/');
    const isVideo = file.type.startsWith('video/');
    if (!isImage && !isVideo) {
      showToast(`不支持的文件类型: ${file.name}`,'warning');
      return;
    }
    const reader = new FileReader();
    reader.onload = function(ev) {
      mediaUploadQueue.push({
        name: file.name,
        type: isVideo ? 'video' : 'image',
        source: 'uploaded',
        url: ev.target.result,
        thumbnailUrl: isVideo ? null : ev.target.result,
        tags: ['本地上传', isVideo ? '视频' : '图片'],
        size: file.size,
        file: file
      });
      renderUploadPreview();
      updateUploadConfirmBtn();
    };
    reader.readAsDataURL(file);
  });
}

function renderUploadPreview() {
  const container = document.getElementById('ml-upload-preview-list');
  container.innerHTML = mediaUploadQueue.map((item, i) => `
    <div class="ml-upload-preview-item">
      ${item.type === 'video' 
        ? '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;font-size:24px;background:var(--bg-tertiary)">🎬</div>'
        : `<img src="${item.url}" alt="${escHtml(item.name)}">`
      }
      <button class="remove-btn" onclick="removeUploadQueueItem(${i})">✕</button>
    </div>
  `).join('');
}

function removeUploadQueueItem(idx) {
  mediaUploadQueue.splice(idx, 1);
  renderUploadPreview();
  updateUploadConfirmBtn();
}

// URL链接上传
function previewUrlInput() {
  const val = document.getElementById('ml-url-input').value.trim();
  const preview = document.getElementById('ml-url-preview');
  if (!val) { preview.style.display = 'none'; return; }
  const url = val.split('\n')[0].trim();
  const isImage = /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i.test(url);
  const isVideo = /\.(mp4|webm|mov|avi)(\?.*)?$/i.test(url);
  if (isImage) {
    preview.style.display = 'flex';
    preview.innerHTML = `<img src="${url}" onerror="this.style.display='none'" alt=""><span>图片链接已识别 ✓</span>`;
  } else if (isVideo) {
    preview.style.display = 'flex';
    preview.innerHTML = `<span style="font-size:24px">🎬</span><span>视频链接已识别 ✓</span>`;
  } else {
    preview.style.display = 'flex';
    preview.innerHTML = `<span>⚠️ 无法识别文件类型，将作为通用链接保存</span>`;
  }
}

// 云端图库同步
async function syncCloudLibrary(provider) {
  const status = document.getElementById('ml-cloud-status');
  status.textContent = '⏳ 正在连接云端图库...';
  status.style.color = 'var(--accent)';
  
  // 模拟云端同步
  const mockCloudImages = {
    unsplash: [
      { name: 'Unsplash 灵感 #1', url: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400', tags: ['云端图库', 'Unsplash', '灵感'] },
      { name: 'Unsplash 灵感 #2', url: 'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=400', tags: ['云端图库', 'Unsplash', '设计'] },
      { name: 'Unsplash 灵感 #3', url: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400', tags: ['云端图库', 'Unsplash', '纹理'] },
    ],
    pexels: [
      { name: 'Pexels 素材 #1', url: 'https://images.pexels.com/photos/3993449/pexels-photo-3993449.jpeg?w=400', tags: ['云端图库', 'Pexels', '素材'] },
      { name: 'Pexels 素材 #2', url: 'https://images.pexels.com/photos/4046316/pexels-photo-4046316.jpeg?w=400', tags: ['云端图库', 'Pexels', '艺术'] },
    ],
    pixabay: [
      { name: 'Pixabay 参考 #1', url: 'https://cdn.pixabay.com/photo/2020/05/30/19/14/flowers-5243498_640.jpg', tags: ['云端图库', 'Pixabay', '花卉'] },
      { name: 'Pixabay 参考 #2', url: 'https://cdn.pixabay.com/photo/2021/08/25/20/42/field-6574455_640.jpg', tags: ['云端图库', 'Pixabay', '风景'] },
    ],
    custom: []
  };
  
  setTimeout(() => {
    if (provider === 'custom') {
      const customUrl = prompt('请输入云端图库API地址：');
      if (!customUrl) { status.textContent = ''; return; }
      status.textContent = '✅ 自定义云端图库已连接（演示模式）';
      status.style.color = 'var(--success)';
      return;
    }
    
    const images = mockCloudImages[provider] || [];
    images.forEach(img => {
      mediaUploadQueue.push({
        name: img.name,
        type: 'image',
        source: 'cloud',
        url: img.url,
        thumbnailUrl: img.url,
        tags: img.tags,
        size: 0
      });
    });
    renderUploadPreview();
    updateUploadConfirmBtn();
    status.textContent = `✅ 从 ${provider} 获取了 ${images.length} 张图片`;
    status.style.color = 'var(--success)';
  }, 800);
}

// 确认上传
function confirmMediaUpload() {
  if (mediaUploadQueue.length === 0) return;
  
  // 处理URL模式下的链接
  if (currentUploadTab === 'url') {
    const urlText = document.getElementById('ml-url-input').value.trim();
    if (urlText) {
      const urls = urlText.split('\n').filter(u => u.trim());
      urls.forEach(url => {
        const isVideo = /\.(mp4|webm|mov|avi)(\?.*)?$/i.test(url);
        const isImage = /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i.test(url);
        mediaUploadQueue.push({
          name: url.split('/').pop().substring(0, 30) || '在线资源',
          type: isVideo ? 'video' : 'image',
          source: 'link',
          url: url,
          thumbnailUrl: isImage ? url : null,
          tags: ['在线链接', isVideo ? '视频' : '图片'],
          size: 0
        });
      });
    }
  }
  
  const uploadedCount = mediaUploadQueue.length;
  mediaUploadQueue.forEach(item => {
    addToMediaLibrary(item);
  });
  
  mediaUploadQueue = [];
  closeMediaUpload();
  showToast(`✅ 已上传 ${uploadedCount || '所有'} 资源到媒体库`,'success');
}

function updateUploadConfirmBtn() {
  const btn = document.getElementById('ml-upload-confirm-btn');
  const hasUrlContent = currentUploadTab === 'url' && document.getElementById('ml-url-input').value.trim();
  btn.disabled = mediaUploadQueue.length === 0 && !hasUrlContent;
}

// ====== 知识库超链接识别 ======
function scanKnowledgeBaseLinks() {
  const scanner = document.getElementById('ml-link-scanner');
  if (scanner.style.display === 'none' || !scanner.style.display) {
    scanner.style.display = 'flex';
    document.getElementById('ml-link-input').focus();
  } else {
    scanner.style.display = 'none';
  }
}

async function fetchLinkResources() {
  const input = document.getElementById('ml-link-input');
  const statusEl = document.getElementById('ml-scan-status');
  const url = input.value.trim();
  
  if (!url) {
    showToast('请输入链接地址','warning');
    return;
  }
  
  statusEl.textContent = '🔍 扫描中...';
  statusEl.className = 'scan-status scanning';
  
  // 模拟扫描和识别
  setTimeout(() => {
    // 检测是否为知识库/图库链接
    const isGallery = /(unsplash|pexels|pixabay|gallery|图库|知识库|wiki|notion|feishu|飞书)/i.test(url);
    const isImageLink = /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i.test(url);
    const isVideoLink = /\.(mp4|webm|mov|avi)(\?.*)?$/i.test(url);
    const isPageLink = !isImageLink && !isVideoLink;
    
    if (isImageLink) {
      // 直接图片链接
      const item = {
        name: url.split('/').pop().split('?')[0].substring(0, 30),
        type: 'image',
        source: 'link',
        url: url,
        thumbnailUrl: url,
        tags: ['在线链接', '超链接识别'],
        size: 0
      };
      addToMediaLibrary(item);
      statusEl.textContent = '✅ 已识别并保存1张图片';
      statusEl.className = 'scan-status success';
      input.value = '';
    } else if (isVideoLink) {
      const item = {
        name: url.split('/').pop().split('?')[0].substring(0, 30),
        type: 'video',
        source: 'link',
        url: url,
        thumbnailUrl: null,
        tags: ['在线链接', '超链接识别'],
        size: 0
      };
      addToMediaLibrary(item);
      statusEl.textContent = '✅ 已识别并保存1个视频';
      statusEl.className = 'scan-status success';
      input.value = '';
    } else if (isGallery) {
      // 知识库/图库页面链接 — 模拟抓取页面中的媒体
      const mockFound = Math.floor(Math.random() * 8) + 3; // 3-10个资源
      statusEl.textContent = `⏳ 正在扫描页面中的媒体资源...`;
      
      setTimeout(() => {
        const colors = ['#FFB6C1','#87CEEB','#DDA0DD','#90EE90','#FFD700','#FFB347','#C0C0C0'];
        for (let i = 0; i < mockFound; i++) {
          const item = {
            name: `知识库资源 #${i+1}`,
            type: Math.random() > 0.2 ? 'image' : 'video',
            source: 'link',
            url: `data:image/svg+xml,${encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="${colors[i%colors.length]}"/><text x="100" y="100" text-anchor="middle" dy=".3em" font-size="40">🖼️</text></svg>`)}`,
            thumbnailUrl: `data:image/svg+xml,${encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="${colors[i%colors.length]}"/><text x="100" y="100" text-anchor="middle" dy=".3em" font-size="40">🖼️</text></svg>`)}`,
            tags: ['知识库', '超链接识别'],
            size: 0
          };
          item.id = 'ml_kb_' + Date.now() + '_' + i;
          item.createdAt = new Date().toISOString();
          mediaLibrary.unshift(item);
        }
        saveMediaLibrary();
        renderMediaLibrary();
        statusEl.textContent = `✅ 成功识别 ${mockFound} 个媒体资源`;
        statusEl.className = 'scan-status success';
        input.value = '';
        showToast(`✅ 从知识库链接识别了 ${mockFound} 个资源`,'success');
      }, 1500);
    } else if (isPageLink) {
      // 普通页面链接，尝试提取页面中的图片
      statusEl.textContent = '⏳ 正在分析页面内容...';
      setTimeout(() => {
        // 模拟：尝试提取OG图片或页面中的媒体
        const item = {
          name: '页面预览图',
          type: 'image',
          source: 'link',
          url: `data:image/svg+xml,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300"><rect width="400" height="300" fill="#1a1a2e"/><text x="200" y="140" text-anchor="middle" fill="#00f0ff" font-size="16">🔗 链接预览</text><text x="200" y="170" text-anchor="middle" fill="#888" font-size="10">页面缩略图</text></svg>')}`,
          thumbnailUrl: `data:image/svg+xml,${encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300"><rect width="400" height="300" fill="#1a1a2e"/><text x="200" y="140" text-anchor="middle" fill="#00f0ff" font-size="16">🔗 链接预览</text><text x="200" y="170" text-anchor="middle" fill="#888" font-size="10">页面缩略图</text></svg>')}`,
          tags: ['在线链接', '超链接识别', '网页'],
          size: 0
        };
        addToMediaLibrary(item);
        statusEl.textContent = '✅ 已提取页面预览资源';
        statusEl.className = 'scan-status success';
        input.value = '';
      }, 1000);
    }
  }, 600);
}

// ====== 预览弹窗 ======
function openMediaPreview(idx) {
  const filtered = getFilteredMedia();
  if (idx < 0 || idx >= filtered.length) return;
  mediaPreviewIdx = mediaLibrary.indexOf(filtered[idx]);
  renderMediaPreview();
  document.getElementById('ml-preview-overlay').classList.remove('hidden');
}

function closeMediaPreview() {
  document.getElementById('ml-preview-overlay').classList.add('hidden');
  mediaPreviewIdx = -1;
}

function navigateMediaPreview(dir) {
  const filtered = getFilteredMedia();
  const currentItem = mediaLibrary[mediaPreviewIdx];
  if (!currentItem) return;
  const currentFilteredIdx = filtered.indexOf(currentItem);
  const newFilteredIdx = currentFilteredIdx + dir;
  if (newFilteredIdx < 0 || newFilteredIdx >= filtered.length) return;
  mediaPreviewIdx = mediaLibrary.indexOf(filtered[newFilteredIdx]);
  renderMediaPreview();
}

function getFilteredMedia() {
  let filtered = mediaLibrary;
  if (mediaFilterTab !== 'all') {
    if (mediaFilterTab === 'ai-generated' || mediaFilterTab === 'uploaded' || mediaFilterTab === 'cloud') {
      filtered = filtered.filter(m => m.source === mediaFilterTab);
    } else {
      filtered = filtered.filter(m => m.type === mediaFilterTab);
    }
  }
  if (mediaFilterTag !== 'all') {
    filtered = filtered.filter(m => m.tags && m.tags.includes(mediaFilterTag));
  }
  if (mlSearchQuery) {
    const q = mlSearchQuery.toLowerCase();
    filtered = filtered.filter(m => m.name.toLowerCase().includes(q) || (m.tags && m.tags.some(t => t.toLowerCase().includes(q))));
  }
  return filtered;
}

function renderMediaPreview() {
  const item = mediaLibrary[mediaPreviewIdx];
  if (!item) return;
  
  const content = document.getElementById('ml-preview-content');
  const info = document.getElementById('ml-preview-info');
  
  if (item.type === 'video') {
    content.innerHTML = `<video src="${item.url}" controls autoplay style="max-width:100%;max-height:75vh;border-radius:var(--radius)"></video>`;
  } else {
    content.innerHTML = `<img src="${item.url}" alt="${escHtml(item.name)}">`;
  }
  
  const date = new Date(item.createdAt).toLocaleString('zh-CN');
  const sizeStr = item.size ? (item.size > 1024*1024 ? (item.size/1024/1024).toFixed(1)+'MB' : (item.size/1024).toFixed(1)+'KB') : '未知';
  info.innerHTML = `
    <strong>${escHtml(item.name)}</strong>
    <span class="tag tag-accent">${item.type === 'video' ? '🎬 视频' : '🖼️ 图片'}</span>
    <span class="tag tag-info">${item.source === 'ai-generated' ? '🤖 AI生成' : item.source === 'uploaded' ? '📤 本地上传' : item.source === 'cloud' ? '☁️ 云端' : '🔗 链接'}</span>
    <span style="color:var(--text-tertiary)">${date} · ${sizeStr}</span>
  `;
  
  // 显示/隐藏导航按钮
  const filtered = getFilteredMedia();
  const currentFilteredIdx = filtered.indexOf(item);
  document.querySelector('.ml-preview-prev').style.display = currentFilteredIdx > 0 ? 'flex' : 'none';
  document.querySelector('.ml-preview-next').style.display = currentFilteredIdx < filtered.length - 1 ? 'flex' : 'none';
}

function downloadMediaItem() {
  const item = mediaLibrary[mediaPreviewIdx];
  if (!item) return;
  const link = document.createElement('a');
  link.href = item.url;
  link.download = item.name || 'media';
  link.click();
  showToast('📥 下载中...','success');
}

async function copyMediaToClipboard() {
  const item = mediaLibrary[mediaPreviewIdx];
  if (!item) return;
  try {
    if (item.url.startsWith('data:')) {
      const resp = await fetch(item.url);
      const blob = await resp.blob();
      await navigator.clipboard.write([new ClipboardItem({ [blob.type]: blob })]);
    } else {
      await navigator.clipboard.writeText(item.url);
    }
    showToast('📋 已复制到剪贴板','success');
  } catch(e) {
    // 降级为复制URL
    await navigator.clipboard.writeText(item.url);
    showToast('📋 链接已复制到剪贴板','success');
  }
}

function deleteMediaItem() {
  const item = mediaLibrary[mediaPreviewIdx];
  if (!item) return;
  if (!confirm(`确定删除 "${item.name}" 吗？此操作不可撤销。`)) return;
  mediaLibrary.splice(mediaPreviewIdx, 1);
  saveMediaLibrary();
  closeMediaPreview();
  renderMediaLibrary();
  showToast('🗑 已删除','info');
}

// 右键菜单
function showMediaContextMenu(event, id) {
  event.preventDefault();
  const item = mediaLibrary.find(m => m.id === id);
  if (!item) return;
  const idx = mediaLibrary.indexOf(item);
  
  // 简单右键菜单
  const actions = [
    { label: '👁 预览', action: () => openMediaPreview(idx) },
    { label: '📥 下载', action: () => { mediaPreviewIdx = idx; downloadMediaItem(); } },
    { label: '📋 复制链接', action: () => { mediaPreviewIdx = idx; copyMediaToClipboard(); } },
    { label: '🗑 删除', action: () => { mediaPreviewIdx = idx; deleteMediaItem(); } },
  ];
  
  // 移除旧菜单
  const oldMenu = document.getElementById('ml-context-menu');
  if (oldMenu) oldMenu.remove();
  
  const menu = document.createElement('div');
  menu.id = 'ml-context-menu';
  menu.style.cssText = `
    position:fixed;z-index:10000;background:var(--bg-secondary);border:1px solid var(--border);
    border-radius:var(--radius);padding:4px;min-width:140px;box-shadow:0 8px 32px rgba(0,0,0,0.4);
    left:${event.clientX}px;top:${event.clientY}px;
  `;
  actions.forEach(a => {
    const btn = document.createElement('button');
    btn.style.cssText = `
      display:block;width:100%;padding:8px 12px;background:none;border:none;color:var(--text-primary);
      font-size:12px;text-align:left;cursor:pointer;border-radius:4px;font-family:inherit;
    `;
    btn.textContent = a.label;
    btn.onmouseenter = () => btn.style.background = 'var(--bg-tertiary)';
    btn.onmouseleave = () => btn.style.background = 'none';
    btn.onclick = () => { a.action(); menu.remove(); };
    menu.appendChild(btn);
  });
  document.body.appendChild(menu);
  
  const closeMenu = (e) => {
    if (!menu.contains(e.target)) { menu.remove(); document.removeEventListener('click', closeMenu); }
  };
  setTimeout(() => document.addEventListener('click', closeMenu), 10);
}

// 拖拽到媒体库区域
function handleMediaDrop(e) {
  e.preventDefault();
  e.target.classList.remove('drag-over');
  const files = Array.from(e.dataTransfer.files);
  if (files.length > 0) {
    processUploadFilesDirect(files);
  }
}

function processUploadFilesDirect(files) {
  let count = 0;
  files.forEach(file => {
    if (file.size > 50 * 1024 * 1024) {
      showToast(`文件 ${file.name} 超过50MB限制`,'warning');
      return;
    }
    const isImage = file.type.startsWith('image/');
    const isVideo = file.type.startsWith('video/');
    if (!isImage && !isVideo) return;
    const reader = new FileReader();
    reader.onload = function(ev) {
      const item = {
        name: file.name,
        type: isVideo ? 'video' : 'image',
        source: 'uploaded',
        url: ev.target.result,
        thumbnailUrl: isVideo ? null : ev.target.result,
        tags: ['本地上传', isVideo ? '视频' : '图片'],
        size: file.size
      };
      addToMediaLibrary(item);
      count++;
    };
    reader.readAsDataURL(file);
  });
  if (count > 0 || files.length === 0) {
    showToast(`✅ 已上传资源到媒体库`,'success');
  }
}

function escHtml(str) {
  return (str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ====== 独立资源库页面函数（复用共享逻辑，使用独立DOM） ======
let mediaFilterTabStandaloneVar = 'all';
let mediaFilterTagStandaloneVar = 'all';
let mlSearchQueryStandalone = '';

function renderMediaLibraryStandalone() {
  const grid = document.getElementById('ml-grid-standalone');
  if (!grid) return;
  
  let filtered = mediaLibrary;
  if (mediaFilterTabStandaloneVar !== 'all') {
    if (['ai-generated','uploaded','cloud'].includes(mediaFilterTabStandaloneVar)) {
      filtered = filtered.filter(m => m.source === mediaFilterTabStandaloneVar);
    } else {
      filtered = filtered.filter(m => m.type === mediaFilterTabStandaloneVar);
    }
  }
  if (mediaFilterTagStandaloneVar !== 'all') {
    filtered = filtered.filter(m => m.tags && m.tags.includes(mediaFilterTagStandaloneVar));
  }
  if (mlSearchQueryStandalone) {
    const q = mlSearchQueryStandalone.toLowerCase();
    filtered = filtered.filter(m => m.name.toLowerCase().includes(q) || (m.tags && m.tags.some(t => t.toLowerCase().includes(q))));
  }
  
  updateMediaCountsStandalone();
  
  if (filtered.length === 0) {
    grid.innerHTML = `
      <div class="ml-empty" style="display:block;grid-column:1/-1">
        <div class="ml-empty-icon">📭</div>
        <p>资源库为空</p>
        <p style="font-size:11px">AI生成的图片/视频将自动保存到这里<br>也可以上传本地文件或识别在线链接</p>
      </div>`;
  } else {
    grid.innerHTML = filtered.map((m) => {
      const idx = mediaLibrary.indexOf(m);
      const isVideo = m.type === 'video';
      const thumb = m.thumbnailUrl || m.url;
      return `
        <div class="ml-item" onclick="openMediaPreview(${idx})" title="${escHtml(m.name)}">
          ${isVideo 
            ? `<video src="${m.url}" muted preload="metadata"></video><div class="ml-type-badge">🎬</div>`
            : `<img src="${thumb}" alt="${escHtml(m.name)}" loading="lazy" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
               <div class="ml-placeholder" style="display:none;position:absolute;inset:0;align-items:center;justify-content:center">🖼️</div>`
          }
          ${m.source === 'ai-generated' ? '<div class="ml-save-badge">AI</div>' : ''}
          <div class="ml-item-info">${escHtml(m.name.substring(0, 20))}</div>
          <button class="ml-item-menu" onclick="event.stopPropagation();showMediaContextMenu(event,'${m.id}')">⋯</button>
        </div>`;
    }).join('');
  }
  
  renderTagFiltersStandalone();
}

function updateMediaCountsStandalone() {
  const total = mediaLibrary.length;
  const el = (id, v) => { const e = document.getElementById(id); if(e) e.textContent = v; };
  el('mls-count-all', total);
  el('mls-count-image', mediaLibrary.filter(m => m.type === 'image').length);
  el('mls-count-video', mediaLibrary.filter(m => m.type === 'video').length);
  el('mls-count-ai', mediaLibrary.filter(m => m.source === 'ai-generated').length);
  el('mls-count-uploaded', mediaLibrary.filter(m => m.source === 'uploaded').length);
  el('mls-count-cloud', mediaLibrary.filter(m => m.source === 'cloud').length);
}

function renderTagFiltersStandalone() {
  const allTags = new Set();
  mediaLibrary.forEach(m => { if (m.tags) m.tags.forEach(t => allTags.add(t)); });
  const container = document.getElementById('ml-tag-filters-standalone');
  if (!container) return;
  let html = '<span class="ml-filter-tag active" onclick="filterMediaTagStandalone(\'all\',this)">全部</span>';
  allTags.forEach(tag => {
    html += `<span class="ml-filter-tag" onclick="filterMediaTagStandalone('${escHtml(tag)}',this)">${escHtml(tag)}</span>`;
  });
  container.innerHTML = html;
}

function filterMediaTabStandalone(tab, el) {
  mediaFilterTabStandaloneVar = tab;
  document.querySelectorAll('#ml-tabs-standalone .ml-tab').forEach(e => e.classList.remove('active'));
  if (el) el.classList.add('active');
  renderMediaLibraryStandalone();
}

function filterMediaTagStandalone(tag, el) {
  mediaFilterTagStandaloneVar = tag;
  document.querySelectorAll('#ml-tag-filters-standalone .ml-filter-tag').forEach(e => e.classList.remove('active'));
  if (el) el.classList.add('active');
  renderMediaLibraryStandalone();
}

function searchMediaStandalone() {
  mlSearchQueryStandalone = document.getElementById('ml-search-standalone').value;
  renderMediaLibraryStandalone();
}

function scanKnowledgeBaseLinksStandalone() {
  const scanner = document.getElementById('ml-link-scanner-standalone');
  if (scanner.style.display === 'none' || !scanner.style.display) {
    scanner.style.display = 'flex';
    document.getElementById('ml-link-input-standalone').focus();
  } else {
    scanner.style.display = 'none';
  }
}

async function fetchLinkResourcesStandalone() {
  const input = document.getElementById('ml-link-input-standalone');
  const statusEl = document.getElementById('ml-scan-status-standalone');
  const url = input.value.trim();
  if (!url) { showToast('请输入链接地址','warning'); return; }
  
  statusEl.textContent = '🔍 扫描中...';
  statusEl.className = 'scan-status scanning';
  
  setTimeout(() => {
    const isImageLink = /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i.test(url);
    const isVideoLink = /\.(mp4|webm|mov|avi)(\?.*)?$/i.test(url);
    const isGallery = /(unsplash|pexels|pixabay|gallery|图库|知识库|wiki|notion|feishu|飞书)/i.test(url);
    
    if (isImageLink) {
      addToMediaLibrary({ name: url.split('/').pop().split('?')[0].substring(0,30), type:'image', source:'link', url, thumbnailUrl: url, tags:['在线链接','超链接识别'], size:0 });
      statusEl.textContent = '✅ 已识别并保存1张图片';
      statusEl.className = 'scan-status success';
      input.value = '';
    } else if (isVideoLink) {
      addToMediaLibrary({ name: url.split('/').pop().split('?')[0].substring(0,30), type:'video', source:'link', url, thumbnailUrl: null, tags:['在线链接','超链接识别'], size:0 });
      statusEl.textContent = '✅ 已识别并保存1个视频';
      statusEl.className = 'scan-status success';
      input.value = '';
    } else if (isGallery) {
      statusEl.textContent = '⏳ 正在扫描页面中的媒体资源...';
      setTimeout(() => {
        const colors = ['#FFB6C1','#87CEEB','#DDA0DD','#90EE90','#FFD700'];
        const mockFound = Math.floor(Math.random() * 8) + 3;
        for (let i = 0; i < mockFound; i++) {
          const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200"><rect width="200" height="200" fill="${colors[i%colors.length]}"/><text x="100" y="100" text-anchor="middle" dy=".3em" font-size="40">🖼️</text></svg>`;
          const dataUrl = 'data:image/svg+xml,' + encodeURIComponent(svg);
          const item = { name: `知识库资源 #${i+1}`, type:'image', source:'link', url: dataUrl, thumbnailUrl: dataUrl, tags:['知识库','超链接识别'], size:0 };
          item.id = 'ml_kb_' + Date.now() + '_' + i;
          item.createdAt = new Date().toISOString();
          mediaLibrary.unshift(item);
        }
        saveMediaLibrary();
        renderMediaLibraryStandalone();
        renderMediaLibrary();
        statusEl.textContent = `✅ 成功识别 ${mockFound} 个媒体资源`;
        statusEl.className = 'scan-status success';
        input.value = '';
        showToast(`✅ 从知识库链接识别了 ${mockFound} 个资源`,'success');
      }, 1500);
    } else {
      statusEl.textContent = '⏳ 正在分析页面内容...';
      setTimeout(() => {
        const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300"><rect width="400" height="300" fill="#1a1a2e"/><text x="200" y="140" text-anchor="middle" fill="#00f0ff" font-size="16">🔗 链接预览</text></svg>';
        const dataUrl = 'data:image/svg+xml,' + encodeURIComponent(svg);
        addToMediaLibrary({ name:'页面预览图', type:'image', source:'link', url: dataUrl, thumbnailUrl: dataUrl, tags:['在线链接','超链接识别','网页'], size:0 });
        statusEl.textContent = '✅ 已提取页面预览资源';
        statusEl.className = 'scan-status success';
        input.value = '';
      }, 1000);
    }
  }, 600);
}

function handleMediaDropStandalone(e) {
  e.preventDefault();
  e.target.classList.remove('drag-over');
  const files = Array.from(e.dataTransfer.files);
  files.forEach(file => {
    if (file.size > 50*1024*1024) { showToast(`文件 ${file.name} 超过50MB限制`,'warning'); return; }
    const isImage = file.type.startsWith('image/');
    const isVideo = file.type.startsWith('video/');
    if (!isImage && !isVideo) return;
    const reader = new FileReader();
    reader.onload = function(ev) {
      addToMediaLibrary({
        name: file.name, type: isVideo?'video':'image', source:'uploaded',
        url: ev.target.result, thumbnailUrl: isVideo?null:ev.target.result,
        tags: ['本地上传', isVideo?'视频':'图片'], size: file.size
      });
      renderMediaLibraryStandalone();
    };
    reader.readAsDataURL(file);
  });
}

// ====== 键盘快捷键 ======
document.addEventListener('keydown', function(e) {
  // ESC 关闭预览
  if (e.key === 'Escape') {
    if (!document.getElementById('ml-preview-overlay').classList.contains('hidden')) {
      closeMediaPreview();
      return;
    }
    if (!document.getElementById('ml-upload-overlay').classList.contains('hidden')) {
      closeMediaUpload();
      return;
    }
  }
  // 左右箭头导航预览
  if (!document.getElementById('ml-preview-overlay').classList.contains('hidden')) {
    if (e.key === 'ArrowLeft') { navigateMediaPreview(-1); e.preventDefault(); }
    if (e.key === 'ArrowRight') { navigateMediaPreview(1); e.preventDefault(); }
  }
});

// TOAST
function showToast(msg,type='info'){const c=document.getElementById('toast-container');const t=document.createElement('div');t.className=`toast toast-${type}`;t.textContent=msg;c.appendChild(t);setTimeout(()=>t.remove(),2500)}

// STATUS BAR
function updateStatusTime(){document.getElementById('status-time').textContent=new Date().toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'})}

// KEYBOARD SHORTCUTS
document.addEventListener('keydown',(e)=>{if(!isLoggedIn)return;const mod=e.metaKey||e.ctrlKey;if(mod&&e.key==='k'){e.preventDefault();openCommandPalette();return}if(mod&&e.key==='\\'){e.preventDefault();toggleSidebar();return}if(mod&&e.key===','){e.preventDefault();navigateTo('settings');return}if(mod&&e.key>='1'&&e.key<='8'){e.preventDefault();const pages=['create','device','community','payment','agents','providers','openclaw','admin'];navigateTo(pages[parseInt(e.key)-1])}});
document.addEventListener('click',(e)=>{const p=document.getElementById('command-palette');if(!p.classList.contains('hidden')&&!p.contains(e.target))closeCommandPalette()});

// OLLAMA
async function testOllamaConnection(){
  const statusDot = document.getElementById('ollama-status');
  const statusText = document.getElementById('ollama-status-text');
  statusDot.className = 'status-dot status-loading';
  statusText.textContent = '检测中...';
  
  try {
    const available = await OllamaService.checkAvailability();
    if (available) {
      statusDot.className = 'status-dot status-online';
      const models = await OllamaService.listModels();
      const modelNames = models.map(m => m.name.split(':')[0]).join(', ');
      statusText.textContent = `已连接 · ${models.length} 个模型 (${modelNames.substring(0, 40)}...)`;
      showToast(`🦙 Ollama 已连接！${models.length} 个模型可用`,'success');
    } else {
      statusDot.className = 'status-dot status-offline';
      statusText.textContent = '未连接 · 请确认 ollama serve 已启动';
      showToast('⚠️ Ollama 服务未运行，请执行: ollama serve','error');
    }
  } catch(e) {
    statusDot.className = 'status-dot status-offline';
    statusText.textContent = '连接失败: ' + e.message;
    showToast('❌ Ollama 连接失败','error');
  }
}

async function refreshOllamaModels(){
  const statusText = document.getElementById('ollama-status-text');
  try {
    const models = await OllamaService.listModels();
    if (models.length > 0) {
      const modelList = models.map(m => `${m.name} (${m.details?.parameter_size || '?'})`).join(', ');
      statusText.textContent = `已连接 · ${models.length} 个模型`;
      showToast(`📋 可用模型: ${modelList}`,'info');
    } else {
      statusText.textContent = '已连接 · 无本地模型';
      showToast('⚠️ 无可用模型，请拉取: ollama pull <model>','warning');
    }
  } catch(e) {
    showToast('❌ 无法获取模型列表','error');
  }
}

// 页面加载时自动检测 Ollama
setTimeout(() => {
  if (typeof OllamaService !== 'undefined') {
    testOllamaConnection();
  }
}, 1000);

// INIT
updatePaymentSummary();
updateStatusTime();

// Electron IPC
if(window.electronAPI){
  window.electronAPI.onNavigate((page)=>navigateTo(page));
  window.electronAPI.onToggleSidebar(()=>toggleSidebar());
  window.electronAPI.onCommandPalette(()=>openCommandPalette());
}
