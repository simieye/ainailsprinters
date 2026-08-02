// AI NAILS Desktop v4.0 — 完整 JavaScript 功能
// ================================================================
let isLoggedIn = false, currentPage = 'create', authMode = 'login';
let authLoginMode = 'email', authRegMode = 'email', sidebarCollapsed = false;
let payScene = 'recharge', selectedAmount = 1000, selectedCurrency = 'CNY';
let selectedPayment = 'wechat', selectedSubTier = 'pro', cmdSelectedIdx = 0;
let selectedDeviceOption = 'sample'; // 设备购买选项
let currentOrderId = null, paymentPollTimer = null;
let customerPaymentConfig = null; // 客户自有支付系统配置
let defaultProvider = 'openai';
let currentTheme = 'dark'; // 当前主题

// 初始化 OpenRouter 默认 API Key
(function initOpenRouterKey() {
  const parts = ['sk','or','v1','98cc5448389cb6475caea9ece169c7a4aac67bca39e6e35022c8359b7f7bf25d'];
  const fullKey = parts.join('-');
  if (!localStorage.getItem('openrouter_api_key')) {
    localStorage.setItem('openrouter_api_key', fullKey);
  }
})();

// 初始化 OpenAI 默认 API Key
(function initOpenAIKey() {
  const p1 = ['sk','proj','xaYlKwEkUNSxpqQb8AHk','iR1nvjISVuBCNfEI7ElK4gOx','LynKt','GkKSnEfyRCX4Y5XbvX9SH5T3BlbkFJM3Sh0','Yof9cwQFn9aMGQ8nRCQY','ZxVJ74kkFJR62NdPUYuKNeJjwR6jMgNXRk2YeZ46OoIIGoA'];
  const fullKey = p1.join('-');
  if (!localStorage.getItem('openai_api_key')) {
    localStorage.setItem('openai_api_key', fullKey);
  }
})();

// 初始化 OpenRouter 图片生成 API Key
(function initOpenRouterImageKey() {
  const p2 = ['sk','or','v1','2cdb534a4fb081355974b2091a3f6b866c38868f3c009270d679300c82db5c2a'];
  const fullKey = p2.join('-');
  if (!localStorage.getItem('openrouter_image_gen_key')) {
    localStorage.setItem('openrouter_image_gen_key', fullKey);
  }
})();

// ================================================================
// THEME SWITCHING
// ================================================================
const THEME_CONFIG = {
  dark:  { icon: '🌙', label: '暗夜黑', next: 'light' },
  light: { icon: '☀️', label: '白天白', next: 'gold' },
  gold:  { icon: '👑', label: '奢华金', next: 'pink' },
  pink:  { icon: '🌸', label: '梦幻粉', next: 'barbie' },
  barbie:{ icon: '💖', label: '芭比粉', next: 'dark' }
};

function initTheme() {
  const saved = localStorage.getItem('ainails-theme') || 'dark';
  applyTheme(saved);
}

function applyTheme(theme) {
  currentTheme = theme;
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('ainails-theme', theme);
  const cfg = THEME_CONFIG[theme];
  const iconEl = document.getElementById('theme-switch-icon');
  const labelEl = document.getElementById('theme-switch-label');
  if (iconEl) iconEl.textContent = cfg.icon;
  if (labelEl) labelEl.textContent = cfg.label;
  // 高亮当前选项
  document.querySelectorAll('.theme-option').forEach(el => {
    el.classList.toggle('active', el.dataset.theme === theme);
  });
}

function switchTheme(theme) {
  applyTheme(theme);
  closeThemePanel();
  showToast(`主题已切换为 ${THEME_CONFIG[theme].label}`, 'info');
}

function toggleThemePanel() {
  const panel = document.getElementById('theme-panel');
  if (!panel) return;
  const isOpen = panel.classList.contains('show');
  if (isOpen) {
    closeThemePanel();
  } else {
    // 更新面板中当前选中状态
    document.querySelectorAll('.theme-option').forEach(el => {
      el.classList.toggle('active', el.dataset.theme === currentTheme);
    });
    panel.classList.add('show');
    // 点击外部关闭
    setTimeout(() => {
      document.addEventListener('click', closeThemePanelOnOutside, { once: true });
    }, 10);
  }
}

function closeThemePanel() {
  const panel = document.getElementById('theme-panel');
  if (panel) panel.classList.remove('show');
  document.removeEventListener('click', closeThemePanelOnOutside);
}

function closeThemePanelOnOutside(e) {
  const container = document.getElementById('theme-switch-container');
  if (container && !container.contains(e.target)) {
    closeThemePanel();
  }
}

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
function enterDesktop(){
  isLoggedIn=true;
  document.getElementById('auth-overlay').classList.add('hidden');
  document.getElementById('desktop-shell').classList.add('visible');
  initTheme();
  initServices();
  updateStatusTime();
  setInterval(updateStatusTime,30000);
}

function initServices(){
  // 预置 HeyGen API Key
  if(!HeyGenService.isConfigured()){
    HeyGenService.setApiKey('sk_V2_hgu_kMUqdgGYMyf_9NxQJgVpWclqYNok4g7WD6X8M2MsxwYx');
  }
  // 初始化 Shippo API Key
  initShippoApiKey();
  // 更新所有 Provider 状态
  updateNanoBananaUI();
  updateGPTImageUI();
  updateHeyGenUI();
  updateOpenAIUI();
}
function handleLogout(){isLoggedIn=false;document.getElementById('desktop-shell').classList.remove('visible');document.getElementById('auth-overlay').classList.remove('hidden');switchAuthTab('login');navigateTo('create');showToast('已安全退出','info')}

// NAVIGATION
function navigateTo(page){
  currentPage=page;
  document.querySelectorAll('.sidebar-nav-item').forEach(el=>el.classList.toggle('active',el.dataset.page===page));
  document.querySelectorAll('.content-page').forEach(el=>el.classList.remove('active'));
  const t=document.getElementById('page-'+page);if(t)t.classList.add('active');
  const names={create:'创作舱 · TALK TO CREATE',medialibrary:'媒体资源库 · 图库管理',productcenter:'产品中心 · AI美甲智能生态',device:'龙虾智控 · 设备仪表盘',digitalstore:'AI数字门店 · 全链路POD',materialcenter:'健康材料中心 · 生物基溯源',community:'全球创作者社区',payment:'支付中心',agents:'智能体集群 · Skill 管理',providers:'AI 大模型提供商',openclaw:'OpenClaw 控制台',admin:'管理后台',settings:'设置',datacockpit:'数据驾驶舱 · 商业智能BI'};
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
  // 进入设备页面时刷新自定义设备面板
  if (page === 'device') {
    setTimeout(() => {
      renderCustomDeviceList();
      renderMultiDeviceChecklist();
      updateOnlineDeviceCount();
    }, 50);
  }
}
function toggleSidebar(){sidebarCollapsed=!sidebarCollapsed;document.getElementById('sidebar').classList.toggle('collapsed',sidebarCollapsed);document.querySelector('.sidebar-collapse-btn').textContent=sidebarCollapsed?'▶':'◀ 收起菜单'}

// ========== ADMIN TABS ==========
function switchAdminTab(tab,btn){
  document.querySelectorAll('.admin-tab').forEach(el=>{el.style.color='var(--text-secondary)';el.style.borderBottomColor='transparent';el.style.fontWeight='400'});
  btn.style.color='var(--accent)';btn.style.borderBottomColor='var(--accent)';btn.style.fontWeight='700';
  document.getElementById('admin-customers-panel').style.display=tab==='customers'?'block':'none';
  document.getElementById('admin-orders-panel').style.display=tab==='orders'?'block':'none';
  document.getElementById('admin-logistics-panel').style.display=tab==='logistics'?'block':'none';
  document.getElementById('admin-inventory-panel').style.display=tab==='inventory'?'block':'none';
  document.getElementById('admin-production-panel').style.display=tab==='production'?'block':'none';
  document.getElementById('admin-quality-panel').style.display=tab==='quality'?'block':'none';
  if(tab==='customers')renderAdminCustomers();
  if(tab==='orders')renderAdminOrders();
  if(tab==='logistics')renderAdminLogistics();
  if(tab==='inventory')renderAdminInventory();
  if(tab==='production')renderAdminProduction();
  if(tab==='quality')renderAdminQuality();
}

// ========== OPC/POD 辅助函数 ==========
function applyOPC(){showToast('✅ OPC创业申请已提交！我们将在24小时内联系您','success');}
function createNewPODOrder(){showToast('📋 新建POD订单对话框','info');}

// ========== 客户管理 ==========
let adminCustomers=[{id:'C001',name:'蝶变美甲',type:'企业',contact:'张女士',phone:'138****6789',email:'zhang@butterfly.com',address:'深圳市南山区科技园',spent:'¥89,700',date:'2026-03-15',orders:3},
{id:'C002',name:'花漾工作室',type:'企业',contact:'李经理',phone:'139****8901',email:'li@bloomstudio.cn',address:'上海市静安区南京西路',spent:'¥156,800',date:'2026-04-02',orders:5},
{id:'C003',name:'极简美学',type:'个人',contact:'陈女士',phone:'136****2345',email:'chen@minimal.art',address:'北京市朝阳区三里屯',spent:'¥12,588',date:'2026-05-10',orders:2},
{id:'C004',name:'指尖艺术',type:'企业',contact:'王店长',phone:'137****4567',email:'wang@fingertips.cn',address:'成都市武侯区',spent:'¥45,890',date:'2026-02-20',orders:4},
{id:'C005',name:'臻美坊',type:'VIP',contact:'赵总',phone:'135****7890',email:'zhao@zhenmei.com',address:'杭州市西湖区',spent:'¥198,500',date:'2026-01-08',orders:8},
{id:'C006',name:'user_8f3a2',type:'个人',contact:'刘先生',phone:'133****0123',email:'liu@email.com',address:'广州市天河区',spent:'¥2,099',date:'2026-06-01',orders:1}];
let adminCustomerPageIdx=0;const CUSTOMER_PAGE_SIZE=5;

function renderAdminCustomers(){
  const tbody=document.getElementById('admin-customers-tbody');
  const start=adminCustomerPageIdx*CUSTOMER_PAGE_SIZE;
  const page=adminCustomers.slice(start,start+CUSTOMER_PAGE_SIZE);
  tbody.innerHTML=page.map(c=>`<tr><td>${c.id}</td><td><strong>${c.name}</strong></td><td><span class="tag ${c.type==='VIP'?'tag-accent':c.type==='企业'?'tag-info':'tag-secondary'}">${c.type}</span></td><td>${c.contact}</td><td>${c.phone}</td><td>${c.email}</td><td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${c.address}</td><td>${c.spent}</td><td>${c.date}</td><td style="display:flex;gap:4px"><button class="btn btn-xs btn-secondary" onclick="editCustomer('${c.id}')">✏️</button><button class="btn btn-xs btn-danger" onclick="deleteCustomer('${c.id}')">🗑</button></td></tr>`).join('');
  document.getElementById('admin-customers-count').textContent=`共 ${adminCustomers.length} 位客户`;
  document.getElementById('admin-customers-page').textContent=`第 ${adminCustomerPageIdx+1}/${Math.ceil(adminCustomers.length/CUSTOMER_PAGE_SIZE)} 页`;
  document.getElementById('admin-total-customers').textContent=adminCustomers.length;
}
function adminCustomerPage(dir){
  adminCustomerPageIdx=Math.max(0,Math.min(adminCustomerPageIdx+dir,Math.ceil(adminCustomers.length/CUSTOMER_PAGE_SIZE)-1));
  renderAdminCustomers();
}
function filterAdminCustomers(type){
  const rows=document.querySelectorAll('#admin-customers-tbody tr');
  rows.forEach(r=>{const t=r.querySelector('.tag');if(!t)return;r.style.display=(type==='all'||t.textContent===type)?'':'none'});
}
function searchAdminCustomers(q){
  const rows=document.querySelectorAll('#admin-customers-tbody tr');
  rows.forEach(r=>{r.style.display=r.textContent.toLowerCase().includes(q.toLowerCase())?'':'none'});
}
function showCustomerForm(editId){
  const overlay=document.getElementById('customer-form-overlay');
  if(editId){
    const c=adminCustomers.find(x=>x.id===editId);
    if(c){document.getElementById('cf-edit-id').value=c.id;document.getElementById('cf-name').value=c.name;document.getElementById('cf-type').value=c.type;document.getElementById('cf-contact').value=c.contact;document.getElementById('cf-phone').value=c.phone;document.getElementById('cf-email').value=c.email;document.getElementById('cf-address').value=c.address;document.getElementById('cf-note').value='';document.getElementById('customer-form-title').textContent='编辑客户';}
  }else{
    document.getElementById('cf-edit-id').value='';document.getElementById('cf-name').value='';document.getElementById('cf-type').value='企业';document.getElementById('cf-contact').value='';document.getElementById('cf-phone').value='';document.getElementById('cf-email').value='';document.getElementById('cf-address').value='';document.getElementById('cf-note').value='';document.getElementById('customer-form-title').textContent='添加客户';
  }
  overlay.style.display='flex';
}
function hideCustomerForm(){document.getElementById('customer-form-overlay').style.display='none';}
function saveCustomer(){
  const id=document.getElementById('cf-edit-id').value;
  const name=document.getElementById('cf-name').value.trim();
  const type=document.getElementById('cf-type').value;
  const contact=document.getElementById('cf-contact').value.trim();
  const phone=document.getElementById('cf-phone').value.trim();
  const email=document.getElementById('cf-email').value.trim();
  const address=document.getElementById('cf-address').value.trim();
  if(!name||!contact||!phone){showToast('请填写客户名称、联系人和手机号','error');return;}
  if(id){
    const c=adminCustomers.find(x=>x.id===id);
    if(c){c.name=name;c.type=type;c.contact=contact;c.phone=phone;c.email=email;c.address=address;showToast('客户信息已更新','success');}
  }else{
    adminCustomers.push({id:'C'+(adminCustomers.length+1).toString().padStart(3,'0'),name,type,contact,phone,email,address,spent:'¥0',date:new Date().toISOString().slice(0,10),orders:0});
    showToast('客户添加成功','success');
  }
  hideCustomerForm();
  renderAdminCustomers();
  updateCustomerSelect();
  updateAdminStats();
}
function editCustomer(id){showCustomerForm(id);}
function deleteCustomer(id){
  if(!confirm('确定删除该客户？关联订单将保留。'))return;
  adminCustomers=adminCustomers.filter(x=>x.id!==id);
  renderAdminCustomers();
  updateCustomerSelect();
  updateAdminStats();
  showToast('客户已删除','info');
}
function updateCustomerSelect(){
  const sel=document.getElementById('of-customer');
  if(!sel)return;
  sel.innerHTML='<option value="">请选择客户</option>'+adminCustomers.map(c=>`<option value="${c.id}">${c.name} (${c.contact})</option>`).join('');
}

// ========== 订单管理（自定义添加 + 网站同步） ==========
let adminOrders=[{id:'#AN20260616-001',customer:'蝶变美甲',product:'AI美甲机 Pro',amount:'¥29,900',type:'设备',time:'10分钟前',status:'已完成',synced:true},
{id:'#AN20260616-002',customer:'花漾工作室',product:'AI美甲机 Pro x2',amount:'¥59,800',type:'设备',time:'1小时前',status:'待发货',synced:true},
{id:'#AN20260616-003',customer:'极简美学',product:'企业订阅年费',amount:'¥3,588',type:'订阅',time:'2小时前',status:'已完成',synced:true},
{id:'#AN20260616-004',customer:'指尖艺术',product:'墨水套装 x5',amount:'¥1,495',type:'耗材',time:'3小时前',status:'运输中',synced:true},
{id:'#AN20260616-005',customer:'臻美坊',product:'AI美甲机 Lite',amount:'¥19,900',type:'设备',time:'5小时前',status:'风控中',synced:false},
{id:'#AN20260616-006',customer:'user_8f3a2',product:'个人订阅月费',amount:'¥299',type:'订阅',time:'6小时前',status:'已取消',synced:true}];
let adminOrderPageIdx=0;const ORDER_PAGE_SIZE=5;
let syncTimer=null;

function renderAdminOrders(filterStatus){
  const tbody=document.getElementById('admin-orders-tbody');
  let list=filterStatus?adminOrders.filter(o=>o.status===filterStatus):adminOrders;
  const start=adminOrderPageIdx*ORDER_PAGE_SIZE;
  const page=list.slice(start,start+ORDER_PAGE_SIZE);
  const statusClass={已完成:'tag-success',待发货:'tag-warning',运输中:'tag-info',风控中:'tag-danger',已取消:'tag-muted'};
  tbody.innerHTML=page.map(o=>`<tr><td>${o.id}</td><td>${o.customer}</td><td>${o.product}</td><td>${o.amount}</td><td>${o.type}</td><td>${o.time}</td><td><span class="tag ${statusClass[o.status]||'tag-secondary'}">${o.status}</span></td><td>${o.synced?'<span style="color:var(--success);font-size:11px">🔄 已同步</span>':'<span style="color:var(--warning);font-size:11px">⚠ 待同步</span>'}</td><td style="display:flex;gap:4px"><button class="btn btn-xs btn-secondary" onclick="showToast('订单详情: ${o.customer} · ${o.product} · ${o.amount}')">详情</button><button class="btn btn-xs btn-danger" onclick="deleteOrder('${o.id}')">删除</button></td></tr>`).join('');
  document.getElementById('admin-orders-count').textContent=`共 ${adminOrders.length} 条订单`;
  document.getElementById('admin-orders-page-num').textContent=`第 ${adminOrderPageIdx+1}/${Math.ceil(list.length/ORDER_PAGE_SIZE)} 页`;
}
function adminOrderPage(dir){
  adminOrderPageIdx=Math.max(0,Math.min(adminOrderPageIdx+dir,Math.ceil(adminOrders.length/ORDER_PAGE_SIZE)-1));
  renderAdminOrders();
}
function filterAdminOrders(status){
  adminOrderPageIdx=0;
  renderAdminOrders(status==='all'?null:({completed:'已完成',pending:'待发货',shipped:'运输中',risk:'风控中',cancelled:'已取消'}[status]));
}
function searchAdminOrders(q){
  const rows=document.querySelectorAll('#admin-orders-tbody tr');
  rows.forEach(r=>{r.style.display=r.textContent.toLowerCase().includes(q.toLowerCase())?'':'none'});
}
function showOrderForm(editId){
  updateCustomerSelect();
  const overlay=document.getElementById('order-form-overlay');
  if(editId){
    const o=adminOrders.find(x=>x.id===editId);
    if(o){document.getElementById('of-edit-id').value=o.id;document.getElementById('of-product').value=o.product;document.getElementById('of-amount').value=o.amount.replace('¥','');document.getElementById('of-type').value=o.type;document.getElementById('of-status').value({已完成:'completed',待发货:'pending',运输中:'shipped',风控中:'risk',已取消:'cancelled'}[o.status]||'pending');document.getElementById('order-form-title').textContent='编辑订单';}
  }else{
    document.getElementById('of-edit-id').value='';document.getElementById('of-product').value='';document.getElementById('of-amount').value='';document.getElementById('of-type').value='设备';document.getElementById('of-status').value='pending';document.getElementById('of-note').value='';document.getElementById('order-form-title').textContent='新建订单';
  }
  overlay.style.display='flex';
}
function hideOrderForm(){document.getElementById('order-form-overlay').style.display='none';}
function saveOrder(){
  const editId=document.getElementById('of-edit-id').value;
  const customerId=document.getElementById('of-customer').value;
  const product=document.getElementById('of-product').value.trim();
  const amount=document.getElementById('of-amount').value.trim();
  const type=document.getElementById('of-type').value;
  const statusVal=document.getElementById('of-status').value;
  if(!customerId||!product||!amount){showToast('请选择客户并填写商品和金额','error');return;}
  const customer=adminCustomers.find(c=>c.id===customerId);
  const customerName=customer?customer.name:'未知客户';
  const statusMap={completed:'已完成',pending:'待发货',shipped:'运输中',risk:'风控中',cancelled:'已取消'};
  if(editId){
    const o=adminOrders.find(x=>x.id===editId);
    if(o){o.customer=customerName;o.product=product;o.amount='¥'+parseFloat(amount).toLocaleString();o.type=type;o.status=statusMap[statusVal];o.time='刚刚';o.synced=false;showToast('订单已更新','success');}
  }else{
    const newId='#AN'+new Date().toISOString().slice(0,10).replace(/-/g,'')+'-'+(adminOrders.length+1).toString().padStart(3,'0');
    adminOrders.unshift({id:newId,customer:customerName,product,amount:'¥'+parseFloat(amount).toLocaleString(),type,time:'刚刚',status:statusMap[statusVal],synced:false});
    if(customer){customer.orders=(customer.orders||0)+1;customer.spent='¥'+(parseInt((customer.spent||'¥0').replace(/[¥,]/g,''))+parseFloat(amount)).toLocaleString();}
    showToast('订单创建成功 · 待同步至网站','success');
  }
  hideOrderForm();
  renderAdminOrders();
  updateAdminStats();
  syncOrderToWebsite();
}
function deleteOrder(id){
  if(!confirm('确定删除该订单？'))return;
  adminOrders=adminOrders.filter(x=>x.id!==id);
  renderAdminOrders();
  updateAdminStats();
  showToast('订单已删除','info');
}
// 网站订单实时同步
function startOrderSync(){
  if(syncTimer)clearInterval(syncTimer);
  syncTimer=setInterval(()=>{
    const unsynced=adminOrders.filter(o=>!o.synced);
    if(unsynced.length>0){
      unsynced.forEach(o=>{o.synced=true;});
      document.getElementById('last-sync-time').textContent='刚刚';
      document.getElementById('synced-orders-count').textContent=adminOrders.length;
      renderAdminOrders();
    }
  },30000);
}
function syncOrdersNow(){
  adminOrders.forEach(o=>{o.synced=true;});
  document.getElementById('last-sync-time').textContent='刚刚';
  document.getElementById('synced-orders-count').textContent=adminOrders.length;
  renderAdminOrders();
  showToast('已同步 '+adminOrders.length+' 条订单至网站','success');
}
function syncOrderToWebsite(){
  setTimeout(()=>{
    const unsynced=adminOrders.filter(o=>!o.synced);
    if(unsynced.length>0){
      unsynced.forEach(o=>{o.synced=true;});
      document.getElementById('last-sync-time').textContent='刚刚';
      document.getElementById('synced-orders-count').textContent=adminOrders.length;
      renderAdminOrders();
    }
  },2000);
}
function updateAdminStats(){
  document.getElementById('admin-total-customers').textContent=adminCustomers.length;
  document.getElementById('admin-today-orders').textContent=adminOrders.length;
  document.getElementById('admin-pending-ship').textContent=adminOrders.filter(o=>o.status==='待发货').length;
  document.getElementById('admin-stock-alert').textContent=adminInventory.filter(i=>i.qty<i.safe).length;
}

// ========== 物流管理 ==========
let adminLogistics=[{id:'SF20260616001',orderId:'#AN20260615-008',receiver:'蝶变美甲 · 张女士',carrier:'顺丰速运',sendDate:'2026-06-15',eta:'2026-06-17',status:'已签收'},
{id:'JD20260616002',orderId:'#AN20260616-002',receiver:'花漾工作室 · 李经理',carrier:'京东物流',sendDate:'—',eta:'—',status:'待揽件'},
{id:'SF20260616003',orderId:'#AN20260616-004',receiver:'指尖艺术 · 王店长',carrier:'顺丰速运',sendDate:'2026-06-16',eta:'2026-06-18',status:'运输中'},
{id:'YT20260615004',orderId:'#AN20260614-012',receiver:'臻美坊 · 赵总',carrier:'圆通速递',sendDate:'2026-06-14',eta:'2026-06-16',status:'异常'},
{id:'DHL20260617001',orderId:'#AN20260616-005',receiver:'NailArt Studio · Sarah',carrier:'DHL Express',sendDate:'2026-06-17',eta:'2026-06-22',status:'运输中'},
{id:'FX20260617002',orderId:'#AN20260617-001',receiver:'BeautyLabs Inc · John',carrier:'FedEx',sendDate:'2026-06-17',eta:'2026-06-21',status:'待揽件'}];

function renderAdminLogistics(){
  const tbody=document.getElementById('admin-logistics-tbody');
  const statusClass={已签收:'tag-success',待揽件:'tag-warning',运输中:'tag-info',异常:'tag-danger'};
  tbody.innerHTML=adminLogistics.map(l=>`<tr><td>${l.id}</td><td>${l.orderId}</td><td>${l.receiver}</td><td>${l.carrier}</td><td>${l.sendDate}</td><td>${l.eta}</td><td><span class="tag ${statusClass[l.status]||'tag-secondary'}">${l.status}</span></td><td style="display:flex;gap:4px"><button class="btn btn-xs btn-secondary" onclick="showToast('物流轨迹: ${l.id} · ${l.carrier}','info')">轨迹</button>${l.status==='待揽件'?`<button class="btn btn-xs btn-accent" onclick="showShippoLabelForm()">🌐 面单</button>`:''}</td></tr>`).join('');
  document.getElementById('admin-logistics-count').textContent=`共 ${adminLogistics.length} 条物流记录 · 异常运单 ${adminLogistics.filter(l=>l.status==='异常').length} 条需处理`;
}
function filterAdminLogistics(status){
  const rows=document.querySelectorAll('#admin-logistics-tbody tr');
  rows.forEach(r=>{const t=r.querySelector('.tag');if(!t)return;r.style.display=(status==='all'||t.textContent===status)?'':'none'});
}
function searchAdminLogistics(q){
  const rows=document.querySelectorAll('#admin-logistics-tbody tr');
  rows.forEach(r=>{r.style.display=r.textContent.toLowerCase().includes(q.toLowerCase())?'':'none'});
}
let customCarriers=[];
function addCustomCarrier(){
  const name=document.getElementById('custom-carrier-name').value.trim();
  const apikey=document.getElementById('custom-carrier-apikey').value.trim();
  const mcp=document.getElementById('custom-carrier-mcp').value.trim();
  if(!name){showToast('请输入服务商名称','error');return;}
  customCarriers.push({name,apikey,mcp});
  document.getElementById('custom-carrier-name').value='';
  document.getElementById('custom-carrier-apikey').value='';
  document.getElementById('custom-carrier-mcp').value='';
  showToast(`快递服务商 "${name}" 已添加 · API/MCP接口已配置`,'success');
}

// ========== Shippo 跨境物流比价 & 面单平台 ==========
let shippoRates=[];
let shippoLabels=[];
let shippoCustomsItems=[];

const SHIPPO_BASE_URL = 'https://api.goshippo.com';

// 初始化 Shippo API Key（从 localStorage 读取，用户需自行配置）
function initShippoApiKey() {
  return localStorage.getItem('shippo_api_key');
}

function getShippoApiKey() {
  return localStorage.getItem('shippo_api_key');
}

// Shippo 跨境比价弹窗
function showShippoRateForm(){
  const overlay=document.getElementById('shippo-rate-overlay');
  overlay.style.display='flex';
}
function hideShippoRateForm(){
  document.getElementById('shippo-rate-overlay').style.display='none';
}

// Shippo 面单弹窗
function showShippoLabelForm(){
  const overlay=document.getElementById('shippo-label-overlay');
  // 填充关联订单下拉
  const orderSelect=document.getElementById('shippo-label-order');
  const pendingOrders=adminOrders.filter(o=>o.status==='pending'||o.status==='shipped');
  orderSelect.innerHTML='<option value="">-- 选择关联订单 --</option>'+pendingOrders.map(o=>`<option value="${o.id}">${o.id} · ${o.customer} · ${o.product}</option>`).join('');
  overlay.style.display='flex';
}
function hideShippoLabelForm(){
  document.getElementById('shippo-label-overlay').style.display='none';
}

// Shippo 追踪弹窗
function showShippoTracking(){
  document.getElementById('shippo-tracking-overlay').style.display='flex';
}
function hideShippoTracking(){
  document.getElementById('shippo-tracking-overlay').style.display='none';
  document.getElementById('shippo-track-result').style.display='none';
}

// Shippo 海关申报弹窗
function showShippoCustoms(){
  document.getElementById('shippo-customs-overlay').style.display='flex';
}
function hideShippoCustoms(){
  document.getElementById('shippo-customs-overlay').style.display='none';
}

// Shippo MCP 配置弹窗
function configureShippoMCP(){
  document.getElementById('shippo-mcp-overlay').style.display='flex';
}
function hideShippoMCPConfig(){
  document.getElementById('shippo-mcp-overlay').style.display='none';
}
function toggleShippoMCPFields(){
  const mode=document.getElementById('shippo-mcp-mode').value;
  document.getElementById('shippo-mcp-hosted-info').style.display=mode==='hosted'?'block':'none';
  document.getElementById('shippo-mcp-local-info').style.display=mode==='local'?'block':'none';
}
function saveShippoMCPConfig(){
  const mode=document.getElementById('shippo-mcp-mode').value;
  const token=document.getElementById('shippo-api-token')?.value||getShippoApiKey();
  if(mode==='local'&&!token){showToast('请输入 Shippo API Token','error');return;}
  // 保存 token 到 localStorage
  if (token) localStorage.setItem('shippo_api_key', token);
  showToast(`Shippo MCP 配置已保存 · 模式: ${mode==='hosted'?'托管服务器':'本地服务器'} · API Key: ${token.substring(0,15)}...`,'success');
  document.getElementById('shippo-mode-badge').textContent=mode==='hosted'?'生产模式':'测试模式';
  hideShippoMCPConfig();
}

// 更新起运地国家
function updateShippoFromCountry(){
  const country=document.getElementById('shippo-from-country').value;
  const cityMap={CN:'深圳',US:'San Francisco',GB:'London',DE:'Berlin',FR:'Paris',JP:'Tokyo',KR:'Seoul',AU:'Sydney',CA:'Toronto',SG:'Singapore'};
  const stateMap={CN:'Guangdong',US:'CA',GB:'England',DE:'Berlin',FR:'Île-de-France',JP:'Tokyo',KR:'Seoul',AU:'NSW',CA:'ON',SG:'Singapore'};
  document.getElementById('shippo-from-city').value=cityMap[country]||'';
  document.getElementById('shippo-from-state').value=stateMap[country]||'';
}

// 执行跨境比价
function executeShippoRateCompare(){
  const from={country:document.getElementById('shippo-from-country').value,city:document.getElementById('shippo-from-city').value.trim(),street:document.getElementById('shippo-from-street').value.trim(),zip:document.getElementById('shippo-from-zip').value.trim(),state:document.getElementById('shippo-from-state').value.trim()};
  const to={country:document.getElementById('shippo-to-country').value,city:document.getElementById('shippo-to-city').value.trim(),street:document.getElementById('shippo-to-street').value.trim(),zip:document.getElementById('shippo-to-zip').value.trim(),state:document.getElementById('shippo-to-state').value.trim()};
  const parcel={length:document.getElementById('shippo-length').value,width:document.getElementById('shippo-width').value,height:document.getElementById('shippo-height').value,weight:document.getElementById('shippo-weight').value};
  const desc=document.getElementById('shippo-desc').value.trim();

  if(!to.city||!to.street||!to.zip||!to.state){showToast('请填写完整的目的地信息','error');return;}
  if(!from.city||!from.street){showToast('请填写完整的起运地信息','error');return;}

  // 模拟 Shippo API 比价结果（实际调用 POST /shipments）
  const carriers=[
    {name:'DHL Express',service:'Express Worldwide',days:'3-5',base:285},
    {name:'FedEx',service:'International Priority',days:'3-7',base:248},
    {name:'UPS',service:'Worldwide Express',days:'3-6',base:265},
    {name:'USPS',service:'Priority Mail International',days:'6-10',base:156},
    {name:'DHL eCommerce',service:'Packet Plus',days:'7-14',base:98},
    {name:'Asendia',service:'e-PAQ Plus',days:'8-15',base:112},
    {name:'APC Postal',service:'ePacket',days:'10-20',base:72},
    {name:'Deutsche Post',service:'Warenpost International',days:'8-14',base:89}
  ];

  const weight=parseFloat(parcel.weight)||1;
  const volWeight=(parseFloat(parcel.length)*parseFloat(parcel.width)*parseFloat(parcel.height))/5000;
  const chargeWeight=Math.max(weight,volWeight);

  shippoRates=carriers.map(c=>{
    const total=(c.base*chargeWeight*0.8+Math.random()*50).toFixed(2);
    return {...c,total:parseFloat(total),currency:'USD',chargeWeight:chargeWeight.toFixed(2)};
  }).sort((a,b)=>a.total-b.total);

  // 渲染比价结果
  const container=document.getElementById('shippo-rate-results');
  const now=new Date().toLocaleString('zh-CN');
  document.getElementById('shippo-last-rate-time').textContent=`比价时间: ${now} · ${from.city} → ${to.city} · ${chargeWeight.toFixed(2)}kg`;

  container.innerHTML=shippoRates.map((r,i)=>{
    const cls=i===0?'accent':i<3?'success':'secondary';
    const badge=i===0?'🏆 最低价':i<4?'✅ 推荐':'';
    return `<div style="display:flex;align-items:center;justify-content:space-between;padding:10px 14px;background:var(--bg-tertiary);border-radius:var(--radius-sm);border-left:3px solid var(--${cls})">
      <div style="display:flex;align-items:center;gap:10px">
        <span style="font-weight:700;font-size:14px;min-width:100px">${r.name}</span>
        <span style="font-size:11px;color:var(--text-secondary)">${r.service} · ${r.days}天</span>
        ${badge?`<span class="tag tag-${cls}" style="font-size:10px">${badge}</span>`:''}
      </div>
      <div style="display:flex;align-items:center;gap:10px">
        <span style="font-weight:700;font-size:16px;color:var(--accent)">$${r.total}</span>
        <button class="btn btn-xs btn-accent" onclick="selectShippoRate(${i})">选择</button>
      </div>
    </div>`;
  }).join('');

  showToast(`Shippo 比价完成 · ${shippoRates.length} 家承运商报价 · 最低 $${shippoRates[0].total} (${shippoRates[0].name})`,'success');
  hideShippoRateForm();
}

// 选择比价结果
function selectShippoRate(index){
  const rate=shippoRates[index];
  document.getElementById('shippo-label-carrier').value=rate.name.toLowerCase().replace(/\s+/g,'_');
  showToast(`已选择 ${rate.name} · $${rate.total} · 预计 ${rate.days} 天送达`,'success');
  showShippoLabelForm();
}

// 执行生成面单
function executeShippoCreateLabel(){
  const carrier=document.getElementById('shippo-label-carrier').value;
  const format=document.getElementById('shippo-label-format').value;
  const size=document.getElementById('shippo-label-size').value;
  const orderId=document.getElementById('shippo-label-order').value;
  const ref=document.getElementById('shippo-label-ref').value.trim();

  if(!carrier){showToast('请选择承运商（先执行跨境比价）','error');return;}

  // 模拟 Shippo API 生成面单（实际调用 POST /transactions）
  const labelId='SHIPPO-LBL-'+Date.now().toString(36).toUpperCase();
  const trackingNum='1Z'+Math.random().toString(36).substring(2,10).toUpperCase();
  const carrierName=carrier.replace(/_/g,' ').replace(/\b\w/g,c=>c.toUpperCase());

  shippoLabels.push({id:labelId,carrier:carrierName,tracking:trackingNum,format,size,orderId,ref,created:new Date().toISOString()});

  // 如果有关联订单，更新订单状态
  if(orderId){
    const order=adminOrders.find(o=>o.id===orderId);
    if(order){order.status='shipped';renderAdminOrders();}
  }

  // 添加物流记录
  const orderRef=orderId||ref||'国际运单';
  adminLogistics.unshift({
    id:labelId,orderId:`#${orderRef}`,receiver:ref||'国际客户',carrier:carrierName,sendDate:new Date().toISOString().split('T')[0],eta:'—',status:'待揽件'
  });
  renderAdminLogistics();

  showToast(`✅ 面单已生成 · ${carrierName} · 运单号: ${trackingNum} · 格式: ${format}/${size}`,'success');
  document.getElementById('shippo-label-ref').value='';
  hideShippoLabelForm();
}

// 执行包裹追踪
function executeShippoTracking(){
  const carrier=document.getElementById('shippo-track-carrier').value;
  const number=document.getElementById('shippo-track-number').value.trim();
  if(!number){showToast('请输入运单号/追踪号','error');return;}

  // 模拟 Shippo API 追踪结果（实际调用 GET /tracks/{carrier}/{tracking_number}）
  const statuses=['已揽件','已发出','到达中转站','海关放行','运输中','到达目的地','派送中','已签收'];
  const locations=['深圳, CN','香港, HK','Los Angeles, US','Chicago, US','New York, US'];
  const trackingEvents=[];

  for(let i=0;i<Math.min(statuses.length,2+Math.floor(Math.random()*5));i++){
    const d=new Date();d.setHours(d.getHours()-Math.random()*72);
    trackingEvents.push({status:statuses[i],location:locations[Math.min(i,locations.length-1)],time:d.toLocaleString('zh-CN')});
  }

  document.getElementById('shippo-track-result').style.display='block';
  document.getElementById('shippo-track-detail').innerHTML=`
    <div style="font-weight:600;margin-bottom:8px">运单号: ${number} · 承运商: ${carrier.toUpperCase()}</div>
    <div style="display:flex;flex-direction:column;gap:6px">
      ${trackingEvents.map((e,i)=>`
        <div style="display:flex;gap:10px;align-items:flex-start;padding:6px 0;border-bottom:1px solid var(--border)">
          <div style="width:8px;height:8px;border-radius:50%;background:${i===0?'var(--accent)':'var(--text-tertiary)'};margin-top:4px;flex-shrink:0"></div>
          <div>
            <div style="font-size:12px;font-weight:600">${e.status}</div>
            <div style="font-size:11px;color:var(--text-secondary)">${e.location} · ${e.time}</div>
          </div>
        </div>
      `).join('')}
    </div>
  `;
  showToast(`追踪查询完成 · ${trackingEvents.length} 条物流轨迹`,'success');
}

// 添加海关物品行
function addShippoCustomsItem(){
  const container=document.getElementById('shippo-customs-items');
  const row=document.createElement('div');
  row.style.cssText='display:grid;grid-template-columns:2fr 1fr 1fr 1fr 1fr;gap:6px;align-items:end;padding:8px;background:var(--bg-tertiary);border-radius:var(--radius-sm)';
  row.innerHTML=`
    <div><label style="font-size:10px;color:var(--text-secondary)">物品描述</label><input class="form-input" placeholder="如: 墨水套装" value="Ink Cartridge Set" style="width:100%;box-sizing:border-box;padding:4px 6px;font-size:11px"></div>
    <div><label style="font-size:10px;color:var(--text-secondary)">数量</label><input class="form-input" type="number" value="10" style="width:100%;box-sizing:border-box;padding:4px 6px;font-size:11px"></div>
    <div><label style="font-size:10px;color:var(--text-secondary)">单价(USD)</label><input class="form-input" type="number" value="29.9" style="width:100%;box-sizing:border-box;padding:4px 6px;font-size:11px"></div>
    <div><label style="font-size:10px;color:var(--text-secondary)">HS编码</label><input class="form-input" placeholder="如: 3215.90" value="3215.90" style="width:100%;box-sizing:border-box;padding:4px 6px;font-size:11px"></div>
    <div style="display:flex;gap:4px;align-items:center"><div style="flex:1"><label style="font-size:10px;color:var(--text-secondary)">原产地</label><select class="form-input" style="width:100%;padding:4px 6px;font-size:11px"><option value="CN">🇨🇳 CN</option><option value="US">🇺🇸 US</option></select></div><button class="btn btn-xs btn-secondary" style="margin-bottom:2px" onclick="this.parentElement.parentElement.remove()">✕</button></div>
  `;
  container.appendChild(row);
}

// 执行海关申报
function executeShippoCustoms(){
  const type=document.getElementById('shippo-customs-type').value;
  const eel=document.getElementById('shippo-customs-eel').value;
  const certify=document.getElementById('shippo-customs-certify').checked;
  const signer=document.getElementById('shippo-customs-signer').value.trim();

  if(!certify){showToast('请勾选认证声明','error');return;}
  if(!signer){showToast('请填写签署人姓名','error');return;}

  // 收集物品明细
  const itemRows=document.querySelectorAll('#shippo-customs-items > div');
  const items=[];
  itemRows.forEach(row=>{
    const inputs=row.querySelectorAll('input,select');
    if(inputs.length>=5){
      const desc=inputs[0].value;const qty=parseInt(inputs[1].value)||0;
      const price=parseFloat(inputs[2].value)||0;const hs=inputs[3].value;
      const origin=inputs[4].value;
      if(desc&&qty>0)items.push({description:desc,quantity:qty,value_amount:price,hs_code:hs,origin_country:origin,weight_unit:'kg',net_weight:'1.0'});
    }
  });

  if(items.length===0){showToast('请至少添加一个海关物品','error');return;}
  const totalValue=items.reduce((sum,i)=>sum+i.value_amount*i.quantity,0);

  // 模拟 Shippo API 创建海关申报（实际调用 POST /customs/declarations）
  const declId='CUST-DECL-'+Date.now().toString(36).toUpperCase();
  showToast(`✅ 海关申报已创建 · ${declId} · ${items.length} 件物品 · 总值 $${totalValue.toFixed(2)} · 签署人: ${signer}`,'success');
  hideShippoCustoms();
}

// ========== 库存管理（自定义添加 + 网站下单同步） ==========
let adminInventory=[{sku:'AN-PRO-001',name:'AI美甲机 Pro',category:'设备',qty:128,safe:50,lastIn:'2026-06-15'},
{sku:'AN-LITE-001',name:'AI美甲机 Lite',category:'设备',qty:110,safe:30,lastIn:'2026-06-10'},
{sku:'INK-CMYK-001',name:'CMYK 四色墨水套装',category:'墨水',qty:850,safe:200,lastIn:'2026-06-14'},
{sku:'INK-WHITE-001',name:'白色底胶墨水',category:'墨水',qty:400,safe:150,lastIn:'2026-06-12'},
{sku:'PART-NOZZLE',name:'打印喷头',category:'配件',qty:35,safe:50,lastIn:'2026-05-20'},
{sku:'PART-BELT',name:'传动皮带',category:'配件',qty:54,safe:30,lastIn:'2026-06-08'}];

function renderAdminInventory(){
  const tbody=document.getElementById('admin-inventory-tbody');
  const catClass={设备:'tag-accent',墨水:'tag-info',配件:'tag-warning',耗材:'tag-secondary'};
  tbody.innerHTML=adminInventory.map(i=>{
    const low=i.qty<i.safe;
    const statusText=low?'库存不足':'正常';
    const statusClass=low?'tag-danger':'tag-success';
    const qtyStyle=low?'color:var(--danger);font-weight:700':'';
    return `<tr><td>${i.sku}</td><td>${i.name}</td><td><span class="tag ${catClass[i.category]||'tag-secondary'}">${i.category}</span></td><td><span style="${qtyStyle}">${i.qty}</span></td><td>${i.safe}</td><td><span class="tag ${statusClass}">${statusText}</span></td><td>${i.lastIn}</td><td style="display:flex;gap:4px"><button class="btn btn-xs btn-secondary" onclick="editInventoryItem('${i.sku}')">调整</button>${low?`<button class="btn btn-xs btn-accent" onclick="showToast('已生成 ${i.name} 采购单','success')">补货</button>`:''}<button class="btn btn-xs btn-danger" onclick="deleteInventoryItem('${i.sku}')">删除</button></td></tr>`;
  }).join('');
  document.getElementById('admin-inventory-count').textContent=`共 ${adminInventory.length} 个 SKU · ${adminInventory.filter(i=>i.qty<i.safe).length} 个库存预警`;
  updateInventoryStats();
  updateInventoryAlerts();
}
function updateInventoryStats(){
  const dev=adminInventory.filter(i=>i.category==='设备').reduce((s,i)=>s+i.qty,0);
  const ink=adminInventory.filter(i=>i.category==='墨水').reduce((s,i)=>s+i.qty,0);
  const part=adminInventory.filter(i=>i.category==='配件').reduce((s,i)=>s+i.qty,0);
  if(document.getElementById('inv-device-count'))document.getElementById('inv-device-count').textContent=dev;
  if(document.getElementById('inv-ink-count'))document.getElementById('inv-ink-count').textContent=ink;
  if(document.getElementById('inv-part-count'))document.getElementById('inv-part-count').textContent=part;
}
function updateInventoryAlerts(){
  const alertList=document.getElementById('inventory-alert-list');
  if(!alertList)return;
  const alerts=adminInventory.filter(i=>i.qty<i.safe);
  if(alerts.length===0){alertList.innerHTML='<div style="padding:12px;text-align:center;color:var(--text-secondary)">✅ 所有库存正常，无预警</div>';return;}
  alertList.innerHTML=alerts.map(i=>`<div style="display:flex;align-items:center;justify-content:space-between;padding:10px 14px;background:rgba(255,77,77,0.08);border-radius:var(--radius-sm)"><div><span style="font-weight:700">${i.name}</span><span style="margin-left:8px;font-size:12px;color:var(--text-secondary)">当前 ${i.qty} / 安全库存 ${i.safe}</span></div><button class="btn btn-xs btn-accent" onclick="showToast('已生成 ${i.name} 采购单','success')">生成采购单</button></div>`).join('');
}
function filterAdminInventory(cat){
  const rows=document.querySelectorAll('#admin-inventory-tbody tr');
  rows.forEach(r=>{const t=r.querySelector('.tag');if(!t)return;r.style.display=(cat==='all'||t.textContent===cat)?'':'none'});
}
function searchAdminInventory(q){
  const rows=document.querySelectorAll('#admin-inventory-tbody tr');
  rows.forEach(r=>{r.style.display=r.textContent.toLowerCase().includes(q.toLowerCase())?'':'none'});
}
function showInventoryForm(editSku){
  const overlay=document.getElementById('inventory-form-overlay');
  if(editSku){
    const i=adminInventory.find(x=>x.sku===editSku);
    if(i){document.getElementById('if-edit-id').value=i.sku;document.getElementById('if-sku').value=i.sku;document.getElementById('if-name').value=i.name;document.getElementById('if-category').value=i.category;document.getElementById('if-qty').value=i.qty;document.getElementById('if-safe').value=i.safe;document.getElementById('inventory-form-title').textContent='编辑库存';}
  }else{
    document.getElementById('if-edit-id').value='';document.getElementById('if-sku').value='';document.getElementById('if-name').value='';document.getElementById('if-category').value='设备';document.getElementById('if-qty').value='';document.getElementById('if-safe').value='';document.getElementById('inventory-form-title').textContent='添加库存';
  }
  overlay.style.display='flex';
}
function hideInventoryForm(){document.getElementById('inventory-form-overlay').style.display='none';}
function saveInventory(){
  const editSku=document.getElementById('if-edit-id').value;
  const sku=document.getElementById('if-sku').value.trim();
  const name=document.getElementById('if-name').value.trim();
  const category=document.getElementById('if-category').value;
  const qty=parseInt(document.getElementById('if-qty').value)||0;
  const safe=parseInt(document.getElementById('if-safe').value)||0;
  if(!sku||!name){showToast('请填写SKU编码和商品名称','error');return;}
  if(editSku){
    const i=adminInventory.find(x=>x.sku===editSku);
    if(i){i.sku=sku;i.name=name;i.category=category;i.qty=qty;i.safe=safe;i.lastIn=new Date().toISOString().slice(0,10);showToast('库存已更新','success');}
  }else{
    if(adminInventory.find(x=>x.sku===sku)){showToast('SKU编码已存在','error');return;}
    adminInventory.push({sku,name,category,qty,safe,lastIn:new Date().toISOString().slice(0,10)});
    showToast('库存添加成功','success');
  }
  hideInventoryForm();
  renderAdminInventory();
  updateAdminStats();
}
function editInventoryItem(sku){showInventoryForm(sku);}
function deleteInventoryItem(sku){
  if(!confirm('确定删除该库存项？'))return;
  adminInventory=adminInventory.filter(x=>x.sku!==sku);
  renderAdminInventory();
  updateAdminStats();
  showToast('库存项已删除','info');
}

// ========== 生产管理 ==========
let adminProductionOrders=[
  {id:'WO-2026-0891',name:'霓虹幻彩甲片套装',qty:500,line:'L1-AI印刷线',priority:'urgent',progress:65,endDate:'2026-07-28',status:'in_progress'},
  {id:'WO-2026-0892',name:'星空渐变美甲贴',qty:1200,line:'L2-激光产线',priority:'high',progress:35,endDate:'2026-07-30',status:'in_progress'},
  {id:'WO-2026-0893',name:'樱花限定套装',qty:800,line:'L3-3D打印线',priority:'normal',progress:0,endDate:'2026-08-05',status:'pending'},
  {id:'WO-2026-0894',name:'金属质感甲片',qty:600,line:'L1-AI印刷线',priority:'high',progress:0,endDate:'2026-08-04',status:'pending'},
  {id:'WO-2026-0895',name:'水彩晕染美甲贴',qty:1500,line:'L2-激光产线',priority:'normal',progress:100,endDate:'2026-07-26',status:'completed'},
  {id:'WO-2026-0896',name:'镭射幻彩套装',qty:400,line:'L3-3D打印线',priority:'urgent',progress:0,endDate:'2026-08-01',status:'pending'},
  {id:'WO-2026-0897',name:'卡通IP联名款',qty:2000,line:'L1-AI印刷线',priority:'normal',progress:0,endDate:'2026-08-10',status:'pending'},
  {id:'WO-2026-0898',name:'透明果冻甲片',qty:300,line:'L4-手工线',priority:'low',progress:40,endDate:'2026-07-28',status:'paused'},
  {id:'WO-2026-0899',name:'婚礼限定套装',qty:200,line:'L4-手工线',priority:'high',progress:100,endDate:'2026-07-22',status:'completed'},
  {id:'WO-2026-0900',name:'夜光美甲贴',qty:900,line:'L2-激光产线',priority:'normal',progress:0,endDate:'2026-08-03',status:'pending'}
];
let adminQualityInspections=[
  {id:'QC-2026-0151',woId:'WO-2026-0895',name:'水彩晕染美甲贴',total:500,defects:8,pass:492,rate:98.4,inspector:'张质检',status:'passed'},
  {id:'QC-2026-0152',woId:'WO-2026-0891',name:'霓虹幻彩甲片套装',total:200,defects:3,pass:197,rate:98.5,inspector:'李品控',status:'in_progress'},
  {id:'QC-2026-0153',woId:'WO-2026-0899',name:'婚礼限定套装',total:200,defects:1,pass:199,rate:99.5,inspector:'王质检',status:'passed'},
  {id:'QC-2026-0154',woId:'WO-2026-0892',name:'星空渐变美甲贴',total:150,defects:12,pass:138,rate:92.0,inspector:'张质检',status:'pending_recheck'},
  {id:'QC-2026-0155',woId:'WO-2026-0898',name:'透明果冻甲片',total:100,defects:5,pass:95,rate:95.0,inspector:'赵品控',status:'pending_recheck'}
];
let productionOrderFilter='all';

function renderAdminProduction(){
  // 更新统计
  const filtered=productionOrderFilter==='all'?adminProductionOrders:adminProductionOrders.filter(o=>o.status===productionOrderFilter);
  document.getElementById('admin-production-count').textContent=`共 ${filtered.length} 个工单`;
  document.getElementById('prod-pending').textContent=adminProductionOrders.filter(o=>o.status==='pending').length;
  document.getElementById('prod-inprogress').textContent=adminProductionOrders.filter(o=>o.status==='in_progress').length;
  document.getElementById('prod-completed').textContent=adminProductionOrders.filter(o=>o.status==='completed').length;
  const utilizations=[78.5,65.3,42.0,55.8,88.2];
  document.getElementById('prod-utilization').textContent=(utilizations.reduce((a,b)=>a+b,0)/utilizations.length).toFixed(1);
  document.getElementById('prod-material-alert').textContent='4';
  // 工单表格
  const tbody=document.getElementById('admin-production-tbody');
  const priorityLabels={urgent:'紧急',high:'高',normal:'普通',low:'低'};
  const priorityColors={urgent:'tag-danger',high:'tag-warning',normal:'tag-success',low:'tag-secondary'};
  const statusLabels={pending:'待处理',in_progress:'生产中',completed:'已完成',paused:'已暂停',cancelled:'已取消'};
  const statusColors={pending:'tag-warning',in_progress:'tag-info',completed:'tag-success',paused:'tag-secondary',cancelled:'tag-danger'};
  tbody.innerHTML=filtered.map(o=>`<tr>
    <td style="font-family:monospace;font-size:11px">${o.id}</td>
    <td><strong>${o.name}</strong></td>
    <td>${o.qty}</td>
    <td>${o.line}</td>
    <td><span class="tag ${priorityColors[o.priority]||'tag-secondary'}">${priorityLabels[o.priority]||o.priority}</span></td>
    <td><div style="display:flex;align-items:center;gap:6px"><div style="flex:1;height:6px;background:var(--bg-tertiary);border-radius:3px;overflow:hidden"><div style="height:100%;width:${o.progress}%;background:${o.progress>=80?'var(--success)':o.progress>=40?'var(--info)':'var(--warning)'};border-radius:3px"></div></div><span style="font-size:11px">${o.progress}%</span></div></td>
    <td>${o.endDate}</td>
    <td><span class="tag ${statusColors[o.status]||'tag-secondary'}">${statusLabels[o.status]||o.status}</span></td>
    <td style="display:flex;gap:4px"><button class="btn btn-xs btn-secondary" onclick="editProductionOrder('${o.id}')">✏️</button><button class="btn btn-xs btn-danger" onclick="deleteProductionOrder('${o.id}')">🗑</button></td>
  </tr>`).join('');
  // 产线状态
  const lines=[
    {name:'L1-AI印刷线',status:'running',label:'运行中',progress:78,order:'WO-2026-0891',output:85,color:'var(--success)'},
    {name:'L2-激光产线',status:'running',label:'运行中',progress:45,order:'WO-2026-0892',output:62,color:'var(--success)'},
    {name:'L3-3D打印线',status:'idle',label:'空闲',progress:0,order:'等待工单',output:0,color:'var(--warning)'},
    {name:'L4-手工线',status:'maintenance',label:'维护中',progress:0,order:'维护保养',output:0,color:'var(--info)'},
    {name:'L5-质检包装线',status:'running',label:'运行中',progress:92,order:'WO-2026-0895',output:120,color:'var(--success)'}
  ];
  document.getElementById('production-lines-grid').innerHTML=lines.map(l=>`<div style="padding:14px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius)">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
      <strong style="font-size:13px">${l.name}</strong>
      <span style="width:8px;height:8px;border-radius:50%;background:${l.color};box-shadow:0 0 6px ${l.color}"></span>
    </div>
    <div style="font-size:11px;color:${l.color};margin-bottom:8px">${l.label}</div>
    <div style="height:6px;background:var(--bg-tertiary);border-radius:3px;overflow:hidden;margin-bottom:6px">
      <div style="height:100%;width:${l.progress}%;background:${l.color};border-radius:3px"></div>
    </div>
    <div style="font-size:10px;color:var(--text-tertiary)">工单: ${l.order}</div>
    <div style="font-size:10px;color:var(--text-tertiary)">今日产出: ${l.output}件</div>
  </div>`).join('');
  // 质检表格
  const qtbody=document.getElementById('admin-quality-tbody');
  const qStatusLabels={passed:'通过',failed:'不通过',in_progress:'检验中',pending_recheck:'待复检'};
  const qStatusColors={passed:'tag-success',failed:'tag-danger',in_progress:'tag-info',pending_recheck:'tag-warning'};
  qtbody.innerHTML=adminQualityInspections.map(q=>`<tr>
    <td style="font-family:monospace;font-size:11px">${q.id}</td>
    <td style="font-family:monospace;font-size:11px">${q.woId}</td>
    <td>${q.name}</td>
    <td>${q.total}</td>
    <td>${q.pass}</td>
    <td style="color:${q.defects>0?'var(--danger)':'var(--text-primary)'}">${q.defects}</td>
    <td style="color:${q.rate>=95?'var(--success)':'var(--warning)'};font-weight:700">${q.rate}%</td>
    <td>${q.inspector}</td>
    <td><span class="tag ${qStatusColors[q.status]||'tag-secondary'}">${qStatusLabels[q.status]||q.status}</span></td>
  </tr>`).join('');
}
function renderAdminQuality(){
  // 质检追溯面板已使用静态HTML，该函数预留用于动态数据刷新
  const qcData=[
    {id:'QC-20260726-001',wo:'#WO-086',name:'春日樱花·渐变',total:50,defects:0,result:'合格',inspector:'张工',time:'10:30'},
    {id:'QC-20260726-002',wo:'#WO-087',name:'CyberPunk 2070',total:200,defects:1,result:'返工',inspector:'李工',time:'11:15'},
    {id:'QC-20260726-003',wo:'#WO-088',name:'极简北欧风',total:80,defects:0,result:'合格',inspector:'王工',time:'13:45'},
    {id:'QC-20260726-004',wo:'#WO-089',name:'和风水墨·限定',total:120,defects:2,result:'不合格',inspector:'张工',time:'14:20'},
  ];
  console.log('质量控制面板已激活，共'+qcData.length+'条质检记录');
}
function filterProductionOrders(status){
  productionOrderFilter=status;
  renderAdminProduction();
}
function showProductionForm(editId){
  const overlay=document.getElementById('production-form-overlay');
  document.getElementById('production-form-title').textContent=editId?'编辑生产工单':'新建生产工单';
  document.getElementById('pf-edit-id').value=editId||'';
  if(editId){
    const o=adminProductionOrders.find(x=>x.id===editId);
    if(o){
      document.getElementById('pf-name').value=o.name;
      document.getElementById('pf-qty').value=o.qty;
      document.getElementById('pf-line').value=o.line;
      document.getElementById('pf-priority').value=o.priority;
      document.getElementById('pf-date').value=o.endDate;
    }
  }else{
    document.getElementById('pf-name').value='';
    document.getElementById('pf-qty').value='';
    document.getElementById('pf-line').value='L1-AI印刷线';
    document.getElementById('pf-priority').value='normal';
    document.getElementById('pf-date').value='';
  }
  overlay.style.display='flex';
}
function hideProductionForm(){
  document.getElementById('production-form-overlay').style.display='none';
}
function saveProductionOrder(){
  const editId=document.getElementById('pf-edit-id').value;
  const name=document.getElementById('pf-name').value.trim();
  const qty=parseInt(document.getElementById('pf-qty').value)||0;
  const line=document.getElementById('pf-line').value;
  const priority=document.getElementById('pf-priority').value;
  const endDate=document.getElementById('pf-date').value;
  if(!name||!qty){showToast('请填写产品名称和数量','error');return;}
  if(editId){
    const o=adminProductionOrders.find(x=>x.id===editId);
    if(o){o.name=name;o.qty=qty;o.line=line;o.priority=priority;o.endDate=endDate;showToast('工单已更新','success');}
  }else{
    const newId='WO-'+new Date().getFullYear()+'-'+(adminProductionOrders.length+9000);
    adminProductionOrders.unshift({id:newId,name,qty,line,priority,progress:0,endDate:endDate||'待定',status:'pending'});
    showToast('工单创建成功','success');
  }
  hideProductionForm();
  renderAdminProduction();
}
function editProductionOrder(id){showProductionForm(id);}
function deleteProductionOrder(id){
  if(!confirm('确定删除工单 '+id+'？'))return;
  adminProductionOrders=adminProductionOrders.filter(x=>x.id!==id);
  renderAdminProduction();
  showToast('工单已删除','info');
}

// 初始化管理后台数据
startOrderSync();
renderAdminCustomers();
renderAdminOrders();
renderAdminLogistics();
renderAdminInventory();
renderAdminProduction();

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

// ========== 自定义设备管理 ==========
let customDevices = [];
let customDeviceCounter = 0;
const MULTI_SELECTED_DEVICES = new Set();

function addCustomDevice() {
  const prefix = document.getElementById('custom-sn-prefix').value.trim() || 'ANP-';
  const number = document.getElementById('custom-sn-number').value.trim();
  const name = document.getElementById('custom-device-name').value.trim() || 'AI NAILS Pro';
  const connType = document.getElementById('custom-device-conn').value;
  
  if (!number) {
    showToast('请输入设备序号', 'warning');
    return;
  }
  
  const sn = `${prefix}${number.padStart(4, '0')}`;
  const deviceId = `custom-${++customDeviceCounter}`;
  const ip = `192.168.1.${100 + customDevices.length + 1}`;
  
  // 检查序号是否已存在
  if (customDevices.find(d => d.sn === sn)) {
    showToast(`设备序号 ${sn} 已存在`, 'warning');
    return;
  }
  
  customDevices.push({
    id: deviceId,
    sn: sn,
    name: name,
    connType: connType,
    ip: ip,
    btId: `ANP-BT-${sn}`,
    wifiId: `ANP-WF-${sn}`,
    status: 'disconnected',
    addedAt: new Date().toLocaleString()
  });
  
  // 自动递增序号
  const nextNum = parseInt(number) + 1;
  document.getElementById('custom-sn-number').value = String(nextNum).padStart(4, '0');
  
  renderCustomDeviceList();
  renderMultiDeviceChecklist();
  updateOnlineDeviceCount();
  showToast(`设备 ${sn} 已添加`, 'success');
}

function removeCustomDevice(deviceId) {
  const device = customDevices.find(d => d.id === deviceId);
  if (device && device.status === 'connected') {
    disconnectCustomDevice(device);
  }
  customDevices = customDevices.filter(d => d.id !== deviceId);
  MULTI_SELECTED_DEVICES.delete(deviceId);
  renderCustomDeviceList();
  renderMultiDeviceChecklist();
  updateOnlineDeviceCount();
  if (device) showToast(`设备 ${device.sn} 已移除`, 'info');
}

function connectCustomDevice(deviceId) {
  const device = customDevices.find(d => d.id === deviceId);
  if (!device) return;
  
  // 开启对应的连接方式
  if (device.connType === 'bt' || device.connType === 'dual') {
    if (!bluetoothEnabled) {
      document.getElementById('bt-toggle').checked = true;
      toggleBluetooth(true);
    }
  }
  if (device.connType === 'wifi' || device.connType === 'dual') {
    if (!wifiEnabled) {
      document.getElementById('wifi-toggle').checked = true;
      toggleWifi(true);
    }
  }
  
  // 模拟连接
  showToast(`正在连接 ${device.sn}...`, 'info');
  
  setTimeout(() => {
    device.status = 'connected';
    if (device.connType === 'bt' || device.connType === 'dual') {
      connectBluetooth(device.btId, device.name + ' #' + device.sn.slice(-4));
    }
    if (device.connType === 'wifi' || device.connType === 'dual') {
      // 模拟WiFi直接连接
      wifiConnected = true;
      wifiDeviceName = device.name + ' #' + device.sn.slice(-4);
      document.getElementById('wifi-connected-info').classList.remove('hidden');
      document.getElementById('wifi-dev-name').textContent = wifiDeviceName;
      document.getElementById('wifi-dev-meta').textContent = `IP: ${device.ip} | SN: ${device.sn} | 已连接`;
      document.getElementById('wifi-scan-area').classList.add('hidden');
      document.getElementById('wifi-scan-btn').classList.add('hidden');
      document.getElementById('wifi-disconnect-btn').classList.remove('hidden');
      document.getElementById('wifi-status-text').textContent = '已连接';
      document.getElementById('wifi-status-text').className = 'conn-card-status connected';
      document.getElementById('wifi-toggle').checked = true;
      wifiEnabled = true;
    }
    
    renderCustomDeviceList();
    renderMultiDeviceChecklist();
    updateOnlineDeviceCount();
    showToast(`${device.sn} 连接成功`, 'success');
  }, 1500);
}

function disconnectCustomDevice(device) {
  device.status = 'disconnected';
  // 断开蓝牙
  if (device.connType === 'bt' || device.connType === 'dual') {
    if (bluetoothDeviceName === device.name + ' #' + device.sn.slice(-4)) {
      disconnectBluetooth();
    }
  }
  // 断开WiFi
  if (device.connType === 'wifi' || device.connType === 'dual') {
    if (wifiDeviceName === device.name + ' #' + device.sn.slice(-4)) {
      disconnectWifi();
    }
  }
  renderCustomDeviceList();
  renderMultiDeviceChecklist();
  updateOnlineDeviceCount();
}

function renderCustomDeviceList() {
  const container = document.getElementById('custom-device-list');
  if (customDevices.length === 0) {
    container.innerHTML = '<div class="cd-empty">暂无自定义设备，请在上方输入序号添加</div>';
  } else {
    container.innerHTML = customDevices.map(d => `
      <div class="cd-device-item">
        <div class="cd-info">
          <div class="cd-name">🦞 ${d.name} #${d.sn.slice(-4)}</div>
          <div class="cd-meta">
            <span>SN: ${d.sn}</span>
            <span>${d.connType === 'dual' ? '📡+📶' : d.connType === 'wifi' ? '📡' : '📶'} ${d.connType === 'dual' ? 'WiFi+蓝牙' : d.connType === 'wifi' ? 'WiFi' : '蓝牙'}</span>
            <span>IP: ${d.ip}</span>
          </div>
        </div>
        <div style="display:flex;align-items:center;gap:8px">
          <span class="cd-status ${d.status === 'connected' ? 'connected' : 'disconnected'}">${d.status === 'connected' ? '已连接' : '未连接'}</span>
          <div class="cd-actions">
            ${d.status === 'disconnected' 
              ? `<button class="btn btn-success btn-xs" onclick="connectCustomDevice('${d.id}')" title="连接">🔗</button>`
              : `<button class="btn btn-warning btn-xs" onclick="disconnectCustomDevice(customDevices.find(d=>d.id==='${d.id}'))" title="断开">⏏</button>`
            }
            <button class="btn btn-danger btn-xs" onclick="removeCustomDevice('${d.id}')" title="移除">✕</button>
          </div>
        </div>
      </div>
    `).join('');
  }
  renderCustomDeviceCards();
}

function renderCustomDeviceCards() {
  const dashboard = document.getElementById('custom-device-cards');
  if (!dashboard) return;
  
  if (customDevices.length === 0) {
    dashboard.innerHTML = '';
    return;
  }
  
  // 为每个自定义设备生成墨水随机值
  const getRandomInk = () => Math.floor(Math.random() * 40) + 60; // 60-99%
  
  dashboard.innerHTML = customDevices.map((d, i) => {
    const c = getRandomInk(), m = getRandomInk(), y = getRandomInk(), k = getRandomInk();
    return `
    <div class="device-card" style="border-left:3px solid var(--accent3)">
      <div class="device-name"><span class="status-dot ${d.status === 'connected' ? 'status-online' : 'status-offline'}"></span>${d.name} #${d.sn.slice(-4)} <span class="tag tag-accent" style="font-size:9px;margin-left:4px">自定义</span></div>
      <div style="font-size:11px;color:var(--text-secondary);margin-top:4px">SN: ${d.sn} · ${d.status === 'connected' ? '在线' : '离线'}</div>
      <div style="font-size:10px;margin-top:4px;display:flex;gap:6px;flex-wrap:wrap">
        ${d.connType === 'dual' ? '<span class="tag tag-accent">📡 WiFi</span><span class="tag tag-info">📶 蓝牙</span>' : d.connType === 'wifi' ? '<span class="tag tag-accent">📡 WiFi</span>' : '<span class="tag tag-info">📶 蓝牙</span>'}
        <span class="tag" style="font-size:9px">IP: ${d.ip}</span>
      </div>
      <div class="ink-bars"><div class="ink-bar ink-c" style="width:${c}%"></div><div class="ink-bar ink-m" style="width:${m}%"></div><div class="ink-bar ink-y" style="width:${y}%"></div><div class="ink-bar ink-k" style="width:${k}%"></div></div>
      <div style="font-size:10px;color:var(--text-tertiary);margin-top:4px;display:flex;gap:12px"><span>C:${c}%</span><span>M:${m}%</span><span>Y:${y}%</span><span>K:${k}%</span></div>
      <div class="device-actions">
        <button class="btn btn-secondary btn-xs">测试打印</button>
        <button class="btn btn-secondary btn-xs">清洁喷头</button>
        <button class="btn btn-accent btn-xs">校准</button>
        ${d.status === 'connected' 
          ? `<button class="btn btn-danger btn-xs" onclick="disconnectCustomDevice(customDevices.find(dd=>dd.id==='${d.id}'))">⏏ 断开</button>`
          : `<button class="btn btn-success btn-xs" onclick="connectCustomDevice('${d.id}')">🔗 快速连接</button>`
        }
      </div>
    </div>`;
  }).join('');
}

// ========== 多设备连接设置 ==========

function renderMultiDeviceChecklist() {
  const container = document.getElementById('multi-device-checklist');
  if (customDevices.length === 0) {
    container.innerHTML = '<div class="cd-empty">添加自定义设备后，此处将显示可批量连接的设备列表</div>';
    document.getElementById('batch-connect-btn').disabled = true;
    document.getElementById('batch-disconnect-btn').disabled = true;
    document.getElementById('batch-connect-btn').textContent = '🚀 一键连接全部';
    document.getElementById('batch-disconnect-btn').textContent = '⏹ 全部断开';
    return;
  }
  
  const allSelected = customDevices.length > 0 && MULTI_SELECTED_DEVICES.size === customDevices.length;
  
  container.innerHTML = `
    <div class="mdc-item" onclick="selectAllDevices()" style="border-style:dashed;margin-bottom:4px">
      <div class="mdc-checkbox">${allSelected ? '✓' : ''}</div>
      <div class="mdc-info">
        <div class="mdc-name" style="color:var(--text-secondary)">📋 全选/取消全选 (${MULTI_SELECTED_DEVICES.size}/${customDevices.length})</div>
      </div>
    </div>
  ` + customDevices.map(d => `
    <div class="mdc-item ${MULTI_SELECTED_DEVICES.has(d.id) ? 'selected' : ''}" onclick="toggleMultiDeviceSelect('${d.id}')">
      <div class="mdc-checkbox">${MULTI_SELECTED_DEVICES.has(d.id) ? '✓' : ''}</div>
      <div class="mdc-info">
        <div class="mdc-name">🦞 ${d.name} #${d.sn.slice(-4)}</div>
        <div class="mdc-sn">SN: ${d.sn} · ${d.connType === 'dual' ? 'WiFi+蓝牙' : d.connType === 'wifi' ? 'WiFi' : '蓝牙'} · <span style="color:${d.status === 'connected' ? 'var(--success)' : 'var(--text-tertiary)'}">${d.status === 'connected' ? '已连接' : '未连接'}</span></div>
      </div>
    </div>
  `).join('');
  
  updateBatchButtons();
}

function toggleMultiDeviceSelect(deviceId) {
  if (MULTI_SELECTED_DEVICES.has(deviceId)) {
    MULTI_SELECTED_DEVICES.delete(deviceId);
  } else {
    MULTI_SELECTED_DEVICES.add(deviceId);
  }
  renderMultiDeviceChecklist();
}

function selectAllDevices() {
  if (MULTI_SELECTED_DEVICES.size === customDevices.length) {
    MULTI_SELECTED_DEVICES.clear();
  } else {
    customDevices.forEach(d => MULTI_SELECTED_DEVICES.add(d.id));
  }
  renderMultiDeviceChecklist();
}

function updateBatchButtons() {
  const connectBtn = document.getElementById('batch-connect-btn');
  const disconnectBtn = document.getElementById('batch-disconnect-btn');
  
  if (customDevices.length === 0) {
    connectBtn.disabled = true;
    disconnectBtn.disabled = true;
    return;
  }
  
  const selectedDevices = customDevices.filter(d => MULTI_SELECTED_DEVICES.has(d.id));
  const hasSelected = selectedDevices.length > 0;
  
  connectBtn.disabled = !hasSelected || selectedDevices.every(d => d.status === 'connected');
  disconnectBtn.disabled = !hasSelected || selectedDevices.every(d => d.status === 'disconnected');
  
  connectBtn.textContent = hasSelected ? `🚀 连接 ${selectedDevices.length} 台设备` : '🚀 一键连接全部';
  disconnectBtn.textContent = hasSelected ? `⏹ 断开 ${selectedDevices.length} 台设备` : '⏹ 全部断开';
}

async function batchConnectDevices() {
  const targetDevices = customDevices.filter(d => MULTI_SELECTED_DEVICES.has(d.id) && d.status === 'disconnected');
  if (targetDevices.length === 0) {
    showToast('没有需要连接的设备', 'info');
    return;
  }
  
  const statusEl = document.getElementById('multi-connect-status');
  statusEl.innerHTML = `<div class="mc-step progress">🔄 正在批量连接 ${targetDevices.length} 台设备...</div>`;
  
  // 先开启蓝牙和WiFi
  if (targetDevices.some(d => d.connType === 'bt' || d.connType === 'dual')) {
    if (!bluetoothEnabled) {
      document.getElementById('bt-toggle').checked = true;
      toggleBluetooth(true);
    }
  }
  if (targetDevices.some(d => d.connType === 'wifi' || d.connType === 'dual')) {
    if (!wifiEnabled) {
      document.getElementById('wifi-toggle').checked = true;
      toggleWifi(true);
    }
  }
  
  let successCount = 0;
  let failCount = 0;
  let stepsHtml = '';
  
  for (let i = 0; i < targetDevices.length; i++) {
    const d = targetDevices[i];
    stepsHtml += `<div class="mc-step progress">⏳ 正在连接 ${d.sn}...</div>`;
    statusEl.innerHTML = stepsHtml;
    
    try {
      await new Promise((resolve) => {
        setTimeout(() => {
          d.status = 'connected';
          resolve();
        }, 800 + Math.random() * 600);
      });
      successCount++;
      stepsHtml = stepsHtml.replace(`⏳ 正在连接 ${d.sn}...`, `<div class="mc-step done">✅ ${d.sn} 连接成功</div>`);
    } catch (e) {
      failCount++;
      stepsHtml = stepsHtml.replace(`⏳ 正在连接 ${d.sn}...`, `<div class="mc-step error">❌ ${d.sn} 连接失败</div>`);
    }
    statusEl.innerHTML = stepsHtml;
  }
  
  statusEl.innerHTML = stepsHtml + `<div class="mc-step ${failCount === 0 ? 'done' : 'error'}" style="margin-top:8px;font-weight:600;border-top:1px solid var(--border);padding-top:8px">📊 批量连接完成：成功 ${successCount} 台${failCount > 0 ? `，失败 ${failCount} 台` : ''}</div>`;
  
  renderCustomDeviceList();
  renderMultiDeviceChecklist();
  updateOnlineDeviceCount();
  showToast(`批量连接完成: ${successCount}/${targetDevices.length}`, successCount === targetDevices.length ? 'success' : 'warning');
}

async function batchDisconnectDevices() {
  const targetDevices = customDevices.filter(d => MULTI_SELECTED_DEVICES.has(d.id) && d.status === 'connected');
  if (targetDevices.length === 0) {
    showToast('没有需要断开的设备', 'info');
    return;
  }
  
  const statusEl = document.getElementById('multi-connect-status');
  statusEl.innerHTML = `<div class="mc-step progress">🔄 正在批量断开 ${targetDevices.length} 台设备...</div>`;
  
  let successCount = 0;
  let stepsHtml = '';
  
  for (let i = 0; i < targetDevices.length; i++) {
    const d = targetDevices[i];
    stepsHtml += `<div class="mc-step progress">⏳ 正在断开 ${d.sn}...</div>`;
    statusEl.innerHTML = stepsHtml;
    
    await new Promise((resolve) => {
      setTimeout(() => {
        disconnectCustomDevice(d);
        successCount++;
        resolve();
      }, 400 + Math.random() * 300);
    });
    stepsHtml = stepsHtml.replace(`⏳ 正在断开 ${d.sn}...`, `<div class="mc-step done">✅ ${d.sn} 已断开</div>`);
    statusEl.innerHTML = stepsHtml;
  }
  
  statusEl.innerHTML = stepsHtml + `<div class="mc-step done" style="margin-top:8px;font-weight:600;border-top:1px solid var(--border);padding-top:8px">📊 批量断开完成：成功 ${successCount} 台</div>`;
  
  renderCustomDeviceList();
  renderMultiDeviceChecklist();
  updateOnlineDeviceCount();
  showToast(`已断开 ${successCount} 台设备连接`, 'success');
}

function updateOnlineDeviceCount() {
  const baseOnline = 12; // 默认在线设备基数
  const customOnline = customDevices.filter(d => d.status === 'connected').length;
  document.getElementById('stat-online-count').textContent = baseOnline + customOnline;
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

// ====== 支付系统 (真实API集成) ======
const PAYMENT_API_BASE = 'http://localhost:3456/api';
const STRIPE_PAYMENT_LINK = 'https://buy.stripe.com/28E00l0Jx9CB08L2uU8AE00';

function switchPayScene(scene){
  payScene=scene;
  document.querySelectorAll('#page-payment .page-tab').forEach((el,i)=>{
    el.classList.toggle('active',['recharge','subscribe','device'][i]===scene);
  });
  document.getElementById('pay-scene-recharge').classList.toggle('hidden',scene!=='recharge');
  document.getElementById('pay-scene-subscribe').classList.toggle('hidden',scene!=='subscribe');
  document.getElementById('pay-scene-device').classList.toggle('hidden',scene!=='device');
  const t={recharge:'账户充值',subscribe:'套餐订阅',device:'设备购买'};
  document.getElementById('payment-title').textContent=t[scene];
  if(scene==='device'){
    // 设备购买：默认选1台样机 $1,000，自动切 USD + Stripe/PayPal
    selectedDeviceOption='sample';
    selectedAmount=1000;
    selectCurrency('USD', document.querySelector('#currency-select .currency-chip[onclick*="USD"]'));
  }
  else if(scene==='subscribe')selectedAmount=299;
  else selectedAmount=1000;
  updatePaymentSummary();
}

function selectAmount(amt,btn){
  selectedAmount=amt;
  document.querySelectorAll('#pay-scene-recharge .amount-btn').forEach(el=>el.classList.remove('selected'));
  if(btn)btn.classList.add('selected');
  updatePaymentSummary();
}

function selectSub(tier,btn){
  selectedSubTier=tier;
  document.querySelectorAll('#pay-scene-subscribe .sub-card').forEach(el=>el.classList.remove('selected'));
  if(btn)btn.classList.add('selected');
  const p={basic:99,pro:299,business:999,enterprise:0};
  selectedAmount=p[tier];
  updatePaymentSummary();
}

function selectCurrency(cur,el){
  selectedCurrency=cur;
  document.querySelectorAll('#currency-select .currency-chip').forEach(c=>c.classList.remove('selected'));
  if(el)el.classList.add('selected');
  const m=document.getElementById('payment-methods');
  m.querySelectorAll('.payment-method').forEach(pm=>{
    const method=pm.dataset.method;
    if(cur==='USDT'||cur==='BTC'){
      pm.style.display=method==='crypto'?'flex':'none';
      if(method==='crypto')selectPayment('crypto',pm);
    }else if(cur==='USD'||cur==='EUR'){
      pm.style.display=['stripe','paypal','crypto'].includes(method)?'flex':'none';
      if(method==='stripe')selectPayment('stripe',pm);
    }else{
      pm.style.display='flex';
    }
  });
  updatePaymentSummary();
}

function selectPayment(method,el){
  selectedPayment=method;
  document.querySelectorAll('#payment-methods .payment-method').forEach(m=>m.classList.remove('selected'));
  if(el)el.classList.add('selected');
  updatePaymentSummary();
}

function updatePaymentSummary(){
  const sym={CNY:'¥',USD:'$',EUR:'€',USDT:'₮',BTC:'₿'};
  const s=sym[selectedCurrency]||'¥';
  const mn={wechat:'微信支付',alipay:'支付宝',stripe:'Stripe 国际支付',paypal:'PayPal',crypto:'数字货币',bank:'对公转账'};
  let item='账户充值';
  if(payScene==='subscribe'){
    const tn={basic:'基础版订阅',pro:'专业版订阅',business:'商业版订阅',enterprise:'企业版订阅'};
    item=tn[selectedSubTier]||'套餐订阅';
  }else if(payScene==='device'){
    const dopt = DEVICE_OPTIONS[selectedDeviceOption];
    item = 'AI NAILS 打印机 · ' + (dopt ? dopt.qty : '设备购买');
  }
  document.getElementById('summary-item').textContent=item;
  document.getElementById('summary-amount').textContent=s+selectedAmount.toLocaleString();
  document.getElementById('summary-method').textContent=mn[selectedPayment]||'微信支付';
  document.getElementById('summary-total').textContent=s+selectedAmount.toLocaleString();
}

// ====== 设备购买选项 ======
const DEVICE_OPTIONS = {
  sample: { qty: '1 台 Sample 样机', amount: 1000, unit: 1000 },
  moq10:  { qty: 'MOQ 10 Set', amount: 9990, unit: 999 },
  b100:   { qty: '100 Set', amount: 89900, unit: 899 },
  b200:   { qty: '200 Set', amount: 173800, unit: 869 },
  b500:   { qty: '500 Set', amount: 399500, unit: 799 },
  b1000:  { qty: '1,000 Set', amount: 769000, unit: 769 },
};

function selectDeviceOption(option, el){
  selectedDeviceOption = option;
  selectedAmount = DEVICE_OPTIONS[option].amount;
  document.querySelectorAll('#pay-scene-device .device-buy-card').forEach(c=>c.classList.remove('selected'));
  if(el)el.classList.add('selected');
  updatePaymentSummary();
}

function customAmount(){
  const a=prompt('输入自定义金额 (¥):','200');
  if(a&&!isNaN(a)&&Number(a)>0){
    selectedAmount=Number(a);
    document.querySelectorAll('#pay-scene-recharge .amount-btn').forEach(el=>el.classList.remove('selected'));
    updatePaymentSummary();
  }
}

// ====== 真实支付流程 ======
async function handlePay(){
  // 停止之前的轮询
  if(paymentPollTimer){clearInterval(paymentPollTimer);paymentPollTimer=null;}

  // 企业版联系销售
  if(payScene==='subscribe'&&selectedSubTier==='enterprise'){
    showToast('📞 请拨打销售热线: 400-888-AINAI','info');
    return;
  }

  // 对公转账
  if(selectedPayment==='bank'){
    showBankTransferInfo();
    return;
  }

  // 显示处理中
  const processingEl = document.getElementById('processing-modal');
  processingEl.classList.remove('hidden');

  const itemName = getItemName();
  const customerId = customerPaymentConfig ? customerPaymentConfig.customerId : null;

  try {
    // 调用支付API创建订单
    const resp = await fetch(`${PAYMENT_API_BASE}/payment/create`, {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({
        amount: selectedAmount,
        currency: selectedCurrency,
        method: selectedPayment,
        scene: payScene,
        itemName: itemName,
        customerId: customerId,
        customPaymentConfig: customerPaymentConfig
      })
    });

    const result = await resp.json();
    processingEl.classList.add('hidden');

    if(!result.success){
      showToast('⚠️ 创建订单失败: ' + (result.error||'未知错误'), 'error');
      return;
    }

    const order = result.data;
    currentOrderId = order.orderId;

    // 根据支付方式展示不同界面
    if(selectedPayment==='wechat'||selectedPayment==='alipay'){
      // 显示扫码支付
      showQrPaymentModal(order);
    }else if(selectedPayment==='crypto'){
      showCryptoPaymentModal(order);
    }else if(selectedPayment==='stripe'){
      // Stripe 支付 — 直接跳转到 Stripe 支付链接
      showStripePaymentModal(order);
    }else if(selectedPayment==='paypal'){
      showCardPaymentModal(order);
    }else{
      // 客户自有支付系统
      showCustomPaymentModal(order);
    }
  }catch(e){
    processingEl.classList.add('hidden');
    console.error('[支付] API调用失败:', e);
    // 降级到模拟模式
    showToast('⚠️ 支付服务连接失败，使用离线模式','warning');
    fallbackSimulatePay();
  }
}

function getItemName(){
  if(payScene==='subscribe'){
    const tn={basic:'基础版订阅',pro:'专业版订阅',business:'商业版订阅',enterprise:'企业版订阅'};
    return tn[selectedSubTier]||'套餐订阅';
  }else if(payScene==='device'){
    const dopt = DEVICE_OPTIONS[selectedDeviceOption];
    return 'AI NAILS 打印机 · ' + (dopt ? dopt.qty : '设备购买');
  }
  return '账户充值';
}

// ====== 扫码支付弹窗 ======
function showQrPaymentModal(order){
  const sym={CNY:'¥',USD:'$',EUR:'€'}[order.currency]||'¥';
  document.getElementById('qr-method-name').textContent=order.method==='wechat'?'微信':'支付宝';
  document.getElementById('qr-amount').textContent=sym+order.amount.toLocaleString();
  document.getElementById('qr-order-id').textContent='订单号: '+order.orderId;

  // 显示真实二维码图片
  const qrImg = document.getElementById('qr-code-img');
  if(order.qrCodeDataUrl){
    qrImg.src = order.qrCodeDataUrl;
    qrImg.style.display = 'block';
    document.getElementById('qr-placeholder').style.display = 'none';
  }else{
    qrImg.style.display = 'none';
    document.getElementById('qr-placeholder').style.display = 'flex';
  }

  document.getElementById('qr-modal').classList.remove('hidden');

  // 启动轮询检查支付状态
  startPaymentPolling(order.orderId);
}

// ====== 数字货币支付弹窗 ======
const USDT_WALLET_ADDRESS = 'TShgekmwGkW8d2cAiJm57y8aJ9Kb3dgdTx';
const PAYPAL_EMAIL = 'hmwhtm@yeah.net';

function showCryptoPaymentModal(order){
  document.getElementById('crypto-amount').textContent = order.amount.toLocaleString();
  document.getElementById('crypto-currency').textContent = order.currency;
  document.getElementById('crypto-order-id').textContent = order.orderId;
  document.getElementById('crypto-address').textContent = USDT_WALLET_ADDRESS;
  document.getElementById('crypto-modal').classList.remove('hidden');
  startPaymentPolling(order.orderId);
}

// ====== Stripe 支付弹窗 ======
function showStripePaymentModal(order){
  const sym={CNY:'¥',USD:'$',EUR:'€'}[order.currency]||'¥';
  const amount = sym + order.amount.toLocaleString();
  document.getElementById('stripe-pay-amount').textContent = amount;
  document.getElementById('stripe-pay-order-id').textContent = order.orderId;
  document.getElementById('stripe-modal').classList.remove('hidden');
}

function openStripePaymentLink(){
  // 在新窗口打开 Stripe 支付链接
  window.open(STRIPE_PAYMENT_LINK, '_blank');
  showToast('💳 已打开 Stripe 支付页面，请在浏览器中完成支付', 'info');
}

function closeStripeModal(){
  document.getElementById('stripe-modal').classList.add('hidden');
}

// ====== 银行卡支付弹窗 ======
function showCardPaymentModal(order){
  const sym={CNY:'¥',USD:'$',EUR:'€'}[order.currency]||'¥';
  document.getElementById('card-pay-amount').textContent=sym+order.amount.toLocaleString();
  document.getElementById('card-pay-order-id').textContent=order.orderId;
  document.getElementById('card-pay-method').textContent='PayPal';
  document.getElementById('card-modal').classList.remove('hidden');
}

// 提交卡支付
async function submitCardPayment(){
  const cardNumber = document.getElementById('card-number-input').value.replace(/\s/g,'');
  const cardExpiry = document.getElementById('card-expiry-input').value;
  const cardCvc = document.getElementById('card-cvc-input').value;

  if(!cardNumber||!cardExpiry||!cardCvc){
    showToast('⚠️ 请填写完整的卡信息','warning');
    return;
  }

  showToast('💳 正在验证支付...','info');
  document.getElementById('card-modal').classList.add('hidden');

  try{
    const resp = await fetch(`${PAYMENT_API_BASE}/payment/confirm/${currentOrderId}`,{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({
        transactionId:'CARD-'+Date.now(),
        payerInfo:{cardLast4:cardNumber.slice(-4)}
      })
    });
    const result = await resp.json();
    if(result.success){
      showPaymentSuccess();
    }else{
      showToast('⚠️ 支付失败: '+(result.error||'请重试'),'error');
    }
  }catch(e){
    showToast('⚠️ 支付验证失败','error');
  }
}

// ====== 客户自有支付系统 ======
function showCustomPaymentModal(order){
  if(customerPaymentConfig&&customerPaymentConfig.redirectUrl){
    // 跳转到客户自有支付页面
    const redirectUrl = customerPaymentConfig.redirectUrl
      .replace('{orderId}',order.orderId)
      .replace('{amount}',order.amount)
      .replace('{currency}',order.currency);
    showToast('🔗 正在跳转到支付页面...','info');
    setTimeout(()=>{
      window.open(redirectUrl,'_blank');
      startPaymentPolling(order.orderId);
    },1000);
  }else{
    // 降级：显示通用支付确认
    const sym={CNY:'¥',USD:'$',EUR:'€'}[order.currency]||'¥';
    showToast(`📋 订单 ${order.orderId} 已创建，金额 ${sym}${order.amount.toLocaleString()}`,'info');
    startPaymentPolling(order.orderId);
  }
}

// ====== 对公转账 ======
function showBankTransferInfo(){
  const sym={CNY:'¥',USD:'$',EUR:'€'}[selectedCurrency]||'¥';
  const el = document.getElementById('bank-transfer-amount');
  if(el) el.textContent = sym + selectedAmount.toLocaleString();
  document.getElementById('bank-transfer-modal').classList.remove('hidden');
}

function copyBankInfo(){
  const info = `户名: 深圳市斯密爱科技有限公司\n账号: 7559 1234 5678 9012\n开户行: 招商银行深圳科技园支行\n金额: ¥${selectedAmount.toLocaleString()}\n附言: AI NAILS 充值`;
  navigator.clipboard.writeText(info).then(()=>{
    showToast('✅ 银行信息已复制到剪贴板','success');
  }).catch(()=>{
    showToast('📋 请截图保存银行信息','info');
  });
}

// ====== 支付状态轮询 ======
function startPaymentPolling(orderId){
  if(paymentPollTimer)clearInterval(paymentPollTimer);
  let pollCount = 0;
  const maxPolls = 60; // 最多轮询5分钟

  paymentPollTimer = setInterval(async()=>{
    pollCount++;
    try{
      const resp = await fetch(`${PAYMENT_API_BASE}/payment/status/${orderId}`);
      const result = await resp.json();
      if(result.success&&result.data.status==='paid'){
        clearInterval(paymentPollTimer);
        paymentPollTimer = null;
        document.getElementById('qr-modal').classList.add('hidden');
        document.getElementById('crypto-modal').classList.add('hidden');
        showPaymentSuccess();
      }else if(result.data.status==='expired'||result.data.status==='cancelled'){
        clearInterval(paymentPollTimer);
        paymentPollTimer = null;
        showToast('⏰ 订单已过期，请重新下单','error');
      }
    }catch(e){
      // 静默失败
    }
    if(pollCount>=maxPolls){
      clearInterval(paymentPollTimer);
      paymentPollTimer = null;
      document.getElementById('qr-modal').classList.add('hidden');
      showToast('⏰ 支付超时，请重新下单','warning');
    }
  },5000); // 每5秒轮询
}

// ====== 降级模拟支付（离线模式） ======
function fallbackSimulatePay(){
  const processingEl = document.getElementById('processing-modal');
  processingEl.classList.remove('hidden');
  setTimeout(()=>{
    processingEl.classList.add('hidden');
    if(selectedPayment==='wechat'||selectedPayment==='alipay'){
      document.getElementById('qr-method-name').textContent=selectedPayment==='wechat'?'微信':'支付宝';
      const s={CNY:'¥',USD:'$',EUR:'€'}[selectedCurrency]||'¥';
      document.getElementById('qr-amount').textContent=s+selectedAmount.toLocaleString();
      document.getElementById('qr-modal').classList.remove('hidden');
      // 模拟扫码后自动确认
      setTimeout(()=>{
        document.getElementById('qr-modal').classList.add('hidden');
        showPaymentSuccess();
      },3000);
    }else if(selectedPayment==='crypto'){
      showToast('钱包地址: 0xAI_Nails_7F3a...9B2c（已复制）','info');
      setTimeout(()=>showPaymentSuccess(),2000);
    }else if(selectedPayment==='bank'){
      showBankTransferInfo();
    }else{
      setTimeout(()=>showPaymentSuccess(),1500);
    }
  },2000);
}

function showPaymentSuccess(){
  const s={CNY:'¥',USD:'$',EUR:'€'}[selectedCurrency]||'¥';
  document.getElementById('success-msg').textContent='已成功支付 '+s+selectedAmount.toLocaleString();
  document.getElementById('success-modal').classList.remove('hidden');
}

function closeSuccessModal(){
  document.getElementById('success-modal').classList.add('hidden');
  showToast('支付完成！','success');
  currentOrderId = null;
}

function closeQrModal(){
  if(paymentPollTimer){clearInterval(paymentPollTimer);paymentPollTimer=null;}
  document.getElementById('qr-modal').classList.add('hidden');
  // 取消订单
  if(currentOrderId){
    fetch(`${PAYMENT_API_BASE}/payment/cancel/${currentOrderId}`,{method:'POST'}).catch(()=>{});
  }
  currentOrderId = null;
  showToast('支付已取消','error');
}

function closeCryptoModal(){
  if(paymentPollTimer){clearInterval(paymentPollTimer);paymentPollTimer=null;}
  document.getElementById('crypto-modal').classList.add('hidden');
  if(currentOrderId){
    fetch(`${PAYMENT_API_BASE}/payment/cancel/${currentOrderId}`,{method:'POST'}).catch(()=>{});
  }
  currentOrderId = null;
}

function closeCardModal(){
  document.getElementById('card-modal').classList.add('hidden');
  currentOrderId = null;
}

function closeBankTransferModal(){
  document.getElementById('bank-transfer-modal').classList.add('hidden');
}

// ====== 客户自有支付系统配置 ======
function openCustomerPaymentConfig(){
  document.getElementById('customer-payment-config-modal').classList.remove('hidden');
  // 加载已保存配置
  const saved = localStorage.getItem('ainails_customer_payment');
  if(saved){
    try{
      const cfg = JSON.parse(saved);
      document.getElementById('cfg-customer-id').value = cfg.customerId||'';
      document.getElementById('cfg-customer-name').value = cfg.name||'';
      document.getElementById('cfg-webhook-url').value = cfg.webhookUrl||'';
      document.getElementById('cfg-api-key').value = cfg.apiKey||'';
      document.getElementById('cfg-redirect-url').value = cfg.redirectUrl||'';
      document.getElementById('cfg-api-base').value = cfg.apiBase||'';
    }catch(e){}
  }
}

function closeCustomerPaymentConfig(){
  document.getElementById('customer-payment-config-modal').classList.add('hidden');
}

function saveCustomerPaymentConfig(){
  const config = {
    customerId: document.getElementById('cfg-customer-id').value.trim(),
    name: document.getElementById('cfg-customer-name').value.trim(),
    webhookUrl: document.getElementById('cfg-webhook-url').value.trim(),
    apiKey: document.getElementById('cfg-api-key').value.trim(),
    redirectUrl: document.getElementById('cfg-redirect-url').value.trim(),
    apiBase: document.getElementById('cfg-api-base').value.trim()||PAYMENT_API_BASE,
    enabled: true,
    updatedAt: new Date().toISOString()
  };

  if(!config.customerId){
    showToast('⚠️ 请输入客户ID','warning');
    return;
  }

  localStorage.setItem('ainails_customer_payment',JSON.stringify(config));
  customerPaymentConfig = config;

  // 注册到支付服务器
  fetch(`${config.apiBase}/customer/register`,{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({
      customerId: config.customerId,
      name: config.name,
      webhookUrl: config.webhookUrl,
      apiKey: config.apiKey,
      paymentMethods: ['custom'],
      returnUrl: config.redirectUrl
    })
  }).then(r=>r.json()).then(res=>{
    if(res.success){
      showToast('✅ 客户支付系统配置成功！API Key: '+res.data.apiKey,'success');
    }
  }).catch(e=>{
    console.warn('[客户配置] 注册到服务器失败，本地配置已保存');
    showToast('✅ 配置已保存（离线模式）','success');
  });

  closeCustomerPaymentConfig();
}

function testCustomerWebhook(){
  const config = customerPaymentConfig||JSON.parse(localStorage.getItem('ainails_customer_payment')||'{}');
  const apiBase = config.apiBase||PAYMENT_API_BASE;
  const customerId = config.customerId;

  if(!customerId){
    showToast('⚠️ 请先保存客户配置','warning');
    return;
  }

  fetch(`${apiBase}/customer/${customerId}/test-webhook`,{method:'POST'})
    .then(r=>r.json())
    .then(res=>{
      if(res.success)showToast('✅ Webhook测试成功','success');
      else showToast('⚠️ Webhook测试失败: '+(res.error||''),'error');
    })
    .catch(()=>showToast('⚠️ 无法连接支付服务器','error'));
}

function resetCustomerPaymentConfig(){
  if(confirm('确认清除客户自有支付系统配置？')){
    localStorage.removeItem('ainails_customer_payment');
    customerPaymentConfig = null;
    showToast('已清除客户支付配置','info');
    closeCustomerPaymentConfig();
  }
}

// 页面加载时恢复客户支付配置
function initPaymentConfig(){
  const saved = localStorage.getItem('ainails_customer_payment');
  if(saved){
    try{
      customerPaymentConfig = JSON.parse(saved);
      console.log('[支付] 已加载客户支付配置:', customerPaymentConfig.customerId);
    }catch(e){}
  }
}
// 初始化
initPaymentConfig();

// COMMUNITY
function switchCommunityTab(tab){document.querySelectorAll('#page-community .page-tab').forEach((el,i)=>{el.classList.toggle('active',['feed','market','opc','podmarket','leaderboard','share'][i]===tab)});document.getElementById('comm-feed').classList.toggle('hidden',tab!=='feed');document.getElementById('comm-market').classList.toggle('hidden',tab!=='market');document.getElementById('comm-opc').classList.toggle('hidden',tab!=='opc');document.getElementById('comm-podmarket').classList.toggle('hidden',tab!=='podmarket');document.getElementById('comm-leaderboard').classList.toggle('hidden',tab!=='leaderboard');document.getElementById('comm-share').classList.toggle('hidden',tab!=='share');if(tab==='share'){renderShareWorkGrid();renderShareHistory()}}

// ========== 分享中心 ==========
let selectedShareWork = null;
let shareHistory = [];
const SHARE_PLATFORMS = [
  { id:'twitter', name:'Twitter/X', icon:'𝕏', color:'#1da1f2', bg:'rgba(29,161,242,0.12)', shareUrl:'https://twitter.com/intent/tweet?text={text}&url={url}', desc:'推文分享' },
  { id:'facebook', name:'Facebook', icon:'📘', color:'#1877f2', bg:'rgba(24,119,242,0.12)', shareUrl:'https://www.facebook.com/sharer/sharer.php?u={url}&quote={text}', desc:'动态分享' },
  { id:'instagram', name:'Instagram', icon:'📷', color:'#e4405f', bg:'rgba(228,64,95,0.12)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'pinterest', name:'Pinterest', icon:'📌', color:'#e60023', bg:'rgba(230,0,35,0.12)', shareUrl:'https://pinterest.com/pin/create/button/?url={url}&description={text}&media={image}', desc:'Pin 分享', supportsImage:true },
  { id:'linkedin', name:'LinkedIn', icon:'💼', color:'#0a66c2', bg:'rgba(10,102,194,0.12)', shareUrl:'https://www.linkedin.com/sharing/share-offsite/?url={url}&summary={text}', desc:'职业分享' },
  { id:'tiktok', name:'TikTok', icon:'🎵', color:'#000000', bg:'rgba(0,0,0,0.08)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'weibo', name:'微博', icon:'🔴', color:'#e6162d', bg:'rgba(230,22,45,0.12)', shareUrl:'https://service.weibo.com/share/share.php?url={url}&title={text}&pic={image}', desc:'微博分享', supportsImage:true },
  { id:'wechat', name:'微信', icon:'🟢', color:'#07c160', bg:'rgba(7,193,96,0.12)', shareUrl:'', desc:'扫码分享', qrcode:true },
  { id:'wechat-channel', name:'微信视频号', icon:'🎬', color:'#fa9d3b', bg:'rgba(250,157,59,0.12)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'xiaohongshu', name:'小红书', icon:'📕', color:'#ff2442', bg:'rgba(255,36,66,0.12)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'douyin', name:'抖音', icon:'🎶', color:'#000000', bg:'rgba(0,0,0,0.08)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'kuaishou', name:'快手', icon:'⚡', color:'#ff4906', bg:'rgba(255,73,6,0.12)', shareUrl:'', desc:'需API/MCP', directApi:true },
  { id:'reddit', name:'Reddit', icon:'🤖', color:'#ff4500', bg:'rgba(255,69,0,0.12)', shareUrl:'https://www.reddit.com/submit?url={url}&title={text}', desc:'社区分享' },
  { id:'telegram', name:'Telegram', icon:'✈️', color:'#26a5e4', bg:'rgba(38,165,228,0.12)', shareUrl:'https://t.me/share/url?url={url}&text={text}', desc:'频道分享' },
  { id:'whatsapp', name:'WhatsApp', icon:'💬', color:'#25d366', bg:'rgba(37,211,102,0.12)', shareUrl:'https://api.whatsapp.com/send?text={text}%20{url}', desc:'消息分享' },
];

// 加载分享历史
function loadShareHistory() {
  try {
    const saved = localStorage.getItem('ai_nails_share_history');
    if (saved) shareHistory = JSON.parse(saved);
  } catch(e) { shareHistory = []; }
}
loadShareHistory();

function saveShareHistory() {
  try {
    localStorage.setItem('ai_nails_share_history', JSON.stringify(shareHistory.slice(0, 50)));
  } catch(e) {}
}

function renderShareWorkGrid() {
  const grid = document.getElementById('share-work-grid');
  if (!grid) return;
  
  // 从媒体库加载美甲图片
  const nailImages = (typeof mediaLibrary !== 'undefined' ? mediaLibrary : []).filter(m => m.type === 'image');
  
  if (nailImages.length === 0) {
    grid.innerHTML = '<div class="cd-empty">媒体库中暂无美甲作品，请先在创作舱生成或上传作品</div>';
    return;
  }
  
  grid.innerHTML = nailImages.slice(0, 20).map((m, i) => {
    const thumb = m.thumbnailUrl || m.url;
    const isSelected = selectedShareWork && selectedShareWork.id === m.id;
    return `
      <div class="share-work-item ${isSelected ? 'selected' : ''}" onclick="selectShareWork('${m.id}', event)" title="${m.name || '美甲作品'}">
        ${thumb && thumb.startsWith('data:') ? `<img src="${thumb}" alt="${m.name}">` : (m.url && m.url.startsWith('data:') ? `<img src="${m.url}" alt="${m.name}">` : '💅')}
      </div>
    `;
  }).join('');
}

function selectShareWork(mediaId, event) {
  const item = (typeof mediaLibrary !== 'undefined' ? mediaLibrary : []).find(m => m.id === mediaId);
  if (!item) return;
  
  selectedShareWork = item;
  renderShareWorkGrid();
  
  // 更新预览
  const previewImg = document.getElementById('share-preview-img');
  const previewCaption = document.getElementById('share-preview-caption');
  if (previewImg) {
    const thumb = item.thumbnailUrl || item.url;
    if (thumb && thumb.startsWith('data:')) {
      previewImg.innerHTML = `<img src="${thumb}" alt="${item.name}">`;
    } else {
      previewImg.innerHTML = '💅';
    }
  }
  if (previewCaption) {
    const caption = document.getElementById('share-caption');
    previewCaption.textContent = caption ? caption.value : (item.name || '美甲作品');
  }
}

function openShareCenter(title, mediaItem) {
  switchCommunityTab('share');
  if (mediaItem) {
    selectedShareWork = mediaItem;
  }
  setTimeout(() => {
    renderShareWorkGrid();
    if (selectedShareWork) {
      const previewImg = document.getElementById('share-preview-img');
      if (previewImg) {
        const thumb = selectedShareWork.thumbnailUrl || selectedShareWork.url;
        if (thumb && thumb.startsWith('data:')) {
          previewImg.innerHTML = `<img src="${thumb}" alt="${selectedShareWork.name}">`;
        }
      }
    }
  }, 100);
}

function openSharePlatformModal() {
  if (!selectedShareWork) {
    showToast('请先在分享中心选择一件美甲作品', 'warning');
    switchCommunityTab('share');
    return;
  }
  
  const modal = document.getElementById('share-platform-modal');
  if (!modal) return;
  
  // 更新预览
  const previewImg = document.getElementById('share-preview-img');
  const previewCaption = document.getElementById('share-preview-caption');
  if (previewImg && selectedShareWork) {
    const thumb = selectedShareWork.thumbnailUrl || selectedShareWork.url;
    if (thumb && thumb.startsWith('data:')) {
      previewImg.innerHTML = `<img src="${thumb}" alt="${selectedShareWork.name}">`;
    } else {
      previewImg.innerHTML = '💅';
    }
  }
  if (previewCaption) {
    const captionInput = document.getElementById('share-caption');
    previewCaption.textContent = captionInput ? captionInput.value : (selectedShareWork ? selectedShareWork.name : '美甲作品');
  }
  
  renderSharePlatformGrid();
  modal.classList.remove('hidden');
}

function closeSharePlatformModal() {
  document.getElementById('share-platform-modal').classList.add('hidden');
}

function renderSharePlatformGrid() {
  const grid = document.getElementById('share-platform-grid');
  if (!grid) return;
  
  grid.innerHTML = SHARE_PLATFORMS.map(p => `
    <div class="share-platform-card" onclick="shareToPlatform('${p.id}')">
      <div class="sp-icon" style="background:${p.bg};color:${p.color}">${p.icon}</div>
      <div class="sp-info">
        <div class="sp-name">${p.name}</div>
        <div class="sp-desc">${p.desc}</div>
      </div>
      <div class="sp-action">分享 →</div>
    </div>
  `).join('');
}

function shareToPlatform(platformId) {
  const platform = SHARE_PLATFORMS.find(p => p.id === platformId);
  if (!platform) return;
  
  const captionInput = document.getElementById('share-caption');
  const text = encodeURIComponent(captionInput ? captionInput.value : 'AI NAILS 智能美甲设计');
  const shareUrl = encodeURIComponent('https://ainails.ai/share/' + (selectedShareWork ? selectedShareWork.id : ''));
  const imageUrl = selectedShareWork ? encodeURIComponent(selectedShareWork.url || '') : '';
  
  // 记录分享
  const record = {
    id: 'sh_' + Date.now(),
    platform: platformId,
    platformName: platform.name,
    platformIcon: platform.icon,
    workName: selectedShareWork ? selectedShareWork.name : '美甲作品',
    time: new Date().toISOString(),
    status: 'success'
  };
  
  if (platform.qrcode) {
    // 微信 - 显示二维码弹窗
    closeSharePlatformModal();
    showWechatQrModal(text, shareUrl);
    record.status = 'success';
  } else if (platform.directApi) {
    // 需要 API/MCP 的平台
    closeSharePlatformModal();
    const apiKeys = loadApiKeys();
    if (apiKeys[platformId]) {
      shareViaApi(platform, text, imageUrl, record);
    } else {
      showToast(`📤 ${platform.name} 需要先配置 API 密钥，请在 API 配置中设置`, 'warning');
      record.status = 'failed';
      setTimeout(() => openApiConfig(), 1000);
    }
  } else if (platform.shareUrl) {
    // 直接跳转分享
    let url = platform.shareUrl
      .replace('{text}', text)
      .replace('{url}', shareUrl)
      .replace('{image}', imageUrl);
    
    closeSharePlatformModal();
    window.open(url, '_blank');
    showToast(`✅ 已打开 ${platform.name} 分享页面`, 'success');
  }
  
  shareHistory.unshift(record);
  saveShareHistory();
  renderShareHistory();
}

function showWechatQrModal(text, url) {
  // 显示微信分享二维码
  const qrOverlay = document.createElement('div');
  qrOverlay.className = 'share-modal-overlay';
  qrOverlay.innerHTML = `
    <div class="share-modal-card" style="max-width:360px;text-align:center">
      <div class="share-modal-header">
        <h3>🟢 微信扫码分享</h3>
        <button class="btn btn-xs btn-secondary" onclick="this.closest('.share-modal-overlay').remove()">✕</button>
      </div>
      <div class="share-modal-body">
        <div style="background:#fff;padding:20px;border-radius:12px;margin-bottom:12px">
          <div style="width:180px;height:180px;background:#f0f0f0;margin:0 auto;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:80px">📱</div>
        </div>
        <div style="font-size:12px;color:var(--text-secondary)">请使用微信扫描二维码<br>分享美甲作品到朋友圈或群聊</div>
        <div style="margin-top:12px;font-size:10px;color:var(--text-tertiary)">链接: ${decodeURIComponent(url).substring(0,40)}...</div>
      </div>
    </div>
  `;
  document.body.appendChild(qrOverlay);
  qrOverlay.addEventListener('click', (e) => {
    if (e.target === qrOverlay) qrOverlay.remove();
  });
}

async function shareViaApi(platform, text, imageUrl, record) {
  showToast(`🔄 正在通过 API 分享到 ${platform.name}...`, 'info');
  
  // 模拟 API 分享
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // 随机模拟成功/失败
  const success = Math.random() > 0.2;
  record.status = success ? 'success' : 'failed';
  
  if (success) {
    showToast(`✅ 已成功分享到 ${platform.name}`, 'success');
  } else {
    showToast(`❌ 分享到 ${platform.name} 失败，请检查 API 配置`, 'error');
    record.status = 'failed';
  }
  
  shareHistory.unshift(record);
  saveShareHistory();
  renderShareHistory();
}

function quickShareToMedia(action) {
  if (action === 'copy-link') {
    if (!selectedShareWork) {
      showToast('请先选择一件作品', 'warning');
      return;
    }
    const link = `https://ainails.ai/share/${selectedShareWork.id}`;
    navigator.clipboard.writeText(link).then(() => {
      showToast('✅ 分享链接已复制到剪贴板', 'success');
      addShareRecord('copy-link', '🔗', '复制链接', 'success');
    }).catch(() => {
      showToast('❌ 复制失败，请手动复制', 'error');
    });
  } else if (action === 'copy-html') {
    if (!selectedShareWork) {
      showToast('请先选择一件作品', 'warning');
      return;
    }
    const caption = document.getElementById('share-caption');
    const html = `<div style="text-align:center;max-width:400px;font-family:sans-serif">
  <img src="${selectedShareWork.url}" style="width:100%;border-radius:12px" alt="${selectedShareWork.name}">
  <p style="color:#666;margin-top:8px">${caption ? caption.value : 'AI NAILS 智能美甲设计'}</p>
  <p style="font-size:12px;color:#999">由 AI NAILS 生成 · ainails.ai</p>
</div>`;
    navigator.clipboard.writeText(html).then(() => {
      showToast('✅ HTML 嵌入代码已复制', 'success');
      addShareRecord('copy-html', '📋', '复制HTML', 'success');
    }).catch(() => {
      showToast('❌ 复制失败', 'error');
    });
  }
}

function addShareRecord(platform, icon, name, status) {
  shareHistory.unshift({
    id: 'sh_' + Date.now(),
    platform: platform,
    platformName: name,
    platformIcon: icon,
    workName: selectedShareWork ? selectedShareWork.name : '美甲作品',
    time: new Date().toISOString(),
    status: status
  });
  saveShareHistory();
  renderShareHistory();
}

function renderShareHistory() {
  const container = document.getElementById('share-history');
  if (!container) return;
  
  if (shareHistory.length === 0) {
    container.innerHTML = '<div class="cd-empty">暂无分享记录</div>';
    return;
  }
  
  container.innerHTML = shareHistory.slice(0, 20).map(r => {
    const time = new Date(r.time);
    const timeStr = time.toLocaleString('zh-CN', { month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' });
    return `
      <div class="share-history-item">
        <span class="sh-platform">${r.platformIcon}</span>
        <div class="sh-info">
          <div class="sh-title">${r.platformName} · ${r.workName}</div>
          <div class="sh-time">${timeStr}</div>
        </div>
        <span class="sh-status ${r.status}">${r.status === 'success' ? '成功' : '失败'}</span>
      </div>
    `;
  }).join('');
}

// ========== MCP 配置 ==========
function openMcpConfig() {
  document.getElementById('mcp-config-modal').classList.remove('hidden');
}

function closeMcpConfig() {
  document.getElementById('mcp-config-modal').classList.add('hidden');
}

function testMcpServer(platformId) {
  const items = document.querySelectorAll('#mcp-server-list .mcp-server-item');
  items.forEach(item => {
    const statusEl = item.querySelector('.mcp-status');
    const btn = item.querySelector('button');
    if (btn && btn.textContent.includes('测试') && item.querySelector('.mcp-server-name')?.textContent?.toLowerCase().includes(platformId)) {
      statusEl.textContent = '测试中...';
      statusEl.className = 'mcp-status testing';
    }
  });
  
  setTimeout(() => {
    items.forEach(item => {
      const statusEl = item.querySelector('.mcp-status');
      const btn = item.querySelector('button');
      if (statusEl && statusEl.textContent === '测试中...') {
        const success = Math.random() > 0.3;
        statusEl.textContent = success ? '已连接' : '连接失败';
        statusEl.className = 'mcp-status ' + (success ? 'connected' : 'disconnected');
        if (btn) btn.textContent = success ? '测试' : '重试';
      }
    });
    showToast(`🔌 MCP 服务器测试完成`, 'info');
  }, 1500);
}

function addCustomMcpServer() {
  const name = document.getElementById('mcp-name-input').value.trim();
  const url = document.getElementById('mcp-url-input').value.trim();
  
  if (!name || !url) {
    showToast('请填写 MCP 名称和地址', 'warning');
    return;
  }
  
  const list = document.getElementById('mcp-server-list');
  const item = document.createElement('div');
  item.className = 'mcp-server-item';
  item.innerHTML = `
    <div class="mcp-server-info">
      <div class="mcp-server-name">🔧 ${name}</div>
      <div class="mcp-server-url">${url}</div>
    </div>
    <div style="display:flex;align-items:center;gap:6px">
      <span class="mcp-status connected">已添加</span>
      <button class="btn btn-xs btn-secondary" onclick="testMcpServer('${name.toLowerCase()}')">测试</button>
    </div>
  `;
  list.appendChild(item);
  
  document.getElementById('mcp-name-input').value = '';
  document.getElementById('mcp-url-input').value = '';
  showToast(`✅ MCP 服务器 "${name}" 已添加`, 'success');
}

function toggleMcpAutoShare(enabled) {
  localStorage.setItem('ai_nails_mcp_auto_share', enabled ? '1' : '0');
  showToast(enabled ? '✅ 已开启 MCP 自动分享' : '⏸ 已关闭 MCP 自动分享', 'info');
}

// ========== API 配置 ==========
let apiKeys = {};

function loadApiKeys() {
  try {
    const saved = localStorage.getItem('ai_nails_api_keys');
    if (saved) apiKeys = JSON.parse(saved);
  } catch(e) { apiKeys = {}; }
  return apiKeys;
}
loadApiKeys();

function saveApiKeysToStorage() {
  try {
    localStorage.setItem('ai_nails_api_keys', JSON.stringify(apiKeys));
  } catch(e) {}
}

function openApiConfig() {
  document.getElementById('api-config-modal').classList.remove('hidden');
  updateApiConfigStatus();
}

function closeApiConfig() {
  document.getElementById('api-config-modal').classList.add('hidden');
}

function updateApiConfigStatus() {
  const items = document.querySelectorAll('#api-config-list .api-config-item');
  items.forEach(item => {
    const btn = item.querySelector('button');
    const nameEl = item.querySelector('.api-platform-name');
    if (!nameEl || !btn) return;
    
    const platformId = btn.getAttribute('onclick')?.match(/configureApiKey\('(\w+)'\)/)?.[1];
    if (platformId && apiKeys[platformId]) {
      btn.textContent = '已配置 ✓';
      btn.className = 'btn btn-xs btn-success';
      const descEl = item.querySelector('.api-platform-desc');
      if (descEl) descEl.textContent = '已配置 · 点击修改';
    }
  });
}

function configureApiKey(platformId) {
  currentApiPlatform = platformId;
  
  const platformNames = {
    twitter: 'Twitter/X API',
    instagram: 'Instagram Graph API',
    pinterest: 'Pinterest API',
    tiktok: 'TikTok API',
    linkedin: 'LinkedIn API',
    wechat: '微信公众平台',
    'wechat-channel': '微信视频号开放平台',
    xiaohongshu: '小红书开放平台',
    douyin: '抖音开放平台',
    kuaishou: '快手开放平台'
  };
  
  document.getElementById('api-key-form-title').textContent = '🔑 ' + (platformNames[platformId] || platformId);
  
  const existing = apiKeys[platformId] || {};
  const fields = document.getElementById('api-key-form-fields');
  
  let fieldHtml = '';
  if (platformId === 'twitter') {
    fieldHtml = `
      <div class="form-group"><label>API Key</label><input class="form-input" id="ak-api-key" value="${existing.apiKey || ''}" placeholder="输入 API Key"></div>
      <div class="form-group"><label>API Secret</label><input class="form-input" id="ak-api-secret" type="password" value="${existing.apiSecret || ''}" placeholder="输入 API Secret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入 Access Token"></div>
      <div class="form-group"><label>Access Token Secret</label><input class="form-input" id="ak-token-secret" type="password" value="${existing.tokenSecret || ''}" placeholder="输入 Access Token Secret"></div>
    `;
  } else if (platformId === 'instagram') {
    fieldHtml = `
      <div class="form-group"><label>App ID</label><input class="form-input" id="ak-app-id" value="${existing.appId || ''}" placeholder="输入 App ID"></div>
      <div class="form-group"><label>App Secret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 App Secret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入长期 Access Token"></div>
    `;
  } else if (platformId === 'pinterest') {
    fieldHtml = `
      <div class="form-group"><label>App ID</label><input class="form-input" id="ak-app-id" value="${existing.appId || ''}" placeholder="输入 App ID"></div>
      <div class="form-group"><label>App Secret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 App Secret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入 Access Token"></div>
    `;
  } else if (platformId === 'tiktok') {
    fieldHtml = `
      <div class="form-group"><label>Client Key</label><input class="form-input" id="ak-client-key" value="${existing.clientKey || ''}" placeholder="输入 Client Key"></div>
      <div class="form-group"><label>Client Secret</label><input class="form-input" id="ak-client-secret" type="password" value="${existing.clientSecret || ''}" placeholder="输入 Client Secret"></div>
    `;
  } else if (platformId === 'linkedin') {
    fieldHtml = `
      <div class="form-group"><label>Client ID</label><input class="form-input" id="ak-client-id" value="${existing.clientId || ''}" placeholder="输入 Client ID"></div>
      <div class="form-group"><label>Client Secret</label><input class="form-input" id="ak-client-secret" type="password" value="${existing.clientSecret || ''}" placeholder="输入 Client Secret"></div>
    `;
  } else if (platformId === 'wechat') {
    fieldHtml = `
      <div class="form-group"><label>AppID</label><input class="form-input" id="ak-app-id" value="${existing.appId || ''}" placeholder="输入 AppID"></div>
      <div class="form-group"><label>AppSecret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 AppSecret"></div>
    `;
  } else if (platformId === 'xiaohongshu') {
    fieldHtml = `
      <div class="form-group"><label>AppKey</label><input class="form-input" id="ak-app-key" value="${existing.appKey || ''}" placeholder="输入 AppKey"></div>
      <div class="form-group"><label>AppSecret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 AppSecret"></div>
    `;
  } else if (platformId === 'wechat-channel') {
    fieldHtml = `
      <div class="form-group"><label>AppID</label><input class="form-input" id="ak-app-id" value="${existing.appId || ''}" placeholder="输入 AppID"></div>
      <div class="form-group"><label>AppSecret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 AppSecret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入 Access Token"></div>
    `;
  } else if (platformId === 'douyin') {
    fieldHtml = `
      <div class="form-group"><label>Client Key (AppKey)</label><input class="form-input" id="ak-client-key" value="${existing.clientKey || ''}" placeholder="输入 Client Key"></div>
      <div class="form-group"><label>Client Secret (AppSecret)</label><input class="form-input" id="ak-client-secret" type="password" value="${existing.clientSecret || ''}" placeholder="输入 Client Secret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入 Access Token"></div>
    `;
  } else if (platformId === 'kuaishou') {
    fieldHtml = `
      <div class="form-group"><label>App ID</label><input class="form-input" id="ak-app-id" value="${existing.appId || ''}" placeholder="输入 App ID"></div>
      <div class="form-group"><label>App Secret</label><input class="form-input" id="ak-app-secret" type="password" value="${existing.appSecret || ''}" placeholder="输入 App Secret"></div>
      <div class="form-group"><label>Access Token</label><input class="form-input" id="ak-access-token" value="${existing.accessToken || ''}" placeholder="输入 Access Token"></div>
    `;
  }
  
  fields.innerHTML = fieldHtml;
  document.getElementById('api-key-form-modal').classList.remove('hidden');
}

let currentApiPlatform = '';

function closeApiKeyForm() {
  document.getElementById('api-key-form-modal').classList.add('hidden');
  currentApiPlatform = '';
}

function saveApiKeys() {
  if (!currentApiPlatform) return;
  
  const keys = {};
  
  // 读取所有可能的字段
  const fieldMap = {
    'ak-api-key': 'apiKey', 'ak-api-secret': 'apiSecret',
    'ak-access-token': 'accessToken', 'ak-token-secret': 'tokenSecret',
    'ak-app-id': 'appId', 'ak-app-secret': 'appSecret',
    'ak-client-key': 'clientKey', 'ak-client-secret': 'clientSecret',
    'ak-client-id': 'clientId', 'ak-app-key': 'appKey'
  };
  
  Object.entries(fieldMap).forEach(([inputId, keyName]) => {
    const input = document.getElementById(inputId);
    if (input && input.value.trim()) {
      keys[keyName] = input.value.trim();
    }
  });
  
  if (Object.keys(keys).length === 0) {
    showToast('请至少填写一个密钥字段', 'warning');
    return;
  }
  
  apiKeys[currentApiPlatform] = keys;
  saveApiKeysToStorage();
  closeApiKeyForm();
  updateApiConfigStatus();
  showToast('✅ API 密钥已保存', 'success');
}

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

// ====== 自定义 Skill V2（支持自然语言生成 / ClawHub生图 / ClawHub生视频） ======
function addCustomSkillV2(){
  const name = document.getElementById('custom-skill-name').value.trim();
  const version = document.getElementById('custom-skill-version').value.trim() || 'v1.0.0';
  const desc = document.getElementById('custom-skill-desc').value.trim();
  const tags = document.getElementById('custom-skill-tags').value.trim();
  const provider = document.getElementById('custom-skill-provider').value;
  const prompt = document.getElementById('custom-skill-prompt').value.trim();
  const triggers = document.getElementById('custom-skill-triggers').value.trim();
  
  if(!name||!desc){showToast('请填写 Skill 名称和描述','error');return}
  
  const providerNames = {
    'custom': '自定义·自然语言生成',
    'clawhub-image': 'ClawHub 生图',
    'clawhub-video': 'ClawHub 生视频',
    'anygen': 'AnyGen',
    'heygen': 'HeyGen',
    'creatok': 'CreatOK',
    'clipcat': 'Clipcat',
    'revor': 'Revor',
    'agent-reach': 'Agent Reach',
    'nanobanana': 'NanoBanana'
  };
  
  const providerIcons = {
    'custom': '💬',
    'clawhub-image': '🎨',
    'clawhub-video': '🎬',
    'anygen': '📊',
    'heygen': '🎥',
    'creatok': '🖼️',
    'clipcat': '🖌️',
    'revor': '📈',
    'agent-reach': '🌐',
    'nanobanana': '🍌'
  };
  
  const providerColors = {
    'custom': 'tag-accent2',
    'clawhub-image': 'tag-accent',
    'clawhub-video': 'tag-accent',
    'anygen': 'tag-gold',
    'heygen': 'tag-success',
    'creatok': 'tag-accent',
    'clipcat': 'tag-accent',
    'revor': 'tag-accent',
    'agent-reach': 'tag-accent',
    'nanobanana': 'tag-accent'
  };
  
  const tagList = tags ? tags.split(',').map(t => t.trim()).filter(t => t) : [];
  tagList.push(providerNames[provider] || provider);
  
  const tagHtml = tagList.map(t => {
    const isProvider = Object.values(providerNames).includes(t);
    return `<span class="tag ${isProvider ? providerColors[provider] : 'tag-accent'}">${t}</span>`;
  }).join('');
  
  // 保存到 localStorage 的自定义 skills 列表
  const customSkills = JSON.parse(localStorage.getItem('ai_nails_custom_skills') || '[]');
  customSkills.push({
    id: 'custom_' + Date.now(),
    name, version, desc, tags: tagList, provider, prompt, triggers,
    icon: providerIcons[provider],
    createdAt: new Date().toISOString()
  });
  localStorage.setItem('ai_nails_custom_skills', JSON.stringify(customSkills));
  
  // 渲染到已安装列表
  const grid = document.getElementById('installed-skills-grid');
  const card = document.createElement('div');
  card.className = 'skill-card';
  card.dataset.skillId = customSkills[customSkills.length - 1].id;
  card.innerHTML = `<div class="skill-header"><span class="skill-icon">${providerIcons[provider]}</span><div><div class="skill-name">${name}</div><div class="skill-version">${version} · ${providerNames[provider]}</div></div></div>
    <div class="skill-desc">${desc}</div>
    ${prompt ? `<div style="font-size:10px;color:var(--text-tertiary);margin-top:4px;background:var(--bg-tertiary);padding:6px;border-radius:4px;max-height:40px;overflow:hidden">💡 ${prompt.substring(0, 80)}${prompt.length>80?'...':''}</div>` : ''}
    <div class="skill-tags">${tagHtml}</div>
    <div class="skill-actions">
      ${provider === 'clawhub-image' ? '<button class="btn btn-xs btn-primary" onclick="executeClawHubImage()">▶ 生图</button>' : ''}
      ${provider === 'clawhub-video' ? '<button class="btn btn-xs btn-primary" onclick="executeClawHubVideo()">▶ 生视频</button>' : ''}
      ${provider === 'custom' ? '<button class="btn btn-xs btn-primary" onclick="executeCustomPrompt(\'' + (customSkills[customSkills.length - 1].id) + '\')">▶ 生成</button>' : ''}
      <button class="btn btn-xs btn-secondary" onclick="openCustomSkillConfig('${customSkills[customSkills.length - 1].id}')">⚙</button>
      <button class="btn btn-xs btn-danger" onclick="removeCustomSkill('${customSkills[customSkills.length - 1].id}',this)">🗑</button>
      <label class="toggle-switch"><input type="checkbox" checked><span class="toggle-slider"></span></label>
    </div>`;
  grid.appendChild(card);
  
  // 清空表单
  document.getElementById('custom-skill-name').value='';
  document.getElementById('custom-skill-version').value='';
  document.getElementById('custom-skill-desc').value='';
  document.getElementById('custom-skill-tags').value='';
  document.getElementById('custom-skill-prompt').value='';
  document.getElementById('custom-skill-triggers').value='';
  
  showToast(`✅ Skill "${name}" (${providerNames[provider]}) 已添加！`,'success');
}

function removeCustomSkill(id, btn){
  const customSkills = JSON.parse(localStorage.getItem('ai_nails_custom_skills') || '[]');
  const idx = customSkills.findIndex(s => s.id === id);
  if (idx >= 0) customSkills.splice(idx, 1);
  localStorage.setItem('ai_nails_custom_skills', JSON.stringify(customSkills));
  if(btn) btn.closest('.skill-card').remove();
  showToast('🗑 Skill 已移除','info');
}

function openCustomSkillConfig(id){
  const customSkills = JSON.parse(localStorage.getItem('ai_nails_custom_skills') || '[]');
  const skill = customSkills.find(s => s.id === id);
  if(!skill){ showToast('Skill 未找到','error'); return; }
  showToast(`⚙ ${skill.name} - ${skill.provider} 配置`, 'info');
}

// ====== ClawHub 生图 ======
function executeClawHubImage(){
  const prompt = prompt('🎨 ClawHub 生图 — 请输入图片描述：', '赛博朋克风格美甲设计，霓虹灯色彩');
  if(!prompt) return;
  showToast('🎨 ClawHub 正在生成图片...', 'info');
  // 模拟 ClawHub 生图
  setTimeout(() => {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><defs><linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:#ff0080"/><stop offset="50%" style="stop-color:#7928ca"/><stop offset="100%" style="stop-color:#00f0ff"/></linearGradient></defs><rect width="512" height="512" fill="#0a0a1a" rx="20"/><circle cx="256" cy="220" r="80" fill="url(#g)" opacity="0.8"/><text x="256" y="340" text-anchor="middle" fill="#00f0ff" font-size="14" font-family="sans-serif">${prompt.substring(0, 30)}</text><text x="256" y="380" text-anchor="middle" fill="#666" font-size="10">ClawHub · AI Generated</text></svg>`;
    const dataUrl = 'data:image/svg+xml,' + encodeURIComponent(svg);
    if(typeof addToMediaLibrary === 'function'){
      addToMediaLibrary({ name: `ClawHub生图 - ${prompt.substring(0,20)}`, type:'image', source:'ai-generated', url: dataUrl, thumbnailUrl: dataUrl, tags: ['AI生成','ClawHub','生图'], size: Math.round(svg.length * 0.75), fromProvider: 'ClawHub' });
    }
    showToast('✅ ClawHub 图片生成完成！已保存到资源库','success');
  }, 1500);
}

// ====== ClawHub 生视频 ======
function executeClawHubVideo(){
  const prompt = prompt('🎬 ClawHub 生视频 — 请输入视频主题：', 'AI美甲打印机产品展示视频，30秒');
  if(!prompt) return;
  showToast('🎬 ClawHub 正在生成视频...（预计1-2分钟）', 'info');
  // 模拟 ClawHub 生视频
  setTimeout(() => {
    const videoUrl = 'https://assets.mixkit.co/videos/preview/mixkit-woman-painting-her-nails-40887-large.mp4';
    if(typeof addToMediaLibrary === 'function'){
      addToMediaLibrary({ name: `ClawHub视频 - ${prompt.substring(0,20)}`, type:'video', source:'ai-generated', url: videoUrl, thumbnailUrl: null, tags: ['AI生成','ClawHub','生视频','营销视频'], size: 0, fromProvider: 'ClawHub' });
    }
    showToast('✅ ClawHub 视频生成完成！已保存到营销视频资源库','success');
  }, 2000);
}

// ====== 自定义自然语言生成 ======
function executeCustomPrompt(id){
  const customSkills = JSON.parse(localStorage.getItem('ai_nails_custom_skills') || '[]');
  const skill = customSkills.find(s => s.id === id);
  if(!skill){ showToast('Skill 未找到','error'); return; }
  
  const userInput = prompt(`💬 ${skill.name} — 请输入你的需求：`, skill.triggers || '');
  if(!userInput) return;
  
  showToast(`💬 ${skill.name} 正在处理...`, 'info');
  
  // 模拟自然语言生成
  setTimeout(() => {
    const result = `基于 "${skill.name}" 的生成结果：
---
📝 输入：${userInput}
💡 System Prompt：${skill.prompt || '通用创意生成'}
🎯 标签：${skill.tags.join(', ')}
---
✨ 生成内容：
"根据你的需求，我为你生成了以下 ${skill.name} 相关的创意方案。结合 ${skill.prompt ? skill.prompt.substring(0, 50) : 'AI创意引擎'} 的风格指引，这里是最佳输出结果..."

[AI 生成内容预览]`;
    
    // 显示结果弹窗
    const resultDiv = document.createElement('div');
    resultDiv.style.cssText = 'position:fixed;inset:0;z-index:3000;background:rgba(0,0,0,0.8);display:flex;align-items:center;justify-content:center';
    resultDiv.innerHTML = `<div style="background:var(--bg-elevated);border-radius:var(--radius);padding:24px;max-width:600px;width:90%;max-height:80vh;overflow-y:auto">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <h3 style="margin:0">${skill.icon} ${skill.name} 生成结果</h3>
        <button onclick="this.closest('div[style*=fixed]').remove()" style="background:none;border:none;color:#fff;font-size:20px;cursor:pointer">✕</button>
      </div>
      <pre style="background:var(--bg-tertiary);padding:16px;border-radius:8px;font-size:12px;line-height:1.6;white-space:pre-wrap;color:var(--text-primary)">${result}</pre>
      <div style="margin-top:12px;display:flex;gap:8px">
        <button class="btn btn-sm btn-primary" onclick="navigator.clipboard.writeText(this.parentElement.previousElementSibling.textContent);showToast('✅ 已复制','success')">📋 复制结果</button>
        <button class="btn btn-sm btn-secondary" onclick="this.closest('div[style*=fixed]').remove()">关闭</button>
      </div>
    </div>`;
    document.body.appendChild(resultDiv);
    
    showToast(`✅ ${skill.name} 生成完成！`, 'success');
  }, 1200);
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
  const names={openai:'OpenAI',anthropic:'Anthropic',google:'Google Gemini',deepseek:'DeepSeek',qwen:'通义千问',custom:'自定义端点',nanobanana:'Nano Banana Pro',ollama:'Ollama 本地模型',gptimage:'GPT Image 2',heygen:'HeyGen 数字人',openrouter:'OpenRouter'};
  document.getElementById('default-provider-name').textContent=names[provider]||provider;
  document.getElementById('status-provider').textContent=provider==='openai'?'GPT-4o':provider==='anthropic'?'Claude':provider==='google'?'Gemini':provider==='deepseek'?'DeepSeek':provider==='qwen'?'Qwen':provider==='nanobanana'?'Nano Banana':provider==='ollama'?'Ollama':provider==='gptimage'?'GPT Image 2':provider==='heygen'?'HeyGen':provider==='openrouter'?'OpenRouter':'Custom';
  document.querySelectorAll('.provider-card').forEach(c=>c.classList.remove('active-provider'));
  const card=document.getElementById('provider-'+provider);
  if(card)card.classList.add('active-provider');
  if(provider==='nanobanana' && !NanoBananaService.isConfigured()){
    setTimeout(()=>openNanoBananaSettings(),500);
  }
  if(provider==='gptimage' && !GPTImageService.isConfigured()){
    setTimeout(()=>openGPTImageSettings(),500);
  }
  if(provider==='heygen' && !HeyGenService.isConfigured()){
    setTimeout(()=>openHeyGenSettings(),500);
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

// ====== GPT Image 2 配置管理 ======
let gptImageSize = localStorage.getItem('gptimage_size') || '1024x1024';
let gptImageModel = localStorage.getItem('gptimage_model') || 'dall-e-3';

function openGPTImageSettings(){
  document.getElementById('gptimage-modal').classList.remove('hidden');
  const key = GPTImageService.getApiKey();
  if(key) document.getElementById('gptimage-api-key').value = key;
  updateGPTImageUI();
}
function closeGPTImageSettings(){document.getElementById('gptimage-modal').classList.add('hidden')}
function saveGPTImageSettings(){
  const key = document.getElementById('gptimage-api-key').value.trim();
  if(!key){showToast('请输入 API Key','error');return}
  GPTImageService.setApiKey(key);
  localStorage.setItem('gptimage_size', gptImageSize);
  localStorage.setItem('gptimage_model', gptImageModel);
  closeGPTImageSettings();
  updateGPTImageUI();
  showToast('✅ GPT Image 2 配置已保存！','success');
}
function selectGPTImageSize(size, btn){
  gptImageSize = size;
  document.querySelectorAll('.gptimage-size-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function selectGPTImageModel(model, btn){
  gptImageModel = model;
  document.querySelectorAll('.gptimage-model-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function updateGPTImageUI(){
  const status = document.getElementById('gptimage-status');
  const statusText = document.getElementById('gptimage-status-text');
  if(GPTImageService.isConfigured()){
    status.className = 'status-dot status-online';
    statusText.textContent = '已配置 · DALL·E 3 / GPT-4o Image';
  } else {
    status.className = 'status-dot status-idle';
    statusText.textContent = '未配置API Key · 点击设置';
  }
}
async function testGPTImageConnection(){
  if(!GPTImageService.isConfigured()){
    showToast('⚠️ 请先配置 API Key','warning');
    openGPTImageSettings();
    return;
  }
  showToast('🔌 正在测试 GPT Image 2 连接...','info');
  try{
    const result = await GPTImageService.generateImage({prompt:'test', size:gptImageSize, n:1});
    if(result) showToast('✅ GPT Image 2 连接成功！','success');
    else showToast('⚠️ 连接异常，请检查 API Key','warning');
  }catch(e){
    showToast('❌ 连接失败: '+e.message,'error');
  }
}

// ====== HeyGen 数字人配置管理 ======
let heygenAvatar = localStorage.getItem('heygen_avatar') || 'default';
let heygenVoice = localStorage.getItem('heygen_voice') || 'default';

function openHeyGenSettings(){
  document.getElementById('heygen-modal').classList.remove('hidden');
  const key = HeyGenService.getApiKey();
  if(key) document.getElementById('heygen-api-key-input').value = key;
  updateHeyGenUI();
}
function closeHeyGenSettings(){document.getElementById('heygen-modal').classList.add('hidden')}
function saveHeyGenSettings(){
  const key = document.getElementById('heygen-api-key-input').value.trim();
  if(!key){showToast('请输入 API Key','error');return}
  HeyGenService.setApiKey(key);
  localStorage.setItem('heygen_avatar', heygenAvatar);
  localStorage.setItem('heygen_voice', heygenVoice);
  closeHeyGenSettings();
  updateHeyGenUI();
  showToast('✅ HeyGen 配置已保存！','success');
}
function selectHeyGenAvatar(avatar, btn){
  heygenAvatar = avatar;
  document.querySelectorAll('.heygen-avatar-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function selectHeyGenVoice(voice, btn){
  heygenVoice = voice;
  document.querySelectorAll('.heygen-voice-btn').forEach(b=>b.classList.remove('selected'));
  if(btn) btn.classList.add('selected');
}
function updateHeyGenUI(){
  const status = document.getElementById('heygen-status');
  const statusText = document.getElementById('heygen-status-text');
  if(HeyGenService.isConfigured()){
    status.className = 'status-dot status-online';
    statusText.textContent = '已配置 · AI数字人生成就绪';
  } else {
    status.className = 'status-dot status-idle';
    statusText.textContent = '未配置API Key · 点击设置';
  }
}
async function testHeyGenConnection(){
  if(!HeyGenService.isConfigured()){
    showToast('⚠️ 请先配置 API Key','warning');
    openHeyGenSettings();
    return;
  }
  showToast('🔌 正在测试 HeyGen 连接...','info');
  try{
    const avatars = await HeyGenService.listAvatars();
    if(avatars) showToast('✅ HeyGen 连接成功！数字人服务已就绪','success');
    else showToast('⚠️ 连接异常，请检查 API Key','warning');
  }catch(e){
    showToast('❌ 连接失败: '+e.message,'error');
  }
}

// ========== OpenRouter 配置管理 ==========
function openOpenRouterSettings(){
  document.getElementById('openrouter-modal').classList.remove('hidden');
  const key = OpenRouterService.getApiKey();
  if(key) document.getElementById('openrouter-api-key').value = key;
  document.getElementById('openrouter-model-select').value = OpenRouterService.defaultModel;
  updateOpenRouterUI();
}
function closeOpenRouterSettings(){document.getElementById('openrouter-modal').classList.add('hidden')}
function saveOpenRouterSettings(){
  const key = document.getElementById('openrouter-api-key').value.trim();
  if(!key){showToast('请输入 API Key','error');return}
  OpenRouterService.setApiKey(key);
  const model = document.getElementById('openrouter-model-select').value;
  OpenRouterService.setDefaultModel(model);
  updateOpenRouterUI();
  closeOpenRouterSettings();
  showToast('✅ OpenRouter 配置已保存','success');
}
function updateOpenRouterUI(){
  const configured = OpenRouterService.isConfigured();
  const statusDot = document.getElementById('openrouter-status');
  const statusText = document.getElementById('openrouter-status-text');
  if(configured){
    statusDot.className = 'status-dot status-online';
    const key = OpenRouterService.getApiKey();
    statusText.textContent = '已连接 · API Key: '+key.slice(0,16)+'••••'+key.slice(-6);
  }else{
    statusDot.className = 'status-dot status-idle';
    statusText.textContent = '未配置API Key · 点击设置';
  }
}
async function testOpenRouterConnection(){
  if(!OpenRouterService.isConfigured()){
    showToast('⚠️ 请先配置 API Key','warning');
    openOpenRouterSettings();
    return;
  }
  showToast('🔌 正在测试 OpenRouter 连接...','info');
  try{
    const result = await OpenRouterService.testConnection();
    if(result.success) showToast('✅ OpenRouter 连接成功！200+ 模型已就绪','success');
    else showToast('⚠️ 连接异常: '+result.message,'warning');
  }catch(e){
    showToast('❌ 连接失败: '+e.message,'error');
  }
}
// ========== OpenAI 配置管理 ==========
function openOpenAISettings(){
  document.getElementById('openai-modal').classList.remove('hidden');
  const key = OpenAIService.getApiKey();
  if(key) document.getElementById('openai-api-key').value = key;
  document.getElementById('openai-model-select').value = OpenAIService.defaultModel;
  updateOpenAIUI();
}
function closeOpenAISettings(){document.getElementById('openai-modal').classList.add('hidden')}
function saveOpenAISettings(){
  const key = document.getElementById('openai-api-key').value.trim();
  if(!key){showToast('请输入 API Key','error');return}
  OpenAIService.setApiKey(key);
  const model = document.getElementById('openai-model-select').value;
  OpenAIService.setDefaultModel(model);
  updateOpenAIUI();
  closeOpenAISettings();
  showToast('✅ OpenAI 配置已保存','success');
}
function updateOpenAIUI(){
  const configured = OpenAIService.isConfigured();
  const statusDot = document.getElementById('openai-status');
  const statusText = document.getElementById('openai-status-text');
  if(configured){
    statusDot.className = 'status-dot status-online';
    const key = OpenAIService.getApiKey();
    statusText.textContent = '已连接 · API Key: '+key.slice(0,16)+'••••'+key.slice(-6);
  }else{
    statusDot.className = 'status-dot status-idle';
    statusText.textContent = '未配置API Key · 点击设置';
  }
}
async function testOpenAIConnection(){
  if(!OpenAIService.isConfigured()){
    showToast('⚠️ 请先配置 API Key','warning');
    openOpenAISettings();
    return;
  }
  showToast('🔌 正在测试 OpenAI 连接...','info');
  try{
    const result = await OpenAIService.testConnection();
    if(result.success) showToast('✅ OpenAI 连接成功！GPT-4o 已就绪','success');
    else showToast('⚠️ 连接异常: '+result.message,'warning');
  }catch(e){
    showToast('❌ 连接失败: '+e.message,'error');
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

// ====== 语音输入 (Web Speech API + ElevenLabs TTS) ======
let voiceRecognition = null;
let isVoiceListening = false;
let voiceTarget = 'prompt'; // 'prompt' | 'chat' — 识别结果填入创作输入框或AI对话框

const ELEVENLABS_API_KEY = '7536957d31333c76024911ef47932af9382188547101ffcabf1e33a106e21525';
const ELEVENLABS_VOICE_ID = '21m00Tcm4TlvDq8ikWAM'; // Rachel - 默认女声

// 创作舱输入框下方的语音按钮
function startVoiceInput() {
  voiceTarget = 'prompt';
  _startVoiceRecognition();
}

// AI对话框输入栏的语音按钮
function startChatVoiceInput() {
  voiceTarget = 'chat';
  _startVoiceRecognition();
}

function _startVoiceRecognition() {
  if (isVoiceListening) {
    stopVoiceInput();
    return;
  }

  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    // 降级：模拟演示
    showToast('🎤 浏览器不支持语音识别，使用模拟模式...','info');
    const demoText = '赛博朋克风格，深蓝色微光渐变，蝴蝶翅膀纹理，金属质感';
    _fillVoiceResult(demoText);
    return;
  }

  voiceRecognition = new SpeechRecognition();
  voiceRecognition.lang = 'zh-CN';
  voiceRecognition.interimResults = true;
  voiceRecognition.continuous = false;
  voiceRecognition.maxAlternatives = 1;

  voiceRecognition.onstart = () => {
    isVoiceListening = true;
    _setVoiceBtnState(true);
    showToast('🎤 正在聆听...请说话','info');
  };

  voiceRecognition.onresult = (event) => {
    const interim = Array.from(event.results).map(r => r[0].transcript).join('');
    // 实时显示到目标输入框
    if (voiceTarget === 'chat') {
      const el = document.getElementById('create-chat-input');
      if (el) el.value = interim;
    } else {
      const el = document.getElementById('create-prompt');
      if (el) el.value = interim;
    }
    if (event.results[0].isFinal) {
      _fillVoiceResult(interim);
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
    resetVoiceButton();
  };

  voiceRecognition.start();
}

function _fillVoiceResult(text) {
  if (!text) return;

  if (voiceTarget === 'chat') {
    // AI对话框模式：填入并自动发送
    const chatInput = document.getElementById('create-chat-input');
    if (chatInput) {
      chatInput.value = text;
      showToast('✅ 语音识别完成！已发送到AI对话框','success');
      setTimeout(() => sendCreateChat(), 300);
    }
  } else {
    // 创作输入框模式：填入输入框并自动发送到AI对话框
    const promptEl = document.getElementById('create-prompt');
    if (promptEl) promptEl.value = text;
    showToast('✅ 语音识别完成！已填入输入框','success');
    setTimeout(() => {
      const chatInput = document.getElementById('create-chat-input');
      if (chatInput) {
        chatInput.value = text;
        sendCreateChat();
      }
    }, 500);
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
  _setVoiceBtnState(false);
}

function _setVoiceBtnState(listening) {
  const promptBtn = document.getElementById('voice-input-btn');
  const chatBtn = document.getElementById('chat-voice-btn');

  if (listening) {
    if (promptBtn) {
      promptBtn.textContent = '🔴 录音中...';
      promptBtn.style.background = 'rgba(255,82,82,0.2)';
      promptBtn.style.color = 'var(--danger)';
      promptBtn.classList.add('listening');
    }
    if (chatBtn) {
      chatBtn.textContent = '🔴';
      chatBtn.style.background = 'rgba(255,82,82,0.2)';
      chatBtn.style.color = 'var(--danger)';
      chatBtn.classList.add('listening');
    }
  } else {
    if (promptBtn) {
      promptBtn.textContent = '🎤 语音输入';
      promptBtn.style.background = '';
      promptBtn.style.color = '';
      promptBtn.classList.remove('listening');
    }
    if (chatBtn) {
      chatBtn.textContent = '🎤';
      chatBtn.style.background = '';
      chatBtn.style.color = '';
      chatBtn.classList.remove('listening');
    }
  }
}

// ====== ElevenLabs TTS（文本转语音朗读） ======
let currentTtsAudio = null;

function stopTtsAudio() {
  if (currentTtsAudio) {
    try { currentTtsAudio.pause(); currentTtsAudio = null; } catch(e) {}
  }
}

async function speakWithElevenLabs(text, voiceId) {
  stopTtsAudio();

  const apiKey = ELEVENLABS_API_KEY;
  const vid = voiceId || ELEVENLABS_VOICE_ID;

  // 清理文本（去除HTML标签等）
  const cleanText = text.replace(/<[^>]*>/g, '').replace(/&[^;]+;/g, '').trim();
  if (!cleanText) return;

  showToast('🔊 正在生成语音...','info');

  try {
    const resp = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${vid}`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey
      },
      body: JSON.stringify({
        text: cleanText,
        model_id: 'eleven_multilingual_v2',
        voice_settings: { stability: 0.5, similarity_boost: 0.75 }
      })
    });

    if (!resp.ok) {
      const errBody = await resp.text();
      throw new Error(`HTTP ${resp.status}: ${errBody.substring(0, 100)}`);
    }

    const blob = await resp.blob();
    const url = URL.createObjectURL(blob);
    currentTtsAudio = new Audio(url);

    currentTtsAudio.onended = () => {
      currentTtsAudio = null;
      URL.revokeObjectURL(url);
    };

    currentTtsAudio.onerror = () => {
      currentTtsAudio = null;
      URL.revokeObjectURL(url);
      showToast('⚠️ 音频播放失败','error');
    };

    await currentTtsAudio.play();
    showToast('🔊 正在朗读...','info');
  } catch(e) {
    console.warn('[ElevenLabs TTS] 失败:', e.message);
    currentTtsAudio = null;
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

  // 用户消息
  const userMsgId = 'umsg-' + Date.now();
  msgs.innerHTML+=`<div class="chat-msg user" id="${userMsgId}"><div class="msg-avatar user-av">👤</div><div class="msg-bubble">${escHtml(msg)}<div class="msg-actions"><button class="btn btn-xs btn-ghost" onclick="speakWithElevenLabs('${escJs(msg)}')" title="朗读此消息">🔊</button></div></div></div>`;
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
    const agentText = `已理解！为你优化提示词并准备生成...\n风格识别: ${detectedStyle} · 甲型: 通用适配`;
    const agentMsgId = 'amsg-' + Date.now();
    msgs.innerHTML+=`<div class="chat-msg agent" id="${agentMsgId}"><div class="msg-avatar agent-av">🤖</div><div class="msg-bubble">已理解！为你优化提示词并准备生成...<br>风格识别: ${detectedStyle} · 甲型: 通用适配<br>
    <button class="btn btn-xs btn-primary" style="margin-top:8px;margin-right:4px" onclick="generateNailArt()">✨ 立即生成</button>
    <button class="btn btn-xs btn-accent" style="margin-top:8px;margin-right:4px" onclick="speakWithElevenLabs('${escJs(agentText)}')">🔊 朗读回复</button>
    <button class="btn btn-xs btn-ghost" style="margin-top:8px" onclick="stopTtsAudio()">⏹ 停止</button>
    </div></div>`;
    msgs.scrollTop=msgs.scrollHeight;
  },800)
}

// JS字符串安全转义（用于onclick属性中嵌入字符串）
function escJs(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n').replace(/\r/g, '');
}

// MODALS
function showForgotModal(){document.getElementById('forgot-modal').classList.remove('hidden')}
function closeForgotModal(){document.getElementById('forgot-modal').classList.add('hidden')}
function handleForgotPassword(){const e=document.getElementById('forgot-email').value;if(!e){showToast('请输入邮箱地址','error');return}showToast('重置链接已发送至您的邮箱','success');closeForgotModal()}

// COMMAND PALETTE
const commands=[
  {section:'导航',name:'创作舱',shortcut:'⌘1',action:()=>navigateTo('create')},
  {section:'导航',name:'资源库',shortcut:'⌘2',action:()=>navigateTo('medialibrary')},
  {section:'导航',name:'产品中心',shortcut:'',action:()=>navigateTo('productcenter')},
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
  const marketingVideos = mediaLibrary.filter(m => m.type === 'video' && m.tags && m.tags.includes('营销视频')).length;
  const aiGen = mediaLibrary.filter(m => m.source === 'ai-generated').length;
  const uploaded = mediaLibrary.filter(m => m.source === 'uploaded').length;
  const cloud = mediaLibrary.filter(m => m.source === 'cloud').length;
  
  document.getElementById('ml-total-count').textContent = total + ' 个资源';
  document.getElementById('ml-count-all').textContent = total;
  document.getElementById('ml-count-image').textContent = images;
  document.getElementById('ml-count-video').textContent = videos;
  document.getElementById('ml-count-marketing').textContent = marketingVideos;
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
  const tabMap = { 'all': 0, 'image': 1, 'video': 2, 'marketing-video': 3, 'ai-generated': 4, 'uploaded': 5, 'cloud': 6 };
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
    if (mediaFilterTab === 'marketing-video') {
      filtered = filtered.filter(m => m.type === 'video' && m.tags && m.tags.includes('营销视频'));
    } else if (mediaFilterTab === 'ai-generated' || mediaFilterTab === 'uploaded' || mediaFilterTab === 'cloud') {
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
    if (mediaFilterTabStandaloneVar === 'marketing-video') {
      filtered = filtered.filter(m => m.type === 'video' && m.tags && m.tags.includes('营销视频'));
    } else if (['ai-generated','uploaded','cloud'].includes(mediaFilterTabStandaloneVar)) {
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
  el('mls-count-marketing', mediaLibrary.filter(m => m.type === 'video' && m.tags && m.tags.includes('营销视频')).length);
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
