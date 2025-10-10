import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/common/models/response_model.dart';

class UserService {
  
  // Store the last user data response
  Map<String, dynamic>? _lastUserData;
  
  // Get last user data
  Map<String, dynamic>? getLastUserData() => _lastUserData;
  
  // Check if phone number exists using the correct endpoint
  Future<ResponseModel> checkPhoneExists(String phoneNumber) async {
    try {
      print('Checking phone exists for: $phoneNumber using /api/users/phone'); // Debug log
      
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/users/phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'phone': phoneNumber,
        }),
      ).timeout(Duration(seconds: 10));

      print('Check phone response status: ${response.statusCode}'); // Debug log
      print('Check phone response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          // Check if user was found
          if (responseData.containsKey('user') && responseData['user'] != null) {
            String message = responseData['message'] ?? 'User found';
            
            // Store user data for later use
            _lastUserData = responseData['user'];
            print('User data stored: ${_lastUserData}'); // Debug log
            
            return ResponseModel(true, message);
          } else if (responseData.containsKey('message') && 
                     responseData['message'].toString().toLowerCase().contains('found')) {
            return ResponseModel(true, responseData['message']);
          }
        }
        
        // If we reach here, user probably doesn't exist
        _lastUserData = null;
        return ResponseModel(false, 'User not found');
        
      } else if (response.statusCode == 404) {
        // User not found
        _lastUserData = null;
        return ResponseModel(false, 'User not found');
        
      } else if (response.statusCode >= 500) {
        // Server error - should retry
        return ResponseModel(false, 'Server error - please try again');
        
      } else {
        // Other client errors - assume user not found
        final responseData = json.decode(response.body);
        String message = 'User not found';
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          message = responseData['message'];
        }
        _lastUserData = null;
        return ResponseModel(false, message);
      }
      
    } on SocketException {
      return ResponseModel(false, 'No internet connection');
    } on FormatException {
      return ResponseModel(false, 'Invalid response format from server');
    } on http.ClientException {
      return ResponseModel(false, 'Network request failed');
    } catch (e) {
      print('Error in checkPhoneExists: $e'); // Debug log
      return ResponseModel(false, 'Network error: ${e.toString()}');
    }
  }

  // Mock version for testing
  Future<ResponseModel> mockCheckPhoneExists(String phoneNumber) async {
    await Future.delayed(Duration(seconds: 1));
    
    List<String> existingUsers = [
      '+6281234567890',
      '+6287654321098',
      '+6281288611368', // From your example
    ];
    
    if (existingUsers.contains(phoneNumber)) {
      // Mock user data similar to API response
      _lastUserData = {
        "id": 8,
        "f_name": "Andri",
        "l_name": "",
        "phone": phoneNumber,
        "email": "andrijunandri1@gmail.com",
        "image": null,
        "is_phone_verified": 1,
        "email_verified_at": null,
        "created_at": "2025-08-29T18:10:10.000Z",
        "updated_at": "2025-08-31T21:27:01.000Z",
        "interest": "[90,91,92,93,94,95,96,97,98,99,45,53,58,59,60,61,62,63,64,200,202,204,206,241]",
        "status": 1,
        "order_count": 0,
        "login_medium": "otp",
        "zone_id": 0,
        "wallet_balance": "0.000",
        "loyalty_point": "0.000",
        "ref_code": "QQGWZEFPXU",
        "current_language_key": "id",
      };
      
      return ResponseModel(true, 'User found');
    } else {
      _lastUserData = null;
      return ResponseModel(false, 'User not found');
    }
  }
}