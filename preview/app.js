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
  const names={create:'创作舱 · TALK TO CREATE',device:'龙虾智控 · 设备仪表盘',community:'全球创作者社区',payment:'支付中心',agents:'智能体集群 · Skill 管理',providers:'AI 大模型提供商',openclaw:'OpenClaw 控制台',admin:'管理后台',settings:'设置'};
  document.getElementById('titlebar-page-name').textContent=names[page]||page;
}
function toggleSidebar(){sidebarCollapsed=!sidebarCollapsed;document.getElementById('sidebar').classList.toggle('collapsed',sidebarCollapsed);document.querySelector('.sidebar-collapse-btn').textContent=sidebarCollapsed?'▶':'◀ 收起菜单'}

// DEVICE
function switchDeviceMode(mode){document.querySelectorAll('#page-device .auth-tab').forEach(el=>{el.classList.toggle('active',(mode==='b2c'&&el.textContent.includes('B2C'))||(mode==='b2b'&&el.textContent.includes('B2B')))});document.getElementById('device-b2c').classList.toggle('hidden',mode!=='b2c');document.getElementById('device-b2b').classList.toggle('hidden',mode!=='b2b')}

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
function switchAgentTab(tab){document.querySelectorAll('#page-agents .page-tab').forEach((el,i)=>{el.classList.toggle('active',['installed','hub','custom','chat'][i]===tab)});document.getElementById('agent-installed').classList.toggle('hidden',tab!=='installed');document.getElementById('agent-hub').classList.toggle('hidden',tab!=='hub');document.getElementById('agent-custom').classList.toggle('hidden',tab!=='custom');document.getElementById('agent-chat').classList.toggle('hidden',tab!=='chat')}

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
  const names={openai:'OpenAI',anthropic:'Anthropic',google:'Google Gemini',deepseek:'DeepSeek',qwen:'通义千问',custom:'自定义端点'};
  document.getElementById('default-provider-name').textContent=names[provider]||provider;
  document.getElementById('status-provider').textContent=provider==='openai'?'GPT-4o':provider==='anthropic'?'Claude':provider==='google'?'Gemini':provider==='deepseek'?'DeepSeek':provider==='qwen'?'Qwen':'Custom';
  document.querySelectorAll('.provider-card').forEach(c=>c.classList.remove('active-provider'));
  const card=document.getElementById('provider-'+provider);
  if(card)card.classList.add('active-provider');
  showToast(`默认提供商已切换至 ${names[provider]}`,'success');
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

// CREATE - AI generation
function generateNailArt(){
  const prompt=document.getElementById('create-prompt').value;
  if(!prompt){showToast('请先描述你想要的甲面设计','error');return}
  showToast('✨ AI 正在生成... OpenClaw 解析意图 → nanobanana 3.0 图案重构 → 甲型自适应形变 → 1200 DPI 渲染','info');
  const preview=document.getElementById('prompt-preview-card');
  preview.style.display='block';
  document.getElementById('optimized-prompt').textContent=`"${prompt}" — 经过 ${defaultProvider==='openai'?'GPT-4o':defaultProvider==='anthropic'?'Claude 3.5':defaultProvider==='google'?'Gemini 2.0':defaultProvider} 优化，分辨率 1200 DPI，甲型自适应拓扑形变`;
  document.getElementById('prompt-tags').innerHTML='<span class="tag tag-accent">🎯 AI优化</span><span class="tag" style="background:rgba(180,76,255,0.12);color:var(--accent2)">94% 置信度</span><span class="tag tag-success">0.8s</span>';
  document.getElementById('result-grid').style.display='grid';
}

function startVoiceInput(){showToast('🎤 语音输入已激活，请说话...','info');setTimeout(()=>{document.getElementById('create-prompt').value='赛博朋克风格，深蓝色微光渐变，蝴蝶翅膀纹理，金属质感';showToast('语音识别完成！','success')},2000)}
function triggerImageUpload(){document.getElementById('image-upload-input').click()}
function handleImageUpload(e){const file=e.target.files[0];if(file){const reader=new FileReader();reader.onload=function(ev){document.getElementById('upload-preview-img').src=ev.target.result;document.getElementById('upload-preview').style.display='block'};reader.readAsDataURL(file);showToast('图片已上传，AI 将以此作为参考','success')}}
function clearImageUpload(){document.getElementById('upload-preview').style.display='none';document.getElementById('image-upload-input').value=''}

function showStylePicker(){document.getElementById('style-modal').classList.remove('hidden')}
function closeStyleModal(){document.getElementById('style-modal').classList.add('hidden')}
function selectStyle(style){document.getElementById('create-prompt').value=style+'风格美甲设计';closeStyleModal();showToast(`已选择风格: ${style}`,'success')}

function sendCreateChat(){
  const input=document.getElementById('create-chat-input');
  const msg=input.value.trim();
  if(!msg)return;
  const msgs=document.getElementById('create-chat-msgs');
  msgs.innerHTML+=`<div class="chat-msg user"><div class="msg-avatar user-av">👤</div><div class="msg-bubble">${msg}</div></div>`;
  input.value='';msgs.scrollTop=msgs.scrollHeight;
  setTimeout(()=>{
    document.getElementById('create-prompt').value=msg;
    msgs.innerHTML+=`<div class="chat-msg agent"><div class="msg-avatar agent-av">🤖</div><div class="msg-bubble">已理解！为你优化提示词并准备生成...<br>风格识别: ${msg.includes('赛博')?'赛博朋克':msg.includes('花')?'花卉':msg.includes('简约')?'极简':'自定义'} · 甲型: 通用适配<br><button class="btn btn-xs btn-primary" style="margin-top:8px" onclick="generateNailArt()">✨ 立即生成</button></div></div>`;
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
  {section:'导航',name:'龙虾智控',shortcut:'⌘2',action:()=>navigateTo('device')},
  {section:'导航',name:'社区',shortcut:'⌘3',action:()=>navigateTo('community')},
  {section:'导航',name:'支付中心',shortcut:'⌘4',action:()=>navigateTo('payment')},
  {section:'导航',name:'智能体集群',shortcut:'⌘5',action:()=>navigateTo('agents')},
  {section:'导航',name:'模型提供商',shortcut:'⌘6',action:()=>navigateTo('providers')},
  {section:'导航',name:'OpenClaw控制台',shortcut:'⌘7',action:()=>navigateTo('openclaw')},
  {section:'导航',name:'管理后台',shortcut:'⌘8',action:()=>navigateTo('admin')},
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

// TOAST
function showToast(msg,type='info'){const c=document.getElementById('toast-container');const t=document.createElement('div');t.className=`toast toast-${type}`;t.textContent=msg;c.appendChild(t);setTimeout(()=>t.remove(),2500)}

// STATUS BAR
function updateStatusTime(){document.getElementById('status-time').textContent=new Date().toLocaleTimeString('zh-CN',{hour:'2-digit',minute:'2-digit'})}

// KEYBOARD SHORTCUTS
document.addEventListener('keydown',(e)=>{if(!isLoggedIn)return;const mod=e.metaKey||e.ctrlKey;if(mod&&e.key==='k'){e.preventDefault();openCommandPalette();return}if(mod&&e.key==='\\'){e.preventDefault();toggleSidebar();return}if(mod&&e.key===','){e.preventDefault();navigateTo('settings');return}if(mod&&e.key>='1'&&e.key<='8'){e.preventDefault();const pages=['create','device','community','payment','agents','providers','openclaw','admin'];navigateTo(pages[parseInt(e.key)-1])}});
document.addEventListener('click',(e)=>{const p=document.getElementById('command-palette');if(!p.classList.contains('hidden')&&!p.contains(e.target))closeCommandPalette()});

// INIT
updatePaymentSummary();
updateStatusTime();

// Electron IPC
if(window.electronAPI){
  window.electronAPI.onNavigate((page)=>navigateTo(page));
  window.electronAPI.onToggleSidebar(()=>toggleSidebar());
  window.electronAPI.onCommandPalette(()=>openCommandPalette());
}
