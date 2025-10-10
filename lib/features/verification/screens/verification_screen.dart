import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/features/verification/domein/enum/verification_type_enum.dart';
import 'package:sixam_mart/features/verification/domein/models/verification_data_model.dart';
import 'package:sixam_mart/features/verification/screens/new_pass_screen.dart';
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? email;
  final bool fromSignUp;
  final String? token;
  final String? password;
  final String loginType;
  final String? firebaseSession;
  final bool fromForgetPassword;
  final UpdateUserModel? userModel;
  
  const VerificationScreen({
    super.key, 
    required this.number, 
    required this.password, 
    required this.fromSignUp,
    required this.token, 
    this.email, 
    required this.loginType, 
    this.firebaseSession, 
    required this.fromForgetPassword, 
    this.userModel
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  String? _email;
  Timer? _timer;
  int _seconds = 0;
  final ScrollController _scrollController = ScrollController();
  late StreamController<ErrorAnimationType> errorController;
  bool hasError = false;
  String errorMessage = "";
  bool _isVerifying = false;
  bool _locationPermissionRequested = false;

  @override
  void initState() {
    super.initState();
    
    print('VERIFICATION INIT: fromSignUp=${widget.fromSignUp}, loginType=${widget.loginType}');
    
    // Reset verification state
    _isVerifying = false;
    hasError = false;
    errorMessage = "";
    
    // Reset verification controller
    Get.find<VerificationController>().updateVerificationCode('', canUpdate: false);
    
    // Log controller states untuk debug
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('VerificationController isLoading: ${Get.find<VerificationController>().isLoading}');
      print('ProfileController isLoading: ${Get.find<ProfileController>().isLoading}');
      print('Local _isVerifying: $_isVerifying');
    });
    
    if(widget.number != null && widget.number!.isNotEmpty) {
      _number = widget.number!.startsWith('+') ? widget.number : '+${widget.number!.substring(1, widget.number!.length)}';
    }
    _email = widget.email;
    _startTimer();
    errorController = StreamController<ErrorAnimationType>();
    
    _requestLocationPermission();
    _preloadLocationData();
  }

  Future<void> _requestLocationPermission() async {
    print('Requesting location permission...');
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Permission denied forever - opening settings');
        Get.dialog(
          AlertDialog(
            title: Text('location_permission'.tr),
            content: Text('please_allow_location_permission'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
                child: Text('settings'.tr),
              ),
            ],
          ),
        );
      }
      
      setState(() {
        _locationPermissionRequested = true;
      });
      
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }
 
  Future<void> _preloadLocationData() async {
    print('Getting current location...');
    
    try {
      LocationController locationController = Get.find<LocationController>();
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          
          // Ambil current location dan set sebagai user address
          AddressModel addressModel = await locationController.getCurrentLocation(true);
          
          // Pastikan address model valid sebelum save
          if (addressModel.latitude != null && addressModel.longitude != null) {
            // Save sebagai user address supaya home screen bisa load data
            bool saved = await AddressHelper.saveUserAddressInSharedPref(addressModel);
            
            if (saved) {
              print('Location saved successfully: ${addressModel.address}');
              print('Latitude: ${addressModel.latitude}, Longitude: ${addressModel.longitude}');
            } else {
              print('Failed to save location');
            }
          } else {
            print('Invalid address model received');
          }
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
      
      // Fallback: create minimal address model
      try {
        AddressModel fallbackAddress = AddressModel(
          latitude: '-6.2088',
          longitude: '106.8456',
          address: 'Jakarta, Indonesia',
          addressType: 'others',
          zoneId: 1,
          zoneIds: [1],
        );
        await AddressHelper.saveUserAddressInSharedPref(fallbackAddress);
        print('Fallback address saved');
      } catch (fallbackError) {
        print('Fallback address save failed: $fallbackError');
      }
    }
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    errorController.close();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: isDesktop ? Colors.transparent : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Container(
            width: context.width > 700 ? 500 : context.width,
            padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
            decoration: context.width > 700 ? BoxDecoration(
              color: Theme.of(context).cardColor, 
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ) : null,
            child: GetBuilder<VerificationController>(builder: (verificationController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(isDesktop) Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Get.back(), 
                      icon: const Icon(Icons.clear)
                    ),
                  ),

                  Text(
                    'Masukkan Kode OTP',
                    style: robotoBold.copyWith(fontSize: 24, color: Colors.black),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    'Silahkan Masukkan 6 digit kode OTP yang dikirimkan melalui whatsapp',
                    style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                 // Di dalam Column widget, ganti bagian PinCodeTextField dan error message dengan kode berikut:

Padding(
  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
  child: PinCodeTextField(
    length: 6,
    appContext: context,
    keyboardType: TextInputType.number,
    animationType: AnimationType.fade,
    pinTheme: PinTheme(
      shape: PinCodeFieldShape.box,
      fieldHeight: 60,
      fieldWidth: 50,
      borderWidth: 0,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      selectedColor: Colors.transparent,
      selectedFillColor: Colors.grey.shade200,
      inactiveFillColor: Colors.grey.shade200,
      inactiveColor: Colors.transparent,
      activeColor: Colors.transparent,
      activeFillColor: Colors.grey.shade200,
    ),
    animationDuration: const Duration(milliseconds: 300),
    backgroundColor: Colors.transparent,
    enableActiveFill: true,
    onChanged: verificationController.updateVerificationCode,
    beforeTextPaste: (text) => true,
    errorAnimationController: errorController,
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
),

// Error message dengan spacing yang lebih baik
if(hasError) Padding(
  padding: const EdgeInsets.only(
    left: Dimensions.paddingSizeSmall,
    right: Dimensions.paddingSizeSmall,
    bottom: Dimensions.paddingSizeDefault,
  ),
  child: Text(
    errorMessage,
    style: const TextStyle(
      color: Colors.red, 
      fontSize: 12, 
      fontWeight: FontWeight.w400,
    ),
  ),
),

const SizedBox(height: Dimensions.paddingSizeSmall),

// Text "Tidak menerima kode OTP?" dengan positioning yang disesuaikan
Center(
  child: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        'Tidak menerima kode OTP? ',
        style: robotoRegular.copyWith(color: Colors.black, fontSize: 10),
      ),
      TextButton(
        onPressed: _seconds < 1 ? () async {
          if (widget.firebaseSession != null) {
            await Get.find<AuthController>().firebaseVerifyPhoneNumber(
              _number!,
              widget.token,
              widget.loginType,
              fromSignUp: widget.fromSignUp,
              canRoute: false,
            );
            _startTimer();
          } else {
            _resendOtp();
          }
        } : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Kirim Ulang${_seconds > 0 ? ' ($_seconds)' : ''}',
          style: robotoMedium.copyWith(
            color: _seconds < 1 ? const Color(0xFF5EC1B2) : Colors.grey,
            fontSize: 10,
          ),
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  GetBuilder<ProfileController>(builder: (profileController) {
                    // Check loading state dari multiple controller
                    bool isProcessing = _isVerifying || 
                                        verificationController.isLoading || 
                                        profileController.isLoading;
                    
                    print('Button render - VC Loading: ${verificationController.isLoading}, PC Loading: ${profileController.isLoading}, Local: $_isVerifying, Final: $isProcessing');
                    
                    return CustomButton(
                      buttonText: 'Konfirmasi',
                      radius: 16,
                      color: const Color(0xFF5DCBAD),
                      isBold: true,
                      isLoading: isProcessing,
                      onPressed: (verificationController.verificationCode.length < 6 || isProcessing) ? null : () async {
                        print('KONFIRMASI clicked with OTP: ${verificationController.verificationCode}');
                        print('Current _isVerifying state: $_isVerifying');
                        
                        // Force reset state di awal
                        setState(() {
                          _isVerifying = true;
                          hasError = false;
                          errorMessage = "";
                        });
                        
                        print('State set to verifying: $_isVerifying');
                        
                        try {
                          if(widget.fromSignUp) {
                            print('Processing sign up verification...');
                            
                            ResponseModel value = await verificationController.verifyPhone(
                              data: VerificationDataModel(
                                phone: _number, 
                                email: _email, 
                                verificationType: _number != null 
                                  ? VerificationTypeEnum.phone.name 
                                  : VerificationTypeEnum.email.name,
                                otp: verificationController.verificationCode, 
                                loginType: widget.loginType,
                                guestId: AuthHelper.getGuestId(),
                              )
                            );
                            
                            print('Verification response: success=${value.isSuccess}, message=${value.message}');
                            
                            if(value.isSuccess) {
                              await _handleVerifyResponse(value, _number, _email);
                            } else {
                              setState(() {
                                hasError = true;
                                errorMessage = value.message ?? 'Verification failed';
                                _isVerifying = false;
                              });
                              errorController.add(ErrorAnimationType.shake);
                              showCustomSnackBar(value.message);
                            }
                          }
                          else if(widget.firebaseSession != null && widget.userModel == null) {
                            await verificationController.verifyFirebaseOtp(
                              phoneNumber: _number!, 
                              session: widget.firebaseSession!, 
                              loginType: widget.loginType,
                              otp: verificationController.verificationCode, 
                              token: widget.token, 
                              isForgetPassPage: widget.fromForgetPassword,
                              isSignUpPage: widget.loginType == CentralizeLoginType.otp.name ? false : true,
                            ).then((value) async {
                              if(value.isSuccess) {
                                await _handleVerifyResponse(value, _number, _email);
                              } else {
                                setState(() {
                                  hasError = true;
                                  errorMessage = value.message ?? 'Verification failed';
                                  _isVerifying = false;
                                });
                                showCustomSnackBar(value.message);
                              }
                            });
                          }
                          else if(widget.userModel != null) {
                            widget.userModel!.otp = verificationController.verificationCode;
                            await Get.find<ProfileController>().updateUserInfo(
                              widget.userModel!, 
                              Get.find<AuthController>().getUserToken(), 
                              fromButton: true
                            );
                            setState(() {
                              _isVerifying = false;
                            });
                          }
                          else {
                            await verificationController.verifyToken(
                              phone: _number, 
                              email: _email
                            ).then((value) {
                              if(value.isSuccess) {
                                if(ResponsiveHelper.isDesktop(Get.context!)){
                                  Get.back();
                                  Get.dialog(Center(
                                    child: NewPassScreen(
                                      resetToken: verificationController.verificationCode, 
                                      number: _number, 
                                      email: _email, 
                                      fromPasswordChange: false, 
                                      fromDialog: true
                                    )
                                  ));
                                } else {
                                  Get.toNamed(RouteHelper.getResetPasswordRoute(
                                    phone: _number, 
                                    email: _email, 
                                    token: verificationController.verificationCode, 
                                    page: 'reset-password'
                                  ));
                                }
                              } else {
                                errorController.add(ErrorAnimationType.shake);
                                setState(() {
                                  hasError = true;
                                  errorMessage = value.message ?? '';
                                  _isVerifying = false;
                                });
                                showCustomSnackBar(value.message);
                              }
                            });
                            setState(() {
                              _isVerifying = false;
                            });
                          }
                        } catch (e) {
                          print('Error during verification: $e');
                          
                          await Future.delayed(const Duration(seconds: 1));
                          if(Get.find<AuthController>().isLoggedIn()) {
                            print('User is logged in - navigating directly to home');
                            Get.offAll(() => DashboardScreen(pageIndex: 0));
                          } else {
                            setState(() {
                              hasError = true;
                              errorMessage = 'Something went wrong. Please try again.';
                              _isVerifying = false;
                            });
                          }
                        } finally {
                          // Force reset state regardless of success/failure
                          if (mounted) {
                            setState(() {
                              _isVerifying = false;
                            });
                          }
                          print('Finally block - _isVerifying reset to: $_isVerifying');
                        }
                      },
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerifyResponse(ResponseModel response, String? number, String? email) async {
    print('HANDLE VERIFY RESPONSE: ${response.isSuccess}');
    
    try {
      if(response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
        print('Existing user detected');
        
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
          Get.dialog(Center(
            child: ExistingUserBottomSheet(
              userModel: response.authResponseModel!.isExistUser!, 
              number: _number, 
              email: _email,
              loginType: widget.loginType, 
              otp: Get.find<VerificationController>().verificationCode,
            ),
          ));
        } else {
          Get.bottomSheet(ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, 
            number: _number, 
            email: _email,
            loginType: widget.loginType, 
            otp: Get.find<VerificationController>().verificationCode,
          ));
        }
      } 
      else if(response.authResponseModel != null && !response.authResponseModel!.isPersonalInfo!) {
        print('New user needs setup');
        
        if(ResponsiveHelper.isDesktop(context)) {
          Get.back();
          await Get.dialog(NewUserSetupScreen(
            name: '', 
            loginType: widget.loginType, 
            phone: number, 
            email: email
          ));
        } else {
          await Get.offNamed(RouteHelper.getNewUserSetupScreen(
            name: '', 
            loginType: widget.loginType, 
            phone: number, 
            email: email
          ));
        }
      } 
      else {
        print('Verification successful - navigating to home');
        
        if(widget.fromForgetPassword) {
          await Get.offNamed(RouteHelper.getResetPasswordRoute(
            phone: _number, 
            email: _email, 
            token: Get.find<VerificationController>().verificationCode, 
            page: 'reset-password'
          ));
        } else {
          print('Going directly to home screen');
          
          bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
          print('User login status: $isLoggedIn');
          
          Get.offAll(() => DashboardScreen(pageIndex: 0));
        }
      }
      
      setState(() {
        _isVerifying = false;
      });
      
    } catch (e) {
      print('Error in _handleVerifyResponse: $e');
      
      if(Get.find<AuthController>().isLoggedIn()) {
        print('Force navigating to home');
        await Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
      }
      
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _resendOtp() {
    print('Resending OTP...');
    
    if(widget.userModel != null) {
      Get.find<ProfileController>().updateUserInfo(
        widget.userModel!, 
        Get.find<AuthController>().getUserToken(), 
        fromVerification: true
      );
    } else if(widget.fromSignUp) {
      if(widget.loginType == CentralizeLoginType.otp.name) {
        Get.find<AuthController>().otpLogin(
          phone: _number!, 
          otp: '', 
          loginType: widget.loginType, 
          verified: ''
        ).then((response) {
          if (response.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      } else {
        Get.find<AuthController>().login(
          emailOrPhone: _number != null ? _number! : _email ?? '', 
          password: widget.password!, 
          loginType: widget.loginType,
          fieldType: _number != null ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
        ).then((value) {
          if (value.isSuccess) {
            _startTimer();
            showCustomSnackBar('resend_code_successful'.tr, isError: false);
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    } else {
      Get.find<VerificationController>().forgetPassword(
        phone: _number, 
        email: _email
      ).then((value) {
        if (value.isSuccess) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          showCustomSnackBar(value.message);
        }
      });
    }
  }
}