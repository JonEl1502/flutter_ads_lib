import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static final ConsentManager instance = ConsentManager._();
  ConsentManager._();

  bool _consentObtained = false;
  bool get consentObtained => _consentObtained;

  /// Request consent info update and show the consent form if required.
  Future<void> requestConsent({bool tagForUnderAgeOfConsent = false}) async {
    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: tagForUnderAgeOfConsent,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _showConsentForm();
        } else {
          _consentObtained = true;
        }
      },
      (error) {
        debugPrint('Consent info update failed: ${error.message}');
        _consentObtained = true; // Allow ads to load even if consent fails
      },
    );
  }

  void _showConsentForm() {
    ConsentForm.loadConsentForm(
      (consentForm) {
        consentForm.show((formError) {
          if (formError != null) {
            debugPrint('Consent form error: ${formError.message}');
          }
          _consentObtained = true;
        });
      },
      (formError) {
        debugPrint('Consent form load error: ${formError.message}');
        _consentObtained = true;
      },
    );
  }

  /// Reset consent state (for testing or GDPR "withdraw consent").
  void reset() {
    ConsentInformation.instance.reset();
    _consentObtained = false;
  }
}
