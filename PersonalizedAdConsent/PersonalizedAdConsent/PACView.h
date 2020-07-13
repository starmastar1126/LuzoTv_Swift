//
//  Copyright 2018 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "PACConsentForm.h"

typedef NSString *PACFormKey NS_STRING_ENUM;
static PACFormKey const _Nullable PACFormKeyOfferPersonalized = @"offer_personalized";
static PACFormKey const _Nullable PACFormKeyOfferNonPersonalized = @"offer_non_personalized";
static PACFormKey const _Nullable PACFormKeyOfferAdFree = @"offer_ad_free";
static PACFormKey const _Nullable PACFormKeyAppPrivacyPolicyURLString = @"app_privacy_url";
static PACFormKey const _Nullable PACFormKeyConstentInfo = @"consent_info";
static PACFormKey const _Nullable PACFormKeyAppName = @"app_name";
static PACFormKey const _Nullable PACFormKeyAppIcon = @"app_icon";
static PACFormKey const _Nullable PACFormKeyPlatform = @"plat";

/// Loads and displays the consent form.
@interface PACView : UIView<UIWebViewDelegate>
@property(nonatomic, nullable) PACDismissCompletion dismissCompletion;
@property(nonatomic) BOOL shouldNonPersonalizedAds;
@property(nonatomic) BOOL shouldOfferAdFree;

/// Loads the view with form information and calls the handler on the main queue.
- (void)loadWithFormInformation:(nonnull NSDictionary<PACFormKey, id> *)formInformation
              completionHandler:(nonnull PACLoadCompletion)handler;
@end
