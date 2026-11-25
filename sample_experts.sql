-- اختياري: خبراء تجريبيون لرؤية شكل الموقع. نماذج وهمية، احذفها من لوحة الإدارة قبل الإطلاق الفعلي.
insert into experts(name,name_en,role,role_en,field,category_id,years,price,shift,bio,bio_en,certs,certs_en,active,verified) values
('م. طارق المنياوي (نموذج تجريبي)','Eng. Tarek (Demo)','استشاري تخطيط المصانع وخطوط الإنتاج','Factory Layout Consultant',
 'استشاري تخطيط المصانع',(select id from categories where name_ar like 'الاستشارات الصناعية%' limit 1),18,600,'both',
 'نموذج تجريبي لعرض شكل الملف المهني.','Demo profile to preview the layout.','مثال: ماجستير الهندسة الصناعية','Example: M.Sc. Industrial Engineering',true,false),
('د. هالة عبد الرحمن (نموذج تجريبي)','Dr. Hala (Demo)','خبيرة التراخيص الصناعية','Industrial Licensing Expert',
 'التراخيص الصناعية',(select id from categories where name_ar like 'التراخيص الصناعية%' limit 1),15,500,'morning',
 'نموذج تجريبي لعرض شكل الملف المهني.','Demo profile to preview the layout.','مثال: دكتوراه القانون الإداري','Example: PhD Administrative Law',true,false),
('أ. محمود الشاذلي (نموذج تجريبي)','Mr. Mahmoud (Demo)','مستشار الاستيراد والتصدير','Import & Export Advisor',
 'الاستيراد والتصدير',(select id from categories where name_ar like 'الاستيراد%' limit 1),14,450,'evening',
 'نموذج تجريبي لعرض شكل الملف المهني.','Demo profile to preview the layout.','مثال: دبلوم التجارة الدولية','Example: Intl Trade Diploma',true,false);
