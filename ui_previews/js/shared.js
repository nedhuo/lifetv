// 共享JavaScript功能

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', function() {
    // 初始化所有交互元素
    initInteractions();
    
    // 初始化响应式设计
    initResponsive();
    
    // 初始化模拟数据
    initMockData();
});

// 初始化交互元素
function initInteractions() {
    // 按钮悬停效果
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-1px)';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // 卡片悬停效果
    const cards = document.querySelectorAll('.card, .video-card, .list-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // 开关组件交互
    const switches = document.querySelectorAll('.switch input');
    switches.forEach(switchInput => {
        switchInput.addEventListener('change', function() {
            const slider = this.nextElementSibling;
            if (this.checked) {
                slider.style.backgroundColor = 'var(--primary-color)';
            } else {
                slider.style.backgroundColor = 'var(--border-color)';
            }
        });
    });
    
    // 视频卡片点击事件
    const videoCards = document.querySelectorAll('.video-card');
    videoCards.forEach(card => {
        card.addEventListener('click', function() {
            // 模拟跳转到视频播放页
            alert('跳转到视频播放页');
        });
    });
    
    // 侧边栏导航点击事件
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    sidebarItems.forEach(item => {
        item.addEventListener('click', function() {
            // 移除所有活跃状态
            sidebarItems.forEach(sidebarItem => {
                sidebarItem.classList.remove('active');
            });
            
            // 添加当前活跃状态
            this.classList.add('active');
        });
    });
    
    // 顶部导航标签点击事件
    const topnavTabs = document.querySelectorAll('.topnav-tab');
    topnavTabs.forEach(tab => {
        tab.addEventListener('click', function(e) {
            e.preventDefault();
            // 移除所有活跃状态
            topnavTabs.forEach(topnavTab => {
                topnavTab.classList.remove('active');
            });
            
            // 添加当前活跃状态
            this.classList.add('active');
        });
    });
}

// 初始化响应式设计
function initResponsive() {
    // 监听窗口大小变化
    window.addEventListener('resize', function() {
        updateLayout();
    });
    
    // 初始更新
    updateLayout();
}

// 更新布局
function updateLayout() {
    const width = window.innerWidth;
    const sidebar = document.querySelector('.sidebar');
    const topnav = document.querySelector('.topnav');
    const mainContent = document.querySelector('.main-content');
    
    if (width <= 768) {
        // 移动端布局
        if (sidebar) {
            sidebar.style.width = '0';
        }
        if (topnav) {
            topnav.style.left = '0';
        }
        if (mainContent) {
            mainContent.style.marginLeft = '0';
        }
    } else {
        // 桌面端布局
        if (sidebar) {
            sidebar.style.width = 'var(--sidebar-width)';
        }
        if (topnav) {
            topnav.style.left = 'var(--sidebar-width)';
        }
        if (mainContent) {
            mainContent.style.marginLeft = 'var(--sidebar-width)';
        }
    }
}

// 初始化模拟数据
function initMockData() {
    // 模拟视频播放量
    const videoMetas = document.querySelectorAll('.video-card-meta');
    videoMetas.forEach(meta => {
        const views = Math.floor(Math.random() * 100000) + 1000;
        meta.textContent = `播放量: ${formatNumber(views)}`;
    });
    
    // 模拟加载状态
    const loadingElements = document.querySelectorAll('.loading');
    loadingElements.forEach(element => {
        // 模拟加载完成
        setTimeout(() => {
            element.style.display = 'none';
        }, 1000);
    });
}

// 格式化数字（添加千位分隔符）
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// 模拟API请求
function mockApiRequest(url, options = {}) {
    return new Promise((resolve, reject) => {
        // 模拟网络延迟
        setTimeout(() => {
            // 模拟成功响应
            resolve({
                success: true,
                data: options.data || {},
                message: '请求成功'
            });
        }, 500);
    });
}

// 显示消息提示
function showMessage(message, type = 'info') {
    // 创建消息元素
    const messageElement = document.createElement('div');
    messageElement.className = `message message-${type}`;
    messageElement.textContent = message;
    
    // 添加样式
    messageElement.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background: var(--bg-primary);
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius-sm);
        box-shadow: var(--shadow-md);
        color: var(--text-primary);
        z-index: 10000;
        animation: slideIn 0.3s ease;
    `;
    
    // 添加到页面
    document.body.appendChild(messageElement);
    
    // 3秒后自动移除
    setTimeout(() => {
        messageElement.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            messageElement.remove();
        }, 300);
    }, 3000);
}

// 添加CSS动画
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .fade-in {
        animation: fadeIn 0.5s ease;
    }
`;
document.head.appendChild(style);

// 页面导航功能
function navigateTo(pageUrl) {
    window.location.href = pageUrl;
}

// 模拟视频播放
function playVideo(videoId) {
    showMessage('开始播放视频: ' + videoId);
    // 这里可以添加实际的视频播放逻辑
}

// 模拟添加到收藏
function addToFavorites(itemId) {
    showMessage('已添加到收藏');
    // 这里可以添加实际的收藏逻辑
}

// 模拟从收藏中移除
function removeFromFavorites(itemId) {
    showMessage('已从收藏中移除');
    // 这里可以添加实际的移除逻辑
}

// 模拟添加到历史记录
function addToHistory(itemId) {
    showMessage('已添加到历史记录');
    // 这里可以添加实际的历史记录逻辑
}

// 模拟搜索功能
function search(query) {
    showMessage('搜索: ' + query);
    // 这里可以添加实际的搜索逻辑
}

// 模拟设置更新
function updateSetting(key, value) {
    showMessage('设置已更新: ' + key + ' = ' + value);
    // 这里可以添加实际的设置更新逻辑
}

// 响应式导航切换
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    const topnav = document.querySelector('.topnav');
    const mainContent = document.querySelector('.main-content');
    
    if (sidebar.style.width === '0px' || sidebar.style.width === '') {
        // 展开侧边栏
        sidebar.style.width = 'var(--sidebar-width)';
        topnav.style.left = 'var(--sidebar-width)';
        mainContent.style.marginLeft = 'var(--sidebar-width)';
    } else {
        // 收起侧边栏
        sidebar.style.width = '0';
        topnav.style.left = '0';
        mainContent.style.marginLeft = '0';
    }
}

// 生成随机ID
function generateId() {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}

// 生成模拟视频数据
function generateMockVideos(count = 12) {
    const videos = [];
    const categories = ['电影', '电视剧', '综艺', '动漫', '纪录片'];
    
    for (let i = 0; i < count; i++) {
        videos.push({
            id: generateId(),
            title: `视频标题 ${i + 1}`,
            category: categories[Math.floor(Math.random() * categories.length)],
            views: Math.floor(Math.random() * 100000) + 1000,
            duration: `${Math.floor(Math.random() * 2) + 1}:${Math.floor(Math.random() * 60).toString().padStart(2, '0')}`,
            thumbnail: `https://picsum.photos/seed/video${i}/320/180`
        });
    }
    
    return videos;
}

// 生成模拟视频源数据
function generateMockSources(count = 5) {
    const sources = [];
    
    for (let i = 0; i < count; i++) {
        sources.push({
            id: generateId(),
            name: `视频源 ${i + 1}`,
            url: `https://example.com/source${i + 1}`,
            isDefault: i === 0,
            isActive: true,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
    }
    
    return sources;
}

// 生成模拟设置项数据
function generateMockSettings() {
    return [
        { key: 'autoPlay', label: '自动播放', type: 'boolean', value: true },
        { key: 'hdQuality', label: '默认高清画质', type: 'boolean', value: false },
        { key: 'notifications', label: '接收通知', type: 'boolean', value: true },
        { key: 'darkMode', label: '深色模式', type: 'boolean', value: false },
        { key: 'language', label: '语言', type: 'select', value: 'zh-CN', options: ['zh-CN', 'en-US', 'ja-JP'] },
        { key: 'downloadPath', label: '下载路径', type: 'text', value: '/Downloads/Videos' },
        { key: 'maxDownloads', label: '最大同时下载数', type: 'number', value: 3 }
    ];
}

// 渲染视频卡片
function renderVideoCards(containerId, videos) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    container.innerHTML = '';
    
    videos.forEach(video => {
        const card = document.createElement('div');
        card.className = 'video-card';
        card.innerHTML = `
            <div class="video-card-thumbnail" style="background-image: url(${video.thumbnail}); background-size: cover; background-position: center;"></div>
            <div class="video-card-content">
                <h4 class="video-card-title">${video.title}</h4>
                <p class="video-card-meta">${video.category} • ${formatNumber(video.views)}次播放</p>
            </div>
        `;
        
        card.addEventListener('click', function() {
            playVideo(video.id);
        });
        
        container.appendChild(card);
    });
}

// 渲染视频源列表
function renderSourceList(containerId, sources) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    container.innerHTML = '';
    
    sources.forEach(source => {
        const card = document.createElement('div');
        card.className = 'list-card';
        card.innerHTML = `
            <h4>${source.name}</h4>
            <p style="color: var(--text-secondary); font-size: var(--font-size-sm); margin-bottom: var(--spacing-md);">${source.url}</p>
            <div class="action-buttons">
                <button class="btn btn-sm btn-outline" onclick="updateSource('${source.id}')">编辑</button>
                <button class="btn btn-sm btn-outline" onclick="deleteSource('${source.id}')">删除</button>
                ${source.isDefault ? '<span style="color: var(--success-color); margin-left: auto;">默认</span>' : ''}
            </div>
        `;
        
        container.appendChild(card);
    });
}

// 渲染设置项
function renderSettings(containerId, settings) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    container.innerHTML = '';
    
    settings.forEach(setting => {
        const settingItem = document.createElement('div');
        settingItem.className = 'setting-item';
        
        let controlHtml = '';
        
        switch (setting.type) {
            case 'boolean':
                controlHtml = `
                    <label class="switch">
                        <input type="checkbox" ${setting.value ? 'checked' : ''} onchange="updateSetting('${setting.key}', this.checked)">
                        <span class="slider"></span>
                    </label>
                `;
                break;
            case 'select':
                controlHtml = `
                    <select onchange="updateSetting('${setting.key}', this.value)">
                        ${setting.options.map(option => `<option value="${option}" ${setting.value === option ? 'selected' : ''}>${option}</option>`).join('')}
                    </select>
                `;
                break;
            case 'text':
            case 'number':
                controlHtml = `
                    <input type="${setting.type}" value="${setting.value}" onchange="updateSetting('${setting.key}', this.value)">
                `;
                break;
        }
        
        settingItem.innerHTML = `
            <span class="setting-item-label">${setting.label}</span>
            ${controlHtml}
        `;
        
        container.appendChild(settingItem);
    });
}

// 模拟更新视频源
function updateSource(sourceId) {
    showMessage('编辑视频源: ' + sourceId);
    // 这里可以添加实际的编辑逻辑
}

// 模拟删除视频源
function deleteSource(sourceId) {
    showMessage('删除视频源: ' + sourceId);
    // 这里可以添加实际的删除逻辑
}

// 模拟切换视频源
function switchSource(sourceId) {
    showMessage('切换视频源: ' + sourceId);
    // 这里可以添加实际的切换逻辑
}

// 模拟添加视频源
function addSource() {
    showMessage('添加视频源');
    // 这里可以添加实际的添加逻辑
}
