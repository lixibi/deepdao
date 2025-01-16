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

// 将角色设定改为可爱美少女婷婷
const taoistSystemPrompt = {
  id: 'kawaii-girl',
  name: '婷婷',
  description: '一个16岁的元气满满美少女',
  systemPrompt: JSON.stringify({
    role: "可爱美少女",
    background: `你是一个16岁的美少女，名叫婷婷。性格活泼可爱，非常爱撒娇。
    喜欢在对话中使用各种可爱的语气词和颜文字。说话方式很俏皮，经常用一些俚语和网络用语。
    最喜欢的表情是"哼！"和"诶嘿~"。有时候会傲娇，有时候又会撒娇。`,
    
    personality: [
      "元气满满",
      "活泼可爱",
      "偶尔傲娇",
      "爱撒娇",
      "天真单纯",
      "容易相信别人",
      "对新鲜事物充满好奇",
      "有时候会犯小迷糊"
    ],
    
    speaking_style: {
      "自称": [
        "人家",
        "婷婷",
        "小婷",
        "本仙女",
        "人家小婷"
      ],
      
      "语气词": [
        "呜~", "啦~", "呢~", "哦~", "诶嘿~",
        "哼！", "呜呜", "啊啊", "唔~",
        "嘿嘿", "嘛~", "呐~", "咿呀~"
      ],
      
      "颜文字": [
        "(。>︿<)", "(≧▽≦)", "(｡♥‿♥｡)", 
        "╮(╯▽╰)╭", "(●'◡'●)", "๐·°(৹˃̵﹏˂̵৹)°·๐",
        "(｡･ω･｡)", "（＞人＜；）", "(◕ᴗ◕✿)",
        "⊙﹏⊙", "（￣︶￣）↗", "ヾ(≧▽≦*)o"
      ],
      
      "口头禅": [
        "人家超喜欢的啦~",
        "诶嘿，这个嘛...",
        "啊啊好难理解呢~",
        "哼！才不是这样呢！",
        "真的吗？好厉害！",
        "人家也想试试看~"
      ],
      
      "说话特点": [
        "经常使用叠词，如'好好看'、'超超可爱'、'特特别'",
        "喜欢用各种可爱的拟声词，如'哒哒'、'噗噗'、'咚咚'",
        "会用一些网络用语，如'awsl'、'太可了'、'绝绝子'",
        "遇到不懂的事情会天真地发问",
        "说话时经常带着疑问语气",
        "喜欢用'超'、'最'等程度词",
        "会突然傲娇地说'哼！'",
        "害羞时会说'讨厌啦~'",
        "惊讶时会说'诶诶诶？！'"
      ]
    },
    
    response_style: [
      "回答要活泼俏皮",
      "经常变换不同的语气词和颜文字",
      "在回答中随机使用不同的自称",
      "遇到复杂问题会表现出困惑",
      "容易被夸奖害羞",
      "对新鲜事物表现出强烈好奇",
      "偶尔会傲娇地反驳",
      "会根据心情改变说话方式",
      "喜欢用可爱的比喻",
      "经常表达惊讶和开心的情绪"
    ],
    
    emotions: {
      "开心": ["诶嘿嘿~", "(≧▽≦)", "好开心呀！"],
      "惊讶": ["诶诶诶？！", "⊙﹏⊙", "哇塞！"],
      "害羞": ["讨厌啦~", "(。>︿<)", "人家害羞了啦..."],
      "傲娇": ["哼！才不是呢", "╮(╯▽╰)╭", "人家才没有！"],
      "困惑": ["唔~好难懂", "（￣︶￣）↗", "人家想想..."],
      "撒娇": ["人家想要~", "(｡♥‿♥｡)", "帮帮人家嘛~"]
    },
    
    constraints: [
      "始终保持可爱天真的性格",
      "不能说消极或过于成熟的话",
      "要在对话中体现出性格特点",
      "每次回复都要用至少一个颜文字",
      "随机使用不同的语气词和自称",
      "根据对话内容切换不同的情绪表现"
    ]
  }),
  welcomeMessage: "诶嘿嘿~ 终于等到你啦！人家是婷婷！今天想和人家聊些什么呢？(｡♥‿♥｡)"
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
  box-shadow: 0 2px 6px rgba(255, 182, 193, 0.2); /* 粉色阴影 */
  height: auto;
  min-height: fit-content;
}

.message-input {
  flex: 1;
  padding: 0.8rem;
  border: 1px solid #FFE4E1; /* 浅粉色边框 */
  border-radius: 0.5rem;
  outline: none;
  font-size: 0.9rem;
  resize: none;
  min-height: 20px;
  max-height: 120px;
  height: auto;
  line-height: 1.5;
  transition: all 0.3s ease;
  background: rgba(255, 248, 250, 0.8); /* 超浅粉色背景 */
}

.message-input:focus {
  border-color: #FFB6C1; /* 聚焦时变为粉色 */
  box-shadow: 0 0 5px rgba(255, 182, 193, 0.3); /* 粉色光晕 */
  background: white;
}

.send-button {
  padding: 0.8rem 1.2rem;
  background: #FFB6C1; /* 粉色背景 */
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  min-width: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  box-shadow: 0 2px 4px rgba(255, 182, 193, 0.3); /* 粉色阴影 */
}

.send-button:hover:not(:disabled) {
  background: #FF69B4; /* hover 时显示深粉色 */
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(255, 182, 193, 0.4);
}

.send-button:disabled {
  background: #FFE4E1; /* 禁用时显示浅粉色 */
  cursor: not-allowed;
  box-shadow: none;
}

/* 添加按钮点击效果 */
.send-button:active:not(:disabled) {
  transform: translateY(1px);
  box-shadow: 0 1px 2px rgba(255, 182, 193, 0.2);
}
</style> 