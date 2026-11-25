-- EGID: ملف قاعدة البيانات الكامل لمشروع Supabase جديد (شغّله مرة واحدة)
-- الصق هذا الملف كاملًا في Supabase > SQL Editor ثم اضغط Run
create table experts(id uuid primary key default gen_random_uuid(),name text not null,field text,price numeric not null default 0,bio text,cv text,days int[] default '{}',times text[] default '{}',active boolean default true,created_at timestamptz default now());
create table applications(id uuid primary key default gen_random_uuid(),name text,field text,price text,phone text,email text,avail text,bio text,cv text,created_at timestamptz default now());
create table bookings(id uuid primary key default gen_random_uuid(),user_id uuid references auth.users,expert_id uuid references experts on delete set null,expert_name text,day date,tm text,price numeric,method text,client_name text,client_phone text,client_email text,status text default 'pending',created_at timestamptz default now());
create unique index one_slot on bookings(expert_id,day,tm) where status<>'cancelled';
create table settings(k text primary key,v text);

-- المدير الوحيد: بريدك (يجب أن يكون مؤكدًا)
create function is_admin() returns boolean language sql stable security definer as $$ select lower(coalesce(auth.jwt()->>'email',''))='aly.ghazal@icloud.com' $$;
-- المواعيد المحجوزة فقط، بدون بيانات أي عميل
create function taken(p uuid) returns table(day date,tm text) language sql security definer as $$ select day,tm from bookings where expert_id=p and status<>'cancelled' and day>=current_date $$;

alter table experts enable row level security;
alter table applications enable row level security;
alter table bookings enable row level security;
alter table settings enable row level security;

create policy ex_read on experts for select using (active or is_admin());
create policy ex_admin on experts for all using (is_admin()) with check (is_admin());
create policy ap_ins on applications for insert with check (true);
create policy ap_admin on applications for all using (is_admin()) with check (is_admin());
create policy bk_ins on bookings for insert to authenticated with check (user_id=auth.uid() and status='pending');
create policy bk_read on bookings for select using (user_id=auth.uid() or is_admin());
create policy bk_admin on bookings for update using (is_admin()) with check (is_admin());
create policy bk_del on bookings for delete using (is_admin());
create policy st_read on settings for select using (true);
create policy st_admin on settings for all using (is_admin()) with check (is_admin());

insert into settings(k,v) values
('platform','وسيط الخبراء'),('whatsapp','201069714555'),('phone','01069714555'),('email','Aly.Ghazal@icloud.com'),('fee','0.15'),
('pay_pi','01069714555'),('pay_pw','01069714555'),('pay_pb',''),('pay_pv','');

-- رسائل الاستفسار والتواصل
create table inquiries(id uuid primary key default gen_random_uuid(),name text,contact text,message text,created_at timestamptz default now());
alter table inquiries enable row level security;
create policy iq_ins on inquiries for insert with check (true);
create policy iq_admin on inquiries for all using (is_admin()) with check (is_admin());

-- المحتوى والصور
alter table experts add column photo text;
create table blocks(id uuid primary key default gen_random_uuid(),title text,body text,image text,pos bigint default 0,active boolean default true);
alter table blocks enable row level security;
create policy bl_read on blocks for select using (active or is_admin());
create policy bl_admin on blocks for all using (is_admin()) with check (is_admin());

-- صفحات من نحن والشروط (قابلة للتعديل من لوحة التحكم)
insert into settings(k,v) values('about','منصة وساطة تربط العملاء بخبراء موثّقين، وتتولى المنصة الحجز والدفع والتنسيق.'),('terms','1) تتم الحجوزات والمدفوعات عبر المنصة فقط.
2) لا يجوز التواصل المباشر أو التحايل على المنصة.
3) تُراجَع شهادات الخبراء قبل التعاقد.
4) تُستخدم بياناتك لتنفيذ الخدمة فقط.') on conflict (k) do nothing;

-- ===== الجزء الثاني: التخصصات وB2B وشارة الخبير =====
-- شغّله مرة واحدة في Supabase > SQL Editor بعد schema.sql (الذي شغّلته سابقًا)
create table categories(id uuid primary key default gen_random_uuid(),name_ar text not null,name_en text,pos bigint default 0,active boolean default true);
alter table experts add column category_id uuid references categories on delete set null;
alter table experts add column role text;
alter table experts add column years int default 0;
alter table experts add column shift text default 'both';
alter table experts add column certs text;
alter table experts add column verified boolean default false;
create table b2b_requests(id uuid primary key default gen_random_uuid(),company text,person text,phone text,email text,sector text,budget text,details text,status text default 'new',created_at timestamptz default now());
alter table categories enable row level security;
alter table b2b_requests enable row level security;
create policy cat_read on categories for select using (active or is_admin());
create policy cat_admin on categories for all using (is_admin()) with check (is_admin());
create policy b2b_ins on b2b_requests for insert with check (true);
create policy b2b_admin on b2b_requests for all using (is_admin()) with check (is_admin());

insert into categories(name_ar,name_en,pos) values
('الاستشارات الصناعية وخطوط الإنتاج','Industrial & Production Lines',1),
('التراخيص الصناعية والسجل التجاري','Industrial Licensing & Permits',2),
('الاستيراد والتصدير وسلاسل الإمداد','Import, Export & Supply Chain',3),
('دراسات الجدوى وتقييم المشروعات','Feasibility Studies & Valuation',4),
('التسويق الصناعي وتطوير المبيعات','Industrial Marketing & Sales',5),
('المالية والمحاسبة والتكاليف الصناعية','Finance, Accounting & Costing',6),
('الاستشارات القانونية وعقود الشركات','Corporate Legal & Contracts',7),
('البرمجة والأتمتة الصناعية','Software & Industrial Automation',8),
('الموارد البشرية وهيكلة المصانع','HR & Organizational Structuring',9),
('العقارات الصناعية والمخازن','Industrial Real Estate & Warehouses',10);

insert into settings(k,v) values
('platform','EGID | وسيط الخبراء الصناعي والتجاري'),
('tagline','وساطة استشارية بين الخبراء والمصانع والشركات'),
('color','#0f2942'),
('about','EGID منصة خاصة للوساطة الاستشارية، تربط أصحاب المصانع والشركات والأفراد بخبراء في المجالات الصناعية والتجارية. تتولى المنصة الحجز والدفع والتنسيق. المنصة ليست جهة حكومية ولا تتبع أي جهة رسمية.'),
('terms','1) المنصة وسيط خاص، وليست جهة حكومية أو معتمدة من جهة رسمية.
2) الحجز والدفع يتمان عبر قنوات المنصة فقط، وتُحوَّل مستحقات الخبير بعد تنفيذ الجلسة وخصم العمولة.
3) شارة «موثّق» تُمنح للخبير بعد مراجعة المنصة لشهاداته ومؤهلاته.
4) لا يتم التواصل المباشر بين العميل والخبير إلا بعد موافقة المنصة، ويُمنع التحايل على المنصة.
5) سياسة الإلغاء والاسترجاع: تُحدَّد وتُعلَن بعد مراجعة قانونية.
6) تُستخدم بيانات العملاء والخبراء لتنفيذ الخدمة فقط ولا تُباع لأي طرف.')
on conflict (k) do update set v=excluded.v;
-- EGID v3: شغّله مرة واحدة في Supabase > SQL Editor > New query > Run
-- (بعد schema_all.sql الذي شغّلته سابقًا)

-- أعمدة الحجوزات
alter table bookings add column if not exists ref text;
alter table bookings add column if not exists shift text;
alter table bookings add column if not exists tx_ref text;
alter table bookings add column if not exists comm numeric default 0;
alter table bookings add column if not exists net numeric default 0;
alter table bookings add column if not exists meet_link text;
create unique index if not exists bookings_ref_uq on bookings(ref);

-- أعمدة الخبراء (الإنجليزية)
alter table experts add column if not exists name_en text;
alter table experts add column if not exists role_en text;
alter table experts add column if not exists bio_en text;
alter table experts add column if not exists certs_en text;

-- أعمدة طلبات انضمام الخبراء
alter table applications add column if not exists category_id uuid references categories on delete set null;
alter table applications add column if not exists sub text;
alter table applications add column if not exists years int;
alter table applications add column if not exists shift text;
alter table applications add column if not exists payout text;
alter table applications add column if not exists status text default 'pending';

-- حساب السعر والعمولة والمرجع داخل القاعدة (يمنع العبث بالأسعار من المتصفح)
create sequence if not exists booking_seq start 1001;
create or replace function set_booking_fields() returns trigger language plpgsql security definer set search_path = public as $$
declare p numeric; f numeric; nm text;
begin
  select price, name into p, nm from experts where id = new.expert_id and active;
  if p is null then raise exception 'expert not available'; end if;
  select nullif(v,'')::numeric into f from settings where k = 'fee';
  f := coalesce(f, 0.15);
  new.price := p;
  new.comm := round(p * f);
  new.net := p - new.comm;
  new.expert_name := nm;
  new.status := 'pending';
  new.meet_link := null;
  new.ref := 'EGID-' || to_char(now(),'YYYY') || '-' || nextval('booking_seq');
  new.user_id := auth.uid();
  return new;
end $$;
drop trigger if exists trg_booking_fields on bookings;
create trigger trg_booking_fields before insert on bookings for each row execute function set_booking_fields();

insert into settings(k,v) values ('i18n_ar','{}'),('i18n_en','{}') on conflict (k) do nothing;
