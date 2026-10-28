import { computed, reactive } from 'vue'
import { defineStore } from 'pinia'
import { createId, loadData, saveData } from '../services/localStore'
import type { AgendaEvent, AppData, Habit, JournalEntry, Mission, Note } from '../types'

export const useAppStore = defineStore('app', () => {
  const data = reactive<AppData>(loadData())
  const today = new Date().toISOString().slice(0, 10)

  function persist() {
    saveData(JSON.parse(JSON.stringify(data)))
  }

  function addMission(input: Omit<Mission, 'id' | 'progress' | 'activities'>) {
    data.missions.unshift({ ...input, id: createId(), progress: 0, activities: 0 })
    persist()
  }
  function addHabit(input: Omit<Habit, 'id' | 'logs'>) {
    data.habits.unshift({ ...input, id: createId(), logs: [] })
    persist()
  }
  function addAgenda(input: Omit<AgendaEvent, 'id'>) {
    data.agenda.unshift({ ...input, id: createId() })
    persist()
  }
  function addJournal(input: Omit<JournalEntry, 'id' | 'updatedAt'>) {
    data.journal.unshift({ ...input, id: createId(), updatedAt: new Date().toISOString() })
    persist()
  }
  function addNote(input: Omit<Note, 'id' | 'updatedAt'>) {
    data.notes.unshift({ ...input, id: createId(), updatedAt: new Date().toISOString() })
    persist()
  }
  function toggleHabit(habit: Habit) {
    const index = habit.logs.indexOf(today)
    if (index >= 0) habit.logs.splice(index, 1)
    else habit.logs.push(today)
    persist()
  }
  function completeAgenda(event: AgendaEvent) {
    event.status = event.status === 'Completed' ? 'Planned' : 'Completed'
    persist()
  }
  function deleteItem(collection: keyof Pick<AppData, 'missions' | 'habits' | 'agenda' | 'journal' | 'notes'>, id: string) {
    const items = data[collection] as Array<{ id: string }>
    const index = items.findIndex((item) => item.id === id)
    if (index >= 0) items.splice(index, 1)
    persist()
  }
  function updateProfile(name: string) {
    data.profileName = name.trim() || 'Jufri'
    persist()
  }

  const activeMissions = computed(() => data.missions.filter((mission) => mission.status === 'Active'))
  const todayAgenda = computed(() => data.agenda.filter((event) => event.date === today))
  const todayHabits = computed(() => data.habits.filter((habit) => !habit.archived))
  const completedAgenda = computed(() => data.agenda.filter((event) => event.status === 'Completed').length)

  return { data, today, activeMissions, todayAgenda, todayHabits, completedAgenda, addMission, addHabit, addAgenda, addJournal, addNote, toggleHabit, completeAgenda, deleteItem, updateProfile }
})
