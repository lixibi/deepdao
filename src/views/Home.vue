<template>
  <div class="ai-agent-container">
    <!-- 折叠按钮 -->
    <button class="expand-button" @click="isExpanded = !isExpanded">
      <span class="arrow" :class="{ 'arrow-up': !isExpanded }">▼</span>
    </button>
    <!-- 聊天区域 -->
    <div class="chat-wrapper" :class="{ 'expanded': isExpanded }">
      <div class="chat-container">
        <div class="chat-history" ref="chatHistoryEl">
          <div v-for="(message, index) in chatHistory" :key="index"
            :class="['message', message.role]">
            <!-- 只显示AI头像 -->
            <div v-if="message.role === 'assistant'" class="avatar">
              <img src="/avatar.jpg" alt="道长" />
            </div>
            <div 
              class="bubble" 
              :class="{ 
                'typing': message.isTyping,
                'typing ending': message.isEnding 
              }"
              v-html="processMarkdown(message.content)"
            >
            </div>
          </div>
        </div>
        
        <!-- AI聊天组件 -->
        <AIChatBox ref="chatBox" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch, nextTick } from 'vue';
import AIChatBox from '../components/AIChatBox.vue';

const chatBox = ref(null);
const chatHistoryEl = ref(null);
const isExpanded = ref(false);

// 计算属性获取聊天历史
const chatHistory = computed(() => chatBox.value?.chatHistory || []);

// 使用 processMarkdown 函数
const processMarkdown = (text) => {
  return chatBox.value?.processMarkdown(text) || text;
};

// 监听聊天历史变化，包括内容的变化
watch(
  chatHistory,
  () => {
    setTimeout(() => {
      if (chatHistoryEl.value) {
        chatHistoryEl.value.scrollTop = chatHistoryEl.value.scrollHeight;
      }
    }, 100);
  },
  { deep: true } // 添加 deep: true 以监听深层变化
);

// 添加自动滚动函数
const scrollToBottom = () => {
  if (chatHistoryEl.value) {
    chatHistoryEl.value.scrollTop = chatHistoryEl.value.scrollHeight;
  }
};

// 监听消息内容变化
watch(
  () => chatHistory.value.map(msg => msg.content),
  () => {
    nextTick(scrollToBottom);
  },
  { deep: true }
);
</script>

<style scoped>
.ai-agent-container {
  min-height: 100vh;
  background: url('/back.png') center/cover no-repeat fixed;
  display: flex;
  flex-direction: column;
  position: relative;
  justify-content: flex-start; /* 改为从顶部开始布局 */
  align-items: center;
  padding: 2rem;
}

.chat-wrapper {
  width: 100%;
  max-width: 1200px;
  height: 52.5vh;
  margin-top: 35vh;
  padding: 0 1rem;
  transition: all 0.3s ease;
  position: relative;
}

.chat-wrapper.expanded {
  height: 85vh;
  margin-top: 5vh;
}

.expand-button {
  position: absolute;
  top: -1rem;
  left: 50%;
  transform: translateX(-50%);
  background: #E3BC9A; /* 典雅的米褐色 */
  border: 1px solid #B88D57; /* 古铜色边框 */
  border-radius: 0.5rem 0.5rem 0 0;
  padding: 0.5rem 2.5rem;
  cursor: pointer;
  box-shadow: 0 -2px 6px rgba(184, 141, 87, 0.2);
  transition: all 0.3s ease;
  z-index: 100;
  font-size: 1.2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 100px;
  /* 添加云纹背景 */
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='20' viewBox='0 0 80 20'%3E%3Cpath d='M30,10 Q35,5 40,10 Q45,15 50,10' fill='none' stroke='%23B88D57' stroke-width='1' opacity='0.3'/%3E%3C/svg%3E");
  background-size: 80px 20px;
  background-repeat: repeat-x;
  background-position: center;
}

.expand-button:hover {
  background-color: #D4A373; /* 稍深的米褐色 */
  box-shadow: 0 -2px 12px rgba(184, 141, 87, 0.3);
  transform: translateX(-50%) translateY(2px);
}

.arrow {
  display: inline-block;
  transition: transform 0.3s ease;
  font-size: 1.2rem;
  line-height: 1;
  color: #8C4E37; /* 深褐色箭头 */
}

.arrow-up {
  transform: rotate(180deg);
}

.chat-container {
  height: 100%;
  background: rgba(252, 248, 242, 0.95); /* 米白色背景 */
  padding: 0.5rem;
  box-shadow: 0 4px 12px rgba(184, 141, 87, 0.2);
  display: flex;
  flex-direction: column;
  border-radius: 1rem;
  backdrop-filter: blur(10px);
  border: 1px solid #B88D57;
  /* 添加云纹背景 */
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='120' viewBox='0 0 120 120'%3E%3Cpath d='M30,60 Q45,45 60,60 Q75,75 90,60 M15,30 Q30,15 45,30 Q60,45 75,30 M45,90 Q60,75 75,90 Q90,105 105,90' fill='none' stroke='%23B88D57' stroke-width='1' opacity='0.1'/%3E%3C/svg%3E");
  background-size: 120px 120px;
}

.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem;
  margin-bottom: 0.5rem;
  scrollbar-width: thin;
  scrollbar-color: rgba(184, 141, 87, 0.3) transparent;
}

.chat-history::-webkit-scrollbar {
  width: 6px;
}

.chat-history::-webkit-scrollbar-track {
  background: transparent;
}

.chat-history::-webkit-scrollbar-thumb {
  background-color: rgba(184, 141, 87, 0.3);
  border-radius: 3px;
}

.message {
  margin: 0.5rem 0;
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding-left: 0.5rem; /* 添加左边距，让头像靠左一点 */
}

.message.user {
  justify-content: flex-end;
  padding-left: 0;
  padding-right: 0.5rem; /* 用户消息右边距 */
}

.avatar {
  width: 32px;
  height: 32px;
  min-width: 32px;
  margin-top: 4px; /* 头像稍微下移一点，与文字对齐 */
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.bubble {
  max-width: calc(100% - 44px);
  padding: 0.6rem 0.8rem;
  border-radius: 0.8rem;
  font-size: 0.9rem;
  line-height: 1.4;
  position: relative;
  text-align: left;
  box-shadow: 0 2px 4px rgba(184, 141, 87, 0.1);
}

/* AI消息的特殊样式 */
.ai .bubble {
  background: rgba(227, 188, 154, 0.2); /* 浅米色背景 */
  border: 1px solid rgba(184, 141, 87, 0.3);
  border-top-left-radius: 0.2rem;
  margin-right: -44px;
  padding-left: 44px;
  text-indent: -36px;
  color: #5C3D2E; /* 深褐色文字 */
}

/* 用户消息样式 */
.user .bubble {
  max-width: 85%;
  background: #B88D57; /* 古铜色背景 */
  color: #FCF8F2; /* 米白色文字 */
  border-top-right-radius: 0.2rem;
  margin-left: 0;
  border: 1px solid rgba(92, 61, 46, 0.2);
}

/* 确保消息内容中的换行符正确显示 */
.bubble :deep(br) {
  display: block;
  content: "";
  margin-top: 0.5em;
}

/* 移动端适配 */
@media (max-width: 640px) {
  .ai-agent-container {
    padding: 0.5rem;
  }

  .chat-wrapper {
    padding: 0 0.25rem;
  }

  .chat-container {
    padding: 0.3rem;
  }

  .message {
    padding-left: 0.25rem;
    margin: 0.4rem 0;
  }

  .message.user {
    padding-right: 0.25rem;
  }

  .avatar {
    width: 28px; /* 移动端头像更小 */
    height: 28px;
    min-width: 28px;
  }

  .bubble {
    font-size: 0.9rem;
    padding: 0.5rem 0.7rem;
    max-width: calc(100% - 36px);
  }

  .ai .bubble {
    margin-right: -32px;
    padding-left: 32px;
    text-indent: -28px;
  }

  .user .bubble {
    max-width: 80%;
  }

  .chat-history {
    padding: 0.25rem;
  }

  .chat-wrapper.expanded {
    height: 90vh;
    margin-top: 2vh;
  }

  .expand-button {
    top: -0.8rem;
    padding: 0.4rem 1.5rem;
    font-size: 1rem;
    min-width: 80px;
    background-size: 60px 15px; /* 调整移动端云纹大小 */
  }

  .arrow {
    font-size: 1.2rem;
  }

  .chat-container {
    background-size: 80px 80px; /* 调整移动端云纹大小 */
  }

  .ai .bubble {
    background: rgba(227, 188, 154, 0.15);
  }
}

/* 更小屏幕的适配 */
@media (max-width: 380px) {
  .bubble {
    font-size: 0.85rem;
    padding: 0.4rem 0.6rem;
  }

  .avatar {
    width: 24px;
    height: 24px;
    min-width: 24px;
  }

  .ai .bubble {
    margin-right: -28px;
    padding-left: 28px;
    text-indent: -24px;
  }

  .user .bubble {
    max-width: 75%;
  }
}

.typing::after {
  content: '';
  display: inline-block;
  vertical-align: middle;
  width: 16px;
  height: 16px;
  margin-left: 4px;
  background-image: url("data:image/svg+xml,%3Csvg t='1737011556781' viewBox='0 0 1024 1024' version='1.1' xmlns='http://www.w3.org/2000/svg' p-id='12573'%3E%3Cpath d='M510.977 62.648c-247.511 0-448.16 200.649-448.16 448.16s200.649 448.16 448.16 448.16c247.511 0 448.16-200.649 448.16-448.16s-200.649-448.16-448.16-448.16z m0 174.782c33.002 0 59.756 26.754 59.756 59.756s-26.754 59.755-59.756 59.755-59.755-26.754-59.755-59.755c0-33.004 26.753-59.756 59.755-59.756z m0 700.624c-117.979 0-213.623-95.641-213.623-213.622 0-117.979 90.394-213.622 213.623-213.622l0.001-0.002c117.98-0.001 213.622-95.641 213.622-213.622 0-111.627-85.625-203.242-194.777-212.785-0.144-0.152-0.296-0.292-0.443-0.44 227.422 9.64 408.841 197.052 408.841 426.849 0.001 235.961-191.284 427.246-427.245 427.246z' p-id='12574' fill='%23dbdbdb'%3E%3C/path%3E%3Cpath d='M451.222 724.431c0 33.002 26.753 59.755 59.755 59.755s59.755-26.753 59.755-59.755-26.753-59.755-59.755-59.755-59.755 26.753-59.755 59.755z' p-id='12575' fill='%23dbdbdb'%3E%3C/path%3E%3C/svg%3E");
  background-size: contain;
  background-repeat: no-repeat;
  animation: rotate 3s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  opacity: 0;
  animation: appear 0.3s ease forwards, rotate 3s cubic-bezier(0.4, 0, 0.2, 1) infinite;
}

@keyframes rotate {
  0% {
    transform: rotate(0deg) scale(1);
  }
  50% {
    transform: rotate(180deg) scale(0.95);
  }
  100% {
    transform: rotate(360deg) scale(1);
  }
}

@keyframes appear {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.typing.ending::after {
  animation: rotate 3s cubic-bezier(0.4, 0, 0.2, 1) infinite, disappear 1.5s ease forwards;
}

@keyframes disappear {
  0% {
    opacity: 1;
    transform: scale(1) rotate(0deg);
  }
  100% {
    opacity: 0;
    transform: scale(0.8) rotate(360deg);
  }
}

/* 深色模式下的光标颜色调整 */
@media (prefers-color-scheme: dark) {
  .typing::after {
    background-image: url("data:image/svg+xml,%3Csvg t='1737011556781' viewBox='0 0 1024 1024' version='1.1' xmlns='http://www.w3.org/2000/svg' p-id='12573'%3E%3Cpath d='M510.977 62.648c-247.511 0-448.16 200.649-448.16 448.16s200.649 448.16 448.16 448.16c247.511 0 448.16-200.649 448.16-448.16s-200.649-448.16-448.16-448.16z m0 174.782c33.002 0 59.756 26.754 59.756 59.756s-26.754 59.755-59.756 59.755-59.755-26.754-59.755-59.755c0-33.004 26.753-59.756 59.755-59.756z m0 700.624c-117.979 0-213.623-95.641-213.623-213.622 0-117.979 90.394-213.622 213.623-213.622l0.001-0.002c117.98-0.001 213.622-95.641 213.622-213.622 0-111.627-85.625-203.242-194.777-212.785-0.144-0.152-0.296-0.292-0.443-0.44 227.422 9.64 408.841 197.052 408.841 426.849 0.001 235.961-191.284 427.246-427.245 427.246z' p-id='12574' fill='%23ffffff'%3E%3C/path%3E%3Cpath d='M451.222 724.431c0 33.002 26.753 59.755 59.755 59.755s59.755-26.753 59.755-59.755-26.753-59.755-59.755-59.755-59.755 26.753-59.755 59.755z' p-id='12575' fill='%23ffffff'%3E%3C/path%3E%3C/svg%3E");
    opacity: 0.7;
  }
}

/* 确保消息内容中的链接样式正确 */
.bubble :deep(a) {
  color: #8C4E37;
  text-decoration: none;
  border-bottom: 1px solid rgba(140, 78, 55, 0.3);
}

.bubble :deep(a):hover {
  border-bottom-color: #8C4E37;
}

/* 确保代码块样式正确 */
.bubble :deep(pre) {
  background: rgba(92, 61, 46, 0.05);
  padding: 1rem;
  border-radius: 0.5rem;
  border: 1px solid rgba(184, 141, 87, 0.2);
  overflow-x: auto;
  margin: 0.5rem 0;
}

.bubble :deep(code) {
  background: rgba(92, 61, 46, 0.05);
  padding: 0.2rem 0.4rem;
  border-radius: 0.25rem;
  font-size: 0.9em;
  color: #5C3D2E;
}
</style> 