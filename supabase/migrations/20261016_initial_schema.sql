-- ==============================================================================
-- Momentum Productivity App - Supabase Initial Schema Migration
-- Migration Date: 2026-10-16
-- Tables:
--   1. users
--   2. labels
--   3. recurrence_rules
--   4. tasks
--   5. task_occurrences
--   6. completion_events
--   7. timer_sessions
--   8. kpi_definitions
--   9. attachments
--  10. notification_settings
-- ==============================================================================

-- Enable UUID extension if not already present
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 1. USERS (Profiles linked to Supabase Auth)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    settings_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 2. LABELS / CATEGORIES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.labels (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_id TEXT REFERENCES public.labels(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL DEFAULT 'label',
    color TEXT NOT NULL DEFAULT '#6366F1',
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 3. RECURRENCE RULES
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.recurrence_rules (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    days_of_week TEXT,
    interval_days INTEGER,
    interval_months INTEGER,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    max_occurrences INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 4. TASKS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.tasks (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    label_id TEXT REFERENCES public.labels(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon_name TEXT,
    image_path TEXT,
    url TEXT,
    category TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    priority TEXT NOT NULL DEFAULT 'medium',
    has_time_tracking BOOLEAN NOT NULL DEFAULT FALSE,
    estimated_minutes INTEGER,
    recurrence_rule_id TEXT REFERENCES public.recurrence_rules(id) ON DELETE SET NULL,
    scheduled_date TIMESTAMPTZ,
    due_date TIMESTAMPTZ,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 5. TASK OCCURRENCES (Recurring Instances)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.task_occurrences (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id TEXT NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    occurrence_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 6. COMPLETION EVENTS (Append-Only Log)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.completion_events (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id TEXT NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    occurrence_id TEXT REFERENCES public.task_occurrences(id) ON DELETE SET NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 7. TIMER SESSIONS (Append-Only Log)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.timer_sessions (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id TEXT NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    occurrence_id TEXT REFERENCES public.task_occurrences(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ NOT NULL,
    paused_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    elapsed_seconds INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'running',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 8. KPI DEFINITIONS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.kpi_definitions (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    label_id TEXT REFERENCES public.labels(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    kpi_type TEXT NOT NULL,
    target_value DOUBLE PRECISION NOT NULL,
    period TEXT NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 9. ATTACHMENTS
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.attachments (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id TEXT NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    remote_url TEXT,
    mime_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- 10. NOTIFICATION SETTINGS (1:1 with User)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notification_settings (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    hourly_reminders_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    active_hours_start TEXT NOT NULL DEFAULT '08:00',
    active_hours_end TEXT NOT NULL DEFAULT '22:00',
    active_days TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    quiet_start TEXT NOT NULL DEFAULT '22:00',
    quiet_end TEXT NOT NULL DEFAULT '07:00',
    daily_report_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    daily_report_time TEXT NOT NULL DEFAULT '21:00',
    motivation_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==============================================================================
-- INDEXES
-- ==============================================================================
-- Users
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Labels
CREATE INDEX IF NOT EXISTS idx_labels_user_id ON public.labels(user_id);
CREATE INDEX IF NOT EXISTS idx_labels_parent_id ON public.labels(parent_id);

-- Recurrence Rules
CREATE INDEX IF NOT EXISTS idx_recurrence_rules_user_id ON public.recurrence_rules(user_id);

-- Tasks
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_label_id ON public.tasks(label_id);
CREATE INDEX IF NOT EXISTS idx_tasks_scheduled_date ON public.tasks(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_recurrence_rule_id ON public.tasks(recurrence_rule_id);
CREATE INDEX IF NOT EXISTS idx_tasks_updated_at ON public.tasks(updated_at);

-- Task Occurrences
CREATE INDEX IF NOT EXISTS idx_task_occurrences_user_id ON public.task_occurrences(user_id);
CREATE INDEX IF NOT EXISTS idx_task_occurrences_task_id ON public.task_occurrences(task_id);
CREATE INDEX IF NOT EXISTS idx_task_occurrences_occurrence_date ON public.task_occurrences(occurrence_date);
CREATE INDEX IF NOT EXISTS idx_task_occurrences_status ON public.task_occurrences(status);
CREATE INDEX IF NOT EXISTS idx_task_occurrences_updated_at ON public.task_occurrences(updated_at);

-- Completion Events
CREATE INDEX IF NOT EXISTS idx_completion_events_user_id ON public.completion_events(user_id);
CREATE INDEX IF NOT EXISTS idx_completion_events_task_id ON public.completion_events(task_id);
CREATE INDEX IF NOT EXISTS idx_completion_events_occurrence_id ON public.completion_events(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_completion_events_completed_at ON public.completion_events(completed_at);
CREATE INDEX IF NOT EXISTS idx_completion_events_created_at ON public.completion_events(created_at);

-- Timer Sessions
CREATE INDEX IF NOT EXISTS idx_timer_sessions_user_id ON public.timer_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_timer_sessions_task_id ON public.timer_sessions(task_id);
CREATE INDEX IF NOT EXISTS idx_timer_sessions_occurrence_id ON public.timer_sessions(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_timer_sessions_started_at ON public.timer_sessions(started_at);
CREATE INDEX IF NOT EXISTS idx_timer_sessions_updated_at ON public.timer_sessions(updated_at);

-- KPI Definitions
CREATE INDEX IF NOT EXISTS idx_kpi_definitions_user_id ON public.kpi_definitions(user_id);
CREATE INDEX IF NOT EXISTS idx_kpi_definitions_label_id ON public.kpi_definitions(label_id);
CREATE INDEX IF NOT EXISTS idx_kpi_definitions_updated_at ON public.kpi_definitions(updated_at);

-- Attachments
CREATE INDEX IF NOT EXISTS idx_attachments_user_id ON public.attachments(user_id);
CREATE INDEX IF NOT EXISTS idx_attachments_task_id ON public.attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_attachments_updated_at ON public.attachments(updated_at);

-- Notification Settings
CREATE INDEX IF NOT EXISTS idx_notification_settings_user_id ON public.notification_settings(user_id);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- Enabled on EVERY table with strict user isolation
-- ==============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurrence_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_occurrences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.completion_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timer_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kpi_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

-- Users policy (matching auth.uid() with id)
DROP POLICY IF EXISTS "Users can access own data" ON public.users;
CREATE POLICY "Users can access own data"
    ON public.users
    FOR ALL
    USING (auth.uid() = id);

-- Standard tables matching auth.uid() with user_id
DROP POLICY IF EXISTS "Users can access own data" ON public.labels;
CREATE POLICY "Users can access own data"
    ON public.labels
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.recurrence_rules;
CREATE POLICY "Users can access own data"
    ON public.recurrence_rules
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.tasks;
CREATE POLICY "Users can access own data"
    ON public.tasks
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.task_occurrences;
CREATE POLICY "Users can access own data"
    ON public.task_occurrences
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.completion_events;
CREATE POLICY "Users can access own data"
    ON public.completion_events
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.timer_sessions;
CREATE POLICY "Users can access own data"
    ON public.timer_sessions
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.kpi_definitions;
CREATE POLICY "Users can access own data"
    ON public.kpi_definitions
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.attachments;
CREATE POLICY "Users can access own data"
    ON public.attachments
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can access own data" ON public.notification_settings;
CREATE POLICY "Users can access own data"
    ON public.notification_settings
    FOR ALL
    USING (auth.uid() = user_id);

-- ==============================================================================
-- AUTOMATIC updated_at TRIGGER FUNCTION
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers to all tables with updated_at column
DROP TRIGGER IF EXISTS set_updated_at_users ON public.users;
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_labels ON public.labels;
CREATE TRIGGER set_updated_at_labels
    BEFORE UPDATE ON public.labels
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_recurrence_rules ON public.recurrence_rules;
CREATE TRIGGER set_updated_at_recurrence_rules
    BEFORE UPDATE ON public.recurrence_rules
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_tasks ON public.tasks;
CREATE TRIGGER set_updated_at_tasks
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_task_occurrences ON public.task_occurrences;
CREATE TRIGGER set_updated_at_task_occurrences
    BEFORE UPDATE ON public.task_occurrences
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_timer_sessions ON public.timer_sessions;
CREATE TRIGGER set_updated_at_timer_sessions
    BEFORE UPDATE ON public.timer_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_kpi_definitions ON public.kpi_definitions;
CREATE TRIGGER set_updated_at_kpi_definitions
    BEFORE UPDATE ON public.kpi_definitions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_attachments ON public.attachments;
CREATE TRIGGER set_updated_at_attachments
    BEFORE UPDATE ON public.attachments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_notification_settings ON public.notification_settings;
CREATE TRIGGER set_updated_at_notification_settings
    BEFORE UPDATE ON public.notification_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- AUTH HOOK: Automatically create public.users profile on signup
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (
        id,
        email,
        display_name,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'display_name',
            SPLIT_PART(NEW.email, '@', 1)
        ),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_auth_user();
