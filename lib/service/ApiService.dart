import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_cxo/model/ActivityLogResponse.dart';
import 'package:flutter_application_cxo/model/ActivityResponse.dart';
import 'package:flutter_application_cxo/model/ActivityScreenResponse.dart';
import 'package:flutter_application_cxo/model/ClientDebarredResponse.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/ClientonchartResponse.dart';
import 'package:flutter_application_cxo/model/FiveAResponse.dart';
import 'package:flutter_application_cxo/model/LicenseResponse.dart';
import 'package:flutter_application_cxo/model/LoginResponse.dart';
import 'package:flutter_application_cxo/model/MachineResponse.dart';
import 'package:flutter_application_cxo/model/MetricsResponse.dart';
import 'package:flutter_application_cxo/model/PerformanceResponse.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/model/ProjectdetailResponse.dart';
import 'package:flutter_application_cxo/model/RoiResponse.dart';
import 'package:flutter_application_cxo/model/SubschartResponse.dart';
import 'package:flutter_application_cxo/model/SubscriptionResponse.dart';
import 'package:flutter_application_cxo/model/TranschartResponse.dart';
import 'package:flutter_application_cxo/model/UpcomingRenewResponse.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';
import 'package:flutter_application_cxo/model/UsermetricsResponse.dart';
import 'package:flutter_application_cxo/service/ApiClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final ApiClient _client = ApiClient();
  final Dio _dio = Dio();
  Map<String, dynamic>? lastError;
  
  /// Login API
// Future<Loginresponse?> login(String userUsername, String userPassword) async {
//   try {
//     final response = await _client.dio.post(
//       'api/login/',
//       data: {
//         'user_email': userUsername,
//         'password': userPassword,
//       },
//       options: Options(
//         headers: {
//           "Content-Type": "application/json",
//         },
//         validateStatus: (status) => status != null && status < 500,
//       ),
//     );

//     if (response.statusCode == 200 && response.data != null) {
//       final loginResponse = Loginresponse.fromJson(response.data);
//       return loginResponse;
//     } else {
//       print("Login failed: ${response.statusCode} ${response.data}");
//       return null;
//     }
    
//   } catch (e) {
//     print("Login API error: $e");
//     return null;
//   }
// }


Future<Loginresponse?> login(String userUsername, String userPassword) async {
  try {
    final response = await _client.dio.post( 
      'api/login/',
      data: {
        'user_email': userUsername, 
        'password': userPassword,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final loginResponse = Loginresponse.fromJson(response.data);
      
      // --- CHANGE 2: Save the authentication token ---
      // IMPORTANT: Replace 'access' with the actual key your server uses (e.g., 'token', 'key')
      final String token = response.data['access']; 
      await _client.saveToken(token); 
      
      return loginResponse;
    } else {
      print("Login failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("Login API error: $e");
    return null;
  }
}

  //projects 
Future<List<ProjectResponse>?> getprojects() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/projects/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500, 
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final dynamic responseData = response.data;

      if (responseData is List) {
        return responseData
            .map((e) => ProjectResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print("Project API warning: Status 200 but response data is not a list. Type: ${responseData.runtimeType}");
        return null;
      }
      
    } else {
      print("Project failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } on DioException catch (e) {
    print("Project API DioError: ${e.message}");
    return null;
  } catch (e) {
    print("Project API unknown error: $e");
    return null;
  }
}

//users get
Future<List<UserResponse>?> getusers() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/users/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((e) => UserResponse.fromJson(e))
          .toList();
    } else {
      print("user response failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("users API error: $e");
    return null;
  }
}


//client get
Future<List<ClientResponse>?> getclient() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/clients/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((e) => ClientResponse.fromJson(e))
          .toList();
    } else {
      print("ClientResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}


Future<List<ClientDebarredResponse>?> getdebarredclient() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/get_debarred_client/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((e) => ClientDebarredResponse.fromJson(e))
          .toList();
    } else {
      print("ClientResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}


//machines get
Future<List<MachineResult>?> getmachines(
    int page,
    int pagesize,
    String? hosted,
    String? environment,
    String? search,
  ) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/machines-list/',
      queryParameters: {
        "page": page,
        "page_size": pagesize,
        "search": search ?? "",
        "hosted": hosted ?? "",
        "environment": environment ?? "",
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      // ✅ response.data is a Map, get the 'results' list
      final results = response.data['results'] as List<dynamic>;
      return results.map((e) => MachineResult.fromJson(e)).toList();
    } else {
      print("MachineResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("machine API error: $e");
    return null;
  }
}

//licenses get 

Future<List<LicenseResponse>?> getlicenses() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/licenses/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    ); 
  if (response.statusCode == 200) {
        final dynamic responseData = response.data;

      if (responseData is List) {
          return responseData.map((json) => LicenseResponse.fromJson(json)).toList();
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('results')) {
          final List<dynamic> jsonList = responseData['results'] as List<dynamic>;
          return jsonList.map((json) => LicenseResponse.fromJson(json)).toList();
        } else {
          debugPrint("Unexpected API response structure: $responseData");
          return null;
        }
      } else {
        return null;
      }
    } on DioException catch (e) { // Use DioException for Dio-specific errors
      if (e.response != null) {
      } else {
      }
      return null;
    } catch (e) {
      return null;
    }

}


//subscription get
Future<List<SubscriptionResponse>?> getsubscription() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/subscriptions-grouped/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint("API Response Status Code: ${response.statusCode}");
    debugPrint("Type of response.data: ${response.data.runtimeType}"); 

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data as List<dynamic>;
      return jsonList.map((json) => SubscriptionResponse.fromJson(json)).toList();
    } else {
      debugPrint("Failed to fetch SubscriptionResponse with status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("SubscriptionResponse API error: $e");
    return null;
  }
}

//performance get
Future<List<PerformanceResponse>> getperformance(
    int page,
    int pageSize,
    String searchQuery,
    String monthyear,
    String startDate,
    String endDate) async {
 final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final response = await _client.dio.get(
    "api/fivea/summary/",
    queryParameters: {
      "page": page,
      "page_size": pageSize,
      "search": searchQuery,
      "month_year": monthyear,
      "start_date": startDate,
      "end_date": endDate,
    },
    options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
  );

  if (response.statusCode == 200) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final results = data['results'] as List<dynamic>;
      return results
          .map((json) => PerformanceResponse.fromJson(json))
          .toList();
    } else {
      throw Exception("Unexpected API response format");
    }
  } else {
    throw Exception("API call failed with status code: ${response.statusCode}");
  }
}


//fiveA get 
Future<Map<String, dynamic>> getfiveAreq(
    int page,
    int pageSize,
    String searchQuery,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final response = await _client.dio.get(
    "api/fivea/",
    queryParameters: {
      "page": page,
      "page_size": pageSize,
      "search": searchQuery,
      "status": "Pending",
    },
    options: Options(
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  if (response.statusCode == 200) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      // Return the entire JSON map, which contains "count", "next", "previous", and "results"
      return data; 
    } else {
      throw Exception("Unexpected API response format: Expected Map");
    }
  } else {
    throw Exception("API call failed with status code: ${response.statusCode}");
  }
}


// CORRECTED: Returns Future<Map<String, dynamic>> (the raw JSON response)
Future<Map<String, dynamic>> getfiveAhis(int page, int pageSize, String searchQuery) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  final response = await _client.dio.get(
    "api/fivea/",
    queryParameters: {
      "page": page,
      "page_size": pageSize,
      "search": searchQuery,
      "status": "Approved",
    },
    options: Options(
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  if (response.statusCode == 200) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      // Return the entire JSON map, which contains "count", "next", "previous", and "results"
      return data;
    } else {
      throw Exception("Unexpected API response format: Expected Map");
    }
  } else {
    throw Exception("API call failed with status code: ${response.statusCode}");
  }
}


//get activities
Future<ActivityScreenResponse> getActivities() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await _client.dio.get(
      "/api/activities/",
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ActivityScreenResponse.fromJson(data);
      } else {
        throw Exception("Unexpected data format");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  } on DioException catch (e) {
    throw Exception("Network Error: ${e.message}");
  } catch (e) {
    throw Exception("General Error: $e");
  }
}

//activity log get
Future<ActivityLogResponse> getActivitylog(int? page,int? pagesize) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await _client.dio.get(
      "api/project_activities",
      queryParameters: {
        "page":page,
        "page_size":pagesize
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ActivityLogResponse.fromJson(data);
      } else {
        throw Exception("Unexpected data format");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  } on DioException catch (e) {
    throw Exception("Network Error: ${e.message}");
  } catch (e) {
    throw Exception("General Error: $e");
  }
}

//metrics get
Future<MetricsResponse?> getmetrics() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/metrics/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return MetricsResponse.fromJson(response.data);
    } else {
      print("MetricsResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}

//user metrics 
Future<UsermetricsResponse?> getusermetrics() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/get_user_analytics/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return UsermetricsResponse.fromJson(response.data);
    } else {
      print("UsermetricsResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}

Future<TranschartResponse?> gettranschart(String? fromdate, String? todate) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/transaction_chart/',
      queryParameters: {
       "startDate" :fromdate,
       "endDate":todate
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return TranschartResponse.fromJson(response.data);
    } else {
      print("TranschartResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}


//subscription vs resource chart 
Future<SubschartResponse?> getsubschart(String? fromdate, String? todate) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/resource_management_chart/',
      queryParameters: {
       "startDate" :fromdate,
       "endDate":todate
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return SubschartResponse.fromJson(response.data);
    } else {
      print("SubschartResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}


//client onboard trends 
Future<ClientonchartResponse?> getclientonchart(String? year) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/client_onboard_analytics/',
      queryParameters: {
       "year" :year,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return ClientonchartResponse.fromJson(response.data);
    } else {
      print("ClientonchartResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}


//upcoming renewals
Future<List<UpcomingRenewResponse>?> getupcomingrenewals() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/renewal_subscription_list/',
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      // Ensure data is a list
      if (response.data is List) {
        return (response.data as List)
            .map((e) => UpcomingRenewResponse.fromJson(e))
            .toList();
      } else {
        print("⚠️ API did not return a list: ${response.data}");
        return [];
      }
    } else {
      print("UpcomingRenewResponse failed: ${response.statusCode} ${response.data}");
      return [];
    }
  } catch (e) {
    print("❌ Client API error: $e");
    return [];
  }
}
//get project details

Future<Projectdetailresponse?> getprojectdetail(int? projectid) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      'api/get_project_details/',
      queryParameters: {
       "project_id" :projectid,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return Projectdetailresponse.fromJson(response.data);
    } else {
      print("Projectdetailresponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}

//roi data 
Future<RoiResponse?> getroidata(int? projectid) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final response = await _client.dio.get(
      '/api/fetch_effort_data_rest/',
      queryParameters: {
       "project_id" :projectid,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return RoiResponse.fromJson(response.data);
    } else {
      print("RoiResponse failed: ${response.statusCode} ${response.data}");
      return null;
    }
  } catch (e) {
    print("client API error: $e");
    return null;
  }
}

//post and delete options 


Future<UserResponse?> postusers(
  String name,
  String email,
  String password,
  String? path,
  String? selectedLocation,
  bool isChecked,
  bool isStatusActive,
  String? selectedDesignation,
  int? selectedrole,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final formData = FormData.fromMap({
      'user_name': name,
      'user_email': email,
      'password': password,
      'work_location': selectedLocation,
      'production_support': isChecked,
      'is_active': isStatusActive,
      'designation': selectedDesignation ?? 1, // ✅ use your dropdown value
      'role_id': selectedrole ?? 1,            // ✅ use your dropdown value
      if (path != null) 
        'profile_picture': await MultipartFile.fromFile(path),
    });

    final response = await _client.dio.post(
      'api/users/',
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // ✅ Parse into UserResponse model safely
      if (data is Map<String, dynamic>) {
        return UserResponse.fromJson(data);
      } else {
        return null;
      }
    } else {
      lastError = response.data;
      return null;
    }
  } catch (e) {
    debugPrint("users API error: $e");
    return null;
  }
}


Future<UserResponse?> updateusers(
  int userId,
  String name,
  String email,
  String? password,
  String? path,
  String? selectedLocation,
  bool isChecked,
  bool isStatusActive,
  String? selectedDesignation,
  int? selectedrole,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final formData = FormData.fromMap({
      'user_name': name,
      'user_email': email,
      'password': password,
      'work_location': selectedLocation,
      'production_support': isChecked,
      'is_active': isStatusActive,
      'designation': selectedDesignation ?? 1, // ✅ use your dropdown value
      'role_id': selectedrole ?? 1,            // ✅ use your dropdown value
      if (path != null) 
        'profile_picture': await MultipartFile.fromFile(path),
    });

    final response = await _client.dio.put(
      'api/users/$userId/',
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // ✅ Parse into UserResponse model safely
      if (data is Map<String, dynamic>) {
        return UserResponse.fromJson(data);
      } else {
        return null;
      }
    } else {
      lastError = response.data;
      return null;
    }
  } catch (e) {
    debugPrint("users API error: $e");
    return null;
  }
}

Future<ProjectResponse?> postproject({
  required String name,
  String? projectType,
  required String description,
  File? projectLogoFile,
  File? socUploadFile,
 
 List<int>? client,
 List<int>? project_manager,
 List<int>? business_developer,
 List<int>? finance,
  
 List<int>? it_support, 
  List<int>? team_lead,
  List<int>? developer, 
   List<int>? interns}
  
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final formData = FormData.fromMap({
      "project_type":projectType,
      "project_name":name,
      "project_description":description,
      "client":client,
      "project_manager":project_manager,
      "developer":developer,
      "it_support":it_support,
      "interns":interns,
      "team_lead":team_lead,
      "business_developer":business_developer,
      "finance": finance, // <-- ADDED COMMA

    // This is the correct collection-if syntax
    if (projectLogoFile != null)
      'project_logo': await MultipartFile.fromFile(projectLogoFile.path), // <-- ADDED COMMA

    if (socUploadFile != null)
      'soc_upload': await MultipartFile.fromFile(socUploadFile.path),
    });

    final response = await _client.dio.post(
      'api/projects/',
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // ✅ Parse into UserResponse model safely
      if (data is Map<String, dynamic>) {
        return ProjectResponse.fromJson(data);
      } else {
        return null;
      }
    } else {
      lastError = response.data;
      return null;
    }
  } catch (e) {
    debugPrint("users API error: $e");
    return null;
  }
}


Future<ProjectResponse?> updateproject({
required String name,
  String? projectType,
  required String description,
  File? projectLogoFile,
  File? socUploadFile,
 
 List<int>? client,
 List<int>? project_manager,
 List<int>? business_developer,
 List<int>? finance,
  
 List<int>? it_support, 
  List<int>? team_lead,
  List<int>? developer, 
   List<int>? interns, required int projectId}
 
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final formData = FormData.fromMap({
     "project_type":projectType,
      "project_name":name,
      "project_description":description,
      "client":client,
      "project_manager":project_manager,
      "developer":developer,
      "it_support":it_support,
      "interns":interns,
      "team_lead":team_lead,
      "business_developer":business_developer,
      "finance": finance, // <-- ADDED COMMA

    // This is the correct collection-if syntax
    if (projectLogoFile != null)
      'project_logo': await MultipartFile.fromFile(projectLogoFile.path), // <-- ADDED COMMA

    if (socUploadFile != null)
      'soc_upload': await MultipartFile.fromFile(socUploadFile.path),
      });

    final response = await _client.dio.put(
      'api/projects/$projectId/',
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      // ✅ Parse into UserResponse model safely
      if (data is Map<String, dynamic>) {
        return ProjectResponse.fromJson(data);
      } else {
        return null;
      }
    } else {
      lastError = response.data;
      return null;
    }
  } catch (e) {
    debugPrint("users API error: $e");
    return null;
  }
}


}