import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _accessToken; // Store access token
  String? _verificationId; // Store verification ID for OTP
  String? _refreshToken; // Store refresh token
  Timer? _tokenRefreshTimer; // Timer for automatic token refresh

  AuthService() {
    _loadTokens(); // ✅ Load tokens on app startup
  }

  /// **Register User & Initiate OTP Verification**
  Future<void> registerUser({
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    try {
      print("Registering user...");

      // Get user location
      String location = await _getUserLocation();
      const String backendUrl = "http://192.168.11.196:6000/api/users/signup";

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobile_number": phoneNumber,
          "first_name": firstName,
          "last_name": lastName,
          "location": location,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data["data"] != null) {
          _accessToken = data["data"]["tokens"]["accessToken"]; // Fix here
          print("User registered successfully. Access Token: $_accessToken");

          // Send OTP
          await sendOtp(phoneNumber);
          print("OTP sent successfully!");
        } else {
          throw Exception("Unexpected response format: ${response.body}");
        }
      } else {
        throw Exception("Failed to register user: ${response.body}");
      }
    } catch (e) {
      print("Error registering user: $e");
      throw Exception("Registration Error: ${e.toString()}");
    }
  }

  /// **Send OTP to User**
  Future<void> sendOtp(String phoneNumber) async {
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

  /// **Resend OTP to User**
  Future<void> resendOtp(String phoneNumber) async {
    print("Resending OTP...");
    await sendOtp(phoneNumber);
  }

  /// **Verify OTP & Authenticate User**
  Future<void> verifyOtp({required String otpCode}) async {
    try {
      if (_verificationId == null) {
        throw Exception("OTP not sent yet. Please request OTP first.");
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        print(
          "User phone number from Firebase: ${userCredential.user?.phoneNumber}",
        );
        await sendOtpToBackend(await userCredential.user?.getIdToken() ?? "");
      } else {
        throw Exception("User credential is null");
      }
    } catch (e) {
      // print("OTP verification failed: $e");
      throw Exception("Invalid OTP: ${e.toString()}");
    }
  }

  /// **Send Verified OTP Token to Backend**
  Future<void> sendOtpToBackend(String otpToken) async {
    // print(_accessToken);

    try {
      if (_accessToken == null) {
        throw Exception("Access token missing. Please register first.");
      }

      const String otpUrl = "http://192.168.11.196:6000/api/users/verify-token";

      final response = await http.post(
        Uri.parse(otpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          "idToken": otpToken, // Send verified OTP token
        }),
      );

      final responseData = jsonDecode(response.body);

      // ✅ Check if the response contains `success: true`
      if (response.statusCode == 200 && responseData["success"] == true) {
        // print("✅ OTP verified successfully!");
      } else {
        throw Exception("❌ Failed to verify OTP: ${response.body}");
      }
    } catch (e) {
      // print("❌ OTP Verification Error: $e");
      throw Exception("OTP Verification Error: ${e.toString()}");
    }
  }

  /// **Get User Location (Latitude, Longitude)**
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
      String city = await getCityFromCoordinates(latitude, longitude);

      return city;
    } catch (e) {
      return "Location Error: ${e.toString()}";
    }
  }

  Future<String> getCityFromCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("🔍 API Response: $data"); // Debugging

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

  /// **Verify OTP & Get Firebase ID Token**
  Future<String?> verifySigInOtp(String otpCode) async {
    try {
      if (_verificationId == null) {
        throw Exception("OTP not sent yet. Please request OTP first.");
      }

      // ✅ Create a credential using the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      // ✅ Sign in with the credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        // ✅ Get Firebase ID Token
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

  /// **Sign in User after OTP Verification**
  Future<void> signInUser({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      // ✅ Step 1: Verify OTP and Get ID Token
      String? idToken = await verifySigInOtp(otpCode);

      if (idToken == null) {
        throw Exception("❌ Failed to retrieve verified OTP code.");
      }

      const String signInUrl = "http://192.168.11.196:6000/api/users/signin";

      // ✅ Step 2: Send Verified ID Token for Sign-in
      final response = await http.post(
        Uri.parse(signInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "mobile_number": phoneNumber,
          "idToken": idToken, // Send verified OTP as ID token
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["success"] == true) {
        _accessToken = responseData["data"]["tokens"]["accessToken"];
        _refreshToken = responseData["data"]["tokens"]["refreshToken"];

        await _saveTokens(_accessToken!, _refreshToken!);
        _startTokenRefreshTimer(); // Start refresh timer on successful login

        // ✅ Successfully signed in
        print("✅ User signed in successfully!");
        print("🔑 Access Token: $_accessToken");
        print("🔄 Refresh Token: $_refreshToken");
      } else {
        throw Exception("❌ Failed to sign in: ${response.body}");
      }
    } catch (e) {
      // print("❌ Sign-in Error: $e");
      throw Exception("Sign-in Error: ${e.toString()}");
    }
  }

  /// **Auto-Refresh Token Every Hour**
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer
        ?.cancel(); // Cancel existing timer to prevent duplication
    if (_refreshToken == null) return; // Ensure a valid refresh token exists

    _tokenRefreshTimer = Timer.periodic(const Duration(seconds: 10), (
      Timer timer,
    ) async {
      await _refreshAccessToken();
    });
  }

  /// **Refresh Access Token using Refresh Token**
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      print("No refresh token found. Logging out user.");
      await signOut();
      return;
    }

    const String refreshUrl =
        "http://192.168.11.196:6000/api/users/refresh-token";

    try {
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": _refreshToken}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["success"] == true) {
        _accessToken = responseData["data"]["accessToken"]["accessToken"];
        await _saveTokens(_accessToken!, _refreshToken!);
        print("✅ Access token refreshed successfully!");
      } else {
        print("❌ Refresh token expired! Logging out user.");
        await signOut();
      }
    } catch (e) {
      print("❌ Token Refresh Error: ${e.toString()}");
      await signOut();
    }
  }

  /// **Save Tokens in SharedPreferences**
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
  }

  /// **Load Tokens & Start Refresh Timer on App Startup**
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("access_token");
    _refreshToken = prefs.getString("refresh_token");

    if (_refreshToken != null) {
      _startTokenRefreshTimer(); // Start auto-refresh on app launch
    }
  }

  /// **Sign Out User**
  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _verificationId = null;

    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");

    _tokenRefreshTimer?.cancel(); // Stop token refresh timer

    print("✅ User signed out successfully!");
  }

  /// **Check if user is logged in**
  Future<bool> isLoggedIn() async {
    await _loadTokens();
    return _accessToken != null;
  }

  /// **Get Access Token**
  String? getAccessToken() {
    return _accessToken;
  }
}
