  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorFace.xcframework.zip",
            checksum: "8b7acddcd863f89cd3f3c58a7ff907d76585ed5d6ffb9c820414713c732ef121"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "140f3cbb8ff65a9bd6256b32fb7f685b1a99a5ba9af104cec77ab1d0fdc12091"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "3c39ba8525ca0e4cf2a845f575f00c3fe1d6b29cb695080ed93e72770baf179c"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "e9680ba3538f3402b29c2467dfe646f5d19d63aec5fe0f1e137df86a29658158"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "9c5e5e94c6985a6b93682cfa840c94b43070e00ce9c58188edd75feea71670ce"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "3cbc9eae1e282cfdeb337e1b5cbabb43b7eba97ed3b2d80a3248a8708072398a"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonCryptoSDK.xcframework.zip",
            checksum: "46b7af75e6e3884b0a807ed29ab8f002efde4328ff2ea7a2b5b3b54448f87288"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFIDOSDK.xcframework.zip",
            checksum: "8aff6ddf32c5e342d6d0d44a828ef5da9670223ad8b837e8d75533575dae6e8f"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceCapture.xcframework.zip",
            checksum: "d75d2c071ebfe17fed9dcdb5cedece28613796882c1a7571c8254ebee99991b6"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceDetector.xcframework.zip",
            checksum: "b2bfef5f133c0f315ce9d0abf524ad8cb69134d389e70e5394510ff7959f9c6f"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceLiveness.xcframework.zip",
            checksum: "9ad9b4b7bd06196d91d4575e47d8bed62ecd735ed7c7e61ebee0588168b3ca98"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "2ad67c3ea3644703f8e047c51fa4704402f326a5f4cb2be2fe50b2e039000bcf"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceMaskDetector.xcframework.zip",
            checksum: "b54d826f3a5131710ab18b6b4da6695b10c29f85496cce69291328a28e870716"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceMatcher.xcframework.zip",
            checksum: "7302de5ec1bb0915d77b47f9a066878fef750b1f9c70edffeaf5f8af7b2ed1c5"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "ac5a680224268868b55b11594e950cfc5416e9ee72cf6aedb1ffe0698d64638e"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceQuality.xcframework.zip",
            checksum: "159b99e58880cdba0d76a1224ce761783d886030f5db70d77d49fe93a2df8889"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonFaceSDK.xcframework.zip",
            checksum: "0c157cc36fb5f14dd61e61c7ef49e3b6c52bddbf5e8a267f1d0d3e60baa80ebf"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/DaonService.xcframework.zip",
            checksum: "e3a8a946caba46a2e34137e3c3e11f6d2c3a80bd047487b3f9755cc903ed0dfd"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/IDLiveFaceCamera.xcframework.zip",
            checksum: "4cf7a0d215c4d98747bb4e3c22d9a29952902d99d729cc4bd748c41883705d05"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.177/IDLiveFaceIAD.xcframework.zip",
            checksum: "b5dde2b5027e79a7256f93017450c289db1dce2c2ec8e7328f2754d1e37fed19"
         ),
    ]
)
