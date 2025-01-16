# 构建阶段
FROM oven/bun:1 as builder

WORKDIR /app

# 复制项目文件
COPY . .

# 安装依赖并构建
RUN bun install
RUN bun run build

# 生产阶段
FROM nginx:alpine

# 复制构建产物到 Nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 