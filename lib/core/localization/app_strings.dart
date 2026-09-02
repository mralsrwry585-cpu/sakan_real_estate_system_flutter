/// Centralized Arabic (RTL) copy for the SAKAN tenant app.
///
/// The product is Arabic-only per the Lovable spec; keeping strings here makes
/// wording consistent and easy to adjust.
class S {
  const S._();

  // Brand
  static const appName = 'سكن';
  static const appTagline = 'منزلك يبدأ من هنا';
  static const appSubtitle = 'نظام إدارة العقارات';
  static const currency = 'ر.س';
  static const areaUnit = 'م²';

  // Generic
  static const retry = 'إعادة المحاولة';
  static const cancel = 'إلغاء';
  static const confirm = 'تأكيد';
  static const close = 'إغلاق';
  static const save = 'حفظ';
  static const send = 'إرسال';
  static const next = 'التالي';
  static const back = 'رجوع';
  static const ok = 'حسناً';
  static const all = 'الكل';
  static const optional = 'اختياري';
  static const loading = 'جاري التحميل…';
  static const somethingWentWrong = 'حدث خطأ ما';
  static const noInternet = 'تعذّر الاتصال بالخادم. تحقّق من الاتصال بالإنترنت.';
  static const tryAgain = 'حاول مرة أخرى';
  static const seeAll = 'عرض الكل';

  // Auth
  static const login = 'تسجيل الدخول';
  static const register = 'إنشاء حساب';
  static const logout = 'تسجيل الخروج';
  static const email = 'البريد الإلكتروني';
  static const password = 'كلمة المرور';
  static const fullName = 'الاسم الكامل';
  static const mobile = 'رقم الجوال';
  static const nationalId = 'رقم الهوية';
  static const welcomeBack = 'مرحباً بعودتك';
  static const loginSubtitle = 'سجّل دخولك لمتابعة رحلتك العقارية';
  static const createAccount = 'أنشئ حسابك';
  static const registerSubtitle = 'انضم إلى سكن وابدأ البحث عن منزلك';
  static const noAccountYet = 'ليس لديك حساب؟';
  static const haveAccount = 'لديك حساب بالفعل؟';
  static const loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const registerSuccess = 'تم إنشاء الحساب بنجاح';
  static const logoutConfirm = 'هل تريد تسجيل الخروج من حسابك؟';

  // Bottom navigation
  static const navHome = 'الرئيسية';
  static const navSearch = 'بحث';
  static const navFavorites = 'المفضلة';
  static const navRequests = 'طلباتي';
  static const navAccount = 'حسابي';

  // Home
  static const homeGreeting = 'أهلاً بك 👋';
  static const featured = 'عقارات مميزة';
  static const latest = 'أحدث العقارات';
  static const searchHint = 'ابحث عن مدينة أو حي أو عقار…';
  static const emptyProperties = 'لا توجد عقارات متاحة حالياً';
  static const emptyPropertiesHint = 'جرّب تعديل الفلاتر أو المحاولة لاحقاً';

  // Filters
  static const filters = 'الفلاتر';
  static const filterResults = 'عرض النتائج';
  static const resetFilters = 'إعادة تعيين';
  static const contractType = 'نوع العقد';
  static const propertyType = 'نوع العقار';
  static const priceRange = 'نطاق السعر';
  static const bedrooms = 'غرف النوم';
  static const bathrooms = 'دورات المياه';
  static const city = 'المدينة';
  static const district = 'الحي';
  static const amenities = 'المرافق والخدمات';
  static const sortBy = 'ترتيب حسب';
  static const results = 'النتائج';

  // Property details
  static const propertyDetails = 'تفاصيل العقار';
  static const description = 'الوصف';
  static const specifications = 'المواصفات';
  static const location = 'الموقع';
  static const owner = 'المالك';
  static const rooms = 'غرف';
  static const baths = 'حمامات';
  static const area = 'المساحة';
  static const floors = 'طوابق';
  static const ageYears = 'عمر البناء';
  static const yearsUnit = 'سنة';
  static const views = 'مشاهدة';
  static const requestViewing = 'طلب معاينة';
  static const requestBooking = 'طلب حجز';
  static const notAvailableForRequests = 'هذا العقار غير متاح للطلبات حالياً';
  static const showOnMap = 'عرض على الخريطة';

  // Viewing / booking requests
  static const viewingRequest = 'طلب معاينة';
  static const bookingRequest = 'طلب حجز';
  static const requestedDate = 'تاريخ المعاينة';
  static const requestedTime = 'وقت المعاينة';
  static const startDate = 'تاريخ البداية';
  static const durationMonths = 'مدة الإيجار (بالأشهر)';
  static const note = 'ملاحظة';
  static const noteHint = 'أضف ملاحظة للمالك (اختياري)';
  static const submitViewing = 'إرسال طلب المعاينة';
  static const submitBooking = 'إرسال طلب الحجز';
  static const pickDate = 'اختر التاريخ';
  static const pickTime = 'اختر الوقت';

  // Success
  static const requestSentTitle = 'تم إرسال طلبك بنجاح';
  static const viewingSentBody = 'سيتم إشعارك عند رد المالك على طلب المعاينة';
  static const bookingSentBody = 'سيتم إشعارك عند رد المالك على طلب الحجز';
  static const requestNumber = 'رقم الطلب';
  static const viewMyRequests = 'عرض طلباتي';

  // My requests
  static const myRequests = 'طلباتي';
  static const tabAll = 'الكل';
  static const tabViewings = 'المعاينات';
  static const tabBookings = 'الحجوزات';
  static const emptyRequests = 'لا توجد طلبات بعد';
  static const emptyRequestsHint = 'ابدأ بتصفّح العقارات وأرسل طلب معاينة أو حجز';
  static const browseProperties = 'تصفّح العقارات';
  static const ownerResponse = 'رد المالك';

  // Favorites
  static const favorites = 'المفضلة';
  static const emptyFavorites = 'لا توجد عقارات مفضلة';
  static const emptyFavoritesHint = 'أضف العقارات التي تعجبك لتجدها هنا بسهولة';
  static const addedToFavorites = 'تمت الإضافة إلى المفضلة';
  static const removedFromFavorites = 'تمت الإزالة من المفضلة';

  // Notifications
  static const notifications = 'الإشعارات';
  static const markAllRead = 'تحديد الكل كمقروء';
  static const emptyNotifications = 'لا توجد إشعارات';
  static const emptyNotificationsHint = 'ستظهر هنا تحديثات طلباتك';

  // Profile / settings
  static const profile = 'الملف الشخصي';
  static const settings = 'الإعدادات';
  static const account = 'الحساب';
  static const appearance = 'المظهر';
  static const themeSystem = 'حسب النظام';
  static const themeLight = 'فاتح';
  static const themeDark = 'داكن';
  static const language = 'اللغة';
  static const arabic = 'العربية';
  static const about = 'عن التطبيق';
  static const version = 'الإصدار';
  static const tenant = 'مستأجر';

  // Validation
  static const required = 'هذا الحقل مطلوب';
  static const invalidEmail = 'صيغة البريد الإلكتروني غير صحيحة';
  static const shortPassword = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const invalidMobile = 'رقم الجوال غير صحيح';
}
