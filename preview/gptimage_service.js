// ================================================================
// GPT Image 2 Service — OpenAI DALL·E 3 / GPT-4o 图像生成
// ================================================================
const GPTImageService = {
  apiKey: localStorage.getItem('gptimage_api_key') || '',
  baseUrl: 'https://api.openai.com/v1',

  isConfigured() {
    return this.apiKey.length > 0;
  },

  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('gptimage_api_key', key);
  },

  getApiKey() {
    return this.apiKey;
  },

  clearApiKey() {
    this.apiKey = '';
    localStorage.removeItem('gptimage_api_key');
  },

  // 能力定义
  capabilities: {
    generate: { name: '文生图', icon: '🖼️', desc: '文字描述生成高质量图片' },
    variation: { name: '图生图', icon: '🎨', desc: '基于参考图生成变体' },
    edit: { name: '局部编辑', icon: '✏️', desc: '指定区域编辑修改' },
    style: { name: '风格迁移', icon: '🎭', desc: '保持内容变换风格' },
  },

  // DALL·E 3 生成图片
  async generateImage(params) {
    if (!this.isConfigured()) throw new Error('GPTIMAGE_KEY_MISSING');

    const { prompt, size = '1024x1024', n = 1, quality = 'standard', style = 'vivid' } = params;

    const model = localStorage.getItem('gptimage_model') || 'dall-e-3';
    const requestSize = localStorage.getItem('gptimage_size') || size;

    // DALL·E 3 只支持 n=1
    const body = {
      model: model === 'gpt-4o' ? 'dall-e-3' : 'dall-e-3', // GPT-4o image 也用 DALL·E 3 端点
      prompt: prompt,
      n: 1,
      size: requestSize,
      quality: quality,
      style: style,
    };

    try {
      const res = await fetch(`${this.baseUrl}/images/generations`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        if (res.status === 401) throw new Error('GPTIMAGE_KEY_INVALID');
        if (res.status === 429) throw new Error('GPTIMAGE_RATE_LIMIT');
        if (res.status === 402) throw new Error('GPTIMAGE_NO_CREDITS');
        throw new Error(err.error?.message || `OpenAI API 错误 ${res.status}`);
      }

      return await res.json();
    } catch (err) {
      if (err.message.startsWith('GPTIMAGE_')) throw err;
      throw new Error(`GPT Image 网络错误: ${err.message}`);
    }
  },

  // 生成美甲设计图
  async generateNailArt(designDescription, style) {
    const stylePrompts = {
      cyberpunk: 'cyberpunk style, neon glow, metallic texture, dark background, futuristic',
      elegant: 'elegant luxury style, pearl finish, gold accents, sophisticated, high-end',
      cute: 'kawaii cute style, pastel colors, sparkles, heart shapes, adorable',
      natural: 'natural organic style, floral patterns, soft earth tones, botanical elements',
      abstract: 'abstract art style, geometric patterns, bold colors, artistic expression',
      barbie: 'barbie pink style, hot pink and magenta, glamorous, glossy finish, bold and vibrant',
    };

    const styleAddon = stylePrompts[style] || style || 'professional nail art design, high detail';
    
    const prompt = `Professional nail art design: ${designDescription}. ${styleAddon}. 
Close-up macro shot of fingernails, studio lighting, 8K resolution, 
extremely detailed, realistic nail polish texture, professional beauty photography.`;

    return this.generateImage({
      prompt: prompt,
      size: localStorage.getItem('gptimage_size') || '1024x1024',
    });
  },
};

// 导出到全局
window.GPTImageService = GPTImageService;
