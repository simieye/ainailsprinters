// ================================================================
// AnyGen Service — AI 内容生成套件（PPT/文档/图表/网站/研究/图像）
// ================================================================
const AnyGenService = {
  apiKey: localStorage.getItem('anygen_api_key') || '',
  baseUrl: 'https://www.anygen.io/api/v1',

  isConfigured() {
    return this.apiKey.length > 0;
  },

  setApiKey(key) {
    this.apiKey = key;
    localStorage.setItem('anygen_api_key', key);
  },

  getApiKey() {
    return this.apiKey;
  },

  clearApiKey() {
    this.apiKey = '';
    localStorage.removeItem('anygen_api_key');
  },

  // 操作类型定义
  operations: {
    slide: { name: 'PPT/幻灯片', icon: '📊', ext: '.pptx', downloadable: true },
    doc: { name: '文档', icon: '📄', ext: '.docx', downloadable: true },
    smart_draw: { name: '图表', icon: '📐', ext: '.png', downloadable: true },
    storybook: { name: '故事书', icon: '📖', ext: '.pptx', downloadable: true },
    data_analysis: { name: '数据分析', icon: '📈', ext: '', downloadable: false },
    deep_research: { name: '深度研究', icon: '🔬', ext: '', downloadable: false },
    website: { name: '网站', icon: '🌐', ext: '', downloadable: false },
    finance: { name: '金融分析', icon: '💰', ext: '', downloadable: false },
    'ai-designer': { name: 'AI 设计', icon: '🎨', ext: '', downloadable: false },
  },

  // 创建任务
  async createTask(operation, prompt, fileToken = null) {
    if (!this.isConfigured()) throw new Error('ANYGEN_KEY_MISSING');

    const body = { operation, prompt };
    if (fileToken) body.file_token = fileToken;

    try {
      const res = await fetch(`${this.baseUrl}/tasks`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        if (res.status === 401) throw new Error('ANYGEN_KEY_INVALID');
        if (res.status === 402) throw new Error('ANYGEN_NO_CREDITS');
        if (res.status === 429) throw new Error('ANYGEN_RATE_LIMIT');
        throw new Error(err.message || `AnyGen API 错误 ${res.status}`);
      }

      return await res.json();
    } catch (err) {
      if (err.message.startsWith('ANYGEN_')) throw err;
      throw new Error(`AnyGen 网络错误: ${err.message}`);
    }
  },

  // 查询任务状态
  async getTaskStatus(taskId) {
    try {
      const res = await fetch(`${this.baseUrl}/tasks/${taskId}`, {
        headers: { 'Authorization': `Bearer ${this.apiKey}` },
      });
      if (!res.ok) throw new Error(`查询任务失败: ${res.status}`);
      return await res.json();
    } catch (err) {
      throw new Error(`AnyGen 状态查询失败: ${err.message}`);
    }
  },

  // 轮询直到完成
  async pollTask(taskId, maxRetries = 30, interval = 3000) {
    for (let i = 0; i < maxRetries; i++) {
      const status = await this.getTaskStatus(taskId);
      if (status.status === 'completed' || status.status === 'done') {
        return status;
      }
      if (status.status === 'failed' || status.status === 'error') {
        throw new Error(status.error || '任务生成失败');
      }
      await new Promise(r => setTimeout(r, interval));
    }
    throw new Error('任务超时，请稍后重试');
  },

  // 下载文件
  async downloadTask(taskId) {
    try {
      const res = await fetch(`${this.baseUrl}/tasks/${taskId}/download`, {
        headers: { 'Authorization': `Bearer ${this.apiKey}` },
      });
      if (!res.ok) throw new Error(`下载失败: ${res.status}`);
      return await res.blob();
    } catch (err) {
      throw new Error(`AnyGen 下载失败: ${err.message}`);
    }
  },

  // 完整工作流：create → poll → download
  async run(operation, prompt, onProgress = null) {
    if (onProgress) onProgress('create', '正在创建任务...');
    const task = await this.createTask(operation, prompt);

    if (onProgress) onProgress('poll', `任务已创建: ${task.task_id}，等待生成...`);
    const result = await this.pollTask(task.task_id);

    if (onProgress) onProgress('download', '正在下载文件...');
    const blob = await this.downloadTask(task.task_id);

    const opInfo = this.operations[operation];
    const filename = `${opInfo.name}_${Date.now()}${opInfo.ext}`;

    return { taskId: task.task_id, blob, filename, operation: opInfo };
  },

  // 获取操作类型列表
  getOperations() {
    return Object.entries(this.operations).map(([id, info]) => ({
      id,
      ...info,
    }));
  },
};

// 导出到全局
window.AnyGenService = AnyGenService;
