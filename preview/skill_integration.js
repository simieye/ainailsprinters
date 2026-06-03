// ================================================================
// Skill 集成管理系统 — 统一管理 AnyGen/HeyGen/自定义 Skills
// ================================================================

// 预置 Skill 注册表
const PRESET_SKILLS = [
  // === AnyGen Suite Skills ===
  {
    id: 'anygen-slide',
    name: 'AnyGen · PPT 生成',
    version: 'v2.0.0',
    icon: '📊',
    desc: 'AI 驱动的一键生成专业PPT/幻灯片，支持企业汇报、产品发布、教学课件',
    tags: ['AnyGen', 'PPT', '内容生成'],
    provider: 'anygen',
    operation: 'slide',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: true,
  },
  {
    id: 'anygen-doc',
    name: 'AnyGen · 文档生成',
    version: 'v2.0.0',
    icon: '📄',
    desc: 'AI 生成Word文档、PRD、白皮书、技术方案，支持多格式导出',
    tags: ['AnyGen', '文档', '内容生成'],
    provider: 'anygen',
    operation: 'doc',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: true,
  },
  {
    id: 'anygen-diagram',
    name: 'AnyGen · 图表生成',
    version: 'v2.0.0',
    icon: '📐',
    desc: '智能生成架构图、流程图、思维导图、ER图、UML图，支持专业/手绘风格',
    tags: ['AnyGen', '图表', '架构'],
    provider: 'anygen',
    operation: 'smart_draw',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: true,
  },
  {
    id: 'anygen-storybook',
    name: 'AnyGen · 故事书',
    version: 'v2.0.0',
    icon: '📖',
    desc: 'AI 创作精美故事书/绘本，适合品牌故事、产品介绍、营销内容',
    tags: ['AnyGen', '故事', '营销'],
    provider: 'anygen',
    operation: 'storybook',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'anygen-website',
    name: 'AnyGen · 网站生成',
    version: 'v2.0.0',
    icon: '🌐',
    desc: 'AI 快速生成落地页、官网、产品展示页，支持响应式设计',
    tags: ['AnyGen', '网站', '前端'],
    provider: 'anygen',
    operation: 'website',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'anygen-research',
    name: 'AnyGen · 深度研究',
    version: 'v2.0.0',
    icon: '🔬',
    desc: 'AI 驱动的市场调研、竞品分析、行业报告生成',
    tags: ['AnyGen', '研究', '分析'],
    provider: 'anygen',
    operation: 'deep_research',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'anygen-finance',
    name: 'AnyGen · 金融分析',
    version: 'v2.0.0',
    icon: '💰',
    desc: 'AI 财报分析、估值模型、金融研究报告生成',
    tags: ['AnyGen', '金融', '财报'],
    provider: 'anygen',
    operation: 'finance',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'anygen-data',
    name: 'AnyGen · 数据分析',
    version: 'v2.0.0',
    icon: '📈',
    desc: 'AI 数据分析与可视化，CSV/Excel数据自动生成图表和洞察',
    tags: ['AnyGen', '数据', '可视化'],
    provider: 'anygen',
    operation: 'data_analysis',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'anygen-designer',
    name: 'AnyGen · AI 设计',
    version: 'v2.0.0',
    icon: '🎨',
    desc: 'AI 图像设计、海报生成、Banner制作、社交媒体素材',
    tags: ['AnyGen', '设计', '图像'],
    provider: 'anygen',
    operation: 'ai-designer',
    apiKeyEnv: 'ANYGEN_API_KEY',
    enabled: false,
  },

  // === HeyGen Skills ===
  {
    id: 'heygen-video',
    name: 'HeyGen · 数字人视频',
    version: 'v2.0.0',
    icon: '🎬',
    desc: 'AI 数字人播报视频生成，适合产品介绍、营销推广、培训内容',
    tags: ['HeyGen', '视频', '数字人'],
    provider: 'heygen',
    capability: 'video',
    apiKeyEnv: 'HEYGEN_API_KEY',
    enabled: true,
  },
  {
    id: 'heygen-avatar',
    name: 'HeyGen · 定制数字人',
    version: 'v2.0.0',
    icon: '🧑‍💼',
    desc: '创建品牌专属 AI 数字人形象，支持真人克隆和虚拟角色',
    tags: ['HeyGen', '数字人', '品牌'],
    provider: 'heygen',
    capability: 'avatar',
    apiKeyEnv: 'HEYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'heygen-translate',
    name: 'HeyGen · 视频翻译',
    version: 'v2.0.0',
    icon: '🌍',
    desc: '视频多语言配音与字幕生成，助力全球市场推广',
    tags: ['HeyGen', '翻译', '本地化'],
    provider: 'heygen',
    capability: 'translate',
    apiKeyEnv: 'HEYGEN_API_KEY',
    enabled: false,
  },
  {
    id: 'heygen-streaming',
    name: 'HeyGen · 流式数字人',
    version: 'v2.0.0',
    icon: '🔴',
    desc: '实时交互式 AI 数字人，适用于在线客服、直播带货场景',
    tags: ['HeyGen', '直播', '实时'],
    provider: 'heygen',
    capability: 'streaming',
    apiKeyEnv: 'HEYGEN_API_KEY',
    enabled: false,
  },

  // === CreatOK Skills (生图/生视频) ===
  {
    id: 'creatok-image',
    name: 'CreatOK · AI 生图',
    version: 'v1.0.0',
    icon: '🖼️',
    desc: '通过文字描述生成高质量AI图片，支持多种风格、分辨率和参考图',
    tags: ['CreatOK', '生图', '图像生成'],
    provider: 'creatok',
    operation: 'generate-image',
    apiKeyEnv: 'CREATOK_API_KEY',
    enabled: true,
  },
  {
    id: 'creatok-video',
    name: 'CreatOK · AI 生视频',
    version: 'v1.0.0',
    icon: '🎥',
    desc: '将文字脚本/产品图转化为 TikTok 带货短视频，自动配音+字幕',
    tags: ['CreatOK', '生视频', 'TikTok'],
    provider: 'creatok',
    operation: 'generate-video',
    apiKeyEnv: 'CREATOK_API_KEY',
    enabled: true,
  },
  {
    id: 'creatok-analyze',
    name: 'CreatOK · 视频分析',
    version: 'v1.0.0',
    icon: '🔍',
    desc: '深度分析视频脚本结构、钩子、音乐、分镜，提供优化建议',
    tags: ['CreatOK', '分析', 'TikTok'],
    provider: 'creatok',
    operation: 'analyze-video',
    apiKeyEnv: 'CREATOK_API_KEY',
    enabled: false,
  },
  {
    id: 'creatok-recreate',
    name: 'CreatOK · 视频再创作',
    version: 'v1.0.0',
    icon: '🔄',
    desc: '基于参考视频重新创作，适配你的产品和品牌的专属带货视频',
    tags: ['CreatOK', '再创作', 'TikTok'],
    provider: 'creatok',
    operation: 'recreate-video',
    apiKeyEnv: 'CREATOK_API_KEY',
    enabled: false,
  },

  // === Nano Banana Pro Skills (Gemini 生图) ===
  {
    id: 'nanobanana-pro',
    name: 'Nano Banana Pro · AI 生图',
    version: 'v2.0.0',
    icon: '🍌',
    desc: '使用 Gemini 3 Pro Image 引擎的高质量AI图片生成，支持多种分辨率和比例',
    tags: ['NanoBanana', '生图', 'Gemini'],
    provider: 'nanobanana',
    operation: 'generate-image',
    apiKeyEnv: 'NANOBANANA_API_KEY',
    enabled: true,
  },

  // === Clipcat Skills (TikTok 电商视频) ===
  {
    id: 'clipcat-search',
    name: 'Clipcat · 视频搜索',
    version: 'v1.0.0',
    icon: '🔎',
    desc: '搜索 TikTok 热门带货视频，支持关键词、地区、排序筛选',
    tags: ['Clipcat', '搜索', 'TikTok'],
    provider: 'clipcat',
    operation: 'search',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: true,
  },
  {
    id: 'clipcat-replicate',
    name: 'Clipcat · 视频复刻',
    version: 'v1.0.0',
    icon: '📋',
    desc: '复刻热门视频风格，用你的产品图生成同款带货视频（消耗1积分）',
    tags: ['Clipcat', '复刻', 'TikTok'],
    provider: 'clipcat',
    operation: 'replicate',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: true,
  },
  {
    id: 'clipcat-product',
    name: 'Clipcat · 产品生视频',
    version: 'v1.0.0',
    icon: '📦',
    desc: '上传产品图，AI 自动生成 TikTok 带货短视频（消耗1积分）',
    tags: ['Clipcat', '产品', 'TikTok'],
    provider: 'clipcat',
    operation: 'product_video',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: false,
  },
  {
    id: 'clipcat-image',
    name: 'Clipcat · AI 生图',
    version: 'v1.0.0',
    icon: '🎨',
    desc: '使用 GPT Image 2 模型从文字生成高质量图片（消耗1积分）',
    tags: ['Clipcat', '生图', 'GPT Image'],
    provider: 'clipcat',
    operation: 'image',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: false,
  },
  {
    id: 'clipcat-breakdown',
    name: 'Clipcat · 视频拆解',
    version: 'v1.0.0',
    icon: '📝',
    desc: '分析视频脚本结构、分镜、音乐、钩子，提取创作要素',
    tags: ['Clipcat', '分析', '脚本'],
    provider: 'clipcat',
    operation: 'breakdown',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: false,
  },
  {
    id: 'clipcat-download',
    name: 'Clipcat · 视频下载',
    version: 'v1.0.0',
    icon: '⬇️',
    desc: '下载 TikTok/Douyin 视频原始文件',
    tags: ['Clipcat', '下载', 'TikTok'],
    provider: 'clipcat',
    operation: 'download',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: false,
  },
  {
    id: 'clipcat-shop',
    name: 'Clipcat · 商品搜索',
    version: 'v1.0.0',
    icon: '🛒',
    desc: '搜索 TikTok Shop 商品情报，分析竞品和市场趋势',
    tags: ['Clipcat', '商品', '市场'],
    provider: 'clipcat',
    operation: 'search_items',
    apiKeyEnv: 'CLIPCAT_API_KEY',
    enabled: false,
  },

  // === Revor Skills (外展服务) ===
  {
    id: 'revor-outreach',
    name: 'Revor · 智能外展',
    version: 'v1.0.0',
    icon: '📨',
    desc: '通过 LinkedIn/Email/WhatsApp 自动化外展，智能检测意图并起草内容',
    tags: ['Revor', '外展', 'LinkedIn'],
    provider: 'revor',
    operation: 'outreach',
    apiKeyEnv: 'REVOR_API_KEY',
    enabled: true,
  },
];

// 加载自定义 Skills（从 localStorage）
function loadCustomSkills() {
  try {
    return JSON.parse(localStorage.getItem('custom_skills') || '[]');
  } catch (e) {
    return [];
  }
}

function saveCustomSkills(skills) {
  localStorage.setItem('custom_skills', JSON.stringify(skills));
}

// 获取所有已安装的 Skills
function getAllInstalledSkills() {
  const enabledPresetIds = PRESET_SKILLS.filter(s => s.enabled).map(s => s.id);
  const stored = JSON.parse(localStorage.getItem('installed_skill_ids') || JSON.stringify(enabledPresetIds));
  const customSkills = loadCustomSkills();
  
  const presetInstalled = PRESET_SKILLS.filter(s => stored.includes(s.id));
  return [...presetInstalled, ...customSkills];
}

// 安装/卸载预置 Skill
function togglePresetSkill(skillId, enable) {
  const stored = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');
  if (enable) {
    if (!stored.includes(skillId)) stored.push(skillId);
  } else {
    const idx = stored.indexOf(skillId);
    if (idx !== -1) stored.splice(idx, 1);
  }
  localStorage.setItem('installed_skill_ids', JSON.stringify(stored));
}

// 渲染已安装 Skills 面板
function renderInstalledSkills() {
  const grid = document.getElementById('installed-skills-grid');
  const skills = getAllInstalledSkills();

  if (skills.length === 0) {
    grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;padding:40px;color:var(--text-tertiary)">📭 暂无已安装的 Skill，请从 Hub 市场或自定义添加</div>';
    return;
  }

  grid.innerHTML = skills.map(s => {
    const tagHtml = s.tags.map(t => {
      let cls = 'tag-accent';
      if (s.provider === 'anygen') cls = 'tag-gold';
      else if (s.provider === 'heygen') cls = 'tag-success';
      else if (s.provider === 'creatok') cls = 'tag-accent3';
      else if (s.provider === 'clipcat') cls = 'tag-info';
      else if (s.provider === 'revor') cls = 'tag-warning';
      else if (s.provider === 'nanobanana') cls = 'tag-accent2';
      else if (t === '自定义') cls = 'tag-accent2';
      return `<span class="tag ${cls}">${t}</span>`;
    }).join('');

    const configBtn = s.provider
      ? `<button class="btn btn-xs btn-secondary" onclick="openSkillConfig('${s.id}')">⚙</button>`
      : '';

    const useBtn = (() => {
      if (s.provider === 'anygen') return `<button class="btn btn-xs btn-primary" onclick="openAnyGenUsePanel('${s.operation}')">▶ 使用</button>`;
      if (s.provider === 'heygen') return `<button class="btn btn-xs btn-primary" onclick="openHeyGenUsePanel('${s.capability}')">▶ 使用</button>`;
      if (s.provider === 'creatok') return `<button class="btn btn-xs btn-primary" onclick="openCreatOKUsePanel('${s.operation}')">▶ 使用</button>`;
      if (s.provider === 'clipcat') return `<button class="btn btn-xs btn-primary" onclick="openClipcatUsePanel('${s.operation}')">▶ 使用</button>`;
      if (s.provider === 'revor') return `<button class="btn btn-xs btn-primary" onclick="openRevorUsePanel()">▶ 使用</button>`;
      if (s.provider === 'nanobanana') return `<button class="btn btn-xs btn-primary" onclick="navigateTo('create')">▶ 使用</button>`;
      return '';
    })();

    return `
    <div class="skill-card" id="skill-card-${s.id}">
      <div class="skill-header">
        <span class="skill-icon">${s.icon}</span>
        <div>
          <div class="skill-name">${s.name}</div>
          <div class="skill-version">${s.version}${s.provider ? ' · ' + s.provider.toUpperCase() : ''}</div>
        </div>
      </div>
      <div class="skill-desc">${s.desc}</div>
      <div class="skill-tags">${tagHtml}</div>
      <div class="skill-actions">
        ${configBtn}
        ${useBtn}
        ${!s.provider ? `<button class="btn btn-xs btn-danger" onclick="removeCustomSkill('${s.id}')">🗑</button>` : ''}
        <label class="toggle-switch">
          <input type="checkbox" ${s.enabled !== false ? 'checked' : ''} onchange="handleSkillToggle('${s.id}', this.checked)">
          <span class="toggle-slider"></span>
        </label>
      </div>
    </div>`;
  }).join('');
}

// Skill 开关处理
function handleSkillToggle(skillId, checked) {
  const presetPrefixes = ['anygen-', 'heygen-', 'creatok-', 'clipcat-', 'revor-', 'nanobanana-'];
  if (presetPrefixes.some(p => skillId.startsWith(p))) {
    togglePresetSkill(skillId, checked);
  }
  showToast(`Skill ${checked ? '已启用' : '已禁用'}`, checked ? 'success' : 'info');
}

// 移除自定义 Skill
function removeCustomSkill(skillId) {
  const skills = loadCustomSkills().filter(s => s.id !== skillId);
  saveCustomSkills(skills);
  renderInstalledSkills();
  showToast('Skill 已移除', 'info');
}

// ============ AnyGen 使用面板 ============
let anyGenCurrentOp = 'slide';

function openAnyGenUsePanel(operation) {
  anyGenCurrentOp = operation;
  const opInfo = AnyGenService.operations[operation];
  if (!opInfo) return;

  document.getElementById('anygen-panel-title').textContent = `${opInfo.icon} ${opInfo.name}`;
  document.getElementById('anygen-panel-desc').textContent = opInfo.desc || `AI 生成 ${opInfo.name}`;
  document.getElementById('anygen-prompt').value = '';
  document.getElementById('anygen-result').innerHTML = '';
  document.getElementById('anygen-use-panel').classList.remove('hidden');
}

function closeAnyGenPanel() {
  document.getElementById('anygen-use-panel').classList.add('hidden');
}

async function executeAnyGen() {
  const prompt = document.getElementById('anygen-prompt').value.trim();
  if (!prompt) { showToast('请输入生成描述', 'error'); return; }
  if (!AnyGenService.isConfigured()) { showToast('请先在配置中设置 AnyGen API Key', 'error'); openAnyGenConfig(); return; }

  const resultDiv = document.getElementById('anygen-result');
  resultDiv.innerHTML = '<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">⏳ AnyGen 正在生成中...</p></div>';

  try {
    showToast(`🔧 AnyGen 正在生成 ${AnyGenService.operations[anyGenCurrentOp].name}...`, 'info');
    const result = await AnyGenService.run(anyGenCurrentOp, prompt, (stage, msg) => {
      resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">${msg}</p></div>`;
    });

    // 下载文件
    const url = URL.createObjectURL(result.blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = result.filename;
    a.click();
    URL.revokeObjectURL(url);

    resultDiv.innerHTML = `
      <div style="text-align:center;padding:20px">
        <span style="font-size:48px">✅</span>
        <p style="color:var(--success);margin-top:10px">${result.operation.name} 生成完成！</p>
        <p style="color:var(--text-secondary);font-size:12px">文件: ${result.filename}</p>
        <button class="btn btn-xs btn-primary" style="margin-top:10px" onclick="document.querySelector('#anygen-result a')?.click()">📥 重新下载</button>
      </div>`;
    showToast(`✅ ${result.operation.name} 已生成并下载！`, 'success');
  } catch (err) {
    let msg = '生成失败';
    if (err.message.includes('ANYGEN_KEY_INVALID')) msg = 'API Key 无效';
    else if (err.message.includes('ANYGEN_NO_CREDITS')) msg = 'API 额度不足';
    else if (err.message.includes('ANYGEN_RATE_LIMIT')) msg = '请求过于频繁';
    else if (err.message.includes('网络')) msg = '网络连接失败';
    else if (err.message.includes('超时')) msg = '生成超时，请重试';

    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><span style="font-size:48px">❌</span><p style="color:var(--danger);margin-top:10px">${msg}</p><p style="color:var(--text-tertiary);font-size:11px">${err.message}</p></div>`;
    showToast('❌ ' + msg, 'error');
  }
}

// ============ HeyGen 使用面板 ============
let heyGenCurrentCap = 'video';

function openHeyGenUsePanel(capability) {
  heyGenCurrentCap = capability;
  const capInfo = HeyGenService.capabilities[capability];
  if (!capInfo) return;

  document.getElementById('heygen-panel-title').textContent = `${capInfo.icon} ${capInfo.name}`;
  document.getElementById('heygen-panel-desc').textContent = capInfo.desc;
  document.getElementById('heygen-script').value = '';
  document.getElementById('heygen-result').innerHTML = '';
  document.getElementById('heygen-use-panel').classList.remove('hidden');
}

function closeHeyGenPanel() {
  document.getElementById('heygen-use-panel').classList.add('hidden');
}

async function executeHeyGen() {
  const script = document.getElementById('heygen-script').value.trim();
  if (!script) { showToast('请输入视频脚本内容', 'error'); return; }
  if (!HeyGenService.isConfigured()) { showToast('请先在配置中设置 HeyGen API Key', 'error'); openHeyGenConfig(); return; }

  const resultDiv = document.getElementById('heygen-result');
  resultDiv.innerHTML = '<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">⏳ HeyGen 数字人视频生成中...（预计1-3分钟）</p></div>';

  try {
    showToast('🎬 HeyGen 数字人视频开始生成...', 'info');
    const result = await HeyGenService.createVideo({
      text: script,
      title: `AI Nails - ${new Date().toLocaleDateString()}`,
    });

    const videoId = result.data?.video_id || result.video_id;
    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">🎬 视频 ID: ${videoId}<br>正在等待渲染完成...</p></div>`;

    const videoData = await HeyGenService.pollVideo(videoId);

    const videoUrl = videoData.video_url || videoData.url;
    resultDiv.innerHTML = `
      <div style="text-align:center;padding:20px">
        <span style="font-size:48px">✅</span>
        <p style="color:var(--success);margin-top:10px">数字人视频生成完成！</p>
        ${videoUrl ? `<video src="${videoUrl}" controls style="max-width:100%;margin-top:10px;border-radius:8px"></video>
        <a href="${videoUrl}" target="_blank" class="btn btn-xs btn-primary" style="display:inline-block;margin-top:10px">🔗 打开视频</a>` : '<p style="color:var(--text-secondary)">视频链接生成中...</p>'}
      </div>`;
    showToast('✅ 数字人视频生成完成！', 'success');
  } catch (err) {
    let msg = '视频生成失败';
    if (err.message.includes('HEYGEN_KEY_INVALID')) msg = 'API Key 无效';
    else if (err.message.includes('HEYGEN_NO_CREDITS')) msg = 'API 额度不足';
    else if (err.message.includes('HEYGEN_RATE_LIMIT')) msg = '请求过于频繁';
    else if (err.message.includes('网络')) msg = '网络连接失败';
    else if (err.message.includes('超时')) msg = '生成超时';

    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><span style="font-size:48px">❌</span><p style="color:var(--danger);margin-top:10px">${msg}</p><p style="color:var(--text-tertiary);font-size:11px">${err.message}</p></div>`;
    showToast('❌ ' + msg, 'error');
  }
}

// ============ 配置面板 ============
function openSkillConfig(skillId) {
  const skill = PRESET_SKILLS.find(s => s.id === skillId);
  if (!skill) { showToast('Skill 未找到', 'error'); return; }

  if (skill.provider === 'anygen') openAnyGenConfig();
  else if (skill.provider === 'heygen') openHeyGenConfig();
  else if (skill.provider === 'creatok') openCreatOKConfig();
  else if (skill.provider === 'clipcat') openClipcatConfig();
  else if (skill.provider === 'revor') openRevorConfig();
  else if (skill.provider === 'nanobanana') { if (typeof openNanoBananaSettings === 'function') openNanoBananaSettings(); }
}

function openAnyGenConfig() {
  const key = AnyGenService.getApiKey();
  document.getElementById('anygen-config-key').value = key;
  document.getElementById('anygen-config-status').textContent = key ? '已配置' : '未配置';
  document.getElementById('anygen-config-status').style.color = key ? 'var(--success)' : 'var(--danger)';
  document.getElementById('anygen-config-modal').classList.remove('hidden');
}

function closeAnyGenConfig() {
  document.getElementById('anygen-config-modal').classList.add('hidden');
}

function saveAnyGenConfig() {
  const key = document.getElementById('anygen-config-key').value.trim();
  if (!key) { showToast('请输入 API Key', 'error'); return; }
  AnyGenService.setApiKey(key);
  closeAnyGenConfig();
  renderInstalledSkills();
  showToast('✅ AnyGen API Key 已保存！', 'success');
}

function openHeyGenConfig() {
  const key = HeyGenService.getApiKey();
  document.getElementById('heygen-config-key').value = key;
  document.getElementById('heygen-config-status').textContent = key ? '已配置' : '未配置';
  document.getElementById('heygen-config-status').style.color = key ? 'var(--success)' : 'var(--danger)';
  document.getElementById('heygen-config-modal').classList.remove('hidden');
}

function closeHeyGenConfig() {
  document.getElementById('heygen-config-modal').classList.add('hidden');
}

function saveHeyGenConfig() {
  const key = document.getElementById('heygen-config-key').value.trim();
  if (!key) { showToast('请输入 API Key', 'error'); return; }
  HeyGenService.setApiKey(key);
  closeHeyGenConfig();
  renderInstalledSkills();
  showToast('✅ HeyGen API Key 已保存！', 'success');
}

// ============ 增强的 Skill Hub 市场 ============
function renderSkillHub() {
  const hubGrid = document.getElementById('skill-hub-grid');
  if (!hubGrid) return;

  const installedIds = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');

  hubGrid.innerHTML = PRESET_SKILLS.map(s => {
    const isInstalled = installedIds.includes(s.id);
    const providerLabel = s.provider.toUpperCase();
    let providerCls = 'tag-gold';
    if (s.provider === 'heygen') providerCls = 'tag-success';
    if (s.provider === 'creatok') providerCls = 'tag-accent3';
    if (s.provider === 'clipcat') providerCls = 'tag-info';
    if (s.provider === 'revor') providerCls = 'tag-warning';
    if (s.provider === 'nanobanana') providerCls = 'tag-accent2';

    return `
    <div class="skill-card">
      <div class="skill-header">
        <span class="skill-icon">${s.icon}</span>
        <div>
          <div class="skill-name">${s.name}</div>
          <div class="skill-version">${s.version} · <span class="tag ${providerCls}" style="font-size:10px">${providerLabel}</span></div>
        </div>
      </div>
      <div class="skill-desc">${s.desc}</div>
      <div class="skill-tags">${s.tags.map(t => `<span class="tag tag-accent">${t}</span>`).join('')}</div>
      <div class="skill-actions">
        ${isInstalled
          ? `<button class="btn btn-xs btn-danger" onclick="togglePresetSkill('${s.id}',false);renderSkillHub();renderInstalledSkills();showToast('已卸载','info')">卸载</button>`
          : `<button class="btn btn-xs btn-primary" onclick="togglePresetSkill('${s.id}',true);renderSkillHub();renderInstalledSkills();showToast('已安装','success')">安装</button>`
        }
      </div>
    </div>`;
  }).join('');
}

// ============ 增强的自定义 Skill 创建 ============
function addCustomSkillV2() {
  const name = document.getElementById('custom-skill-name').value;
  const version = document.getElementById('custom-skill-version').value || 'v1.0.0';
  const desc = document.getElementById('custom-skill-desc').value;
  const tags = document.getElementById('custom-skill-tags').value;
  const prompt = document.getElementById('custom-skill-prompt').value;
  const triggers = document.getElementById('custom-skill-triggers').value;
  const provider = document.getElementById('custom-skill-provider').value || 'custom';

  if (!name || !desc) { showToast('请填写 Skill 名称和描述', 'error'); return }

  const skills = loadCustomSkills();
  const id = 'custom-' + Date.now();
  const tagList = tags ? tags.split(',').map(t => t.trim()) : [];
  if (provider === 'anygen') tagList.push('AnyGen');
  else if (provider === 'heygen') tagList.push('HeyGen');
  else if (provider === 'creatok') tagList.push('CreatOK');
  else if (provider === 'clipcat') tagList.push('Clipcat');
  else if (provider === 'revor') tagList.push('Revor');

  const iconMap = { anygen: '📊', heygen: '🎬', creatok: '🖼️', clipcat: '📦', revor: '📨', nanobanana: '🍌' };
  const newSkill = {
    id,
    name,
    version,
    icon: iconMap[provider] || '🔧',
    desc,
    tags: [...tagList, '自定义'],
    provider: provider === 'custom' ? null : provider,
    enabled: true,
    prompt,
    triggers,
    createdAt: new Date().toISOString(),
  };

  skills.push(newSkill);
  saveCustomSkills(skills);

  // 清空表单
  ['custom-skill-name', 'custom-skill-version', 'custom-skill-desc', 'custom-skill-tags', 'custom-skill-prompt', 'custom-skill-triggers'].forEach(id => {
    document.getElementById(id).value = '';
  });

  renderInstalledSkills();
  showToast(`✅ Skill "${name}" 已添加！`, 'success');
}

// ============ CreatOK 使用面板 ============
let creatokCurrentOp = 'generate-image';

function openCreatOKUsePanel(operation) {
  creatokCurrentOp = operation;
  const opInfo = CreatOKService.operations[operation];
  if (!opInfo) return;

  document.getElementById('creatok-panel-title').textContent = `${opInfo.icon} ${opInfo.name}`;
  document.getElementById('creatok-panel-desc').textContent = opInfo.desc || '';
  document.getElementById('creatok-prompt').value = '';
  document.getElementById('creatok-result').innerHTML = '';
  document.getElementById('creatok-use-panel').classList.remove('hidden');
}

function closeCreatOKPanel() {
  document.getElementById('creatok-use-panel').classList.add('hidden');
}

async function executeCreatOK() {
  const prompt = document.getElementById('creatok-prompt').value.trim();
  if (!prompt) { showToast('请输入内容描述', 'error'); return; }
  if (!CreatOKService.isConfigured()) { showToast('请先在配置中设置 CreatOK API Key', 'error'); openCreatOKConfig(); return; }

  const resultDiv = document.getElementById('creatok-result');
  resultDiv.innerHTML = '<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">⏳ CreatOK 正在生成中...</p></div>';

  try {
    const result = await CreatOKService.generate(creatokCurrentOp, { prompt });
    resultDiv.innerHTML = `
      <div style="text-align:center;padding:20px">
        <span style="font-size:48px">✅</span>
        <p style="color:var(--success);margin-top:10px">${CreatOKService.operations[creatokCurrentOp].name} 完成！</p>
        <pre style="background:var(--bg-tertiary);padding:12px;border-radius:8px;margin-top:10px;text-align:left;font-size:11px;overflow-x:auto;max-height:300px">${JSON.stringify(result, null, 2)}</pre>
      </div>`;
    showToast('✅ 生成完成！', 'success');
  } catch (err) {
    let msg = '生成失败';
    if (err.message.includes('CREATOK_KEY_INVALID')) msg = 'API Key 无效';
    else if (err.message.includes('CREATOK_NO_CREDITS')) msg = 'API 额度不足';
    else if (err.message.includes('CREATOK_RATE_LIMIT')) msg = '请求过于频繁';
    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><span style="font-size:48px">❌</span><p style="color:var(--danger);margin-top:10px">${msg}</p><p style="color:var(--text-tertiary);font-size:11px">${err.message}</p></div>`;
    showToast('❌ ' + msg, 'error');
  }
}

// ============ Clipcat 使用面板 ============
let clipcatCurrentOp = 'search';

function openClipcatUsePanel(operation) {
  clipcatCurrentOp = operation;
  const capInfo = ClipcatService.capabilities[operation];
  if (!capInfo) return;

  document.getElementById('clipcat-panel-title').textContent = `${capInfo.icon} ${capInfo.name}`;
  document.getElementById('clipcat-panel-desc').textContent = capInfo.desc || '';
  document.getElementById('clipcat-prompt').value = '';
  document.getElementById('clipcat-result').innerHTML = '';
  document.getElementById('clipcat-use-panel').classList.remove('hidden');
}

function closeClipcatPanel() {
  document.getElementById('clipcat-use-panel').classList.add('hidden');
}

async function executeClipcat() {
  const prompt = document.getElementById('clipcat-prompt').value.trim();
  if (!prompt) { showToast('请输入内容', 'error'); return; }
  if (!ClipcatService.isConfigured()) { showToast('请先在配置中设置 Clipcat API Key', 'error'); openClipcatConfig(); return; }

  const resultDiv = document.getElementById('clipcat-result');
  const capInfo = ClipcatService.capabilities[clipcatCurrentOp];

  // 消耗积分的操作给出提示
  if (capInfo.creditCost > 0) {
    showToast(`⚠️ 此操作将消耗 ${capInfo.creditCost} 积分`, 'warning');
  }

  resultDiv.innerHTML = '<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">⏳ Clipcat 正在处理中...</p></div>';

  try {
    // 使用模拟模式（展示UI交互）
    const result = await ClipcatService.simulateCliCall(clipcatCurrentOp, prompt);

    let resultHtml = `<div style="text-align:center;padding:20px"><span style="font-size:48px">✅</span><p style="color:var(--success);margin-top:10px">${capInfo.name} 完成！</p>`;

    if (result.videos) {
      resultHtml += `<div style="text-align:left;margin-top:10px">${result.videos.map(v =>
        `<div style="background:var(--bg-tertiary);padding:10px;border-radius:6px;margin-bottom:8px">
          <div style="font-weight:600;font-size:13px">${v.title}</div>
          <div style="color:var(--text-secondary);font-size:11px">▶ ${v.plays} · ❤ ${v.likes}</div>
        </div>`
      ).join('')}</div>`;
    } else if (result.items) {
      resultHtml += `<div style="text-align:left;margin-top:10px">${result.items.map(i =>
        `<div style="background:var(--bg-tertiary);padding:10px;border-radius:6px;margin-bottom:8px">
          <div style="font-weight:600;font-size:13px">${i.name}</div>
          <div style="color:var(--text-secondary);font-size:11px">💰 ${i.price} · 📦 ${i.sales} · ⭐ ${i.rating}</div>
        </div>`
      ).join('')}</div>`;
    } else if (result.script) {
      resultHtml += `<pre style="background:var(--bg-tertiary);padding:12px;border-radius:8px;margin-top:10px;text-align:left;font-size:11px;white-space:pre-wrap">${result.script}</pre>`;
    } else if (result.task_id) {
      resultHtml += `<div style="background:var(--bg-tertiary);padding:12px;border-radius:8px;margin-top:10px">
        <div style="font-size:12px;color:var(--text-secondary)">任务ID: ${result.task_id}</div>
        <div style="font-size:12px;color:var(--accent);margin-top:4px">预计 ${result.estimated_time} 完成</div>
        <div style="font-size:11px;color:var(--text-tertiary);margin-top:4px">提示: 可使用 clipcat query_task 查询任务状态</div>
      </div>`;
    } else if (result.url) {
      resultHtml += `<a href="${result.url}" target="_blank" class="btn btn-xs btn-primary" style="display:inline-block;margin-top:10px">🔗 下载视频</a>`;
    }

    resultHtml += '</div>';
    resultDiv.innerHTML = resultHtml;
    showToast('✅ 处理完成！', 'success');
  } catch (err) {
    let msg = '处理失败';
    if (err.message.includes('CLIPCAT_KEY_INVALID')) msg = 'API Key 无效';
    else if (err.message.includes('CLIPCAT_NO_CREDITS')) msg = 'API 额度不足';
    else if (err.message.includes('CLIPCAT_RATE_LIMIT')) msg = '请求过于频繁';
    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><span style="font-size:48px">❌</span><p style="color:var(--danger);margin-top:10px">${msg}</p><p style="color:var(--text-tertiary);font-size:11px">${err.message}</p></div>`;
    showToast('❌ ' + msg, 'error');
  }
}

// ============ Revor 使用面板 ============
function openRevorUsePanel() {
  document.getElementById('revor-recipient').value = '';
  document.getElementById('revor-message').value = '';
  document.getElementById('revor-channel').value = 'linkedin';
  document.getElementById('revor-result').innerHTML = '';
  document.getElementById('revor-use-panel').classList.remove('hidden');
}

function closeRevorPanel() {
  document.getElementById('revor-use-panel').classList.add('hidden');
}

async function executeRevor() {
  const recipient = document.getElementById('revor-recipient').value.trim();
  const message = document.getElementById('revor-message').value.trim();
  const channel = document.getElementById('revor-channel').value;

  if (!recipient) { showToast('请输入目标联系人', 'error'); return; }
  if (!message) { showToast('请输入外展消息内容', 'error'); return; }
  if (!RevorService.isConfigured()) { showToast('请先在配置中设置 Revor API Key', 'error'); openRevorConfig(); return; }

  const resultDiv = document.getElementById('revor-result');
  resultDiv.innerHTML = '<div style="text-align:center;padding:20px"><div class="spinner"></div><p style="margin-top:10px;color:var(--text-secondary)">⏳ Revor 正在发送外展消息...</p></div>';

  try {
    const result = await RevorService.dispatchOutreach({ channel, recipient, message });
    resultDiv.innerHTML = `
      <div style="text-align:center;padding:20px">
        <span style="font-size:48px">✅</span>
        <p style="color:var(--success);margin-top:10px">外展消息已通过 ${channel.toUpperCase()} 发送！</p>
        <pre style="background:var(--bg-tertiary);padding:12px;border-radius:8px;margin-top:10px;text-align:left;font-size:11px;overflow-x:auto;max-height:200px">${JSON.stringify(result, null, 2)}</pre>
      </div>`;
    showToast('✅ 外展消息已发送！', 'success');
  } catch (err) {
    let msg = '发送失败';
    if (err.message.includes('REVOR_KEY_INVALID')) msg = 'API Key 无效';
    else if (err.message.includes('REVOR_RATE_LIMIT')) msg = '请求过于频繁';
    resultDiv.innerHTML = `<div style="text-align:center;padding:20px"><span style="font-size:48px">❌</span><p style="color:var(--danger);margin-top:10px">${msg}</p><p style="color:var(--text-tertiary);font-size:11px">${err.message}</p></div>`;
    showToast('❌ ' + msg, 'error');
  }
}

// ============ CreatOK 配置面板 ============
function openCreatOKConfig() {
  const key = CreatOKService.getApiKey();
  document.getElementById('creatok-config-key').value = key;
  document.getElementById('creatok-config-status').textContent = key ? '已配置' : '未配置';
  document.getElementById('creatok-config-status').style.color = key ? 'var(--success)' : 'var(--danger)';
  document.getElementById('creatok-config-modal').classList.remove('hidden');
}

function closeCreatOKConfig() {
  document.getElementById('creatok-config-modal').classList.add('hidden');
}

function saveCreatOKConfig() {
  const key = document.getElementById('creatok-config-key').value.trim();
  if (!key) { showToast('请输入 API Key', 'error'); return; }
  CreatOKService.setApiKey(key);
  closeCreatOKConfig();
  renderInstalledSkills();
  showToast('✅ CreatOK API Key 已保存！', 'success');
}

// ============ Clipcat 配置面板 ============
function openClipcatConfig() {
  const key = ClipcatService.getApiKey();
  document.getElementById('clipcat-config-key').value = key;
  document.getElementById('clipcat-config-status').textContent = key ? '已配置' : '未配置';
  document.getElementById('clipcat-config-status').style.color = key ? 'var(--success)' : 'var(--danger)';
  document.getElementById('clipcat-config-modal').classList.remove('hidden');
}

function closeClipcatConfig() {
  document.getElementById('clipcat-config-modal').classList.add('hidden');
}

function saveClipcatConfig() {
  const key = document.getElementById('clipcat-config-key').value.trim();
  if (!key) { showToast('请输入 API Key', 'error'); return; }
  ClipcatService.setApiKey(key);
  closeClipcatConfig();
  renderInstalledSkills();
  showToast('✅ Clipcat API Key 已保存！', 'success');
}

// ============ Revor 配置面板 ============
function openRevorConfig() {
  const key = RevorService.getApiKey();
  document.getElementById('revor-config-key').value = key;
  document.getElementById('revor-config-status').textContent = key ? '已配置' : '未配置';
  document.getElementById('revor-config-status').style.color = key ? 'var(--success)' : 'var(--danger)';
  document.getElementById('revor-config-modal').classList.remove('hidden');
}

function closeRevorConfig() {
  document.getElementById('revor-config-modal').classList.add('hidden');
}

function saveRevorConfig() {
  const key = document.getElementById('revor-config-key').value.trim();
  if (!key) { showToast('请输入 API Key', 'error'); return; }
  RevorService.setApiKey(key);
  closeRevorConfig();
  renderInstalledSkills();
  showToast('✅ Revor API Key 已保存！', 'success');
}

// ============ 创作舱 · 一键添加生图 Skill ============
// 所有与生图相关的 Skill ID 列表
const IMAGE_SKILL_IDS = [
  'creatok-image',
  'clipcat-image',
  'nanobanana-pro',
  'creatok-video',
];

// Skill ID 到 chip 元素的映射信息
const IMAGE_SKILL_INFO = {
  'creatok-image': { icon: '🖼️', name: 'CreatOK 生图', provider: 'CreatOK', providerCls: 'badge-creatok' },
  'clipcat-image': { icon: '🎨', name: 'Clipcat 生图', provider: 'Clipcat', providerCls: 'badge-clipcat' },
  'nanobanana-pro': { icon: '🍌', name: 'Nano Banana', provider: 'NanoBanana', providerCls: 'badge-nano' },
  'creatok-video': { icon: '🎥', name: 'CreatOK 生视频', provider: 'CreatOK', providerCls: 'badge-creatok' },
};

// 刷新创作舱 Skill 安装状态
function refreshQuickAddChips() {
  const installedIds = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');
  const customSkills = JSON.parse(localStorage.getItem('custom_skills') || '[]');
  const customIds = customSkills.map(s => s.id);

  IMAGE_SKILL_IDS.forEach(skillId => {
    const chip = document.querySelector(`.quick-add-chip[data-skill-id="${skillId}"]`);
    if (!chip) return;

    const isInstalled = installedIds.includes(skillId) || customIds.includes(skillId);
    const statusEl = chip.querySelector('.chip-status');

    if (isInstalled) {
      chip.classList.add('installed');
      if (statusEl) statusEl.textContent = '✓ 已安装';
    } else {
      chip.classList.remove('installed');
      if (statusEl) statusEl.textContent = '未安装';
    }
  });

  // 更新一键安装按钮状态
  updateQuickAddAllBtn();
}

// 更新一键安装全部按钮的状态
function updateQuickAddAllBtn() {
  const btn = document.getElementById('quick-add-all-btn');
  if (!btn) return;

  const installedIds = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');
  const customSkills = JSON.parse(localStorage.getItem('custom_skills') || '[]');
  const customIds = customSkills.map(s => s.id);

  const allInstalled = IMAGE_SKILL_IDS.every(id => installedIds.includes(id) || customIds.includes(id));

  if (allInstalled) {
    btn.innerHTML = '<span class="btn-text">✅ 全部生图 Skill 已就绪</span><span class="btn-spinner"></span>';
    btn.disabled = true;
    btn.style.opacity = '0.6';
    btn.style.cursor = 'default';
  } else {
    btn.innerHTML = '<span class="btn-text">🚀 一键安装全部生图 Skill</span><span class="btn-spinner"></span>';
    btn.disabled = false;
    btn.style.opacity = '1';
    btn.style.cursor = 'pointer';
  }
}

// 单个 Skill 快速安装
function quickAddImageSkill(skillId) {
  const installedIds = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');
  const customSkills = JSON.parse(localStorage.getItem('custom_skills') || '[]');
  const customIds = customSkills.map(s => s.id);

  if (installedIds.includes(skillId) || customIds.includes(skillId)) {
    showQuickAddToast(`"${IMAGE_SKILL_INFO[skillId]?.name || skillId}" 已经安装过了`, 'info');
    return;
  }

  // 预置 Skill 直接加入 installed_skill_ids（包括 nanobanana-pro，现在已在 PRESET_SKILLS 中）
  if (!installedIds.includes(skillId)) {
    installedIds.push(skillId);
    localStorage.setItem('installed_skill_ids', JSON.stringify(installedIds));
  }

  const info = IMAGE_SKILL_INFO[skillId];
  showQuickAddToast(`✅ "${info?.name || skillId}" 安装成功！`, 'success');
  refreshQuickAddChips();

  // 同步刷新智能体页面
  if (typeof renderInstalledSkills === 'function') renderInstalledSkills();
  if (typeof renderSkillHub === 'function') renderSkillHub();
}

// 一键安装全部生图 Skill
function quickAddAllImageSkills() {
  const btn = document.getElementById('quick-add-all-btn');
  if (!btn) return;

  const installedIds = JSON.parse(localStorage.getItem('installed_skill_ids') || '[]');
  const customSkills = JSON.parse(localStorage.getItem('custom_skills') || '[]');
  const customIds = customSkills.map(s => s.id);

  const toInstall = IMAGE_SKILL_IDS.filter(id => !installedIds.includes(id) && !customIds.includes(id));

  if (toInstall.length === 0) {
    showQuickAddToast('所有生图 Skill 已经安装完毕 ✨', 'info');
    refreshQuickAddChips();
    return;
  }

  // 显示加载状态
  btn.classList.add('loading');

  let addedCount = 0;
  const addedNames = [];

  // 逐个安装（带延迟动画效果）
  let delay = 0;
  toInstall.forEach((skillId, index) => {
    setTimeout(() => {
      // 所有生图 Skill 都是预置 Skill，统一通过 installed_skill_ids 管理
      if (!installedIds.includes(skillId)) {
        installedIds.push(skillId);
        localStorage.setItem('installed_skill_ids', JSON.stringify(installedIds));
      }

      addedCount++;
      const info = IMAGE_SKILL_INFO[skillId];
      if (info) addedNames.push(info.name);

      // 实时更新 chip 状态
      const chip = document.querySelector(`.quick-add-chip[data-skill-id="${skillId}"]`);
      if (chip) {
        chip.classList.add('installed');
        const statusEl = chip.querySelector('.chip-status');
        if (statusEl) statusEl.textContent = '✓ 已安装';
      }

      // 最后一个安装完成
      if (index === toInstall.length - 1) {
        setTimeout(() => {
          btn.classList.remove('loading');
          updateQuickAddAllBtn();
          showQuickAddToast(`🎉 成功安装 ${addedCount} 个生图 Skill：${addedNames.join('、')}`, 'success');

          // 同步刷新智能体页面
          if (typeof renderInstalledSkills === 'function') renderInstalledSkills();
          if (typeof renderSkillHub === 'function') renderSkillHub();
        }, 300);
      }
    }, delay);
    delay += 400; // 每个 Skill 间隔 400ms 动画
  });
}

// Toast 提示（用于创作舱）
function showQuickAddToast(msg, type) {
  // 移除已有 toast
  const existing = document.querySelector('.quick-add-toast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.className = `quick-add-toast ${type}`;
  toast.textContent = msg;
  document.body.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity .3s';
    setTimeout(() => toast.remove(), 300);
  }, 2500);
}

// 导出到全局
window.renderInstalledSkills = renderInstalledSkills;
window.renderSkillHub = renderSkillHub;
window.getAllInstalledSkills = getAllInstalledSkills;
window.togglePresetSkill = togglePresetSkill;
window.addCustomSkillV2 = addCustomSkillV2;
window.removeCustomSkill = removeCustomSkill;
window.handleSkillToggle = handleSkillToggle;
window.openSkillConfig = openSkillConfig;
window.openAnyGenConfig = openAnyGenConfig;
window.closeAnyGenConfig = closeAnyGenConfig;
window.saveAnyGenConfig = saveAnyGenConfig;
window.openHeyGenConfig = openHeyGenConfig;
window.closeHeyGenConfig = closeHeyGenConfig;
window.saveHeyGenConfig = saveHeyGenConfig;
window.openAnyGenUsePanel = openAnyGenUsePanel;
window.closeAnyGenPanel = closeAnyGenPanel;
window.executeAnyGen = executeAnyGen;
window.openHeyGenUsePanel = openHeyGenUsePanel;
window.closeHeyGenPanel = closeHeyGenPanel;
window.executeHeyGen = executeHeyGen;
window.openCreatOKUsePanel = openCreatOKUsePanel;
window.closeCreatOKPanel = closeCreatOKPanel;
window.executeCreatOK = executeCreatOK;
window.openCreatOKConfig = openCreatOKConfig;
window.closeCreatOKConfig = closeCreatOKConfig;
window.saveCreatOKConfig = saveCreatOKConfig;
window.openClipcatUsePanel = openClipcatUsePanel;
window.closeClipcatPanel = closeClipcatPanel;
window.executeClipcat = executeClipcat;
window.openClipcatConfig = openClipcatConfig;
window.closeClipcatConfig = closeClipcatConfig;
window.saveClipcatConfig = saveClipcatConfig;
window.openRevorUsePanel = openRevorUsePanel;
window.closeRevorPanel = closeRevorPanel;
window.executeRevor = executeRevor;
window.openRevorConfig = openRevorConfig;
window.closeRevorConfig = closeRevorConfig;
window.saveRevorConfig = saveRevorConfig;
window.quickAddImageSkill = quickAddImageSkill;
window.quickAddAllImageSkills = quickAddAllImageSkills;
window.refreshQuickAddChips = refreshQuickAddChips;
window.showQuickAddToast = showQuickAddToast;

// ============ 初始化 ============
document.addEventListener('DOMContentLoaded', () => {
  // 自动配置预置 API Keys（从环境变量/配置）
  if (window.__ANYGEN_API_KEY__ && !AnyGenService.isConfigured()) {
    AnyGenService.setApiKey(window.__ANYGEN_API_KEY__);
  }
  if (window.__HEYGEN_API_KEY__ && !HeyGenService.isConfigured()) {
    HeyGenService.setApiKey(window.__HEYGEN_API_KEY__);
  }
  if (window.__CLIPCAT_API_KEY__ && !ClipcatService.isConfigured()) {
    ClipcatService.setApiKey(window.__CLIPCAT_API_KEY__);
  }

  // 初始化创作舱 Skill 快速添加面板状态
  if (typeof refreshQuickAddChips === 'function') {
    refreshQuickAddChips();
  }
});
