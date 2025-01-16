<template>
  <div v-if="show" class="settings-modal">
    <div class="settings-content">
      <div class="settings-header">
        <h2>角色提示词设置</h2>
        <button @click="closeModal" class="close-btn">×</button>
      </div>
      
      <div class="settings-body">
        <div class="settings-section">
          <label>角色ID <span class="required">*</span></label>
          <input 
            v-model="localSettings.id" 
            type="text"
            @blur="validateField(localSettings, 'id')"
            :class="{ 'error': errors.id }"
          >
          <span class="error-text" v-if="errors.id">请输入角色ID</span>
        </div>

        <div class="settings-section">
          <label>角色名称 <span class="required">*</span></label>
          <input 
            v-model="localSettings.name" 
            type="text"
            @blur="validateField(localSettings, 'name')"
            :class="{ 'error': errors.name }"
          >
          <span class="error-text" v-if="errors.name">请输入角色名称</span>
        </div>

        <div class="settings-section">
          <label>角色描述 <span class="required">*</span></label>
          <input 
            v-model="localSettings.description" 
            type="text"
            @blur="validateField(localSettings, 'description')"
            :class="{ 'error': errors.description }"
          >
          <span class="error-text" v-if="errors.description">请输入角色描述</span>
        </div>

        <div class="settings-section">
          <label>角色 <span class="required">*</span></label>
          <input 
            v-model="systemPromptObj.role" 
            type="text"
            @blur="validateField(systemPromptObj, 'role')"
            :class="{ 'error': errors.role }"
          >
          <span class="error-text" v-if="errors.role">请输入角色</span>
        </div>

        <div class="settings-section">
          <label>背景故事 <span class="required">*</span></label>
          <textarea 
            v-model="systemPromptObj.background" 
            rows="4"
            @blur="validateField(systemPromptObj, 'background')"
            :class="{ 'error': errors.background }"
          ></textarea>
          <span class="error-text" v-if="errors.background">请输入背景故事</span>
        </div>

        <div class="settings-section">
          <label>性格特征 <span class="required">*</span></label>
          <div class="array-editor">
            <div v-for="(trait, index) in systemPromptObj.personality" :key="index" class="array-item">
              <input 
                v-model="systemPromptObj.personality[index]" 
                type="text"
                @blur="validateArrayItem(systemPromptObj.personality, index)"
                :class="{ 'error': errors['personality'+index] }"
              >
              <button @click="removeItem(systemPromptObj.personality, index)" class="remove-btn" :disabled="systemPromptObj.personality.length <= 1">-</button>
            </div>
            <button @click="addItem(systemPromptObj.personality)" class="add-btn">添加特征</button>
          </div>
        </div>

        <div class="settings-section">
          <label>说话风格 <span class="required">*</span></label>
          <div v-for="(value, key) in (systemPromptObj.speaking_style || {})" :key="key" class="subsection">
            <h4>{{ key }}</h4>
            <div class="array-editor">
              <div v-for="(item, index) in value" :key="index" class="array-item">
                <input 
                  v-model="systemPromptObj.speaking_style[key][index]" 
                  type="text"
                  @blur="validateArrayItem(systemPromptObj.speaking_style[key], index)"
                  :class="{ 'error': errors['speaking_style_' + key + '_' + index] }"
                >
                <button 
                  @click="removeItem(value, index)" 
                  class="remove-btn" 
                  :disabled="!value || value.length <= 1"
                >-</button>
              </div>
              <button @click="addItem(value)" class="add-btn">添加</button>
            </div>
          </div>
        </div>

        <div class="settings-section">
          <label>情感表现 <span class="required">*</span></label>
          <div class="field-input" v-if="showEmotionInput">
            <input 
              v-model="newEmotionName" 
              placeholder="输入情感名称"
              @keyup.enter="handleAddEmotion"
              :class="{ 'error': errors.newEmotion }"
            >
            <span class="error-text" v-if="errors.newEmotion && errors.newEmotionDuplicate">
              该情感名称已存在
            </span>
            <span class="error-text" v-if="errors.newEmotion && !errors.newEmotionDuplicate">
              请输入情感名称
            </span>
            <div class="field-input-buttons">
              <button @click="handleAddEmotion" class="add-btn">确定</button>
              <button @click="cancelAddEmotion" class="cancel-btn">取消</button>
            </div>
          </div>
          <div v-if="!systemPromptObj.emotions || Object.keys(systemPromptObj.emotions || {}).length === 0" class="error-text">
            至少需要添加一个情感类型
          </div>
          <div v-for="(value, key) in (systemPromptObj.emotions || {})" :key="key" class="subsection">
            <div class="field-header">
              <div class="field-title">
                <input 
                  v-model="emotionNames[key]" 
                  class="field-name-input"
                  @blur="updateEmotionName(key)"
                  :placeholder="key"
                >
              </div>
              <button 
                @click="removeEmotion(key)" 
                class="remove-btn"
                :disabled="!systemPromptObj.emotions || Object.keys(systemPromptObj.emotions || {}).length <= 1"
                :title="!systemPromptObj.emotions || Object.keys(systemPromptObj.emotions || {}).length <= 1 ? '至少需要保留一个情感类型' : ''"
              >删除</button>
            </div>
            <div class="array-editor">
              <div v-for="(item, index) in value" :key="index" class="array-item">
                <input 
                  v-model="systemPromptObj.emotions[key][index]" 
                  type="text"
                  @blur="validateArrayItem(value, index)"
                  :class="{ 'error': errors['emotions_' + key + '_' + index] }"
                >
                <button 
                  @click="removeItem(value, index)" 
                  class="remove-btn" 
                  :disabled="!value || value.length <= 1"
                  :title="!value || value.length <= 1 ? '至少需要保留一个表现' : ''"
                >-</button>
              </div>
              <div class="error-text" v-if="errors['emotions_' + key]">
                请添加至少一个情感表现
              </div>
              <button @click="addItem(value)" class="add-btn">添加表现</button>
            </div>
          </div>
          <button v-if="!showEmotionInput" @click="showEmotionInput = true" class="add-btn">添加新情感</button>
        </div>

        <div class="settings-section">
          <label>约束条件 <span class="required">*</span></label>
          <div class="array-editor">
            <div v-for="(constraint, index) in (systemPromptObj.constraints || [])" :key="index" class="array-item">
              <input 
                v-model="systemPromptObj.constraints[index]" 
                type="text"
                @blur="validateArrayItem(systemPromptObj.constraints, index)"
                :class="{ 'error': errors['constraints' + index] }"
              >
              <button 
                @click="removeItem(systemPromptObj.constraints, index)" 
                class="remove-btn" 
                :disabled="!systemPromptObj.constraints || systemPromptObj.constraints.length <= 1"
              >-</button>
            </div>
            <button @click="addItem(systemPromptObj.constraints)" class="add-btn">添加约束</button>
          </div>
        </div>
      </div>

      <div class="button-group">
        <button @click="saveSettings" class="save-btn" :disabled="hasErrors">保存</button>
        <button @click="closeModal" class="cancel-btn">取消</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';

const props = defineProps({
  show: Boolean,
  promptSettings: Object,
});

const emit = defineEmits(['update:show', 'update:settings']);

const errors = ref({});
const showEmotionInput = ref(false);
const showSpeakingStyleInput = ref(false);
const newEmotionName = ref('');
const newSpeakingStyleName = ref('');

// 初始化所有需要的响应式状态
const localSettings = ref({});
const systemPromptObj = ref({});
const emotionNames = ref({});
const speakingStyleNames = ref({});

// 初始化函数
const initializeData = () => {
  try {
    // 深拷贝设置
    localSettings.value = JSON.parse(JSON.stringify(props.promptSettings || {}));
    
    // 解析 systemPrompt，确保有默认值
    let systemPromptData = {};
    try {
      systemPromptData = typeof props.promptSettings?.systemPrompt === 'string'
        ? JSON.parse(props.promptSettings.systemPrompt)
        : props.promptSettings?.systemPrompt || {};
    } catch (e) {
      console.error('Failed to parse systemPrompt:', e);
    }

    // 确保所有必要的对象都存在
    systemPromptObj.value = {
      role: systemPromptData.role || '',
      background: systemPromptData.background || '',
      personality: Array.isArray(systemPromptData.personality) ? systemPromptData.personality : [''],
      speaking_style: systemPromptData.speaking_style || {
        "自称": [""],
        "语气词": [""],
        "口头禅": [""],
        "说话特点": [""]
      },
      emotions: systemPromptData.emotions || {
        "开心": [""]
      },
      constraints: Array.isArray(systemPromptData.constraints) ? systemPromptData.constraints : [''],
      response_style: Array.isArray(systemPromptData.response_style) ? systemPromptData.response_style : ['']
    };

    // 初始化情感名称映射
    emotionNames.value = Object.keys(systemPromptObj.value.emotions).reduce((acc, key) => {
      acc[key] = key;
      return acc;
    }, {});

    // 初始化说话风格名称映射
    speakingStyleNames.value = Object.keys(systemPromptObj.value.speaking_style).reduce((acc, key) => {
      acc[key] = key;
      return acc;
    }, {});

  } catch (e) {
    console.error('Failed to initialize data:', e);
    // 设置默认值
    localSettings.value = {
      id: '',
      name: '',
      description: ''
    };
    systemPromptObj.value = {
      role: '',
      background: '',
      personality: [''],
      speaking_style: {
        "自称": [""],
        "语气词": [""],
        "口头禅": [""],
        "说话特点": [""]
      },
      emotions: {
        "开心": [""]
      },
      constraints: [''],
      response_style: ['']
    };
    emotionNames.value = { "开心": "开心" };
    speakingStyleNames.value = {
      "自称": "自称",
      "语气词": "语气词",
      "口头禅": "口头禅",
      "说话特点": "说话特点"
    };
  }
};

// 监听显示状态变化
watch(() => props.show, (newVal) => {
  if (newVal) {
    initializeData();
    errors.value = {};
    showEmotionInput.value = false;
    showSpeakingStyleInput.value = false;
    newEmotionName.value = '';
    newSpeakingStyleName.value = '';
  }
});

// 初始化时也要调用一次
onMounted(() => {
  if (props.show) {
    initializeData();
  }
});

const addItem = (array) => {
  if (Array.isArray(array)) {
    array.push('');
  }
};

const removeItem = (array, index) => {
  if (Array.isArray(array) && array.length > 1) {
    array.splice(index, 1);
  }
};

const addEmotion = () => {
  if (newEmotionName.value.trim()) {
    systemPromptObj.value.emotions = {
      ...systemPromptObj.value.emotions,
      [newEmotionName.value]: []
    };
    newEmotionName.value = '';
  }
};

const removeEmotion = (key) => {
  const emotions = systemPromptObj.value.emotions || {};
  if (Object.keys(emotions).length <= 1) {
    return;
  }
  
  const newEmotions = { ...emotions };
  delete newEmotions[key];
  systemPromptObj.value.emotions = newEmotions;
  delete emotionNames.value[key];
};

const hasErrors = computed(() => {
  return Object.values(errors.value).some(error => error);
});

const validateField = (obj, field) => {
  errors.value[field] = !obj[field]?.trim();
};

const validateArrayItem = (array, index) => {
  if (Array.isArray(array)) {
    errors.value[`${array}_${index}`] = !array[index]?.trim();
  }
};

const validateAll = () => {
  errors.value = {};
  let hasError = false;

  ['id', 'name', 'description'].forEach(field => {
    if (!localSettings.value[field]?.trim()) {
      errors.value[field] = true;
      hasError = true;
    }
  });

  ['role', 'background'].forEach(field => {
    if (!systemPromptObj.value[field]?.trim()) {
      errors.value[field] = true;
      hasError = true;
    }
  });

  ['personality', 'constraints'].forEach(field => {
    if (!systemPromptObj.value[field]?.length) {
      errors.value[field] = true;
      hasError = true;
    } else {
      systemPromptObj.value[field].forEach((item, index) => {
        if (!item?.trim()) {
          errors.value[`${field}_${index}`] = true;
          hasError = true;
        }
      });
    }
  });

  const speakingStyle = systemPromptObj.value.speaking_style;
  if (!Object.keys(speakingStyle).length) {
    errors.value.speaking_style = true;
    hasError = true;
  } else {
    Object.entries(speakingStyle).forEach(([key, array]) => {
      if (!array?.length) {
        errors.value[`speaking_style_${key}`] = true;
        hasError = true;
      } else {
        array.forEach((item, index) => {
          if (!item?.trim()) {
            errors.value[`speaking_style_${key}_${index}`] = true;
            hasError = true;
          }
        });
      }
    });
  }

  const emotions = systemPromptObj.value.emotions;
  if (!Object.keys(emotions).length) {
    errors.value.emotions = true;
    hasError = true;
  } else {
    Object.entries(emotions).forEach(([key, array]) => {
      if (!array?.length) {
        errors.value[`emotions_${key}`] = true;
        hasError = true;
      } else {
        array.forEach((item, index) => {
          if (!item?.trim()) {
            errors.value[`emotions_${key}_${index}`] = true;
            hasError = true;
          }
        });
      }
    });
  }

  return !hasError;
};

const handleAddEmotion = () => {
  const name = newEmotionName.value.trim();
  if (!name) {
    errors.value.newEmotion = true;
    return;
  }
  
  if (systemPromptObj.value.emotions[name]) {
    errors.value.newEmotion = true;
    errors.value.newEmotionDuplicate = true;
    return;
  }

  systemPromptObj.value.emotions = {
    ...systemPromptObj.value.emotions,
    [name]: ['']
  };
  emotionNames.value[name] = name;
  newEmotionName.value = '';
  showEmotionInput.value = false;
  errors.value.newEmotion = false;
  errors.value.newEmotionDuplicate = false;
};

const cancelAddEmotion = () => {
  newEmotionName.value = '';
  showEmotionInput.value = false;
  errors.value.newEmotion = false;
};

const saveSettings = () => {
  if (!validateAll()) {
    return;
  }
  const settings = JSON.parse(JSON.stringify(localSettings.value));
  settings.systemPrompt = JSON.stringify(systemPromptObj.value);
  emit('update:settings', settings);
  closeModal();
};

const closeModal = () => {
  emit('update:show', false);
};

const handleAddSpeakingStyle = () => {
  const name = newSpeakingStyleName.value.trim();
  if (!name) {
    errors.value.newSpeakingStyle = true;
    return;
  }
  
  if (systemPromptObj.value.speaking_style[name]) {
    errors.value.newSpeakingStyle = true;
    errors.value.newSpeakingStyleDuplicate = true;
    return;
  }

  systemPromptObj.value.speaking_style = {
    ...systemPromptObj.value.speaking_style,
    [name]: ['']
  };
  speakingStyleNames.value[name] = name;
  newSpeakingStyleName.value = '';
  showSpeakingStyleInput.value = false;
  errors.value.newSpeakingStyle = false;
  errors.value.newSpeakingStyleDuplicate = false;
};

const cancelAddSpeakingStyle = () => {
  newSpeakingStyleName.value = '';
  showSpeakingStyleInput.value = false;
  errors.value.newSpeakingStyle = false;
};

const updateSpeakingStyleName = (oldKey) => {
  const newKey = speakingStyleNames.value[oldKey]?.trim();
  if (!newKey || newKey === oldKey) return;

  const newSpeakingStyle = {};
  Object.entries(systemPromptObj.value.speaking_style).forEach(([key, value]) => {
    if (key === oldKey) {
      newSpeakingStyle[newKey] = value;
    } else {
      newSpeakingStyle[key] = value;
    }
  });
  systemPromptObj.value.speaking_style = newSpeakingStyle;
  
  const newNames = { ...speakingStyleNames.value };
  delete newNames[oldKey];
  newNames[newKey] = newKey;
  speakingStyleNames.value = newNames;
};

const updateEmotionName = (oldKey) => {
  const newKey = emotionNames.value[oldKey]?.trim();
  if (!newKey || newKey === oldKey) return;

  const newEmotions = {};
  Object.entries(systemPromptObj.value.emotions).forEach(([key, value]) => {
    if (key === oldKey) {
      newEmotions[newKey] = value;
    } else {
      newEmotions[key] = value;
    }
  });
  systemPromptObj.value.emotions = newEmotions;
  
  const newNames = { ...emotionNames.value };
  delete newNames[oldKey];
  newNames[newKey] = newKey;
  emotionNames.value = newNames;
};
</script>

<style scoped>
.settings-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 1rem;
}

.settings-content {
  background: white;
  border-radius: 1rem;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.settings-header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  background: white;
  border-radius: 1rem 1rem 0 0;
  z-index: 1;
}

.settings-body {
  padding: 1rem;
  overflow-y: auto;
  flex: 1;
}

.close-btn {
  font-size: 1.5rem;
  padding: 0.5rem;
  line-height: 1;
  background: none;
  border: none;
  cursor: pointer;
}

.settings-section {
  margin-bottom: 1.5rem;
}

.required {
  color: #f44336;
  margin-left: 0.25rem;
}

.error {
  border-color: #f44336 !important;
}

.error-text {
  color: #f44336;
  font-size: 0.875rem;
  margin-top: 0.25rem;
  display: block;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #666;
}

input, textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 0.5rem;
  margin-bottom: 0.25rem;
  font-size: 1rem;
}

.array-editor {
  border: 1px solid #eee;
  padding: 1rem;
  border-radius: 0.5rem;
}

.array-item {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.subsection {
  margin: 1rem 0;
  padding: 1rem;
  background: #f9f9f9;
  border-radius: 0.5rem;
}

.emotion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.emotion-input {
  margin-bottom: 1rem;
}

.emotion-input-buttons {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.button-group {
  padding: 1rem;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  position: sticky;
  bottom: 0;
  background: white;
  border-radius: 0 0 1rem 1rem;
}

button {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 1rem;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

button[disabled]:hover {
  transform: none;
  box-shadow: none;
}

.add-btn {
  background: #4CAF50;
  color: white;
}

.remove-btn {
  background: #f44336;
  color: white;
  padding: 0.5rem;
  min-width: 2.5rem;
}

.save-btn {
  background: #2196F3;
  color: white;
  min-width: 6rem;
}

.cancel-btn {
  background: #9e9e9e;
  color: white;
  min-width: 6rem;
}

@media (max-width: 640px) {
  .settings-modal {
    padding: 0;
  }

  .settings-content {
    height: 100%;
    max-height: 100%;
    border-radius: 0;
  }

  .settings-header {
    border-radius: 0;
  }

  button {
    padding: 0.75rem 1rem;
  }

  .array-item {
    flex-direction: column;
  }

  .array-item .remove-btn {
    align-self: flex-end;
  }

  .button-group {
    padding: 1rem;
  }
}
</style> 