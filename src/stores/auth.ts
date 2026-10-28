import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { getCurrentSession, signInWithPassword, signOut, signUpWithPassword, subscribeToAuthState } from '../services/auth.service'

export const useAuthStore = defineStore('auth', () => {
  const session = ref<any>(null)
  const loading = ref(true)
  const error = ref('')
  const email = ref('')
  const password = ref('')

  async function hydrate() {
    try {
      const currentSession = await getCurrentSession()
      session.value = currentSession
    } catch (err) {
      console.error('Auth hydrate failed', err)
      session.value = null
    } finally {
      loading.value = false
    }
  }

  subscribeToAuthState((nextSession) => {
    session.value = nextSession
    loading.value = false
  })

  async function login(nextEmail: string, nextPassword: string) {
    error.value = ''
    try {
      const data = await signInWithPassword(nextEmail.trim(), nextPassword)
      session.value = data.session
      email.value = nextEmail.trim()
      return data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Login failed'
      throw err
    }
  }

  async function register(nextEmail: string, nextPassword: string) {
    error.value = ''
    try {
      const data = await signUpWithPassword(nextEmail.trim(), nextPassword)
      session.value = data.session
      email.value = nextEmail.trim()
      return data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Registration failed'
      throw err
    }
  }

  async function logout() {
    error.value = ''
    await signOut()
    session.value = null
  }

  const isAuthenticated = computed(() => Boolean(session.value))

  hydrate()

  return {
    session,
    loading,
    error,
    email,
    password,
    isAuthenticated,
    login,
    register,
    logout,
  }
})
