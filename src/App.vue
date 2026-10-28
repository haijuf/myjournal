<script setup lang="ts">
import { computed, ref } from 'vue'
import {
  ArrowUpRight, BookOpen, CalendarDays, Check, ChevronRight, CircleCheck,
  FileText, Flame, LayoutDashboard, Menu, Plus, Search, Settings, Sparkles, Target, Trash2,
  X, Zap
} from 'lucide-vue-next'
import { useAppStore } from './stores/app'
import { useAuthStore } from './stores/auth'
import type { View } from './types'

const store = useAppStore()
const auth = useAuthStore()
const currentView = ref<View>('overview')
const mobileOpen = ref(false)
const modal = ref<'mission' | 'habit' | 'agenda' | 'journal' | 'note' | null>(null)
const search = ref('')
const toast = ref('')
const email = ref('')
const password = ref('')

const navItems: { id: View; label: string; icon: typeof LayoutDashboard }[] = [
  { id: 'overview', label: 'Overview', icon: LayoutDashboard },
  { id: 'missions', label: 'Weekly Missions', icon: Target },
  { id: 'agenda', label: 'Agenda', icon: CalendarDays },
  { id: 'habits', label: 'Habits', icon: Flame },
  { id: 'journal', label: 'Journal', icon: BookOpen },
  { id: 'notes', label: 'Notes', icon: FileText },
]

const pageTitle = computed(() => navItems.find((item) => item.id === currentView.value)?.label ?? 'Settings')
const dateLabel = computed(() => new Intl.DateTimeFormat('en-US', { weekday: 'long', month: 'long', day: 'numeric' }).format(new Date()))
const filteredNotes = computed(() => store.data.notes.filter((note) => !search.value || `${note.title} ${note.content}`.toLowerCase().includes(search.value.toLowerCase())))
const filteredJournal = computed(() => store.data.journal.filter((entry) => !search.value || `${entry.title} ${entry.content}`.toLowerCase().includes(search.value.toLowerCase())))

async function handleLogin() {
  try {
    await auth.login(email.value, password.value)
    notify('Login berhasil')
  } catch (error) {
    notify(auth.error || 'Login gagal')
  }
}

async function handleRegister() {
  try {
    await auth.register(email.value, password.value)
    notify('Akun dibuat')
  } catch (error) {
    notify(auth.error || 'Pendaftaran gagal')
  }
}

async function handleLogout() {
  await auth.logout()
  email.value = ''
  password.value = ''
  notify('Berhasil logout')
}

function navigate(view: View) {
  currentView.value = view
  mobileOpen.value = false
  search.value = ''
}
function notify(message: string) {
  toast.value = message
  window.setTimeout(() => { toast.value = '' }, 2600)
}
function openModal(type: typeof modal.value) { modal.value = type }
function closeModal() { modal.value = null }
function submitMission(event: SubmitEvent) {
  const form = new FormData(event.target as HTMLFormElement)
  store.addMission({
    title: String(form.get('title')), description: String(form.get('description') || ''),
    category: String(form.get('category') || 'Personal'), startDate: String(form.get('startDate')),
    endDate: String(form.get('endDate')), status: 'Active',
  })
  closeModal(); notify('Mission berhasil dibuat')
}
function submitHabit(event: SubmitEvent) {
  const form = new FormData(event.target as HTMLFormElement)
  store.addHabit({
    title: String(form.get('title')), description: String(form.get('description') || ''),
    category: String(form.get('category') || 'Personal'), trackingType: form.get('trackingType') as 'Completion' | 'Duration' | 'Quantity',
    targetValue: Number(form.get('targetValue') || 1), targetUnit: String(form.get('targetUnit') || 'sesi'),
    frequency: Number(form.get('frequency') || 1), period: 'Weekly', startDate: store.today, archived: false,
  })
  closeModal(); notify('Habit berhasil ditambahkan')
}
function submitAgenda(event: SubmitEvent) {
  const form = new FormData(event.target as HTMLFormElement)
  store.addAgenda({ title: String(form.get('title')), description: String(form.get('description') || ''), date: String(form.get('date')), time: String(form.get('time') || 'All day'), category: String(form.get('category') || 'Personal'), status: 'Planned' })
  closeModal(); notify('Agenda berhasil ditambahkan')
}
function submitJournal(event: SubmitEvent) {
  const form = new FormData(event.target as HTMLFormElement)
  store.addJournal({ title: String(form.get('title')), date: String(form.get('date')), content: String(form.get('content')), category: String(form.get('category') || 'Reflection') })
  closeModal(); notify('Journal tersimpan')
}
function submitNote(event: SubmitEvent) {
  const form = new FormData(event.target as HTMLFormElement)
  store.addNote({ title: String(form.get('title')), content: String(form.get('content')), category: String(form.get('category') || 'Ideas'), pinned: false })
  closeModal(); notify('Catatan tersimpan')
}
function remove(collection: 'missions' | 'habits' | 'agenda' | 'journal' | 'notes', id: string) {
  if (window.confirm('Hapus item ini secara permanen?')) {
    store.deleteItem(collection, id)
    notify('Item dihapus')
  }
}
</script>

<template>
  <div v-if="auth.loading" class="auth-shell">
    <div class="auth-card"><div class="brand-mark"><Sparkles :size="17" /></div><p>Checking secure session...</p></div>
  </div>

  <div v-else-if="!auth.isAuthenticated" class="auth-shell">
    <div class="auth-card">
      <div class="brand-mark"><Sparkles :size="17" /></div>
      <span class="eyebrow">Secure access</span>
      <h2>Journal Jufri</h2>
      <p class="auth-copy">Sign in with your Supabase account to continue.</p>
      <form class="auth-form" @submit.prevent="handleLogin">
        <label>Email<input v-model="email" type="email" placeholder="you@example.com" required /></label>
        <label>Password<input v-model="password" type="password" placeholder="••••••••" required /></label>
        <button class="primary-button full" type="submit">Login</button>
        <button class="secondary-button" type="button" @click="handleRegister">Create account</button>
      </form>
      <p v-if="auth.error" class="auth-error">{{ auth.error }}</p>
    </div>
  </div>

  <div v-else class="app-shell">
    <aside class="sidebar" :class="{ 'is-open': mobileOpen }">
      <div class="brand"><div class="brand-mark"><Sparkles :size="17" /></div><div><strong>Journal Jufri</strong><span>Personal workspace</span></div></div>
      <div class="sidebar-section"><span class="eyebrow">Workspace</span>
        <button v-for="item in navItems" :key="item.id" class="nav-item" :class="{ active: currentView === item.id }" @click="navigate(item.id)">
          <component :is="item.icon" :size="17" /><span>{{ item.label }}</span>
        </button>
      </div>
      <div class="sidebar-bottom">
        <button class="nav-item" :class="{ active: currentView === 'settings' }" @click="navigate('settings')"><Settings :size="17" /> Settings</button>
        <div class="profile-mini"><div class="avatar">{{ store.data.profileName.slice(0, 1).toUpperCase() }}</div><div><strong>{{ store.data.profileName }}</strong><span>Personal account</span></div><button class="text-button logout-button" @click="handleLogout">Logout</button></div>
      </div>
    </aside>
    <div v-if="mobileOpen" class="mobile-backdrop" @click="mobileOpen = false"></div>
    <main class="main-content">
      <header class="topbar">
        <button class="icon-button mobile-menu" @click="mobileOpen = true"><Menu :size="20" /></button>
        <div class="breadcrumb"><span>Workspace</span><ChevronRight :size="14" /><strong>{{ pageTitle }}</strong></div>
        <div class="topbar-actions"><div class="date-context"><CalendarDays :size="15" /> {{ dateLabel }}</div><button class="avatar">{{ store.data.profileName.slice(0, 1).toUpperCase() }}</button></div>
      </header>
      <div class="page">
        <section class="page-heading">
          <div><p class="eyebrow">{{ currentView === 'overview' ? dateLabel : 'Your personal workspace' }}</p><h1>{{ currentView === 'overview' ? `Good evening, ${store.data.profileName}.` : pageTitle }}</h1><p class="subtitle">{{ currentView === 'overview' ? 'A quiet space to make progress at your own pace.' : 'Keep your intentions visible and your next step simple.' }}</p></div>
          <div class="heading-actions"><div v-if="['journal','notes'].includes(currentView)" class="search-box"><Search :size="16" /><input v-model="search" placeholder="Search..." /></div><button v-if="currentView !== 'overview' && currentView !== 'settings'" class="primary-button" @click="openModal(currentView === 'missions' ? 'mission' : currentView === 'habits' ? 'habit' : currentView === 'agenda' ? 'agenda' : currentView === 'journal' ? 'journal' : 'note')"><Plus :size="17" /> New {{ currentView === 'missions' ? 'mission' : currentView === 'habits' ? 'habit' : currentView === 'agenda' ? 'event' : currentView === 'journal' ? 'entry' : 'note' }}</button></div>
        </section>

        <section v-if="currentView === 'overview'" class="view-content">
          <div class="quote-card"><div class="quote-icon"><Sparkles :size="20" /></div><div><strong>Small steps still move you forward.</strong><p>Focus on what feels meaningful today, not what looks impressive.</p></div><span class="quote-line"></span></div>
          <div class="stat-grid"><div class="stat-card"><span class="stat-label">Active missions</span><strong>{{ store.activeMissions.length }}</strong><span class="stat-note"><Target :size="14" /> This week</span></div><div class="stat-card"><span class="stat-label">Today's agenda</span><strong>{{ store.todayAgenda.length }}</strong><span class="stat-note"><CalendarDays :size="14" /> {{ store.completedAgenda }} completed overall</span></div><div class="stat-card"><span class="stat-label">Habit consistency</span><strong>{{ store.todayHabits.length ? Math.round(store.todayHabits.reduce((sum, h) => sum + Math.min(h.logs.length / Math.max(h.frequency, 1), 1), 0) / store.todayHabits.length * 100) : 0 }}%</strong><span class="stat-note"><Flame :size="14" /> Keep showing up</span></div></div>
          <div class="dashboard-grid">
            <div class="panel"><div class="panel-heading"><div><span class="eyebrow">Today</span><h2>Agenda</h2></div><button class="text-button" @click="navigate('agenda')">View all <ArrowUpRight :size="15" /></button></div><div v-if="store.todayAgenda.length" class="agenda-list"><div v-for="event in store.todayAgenda.slice(0, 4)" :key="event.id" class="agenda-row"><button class="check-circle" :class="{ checked: event.status === 'Completed' }" @click="store.completeAgenda(event)"><Check v-if="event.status === 'Completed'" :size="13" /></button><div class="agenda-main"><strong :class="{ done: event.status === 'Completed' }">{{ event.title }}</strong><span>{{ event.time }} · {{ event.category }}</span></div><span class="status-pill" :class="event.status.toLowerCase()">{{ event.status }}</span></div></div><div v-else class="empty-state"><CalendarDays :size="24" /><p>Your day is open.</p><button class="text-button" @click="openModal('agenda')">Add an agenda <Plus :size="14" /></button></div></div>
            <div class="panel"><div class="panel-heading"><div><span class="eyebrow">This week</span><h2>Active missions</h2></div><button class="text-button" @click="navigate('missions')">View all <ArrowUpRight :size="15" /></button></div><div v-if="store.activeMissions.length" class="mission-list"><div v-for="mission in store.activeMissions.slice(0, 3)" :key="mission.id" class="mission-row"><div class="mission-icon"><Target :size="16" /></div><div class="mission-main"><strong>{{ mission.title }}</strong><span>{{ mission.category }} · {{ mission.startDate }} — {{ mission.endDate }}</span><div class="progress-track"><span :style="{ width: `${mission.progress}%` }"></span></div></div><b>{{ mission.progress }}%</b></div></div><div v-else class="empty-state"><Target :size="24" /><p>No active missions yet.</p><button class="text-button" @click="openModal('mission')">Create your first mission <Plus :size="14" /></button></div></div>
          </div>
          <div class="section-heading"><div><span class="eyebrow">Quick capture</span><h2>Make space for what matters</h2></div></div><div class="quick-actions"><button @click="openModal('mission')"><Target :size="18" /><span><strong>Create mission</strong><small>Set a weekly intention</small></span><Plus :size="16" /></button><button @click="openModal('habit')"><Flame :size="18" /><span><strong>Log a habit</strong><small>Celebrate consistency</small></span><Plus :size="16" /></button><button @click="openModal('journal')"><BookOpen :size="18" /><span><strong>Write journal</strong><small>Reflect on your day</small></span><Plus :size="16" /></button></div>
        </section>

        <section v-else-if="currentView === 'missions'" class="view-content"><div v-if="store.data.missions.length" class="card-grid"><article v-for="mission in store.data.missions" :key="mission.id" class="item-card"><div class="card-top"><span class="category-dot"></span><span class="status-pill active">{{ mission.status }}</span></div><h3>{{ mission.title }}</h3><p>{{ mission.description || 'No description yet.' }}</p><div class="card-meta"><span>{{ mission.category }}</span><span>{{ mission.startDate }} — {{ mission.endDate }}</span></div><div class="card-progress"><div class="progress-label"><span>Progress</span><b>{{ mission.progress }}%</b></div><div class="progress-track"><span :style="{ width: `${mission.progress}%` }"></span></div></div><button class="delete-button" @click="remove('missions', mission.id)"><Trash2 :size="14" /> Delete</button></article></div><div v-else class="large-empty"><Target :size="32" /><h2>Start with an intention</h2><p>A mission gives your week a direction without demanding perfection.</p><button class="primary-button" @click="openModal('mission')"><Plus :size="16" /> Create mission</button></div></section>
        <section v-else-if="currentView === 'habits'" class="view-content"><div v-if="store.data.habits.length" class="card-grid"><article v-for="habit in store.data.habits" :key="habit.id" class="item-card habit-card"><div class="card-top"><div class="habit-badge"><Flame :size="15" /></div><span class="status-pill" :class="habit.logs.includes(store.today) ? 'completed' : 'planned'">{{ habit.logs.includes(store.today) ? 'Logged today' : 'Open today' }}</span></div><h3>{{ habit.title }}</h3><p>{{ habit.description || `${habit.frequency} times ${habit.period.toLowerCase()}` }}</p><div class="habit-progress"><div class="ring"><strong>{{ Math.min(Math.round(habit.logs.length / Math.max(habit.frequency, 1) * 100), 100) }}%</strong></div><div><span class="eyebrow">Weekly progress</span><strong>{{ habit.logs.length }} / {{ habit.frequency }} {{ habit.targetUnit }}</strong><small>{{ habit.trackingType }} tracking</small></div></div><button class="primary-button full" @click="store.toggleHabit(habit)"><CircleCheck :size="16" /> {{ habit.logs.includes(store.today) ? 'Undo today' : 'Log today' }}</button><button class="delete-button" @click="remove('habits', habit.id)"><Trash2 :size="14" /> Delete</button></article></div><div v-else class="large-empty"><Flame :size="32" /><h2>Build a gentle rhythm</h2><p>Track what you want to return to, one day at a time.</p><button class="primary-button" @click="openModal('habit')"><Plus :size="16" /> Add habit</button></div></section>
        <section v-else-if="currentView === 'agenda'" class="view-content"><div class="agenda-panel panel"><div class="agenda-date"><div class="date-number">{{ new Date().getDate() }}</div><div><span class="eyebrow">{{ dateLabel }}</span><h2>Today's plan</h2></div></div><div v-if="store.data.agenda.length" class="agenda-list"><div v-for="event in store.data.agenda" :key="event.id" class="agenda-row agenda-row-large"><button class="check-circle" :class="{ checked: event.status === 'Completed' }" @click="store.completeAgenda(event)"><Check v-if="event.status === 'Completed'" :size="13" /></button><div class="agenda-time">{{ event.time }}</div><div class="agenda-main"><strong :class="{ done: event.status === 'Completed' }">{{ event.title }}</strong><span>{{ event.description || 'No description' }} · {{ event.category }}</span></div><button class="delete-icon" @click="remove('agenda', event.id)"><Trash2 :size="15" /></button></div></div><div v-else class="empty-state"><CalendarDays :size="25" /><p>No agenda items yet. Keep the day open or add something intentional.</p></div></div></section>
        <section v-else-if="currentView === 'journal'" class="view-content"><div v-if="filteredJournal.length" class="journal-list"><article v-for="entry in filteredJournal" :key="entry.id" class="journal-card"><div class="journal-date"><strong>{{ new Date(`${entry.date}T12:00:00`).getDate() }}</strong><span>{{ new Intl.DateTimeFormat('en-US', { month: 'short' }).format(new Date(`${entry.date}T12:00:00`)) }}</span></div><div class="journal-body"><span class="eyebrow">{{ entry.category }}</span><h3>{{ entry.title }}</h3><p>{{ entry.content }}</p><small>Updated {{ new Date(entry.updatedAt).toLocaleDateString() }}</small></div><button class="delete-icon" @click="remove('journal', entry.id)"><Trash2 :size="15" /></button></article></div><div v-else class="large-empty"><BookOpen :size="32" /><h2>Write it down</h2><p>Use this space to notice the day, without needing to make it perfect.</p><button class="primary-button" @click="openModal('journal')"><Plus :size="16" /> New journal entry</button></div></section>
        <section v-else-if="currentView === 'notes'" class="view-content"><div v-if="filteredNotes.length" class="card-grid notes-grid"><article v-for="note in filteredNotes" :key="note.id" class="item-card note-card"><div class="card-top"><span class="eyebrow">{{ note.category }}</span><button class="delete-icon" @click="remove('notes', note.id)"><Trash2 :size="15" /></button></div><h3>{{ note.title }}</h3><p>{{ note.content }}</p><div class="card-meta"><span>{{ note.pinned ? 'Pinned' : 'Note' }}</span><span>{{ new Date(note.updatedAt).toLocaleDateString() }}</span></div></article></div><div v-else class="large-empty"><FileText :size="32" /><h2>Keep a thought nearby</h2><p>Notes are for ideas, references, and everything that does not need a date.</p><button class="primary-button" @click="openModal('note')"><Plus :size="16" /> Create note</button></div></section>
        <section v-else-if="currentView === 'settings'" class="view-content settings-panel panel"><div class="settings-section"><span class="eyebrow">Profile</span><h2>Your workspace</h2><p>These preferences stay on this device for now. Supabase account sync will be connected in the database phase.</p><label>Display name<input :value="store.data.profileName" @change="store.updateProfile(($event.target as HTMLInputElement).value)" /></label><label>Timezone<select><option>Asia/Jakarta (UTC+7)</option><option>UTC</option></select></label></div><div class="settings-section"><span class="eyebrow">About</span><h2>Journal Jufri</h2><p>A calm, weekly-first productivity space. Your current data is stored locally so you can explore the product before connecting Supabase.</p><div class="notice"><Zap :size="16" /> No deployment or database credentials are required for local development.</div></div></section>
      </div>
    </main>
    <div v-if="toast" class="toast"><Check :size="15" /> {{ toast }}</div>
    <div v-if="modal" class="modal-backdrop" @click.self="closeModal"><div class="modal"><div class="modal-header"><div><span class="eyebrow">Quick capture</span><h2>{{ modal === 'mission' ? 'Create mission' : modal === 'habit' ? 'Add habit' : modal === 'agenda' ? 'Add agenda' : modal === 'journal' ? 'New journal entry' : 'Create note' }}</h2></div><button class="icon-button" @click="closeModal"><X :size="18" /></button></div>
      <form v-if="modal === 'mission'" @submit.prevent="submitMission"><label>Title<input name="title" required placeholder="What matters this week?" /></label><label>Description<textarea name="description" rows="3" placeholder="A little context..."></textarea></label><div class="form-row"><label>Category<input name="category" value="Personal" /></label><label>Status<select name="status"><option>Active</option></select></label></div><div class="form-row"><label>Start date<input name="startDate" type="date" :value="store.today" required /></label><label>End date<input name="endDate" type="date" :value="store.today" required /></label></div><button class="primary-button full">Create mission</button></form>
      <form v-else-if="modal === 'habit'" @submit.prevent="submitHabit"><label>Name<input name="title" required placeholder="What do you want to return to?" /></label><label>Description<textarea name="description" rows="2"></textarea></label><div class="form-row"><label>Tracking<select name="trackingType"><option>Completion</option><option>Duration</option><option>Quantity</option></select></label><label>Target<input name="targetValue" type="number" min="1" value="4" required /></label></div><div class="form-row"><label>Unit<input name="targetUnit" value="sessions" /></label><label>Category<input name="category" value="Personal" /></label></div><button class="primary-button full">Add habit</button></form>
      <form v-else-if="modal === 'agenda'" @submit.prevent="submitAgenda"><label>Title<input name="title" required placeholder="A planned moment" /></label><label>Description<textarea name="description" rows="2"></textarea></label><div class="form-row"><label>Date<input name="date" type="date" :value="store.today" required /></label><label>Time<input name="time" type="time" /></label></div><label>Category<input name="category" value="Personal" /></label><button class="primary-button full">Add to agenda</button></form>
      <form v-else-if="modal === 'journal'" @submit.prevent="submitJournal"><label>Title<input name="title" required placeholder="A title for today" /></label><div class="form-row"><label>Date<input name="date" type="date" :value="store.today" required /></label><label>Category<input name="category" value="Reflection" /></label></div><label>Entry<textarea name="content" rows="7" required placeholder="What is present for you today?"></textarea></label><button class="primary-button full">Save entry</button></form>
      <form v-else @submit.prevent="submitNote"><label>Title<input name="title" required placeholder="A thought worth keeping" /></label><label>Category<input name="category" value="Ideas" /></label><label>Note<textarea name="content" rows="8" required placeholder="Write freely..."></textarea></label><button class="primary-button full">Save note</button></form>
    </div></div>
  </div>
</template>
