-- ===========================================
-- Eunbin 음식 추천 앱 - Supabase Database Schema
-- ===========================================
-- Supabase Dashboard > SQL Editor 에서 실행하세요

-- 1. 사용자 프로필 (auth.users 확장)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    meal_patterns TEXT[] DEFAULT '{}',
    restrictions TEXT[] DEFAULT '{}',
    preferred_categories TEXT[] DEFAULT '{}',
    dislikes TEXT[] DEFAULT '{}',
    budget TEXT,
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 음식 카테고리
CREATE TABLE food_categories (
    id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    theme_color TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 카테고리 초기 데이터 (id = 한글)
INSERT INTO food_categories (id, display_name, emoji, theme_color, sort_order) VALUES
    ('한식',       '한식',       '🍚', 'orange',  1),
    ('중식',       '중식',       '🥟', 'red',     2),
    ('일식',       '일식',       '🍣', 'pink',    3),
    ('이탈리안',   '이탈리안',   '🍝', 'green',   4),
    ('아메리칸',   '아메리칸',   '🍔', 'blue',    5),
    ('프렌치',     '프렌치',     '🥐', 'purple',  6),
    ('동남아',     '동남아',     '🍜', 'yellow',  7),
    ('멕시칸',     '멕시칸',     '🌮', 'mint',    8),
    ('중동',       '중동',       '🧆', 'brown',   9),
    ('샐러드',     '샐러드',     '🥗', 'green',  10),
    ('면류',       '면류',       '🍜', 'brown',  11),
    ('패스트푸드', '패스트푸드', '🍟', 'red',    12),
    ('해산물',     '해산물',     '🦐', 'cyan',   13),
    ('브런치',     '브런치',     '🥞', 'orange', 14),
    ('음료',       '음료',       '🥤', 'cyan',   15),
    ('디저트',     '디저트',     '🍰', 'brown',  16),
    ('분식',       '분식',       '🍢', 'yellow', 17),
    ('기타',       '기타',       '🍽️', 'gray',   18);

-- 3. 음식 데이터
CREATE TABLE foods (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL REFERENCES food_categories(id),
    meal_types TEXT[] NOT NULL DEFAULT '{}',
    restrictions TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    base_score DOUBLE PRECISION DEFAULT 1.0,
    image_url TEXT,
    image_url_white TEXT,
    image_url_blue TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 식사 기록
CREATE TABLE meal_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    food_name TEXT NOT NULL,
    meal_type TEXT NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 피드백 (좋아요/싫어요)
CREATE TABLE feedbacks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    food_id TEXT REFERENCES foods(id) ON DELETE CASCADE NOT NULL,
    is_liked BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, food_id)
);

-- 5. 음식 선택 로그 (추천 알고리즘용 - 사용자 상태 포함)
CREATE TABLE selection_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    food_id TEXT REFERENCES foods(id) ON DELETE CASCADE NOT NULL,
    meal_type TEXT NOT NULL,
    -- 선택 당시 사용자 상태 (추후 추천 스코어링용)
    mood_score DOUBLE PRECISION,
    weather TEXT,
    temperature DOUBLE PRECISION,
    time_of_day TEXT,
    day_of_week INTEGER,
    is_selected BOOLEAN DEFAULT TRUE,  -- true: 선택함, false: 넘김(스킵)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 인덱스
-- ===========================================
CREATE INDEX idx_meal_logs_user_id ON meal_logs(user_id);
CREATE INDEX idx_meal_logs_created_at ON meal_logs(created_at DESC);
CREATE INDEX idx_feedbacks_user_id ON feedbacks(user_id);
CREATE INDEX idx_selection_logs_user_id ON selection_logs(user_id);
CREATE INDEX idx_selection_logs_food_id ON selection_logs(food_id);
CREATE INDEX idx_foods_category ON foods(category);

-- ===========================================
-- Row Level Security (RLS)
-- ===========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE selection_logs ENABLE ROW LEVEL SECURITY;

-- profiles: 자기 프로필만 접근
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE USING (auth.uid() = id);

-- food_categories: 누구나 조회 가능
CREATE POLICY "Anyone can view food categories"
    ON food_categories FOR SELECT USING (true);

-- foods: 인증된 사용자 누구나 조회 가능
CREATE POLICY "Authenticated users can view foods"
    ON foods FOR SELECT TO authenticated USING (true);

-- meal_logs: 자기 기록만 접근
CREATE POLICY "Users can view own meal logs"
    ON meal_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own meal logs"
    ON meal_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- feedbacks: 자기 피드백만 접근
CREATE POLICY "Users can view own feedbacks"
    ON feedbacks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own feedbacks"
    ON feedbacks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own feedbacks"
    ON feedbacks FOR UPDATE USING (auth.uid() = user_id);

-- selection_logs: 자기 선택 로그만 접근
CREATE POLICY "Users can view own selection logs"
    ON selection_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own selection logs"
    ON selection_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ===========================================
-- 프로필 자동 생성 트리거 (회원가입 시)
-- ===========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ===========================================
-- updated_at 자동 갱신 트리거
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_profiles
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_food_categories
    BEFORE UPDATE ON food_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_foods
    BEFORE UPDATE ON foods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_feedbacks
    BEFORE UPDATE ON feedbacks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ===========================================
-- 음식 이미지 Storage 버킷
-- ===========================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('food-images', 'food-images', true);

CREATE POLICY "Anyone can view food images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'food-images');

CREATE POLICY "Authenticated users can upload food images"
    ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'food-images');

-- ===========================================
-- 기존 foods 카테고리 마이그레이션
-- Supabase SQL Editor에서 실행하세요
-- ===========================================

-- 1) western → 세분화
UPDATE foods SET category = '이탈리안' WHERE id IN (
    'pasta', 'pizza', 'risotto', 'cream_pasta', 'carbonara',
    'aglio_olio', 'gnocchi', 'truffle_pasta'
);
UPDATE foods SET category = '아메리칸' WHERE id IN (
    'hamburger', 'steak', 'fish_and_chips', 'club_sandwich',
    'smash_burger', 'lobster_roll'
);
UPDATE foods SET category = '프렌치' WHERE id IN (
    'gratin', 'croissant', 'quiche'
);
UPDATE foods SET category = '브런치' WHERE id IN (
    'sandwich', 'omelette', 'brunch_plate', 'eggs_benedict',
    'avocado_toast', 'french_toast', 'bagel', 'acai_bowl', 'wrap'
);
UPDATE foods SET category = '샐러드' WHERE id IN (
    'salad', 'chicken_salad', 'poke_bowl_w', 'grain_bowl'
);

-- 2) other → 세분화
UPDATE foods SET category = '동남아' WHERE id IN (
    'pho', 'pad_thai', 'bun_cha', 'banh_mi', 'tom_yum',
    'green_curry', 'nasi_goreng', 'gapao_rice', 'laksa',
    'butter_chicken', 'naan_curry', 'tikka_masala', 'rice_paper_roll'
);
UPDATE foods SET category = '멕시칸' WHERE id IN (
    'burrito', 'taco', 'nachos', 'quesadilla'
);
UPDATE foods SET category = '샐러드' WHERE id IN (
    'poke_bowl', 'salmon_bowl', 'chicken_breast_salad', 'protein_bowl',
    'boiled_egg_set', 'sweet_potato', 'energy_bowl', 'shrimp_bowl',
    'tofu_bowl', 'salmon_avocado_bowl', 'spicy_salmon_bowl',
    'quinoa_salad', 'buddha_bowl', 'veggie_wrap',
    'chicken_breast_dosirak', 'grilled_chicken'
);
UPDATE foods SET category = '브런치' WHERE id IN (
    'cereal', 'yogurt_granola', 'smoothie_bowl', 'overnight_oats',
    'greek_yogurt_bowl', 'oatmeal', 'banana_pancake'
);
UPDATE foods SET category = '중동' WHERE id IN (
    'shawarma', 'falafel', 'kebab', 'hummus_plate', 'pita_sandwich'
);

-- 3) 기존 영문 카테고리 → 한글 변환
UPDATE foods SET category = '한식' WHERE category = 'korean';
UPDATE foods SET category = '중식' WHERE category = 'chinese';
UPDATE foods SET category = '일식' WHERE category = 'japanese';
UPDATE foods SET category = '분식' WHERE category = 'snack';
UPDATE foods SET category = '기타' WHERE category = 'other';

-- 4) other에서 한식/중식/일식으로 이동하는 항목
UPDATE foods SET category = '한식' WHERE id IN (
    'porridge', 'bibim_guksu', 'spicy_pork_bowl', 'bibimbap_bowl',
    'dosirak', 'triangle_gimbap', 'cup_ramyeon'
);
UPDATE foods SET category = '중식' WHERE id IN ('congee');
UPDATE foods SET category = '일식' WHERE id IN (
    'chicken_teriyaki_bowl', 'teriyaki_salmon'
);
