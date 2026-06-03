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
  // 进入创作舱时刷新 Skill 快速安装状态
  if (page === 'create' && typeof refreshQuickAddChips === 'function') {
    setTimeout(() => refreshQuickAddChips(), 100);
  }
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
      resultGrid.innerHTML = images.map((img,i)=>`
        <div class="result-item" style="position:relative">
          <img src="data:${img.mimeType};base64,${img.base64}" alt="AI Nail Design ${i+1}" loading="lazy">
          <div class="download-overlay" onclick="downloadNailImage('${img.base64}','${img.mimeType}','nail-design-${i+1}')">⬇ 下载</div>
        </div>
      `).join('');
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
  }

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
