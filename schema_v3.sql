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
