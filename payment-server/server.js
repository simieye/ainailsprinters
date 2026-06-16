// ================================================================
// AI NAILS Payment API Server v1.0
// 支持: 微信扫码支付 | 支付宝扫码 | 客户自有支付系统接入
// 运行: node server.js (默认端口 3456)
// ================================================================

const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const QRCode = require('qrcode');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PAYMENT_PORT || 3456;

// ========== 数据存储（生产环境应替换为数据库） ==========
const orders = new Map();       // orderId -> order
const customers = new Map();   // customerId -> config
const transactions = [];       // 交易记录

// ========== 配置 ==========
const CONFIG = {
  // 微信支付（需商户配置）
  wechat: {
    appId: process.env.WECHAT_APPID || '',
    mchId: process.env.WECHAT_MCHID || '',
    apiKey: process.env.WECHAT_APIKEY || '',
    notifyUrl: process.env.WECHAT_NOTIFY_URL || 'http://localhost:3456/api/payment/wechat/notify'
  },
  // 支付宝（需商户配置）
  alipay: {
    appId: process.env.ALIPAY_APPID || '',
    privateKey: process.env.ALIPAY_PRIVATE_KEY || '',
    alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY || '',
    notifyUrl: process.env.ALIPAY_NOTIFY_URL || 'http://localhost:3456/api/payment/alipay/notify'
  }
};

// ========== 工具函数 ==========
function generateOrderId() {
  return 'AN' + Date.now().toString(36).toUpperCase() + crypto.randomBytes(3).toString('hex').toUpperCase();
}

function generateQRCodeUrl(orderId, amount, method) {
  // 生成支付二维码URL（实际应调用微信/支付宝统一下单接口）
  return `https://pay.ainails.app/qr/${method}/${orderId}?amount=${amount}`;
}

function sign(params, key) {
  const sorted = Object.keys(params).sort();
  const str = sorted.map(k => `${k}=${params[k]}`).join('&') + `&key=${key}`;
  return crypto.createHash('md5').update(str).digest('hex').toUpperCase();
}

function verifySign(params, key, sign) {
  const expected = module.exports.sign ? module.exports.sign(params, key) : sign;
  return expected === sign;
}

// ========== 订单管理 API ==========

// 创建支付订单
app.post('/api/payment/create', async (req, res) => {
  try {
    const { amount, currency, method, scene, itemName, customerId, customPaymentConfig } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ success: false, error: '无效的支付金额' });
    }

    const orderId = generateOrderId();
    const order = {
      orderId,
      amount: Number(amount),
      currency: currency || 'CNY',
      method: method || 'wechat',
      scene: scene || 'recharge',
      itemName: itemName || '账户充值',
      customerId: customerId || null,
      status: 'pending',     // pending | paid | failed | cancelled | refunded
      qrCodeUrl: '',
      qrCodeDataUrl: '',
      createdAt: new Date().toISOString(),
      paidAt: null,
      expiredAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(), // 5分钟过期
      customPaymentConfig: customPaymentConfig || null
    };

    // 生成二维码
    const qrContent = JSON.stringify({
      orderId,
      amount: order.amount,
      currency: order.currency,
      method: order.method,
      timestamp: Date.now()
    });

    try {
      order.qrCodeDataUrl = await QRCode.toDataURL(qrContent, {
        width: 300,
        margin: 2,
        color: { dark: '#000000', light: '#ffffff' }
      });
      order.qrCodeUrl = generateQRCodeUrl(orderId, order.amount, order.method);
    } catch (e) {
      // QR生成失败，使用URL模式
      order.qrCodeDataUrl = '';
      order.qrCodeUrl = qrContent;
    }

    orders.set(orderId, order);

    // 自动过期处理
    setTimeout(() => {
      const o = orders.get(orderId);
      if (o && o.status === 'pending') {
        o.status = 'expired';
        orders.set(orderId, o);
      }
    }, 5 * 60 * 1000);

    console.log(`[支付] 新订单创建: ${orderId} | ¥${order.amount} | ${order.method}`);

    res.json({
      success: true,
      data: {
        orderId: order.orderId,
        amount: order.amount,
        currency: order.currency,
        method: order.method,
        status: order.status,
        qrCodeUrl: order.qrCodeUrl,
        qrCodeDataUrl: order.qrCodeDataUrl,
        createdAt: order.createdAt,
        expiredAt: order.expiredAt
      }
    });
  } catch (error) {
    console.error('[支付] 创建订单失败:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// 查询订单状态（轮询用）
app.get('/api/payment/status/:orderId', (req, res) => {
  const { orderId } = req.params;
  const order = orders.get(orderId);

  if (!order) {
    return res.status(404).json({ success: false, error: '订单不存在' });
  }

  res.json({
    success: true,
    data: {
      orderId: order.orderId,
      status: order.status,
      amount: order.amount,
      currency: order.currency,
      method: order.method,
      paidAt: order.paidAt,
      createdAt: order.createdAt
    }
  });
});

// 模拟支付成功（实际由支付平台回调触发）
app.post('/api/payment/confirm/:orderId', (req, res) => {
  const { orderId } = req.params;
  const { transactionId, payerInfo } = req.body || {};

  const order = orders.get(orderId);
  if (!order) {
    return res.status(404).json({ success: false, error: '订单不存在' });
  }

  if (order.status === 'paid') {
    return res.json({ success: true, message: '订单已支付', data: order });
  }

  if (order.status === 'expired') {
    return res.status(400).json({ success: false, error: '订单已过期' });
  }

  order.status = 'paid';
  order.paidAt = new Date().toISOString();
  order.transactionId = transactionId || ('TXN' + uuidv4().replace(/-/g, '').substring(0, 16).toUpperCase());
  orders.set(orderId, order);

  // 记录交易
  const txn = {
    id: order.transactionId,
    orderId,
    amount: order.amount,
    currency: order.currency,
    method: order.method,
    scene: order.scene,
    customerId: order.customerId,
    paidAt: order.paidAt,
    payerInfo: payerInfo || {}
  };
  transactions.push(txn);

  // 触发客户回调
  if (order.customerId) {
    triggerCustomerCallback(order.customerId, order);
  }

  console.log(`[支付] 订单已支付: ${orderId} | ¥${order.amount} | ${order.transactionId}`);

  res.json({ success: true, data: order });
});

// 取消订单
app.post('/api/payment/cancel/:orderId', (req, res) => {
  const { orderId } = req.params;
  const order = orders.get(orderId);

  if (!order) {
    return res.status(404).json({ success: false, error: '订单不存在' });
  }

  if (order.status !== 'pending') {
    return res.status(400).json({ success: false, error: '订单状态不允许取消' });
  }

  order.status = 'cancelled';
  orders.set(orderId, order);

  res.json({ success: true, data: order });
});

// ========== 微信支付回调模拟 ==========
app.post('/api/payment/wechat/notify', (req, res) => {
  const { out_trade_no, transaction_id, total_fee } = req.body || {};

  if (!out_trade_no) {
    return res.status(400).send('FAIL');
  }

  const order = orders.get(out_trade_no);
  if (!order) {
    return res.status(404).send('FAIL');
  }

  order.status = 'paid';
  order.paidAt = new Date().toISOString();
  order.transactionId = transaction_id || ('WX' + Date.now());
  orders.set(out_trade_no, order);

  console.log(`[微信支付回调] 订单 ${out_trade_no} 支付成功`);

  // 返回成功给微信
  res.send('<xml><return_code><![CDATA[SUCCESS]]></return_code><return_msg><![CDATA[OK]]></return_msg></xml>');
});

// ========== 支付宝回调模拟 ==========
app.post('/api/payment/alipay/notify', (req, res) => {
  const { out_trade_no, trade_no, total_amount } = req.body || {};

  if (!out_trade_no) {
    return res.status(400).send('fail');
  }

  const order = orders.get(out_trade_no);
  if (!order) {
    return res.status(404).send('fail');
  }

  order.status = 'paid';
  order.paidAt = new Date().toISOString();
  order.transactionId = trade_no || ('ALI' + Date.now());
  orders.set(out_trade_no, order);

  console.log(`[支付宝回调] 订单 ${out_trade_no} 支付成功`);
  res.send('success');
});

// ========== 客户自有支付系统 API ==========

// 注册客户支付配置
app.post('/api/customer/register', (req, res) => {
  const { customerId, name, webhookUrl, apiKey, paymentMethods, returnUrl } = req.body;

  if (!customerId || !webhookUrl) {
    return res.status(400).json({ success: false, error: 'customerId 和 webhookUrl 为必填项' });
  }

  const customer = {
    customerId,
    name: name || customerId,
    webhookUrl,
    apiKey: apiKey || crypto.randomBytes(16).toString('hex'),
    paymentMethods: paymentMethods || ['wechat', 'alipay'],
    returnUrl: returnUrl || '',
    status: 'active',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  customers.set(customerId, customer);

  console.log(`[客户注册] ${customerId} (${customer.name}) webhook: ${webhookUrl}`);

  res.json({
    success: true,
    data: {
      customerId: customer.customerId,
      apiKey: customer.apiKey,
      webhookUrl: customer.webhookUrl,
      status: customer.status
    }
  });
});

// 获取客户配置
app.get('/api/customer/:customerId', (req, res) => {
  const customer = customers.get(req.params.customerId);

  if (!customer) {
    return res.status(404).json({ success: false, error: '客户不存在' });
  }

  res.json({ success: true, data: customer });
});

// 更新客户支付配置
app.put('/api/customer/:customerId', (req, res) => {
  const customer = customers.get(req.params.customerId);

  if (!customer) {
    return res.status(404).json({ success: false, error: '客户不存在' });
  }

  const allowedFields = ['name', 'webhookUrl', 'apiKey', 'paymentMethods', 'returnUrl', 'status'];
  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      customer[field] = req.body[field];
    }
  }
  customer.updatedAt = new Date().toISOString();
  customers.set(req.params.customerId, customer);

  res.json({ success: true, data: customer });
});

// 客户订单列表
app.get('/api/customer/:customerId/orders', (req, res) => {
  const customer = customers.get(req.params.customerId);
  if (!customer) {
    return res.status(404).json({ success: false, error: '客户不存在' });
  }

  const customerOrders = [];
  orders.forEach(order => {
    if (order.customerId === req.params.customerId) {
      customerOrders.push(order);
    }
  });

  res.json({ success: true, data: customerOrders });
});

// 客户交易统计
app.get('/api/customer/:customerId/stats', (req, res) => {
  const customer = customers.get(req.params.customerId);
  if (!customer) {
    return res.status(404).json({ success: false, error: '客户不存在' });
  }

  const customerTxns = transactions.filter(t => t.customerId === req.params.customerId);
  const totalAmount = customerTxns.reduce((sum, t) => sum + t.amount, 0);
  const paidCount = customerTxns.length;

  res.json({
    success: true,
    data: {
      customerId: req.params.customerId,
      totalOrders: paidCount,
      totalAmount,
      currency: 'CNY',
      transactions: customerTxns.slice(-10) // 最近10条
    }
  });
});

// 触发客户webhook回调
async function triggerCustomerCallback(customerId, order) {
  const customer = customers.get(customerId);
  if (!customer || !customer.webhookUrl) return;

  const payload = {
    event: 'payment.success',
    customerId,
    orderId: order.orderId,
    amount: order.amount,
    currency: order.currency,
    method: order.method,
    transactionId: order.transactionId,
    paidAt: order.paidAt,
    itemName: order.itemName,
    scene: order.scene
  };

  try {
    const axios = require('axios');
    const resp = await axios.post(customer.webhookUrl, payload, {
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': customer.apiKey,
        'X-Webhook-Event': 'payment.success',
        'X-Webhook-Signature': crypto.createHmac('sha256', customer.apiKey)
          .update(JSON.stringify(payload))
          .digest('hex')
      },
      timeout: 10000
    });
    console.log(`[Webhook] 客户 ${customerId} 回调成功: ${resp.status}`);
  } catch (e) {
    console.error(`[Webhook] 客户 ${customerId} 回调失败:`, e.message);
  }
}

// 测试webhook
app.post('/api/customer/:customerId/test-webhook', async (req, res) => {
  const customer = customers.get(req.params.customerId);
  if (!customer) {
    return res.status(404).json({ success: false, error: '客户不存在' });
  }

  const testOrder = {
    orderId: 'TEST-' + uuidv4().substring(0, 8),
    amount: 0.01,
    currency: 'CNY',
    method: 'test',
    transactionId: 'TEST-' + Date.now(),
    paidAt: new Date().toISOString(),
    itemName: '测试订单',
    scene: 'test'
  };

  try {
    await triggerCustomerCallback(req.params.customerId, testOrder);
    res.json({ success: true, message: 'Webhook 测试发送成功' });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Webhook 测试失败: ' + e.message });
  }
});

// ========== 系统统计 ==========
app.get('/api/payment/stats', (req, res) => {
  const totalPaid = transactions.filter(t => !t.orderId.startsWith('TEST-'));
  const totalAmount = totalPaid.reduce((sum, t) => sum + t.amount, 0);
  const pendingOrders = Array.from(orders.values()).filter(o => o.status === 'pending');

  res.json({
    success: true,
    data: {
      totalTransactions: totalPaid.length,
      totalAmount,
      pendingOrders: pendingOrders.length,
      activeCustomers: customers.size,
      recentTransactions: transactions.slice(-20)
    }
  });
});

// ========== 健康检查 ==========
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    service: 'AI NAILS Payment Server',
    version: '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// ========== 启动服务器 ==========
app.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════════╗
║   AI NAILS Payment Server v1.0              ║
║   🚀 运行端口: ${PORT}                        ║
║   📡 支付API: http://localhost:${PORT}/api    ║
║   💳 微信扫码 | 支付宝 | 客户自有系统        ║
╚══════════════════════════════════════════════╝
  `);
});

module.exports = { app, orders, customers, transactions, sign, generateOrderId };
