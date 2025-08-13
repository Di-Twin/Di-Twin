import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/core/network/network_checker.dart';

// Update the AuthRemoteDataSource abstract class to include all required methods
abstract class AuthRemoteDataSource {
  Future<bool> isLoggedIn();
  Future<Map<String, dynamic>> signOut();

  // Token validation
  Future<Map<String, dynamic>> validateToken();

  // Email Authentication
  Future<Map<String, dynamic>> initiateEmailSignup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  });
  Future<Map<String, dynamic>> completeEmailSignup({required String otp, required String token});
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  });

  // OAuth Authentication
  Future<Map<String, dynamic>> oauthSignIn({
    required String email,
    required String provider,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  });

  // Password Reset
  Future<Map<String, dynamic>> forgotPassword({required String email});
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String otp,
    required String password,
  });

  // User Profile
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? dob,
    String? location,
    String? userPlan,
  });
  Future<Map<String, dynamic>> deleteUserAccount();

  // Token Management
  Future<Map<String, dynamic>> refreshAccessToken();
  String? getAccessToken();

  // Legacy Phone Authentication (for backward compatibility)
  Future<Map<String, dynamic>> startUserRegistration({required String phoneNumber});
  Future<Map<String, dynamic>> completeRegistration({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String otpCode,
  });
  Future<Map<String, dynamic>> signInUser({
    required String phoneNumber,
    required String otpCode,
  });
  Future<Map<String, dynamic>> resendOtp(String phoneNumber);
}

// Update the implementation class with the new methods
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _accessToken; // Store access token
  String? _refreshToken; // Store refresh token
  Timer? _tokenRefreshTimer; // Timer for automatic token refresh
  String? _verificationId; // Store verification ID for OTP
  String? _resetToken; // Store token for password reset

  // Base URL for API
  static const String baseUrl = "https://test-prod-f427.onrender.com/api";

  // Singleton pattern to ensure only one instance exists
  static final AuthRemoteDataSourceImpl _instance = AuthRemoteDataSourceImpl._internal();

  factory AuthRemoteDataSourceImpl() {
    return _instance;
  }

  AuthRemoteDataSourceImpl._internal() {
    _loadTokens(); // Load tokens on app startup
  }

  Map<String, dynamic> decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format - expected 3 parts, got ${parts.length}');
      }

      final payload = parts[1];

      // Add padding if needed for base64 decoding
      String normalized = payload;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('Invalid JWT payload format');
      }

      return payloadMap;
    } catch (e) {
      print("❌ JWT decode error: $e");
      throw Exception('Failed to decode JWT token: $e');
    }
  }

  // Private helper methods
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", accessToken);
      await prefs.setString("refresh_token", refreshToken);

      // Try to decode JWT and extract user ID, but don't fail if it doesn't work
      try {
        final decodedToken = decodeJwt(accessToken);
        if (decodedToken.containsKey("userId")) {
          final userId = decodedToken["userId"].toString();
          await prefs.setString("user_id", userId);
          print("✅ User ID saved: $userId");
        } else if (decodedToken.containsKey("sub")) {
          // Some JWTs use 'sub' for user ID
          final userId = decodedToken["sub"].toString();
          await prefs.setString("user_id", userId);
          print("✅ User ID saved from 'sub': $userId");
        } else {
          print("⚠️ No userId found in token payload");
        }
      } catch (e) {
        print("⚠️ Could not decode JWT for user ID: $e");
        // Continue without user ID - not critical for token storage
      }

      print("✅ Tokens saved successfully to SharedPreferences");
      print("✅ Access Token: ${accessToken.substring(0, 20)}...");
      print("✅ Refresh Token: ${refreshToken.substring(0, 20)}...");
    } catch (e) {
      print("❌ Error saving tokens: $e");
      throw Exception("Failed to save authentication tokens: $e");
    }
  }

  Future<void> _loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString("access_token");
      _refreshToken = prefs.getString("refresh_token");

      if (_accessToken != null && _refreshToken != null) {
        print("✅ Tokens loaded from SharedPreferences");
        print("✅ Access Token: ${_accessToken!.substring(0, 20)}...");
        print("✅ Refresh Token: ${_refreshToken!.substring(0, 20)}...");

        _startTokenRefreshTimer(); // Start auto-refresh on app launch
      } else if (_accessToken != null || _refreshToken != null) {
        print("⚠️ Incomplete token data found - clearing all tokens");
        await _clearStoredTokens();
      } else {
        print("ℹ️ No tokens found in storage");
      }
    } catch (e) {
      print("❌ Error loading tokens: $e");
      // Clear potentially corrupted tokens
      await _clearStoredTokens();
    }
  }

  Future<void> _clearStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("refresh_token");
      await prefs.remove("user_id");
      _accessToken = null;
      _refreshToken = null;
      print("🗑️ Stored tokens cleared");
    } catch (e) {
      print("❌ Error clearing stored tokens: $e");
    }
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel(); // Prevent duplicates
    if (_refreshToken == null) return;

    // Refresh token every 30 minutes
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      await refreshAccessToken();
    });

    print("🔁 Token refresh timer started (every 30 minutes)");
  }

  Future<String> _getCityFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract the best available location data
        return data["address"]["city"] ??
            data["address"]["town"] ??
            data["address"]["village"] ??
            data["address"]["suburb"] ??
            data["address"]["county"] ??
            data["address"]["state"] ??
            "Unknown location";
      } else {
        return "City API error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error fetching city: ${e.toString()}";
    }
  }

  Future<String> _getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location disabled";
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return "Location permission denied";
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Call API to get city name
      String city = await _getCityFromCoordinates(latitude, longitude);

      return city;
    } catch (e) {
      return "Location Error: ${e.toString()}";
    }
  }

  Future<void> _sendOtp(String phoneNumber) async {
    print("Sending OTP to: $phoneNumber");
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          print("Auto OTP verification completed.");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("OTP sending failed: ${e.message}");
          throw Exception("OTP sending failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          print("OTP sent successfully. Verification ID: $_verificationId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print("OTP Sending Error: $e");
      throw Exception("OTP Sending Error: ${e.toString()}");
    }
  }

  Future<String?> _verifyOtp(String otpCode) async {
    try {
      if (_verificationId == null) {
        throw Exception("OTP not sent yet. Please request OTP first.");
      }

      // Create a credential using the verification ID and OTP
      UserCredential userCredential = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpCode,
        ),
      );

      if (userCredential.user != null) {
        // Get Firebase ID Token
        String? freshIdToken = await userCredential.user?.getIdToken(true);

        if (freshIdToken == null) {
          throw Exception("Failed to retrieve Firebase ID Token");
        }

        return freshIdToken; // Return valid ID Token
      } else {
        throw Exception("User credential is null");
      }
    } catch (e) {
      throw Exception("Invalid OTP: ${e.toString()}");
    }
  }

  Future<bool> _verifyTokenStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedAccessToken = prefs.getString("access_token");
      final storedRefreshToken = prefs.getString("refresh_token");

      bool isValid = storedAccessToken != null &&
          storedRefreshToken != null &&
          storedAccessToken == _accessToken &&
          storedRefreshToken == _refreshToken;

      if (isValid) {
        print("✅ Token storage verification passed");
      } else {
        print("❌ Token storage verification failed");
        print("Stored access token: ${storedAccessToken?.substring(0, 20)}...");
        print("Memory access token: ${_accessToken?.substring(0, 20)}...");
      }

      return isValid;
    } catch (e) {
      print("❌ Token verification error: $e");
      return false;
    }
  }

  // Debug method to check current token status
  Future<Map<String, dynamic>> debugTokenStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedAccessToken = prefs.getString("access_token");
      final storedRefreshToken = prefs.getString("refresh_token");
      final storedUserId = prefs.getString("user_id");

      return {
        "memory_access_token_exists": _accessToken != null,
        "memory_refresh_token_exists": _refreshToken != null,
        "stored_access_token_exists": storedAccessToken != null,
        "stored_refresh_token_exists": storedRefreshToken != null,
        "stored_user_id_exists": storedUserId != null,
        "tokens_match": _accessToken == storedAccessToken && _refreshToken == storedRefreshToken,
        "access_token_preview": _accessToken?.substring(0, 20),
        "stored_access_token_preview": storedAccessToken?.substring(0, 20),
        "user_id": storedUserId,
      };
    } catch (e) {
      return {
        "error": e.toString(),
      };
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    await _loadTokens();
    return _accessToken != null;
  }

  @override
  Future<Map<String, dynamic>> validateToken() async {
    print("🔍 Starting token validation...");

    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      print("❌ No internet connection for token validation");
      return {
        "success": false,
        "isValid": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    // Load tokens from storage if not already loaded
    await _loadTokens();

    if (_accessToken == null) {
      print("❌ No access token found");
      return {
        "success": false,
        "isValid": false,
        "message": "No access token found. Please log in.",
        "error": "no_token"
      };
    }

    try {
      final String checkTokenUrl = "$baseUrl/check-token";
      print("⚡ Validating token at: $checkTokenUrl");
      print("⚡ Using token: ${_accessToken!.substring(0, 20)}...");

      final response = await http.get(
        Uri.parse(checkTokenUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      print("⚡ Token validation response status: ${response.statusCode}");
      print("⚡ Token validation response body: ${response.body}");

      // Handle empty response body
      if (response.body.isEmpty) {
        print("❌ Empty response from token validation");
        return {
          "success": false,
          "isValid": false,
          "message": "Server returned empty response",
          "error": "empty_response"
        };
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          // Check if token is valid based on API response
          bool isValid = data["message"] == "Token is valid";

          if (isValid) {
            print("✅ Token is valid");
            return {
              "success": true,
              "isValid": true,
              "message": "Token is valid",
              "data": data
            };
          } else {
            print("❌ Token is invalid according to server");
            // Clear invalid tokens
            await _clearStoredTokens();
            return {
              "success": true,
              "isValid": false,
              "message": "Token is invalid",
              "error": "invalid_token"
            };
          }
        } else if (response.statusCode == 401) {
          print("❌ Token validation failed - 401 Unauthorized");

          // Try to refresh the token first
          print("🔄 Attempting to refresh token...");
          final refreshResult = await refreshAccessToken();

          if (refreshResult["success"] == true) {
            print("✅ Token refreshed successfully, retrying validation...");
            // Retry validation with new token
            return await validateToken();
          } else {
            print("❌ Token refresh failed, clearing tokens");
            await _clearStoredTokens();
            return {
              "success": true,
              "isValid": false,
              "message": "Token expired and refresh failed",
              "error": "token_expired"
            };
          }
        } else {
          print("❌ Token validation failed with status: ${response.statusCode}");
          return {
            "success": false,
            "isValid": false,
            "message": "Token validation failed: ${data["message"] ?? "Unknown error"}",
            "error": "validation_failed"
          };
        }
      } catch (e) {
        print("❌ Error parsing token validation response: $e");
        return {
          "success": false,
          "isValid": false,
          "message": "Error parsing server response",
          "error": "parse_error"
        };
      }
    } on SocketException catch (e) {
      print("❌ Network error during token validation: $e");
      return {
        "success": false,
        "isValid": false,
        "message": "Unable to connect to server for token validation",
        "error": "network_error"
      };
    } on TimeoutException catch (e) {
      print("❌ Timeout during token validation: $e");
      return {
        "success": false,
        "isValid": false,
        "message": "Token validation request timed out",
        "error": "timeout_error"
      };
    } catch (e) {
      print("❌ Unexpected error during token validation: $e");
      return {
        "success": false,
        "isValid": false,
        "message": "Token validation failed: ${e.toString()}",
        "error": "validation_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> signOut() async {
    try {
      _tokenRefreshTimer?.cancel(); // Stop token refresh timer first

      await _auth.signOut();
      await _clearStoredTokens();

      print("✅ User signed out successfully!");
      return {
        "success": true,
        "message": "User signed out successfully!",
      };
    } catch (e) {
      print("❌ Sign out Error: ${e.toString()}");
      return {
        "success": false,
        "message": "Failed to sign out: ${e.toString()}",
        "error": "signout_error"
      };
    }
  }

  // Make exactly ONE attempt to initiate email signup with better error handling
  @override
  Future<Map<String, dynamic>> initiateEmailSignup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      final String backendUrl = "$baseUrl/users/email/initiate-signup";
      print("⚡ Sending signup request to: $backendUrl");

      final requestBody = {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "mobile_number": mobileNumber ?? "",
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      // Make exactly ONE HTTP request
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      // .timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      // Handle server availability issues (503 errors)
      if (response.statusCode == 503) {
        return {
          "success": false,
          "message": "The server is temporarily unavailable. Please try again in a few minutes.",
          "error": "server_unavailable"
        };
      }

      // Handle empty response body
      if (response.body.isEmpty) {
        return {
          "success": false,
          "message": "The server returned an empty response. Please try again.",
          "error": "empty_response"
        };
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Check if the response has the expected structure
          if (data.containsKey("success") && data["success"] == true) {
            if (data["message"] == "User already exists") {
              return {
                "success": true,
                "userExists": true,
                "isOauth": data["data"]["isOauth"],
                "isPassword": data["data"]["isPassword"],
              };
            } else if (data["message"] == "OTP sent successfully") {
              // Get the signup token for OTP verification
              String token = data["data"]["token"];
              print("✅ OTP sent successfully. Token received: $token");

              return {
                "success": true,
                "userExists": false,
                "message": "OTP sent successfully",
                "token": token, // Return the token in the response
                "data": {"token": token} // Also include in data for compatibility
              };
            } else {
              // Handle any other success messages
              return {
                "success": true,
                "message": data["message"],
              };
            }
          } else if (data.containsKey("status") && data["status"] == "success") {
            // Alternative API response format
            if (data["message"] == "User already exists") {
              return {
                "success": true,
                "userExists": true,
                "isOauth": data["data"]["isOauth"],
                "isPassword": data["data"]["isPassword"],
              };
            } else if (data["message"] == "OTP sent successfully") {
              // Get the signup token for OTP verification
              String token = data["data"]["token"];
              print("✅ OTP sent successfully. Token received: $token");

              return {
                "success": true,
                "userExists": false,
                "message": "OTP sent successfully",
                "token": token, // Return the token in the response
                "data": {"token": token} // Also include in data for compatibility
              };
            } else {
              // Handle any other success messages
              return {
                "success": true,
                "message": data["message"],
              };
            }
          } else {
            print("❌ Unexpected response format: $data");
            return {
              "success": false,
              "message": "Unexpected response format from server",
              "error": "unexpected_format"
            };
          }
        } else {
          return {
            "success": false,
            "message": "Failed to initiate signup: ${data["message"] ?? "Unknown error"}",
            "error": "api_error"
          };
        }
      } catch (e) {
        print("❌ Error parsing response: $e");
        return {
          "success": false,
          "message": "Error parsing server response. Please try again.",
          "error": "parse_error"
        };
      }
    } on SocketException catch (e) {
      print("❌ Network Error: $e");
      return {
        "success": false,
        "message": "Unable to connect to the server. Please check your internet connection and try again.",
        "error": "network_error"
      };
    } on TimeoutException catch (e) {
      print("❌ Timeout Error: $e");
      return {
        "success": false,
        "message": "The server took too long to respond. Please try again later.",
        "error": "timeout_error"
      };
    } on FormatException catch (e) {
      print("❌ Format Error: $e");
      return {
        "success": false,
        "message": "The server returned an invalid response. Please try again later.",
        "error": "format_error"
      };
    } catch (e) {
      print("❌ Error initiating email signup: $e");
      return {
        "success": false,
        "message": "Email signup failed: ${e.toString()}",
        "error": "unknown_error"
      };
    }
  }

  // Make exactly ONE attempt to complete email signup
  @override
  Future<Map<String, dynamic>> completeEmailSignup({
    required String otp,
    required String token,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    if (token.isEmpty) {
      print("❌ Signup token is empty");
      return {
        "success": false,
        "message": "Signup token is missing. Please initiate signup first.",
        "error": "missing_token"
      };
    }

    print("🔑 Using signup token for verification: $token");

    try {
      final String backendUrl = "$baseUrl/users/email/complete-signup";
      print("⚡ Sending complete signup request to: $backendUrl");

      final requestBody = {
        "token": token,
        "otp": otp,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      // Make exactly ONE HTTP request
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      // Handle server availability issues (503 errors)
      if (response.statusCode == 503) {
        return {
          "success": false,
          "message": "The server is temporarily unavailable. Please try again in a few minutes.",
          "error": "server_unavailable"
        };
      }

      // Handle empty response body
      if (response.body.isEmpty) {
        return {
          "success": false,
          "message": "The server returned an empty response. Please try again.",
          "error": "empty_response"
        };
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (data["success"] == true) {
            _accessToken = data["data"]["accessToken"];
            _refreshToken = data["data"]["refreshToken"];

            await _saveTokens(_accessToken!, _refreshToken!);
            // Verify tokens were saved correctly
            bool verified = await _verifyTokenStorage();
            if (!verified) {
              print("⚠️ Token storage verification failed, but continuing...");
            }
            _startTokenRefreshTimer();

            print("✅ User registered and logged in successfully!");
            return {
              "success": true,
              "message": "User registered and logged in successfully!",
            };
          } else {
            return {
              "success": false,
              "message": "Failed to complete signup: ${data["message"]}",
              "error": "api_error"
            };
          }
        } else {
          return {
            "success": false,
            "message": "Failed to complete signup: ${data["message"] ?? "Unknown error"}",
            "error": "api_error"
          };
        }
      } catch (e) {
        print("❌ Error parsing response: $e");
        return {
          "success": false,
          "message": "Error parsing server response. Please try again.",
          "error": "parse_error"
        };
      }
    } on SocketException catch (e) {
      print("❌ Network Error: $e");
      return {
        "success": false,
        "message": "Unable to connect to the server. Please check your internet connection and try again.",
        "error": "network_error"
      };
    } on TimeoutException catch (e) {
      print("❌ Timeout Error: $e");
      return {
        "success": false,
        "message": "The server took too long to respond. Please try again later.",
        "error": "timeout_error"
      };
    } on FormatException catch (e) {
      print("❌ Format Error: $e");
      return {
        "success": false,
        "message": "The server returned an invalid response. Please try again later.",
        "error": "format_error"
      };
    } catch (e) {
      print("❌ Error completing email signup: $e");
      return {
        "success": false,
        "message": "Complete signup failed: ${e.toString()}",
        "error": "unknown_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      final String loginUrl = "$baseUrl/users/email/login";
      print("⚡ Sending login request to: $loginUrl");

      final requestBody = {
        "email": email,
        "password": password,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      // Handle server availability issues (503 errors)
      if (response.statusCode == 503) {
        return {
          "success": false,
          "message": "The server is temporarily unavailable. Please try again in a few minutes.",
          "error": "server_unavailable"
        };
      }

      // Handle empty response body
      if (response.body.isEmpty) {
        return {
          "success": false,
          "message": "The server returned an empty response. Please try again.",
          "error": "empty_response"
        };
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data["success"] == true) {
          if (data["message"] == "User logged in successfully") {
            _accessToken = data["data"]["accessToken"];
            _refreshToken = data["data"]["refreshToken"];

            await _saveTokens(_accessToken!, _refreshToken!);
            // Verify tokens were saved correctly
            bool verified = await _verifyTokenStorage();
            if (!verified) {
              print("⚠️ Token storage verification failed, but continuing...");
            }
            _startTokenRefreshTimer();

            print("✅ User logged in successfully!");
            print("✅ Access Token: $_accessToken");
            print("✅ Refresh Token: $_refreshToken");

            return {
              "success": true,
              "message": "User logged in successfully",
            };
          } else if (data["message"] == "User already exists") {
            return {
              "success": true,
              "userExists": true,
              "isOauth": data["data"]["isOauth"],
              "isPassword": data["data"]["isPassword"],
              "message": "This account uses a different sign-in method",
            };
          } else {
            return {
              "success": false,
              "message": "Unexpected response message: ${data["message"]}",
              "error": "api_error"
            };
          }
        } else {
          return {
            "success": false,
            "message": "Failed to login: ${data["message"] ?? "Unknown error"}",
            "error": "api_error"
          };
        }
      } catch (e) {
        print("❌ Error parsing response: $e");
        return {
          "success": false,
          "message": "Error parsing server response. Please try again.",
          "error": "parse_error"
        };
      }
    } on SocketException catch (e) {
      print("❌ Network Error: $e");
      return {
        "success": false,
        "message": "Unable to connect to the server. Please check your internet connection and try again.",
        "error": "network_error"
      };
    } on TimeoutException catch (e) {
      print("❌ Timeout Error: $e");
      return {
        "success": false,
        "message": "The server took too long to respond. Please try again later.",
        "error": "timeout_error"
      };
    } on FormatException catch (e) {
      print("❌ Format Error: $e");
      return {
        "success": false,
        "message": "The server returned an invalid response. Please try again later.",
        "error": "format_error"
      };
    } catch (e) {
      print("❌ Email Login Error: $e");
      String errorMessage = e.toString();

      // Provide more user-friendly error messages for common errors
      if (errorMessage.contains("Failed host lookup") ||
          errorMessage.contains("SocketException") ||
          errorMessage.contains("Connection refused")) {
        return {
          "success": false,
          "message": "Unable to connect to the server. Please check your internet connection and try again.",
          "error": "network_error"
        };
      }

      return {
        "success": false,
        "message": "Login failed: ${e.toString()}",
        "error": "unknown_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> oauthSignIn({
    required String email,
    required String provider,
    required String firstName,
    required String lastName,
    String? mobileNumber,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      final String oauthUrl = "$baseUrl/users/oauth/signin";
      print("⚡ Sending OAuth sign-in request to: $oauthUrl");

      final requestBody = {
        "email": email,
        "provider": provider,
        "first_name": firstName,
        "last_name": lastName,
        "mobile_number": mobileNumber ?? "",
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(oauthUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (data["message"] == "User logged in successfully") {
          _accessToken = data["data"]["accessToken"];
          _refreshToken = data["data"]["refreshToken"];

          await _saveTokens(_accessToken!, _refreshToken!);
          _startTokenRefreshTimer();

          print("✅ User logged in with OAuth successfully!");
          return {
            "success": true,
            "message": "User logged in successfully",
          };
        } else if (data["message"] == "User already exists") {
          return {
            "success": false,
            "userExists": true,
            "isOauth": data["data"]["isOauth"],
            "isPassword": data["data"]["isPassword"],
            "message": "This account uses a different sign-in method",
          };
        } else if (data["message"] == "Provider mismatch") {
          return {
            "success": false,
            "userExists": true,
            "isOauth": data["data"]["isOauth"],
            "isPassword": data["data"]["isPassword"],
            "providerWrong": true,
            "message": "This account uses a different OAuth provider",
          };
        } else {
          return {
            "success": false,
            "message": "Unexpected response message: ${data["message"]}",
            "error": "api_error"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Failed to login with OAuth: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ OAuth Sign-in Error: $e");
      return {
        "success": false,
        "message": "OAuth sign-in failed: ${e.toString()}",
        "error": "oauth_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      final String forgotUrl = "$baseUrl/users/password/forgot";
      print("⚡ Sending forgot password request to: $forgotUrl");

      final requestBody = {
        "email": email,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(forgotUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        if (data["message"] == "OTP sent successfully") {
          _resetToken = data["data"]["token"];
          print("✅ Password reset OTP sent successfully!");
          return {
            "success": true,
            "message": "OTP sent successfully",
          };
        } else if (data["message"] == "Cannot reset password for OAuth users") {
          return {
            "success": false,
            "isOauth": true,
            "message": "Cannot reset password for OAuth users",
          };
        } else {
          return {
            "success": false,
            "message": "Unexpected response message: ${data["message"]}",
            "error": "api_error"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Failed to send password reset OTP: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ Forgot Password Error: $e");
      return {
        "success": false,
        "message": "Failed to send password reset OTP: ${e.toString()}",
        "error": "forgot_password_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String otp,
    required String password,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      final String resetUrl = "$baseUrl/users/password/reset";
      print("⚡ Sending password reset request to: $resetUrl");

      final requestBody = {
        "token": token,
        "otp": otp,
        "password": password,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(resetUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        print("✅ Password reset successfully!");
        return {
          "success": true,
          "message": "Password reset successfully",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to reset password: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ Reset Password Error: $e");
      return {
        "success": false,
        "message": "Failed to reset password: ${e.toString()}",
        "error": "reset_password_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    if (_accessToken == null) {
      return {
        "success": false,
        "message": "Not logged in. Please log in first.",
        "error": "auth_error"
      };
    }

    try {
      final String profileUrl = "$baseUrl/users";
      print("⚡ Fetching user profile from: $profileUrl");

      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        print("✅ User profile fetched successfully!");
        return {
          "success": true,
          "message": "User profile fetched successfully",
          "data": data["data"],
        };
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshAccessToken();
        if (refreshResult["success"]) {
          // Retry with new token
          return await getUserProfile();
        } else {
          return {
            "success": false,
            "message": "Session expired. Please log in again.",
            "error": "auth_error"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Failed to fetch user profile: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ Get Profile Error: $e");
      return {
        "success": false,
        "message": "Failed to fetch user profile: ${e.toString()}",
        "error": "profile_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? dob,
    String? location,
    String? userPlan,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    if (_accessToken == null) {
      return {
        "success": false,
        "message": "Not logged in. Please log in first.",
        "error": "auth_error"
      };
    }

    try {
      final String updateUrl = "$baseUrl/users";
      print("⚡ Updating user profile at: $updateUrl");

      // Build request body with only the fields that are provided
      final Map<String, dynamic> requestBody = {};
      if (firstName != null) requestBody["first_name"] = firstName;
      if (lastName != null) requestBody["last_name"] = lastName;
      if (dob != null) requestBody["dob"] = dob;
      if (location != null) requestBody["location"] = location;
      if (userPlan != null) requestBody["user_plan"] = userPlan;

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.patch(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        print("✅ User profile updated successfully!");
        return {
          "success": true,
          "message": "User profile updated successfully",
          "data": data["data"],
        };
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshAccessToken();
        if (refreshResult["success"]) {
          // Retry with new token
          return await updateUserProfile(
            firstName: firstName,
            lastName: lastName,
            dob: dob,
            location: location,
            userPlan: userPlan,
          );
        } else {
          return {
            "success": false,
            "message": "Session expired. Please log in again.",
            "error": "auth_error"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Failed to update user profile: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ Update Profile Error: $e");
      return {
        "success": false,
        "message": "Failed to update user profile: ${e.toString()}",
        "error": "profile_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteUserAccount() async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    if (_accessToken == null) {
      return {
        "success": false,
        "message": "Not logged in. Please log in first.",
        "error": "auth_error"
      };
    }

    try {
      final String deleteUrl = "$baseUrl/users";
      print("⚡ Deleting user account at: $deleteUrl");

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        // Clear all tokens and sign out
        await signOut();

        print("✅ User account deleted successfully!");
        return {
          "success": true,
          "message": "User account deleted successfully",
        };
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshAccessToken();
        if (refreshResult["success"]) {
          // Retry with new token
          return await deleteUserAccount();
        } else {
          return {
            "success": false,
            "message": "Session expired. Please log in again.",
            "error": "auth_error"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Failed to delete user account: ${data["message"] ?? "Unknown error"}",
          "error": "api_error"
        };
      }
    } catch (e) {
      print("❌ Delete Account Error: $e");
      return {
        "success": false,
        "message": "Failed to delete user account: ${e.toString()}",
        "error": "delete_account_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> refreshAccessToken() async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    if (_refreshToken == null) {
      return {
        "success": false,
        "message": "No refresh token found. Please log in again.",
        "error": "auth_error"
      };
    }

    try {
      final String refreshUrl = "$baseUrl/users/refresh-token";
      print("⚡ Refreshing token at: $refreshUrl");

      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": _refreshToken}),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        _accessToken = data["data"]["accessToken"];
        await _saveTokens(_accessToken!, _refreshToken!);

        print("✅ Access token refreshed successfully!");
        return {
          "success": true,
          "message": "Access token refreshed successfully",
        };
      } else {
        // If refresh token is invalid or expired, force logout
        await signOut();
        return {
          "success": false,
          "message": "Failed to refresh token: ${data["message"] ?? "Unknown error"}",
          "error": "refresh_token_error"
        };
      }
    } catch (e) {
      print("❌ Token Refresh Error: $e");
      // Force logout on persistent refresh errors
      await signOut();
      return {
        "success": false,
        "message": "Failed to refresh token: ${e.toString()}",
        "error": "refresh_token_error"
      };
    }
  }

  @override
  String? getAccessToken() {
    return _accessToken;
  }

  // Legacy methods for phone authentication - keeping for backward compatibility
  @override
  Future<Map<String, dynamic>> startUserRegistration({required String phoneNumber}) async {
    try {
      await _sendOtp(phoneNumber);
      return {
        "success": true,
        "message": "OTP sent successfully",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Failed to send OTP: ${e.toString()}",
        "error": "otp_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> completeRegistration({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String otpCode,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      // Step 1: Verify OTP with Firebase and get ID Token
      String? idToken = await _verifyOtp(otpCode);
      print("ID Token: $idToken");
      if (idToken == null) {
        return {
          "success": false,
          "message": "Unable to verify OTP. Please try again.",
          "error": "otp_verification_failed"
        };
      }

      // Step 2: Get user location
      String location = await _getUserLocation();

      final String backendUrl = "$baseUrl/users/signup";
      print("⚡ Sending registration request to: $backendUrl");

      final requestBody = {
        "mobile_number": phoneNumber,
        "first_name": firstName,
        "last_name": lastName,
        "location": location,
        "idToken": idToken,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["success"] == true) {
        _accessToken = data["data"]["tokens"]["accessToken"];
        _refreshToken = data["data"]["tokens"]["refreshToken"];

        await _saveTokens(_accessToken!, _refreshToken!);
        _startTokenRefreshTimer();

        print("✅ User registered and logged in successfully!");
        return {
          "success": true,
          "message": "User registered and logged in successfully!",
        };
      } else {
        return {
          "success": false,
          "message": "Registration failed: ${data["message"]}",
          "error": "registration_error"
        };
      }
    } catch (e) {
      print("❌ Error completing registration: $e");
      return {
        "success": false,
        "message": "Registration failed: ${e.toString()}",
        "error": "registration_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    try {
      print("Resending OTP...");
      await _sendOtp(phoneNumber);
      return {
        "success": true,
        "message": "OTP resent successfully",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Failed to resend OTP: ${e.toString()}",
        "error": "otp_error"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> signInUser({
    required String phoneNumber,
    required String otpCode,
  }) async {
    // Check internet connection first
    if (!await NetworkChecker.hasInternetConnection()) {
      return {
        "success": false,
        "message": "No internet connection. Please check your network settings and try again.",
        "error": "network_error"
      };
    }

    try {
      // Step 1: Verify OTP and Get ID Token
      String? idToken = await _verifyOtp(otpCode);

      if (idToken == null) {
        return {
          "success": false,
          "message": "Failed to verify OTP. Please try again.",
          "error": "otp_verification_failed"
        };
      }

      final String signInUrl = "$baseUrl/users/signin";
      print("⚡ Sending sign-in request to: $signInUrl");

      final requestBody = {
        "mobile_number": phoneNumber,
        "idToken": idToken,
      };

      print("⚡ Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(signInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print("⚡ Response status code: ${response.statusCode}");
      print("⚡ Response body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["success"] == true) {
        _accessToken = responseData["data"]["tokens"]["accessToken"];
        _refreshToken = responseData["data"]["tokens"]["refreshToken"];

        await _saveTokens(_accessToken!, _refreshToken!);
        _startTokenRefreshTimer(); // Start refresh timer on successful login

        // Successfully signed in
        print("✅ User signed in successfully!");
        print("🔑 Access Token: $_accessToken");
        print("🔄 Refresh Token: $_refreshToken");

        return {
          "success": true,
          "message": "User signed in successfully!",
        };
      } else {
        return {
          "success": false,
          "message": "Failed to sign in: ${response.body}",
          "error": "signin_error"
        };
      }
    } catch (e) {
      print("❌ Sign-in Error: $e");
      return {
        "success": false,
        "message": "Sign-in failed: ${e.toString()}",
        "error": "signin_error"
      };
    }
  }
}
