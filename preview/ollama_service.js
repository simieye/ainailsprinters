/**
 * AI NAILS Desktop v4.0 — Ollama 本地大模型服务
 * 
 * 使用本地 Ollama 进行美甲提示词优化:
 * - 将用户的中文描述转为高质量英文生图提示词
 * - 分析参考图并生成风格描述
 * - 生成多种设计变体提示词
 * 
 * Endpoint: http://localhost:11434/api/generate
 * 默认模型: qwen3-coder:480b-cloud (可配置)
 */

const OllamaService = {
  // 配置
  baseUrl: 'http://localhost:11434',
  model: 'qwen3-coder:480b-cloud',  // qwen3 效果最好，gpt-oss 常返回空
  fallbackModel: 'deepseek-v3.1:671b-cloud',
  
  // 美甲风格关键词库
  nailStyleKeywords: {
    '赛博朋克': ['cyberpunk', 'neon lights', 'holographic', 'metallic', 'dark background', 'futuristic'],
    '中国风': ['traditional Chinese', 'ink wash', 'red gold', 'floral patterns', 'jade texture', 'oriental'],
    '极简': ['minimalist', 'clean lines', 'matte finish', 'geometric', 'monochrome', 'sophisticated'],
    '花卉': ['floral', 'watercolor', 'pastel petals', 'romantic garden', 'botanical'],
    '渐变': ['gradient', 'ombre', 'seamless color transition', 'glossy', 'dreamy blend'],
    '哥特': ['gothic', 'dark romantic', 'burgundy black', 'baroque', 'dramatic'],
    '波普': ['pop art', 'bold colors', 'halftone dots', 'Warhol-inspired', 'graphic'],
    '水彩': ['watercolor', 'bleeding colors', 'artistic brush', 'translucent layers', 'ethereal'],
    '星空': ['galaxy', 'cosmic', 'nebula', 'stars', 'shimmering glitter', 'celestial'],
    '大理石': ['marble', 'stone texture', 'elegant veins', 'polished', 'luxurious'],
    '琉璃': ['stained glass', 'jewel tones', 'mosaic', 'translucent', 'luminous'],
    '金属': ['liquid metal', 'chrome', 'mirror finish', 'silver gold', 'reflective'],
  },

  /**
   * 检测 Ollama 服务是否可用
   */
  async checkAvailability() {
    try {
      const resp = await fetch(`${this.baseUrl}/api/tags`, { signal: AbortSignal.timeout(3000) });
      return resp.ok;
    } catch (e) {
      return false;
    }
  },

  /**
   * 获取可用模型列表
   */
  async listModels() {
    try {
      const resp = await fetch(`${this.baseUrl}/api/tags`);
      const data = await resp.json();
      return data.models || [];
    } catch (e) {
      return [];
    }
  },

  /**
   * 核心: 优化美甲提示词
   * 将用户输入转为高质量英文生图提示词
   */
  async enhancePrompt(userInput, style = '') {
    // 先用本地增强把中文关键词转为英文
    const localEnhanced = this.localEnhance(userInput);
    
    // 提取纯英文部分传给 Ollama（中文会干扰模型）
    const englishOnly = localEnhanced.replace(/[\u4e00-\u9fff]+/g, '').replace(/[，。！？、；：""（）【】《》]+/g, '').replace(/\s+/g, ' ').trim();
    const promptText = englishOnly || localEnhanced;
    
    const userMessage = `Generate a detailed English prompt for AI image generation of nail art: ${promptText}. Output only the prompt.`;

    const response = await this._callOllama('', userMessage);
    return response.trim() || promptText;
  },

  /**
   * 生成多个设计变体提示词
   */
  async generateVariantPrompts(basePrompt, count = 4) {
    const variants = [];
    
    // 先用 Ollama 优化基础提示词
    const enhancedBase = await this.enhancePrompt(basePrompt);
    variants.push(enhancedBase);

    // 生成变体 — 通过修改后缀实现
    const variationSuffixes = [
      ', different color palette',
      ', alternative nail shape and length',
      ', different background and lighting',
      ', more minimalist and elegant version',
      ', more ornate and detailed version',
      ', warm golden hour lighting mood'
    ];

    for (let i = 1; i < count && i <= variationSuffixes.length; i++) {
      try {
        const variantPrompt = `Generate a detailed English prompt for AI image generation of nail art: ${this.localEnhance(basePrompt)}${variationSuffixes[i-1]}. Output only the prompt.`;
        const variant = await this._callOllama('', variantPrompt);
        if (variant.trim()) {
          variants.push(variant.trim());
        } else {
          variants.push(`${enhancedBase}${variationSuffixes[i-1]}`);
        }
      } catch (e) {
        variants.push(`${enhancedBase}${variationSuffixes[i-1]}`);
      }
    }

    return variants;
  },

  /**
   * 分析参考图片并生成风格描述
   */
  async analyzeReferenceImage(imageBase64, mimeType = 'image/png') {
    const systemPrompt = `You are a nail art expert. Analyze this nail art reference image and describe it in detail in English. Focus on: colors, patterns, textures, nail shape, finish, and overall style. Output a concise paragraph (under 100 words).`;

    try {
      const resp = await fetch(`${this.baseUrl}/api/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: this.model,
          system: systemPrompt,
          prompt: 'Describe this nail art image in detail:',
          images: [imageBase64],
          stream: false
        })
      });

      if (!resp.ok) {
        // 如果视觉模型不支持，回退到文本描述
        return 'Professional nail art design with elegant details';
      }

      const data = await resp.json();
      return data.response?.trim() || 'Elegant nail art design';
    } catch (e) {
      console.warn('[Ollama] Image analysis failed, using text-only mode');
      return 'Beautiful nail art design';
    }
  },

  /**
   * 调用 Ollama API (核心方法)
   */
  async _callOllama(systemPrompt, userMessage) {
    const body = {
      model: this.model,
      prompt: userMessage,
      stream: false,
      options: {
        temperature: 0.7,
        top_p: 0.9,
        num_predict: 300
      }
    };
    if (systemPrompt) body.system = systemPrompt;

    try {
      const resp = await fetch(`${this.baseUrl}/api/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(60000)
      });

      if (!resp.ok) {
        throw new Error(`HTTP ${resp.status}`);
      }

      const data = await resp.json();
      return data.response || '';
    } catch (e) {
      console.warn(`[Ollama] ${this.model} failed:`, e.message);
      // 尝试回退模型
      if (this.model !== this.fallbackModel) {
        console.log(`[Ollama] Trying fallback model: ${this.fallbackModel}`);
        body.model = this.fallbackModel;
        const fallbackResp = await fetch(`${this.baseUrl}/api/generate`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(60000)
        });
        if (fallbackResp.ok) {
          const data = await fallbackResp.json();
          return data.response || '';
        }
      }
      throw e;
    }
  },

  /**
   * 快速本地提示词增强 (不依赖 API，纯本地处理)
   * 当 Ollama 不可用时的回退方案
   */
  localEnhance(userInput) {
    let enhanced = userInput;
    
    // 检测中文风格关键词并替换为英文
    for (const [cn, enKeywords] of Object.entries(this.nailStyleKeywords)) {
      if (userInput.includes(cn)) {
        enhanced = `${userInput}. ${enKeywords.join(', ')}, nail art design`;
        break;
      }
    }

    // 如果没有匹配到任何风格，添加通用美甲关键词
    if (enhanced === userInput) {
      enhanced = `${userInput}, professional nail art design, high quality, studio lighting, macro close-up, 1200 DPI`;
    }

    return enhanced;
  }
};
