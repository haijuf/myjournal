import type { AppData } from '../types'

const STORAGE_KEY = 'journal-jufri-data'

const initialData: AppData = {
  profileName: 'Jufri',
  missions: [],
  habits: [],
  agenda: [],
  journal: [],
  notes: [],
}

export function loadData(): AppData {
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (!saved) return structuredClone(initialData)
    return { ...initialData, ...JSON.parse(saved) } as AppData
  } catch {
    return structuredClone(initialData)
  }
}

export function saveData(data: AppData) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
}

export function createId() {
  return crypto.randomUUID()
}
