// ================================================================
// Monid Service — 统一工具发现与执行引擎
// 数百个工具：网页抓取、数据丰富、社交媒体、产品/公司/人物数据、
// 搜索结果、内容监控、API 访问等
// 官网: https://monid.ai
// ================================================================

const MonidService = {
  _apiKey: null,
  _apiBase: 'https://api.monid.ai/v1',

  // 核心能力分类
  capabilities: {
    'discover': {
      id: 'discover',
      name: '工具发现',
      icon: '🔍',
      desc: '搜索并发现可用的工具和 API，数百个端点可供选择',
      command: 'monid discover',
    },
    'web-scrape': {
      id: 'web-scrape',
      name: '网页抓取',
      icon: '🕸️',
      desc: '抓取网页内容、提取结构化数据、处理 JS 渲染页面',
      command: 'monid discover "web scraping"',
    },
    'data-enrich': {
      id: 'data-enrich',
      name: '数据丰富',
      icon: '📊',
      desc: '丰富公司/人物/产品数据，获取深度商业情报',
      command: 'monid discover "data enrichment"',
    },
    'social-media': {
      id: 'social-media',
      name: '社交媒体',
      icon: '📱',
      desc: '社交媒体内容搜索、监控和分析',
      command: 'monid discover "social media"',
    },
    'search': {
      id: 'search',
      name: '全网搜索',
      icon: '🌐',
      desc: '搜索引擎结果、新闻、图片、视频等多维度搜索',
      command: 'monid discover "search"',
    },
    'content-monitor': {
      id: 'content-monitor',
      name: '内容监控',
      icon: '📡',
      desc: '监控网页变化、价格变动、品牌提及等',
      command: 'monid discover "monitoring"',
    },
  },

  // API Key 管理
  getApiKey() {
    if (this._apiKey) return this._apiKey;
    try {
      return localStorage.getItem('monid_api_key') || '';
    } catch (e) {
      return '';
    }
  },

  setApiKey(key) {
    this._apiKey = key;
    try {
      localStorage.setItem('monid_api_key', key);
    } catch (e) {
      console.warn('Failed to persist Monid API key:', e);
    }
  },

  isConfigured() {
    return !!this.getApiKey();
  },

  // 检查余额
  async getBalance() {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('MONID_KEY_MISSING');

    try {
      const resp = await fetch(`${this._apiBase}/balance`, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
      });
      if (!resp.ok) {
        if (resp.status === 401) throw new Error('MONID_KEY_INVALID');
        throw new Error(`API 错误: ${resp.status}`);
      }
      return await resp.json();
    } catch (err) {
      if (err.message.startsWith('MONID_')) throw err;
      throw new Error(`网络错误: ${err.message}`);
    }
  },

  // 工具发现
  async discover(query) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('MONID_KEY_MISSING');

    try {
      const resp = await fetch(`${this._apiBase}/discover`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ query }),
      });
      if (!resp.ok) {
        if (resp.status === 401) throw new Error('MONID_KEY_INVALID');
        if (resp.status === 429) throw new Error('MONID_RATE_LIMIT');
        throw new Error(`API 错误: ${resp.status}`);
      }
      return await resp.json();
    } catch (err) {
      if (err.message.startsWith('MONID_')) throw err;
      throw new Error(`网络错误: ${err.message}`);
    }
  },

  // 检查工具详情
  async inspect(toolId) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('MONID_KEY_MISSING');

    try {
      const resp = await fetch(`${this._apiBase}/inspect`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ tool: toolId }),
      });
      if (!resp.ok) {
        if (resp.status === 401) throw new Error('MONID_KEY_INVALID');
        throw new Error(`API 错误: ${resp.status}`);
      }
      return await resp.json();
    } catch (err) {
      if (err.message.startsWith('MONID_')) throw err;
      throw new Error(`网络错误: ${err.message}`);
    }
  },

  // 执行工具
  async run(toolId, params = {}) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('MONID_KEY_MISSING');

    try {
      const resp = await fetch(`${this._apiBase}/run`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          tool: toolId,
          input: params.input || {},
          query: params.query || {},
          path: params.path || {},
          wait: params.wait !== undefined ? params.wait : false,
        }),
      });
      if (!resp.ok) {
        if (resp.status === 401) throw new Error('MONID_KEY_INVALID');
        if (resp.status === 402) throw new Error('MONID_NO_CREDITS');
        if (resp.status === 429) throw new Error('MONID_RATE_LIMIT');
        throw new Error(`API 错误: ${resp.status}`);
      }
      return await resp.json();
    } catch (err) {
      if (err.message.startsWith('MONID_')) throw err;
      throw new Error(`网络错误: ${err.message}`);
    }
  },

  // 获取运行结果
  async getRun(runId) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('MONID_KEY_MISSING');

    try {
      const resp = await fetch(`${this._apiBase}/runs/${runId}`, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
      });
      if (!resp.ok) {
        if (resp.status === 401) throw new Error('MONID_KEY_INVALID');
        throw new Error(`API 错误: ${resp.status}`);
      }
      return await resp.json();
    } catch (err) {
      if (err.message.startsWith('MONID_')) throw err;
      throw new Error(`网络错误: ${err.message}`);
    }
  },
};

// 导出到全局
window.MonidService = MonidService;
