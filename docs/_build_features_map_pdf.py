# توليد docs/Dareb-Features-Map.pdf عبر HTML (RTL أصلي) ثم طباعة Chrome.
from __future__ import annotations

import base64
import html
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "Dareb-Features-Map.pdf"
FONT_DIR = ROOT.parent / "assets" / "fonts"
CHROME = Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe")
EDGE = Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")

STATUS = {
    "connected": ("متصلة بالخادم", "ok"),
    "partial": ("جزئية", "warn"),
    "mock": ("تجريبي — ليست على الخادم", "info"),
    "static": ("نصوص ثابتة", "info"),
    "missing": ("غير مبنية", "miss"),
}

ROWS = [
    (
        "Auth",
        "login, resend, active, logout — delete غير مستخدم عمداً",
        "auth — /login /otp /register",
        "2-1376 دخول، 2-725 رمز، 2-1084 تسجيل",
        "الطلاب / المستخدمون",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Profile + Users",
        "profile/get، users/edit، users/update، users/update-image",
        "auth + profile — /profile وورقة التعديل",
        "2-4980 حسابي، 2-16991 تعديل",
        "الطلاب",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Profile — نقاط وأوسمة",
        "profile/points، medals، cups — users/top",
        "أرقام النقاط والأوسمة من profile/get فقط",
        "2-4980 الإحصاءات — 2-5278 إنجازاتي",
        "الطلاب / الأوسمة",
        "جزئي",
        "العداد من الملف — بلا سجل ولا ترتيب",
        "partial",
    ),
    (
        "Schools + Branches",
        "governorates/all، schools/all، branches/all",
        "auth — قوائم التسجيل وتعديل الحساب",
        "2-958 مدرسة، 2-1014 فرع",
        "المدارس / الفروع",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Home Page + Search",
        "home-page/index غير مستخدم — home-page/search مستخدم",
        "home /search — البحث في وحدة courses",
        "2-1426 الرئيسية، 2-12755 البحث",
        "لا شاشة بحث — البيانات من المواد والاختبارات",
        "نعم",
        "البحث نعم — الرئيسية تجميع محلي",
        "partial",
    ),
    (
        "News",
        "news/all، news/paginate",
        "home — شريط الأخبار",
        "2-1426 آخر الأخبار",
        "الأخبار",
        "نعم",
        "لا — NewsMockDataSource",
        "mock",
    ),
    (
        "Sliders",
        "sliders/all، sliders/paginate",
        "لا ميزة",
        "لا إطار مستقل",
        "السلايدر",
        "لا",
        "لا",
        "missing",
    ),
    (
        "Gallery",
        "galleries/all، galleries/paginate",
        "gallery — /gallery /:id /photo",
        "2-17270، 2-4817، 2-4877",
        "المعرض",
        "نعم",
        "لا — GalleryMockDataSource",
        "mock",
    ),
    (
        "Subjects",
        "subjects/all، subjects/details",
        "courses — /categories /categories/:id",
        "2-9669 كل الفئات، 2-10634 صفحة المادة",
        "المواد",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Courses + Lessions",
        "courses/paginate، courses/details، lessions/details، attend، comments",
        "courses — /courses /:id /video/:lessonId وموادي",
        "2-13072 الدورة، 2-14583 الدرس، 2-3289 موادي",
        "الدورات / الدروس / التعليقات",
        "نعم",
        "نعم — يوتيوب داخل التطبيق لا yt-dlp",
        "connected",
    ),
    (
        "Subscriptions — اشتراكي",
        "subscriptions/my",
        "courses — /my-courses تبويب المواد",
        "2-3289 موادي",
        "الاشتراكات",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Packages + كود الاشتراك",
        "packages/all، packages/details، subscriptions/add",
        "subscription — /subscription",
        "2-11243 الباقات والكود، 2-11307 مواد الباقة",
        "الباقات / الأكواد / الاشتراكات",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Payment Methods + Checkout",
        "payment-methods/all — check-out-code غير مستخدم",
        "subscription — /checkout",
        "2-11667 إتمام الشراء",
        "طرق الدفع",
        "نعم — دفع يدوي لا بوابة إلكترونية",
        "عرض الوكلاء نعم — التحويل خارج التطبيق ثم كود",
        "partial",
    ),
    (
        "Exams",
        "exams/my، exams/result، exams/attend-exam",
        "quiz — /tests /quiz/:id /result /review",
        "2-4323 اختباراتي، 2-11725 سؤال، 2-11931 نتيجة، 2-11795 مراجعة",
        "الاختبارات العامة / الأسئلة",
        "نعم",
        "نعم — قائمتي قد تبقى فارغة",
        "connected",
    ),
    (
        "Daily Activities",
        "daily-activities/my",
        "quiz — تبويب نشاطات يومية، وبطاقات المادة",
        "2-4576 نشاطاتي، 2-12456 مادة",
        "النشاطات اليومية (تحت الاختبارات)",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Notifications",
        "notifications/get",
        "notifications — /notifications",
        "2-11985",
        "الإشعارات",
        "نعم",
        "نعم",
        "connected",
    ),
    (
        "Faqs + Pages",
        "faqs/all، pages/privacy، terms، about",
        "support — /faq /privacy /usage-policy وورقة حول",
        "2-5876 أسئلة، 2-5964 استخدام، 2-6002 خصوصية، 2-16181 حول",
        "الأسئلة الشائعة / الصفحات",
        "نعم",
        "لا — نصوص ثابتة؛ رد الخادم بلا أقسام",
        "static",
    ),
    (
        "Contact Us + Infos",
        "contact-us/add، infos/all، settings/all",
        "support — ورقة تواصل معنا",
        "2-16498 تواصل معنا",
        "جهة الاتصال / الإعدادات",
        "نعم",
        "نعم — الإرسال وinfos/all",
        "connected",
    ),
    (
        "Achievements",
        "لا مجلد مستقل في الكولكشن",
        "achievements — /achievements",
        "2-5278 إنجازاتي",
        "غير واضح في القائمة",
        "نعم",
        "لا — AchievementsMockDataSource",
        "mock",
    ),
    (
        "Downloads",
        "لا مجلد في الكولكشن",
        "downloads — /downloads",
        "2-16781 الكورسات المحملة",
        "لا",
        "نعم",
        "لا — محلي تجريبي",
        "mock",
    ),
]


def font_face(name: str, filename: str, weight: int) -> str:
    data = base64.b64encode((FONT_DIR / filename).read_bytes()).decode("ascii")
    return (
        f"@font-face {{ font-family: '{name}'; "
        f"src: url('data:font/ttf;base64,{data}') format('truetype'); "
        f"font-weight: {weight}; font-style: normal; }}"
    )


def e(text: str) -> str:
    return html.escape(text, quote=True)


def card_html(row: tuple) -> str:
    name, endpoints, flutter, figma, dashboard, built, backend, status = row
    badge, tone = STATUS[status]
    fields = [
        ("Flutter", flutter),
        ("فيجما", figma),
        ("الداشبورد", dashboard),
        ("مبنية", built),
        ("الخادم", backend),
        ("مسارات الكولكشن", endpoints),
    ]
    rows = "".join(
        f'<div class="field"><span class="k">{e(k)}</span><span class="v">{e(v)}</span></div>'
        for k, v in fields
    )
    return f"""
    <article class="card">
      <header class="card-head">
        <h3>{e(name)}</h3>
        <span class="badge {tone}">{e(badge)}</span>
      </header>
      {rows}
    </article>
    """


def build_html(counts: dict[str, int]) -> str:
    cards = "".join(card_html(row) for row in ROWS)
    css = f"""
    {font_face("Noto", "NotoSansArabic-Regular.ttf", 400)}
    {font_face("Noto", "NotoSansArabic-Bold.ttf", 700)}
    :root {{
      --teal: #34BBBD;
      --navy: #1C2434;
      --muted: #5C6B7A;
      --line: #D7E2EA;
      --ok: #E8F6EE;
      --warn: #FFF6E5;
      --info: #EAF1FF;
      --miss: #FDECEC;
      --page: #F7FAFC;
    }}
    * {{ box-sizing: border-box; }}
    html, body {{
      margin: 0;
      padding: 0;
      background: #fff;
      color: var(--navy);
      font-family: Noto, "Noto Sans Arabic", Tahoma, sans-serif;
      direction: rtl;
      text-align: right;
    }}
    @page {{ size: A4; margin: 12mm 11mm 14mm 11mm; }}
    .bar {{ height: 8px; background: var(--teal); }}
    .wrap {{ padding: 18px 8px 8px; }}
    h1 {{
      margin: 8px 0 6px;
      font-size: 22px;
      font-weight: 700;
      text-align: center;
    }}
    .sub {{
      margin: 0 0 18px;
      color: var(--muted);
      font-size: 12px;
      text-align: center;
      line-height: 1.7;
    }}
    .stats {{
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 8px;
      margin-bottom: 14px;
    }}
    .stat {{
      border: 1px solid var(--line);
      border-radius: 10px;
      padding: 10px 8px;
      text-align: center;
    }}
    .stat b {{ display: block; font-size: 22px; line-height: 1.2; }}
    .stat span {{ font-size: 11px; color: var(--navy); }}
    .ok {{ background: var(--ok); }}
    .warn {{ background: var(--warn); }}
    .info {{ background: var(--info); }}
    .miss {{ background: var(--miss); }}
    .callout {{
      border: 1px solid var(--teal);
      border-radius: 10px;
      padding: 10px 12px;
      margin-bottom: 10px;
      break-inside: avoid;
    }}
    .callout h2 {{
      margin: 0 0 6px;
      font-size: 14px;
    }}
    .callout p {{
      margin: 0;
      font-size: 12px;
      line-height: 1.75;
    }}
    .legend {{
      font-size: 11.5px;
      line-height: 1.75;
      color: var(--navy);
      margin: 6px 0 16px;
    }}
    h2.sec {{
      font-size: 15px;
      margin: 16px 0 10px;
    }}
    .card {{
      border: 1.2px solid var(--teal);
      border-radius: 10px;
      overflow: hidden;
      margin-bottom: 10px;
      break-inside: avoid;
    }}
    .card-head {{
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      padding: 8px 10px;
      border-bottom: 1px solid var(--line);
      background: #F3FBFC;
    }}
    .card-head h3 {{
      margin: 0;
      font-size: 13.5px;
    }}
    .badge {{
      display: inline-block;
      border-radius: 999px;
      padding: 3px 10px;
      font-size: 11px;
      font-weight: 700;
      white-space: nowrap;
    }}
    .field {{
      display: grid;
      grid-template-columns: 92px 1fr;
      gap: 8px;
      padding: 5px 10px;
      font-size: 11.5px;
      line-height: 1.55;
      border-top: 1px solid #EEF3F6;
    }}
    .field .k {{
      color: var(--muted);
      font-weight: 700;
      background: #F0F4F6;
      margin: -5px 0 -5px -10px;
      padding: 5px 8px;
    }}
    .field .v {{ word-break: break-word; }}
    .foot {{
      margin-top: 8px;
      color: var(--muted);
      font-size: 10.5px;
      text-align: center;
    }}
    """
    return f"""<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <title>خريطة ميزات تطبيق درب</title>
  <style>{css}</style>
</head>
<body>
  <div class="bar"></div>
  <div class="wrap">
    <h1>خريطة ميزات تطبيق درب</h1>
    <p class="sub">مقابلة كولكشن Dareb API مع Flutter وفيجما ولوحة الإدارة — أكتوبر 2026</p>

    <div class="stats">
      <div class="stat ok"><b>{counts["connected"]}</b><span>متصلة بالخادم</span></div>
      <div class="stat warn"><b>{counts["partial"]}</b><span>جزئية</span></div>
      <div class="stat info"><b>{counts["mock"] + counts["static"]}</b><span>تجريبي أو ثابت</span></div>
      <div class="stat miss"><b>{counts["missing"]}</b><span>غير مبنية</span></div>
    </div>

    <section class="callout ok">
      <h2>الاشتراكات — مبنية ومتصلة</h2>
      <p>صفحة /subscription تجلب الباقات من packages/all، ومواد الباقة من packages/details، والتفعيل من subscriptions/add بالكود. صفحة موادي تقرأ subscriptions/my.</p>
    </section>
    <section class="callout warn">
      <h2>الدفع — مبني يدوياً لا كبوابة إلكترونية</h2>
      <p>صفحة /checkout تعرض وكلاء التحويل من payment-methods/all ثم تعليمات الدفع. التحويل خارج التطبيق وبعده يُدخل كود التفعيل. مسار subscriptions/check-out-code غير مربوط.</p>
    </section>

    <p class="legend">متصلة: الشاشة موجودة والمصدر على الـ API. جزئي: جزء من الكولكشن غير مربوط أو الدفع يدوي. تجريبي: MockDataSource. ثابت: نصوص محلية بدل faqs/pages. غير مبنية: لا ميزة في Flutter.</p>

    <h2 class="sec">تفاصيل كل ميزة</h2>
    {cards}
    <p class="foot">المصدر: Dareb API.postman_collection وlib/features وdocs/design/README.md ولوحة admin.</p>
  </div>
</body>
</html>
"""


def print_pdf(html_path: Path) -> None:
    browser = CHROME if CHROME.exists() else EDGE
    if not browser.exists():
        raise SystemExit("لا يوجد Chrome أو Edge لطباعة PDF")
    out_uri = str(OUT.resolve())
    html_uri = html_path.resolve().as_uri()
    cmd = [
        str(browser),
        "--headless=new",
        "--disable-gpu",
        "--no-pdf-header-footer",
        f"--print-to-pdf={out_uri}",
        html_uri,
    ]
    subprocess.run(cmd, check=True)


def main() -> None:
    counts = {k: 0 for k in STATUS}
    for row in ROWS:
        counts[row[7]] += 1
    html_text = build_html(counts)
    with tempfile.TemporaryDirectory() as tmp:
        html_path = Path(tmp) / "features-map.html"
        html_path.write_text(html_text, encoding="utf-8")
        print_pdf(html_path)
    print(OUT)


if __name__ == "__main__":
    main()
