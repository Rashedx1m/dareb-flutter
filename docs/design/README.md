# تصاميم فيجما

نسخة من إطارات ملف فيجما «تطبيق تعليمي» (صفحة ui desgin) لمقارنة الواجهات بها دون فتح فيجما.
كل صورة إطار هاتف بعرض 430 بمقياس 100%، واسمها `<node-id>_<name>.jpg`.

- الملف: https://www.figma.com/design/LXsrIUVzQtBZPCNweESI5t/ (الإطار بمعرّفه: `https://www.figma.com/design/LXsrIUVzQtBZPCNweESI5t/x?node-id=<node-id>`)
- أسماء الطبقات في فيجما غير موثوقة: إطارات كثيرة اسمها «Cateogries page» أو «Home Page» وهي غير ذلك، فالمرجع هو المعرّف والصورة.
- الإطار يعرض حالة واحدة؛ ما لا يظهر فيه (حالات الخطأ والتحميل والفراغ) يتبع أقرب نمط في التطبيق.
- عند تعارض الصورة مع رد الخادم يُتبع الخادم ويُذكر الفرق في المراجعة.

## الدخول والتسجيل (`auth`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-523`](figma/auth/2-523_splash.jpg) | شاشة البداية (تدرّج تركوازي) | `/` |  |
| [`9-3344`](figma/auth/9-3344_splash_white.jpg) | شاشة البداية (خلفية بيضاء) | `/` | بديل |
| [`2-1376`](figma/auth/2-1376_login.jpg) | أدخل إلى حسابك | `/login` |  |
| [`2-725`](figma/auth/2-725_otp_timer.jpg) | أدخل رمز التحقق مع العدّاد | `/otp` |  |
| [`2-783`](figma/auth/2-783_otp_expired.jpg) | رمز التحقق بعد انتهاء الوقت | `/otp` |  |
| [`2-1084`](figma/auth/2-1084_register_info.jpg) | إستكمل معلوماتك: الاسم والبريد والرقم والمدرسة والشروط | `/register` |  |
| [`2-1242`](figma/auth/2-1242_register_terms_sheet.jpg) | ورقة الشروط والأحكام فوق التسجيل | `/register` |  |
| [`2-841`](figma/auth/2-841_register_gender.jpg) | إستكمل معلوماتك: ذكر/أنثى | `/register` | خطوة |
| [`2-894`](figma/auth/2-894_register_age.jpg) | إستكمل معلوماتك: العمر | `/register` | خطوة |
| [`2-958`](figma/auth/2-958_register_institution.jpg) | إستكمل معلوماتك: مدرسة/معهد | `/register` | خطوة |
| [`2-1014`](figma/auth/2-1014_register_branch.jpg) | إستكمل معلوماتك: الفرع (علمي/أدبي/تجاري) | `/register` | خطوة |
| [`2-1165`](figma/auth/2-1165_register_source.jpg) | كيفية معرفتك بالتطبيق | `/register` | خطوة |
| [`2-1071`](figma/auth/2-1071_register_success.jpg) | مبروك! تم التسجيل | `/register` |  |
| [`14-11857`](figma/auth/14-11857_complete_account_dialog.jpg) | حوار «أكمل حسابك الآن» فوق الرئيسية | `/home` |  |
| [`14-9899`](figma/auth/14-9899_complete_account_sheet.jpg) | ورقة «أكمل حسابك» | `/home` |  |

## الرئيسية (`home`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-1426`](figma/home/2-1426_home.jpg) | الرئيسية كاملة | `/home` |  |
| [`2-2224`](figma/home/2-2224_home_short.jpg) | الرئيسية (الجزء العلوي) | `/home` |  |
| [`2-11985`](figma/home/2-11985_notifications.jpg) | الإشعارات | `/notifications` |  |

## الكورسات (`courses`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-9669`](figma/courses/2-9669_all_categories.jpg) | كل الفئات | `/categories` | اسم الطبقة في فيجما «Cateogries page» |
| [`2-10634`](figma/courses/2-10634_subject_content.jpg) | صفحة المادة: تبويب المحتوى | `/categories/:id` |  |
| [`2-12145`](figma/courses/2-12145_subject_exams.jpg) | صفحة المادة: تبويب الاختبارات | `/categories/:id` |  |
| [`2-12456`](figma/courses/2-12456_subject_activities.jpg) | صفحة المادة: تبويب النشاطات اليومية | `/categories/:id` |  |
| [`2-12755`](figma/courses/2-12755_search.jpg) | نتائج البحث المجمّعة | `/search` |  |
| [`2-13072`](figma/courses/2-13072_course_detail.jpg) | صفحة الدورة ومسار التعلم | `/courses/:id` |  |
| [`2-13375`](figma/courses/2-13375_course_detail_watched_red.jpg) | صفحة الدورة: شارة المشاهدة (نسخة حمراء) | `/courses/:id` | بديل |
| [`2-13700`](figma/courses/2-13700_course_detail_watched_green.jpg) | صفحة الدورة: شارة «تمت المشاهدة» | `/courses/:id` | المعتمد |
| [`2-14025`](figma/courses/2-14025_course_story_dialog.jpg) | قصة الدورة عند أول دخول | `/courses/:id` |  |
| [`2-14206`](figma/courses/2-14206_locked_lesson_dialog.jpg) | اشترك الآن واحصل عليه | `/courses/:id` |  |
| [`2-14393`](figma/courses/2-14393_previous_lesson_dialog.jpg) | أكمل الدرس السابق | `/courses/:id` |  |
| [`2-14583`](figma/courses/2-14583_lesson_video.jpg) | صفحة الدرس مع النقاشات | `/courses/:id/video/:lessonId` |  |
| [`2-3289`](figma/courses/2-3289_my_courses_subjects.jpg) | موادي: تبويب المواد | `/my-courses` |  |
| [`2-3756`](figma/courses/2-3756_my_courses_semesters.jpg) | موادي: تبويب الفصول | `/my-courses` |  |
| [`2-4005`](figma/courses/2-4005_my_courses_packages.jpg) | موادي: تبويب الباقات | `/my-courses` |  |

## الاشتراكات (`subscription`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-11243`](figma/subscription/2-11243_subscription.jpg) | الاشتراكات: الباقات وإدخال الكود | `/subscription` | اسم الطبقة «Cateogries page» |
| [`2-11307`](figma/subscription/2-11307_subscription_subjects_dialog.jpg) | المواد المتاحة في الباقة | `/subscription` |  |
| [`2-11667`](figma/subscription/2-11667_checkout.jpg) | إتمام الشراء | `/checkout` |  |

## الاختبارات (`exams`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-4323`](figma/exams/2-4323_my_exams.jpg) | إختباراتي: تبويب الاختبارات | `/tests` |  |
| [`2-4576`](figma/exams/2-4576_my_activities.jpg) | إختباراتي: تبويب النشاطات اليومية | `/tests` | لقطة ضبابية قليلاً |
| [`2-11725`](figma/exams/2-11725_quiz_question.jpg) | سؤال الاختبار | `/quiz/:id` |  |
| [`2-11931`](figma/exams/2-11931_quiz_finished.jpg) | تم إنهاء الاختبار بنجاح | `/quiz/:id/result` |  |
| [`2-11795`](figma/exams/2-11795_quiz_review.jpg) | نتائج الاختبار: مراجعة تفصيلية | `/quiz/:id/result` |  |

## المعرض (`gallery`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-17270`](figma/gallery/2-17270_gallery.jpg) | المعرض: الألبومات | `/gallery` |  |
| [`2-4817`](figma/gallery/2-4817_gallery_album.jpg) | صور الألبوم | `/gallery/:id` |  |
| [`2-4877`](figma/gallery/2-4877_gallery_photo.jpg) | عارض الصورة | `/gallery/:id/photo/:index` |  |

## الملف الشخصي (`profile`)

| الإطار | الشاشة | المسار في التطبيق | ملاحظات |
| --- | --- | --- | --- |
| [`2-4980`](figma/profile/2-4980_profile.jpg) | الملف الشخصي | `/profile` |  |
| [`2-5278`](figma/profile/2-5278_achievements.jpg) | إنجازاتي | `/achievements` |  |
| [`2-16781`](figma/profile/2-16781_downloads.jpg) | الكورسات المحملة | `/downloads` |  |
| [`2-5876`](figma/profile/2-5876_faq.jpg) | الأسئلة الشائعة | `/faq` |  |
| [`2-5964`](figma/profile/2-5964_usage_policy.jpg) | سياسة الاستخدام | `/usage-policy` |  |
| [`2-6002`](figma/profile/2-6002_privacy_policy.jpg) | سياسة الخصوصية | `/privacy` |  |
| [`2-16991`](figma/profile/2-16991_edit_profile_sheet.jpg) | عدل معلوماتك الشخصية | `/profile` | ورقة سفلية |
| [`2-16498`](figma/profile/2-16498_contact_us_sheet.jpg) | تواصل معنا | `/profile` | ورقة سفلية |
| [`2-16181`](figma/profile/2-16181_about_sheet.jpg) | حول التطبيق | `/profile` | ورقة سفلية |
| [`2-15921`](figma/profile/2-15921_logout_dialog.jpg) | تأكيد تسجيل الخروج | `/profile` |  |

## إعادة الالتقاط

خادم Figma MCP يحتاج تفويضاً؛ وبدونه تُلتقط الإطارات من المتصفح:

1. افتح `https://www.figma.com/design/LXsrIUVzQtBZPCNweESI5t/x?node-id=<node-id>` بنافذة 800×1800 وارفض ملفات تعريف الارتباط غير الضرورية.
2. انتظر نحو 40 ثانية حتى تكتمل الصور (اللقطة المبكرة ضبابية).
3. الإطار يظهر بمقياس 100% في الوسط (x من 185 إلى 615) بحدّ أزرق؛ يُقصّ عند ذلك الحد.
