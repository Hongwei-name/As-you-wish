<template>
  <footer class="footer">
    <div class="container">
      <div class="footer-content">
        <!-- 关于我们 -->
        <div class="footer-section">
          <h3 class="footer-title">关于我们</h3>
          <ul class="footer-links">
            <li><a href="#">公司简介</a></li>
            <li><a href="#">联系我们</a></li>
            <li><a href="#">加入我们</a></li>
            <li><a href="#">隐私政策</a></li>
            <li><a href="#">用户协议</a></li>
          </ul>
        </div>
        
        <!-- 客户服务 -->
        <div class="footer-section">
          <h3 class="footer-title">客户服务</h3>
          <ul class="footer-links">
            <li><a href="#">帮助中心</a></li>
            <li><a href="#">退换货政策</a></li>
            <li><a href="#">配送信息</a></li>
            <li><a href="#">常见问题</a></li>
            <li><a href="#">意见反馈</a></li>
          </ul>
        </div>
        
        <!-- 商家入驻 -->
        <div class="footer-section">
          <h3 class="footer-title">商家入驻</h3>
          <ul class="footer-links">
            <li><a href="#">入驻流程</a></li>
            <li><a href="#">商家后台</a></li>
            <li><a href="#">商家规则</a></li>
            <li><a href="#">营销活动</a></li>
            <li><a href="#">培训中心</a></li>
          </ul>
        </div>
        
        <!-- 关注我们 -->
        <div class="footer-section">
          <h3 class="footer-title">关注我们</h3>
          <div class="social-links">
            <a href="#" class="social-link"><i class="el-icon-chat-dot-round"></i> 微信公众号</a>
            <a href="#" class="social-link"><i class="el-icon-message"></i> 官方微博</a>
            <a href="#" class="social-link"><i class="el-icon-phone"></i> 客服热线: 400-123-4567</a>
          </div>
          <div class="copyright">
            <p>© 2026 如你所愿. 保留所有权利.</p>
            <p>桂ICP备12345678号</p>
          </div>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
// Footer 组件
</script>

<style scoped>
.footer {
  background-color: #FFFFFF;
  border-top: 1px solid var(--el-border-color);
  padding: 40px 0 20px;
  margin-top: 40px;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
}

.footer-section {
  flex: 1;
  min-width: 200px;
  margin-bottom: 30px;
}

.footer-title {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin-bottom: 15px;
  position: relative;
  padding-bottom: 8px;
}

.footer-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 40px;
  height: 2px;
  background-color: var(--el-color-primary);
}

.footer-links {
  list-style: none;
  margin: 0;
  padding: 0;
}

.footer-links li {
  margin-bottom: 10px;
}

.footer-links a {
  color: var(--el-text-color-secondary);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.footer-links a:hover {
  color: var(--el-color-primary);
}

.social-links {
  margin-bottom: 20px;
}

.social-link {
  display: block;
  color: var(--el-text-color-secondary);
  text-decoration: none;
  font-size: 14px;
  margin-bottom: 10px;
  transition: color 0.3s ease;
}

.social-link:hover {
  color: var(--el-color-primary);
}

.social-link i {
  margin-right: 8px;
  font-size: 16px;
}

.copyright {
  margin-top: 20px;
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  line-height: 1.5;
}

.copyright p {
  margin: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
  }
  
  .footer-section {
    width: 100%;
  }
}
</style>
