import { supabase } from './supabase'

export async function signInWithPassword(email: string, password: string) {
  const client = supabase
  if (!client) {
    throw new Error('Supabase is not configured. Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
  }

  const { data, error } = await client.auth.signInWithPassword({ email, password })
  if (error) throw error
  return data
}

export async function signUpWithPassword(email: string, password: string) {
  const client = supabase
  if (!client) {
    throw new Error('Supabase is not configured. Add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
  }

  const { data, error } = await client.auth.signUp({ email, password })
  if (error) throw error
  return data
}

export async function signOut() {
  const client = supabase
  if (!client) return

  const { error } = await client.auth.signOut()
  if (error) throw error
}

export async function getCurrentSession() {
  const client = supabase
  if (!client) return null

  const { data, error } = await client.auth.getSession()
  if (error) throw error
  return data.session
}

export function subscribeToAuthState(callback: (session: any) => void) {
  const client = supabase
  if (!client) {
    callback(null)
    return () => undefined
  }

  return client.auth.onAuthStateChange((_event, session) => {
    callback(session)
  })
}
