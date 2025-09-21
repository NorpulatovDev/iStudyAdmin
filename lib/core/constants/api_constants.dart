class ApiConstants {
  static const String baseUrl = 'https://iStudy-production.up.railway.app/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  

  // Branch endpoints
  static const String branchesEndpoint = '/branches';

  // Dashboard endpoints
  static const String dashboardStatsEndpoint = '/dashboard/stats';

  // User endpoints
  static const String usersEndpoint = '/users';

  // Student endpoints
  static const String studentsEndpoint = '/students';

  // Course endpoints
  static const String coursesEndpoint = '/courses';

  // Group endpoints
  static const String groupsEndpoint = '/groups';

  // Teacher endpoints
  static const String teachersEndpoint = '/teachers';

  // Teacher Salary endpoints
  static const String teacherSalariesEndpoint = '/teacher-salaries';
  static const String salaryCalculateEndpoint = '/teacher-salaries/calculate';
  static const String salaryPaymentsEndpoint = '/teacher-salaries/payments';
  static const String salaryHistoryEndpoint = '/teacher-salaries/history';
  static const String salaryRemainingEndpoint = '/teacher-salaries/remaining';

  // Payment endpoints
  static const String paymentsEndpoint = '/payments';

  // Expense endpoints
  
  static const String expensesEndpoint = '/expenses';

  // Report endpoints
  static const String reportsEndpoint = '/reports';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}