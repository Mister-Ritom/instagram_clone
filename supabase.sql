-- =================================================
-- SUPABASE INSTAGRAM CLONE - FULL REUSABLE SCRIPT
-- CREATED FROM CHATGPT
-- =================================================

-- ==========================================
-- 1️⃣ Utility: moddatetime() trigger function
-- ==========================================
create or replace function public.moddatetime()
returns trigger as $$
begin
  execute format('NEW.%I = now()', TG_ARGV[0]);
  return NEW;
end;
$$ language plpgsql;

-- ==========================================
-- 2️⃣ Profiles Table
-- ==========================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text,
  bio text,
  avatar_url text,
  website text,
  is_private boolean default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create trigger update_profiles_updated_at
before update on public.profiles
for each row
execute procedure public.moddatetime('updated_at');

-- ==========================================
-- 3️⃣ Auto Profile Creator
-- ==========================================
create or replace function public.handle_new_user()
returns trigger as $$
declare
  base_username text;
  final_username text;
  rand_suffix int;
begin
  base_username := regexp_replace(split_part(new.email, '@', 1), '[^a-zA-Z]', '', 'g');
  if base_username = '' then base_username := 'user'; end if;

  loop
    rand_suffix := floor(random() * 9000 + 1000);
    final_username := lower(base_username || rand_suffix);
    exit when not exists (select 1 from public.profiles where username = final_username);
  end loop;

  insert into public.profiles (id, username, full_name, avatar_url)
  values (new.id, final_username, '', 'https://api.dicebear.com/9.x/initials/svg?seed=' || final_username);

  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();

-- ==========================================
-- 4️⃣ Posts Table
-- ==========================================
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 5️⃣ Likes Table
-- ==========================================
create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  created_at timestamp with time zone default now(),
  unique (post_id, user_id)
);

-- ==========================================
-- 6️⃣ Comments Table
-- ==========================================
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 7️⃣ Followers Table
-- ==========================================
create table if not exists public.followers (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at timestamp with time zone default now(),
  unique (follower_id, following_id)
);

-- ==========================================
-- 8️⃣ Stories Table
-- ==========================================
create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamp with time zone default now(),
  expires_at timestamp with time zone default (now() + interval '24 hours')
);

-- ==========================================
-- 9️⃣ RLS Policies
-- ==========================================

-- Profiles
alter table public.profiles enable row level security;
create policy "Profiles readable by everyone" on public.profiles for select using (true);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);

-- Posts
alter table public.posts enable row level security;
create policy "Posts readable by everyone" on public.posts for select using (true);
create policy "Users can create own posts" on public.posts for insert with check (auth.uid() = user_id);
create policy "Users can update own posts" on public.posts for update using (auth.uid() = user_id);
create policy "Users can delete own posts" on public.posts for delete using (auth.uid() = user_id);

-- Likes
alter table public.likes enable row level security;
create policy "Likes readable by everyone" on public.likes for select using (true);
create policy "Users can like posts" on public.likes for insert with check (auth.uid() = user_id);
create policy "Users can unlike posts" on public.likes for delete using (auth.uid() = user_id);

-- Comments
alter table public.comments enable row level security;
create policy "Comments readable by everyone" on public.comments for select using (true);
create policy "Users can create own comments" on public.comments for insert with check (auth.uid() = user_id);
create policy "Users can delete own comments" on public.comments for delete using (auth.uid() = user_id);

-- Followers
alter table public.followers enable row level security;
create policy "Followers readable by everyone" on public.followers for select using (true);
create policy "Users can follow" on public.followers for insert with check (auth.uid() = follower_id);
create policy "Users can unfollow" on public.followers for delete using (auth.uid() = follower_id);

-- Stories
alter table public.stories enable row level security;
create policy "Stories readable by everyone" on public.stories for select using (true);
create policy "Users can create own stories" on public.stories for insert with check (auth.uid() = user_id);
create policy "Users can delete own stories" on public.stories for delete using (auth.uid() = user_id);

-- ==========================================
-- 🔟 Function to delete expired stories
-- ==========================================
create or replace function public.cleanup_expired_stories()
returns void as $$
begin
  delete from public.stories
  where expires_at <= now();
end;
$$ language plpgsql security definer;

-- Schedule cleanup every hour (requires pg_cron)
create extension if not exists pg_cron;
select cron.schedule('0 * * * *', $$select public.cleanup_expired_stories();$$);
