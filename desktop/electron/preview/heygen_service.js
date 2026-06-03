// ================================================================
// HeyGen Service — AI 数字人视频生成
// ================================================================
const HeyGenService = {
  apiKey: localStorage.getItem('heygen_api_key') || '',
  baseUrl: 'https://api.heygen.com/v2',

  isConfigured() {
    return this.apiKey.length > 0;
  },

  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('heygen_api_key', key);
  },

  getApiKey() {
    return this.apiKey;
  },

  clearApiKey() {
    this.apiKey = '';
    localStorage.removeItem('heygen_api_key');
  },

  // 能力定义
  capabilities: {
    video: { name: '视频生成', icon: '🎬', desc: 'AI 数字人播报视频' },
    avatar: { name: '数字人', icon: '🧑‍💼', desc: '定制数字人形象' },
    translate: { name: '视频翻译', icon: '🌍', desc: '视频多语言配音' },
    streaming: { name: '流式数字人', icon: '🔴', desc: '实时交互数字人' },
  },

  // 创建视频生成任务
  async createVideo(params) {
    if (!this.isConfigured()) throw new Error('HEYGEN_KEY_MISSING');

    const { text, avatarId = 'default', voiceId = 'default', title = 'AI Nails Video' } = params;

    const body = {
      video_name: title,
      dimension: { width: 1920, height: 1080 },
      avatar: { avatar_id: avatarId },
      voice: { voice_id: voiceId },
      input_text: text,
    };

    try {
      const res = await fetch(`${this.baseUrl}/video/generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': this.apiKey,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        if (res.status === 401) throw new Error('HEYGEN_KEY_INVALID');
        if (res.status === 402) throw new Error('HEYGEN_NO_CREDITS');
        if (res.status === 429) throw new Error('HEYGEN_RATE_LIMIT');
        throw new Error(err.message || `HeyGen API 错误 ${res.status}`);
      }

      return await res.json();
    } catch (err) {
      if (err.message.startsWith('HEYGEN_')) throw err;
      throw new Error(`HeyGen 网络错误: ${err.message}`);
    }
  },

  // 查询视频状态
  async getVideoStatus(videoId) {
    try {
      const res = await fetch(`${this.baseUrl}/video/generate/${videoId}`, {
        headers: { 'X-Api-Key': this.apiKey },
      });
      if (!res.ok) throw new Error(`查询失败: ${res.status}`);
      return await res.json();
    } catch (err) {
      throw new Error(`HeyGen 状态查询失败: ${err.message}`);
    }
  },

  // 轮询直到完成
  async pollVideo(videoId, maxRetries = 60, interval = 5000) {
    for (let i = 0; i < maxRetries; i++) {
      const status = await this.getVideoStatus(videoId);
      if (status.data?.status === 'completed') {
        return status.data;
      }
      if (status.data?.status === 'failed') {
        throw new Error(status.data.error || '视频生成失败');
      }
      await new Promise(r => setTimeout(r, interval));
    }
    throw new Error('视频生成超时，请稍后重试');
  },

  // 获取数字人列表
  async listAvatars() {
    try {
      const res = await fetch(`${this.baseUrl}/avatars`, {
        headers: { 'X-Api-Key': this.apiKey },
      });
      if (!res.ok) throw new Error(`获取数字人列表失败: ${res.status}`);
      return await res.json();
    } catch (err) {
      throw new Error(`HeyGen 数字人查询失败: ${err.message}`);
    }
  },

  // 获取声音列表
  async listVoices() {
    try {
      const res = await fetch(`${this.baseUrl}/voices`, {
        headers: { 'X-Api-Key': this.apiKey },
      });
      if (!res.ok) throw new Error(`获取声音列表失败: ${res.status}`);
      return await res.json();
    } catch (err) {
      throw new Error(`HeyGen 声音查询失败: ${err.message}`);
    }
  },

  // 生成美甲宣传视频
  async generateNailPromoVideo(designName, description, nailStyle) {
    const script = `Introducing our latest nail art design: ${designName}. 
${description}
This ${nailStyle} style features stunning details and premium quality finish. 
Perfect for any occasion, from casual outings to special events.
Visit AI Nails Studio today and transform your nails into a masterpiece!`;

    return this.createVideo({
      text: script,
      title: `${designName} - AI Nails Design`,
      avatarId: 'default',
      voiceId: 'default',
    });
  },
};

// 导出到全局
window.HeyGenService = HeyGenService;
