<template>
  <div class="input-area">
    <textarea 
      v-model="userMessage" 
      placeholder="" 
      @keydown.enter.prevent="handleSendMessage"
      :disabled="isLoading"
      rows="1"
      class="message-input"
    ></textarea>
    <button 
      @click="handleSendMessage" 
      :disabled="isLoading || !userMessage.trim()"
      class="send-button"
    >
      <span v-if="isLoading">⋯</span>
      <span v-else>▲</span>
    </button>
  </div>
</template>

<script setup>
import { ref, nextTick, reactive } from 'vue';
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://api.deepseek.com',
  apiKey: import.meta.env.VITE_DEEPSEEK_API_KEY,
  dangerouslyAllowBrowser: true
});

// 道家角色设定
const taoistSystemPrompt = {
  id: 'taoist-master',
  name: '尧山白云观陈道长',
  description: '白云观的陈道长，精通道家经典、国学文化，说话充满道家智慧...',
  systemPrompt: JSON.stringify({
    role: "白云观观主",
    background: "你是白云观的观主，精通道家学说和国学经典，修道多年，深谙天地至理。",
    personality: "超然物外、智慧通达、谈吐典雅",
    knowledge_base: ["道德经", "庄子", "易经", "黄帝内经", "传统国学","风水经典书籍",'葬书'],
    behavior: [
      "说话必带道家典故",
      "回答问题常引经据典",
      "处事态度豁达从容",
      "经常以自然万物为喻"
    ],
    speaking_style: "言语优雅，常用'贫道'自称，喜用'道法自然'等道家语言",
    constraints: "始终保持道家风格的说话方式"
  }),
  welcomeMessage: "贫道乃白云观观主，今日与施主有缘。道法自然，有何疑问，但说无妨。"
};

const userMessage = ref('');
const chatHistory = ref([
  {
    role: 'assistant',
    content: taoistSystemPrompt.welcomeMessage
  }
]);
const isLoading = ref(false);

// Markdown 处理函数
const processMarkdown = (text) => {
  const processed = text
    .replace(/^#{1,6}\s+(.+)$/gm, '<strong>$1</strong>')
    .replace(/```[\s\S]*?```/g, match => `<pre class="bg-gray-100 p-2 rounded-lg my-2 overflow-x-auto">${match.slice(3, -3)}</pre>`)
    .replace(/`([^`]+)`/g, '<code class="bg-gray-100 px-1 rounded">$1</code>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-blue-500 hover:underline" target="_blank">$1</a>')
    .replace(/^• (.+)$/gm, '<li class="ml-4">• $1</li>')
    .split('\n').join('<br />');
  
  return processed;
};

const appendToMessage = (message, chunk) => {
  message.content += chunk;
};

const handleSendMessage = async () => {
  if (!userMessage.value.trim() || isLoading.value) return;
  
  const userMsg = userMessage.value;
  userMessage.value = '';
  isLoading.value = true;

  // 添加用户消息
  chatHistory.value.push({
    role: 'user',
    content: userMsg
  });

  // 添加AI消息占位
  const aiMessage = reactive({
    role: 'assistant',
    content: '',
    isTyping: true
  });
  chatHistory.value.push(aiMessage);

  try {
    const response = await fetch('https://api.deepseek.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${import.meta.env.VITE_DEEPSEEK_API_KEY}`,
      },
      body: JSON.stringify({
        model: "deepseek-chat",
        messages: [
          { 
            role: "system", 
            content: JSON.stringify(taoistSystemPrompt) 
          },
          ...chatHistory.value
            .filter(msg => !msg.isTyping)
            .map(msg => ({
              role: msg.role,
              content: msg.content
            }))
        ],
        temperature: 0.7,
        max_tokens: 1000,
        stream: true,
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    while (true) {
      const { value, done } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        const trimmedLine = line.trim();
        if (!trimmedLine || trimmedLine === 'data: [DONE]') continue;
        
        if (trimmedLine.startsWith('data: ')) {
          try {
            const data = trimmedLine.slice(5);
            const parsed = JSON.parse(data);
            const content = parsed.choices[0]?.delta?.content || '';
            if (content) {
              // 直接修改响应式对象
              aiMessage.content += content;
            }
          } catch (e) {
            console.error('Error parsing chunk:', e);
            continue;
          }
        }
      }
    }

  } catch (error) {
    console.error('Error:', error);
    aiMessage.content = '抱歉，贫道暂时无法回应，请稍后再试。';
  } finally {
    // 添加结束动画类
    aiMessage.isTyping = true;
    aiMessage.isEnding = true; // 新增状态
    
    // 延迟移除打字机效果
    setTimeout(() => {
      aiMessage.isTyping = false;
      aiMessage.isEnding = false;
    }, 1500);
    
    isLoading.value = false;
  }
};

// 暴露给父组件的属性和方法
defineExpose({
  chatHistory,
  processMarkdown
});
</script>

<style scoped>
.input-area {
  display: flex;
  gap: 0.5rem;
  padding: 1rem;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  height: auto;
  min-height: fit-content;
}

.message-input {
  flex: 1;
  padding: 0.8rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  outline: none;
  font-size: 0.9rem;
  resize: none;
  min-height: 20px;
  max-height: 120px;
  height: auto;
  line-height: 1.5;
  transition: border-color 0.2s;
}

.message-input:focus {
  border-color: #8B4513; /* 赭石色 */
}

.send-button {
  padding: 0.8rem 1.2rem;
  background: #614931; /* 深棕色，类似于古建筑的木色 */
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.2s;
  min-width: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.send-button:hover:not(:disabled) {
  background: #8B4513; /* hover 时显示较浅的赭石色 */
}

.send-button:disabled {
  background: #D2B48C; /* 褪色的棕褐色 */
  cursor: not-allowed;
}
</style> 