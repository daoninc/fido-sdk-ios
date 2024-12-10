  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorFace.xcframework.zip",
            checksum: "11d4607fd88f52311c9db1f991ec0fd4d31544bf9bf27f2545a611c04c9e3c84"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "90ed09031e700ace2f189ef75c4c665ce50673f711a664dda7f6303381bf3daa"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "2c9ab34a5b8cd5e86ae60c2e76658204f4a66f42ee3f454621a760c35e392fe0"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "e6b5772dfb0f54517a5f77cf27b89aca620768d9e3ee5a7d9ebca25f41e3713d"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "9bd88907795897117a78eafc2f34fbc4f4ae5fc42ae4dc69d25aca2782fe5f35"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "7f7155f5f146316247ae6325471286b501076bc85680c7f87153aecda9618696"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonCryptoSDK.xcframework.zip",
            checksum: "eb79ca9e2b6d8b148f02891f2d0b9cdc3d9aeec5adc877330c2fe28d42fda435"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFIDOSDK.xcframework.zip",
            checksum: "43807151ffc23d156ba1e7f82024b16692c4346bfa325234476e5539224e7e64"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceCapture.xcframework.zip",
            checksum: "76db41303769b8d18eab75973626a8598f96d8805b43023e69f59318b541c9ab"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceDetector.xcframework.zip",
            checksum: "05a41a3b6b59ddd81e3d50832b1d48b4fdf86ca3076bb8468bd5f9ddbc9c81c5"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceLiveness.xcframework.zip",
            checksum: "b78addbd55d05c796cd7ffbc0468f5d63805b6750b76ca916885b6e88d73637a"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "5e802c95502ba3f011baa422db6042382db608dc45b490362e93253ee6e169bb"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceMaskDetector.xcframework.zip",
            checksum: "50e3c66a24585d18a56500ba1c74f9978d79e53256cee5e1efa4ee1f9cfe1fbb"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceMatcher.xcframework.zip",
            checksum: "856dd81d071de39c5fc644a20833e0364e76db6005024034ef2dee33d706a99b"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "2b9893567fb00a8e5cb449f2f136406867ffb0ad073d35030b03d4ea6ce7fc79"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceQuality.xcframework.zip",
            checksum: "5e608426eb5fb9f2728aea739bbae626023175d755adacd70924408573f233ff"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceSDK.xcframework.zip",
            checksum: "8aab6cc42b1dc8b726af56a00a712ede00d2a771f3700bbb816d907eb4e4dca4"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonService.xcframework.zip",
            checksum: "80ca03ca9c230240cad7b8d8b2c9ef9fb07c8298f510434a0b7feec76ebf25d4"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/IDLiveFaceCamera.xcframework.zip",
            checksum: "e765bcaaa59d9bafac80a95087a1e5dd2b359b9d1d1aa56fcff77c5a0e5c1e29"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/IDLiveFaceIAD.xcframework.zip",
            checksum: "26ff010bce00817b0c88c2959085e4d90f03667a61a7e7ca8f0ba6047ec81d0f"
         ),
    ]
)
