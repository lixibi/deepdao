# AI 道长对话助手

一个基于 Vue 3 + Vite 开发的 AI 对话应用，采用道家风格的对话界面。

## 功能特点

- 🎭 道家风格的对话界面
- 💬 流式响应的对话体验
- 🎨 优雅的 UI 设计
- 📱 响应式布局，支持移动端

## 环境要求

- Node.js 16.0 或更高版本
- Bun 1.0 或更高版本

## 本地开发设置

1. 克隆项目
```bash
git clone <你的仓库地址>
```

2. 安装依赖
```bash
bun install
```

3. 配置环境变量
```bash
# 复制环境变量示例文件
cp .env.example .env

# 编辑 .env 文件，填入你的 API Key
VITE_DEEPSEEK_API_KEY=your_api_key_here
```

4. 启动开发服务器
```bash
bun dev
```

5. 打开浏览器访问 http://localhost:5173

## 生产环境部署

### 本地构建
```bash
bun run build
```

### Vercel 部署

1. Fork 此项目到你的 GitHub 账号

2. 在 Vercel 中导入项目
   - 连接你的 GitHub 仓库
   - 选择要部署的分支

3. 配置环境变量
   - 在 Vercel 项目设置中添加环境变量
   - 名称：`VITE_DEEPSEEK_API_KEY`
   - 值：你的 API Key

4. 部署设置
   - Framework Preset: Vue.js
   - Build Command: `bun run build`
   - Output Directory: `dist`
   - Install Command: `bun install`

5. 点击 Deploy 开始部署

## 开发相关

### 项目结构
```
src/
  ├── components/     # 组件目录
  ├── views/         # 页面视图
  ├── router/        # 路由配置
  ├── assets/        # 静态资源
  └── App.vue        # 根组件
```

### 可用的命令

```bash
# 开发环境
bun dev

# 生产环境构建
bun run build

# 预览生产构建
bun run preview

# 类型检查
bun run type-check
```

## 注意事项

- 确保 `.env` 文件已添加到 `.gitignore`
- 不要在代码中硬编码 API Key
- 本地开发时请使用自己的 API Key

## 许可证

[MIT License](LICENSE)

![License](https://img.shields.io/github/license/lixibi/deepdao)
![GitHub stars](https://img.shields.io/github/stars/lixibi/deepdao)
![GitHub forks](https://img.shields.io/github/forks/lixibi/deepdao)
