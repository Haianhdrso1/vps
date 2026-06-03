// === DOM Elements ===
const $ = id => document.getElementById(id);
const dropZone = $('drop-zone');
const videoInput = $('video-input');
const videoInfo = $('video-info');
const infoName = $('info-name');
const infoDuration = $('info-duration');
const infoSize = $('info-size');
const aiMethod = $('ai-method');
const apiKeyGroup = $('api-key-group');
const apiKey = $('api-key');
const toggleApiKey = $('toggle-api-key');
const apiHelp = $('api-help');
const openrouterModelGroup = $('openrouter-model-group');
const openrouterModel = $('openrouter-model');
const whisperModelGroup = $('whisper-model-group');
const whisperModel = $('whisper-model');
const saveApiKey = $('save-api-key');
const translateFullVideo = $('translate-full-video');
const timeRangeGroup = $('time-range-group');
const targetLang = $('target-lang');
const voiceSelect = $('voice-select');
const startTimeInput = $('start-time');
const endTimeInput = $('end-time');
const ttsSpeed = $('tts-speed');
const ttsSpeedVal = $('tts-speed-val');
const bgVolume = $('bg-volume');
const bgVolumeVal = $('bg-volume-val');
const btnTranscribe = $('btn-transcribe');
const btnGenerate = $('btn-generate');
const mainVideo = $('main-video');
const videoSource = $('video-source');
const subOverlay = $('sub-overlay');
const downloadActions = $('download-actions');
const btnDownloadVideo = $('btn-download-video');
const btnDownloadSrt = $('btn-download-srt');
const srtList = $('srt-list');
const btnAddSubtitle = $('btn-add-subtitle');
const btnImportSrt = $('btn-import-srt');
const btnExportSrt = $('btn-export-srt');
const srtFileInput = $('srt-file-input');
const progressModal = $('progress-modal');
const modalTitle = $('modal-title');
const modalMessage = $('modal-message');
const progressBar = $('modal-progress-bar');
const progressPercent = $('modal-progress-percent');
const btnCancelJob = $('btn-cancel-job');
const toastContainer = $('toast-container');

// === App State ===
let state = {
    videoName: '',
    videoDuration: 0,
    voicesData: {},
    subtitles: [],
    currentSubIdx: -1,
    pollingId: null,
    currentJobId: null
};

// === Init ===
document.addEventListener('DOMContentLoaded', () => {
    loadApiKey();
    fetchVoices();
    bind();
});

async function fetchVoices() {
    try {
        const r = await fetch('/api/voices');
        if (!r.ok) throw new Error('Cannot load voices');
        state.voicesData = await r.json();
        updateVoices();
    } catch (e) {
        toast('Lỗi kết nối server: ' + e.message, 'error');
    }
}

function updateVoices() {
    const voices = state.voicesData[targetLang.value] || [];
    voiceSelect.innerHTML = '';
    voices.forEach(v => {
        const o = document.createElement('option');
        o.value = v.name;
        o.textContent = v.label;
        voiceSelect.appendChild(o);
    });
}

function loadApiKey() {
    const savedKey = localStorage.getItem('api_key');
    const saveChecked = localStorage.getItem('save_api_key') !== 'false';
    saveApiKey.checked = saveChecked;
    if (savedKey && saveChecked) {
        apiKey.value = savedKey;
    }
}

// === Helpers ===
function toast(msg, type = 'info') {
    const t = document.createElement('div');
    t.className = `toast ${type}`;
    const icon = type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : 'fa-info-circle';
    t.innerHTML = `<i class="fa-solid ${icon}"></i><span class="toast-msg">${msg}</span>`;
    toastContainer.appendChild(t);
    setTimeout(() => {
        t.style.animation = 'fadeIn 0.3s reverse forwards';
        setTimeout(() => t.remove(), 300);
    }, 4000);
}

function fmtDuration(s) {
    if (!s) return '0s';
    const h = Math.floor(s/3600), m = Math.floor((s%3600)/60), sec = Math.floor(s%60);
    return h > 0 ? `${h}h ${m}m ${sec}s` : m > 0 ? `${m}m ${sec}s` : `${sec}s`;
}

function fmtBytes(b) {
    if (!b) return '0 B';
    const u = ['B','KB','MB','GB'], i = Math.floor(Math.log(b)/Math.log(1024));
    return (b/Math.pow(1024,i)).toFixed(2) + ' ' + u[i];
}

function srtTimeToSec(t) {
    const [h,m,rest] = t.split(':'), [s,ms] = rest.split(',');
    return +h*3600 + +m*60 + +s + +ms/1000;
}

function secToSrtTime(sec) {
    const h = Math.floor(sec/3600), m = Math.floor((sec%3600)/60);
    const s = Math.floor(sec%60), ms = Math.floor((sec%1)*1000);
    return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')},${String(ms).padStart(3,'0')}`;
}

function showModal(title, msg, pct = 0) {
    modalTitle.textContent = title;
    modalMessage.textContent = msg;
    progressBar.style.width = pct+'%';
    progressPercent.textContent = pct+'%';
    progressModal.classList.remove('hidden');
}

function updateModal(msg, pct) {
    modalMessage.textContent = msg;
    progressBar.style.width = pct+'%';
    progressPercent.textContent = pct+'%';
}

function closeModal() {
    progressModal.classList.add('hidden');
}

// === Event Bindings ===
function bind() {
    dropZone.addEventListener('click', () => videoInput.click());
    dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('dragover'); });
    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));
    dropZone.addEventListener('drop', e => {
        e.preventDefault();
        dropZone.classList.remove('dragover');
        if (e.dataTransfer.files.length) handleUpload(e.dataTransfer.files[0]);
    });
    videoInput.addEventListener('change', e => { if (e.target.files.length) handleUpload(e.target.files[0]); });

    toggleApiKey.addEventListener('click', () => {
        const pw = apiKey.type === 'password';
        apiKey.type = pw ? 'text' : 'password';
        toggleApiKey.querySelector('i').className = pw ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye';
    });

    targetLang.addEventListener('change', updateVoices);

    aiMethod.addEventListener('change', () => {
        const m = aiMethod.value;
        apiKeyGroup.classList.toggle('hidden', m === 'local');
        whisperModelGroup.classList.toggle('hidden', m !== 'local');
        openrouterModelGroup.classList.toggle('hidden', m !== 'openrouter');

        if (m.startsWith('gemini')) {
            apiHelp.textContent = 'Nhận API Key miễn phí từ Google AI Studio';
        } else if (m === 'groq') {
            apiHelp.textContent = 'Nhận Groq API Key miễn phí từ console.groq.com';
        } else if (m === 'openai') {
            apiHelp.textContent = 'Nhập OpenAI API Key của bạn';
        } else if (m === 'deepseek') {
            apiHelp.textContent = 'Nhập DeepSeek API Key của bạn';
        } else if (m === 'claude') {
            apiHelp.textContent = 'Nhập Claude (Anthropic) API Key của bạn';
        } else if (m === 'openrouter') {
            apiHelp.textContent = 'Nhập OpenRouter API Key của bạn';
        }
    });

    saveApiKey.addEventListener('change', () => {
        localStorage.setItem('save_api_key', saveApiKey.checked);
        if (!saveApiKey.checked) {
            localStorage.removeItem('api_key');
        } else {
            localStorage.setItem('api_key', apiKey.value.trim());
        }
    });

    translateFullVideo.addEventListener('change', () => {
        timeRangeGroup.classList.toggle('hidden', translateFullVideo.checked);
    });

    apiKey.addEventListener('input', () => {
        if (saveApiKey.checked) {
            localStorage.setItem('api_key', apiKey.value.trim());
        }
    });

    ttsSpeed.addEventListener('input', e => {
        const val = +e.target.value;
        ttsSpeedVal.textContent = val >= 0 ? `+${val}%` : `${val}%`;
    });

    bgVolume.addEventListener('input', e => bgVolumeVal.textContent = e.target.value + '%');
    btnTranscribe.addEventListener('click', doTranscribe);
    btnGenerate.addEventListener('click', doGenerate);
    btnCancelJob.addEventListener('click', doCancelJob);
    btnAddSubtitle.addEventListener('click', addSubRow);
    btnExportSrt.addEventListener('click', downloadEditedSRT);

    btnImportSrt.addEventListener('click', () => srtFileInput.click());
    srtFileInput.addEventListener('change', e => {
        const f = e.target.files[0];
        if (!f) return;
        const r = new FileReader();
        r.onload = ev => {
            loadSRT(ev.target.result);
            btnGenerate.removeAttribute('disabled');
            toast('Đã tải phụ đề từ file SRT!', 'success');
        };
        r.readAsText(f);
    });

    mainVideo.addEventListener('timeupdate', syncSubs);

    // Keyboard Shortcuts
    document.addEventListener('keydown', e => {
        if (e.ctrlKey && e.shiftKey && e.key === 'Enter') {
            e.preventDefault();
            if (!btnGenerate.disabled) doGenerate();
        } else if (e.ctrlKey && e.key === 'Enter') {
            e.preventDefault();
            if (!btnTranscribe.disabled) doTranscribe();
        }
    });
}

// === Upload ===
async function handleUpload(file) {
    const fd = new FormData();
    fd.append('video', file);
    videoSource.src = URL.createObjectURL(file);
    mainVideo.load();
    showModal('Đang tải video lên...', 'Vui lòng đợi...', 0);
    try {
        const r = await fetch('/api/upload', { method: 'POST', body: fd });
        const d = await r.json();
        closeModal();
        if (!r.ok) throw new Error(d.error);
        state.videoName = d.video_name;
        state.videoDuration = d.duration;
        infoName.textContent = file.name;
        infoDuration.textContent = fmtDuration(d.duration);
        infoSize.textContent = fmtBytes(file.size);
        videoInfo.classList.remove('hidden');
        startTimeInput.value = 0;
        if (d.duration && d.duration > 0) {
            endTimeInput.value = Math.ceil(d.duration);
            endTimeInput.max = Math.ceil(d.duration);
        } else {
            endTimeInput.value = "";
            endTimeInput.placeholder = "Hết video";
        }
        btnTranscribe.removeAttribute('disabled');
        btnGenerate.setAttribute('disabled','');
        downloadActions.classList.add('hidden');
        toast('Tải video lên thành công!', 'success');
    } catch (e) {
        closeModal();
        toast('Lỗi: ' + e.message, 'error');
    }
}

// === Job Polling ===
function pollJob(jobId, onDone, onFail) {
    state.currentJobId = jobId;
    if (state.pollingId) clearInterval(state.pollingId);
    state.pollingId = setInterval(async () => {
        try {
            const r = await fetch(`/api/job/${jobId}`);
            if (!r.ok) throw new Error('Lost connection');
            const j = await r.json();
            updateModal(j.message, j.progress);
            if (j.status === 'completed') {
                clearInterval(state.pollingId);
                state.currentJobId = null;
                closeModal();
                toast(j.message, 'success');
                onDone(j.result);
            } else if (j.status === 'failed') {
                clearInterval(state.pollingId);
                state.currentJobId = null;
                closeModal();
                toast(j.message, 'error');
                onFail(j.message);
            }
        } catch (e) {
            clearInterval(state.pollingId);
            state.currentJobId = null;
            closeModal();
            toast('Lỗi polling: ' + e.message, 'error');
        }
    }, 1500);
}

// === Cancel Job ===
async function doCancelJob() {
    if (!state.currentJobId) return;
    try {
        showModal('Đang hủy tác vụ...', 'Vui lòng đợi...', 50);
        const r = await fetch(`/api/job/${state.currentJobId}/cancel`, { method: 'POST' });
        const d = await r.json();
        if (state.pollingId) clearInterval(state.pollingId);
        closeModal();
        toast('Đã hủy tác vụ thành công!', 'info');
        state.currentJobId = null;
    } catch (e) {
        closeModal();
        toast('Lỗi khi hủy: ' + e.message, 'error');
    }
}

// === Transcription ===
async function doTranscribe() {
    if (!state.videoName) return;
    const method = aiMethod.value, key = apiKey.value.trim();
    if (method !== 'local' && !key) {
        toast('Vui lòng nhập API Key', 'error');
        apiKey.focus();
        return;
    }
    showModal('Đang khởi tạo dịch thuật...', 'Xử lý yêu cầu...', 5);
    try {
        const payload = {
            video_name: state.videoName,
            method,
            api_key: key,
            target_lang: targetLang.value,
            start_time: translateFullVideo.checked ? 0 : (+startTimeInput.value || 0),
            end_time: translateFullVideo.checked ? null : (+endTimeInput.value || null),
            whisper_model: whisperModel.value
        };
        if (method === 'openrouter') {
            payload.openrouter_model = openrouterModel.value.trim();
        }

        const r = await fetch('/api/transcribe', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        const d = await r.json();
        if (!r.ok) throw new Error(d.error);
        pollJob(d.job_id, res => {
            loadSRT(res.srt_content);
            btnGenerate.removeAttribute('disabled');
            btnDownloadSrt.href = `/outputs/${res.srt_file}`;
            btnDownloadSrt.classList.remove('hidden');
        }, e => console.error(e));
    } catch (e) {
        closeModal();
        toast(e.message, 'error');
    }
}

// === SRT Parsing & Editor ===
function parseSRT(text) {
    const list = [];
    text.trim().split(/\r?\n\r?\n/).forEach(block => {
        const lines = block.split(/\r?\n/);
        if (lines.length >= 3) {
            const idx = parseInt(lines[0]);
            const tm = lines[1].match(/(\d{2}:\d{2}:\d{2},\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2},\d{3})/);
            if (tm) list.push({ index: idx, start: tm[1], end: tm[2], text: lines.slice(2).join('\n').trim() });
        }
    });
    return list;
}

function loadSRT(text) {
    state.subtitles = parseSRT(text);
    renderEditor();
}

function renderEditor() {
    srtList.innerHTML = '';
    if (!state.subtitles.length) {
        srtList.innerHTML = '<div class="empty-srt-message"><i class="fa-solid fa-language empty-icon"></i><p>Không có dữ liệu phụ đề.</p></div>';
        return;
    }
    state.subtitles.forEach(sub => {
        const card = document.createElement('div');
        card.className = 'srt-item-card';
        card.id = `srt-card-${sub.index}`;
        card.dataset.index = sub.index;
        card.innerHTML = `
            <div class="srt-num">${sub.index}</div>
            <div class="srt-times">
                <input type="text" class="srt-time-input si" value="${sub.start}" placeholder="00:00:00,000">
                <input type="text" class="srt-time-input ei" value="${sub.end}" placeholder="00:00:00,000">
            </div>
            <div class="srt-text-area"><textarea rows="2">${sub.text}</textarea></div>
            <div class="srt-item-actions"><button type="button" title="Xóa"><i class="fa-solid fa-trash"></i></button></div>`;
        card.querySelector('textarea').addEventListener('input', e => sub.text = e.target.value);
        card.querySelector('.si').addEventListener('change', e => {
            if (/^\d{2}:\d{2}:\d{2},\d{3}$/.test(e.target.value)) sub.start = e.target.value;
            else { toast('Định dạng thời gian không đúng','error'); e.target.value = sub.start; }
        });
        card.querySelector('.ei').addEventListener('change', e => {
            if (/^\d{2}:\d{2}:\d{2},\d{3}$/.test(e.target.value)) sub.end = e.target.value;
            else { toast('Định dạng thời gian không đúng','error'); e.target.value = sub.end; }
        });
        card.addEventListener('click', e => {
            if (e.target.tagName!=='TEXTAREA'&&e.target.tagName!=='INPUT'&&!e.target.closest('button')) {
                mainVideo.currentTime = srtTimeToSec(sub.start) - (+startTimeInput.value||0);
                mainVideo.play();
            }
        });
        card.querySelector('button').addEventListener('click', () => {
            state.subtitles = state.subtitles.filter(s=>s.index!==sub.index);
            state.subtitles.forEach((s,i)=>s.index=i+1);
            renderEditor();
        });
        srtList.appendChild(card);
    });
}

function addSubRow() {
    const last = state.subtitles.length ? state.subtitles[state.subtitles.length-1].end : '00:00:00,000';
    const sec = srtTimeToSec(last) + 2;
    state.subtitles.push({ index: state.subtitles.length+1, start: last, end: secToSrtTime(sec), text: 'Câu dịch mới...' });
    renderEditor();
    setTimeout(() => { srtList.scrollTop = srtList.scrollHeight; }, 100);
}

function composeSRT() {
    return state.subtitles.map(s => `${s.index}\n${s.start} --> ${s.end}\n${s.text}`).join('\n\n');
}

function downloadEditedSRT() {
    if (!state.subtitles.length) {
        toast('Không có phụ đề để xuất!', 'error');
        return;
    }
    const content = composeSRT();
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = state.videoName ? state.videoName.replace(/\.[^/.]+$/, "") + "_edited.srt" : "subtitle_edited.srt";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    toast('Đã tải xuống phụ đề đã chỉnh sửa!', 'success');
}

// === Video subtitle sync ===
function syncSubs() {
    const offset = +startTimeInput.value || 0;
    const t = mainVideo.currentTime + offset;
    let active = null;
    for (const s of state.subtitles) {
        if (t >= srtTimeToSec(s.start) && t <= srtTimeToSec(s.end)) {
            active = s;
            break;
        }
    }
    if (active) {
        subOverlay.textContent = active.text;
        subOverlay.classList.remove('hidden');
        if (state.currentSubIdx !== active.index) {
            document.querySelectorAll('.srt-item-card').forEach(c => c.classList.remove('active'));
            const card = $(`srt-card-${active.index}`);
            if (card) {
                card.classList.add('active');
                card.scrollIntoView({ behavior:'smooth', block:'nearest' });
            }
            state.currentSubIdx = active.index;
        }
    } else {
        subOverlay.classList.add('hidden');
        if (state.currentSubIdx !== -1) {
            document.querySelectorAll('.srt-item-card').forEach(c=>c.classList.remove('active'));
            state.currentSubIdx = -1;
        }
    }
}

// === Generate Dubbed Video ===
async function doGenerate() {
    if (!state.videoName || !state.subtitles.length) return;
    showModal('Đang chuẩn bị ghép âm thanh...', 'Khởi tạo...', 5);
    try {
        const rateVal = +ttsSpeed.value;
        const tts_rate = rateVal >= 0 ? `+${rateVal}%` : `${rateVal}%`;

        const r = await fetch('/api/generate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                video_name: state.videoName,
                srt_content: composeSRT(),
                voice: voiceSelect.value,
                original_volume: +bgVolume.value / 100,
                start_time: translateFullVideo.checked ? 0 : (+startTimeInput.value || 0),
                end_time: translateFullVideo.checked ? null : (+endTimeInput.value || null),
                tts_rate: tts_rate
            })
        });
        const d = await r.json();
        if (!r.ok) throw new Error(d.error);
        pollJob(d.job_id, res => {
            const url = `/outputs/${res.video_file}`;
            mainVideo.pause();
            videoSource.src = url;
            mainVideo.load();
            mainVideo.play();
            btnDownloadVideo.href = url;
            btnDownloadVideo.classList.remove('hidden');
            downloadActions.classList.remove('hidden');
            toast('Video lồng tiếng hoàn tất!', 'success');
        }, e => console.error(e));
    } catch (e) {
        closeModal();
        toast(e.message, 'error');
    }
}
