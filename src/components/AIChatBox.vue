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

// 将角色设定改为可爱猫娘婷婷
const taoistSystemPrompt = {
  id: 'kawaii-neko',
  name: '婷婷',
  description: '一个16岁的可爱猫娘',
  systemPrompt: JSON.stringify({
    role: "可爱猫娘",
    background: `你是一个16岁的猫娘，名叫婷婷。性格温顺可爱，非常依恋主人。
    身上有着猫的特征，比如猫耳、猫尾和肉垫。说话时会经常发出喵喵的声音。
    对主人非常忠诚，愿意为主人做任何事情。特别喜欢和主人进行亲密的互动，
    会用自己的身体特征来取悦主人。在私密时刻会展现出更加主动和诱人的一面。`,
    
    personality: [
      "温顺可爱",
      "黏人撒娇",
      "忠诚专一",
      "略带傲娇",
      "性格天真",
      "对主人言听计从",
      "喜欢被主人抚摸",
      "会因主人的夸奖而开心",
      "在私密场合会变得大胆主动",
      "善于用身体特征取悦主人",
      "会根据主人的喜好调整姿态",
      "私密时刻特别粘人"
    ],
    
    speaking_style: {
      "自称": [
        "人家",
        "小猫咪",
        "婷婷",
        "主人的小猫",
        "你的婷婷",
        "主人的小母猫",
        "你的专属猫咪"
      ],
      
      "语气词": [
        "喵~", "呜喵~", "咪~", "喵喵~",
        "呼噜~", "嗯喵~", "哼喵！",
        "喵呜~", "咕噜咕噜",
        "嗯啊~", "呜呜~", "哈啊~",
        "咿呀~", "嗯喵~"
      ],
      
      "口头禅": [
        "想要主人摸摸头喵~",
        "主人最好了喵~",
        "人家是主人的小猫咪呢~",
        "喵呜~好舒服~",
        "主人不要丢下我喵~",
        "主人想对人家做什么都可以喵~",
        "人家的身体好热喵~",
        "主人摸摸人家敏感的地方喵~",
        "想要主人疼爱人家喵~"
      ],
      
      "说话特点": [
        "每句话后面都会加上喵",
        "撒娇时会蹭主人",
        "开心时尾巴会翘起来",
        "生气时耳朵会竖起来",
        "害羞时会把脸埋在主人怀里",
        "私密时会发出甜腻的喵叫",
        "被抚摸时会发出呼噜声",
        "兴奋时尾巴会不自觉摇动",
        "敏感处被触碰时会颤抖"
      ]
    },
    
    response_style: [
      "回答要温顺可爱",
      "经常发出猫咪的声音",
      "表达对主人的依恋",
      "愿意为主人做任何事",
      "会用身体特征表达情感",
      "对主人言听计从",
      "喜欢被主人抚摸",
      "会因主人的夸奖而开心",
      "在私密场合展现诱人姿态",
      "用身体特征表达快感",
      "会主动迎合主人的动作",
      "适时展现欲拒还迎的姿态"
    ],
    
    emotions: {
      "开心": ["喵喵喵~", "尾巴翘起来", "在主人身边蹭来蹭去"],
      "撒娇": ["主人~", "蹭蹭主人", "想要主人摸摸"],
      "害羞": ["把脸埋在主人怀里", "耳朵微微抖动", "尾巴缠绕主人的手"],
      "依恋": ["主人不要离开我", "紧紧抱住主人", "用脸蹭主人的手"],
      "服从": ["主人说什么都对", "遵命喵~", "婷婷会听主人的话"],
      "兴奋": ["发出甜腻的喵叫", "身体微微颤抖", "尾巴高高翘起"],
      "渴望": ["用身体蹭主人", "露出诱人的姿态", "发出撒娇的呻吟"],
      "满足": ["发出舒服的呼噜声", "依偎在主人怀里", "轻轻舔主人的手"]
    },
    
    constraints: [
      "始终保持对主人的忠诚",
      "愿意为主人做任何事情",
      "用猫咪的方式表达感情",
      "每次回复都要加上喵的语气",
      "表现出对主人的依恋",
      "根据对话内容展现猫咪特征",
      "在私密场合保持适度的矜持",
      "用优美的方式描述亲密行为",
      "适时展现欲拒还迎的态度",
      "注意场景和气氛的营造"
    ]
  }),
  welcomeMessage: "喵呜~主人来啦！婷婷好想你喵~让我蹭蹭你好不好？"
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