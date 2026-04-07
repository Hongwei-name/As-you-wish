<template>
  <div class="not-found">
    <div class="container">
      <div class="error-content">
        <div class="error-code">404</div>
        <h1 class="error-title">页面不存在</h1>
        <p class="error-message">抱歉，您访问的页面不存在或已被移除</p>
        <router-link to="/" class="back-home">返回首页</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
// 404页面
</script>

<style scoped>
.not-found {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--el-bg-color);
  padding: 20px;
}

.error-content {
  text-align: center;
  background-color: #FFFFFF;
  padding: 60px 40px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(184, 149, 110, 0.15);
  max-width: 500px;
  width: 100%;
}

.error-code {
  font-size: 120px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin: 0 0 20px;
  font-family: 'Times New Roman', serif;
  text-shadow: 3px 3px 0 rgba(184, 149, 110, 0.1);
}

.error-title {
  font-size: 24px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 15px;
}

.error-message {
  font-size: 16px;
  color: var(--el-text-color-secondary);
  margin: 0 0 30px;
  line-height: 1.5;
}

.back-home {
  display: inline-block;
  padding: 12px 32px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  text-decoration: none;
  border-radius: 4px;
  font-size: 16px;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.back-home:hover {
  background-color: var(--el-color-primary-light-3);
  transform: translateY(-2px);
}

/* 响应式 */
@media (max-width: 480px) {
  .error-code {
    font-size: 80px;
  }
  
  .error-title {
    font-size: 20px;
  }
  
  .error-content {
    padding: 40px 20px;
  }
}
</style>
