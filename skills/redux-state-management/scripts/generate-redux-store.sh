#!/bin/bash
# Generate Redux Toolkit store configuration

mkdir -p src/store/slices

cat > src/store/index.ts << 'EOF'
import { configureStore } from '@reduxjs/toolkit'
import counterReducer from './slices/counterSlice'
import userReducer from './slices/userSlice'

export const store = configureStore({
  reducer: {
    counter: counterReducer,
    user: userReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['user/setUser'],
      },
    }),
  devTools: process.env.NODE_ENV !== 'production',
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch
EOF

cat > src/store/slices/counterSlice.ts << 'EOF'
import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface CounterState {
  value: number
}

const initialState: CounterState = {
  value: 0,
}

export const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1
    },
    decrement: (state) => {
      state.value -= 1
    },
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload
    },
  },
})

export const { increment, decrement, incrementByAmount } = counterSlice.actions
export default counterSlice.reducer
EOF

cat > src/store/slices/userSlice.ts << 'EOF'
import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit'

interface User {
  id: string
  name: string
  email: string
}

interface UserState {
  current: User | null
  loading: boolean
  error: string | null
}

const initialState: UserState = {
  current: null,
  loading: false,
  error: null,
}

export const fetchUser = createAsyncThunk('user/fetchUser', async (id: string) => {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
})

export const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      state.current = action.payload
    },
    logout: (state) => {
      state.current = null
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.current = action.payload
        state.loading = false
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.error = action.error.message ?? 'Failed to fetch'
        state.loading = false
      })
  },
})

export const { setUser, logout } = userSlice.actions
export default userSlice.reducer
EOF

echo "✓ Generated Redux Toolkit store"
