/**
 * AI NAILS Desktop v4.0 — Nano Banana Pro 生图服务
 * 
 * 使用 Google Gemini 原生 API 生成图像:
 * - Endpoint: https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent
 * - 认证方式: X-goog-api-key header
 * - 支持 AIza 和 AQ. 前缀的 API Key
 * - 获取 Key: https://aistudio.google.com/apikey
 */

const NanoBananaService = {
  // 配置
  apiKey: '',
  
  // Google Gemini 图片生成 API
  googleBaseUrl: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent',
  
  // 美甲风格预设提示词增强
  nailStyleEnhancers: {
    '赛博朋克': 'cyberpunk style, neon lights, holographic effect, metallic texture, dark background with vibrant glowing colors, futuristic nail art design',
    '中国风': 'traditional Chinese style, elegant ink wash painting, red and gold accents, delicate floral patterns, jade-inspired textures, classic oriental nail art',
    '极简': 'minimalist style, clean lines, matte finish, subtle geometric patterns, monochrome palette, sophisticated simple nail design',
    '花卉': 'floral botanical style, watercolor flowers, soft pastel petals, romantic garden theme, delicate botanical nail art',
    '渐变': 'smooth gradient ombre effect, seamless color transition, glossy finish, dreamy color blend nail art',
    '哥特': 'gothic dark romantic style, deep burgundy and black, ornate baroque patterns, dramatic mysterious nail design',
    '波普': 'pop art style, bold colors, comic book halftone dots, vibrant Warhol-inspired nail art, graphic design elements',
    '水彩': 'watercolor painting effect, soft bleeding colors, artistic brush strokes, dreamy translucent layers, ethereal nail art',
    '星空': 'galaxy cosmic style, deep space nebula, scattered stars, shimmering glitter, celestial nail art design',
    '大理石': 'luxurious marble stone texture, elegant veins, polished glossy finish, natural stone nail art',
    '琉璃': 'stained glass effect, translucent jewel tones, mosaic patterns, luminous colorful nail design',
    '金属': 'liquid metal chrome effect, mirror finish, silver and gold metallic, futuristic reflective nail art',
  },

  // 支持的宽高比
  aspectRatios: ['1:1', '2:3', '3:2', '3:4', '4:3', '4:5', '5:4', '9:16', '16:9', '21:9'],

  // 支持的分辨率
  imageSizes: ['1K', '2K', '4K'],

  /**
   * 判断 API Key 类型
   * @returns {'google'|'geminigen'|'unknown'}
   */
  _detectKeyType() {
    const key = this.getApiKey();
    // AIza 和 AQ. 前缀都可以直接调用 Google Gemini 原生 API
    if (key.startsWith('AIza') || key.startsWith('AQ.')) return 'google';
    return 'unknown';
  },

  /**
   * 设置 API Key
   */
  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('nanobanana_api_key', key);
  },

  /**
   * 获取已保存的 API Key
   */
  getApiKey() {
    if (!this.apiKey) {
      this.apiKey = localStorage.getItem('nanobanana_api_key') || '';
    }
    return this.apiKey;
  },

  /**
   * 检查是否已配置 API Key
   */
  isConfigured() {
    return this.getApiKey().length > 0;
  },

  /**
   * 获取当前使用的 API 提供商名称
   */
  getProviderName() {
    return 'Google Gemini (Nano Banana Pro)';
  },

  /**
   * 增强美甲提示词 - 加入专业术语
   */
  enhanceNailPrompt(userPrompt, style) {
    let prompt = userPrompt;
    
    // 检测已知风格并添加英文增强
    for (const [styleName, enhancer] of Object.entries(this.nailStyleEnhancers)) {
      if (userPrompt.includes(styleName)) {
        prompt = `${userPrompt}. ${enhancer}`;
        break;
      }
    }

    // 添加美甲专业提示词
    const nailPrefix = 'Professional nail art design, high quality, detailed nail surface, ' +
      'perfectly shaped nails, beauty salon photography, macro close-up, clean background, ' +
      'studio lighting, 1200 DPI rendering quality: ';
    
    // 如果用户已经描述了完整内容，不加前缀
    if (prompt.length < 30) {
      prompt = nailPrefix + prompt;
    } else if (!prompt.toLowerCase().includes('nail')) {
      prompt = prompt + '. Professional nail art design, high detail.';
    }

    return prompt;
  },

  /**
   * 调用 Google Gemini 原生 API 生成图像
   */
  async _generateGoogle(prompt, options) {
    const apiKey = this.getApiKey();
    const { aspectRatio = '1:1', imageSize = '2K', referenceImage = null } = options;

    const parts = [{ text: prompt }];

    // 如果有参考图，添加到请求中
    if (referenceImage) {
      let base64Data;
      let mimeType = 'image/png';

      if (referenceImage instanceof File) {
        base64Data = await this._fileToBase64(referenceImage);
        mimeType = referenceImage.type || 'image/png';
      } else if (typeof referenceImage === 'string' && referenceImage.startsWith('data:')) {
        const match = referenceImage.match(/^data:([^;]+);base64,(.+)$/);
        if (match) {
          mimeType = match[1];
          base64Data = match[2];
        } else {
          base64Data = referenceImage;
        }
      }

      if (base64Data) {
        parts.push({
          inlineData: { mimeType: mimeType, data: base64Data }
        });
      }
    }

    const requestBody = {
      contents: [{ parts: parts }],
      generationConfig: {
        responseModalities: ['IMAGE'],
        responseFormat: {
          image: { aspectRatio: aspectRatio, imageSize: imageSize }
        }
      }
    };

    const url = this.googleBaseUrl;
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': apiKey
      },
      body: JSON.stringify(requestBody)
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      const errorMsg = errorData.error?.message || `HTTP ${response.status}`;
      
      if (response.status === 400) {
        throw new Error('API_BAD_REQUEST: ' + errorMsg);
      } else if (response.status === 401 || response.status === 403) {
        throw new Error('API_KEY_INVALID');
      } else if (response.status === 429) {
        throw new Error('API_RATE_LIMIT: 图片生成配额已用完，请稍后再试或更换 API Key。文本对话功能不受影响。');
      } else {
        throw new Error('API_ERROR: ' + errorMsg);
      }
    }

    const result = await response.json();
    return this._parseGoogleResponse(result);
  },

  /**
   * 解析 Google Gemini 原生 API 响应
   */
  _parseGoogleResponse(result) {
    const images = [];
    if (result.candidates) {
      for (const candidate of result.candidates) {
        if (candidate.content && candidate.content.parts) {
          for (const part of candidate.content.parts) {
            if (part.inlineData) {
              images.push({
                base64: part.inlineData.data,
                mimeType: part.inlineData.mimeType || 'image/png'
              });
            }
          }
        }
      }
    }

    if (images.length === 0) {
      let textResponse = '';
      if (result.candidates) {
        for (const candidate of result.candidates) {
          if (candidate.content && candidate.content.parts) {
            for (const part of candidate.content.parts) {
              if (part.text) textResponse += part.text;
            }
          }
        }
      }
      if (textResponse) {
        throw new Error('NO_IMAGE: ' + textResponse.substring(0, 100));
      }
      throw new Error('NO_IMAGE_GENERATED');
    }

    return images;
  },

  /**
   * 主入口: 调用 API 生成图像
   */
  async generateImage(prompt, options = {}) {
    const apiKey = this.getApiKey();
    if (!apiKey) {
      throw new Error('API_KEY_MISSING');
    }

    const { aspectRatio = '1:1', imageSize = '2K', style = '', referenceImage = null } = options;

    // 增强提示词
    const enhancedPrompt = this.enhanceNailPrompt(prompt, style);

    console.log(`[NanoBanana] 提示词: "${enhancedPrompt.substring(0, 80)}..."`);

    const images = await this._generateGoogle(enhancedPrompt, options);

    // 返回 base64 格式的图片
    return images;
  },

  /**
   * 批量生成多张设计变体
   */
  async generateVariants(prompt, count = 4, options = {}) {
    const results = [];
    
    const variations = [
      '',
      ' slight variation, different color accent',
      ' alternative angle, different lighting',
      ' creative interpretation, unique twist',
      ' different background texture',
      ' mirror effect variation'
    ];

    for (let i = 0; i < count; i++) {
      const variantPrompt = prompt + (variations[i] || '');
      try {
        const images = await this.generateImage(variantPrompt, options);
        results.push(...images);
      } catch (err) {
        console.warn(`[NanoBanana] Variant ${i + 1} failed:`, err.message);
        if (i === 0) throw err;
      }
      
      if (i < count - 1) {
        await this._delay(800);
      }
    }

    return results;
  },

  /**
   * 下载远程图片为 Blob
   */
  async _downloadImage(url) {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`Download failed: ${response.status}`);
    return response.blob();
  },

  /**
   * Blob 转 base64
   */
  _blobToBase64(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const dataUrl = reader.result;
        const base64 = dataUrl.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  },

  /**
   * File 转 base64
   */
  _fileToBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const dataUrl = reader.result;
        const base64 = dataUrl.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  },

  /**
   * 延迟
   */
  _delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
};

// 导出到全局
window.NanoBananaService = NanoBananaService;
