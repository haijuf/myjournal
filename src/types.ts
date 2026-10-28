export type View = 'overview' | 'missions' | 'agenda' | 'habits' | 'journal' | 'notes' | 'settings'
export type MissionStatus = 'Draft' | 'Active' | 'Completed' | 'Archived'
export type AgendaStatus = 'Planned' | 'Completed' | 'Cancelled'
export type TrackingType = 'Completion' | 'Duration' | 'Quantity'

export interface Mission {
  id: string
  title: string
  description: string
  category: string
  startDate: string
  endDate: string
  status: MissionStatus
  progress: number
  activities: number
}

export interface Habit {
  id: string
  title: string
  description: string
  category: string
  trackingType: TrackingType
  targetValue: number
  targetUnit: string
  frequency: number
  period: 'Daily' | 'Weekly'
  startDate: string
  archived: boolean
  logs: string[]
}

export interface AgendaEvent {
  id: string
  title: string
  date: string
  time: string
  category: string
  status: AgendaStatus
  description: string
}

export interface JournalEntry {
  id: string
  title: string
  date: string
  content: string
  category: string
  updatedAt: string
}

export interface Note {
  id: string
  title: string
  content: string
  category: string
  pinned: boolean
  updatedAt: string
}

export interface AppData {
  profileName: string
  missions: Mission[]
  habits: Habit[]
  agenda: AgendaEvent[]
  journal: JournalEntry[]
  notes: Note[]
}
