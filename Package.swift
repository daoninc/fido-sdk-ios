  
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
            name: "DaonAuthenticatorFace",
            targets: [
                "DaonAuthenticatorFace", 
                "DaonFaceSDK",
                "DaonFaceQuality"
            ]
        ),
        .library(
            name: "DaonAuthenticatorFaceLiveness",
            targets: [
                "DaonAuthenticatorFace",
                "DaonFaceSDK", 
                "DaonFaceQuality",
                "DaonFaceLiveness"
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
                        checksum: "0320f25fc70ea6d0e4b0ffbb5c4854222170b9158e0c0d6b15ac5b1049a3bf4f"
                    ),
          .binaryTarget(
                        name: "DaonAuthenticatorFaceIFP",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorFaceIFP.xcframework.zip",
                        checksum: "cbeb43fb42ce41498efbfe6ed8d3369a3096050e8b7e03b46b8ccb9bd6f3533c"
                    ),
          .binaryTarget(
                        name: "DaonAuthenticatorFaceV3Support",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorFaceV3Support.xcframework.zip",
                        checksum: "cd6f957cb9e31fcd7952db8e8790aaa4a3664e6e0dbef288e5bdbea5e6eca3ac"
                    ),
          .binaryTarget(
                        name: "DaonAuthenticatorPasscode",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorPasscode.xcframework.zip",
                        checksum: "0a00def8d0f08bbef5a6742b0a8774e9d8c5230ecfab4c4aff4db4b636ba2f45"
                    ),
          .binaryTarget(
                        name: "DaonAuthenticatorSDK",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorSDK.xcframework.zip",
                        checksum: "90f0eaad5ff32192a9db6eb7ee9dcc317020a4fd71d9ff59df538c695761608d"
                    ),
          .binaryTarget(
                        name: "DaonAuthenticatorVoice",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonAuthenticatorVoice.xcframework.zip",
                        checksum: "dda00375a703a97b62e03e1f0d5bb3d8d40065bdd2b6798623de21216e577608"
                    ),
          .binaryTarget(
                        name: "DaonCryptoSDK",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonCryptoSDK.xcframework.zip",
                        checksum: "80d11cfd9f0213df6e4c06387fc52a1f6877446fe5e25932b8337cdfa8abc43d"
                    ),
          .binaryTarget(
                        name: "DaonFIDOSDK",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFIDOSDK.xcframework.zip",
                        checksum: "ad53abd22dce5a9f38266a9c64ab7b831bcc38341e77cd7ec0a1f7036ea54a1e"
                    ),
          .binaryTarget(
                        name: "DaonFaceCapture",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceCapture.xcframework.zip",
                        checksum: "a69e9681371d40e74688425cc9184fd8be5c9b87fc3e6b6894639696cf16d8d1"
                    ),
          .binaryTarget(
                        name: "DaonFaceDetector",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceDetector.xcframework.zip",
                        checksum: "ce56d462ff4d0c6261f5dcd3cb9f45e3c4f6a5d64567e8cf5faaacff54c92884"
                    ),
          .binaryTarget(
                        name: "DaonFaceLiveness",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceLiveness.xcframework.zip",
                        checksum: "9f96038be6dd0314b10f5fd81d0f96d11194ae6d34b2e111bcaddd7850536e9d"
                    ),
          .binaryTarget(
                        name: "DaonFaceLivenessBlink",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceLivenessBlink.xcframework.zip",
                        checksum: "0ca779955038c33ec70649cd899e6dae7e6ca40301d2d6efc5f84cd7b64fd1ca"
                    ),
          .binaryTarget(
                        name: "DaonFaceMaskDetector",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceMaskDetector.xcframework.zip",
                        checksum: "3ac5ee892b94954e9bb0c034c039d96f82f1262ba47e9ace7db5bba58724a9c7"
                    ),
          .binaryTarget(
                        name: "DaonFaceMatcher",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceMatcher.xcframework.zip",
                        checksum: "c7e9118e1870a97c4b7ad0e1b0ab55e6ed22f1500642633e9562c7c0456db89a"
                    ),
          .binaryTarget(
                        name: "DaonFacePassiveLiveness",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFacePassiveLiveness.xcframework.zip",
                        checksum: "ad3148ff8a350897e33415c27531693da754661747139105c26dc74bc9e9f778"
                    ),
          .binaryTarget(
                        name: "DaonFaceQuality",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceQuality.xcframework.zip",
                        checksum: "3986d7e1752a61fc63b93170d8a4760070d6669d04f5aa6b74ddc9cb02b36e46"
                    ),
          .binaryTarget(
                        name: "DaonFaceSDK",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonFaceSDK.xcframework.zip",
                        checksum: "5878090fa9b50f311294dadfda0b1781c5b191746cf5d82dadd0c1f457086b3d"
                    ),
          .binaryTarget(
                        name: "DaonService",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/DaonService.xcframework.zip",
                        checksum: "711b557ce0902a008819861e70453d79e0dc86a8bb7afc51c4c12a5389a3205e"
                    ),
          .binaryTarget(
                        name: "IDLiveFaceCamera",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/IDLiveFaceCamera.xcframework.zip",
                        checksum: "f6744184a7243e8347da30855009ae9ec08b23a409fcaec510a5762429a3f576"
                    ),
          .binaryTarget(
                        name: "IDLiveFaceIAD",
                        url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.8.137/IDLiveFaceIAD.xcframework.zip",
                        checksum: "f0dce9c5d78bed6814cf7d28868d9b7edbfcfc6d2b8e73cd20d9b3e9c0124b91"
                    ),
  ]
)
