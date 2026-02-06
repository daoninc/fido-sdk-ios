  
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "DaonFIDO",
    products: [
        .library(
            name: "DaonFIDOSDK",
            targets: [
                "DaonFIDOSDK",
                "DaonCryptoSDK", 
                "DaonAuthenticatorSDK"
            ]
        ),
        .library(
            name: "DaonService",
            targets: [
                "DaonService"
            ]
        ),
        .library(
            name: "DaonAuthenticatorFace",
            targets: [
                "DaonAuthenticatorFace", 
                "DaonFaceSDK",
                "DaonFaceQuality"
            ]
        ),
        .library(
            name: "DaonAuthenticatorFaceIFP",
            targets: [
                "DaonAuthenticatorFaceIFP",
                "DaonFaceCapture", 
                "DaonFaceSDK",
                "DaonFaceQuality",
                "IDLiveFaceCamera",
                "IDLiveFaceIAD"
            ]
        ),
        .library(
            name: "DaonAuthenticatorVoice",
            targets: [
                "DaonAuthenticatorVoice"
            ]
        ),
        .library(
            name: "DaonAuthenticatorPasscode",
            targets: [
                "DaonAuthenticatorPasscode"
            ]
        ),
        .library(
            name: "DaonFaceLiveness",
            targets: [
                "DaonFaceLiveness",
                "DaonFaceSDK"
            ]
        ),
        .library(
            name: "DaonFaceLivenessBlink",
            targets: [
                "DaonFaceLivenessBlink",
                "DaonFaceSDK"
            ]
        ),
        .library(
            name: "DaonFaceMaskDetector",
            targets: [
                "DaonFaceMaskDetector",
                "DaonFaceSDK"
            ]
        ),
        .library(
            name: "DaonFaceMatcher",
            targets: [
                "DaonFaceMatcher",
                "DaonFaceDetector",
                "DaonFaceSDK"
            ]
        ),
        .library(
            name: "DaonFacePassiveLiveness",
            targets: [
                "DaonFacePassiveLiveness",
                "DaonFaceMatcher",
                "DaonFaceDetector",
                "DaonFaceQuality",
                "DaonFaceSDK"
            ]
        ),                    
    ],
    targets: [
         .binaryTarget(
            name: "DaonAuthenticatorFace",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorFace.xcframework.zip",
            checksum: "dd36143bb3a905020574d7a672be2823ad218701b9a1343f448b94c98813b3cd"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "471cd530af376bab3acfa867e9764e46e4b24b17c6b8b667d2bde223fe8d1cdf"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "de6986104aaa90bfb73d9060e421d3e0542917ea3d41b691f5c40592711712ce"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "26ce3845a7f338971705880c54a0b1e01a1ccad63ac56e1fb2ec5bd49b0ce8aa"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "2e64472e70535eed832a6c82d34010880b1ab4f0bb88e30a8a11c258402fa70e"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "14a5e0512bae08f9c3bf81da53102af3b4776cb185d52dc7584d057fa0928c56"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonCryptoSDK.xcframework.zip",
            checksum: "559f420c6e78c20c0e4b5bcaa9a9cce5c3f7cb02d98be084afd4b3b6ddbaad03"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceCapture.xcframework.zip",
            checksum: "fca549c510b203e66dee937e1d3e132159857727ca5de52b2c8c40648091d203"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceDetector.xcframework.zip",
            checksum: "199cea53995f7987daa8b492a84fe525112bb101819fdb238b836efc5ea88969"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceLiveness.xcframework.zip",
            checksum: "960424cafb2e81367503d63d03de68448293e84fdabf1a19306ea6ad3bacb965"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "e3010361e9f15d273c6bfcce356b4e58455883fad0ff5697c43d04c3ee241d67"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceMaskDetector.xcframework.zip",
            checksum: "154a244a4ed21a5a0c3fe26277e2549e0c1de6c1f13397d95099596ce2211074"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceMatcher.xcframework.zip",
            checksum: "4bba22bb96b85e1dbcb9abfe45f347ec7557384263dd2cd7c8ee93e948d3adcb"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "3b67aae337aa96cfb1e0115d05a133a12c938968d01be3677207182802382294"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceQuality.xcframework.zip",
            checksum: "f9cdbd89f04a08080a4c81de3e7a920f80a2acd19f644fb4b0f24985b0f507d5"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFaceSDK.xcframework.zip",
            checksum: "3cb26d90f863fda814264921000d8e92bafe34ad61194ff46a49ce568ea1a6a7"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonFIDOSDK.xcframework.zip",
            checksum: "a8c30696115aee73b96e9b594029bf544216a6827b2218c491dbdb7694adf6ee"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/DaonService.xcframework.zip",
            checksum: "7b76202e13ebd55898dfd842f568543788d0d4a6788c3e683767e67f531ba443"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/IDLiveFaceCamera.xcframework.zip",
            checksum: "14810e3a3a1fc46dcb03b7d9e1ae25dd161a7387c980a39f3cdf7e1b5764d353"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.260/IDLiveFaceIAD.xcframework.zip",
            checksum: "1c7b41a16e846f849c31f589025e69a3f9acf1a46c4814c09f709bf3a239d162"
         ),
    ]
)
