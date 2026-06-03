// ================================================================
// CreatOK Service — 生图 + 生视频 + 视频分析 + 视频再创作
// ================================================================

const CreatOKService = {
  BASE_URL: 'https://api.creatok.io',
  _apiKey: null,

  // 能力注册表
  operations: {
    'generate-image': {
      id: 'generate-image',
      name: 'AI 生图',
      icon: '🖼️',
      desc: '通过文字描述生成高质量图片，支持多种风格和分辨率',
      endpoint: '/v1/image/generate',
    },
    'generate-video': {
      id: 'generate-video',
      name: 'AI 生视频',
      icon: '🎥',
      desc: '将文字脚本转化为 TikTok/短视频，自动配音+字幕',
      endpoint: '/v1/video/generate',
    },
    'analyze-video': {
      id: 'analyze-video',
      name: '视频分析',
      icon: '🔍',
      desc: '分析视频脚本结构、钩子、音乐、场景，提供优化建议',
      endpoint: '/v1/video/analyze',
    },
    'recreate-video': {
      id: 'recreate-video',
      name: '视频再创作',
      icon: '🔄',
      desc: '基于参考视频重新创作适配你产品的新版本视频',
      endpoint: '/v1/video/recreate',
    },
  },

  getApiKey() {
    if (this._apiKey) return this._apiKey;
    return localStorage.getItem('creatok_api_key') || '';
  },

  setApiKey(key) {
    this._apiKey = key;
    localStorage.setItem('creatok_api_key', key);
  },

  isConfigured() {
    return !!this.getApiKey();
  },

  async generate(operationId, params) {
    const op = this.operations[operationId];
    if (!op) throw new Error('未知操作: ' + operationId);

    const apiKey = this.getApiKey();
    if (!apiKey) throw new Error('CREATOK_KEY_INVALID: 请先配置 CreatOK API Key');

    try {
      const response = await fetch(`${this.BASE_URL}${op.endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          prompt: params.prompt || '',
          image_url: params.imageUrl || '',
          video_url: params.videoUrl || '',
          reference_url: params.referenceUrl || '',
          style: params.style || 'auto',
          duration: params.duration || 'auto',
          aspect_ratio: params.aspectRatio || '9:16',
          ...params.extra,
        }),
        signal: AbortSignal.timeout(180000), // 3分钟超时
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        if (response.status === 401) throw new Error('CREATOK_KEY_INVALID: API Key 无效');
        if (response.status === 429) throw new Error('CREATOK_RATE_LIMIT: 请求过于频繁');
        if (response.status === 402) throw new Error('CREATOK_NO_CREDITS: 额度不足');
        throw new Error(errData.message || errData.error || `请求失败 (${response.status})`);
      }

      return await response.json();
    } catch (err) {
      if (err.name === 'TimeoutError' || err.name === 'AbortError') {
        throw new Error('请求超时，请检查网络连接或稍后重试');
      }
      if (err.message.startsWith('CREATOK_')) throw err;
      throw new Error('网络连接失败: ' + err.message);
    }
  },
};

window.CreatOKService = CreatOKService;
