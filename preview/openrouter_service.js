// ================================================================
// OpenRouter Service — 200+ 模型统一 API 网关
// ================================================================
const OpenRouterService = {
  apiKey: localStorage.getItem('openrouter_api_key') || '',
  baseUrl: 'https://openrouter.ai/api/v1',

  // 默认模型
  defaultModel: localStorage.getItem('openrouter_model') || 'openai/gpt-4o',

  // 可用模型列表
  models: [
    { id: 'openai/gpt-4o', name: 'GPT-4o', provider: 'OpenAI', context: 128000 },
    { id: 'openai/gpt-4o-mini', name: 'GPT-4o-mini', provider: 'OpenAI', context: 128000 },
    { id: 'openai/o1', name: 'o1', provider: 'OpenAI', context: 200000 },
    { id: 'openai/o3-mini', name: 'o3-mini', provider: 'OpenAI', context: 200000 },
    { id: 'anthropic/claude-3.5-sonnet', name: 'Claude 3.5 Sonnet', provider: 'Anthropic', context: 200000 },
    { id: 'anthropic/claude-3-opus', name: 'Claude 3 Opus', provider: 'Anthropic', context: 200000 },
    { id: 'anthropic/claude-3-haiku', name: 'Claude 3 Haiku', provider: 'Anthropic', context: 200000 },
    { id: 'google/gemini-2.0-flash-001', name: 'Gemini 2.0 Flash', provider: 'Google', context: 1000000 },
    { id: 'google/gemini-2.5-pro-exp-03-25', name: 'Gemini 2.5 Pro', provider: 'Google', context: 1000000 },
    { id: 'deepseek/deepseek-chat', name: 'DeepSeek-V3', provider: 'DeepSeek', context: 128000 },
    { id: 'deepseek/deepseek-r1', name: 'DeepSeek-R1', provider: 'DeepSeek', context: 128000 },
    { id: 'meta-llama/llama-3.3-70b-instruct', name: 'LLaMA 3.3 70B', provider: 'Meta', context: 128000 },
    { id: 'qwen/qwen-max', name: 'Qwen-Max', provider: 'Alibaba', context: 32768 },
  ],

  isConfigured() {
    return this.apiKey.length > 0;
  },

  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('openrouter_api_key', key);
  },

  getApiKey() {
    return this.apiKey;
  },

  clearApiKey() {
    this.apiKey = '';
    localStorage.removeItem('openrouter_api_key');
  },

  setDefaultModel(modelId) {
    this.defaultModel = modelId;
    localStorage.setItem('openrouter_model', modelId);
  },

  // 通用聊天补全
  async chatCompletion(params) {
    if (!this.isConfigured()) throw new Error('OPENROUTER_KEY_MISSING');

    const { model, messages, temperature = 0.7, maxTokens = 4096 } = params;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
        'HTTP-Referer': 'https://ainailsprinters.com',
        'X-Title': 'AI NAILS App',
      },
      body: JSON.stringify({
        model: model || this.defaultModel,
        messages,
        temperature,
        max_tokens: maxTokens,
      }),
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error?.message || `OpenRouter API error: ${response.status}`);
    }

    return response.json();
  },

  // 简单文本生成
  async generateText(prompt, options = {}) {
    const { model, systemPrompt, temperature = 0.7, maxTokens = 4096 } = options;

    const messages = [];
    if (systemPrompt) messages.push({ role: 'system', content: systemPrompt });
    messages.push({ role: 'user', content: prompt });

    const result = await this.chatCompletion({
      model: model || this.defaultModel,
      messages,
      temperature,
      maxTokens,
    });

    return result.choices?.[0]?.message?.content || '';
  },

  // 流式生成
  async streamCompletion(params, onChunk) {
    if (!this.isConfigured()) throw new Error('OPENROUTER_KEY_MISSING');

    const { model, messages, temperature = 0.7, maxTokens = 4096 } = params;

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
        'HTTP-Referer': 'https://ainailsprinters.com',
        'X-Title': 'AI NAILS App',
      },
      body: JSON.stringify({
        model: model || this.defaultModel,
        messages,
        temperature,
        max_tokens: maxTokens,
        stream: true,
      }),
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error?.message || `OpenRouter API error: ${response.status}`);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullContent = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      const lines = chunk.split('\n').filter(l => l.startsWith('data: '));

      for (const line of lines) {
        const data = line.slice(6).trim();
        if (data === '[DONE]') continue;

        try {
          const parsed = JSON.parse(data);
          const content = parsed.choices?.[0]?.delta?.content || '';
          if (content) {
            fullContent += content;
            if (onChunk) onChunk(content, fullContent);
          }
        } catch (e) {
          // skip malformed JSON
        }
      }
    }

    return fullContent;
  },

  // 获取可用模型列表
  async fetchModels() {
    if (!this.isConfigured()) throw new Error('OPENROUTER_KEY_MISSING');

    const response = await fetch(`${this.baseUrl}/models`, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
      },
    });

    if (!response.ok) throw new Error(`Failed to fetch models: ${response.status}`);

    const data = await response.json();
    return data.data || [];
  },

  // 测试连接
  async testConnection() {
    try {
      const result = await this.generateText('Hello, respond with "OK" only.', {
        model: 'openai/gpt-4o-mini',
        maxTokens: 10,
      });
      return { success: true, message: 'OpenRouter 连接成功', data: result };
    } catch (e) {
      return { success: false, message: e.message };
    }
  },
};
