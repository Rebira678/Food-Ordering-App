-- ╔══════════════════════════════════════════════════════════════════╗
-- ║        SaffronEats — Complete Schema & Seed (v3)               ║
-- ║  Run this in Supabase SQL Editor to reset everything cleanly   ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- 0. Drop everything
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP TABLE IF EXISTS public.order_items CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.menu_items CASCADE;
DROP TABLE IF EXISTS public.menu_categories CASCADE;
DROP TABLE IF EXISTS public.restaurants CASCADE;
DROP TABLE IF EXISTS public.owner_applications CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;

-- 1. Types
CREATE TYPE user_role AS ENUM ('customer', 'owner', 'superadmin');
CREATE TYPE order_status AS ENUM ('pending', 'preparing', 'delivering', 'delivered', 'cancelled');

-- 2. Tables
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL DEFAULT 'User',
    role user_role DEFAULT 'customer'::user_role NOT NULL,
    phone TEXT,
    address TEXT,
    avatar_url TEXT,
    push_enabled BOOLEAN DEFAULT true,
    email_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE public.restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id),
    owner_email TEXT,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    image_url TEXT,
    rating DECIMAL(2,1) DEFAULT 4.5,
    time TEXT DEFAULT '30-40 min',
    delivery_fee DECIMAL(10,2) DEFAULT 25.0,
    tags TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE public.menu_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE public.menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.menu_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true
);

CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    restaurant_id UUID REFERENCES public.restaurants(id),
    status order_status DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_address TEXT NOT NULL,
    payment_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES public.menu_items(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE public.owner_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_name TEXT NOT NULL,
    location TEXT,
    cuisine_type TEXT,
    phone TEXT,
    email TEXT,
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- 3. RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.owner_applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "open_all" ON public.profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.restaurants FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.menu_categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.menu_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.order_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open_all" ON public.owner_applications FOR ALL USING (true) WITH CHECK (true);

-- 4. Trigger — BULLETPROOF (never causes signup to fail)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_role user_role;
BEGIN
  -- Determine role from email
  IF LOWER(new.email) = 'admin@saffroneats.com' THEN
    v_role := 'superadmin';
  ELSIF LOWER(new.email) LIKE '%@saffroneats.com' THEN
    v_role := 'owner';
  ELSE
    v_role := 'customer';
  END IF;

  -- Insert profile (catch any error so signup never fails)
  BEGIN
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (
      new.id,
      COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
      v_role
    )
    ON CONFLICT (id) DO UPDATE SET role = v_role;
  EXCEPTION WHEN OTHERS THEN
    NULL; -- silently ignore
  END;

  -- Auto-link owner to their restaurant
  IF v_role = 'owner' THEN
    BEGIN
      UPDATE public.restaurants
      SET owner_id = new.id
      WHERE LOWER(owner_email) = LOWER(new.email);
    EXCEPTION WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Seed Restaurants (with owner_email for auto-linking)
INSERT INTO public.restaurants (id, owner_email, name, description, address, image_url, rating, time, delivery_fee, tags) VALUES
('10000000-0000-0000-0000-000000000001', 'kenbon@saffroneats.com',     'Kenbon Restaurant',   'KenBon Restaurant brings you the authentic taste of both traditional and modern recipes in the heart of Adama.', 'Downtown Adama',        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5', 4.8, '25-35 min', 25.0, '{"Burgers","Pizza","Fast Food"}'),
('10000000-0000-0000-0000-000000000002', 'yegnawbet@saffroneats.com',  'YegnawBet Restaurant','YegnawBet is your home away from home, serving bold and flavorful traditional dishes.', 'Bole Adama Zone',       'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', 4.9, '30-45 min', 30.0, '{"Traditional","Local","Meals"}'),
('10000000-0000-0000-0000-000000000003', 'gola@saffroneats.com',       'Gola Adama Restaurant','Gola Adama offers fast food catered to the fast-paced life — hot, fresh, and irresistible!', 'Adama University Road', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47', 4.7, '15-25 min', 15.0, '{"Fast Food","Snacks"}'),
('10000000-0000-0000-0000-000000000004', 'marafa@saffroneats.com',     'Marafa Restaurant',   'Famous for premium grill items, Marafa elevates the dining experience.', 'Posta Bet Area',        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c', 4.6, '35-50 min', 20.0, '{"Grill","Meat"}');

-- 6. Menu Categories
INSERT INTO public.menu_categories (id, restaurant_id, name) VALUES
-- Kenbon
('c1000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Burgers'),
('c1000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Pizza'),
('c1000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'Drinks'),
-- YegnawBet
('c2000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'Traditional'),
('c2000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', 'Beverages'),
-- Gola
('c3000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', 'Quick Snacks'),
('c3000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003', 'Sandwiches'),
-- Marafa
('c4000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000004', 'Grilled Meat'),
('c4000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000004', 'Specials');

-- 7. Menu Items
INSERT INTO public.menu_items (category_id, name, description, price, image_url) VALUES
-- Kenbon Burgers
('c1000000-0000-0000-0000-000000000001', 'Single Classic Burger',   'Juicy beef patty with lettuce and tomato',        185.0, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'),
('c1000000-0000-0000-0000-000000000001', 'Double Cheese Burger',    'Two patties with extra melted cheese',            350.0, 'https://images.unsplash.com/photo-1525164286253-04e68b9d94bb'),
('c1000000-0000-0000-0000-000000000001', 'Special Saffron Burger',  'The ultimate signature burger with special sauce', 490.0, 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5'),
('c1000000-0000-0000-0000-000000000001', 'Chicken Crispy Burger',   'Crispy fried chicken fillet burger',              280.0, 'https://images.unsplash.com/photo-1603064752734-4c48eff4d405'),
-- Kenbon Pizza
('c1000000-0000-0000-0000-000000000002', 'Margherita Pizza',        'Classic tomato and mozzarella',                   280.0, 'https://images.unsplash.com/photo-1513104890138-7c749659a591'),
('c1000000-0000-0000-0000-000000000002', 'Chicken BBQ Pizza',       'Grilled chicken with BBQ sauce',                  450.0, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38'),
('c1000000-0000-0000-0000-000000000002', 'Veggie Supreme Pizza',    'Fresh garden vegetables',                         360.0, 'https://images.unsplash.com/photo-1513104890138-7c749659a591'),
-- Kenbon Drinks
('c1000000-0000-0000-0000-000000000003', 'Fresh Mango Juice',       '100% natural cold pressed',                        85.0, 'https://images.unsplash.com/photo-1546039907-7fa05f864c02'),
('c1000000-0000-0000-0000-000000000003', 'Avocado Shake',           'Smooth and creamy avocado shake',                115.0, 'https://images.unsplash.com/photo-1544145945-f904253d0c71'),
('c1000000-0000-0000-0000-000000000003', 'Iced Coffee',             'Premium roasted Ethiopian beans',                  95.0, 'https://images.unsplash.com/photo-1517701604599-bb29b565090c'),
('c1000000-0000-0000-0000-000000000003', 'Sprite 500ml',            'Chilled soft drink',                               45.0, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97'),

-- YegnawBet Traditional
('c2000000-0000-0000-0000-000000000001', 'Special Kitfo',           'Minced raw beef marinated in mitmita and butter', 350.0, 'https://images.unsplash.com/photo-1541518763531-4430e54fd483'),
('c2000000-0000-0000-0000-000000000001', 'Doro Wot',                'Traditional spicy chicken stew with boiled egg',  450.0, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'),
('c2000000-0000-0000-0000-000000000001', 'Beyaynetu',               'Colorful platter of various fasting stews',       180.0, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'),
('c2000000-0000-0000-0000-000000000001', 'Beef Tibs',               'Sautéed beef with onions, peppers and rosemary',  280.0, 'https://images.unsplash.com/photo-1544124499-58912cbddaad'),
('c2000000-0000-0000-0000-000000000001', 'Gomen Besiga',            'Collard greens cooked with tender beef',          240.0, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'),
('c2000000-0000-0000-0000-000000000001', 'Shiro',                   'Spiced chickpea stew, the Ethiopian classic',     150.0, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'),
-- YegnawBet Beverages
('c2000000-0000-0000-0000-000000000002', 'Traditional Coffee Ceremony','3-round Ethiopian coffee ceremony',              60.0, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085'),
('c2000000-0000-0000-0000-000000000002', 'Fresh Avocado Juice',     'Thick creamy avocado smoothie',                  100.0, 'https://images.unsplash.com/photo-1544145945-f904253d0c71'),
('c2000000-0000-0000-0000-000000000002', 'Tej (Honey Wine)',        'Traditional Ethiopian honey-based drink',         120.0, 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3'),

-- Gola Quick Snacks
('c3000000-0000-0000-0000-000000000001', 'French Fries (Large)',    'Crispy golden fries with seasoning',               95.0, 'https://images.unsplash.com/photo-1573016608464-98426038477d'),
('c3000000-0000-0000-0000-000000000001', 'Samosa (3 pcs)',          'Crispy pastry with spiced meat or lentil filling', 60.0, 'https://images.unsplash.com/photo-1601050690597-df056fb04791'),
('c3000000-0000-0000-0000-000000000001', 'Chicken Nuggets (8 pcs)','Bite-sized breaded and fried chicken',            180.0, 'https://images.unsplash.com/photo-1562967914-608f82629710'),
('c3000000-0000-0000-0000-000000000001', 'Onion Rings',             'Beer-battered crispy onion rings',                 80.0, 'https://images.unsplash.com/photo-1639024471283-03518883512d'),
('c3000000-0000-0000-0000-000000000001', 'Spring Rolls (4 pcs)',    'Crispy vegetable spring rolls with dipping sauce', 90.0, 'https://images.unsplash.com/photo-1556817411-31ae72fa3ea0'),
-- Gola Sandwiches
('c3000000-0000-0000-0000-000000000002', 'Club Sandwich',           'Triple-decker with chicken, egg and veggies',     220.0, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af'),
('c3000000-0000-0000-0000-000000000002', 'Tuna Sandwich',           'Fresh tuna with mayo and crisp lettuce',          190.0, 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586'),
('c3000000-0000-0000-0000-000000000002', 'Cheese Toast',            'Melted double cheese on toasted sourdough',       140.0, 'https://images.unsplash.com/photo-1525351326368-efbb5cb6814d'),
('c3000000-0000-0000-0000-000000000002', 'Breakfast Roll',          'Egg, sausage, and cheese in a soft roll',         160.0, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af'),

-- Marafa Grilled Meat
('c4000000-0000-0000-0000-000000000001', 'Mixed Grill Platter',     'A variety of grilled meats for two',              550.0, 'https://images.unsplash.com/photo-1544025162-d76694265947'),
('c4000000-0000-0000-0000-000000000001', 'BBQ Ribs (Half Rack)',    'Tender slow-cooked ribs with smoky BBQ sauce',    480.0, 'https://images.unsplash.com/photo-1544025162-d76694265947'),
('c4000000-0000-0000-0000-000000000001', 'Grilled Chicken (Half)', 'Flame-grilled half chicken with chimichurri',     320.0, 'https://images.unsplash.com/photo-1532550907401-a500c9a57435'),
('c4000000-0000-0000-0000-000000000001', 'Grilled Fish',            'Whole grilled tilapia with lemon butter',         380.0, 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2'),
('c4000000-0000-0000-0000-000000000001', 'Lamb Chops (3 pcs)',      'Juicy marinated lamb chops, perfectly charred',   440.0, 'https://images.unsplash.com/photo-1603048297172-c92544798d5a'),
-- Marafa Specials
('c4000000-0000-0000-0000-000000000002', 'Marafa Special Steak',    'Premium cut steak with Marafa secret spice rub',  520.0, 'https://images.unsplash.com/photo-1546241072-48010ad28c2c'),
('c4000000-0000-0000-0000-000000000002', 'Surf & Turf',             'Grilled steak and prawn combo',                   650.0, 'https://images.unsplash.com/photo-1546241072-48010ad28c2c'),
('c4000000-0000-0000-0000-000000000002', 'Barbeque Platter Solo',   'Single-serve BBQ with fries and salad',           380.0, 'https://images.unsplash.com/photo-1544025162-d76694265947');

-- 8. Storage Buckets (For Receipts & Avatars)
INSERT INTO storage.buckets (id, name, public) VALUES ('orders', 'orders', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', true) ON CONFLICT DO NOTHING;

CREATE POLICY "Public Access" ON storage.objects FOR ALL USING (bucket_id IN ('orders', 'profiles')) WITH CHECK (bucket_id IN ('orders', 'profiles'));

-- 9. Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.owner_applications;
