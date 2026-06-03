// ================================================================
// Clipcat Service — TikTok 电商视频创作 + AI 生图
// ================================================================

const ClipcatService = {
  BASE_URL: 'https://api.clipcat.ai',
  _apiKey: null,
  _cliPath: null,

  capabilities: {
    'search': {
      id: 'search',
      name: '视频搜索',
      icon: '🔎',
      desc: '搜索 TikTok 热门带货视频，按关键词/地区/排序筛选',
      creditCost: 0,
    },
    'replicate': {
      id: 'replicate',
      name: '视频复刻',
      icon: '📋',
      desc: '复刻热门视频风格，用你的产品图生成同款带货视频',
      creditCost: 1,
    },
    'product_video': {
      id: 'product_video',
      name: '产品生视频',
      icon: '📦',
      desc: '上传产品图，AI 自动生成 TikTok 带货短视频',
      creditCost: 1,
    },
    'image': {
      id: 'image',
      name: 'AI 生图',
      icon: '🎨',
      desc: '使用 GPT Image 2 模型从文字生成高质量图片',
      creditCost: 1,
    },
    'breakdown': {
      id: 'breakdown',
      name: '视频拆解',
      icon: '📝',
      desc: '分析视频脚本结构、分镜、音乐、钩子，提取创作要素',
      creditCost: 0,
    },
    'download': {
      id: 'download',
      name: '视频下载',
      icon: '⬇️',
      desc: '下载 TikTok/Douyin 视频原始文件',
      creditCost: 0,
    },
    'search_items': {
      id: 'search_items',
      name: '商品搜索',
      icon: '🛒',
      desc: '搜索 TikTok Shop 商品情报，分析竞品和市场趋势',
      creditCost: 0,
    },
  },

  getApiKey() {
    if (this._apiKey) return this._apiKey;
    return localStorage.getItem('clipcat_api_key') || '';
  },

  setApiKey(key) {
    this._apiKey = key;
    localStorage.setItem('clipcat_api_key', key);
  },

  isConfigured() {
    return !!this.getApiKey();
  },

  // 获取 clipcat CLI 路径
  getCliPath() {
    return this._cliPath || 'clipcat';
  },

  setCliPath(path) {
    this._cliPath = path;
    localStorage.setItem('clipcat_cli_path', path);
  },

  // 通过 API 调用 clipcat 功能（前端直连模式）
  async apiCall(endpoint, params) {
    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('CLIPCAT_KEY_INVALID: 请先配置 Clipcat API Key');

    try {
      const response = await fetch(`${this.BASE_URL}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify(params),
        signal: AbortSignal.timeout(300000), // 5分钟超时（视频生成较慢）
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        if (response.status === 401) throw new Error('CLIPCAT_KEY_INVALID: API Key 无效');
        if (response.status === 429) throw new Error('CLIPCAT_RATE_LIMIT: 请求过于频繁');
        if (response.status === 402) throw new Error('CLIPCAT_NO_CREDITS: 额度不足');
        throw new Error(errData.message || errData.error || `请求失败 (${response.status})`);
      }

      return await response.json();
    } catch (err) {
      if (err.name === 'TimeoutError' || err.name === 'AbortError') {
        throw new Error('请求超时，视频生成通常需要较长时间，请稍后查询任务状态');
      }
      if (err.message.startsWith('CLIPCAT_')) throw err;
      throw new Error('网络连接失败: ' + err.message);
    }
  },

  // 模拟 CLI 调用（展示模式，用于演示UI交互）
  async simulateCliCall(capability, prompt) {
    // 模拟异步任务
    await new Promise(r => setTimeout(r, 1500));

    const results = {
      'search': {
        videos: [
          { id: 'v001', title: prompt + ' 热门视频 #1', plays: '1.2M', likes: '45K', url: 'https://tiktok.com/@example/video/001' },
          { id: 'v002', title: prompt + ' 爆款视频 #2', plays: '890K', likes: '32K', url: 'https://tiktok.com/@example/video/002' },
          { id: 'v003', title: prompt + ' 趋势视频 #3', plays: '670K', likes: '28K', url: 'https://tiktok.com/@example/video/003' },
        ],
        total: 3,
        region: 'US',
      },
      'replicate': {
        task_id: 'task_' + Date.now(),
        status: 'submitted',
        message: '视频复刻任务已提交，预计 10 分钟完成',
        estimated_time: '10 min',
      },
      'product_video': {
        task_id: 'task_' + Date.now(),
        status: 'submitted',
        message: '产品视频生成任务已提交，预计 10 分钟完成',
        estimated_time: '10 min',
      },
      'image': {
        task_id: 'img_' + Date.now(),
        status: 'submitted',
        message: 'AI 生图任务已提交，预计 3 分钟完成',
        estimated_time: '3 min',
      },
      'breakdown': {
        script: '钩子 (0-3s): ' + prompt.slice(0, 20) + '...\n主体 (3-15s): 产品展示 + 卖点说明\nCTA (15-20s): 引导点击购物车',
        scenes: 4,
        music_style: 'Trending Pop',
        hooks: ['问题钩子', '结果展示', '价格惊喜'],
      },
      'download': {
        url: 'https://static.clipcat.ai/downloads/demo_video.mp4',
        expires_in: 3600,
        filename: 'tiktok_video.mp4',
      },
      'search_items': {
        items: [
          { id: 'p001', name: prompt + ' 热门商品 #1', price: '$19.99', sales: '12K', rating: 4.8 },
          { id: 'p002', name: prompt + ' 爆款商品 #2', price: '$29.99', sales: '8.5K', rating: 4.6 },
        ],
        total: 2,
        region: 'US',
      },
    };

    return results[capability] || { message: '任务已提交' };
  },
};

window.ClipcatService = ClipcatService;
