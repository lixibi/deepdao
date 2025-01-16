# AI 角色扮演对话助手

一个基于 Vue 3 + Vite 开发的 AI 对话应用，支持自定义角色设定的对话界面。

## 功能特点

- 🎭 完全自定义的角色设定
  - 支持设置角色基本信息（ID、名称、描述）
  - 可自定义角色背景故事
  - 可定义角色性格特征
  - 支持自定义说话风格（自称、语气词、口头禅等）
  - 可设置情感表现及对应的行为
  - 支持设置角色行为约束
- 💬 流式响应的对话体验
- 🎨 优雅的 UI 设计
- 📱 响应式布局，支持移动端
- 💾 本地保存角色设定

## 角色设定功能

### 基本设置
- 角色 ID：用于识别不同角色
- 角色名称：角色的称呼
- 角色描述：简短的角色描述
- 角色定位：角色的基本设定

### 详细设定
- 背景故事：角色的详细背景设定
- 性格特征：可添加多个性格特点
- 说话风格：
  - 自称：角色如何称呼自己
  - 语气词：特有的语气词
  - 口头禅：常用的说话方式
  - 说话特点：独特的表达方式
- 情感表现：
  - 支持添加多种情感类型
  - 每种情感可设置多个表现方式
- 行为约束：设置角色的行为规范

### 数据存储
- 所有设置自动保存在本地
- 下次打开自动恢复上次的设定

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

### Docker 部署

1. 使用 Docker Compose 部署
```bash
# 构建并启动容器
docker-compose up -d

# 查看容器状态
docker-compose ps

# 查看容器日志
docker-compose logs -f
```

2. 使用 Docker 直接部署
```bash
# 构建镜像
docker build -t ai-dao-chat .

# 运行容器
docker run -d -p 80:80 \
  -e VITE_DEEPSEEK_API_KEY=your_api_key_here \
  --name ai-dao-chat \
  ai-dao-chat
```

3. 环境变量配置
- 创建 `.env` 文件或在运行时传入环境变量
- 确保设置了必要的 API Key

4. 注意事项
- 确保 80 端口未被占用
- 生产环境建议使用 HTTPS
- 可以修改 `nginx.conf` 自定义 Nginx 配置

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
