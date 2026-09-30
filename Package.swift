
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "DaonFIDO",
    products: [
        .library(
            name: "DaonFIDOSDK",
            targets: [
                "DaonFIDOSDK",
                "DaonDeviceSignals",
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonAuthenticatorFace.xcframework.zip",
            checksum: "0046800a777e08aa0f7e593a0b628615dc3393cfed3f30d7822b2dddec8b8c37"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "f61e171910cab0a0ef6019a7df8c83a60f7fec67d8f87c494c99fb4354937bc1"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "7ebc11306f413a8989f55e4a2dd74219d392420182c899673f413f01d8084f0a"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "cc2a887296feb5e9294f4a92ae5a986996bf2f912cfacf487aecf220b0f6b63c"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "5d9eaf242a395ec72acd11d8062ca54d5cb51affab542ccd042ded00e1dc8e56"
         ),
         .binaryTarget(
            name: "DaonDeviceSignals",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonDeviceSignals.xcframework.zip",
            checksum: "0249b09c239e06df267fee9c5c75947137f22954db185cb63d91f2c9beb1eb81"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceCapture.xcframework.zip",
            checksum: "0946cc445cd518d5155998e05915aa08b1c52477fe1adcb4b3f50b8f6a587d3c"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceDetector.xcframework.zip",
            checksum: "b303244722d09c075fd1d20dfc3dfa1dede0a8ac22732c77f0d7a84a1c9b3e5b"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceLiveness.xcframework.zip",
            checksum: "f9a28724f6e775c00958ba8962dd4e1ecef1b031428b95fa36594944d1b07056"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "8bc8eea6f199156d17b24bb2487b8fde560eafb702c0736d7c4623ae6a250025"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceMaskDetector.xcframework.zip",
            checksum: "4c45868d3858cc36c40490538d32d71b45de745da49ad71960c04582b542127b"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceMatcher.xcframework.zip",
            checksum: "5113af168f0c231285140e508dae8a1030eee8ed7210626a5ea4f267d7b3cc3f"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "abc192d09b8ab81a56a0d519969cb49f92c8bb671b68636a8da12e9399ac4d94"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceQuality.xcframework.zip",
            checksum: "7cc946b9ba7726678082359d5f6556f071f3a37cde4fbcdee32be67155f71500"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFaceSDK.xcframework.zip",
            checksum: "4c808ef9fc30cd3c2189513b7fa7ac04158926089840c1ba7c436947fab22fdd"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonFIDOSDK.xcframework.zip",
            checksum: "550d557d1c2c28fcb44b7e89db06c4f3ff705ddfdb5af79dcf1c5bfcfd1f87fa"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/DaonService.xcframework.zip",
            checksum: "f8edc0b718c477c5ea8b8d57fd26fadc96cf8532865bb2a21878175a59b500d1"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/IDLiveFaceCamera.xcframework.zip",
            checksum: "4a8f96070a6596ecb9b008bc57420d7e44c20eb729fa8a6c0213977beb0f8c95"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.77/IDLiveFaceIAD.xcframework.zip",
            checksum: "42045527a83610f641c76b439cb7fa8864e6764a9309e8b06137436a23731da7"
         ),
    ]
)
