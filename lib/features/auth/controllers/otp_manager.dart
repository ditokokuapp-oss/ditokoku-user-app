import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpManager extends GetxController {
  static const String _otpKey = 'current_otp';
  static const String _phoneKey = 'current_phone';
  static const String _timestampKey = 'otp_timestamp';
  
  // Store OTP with phone number and timestamp
  Future<void> storeOTP(String otp, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otpKey, otp);
    await prefs.setString(_phoneKey, phoneNumber);
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  // Get stored OTP
  Future<String?> getStoredOTP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_otpKey);
  }
  
  // Get stored phone number
  Future<String?> getStoredPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }
  
  // Check if OTP is still valid (within 5 minutes)
  Future<bool> isOTPValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    
    if (timestamp == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - timestamp;
    const fiveMinutes = 5 * 60 * 1000; // 5 minutes in milliseconds
    
    return difference <= fiveMinutes;
  }
  
  // Verify OTP
  Future<bool> verifyOTP(String inputOTP, String phoneNumber) async {
    final storedOTP = await getStoredOTP();
    final storedPhone = await getStoredPhone();
    final isValid = await isOTPValid();
    
    return storedOTP == inputOTP && 
           storedPhone == phoneNumber && 
           isValid;
  }
  
  // Clear stored OTP
  Future<void> clearOTP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_timestampKey);
  }
}