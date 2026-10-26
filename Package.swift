
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonAuthenticatorFace.xcframework.zip",
            checksum: "c59bcc74e8d70dde58a0cdf8b2a60d36d0e9df0714a54b785f60f41524d4c70e"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "417e684041bf2a945d580e50e6ec6a011a794c5160fa7174d7a29e86ee7e9c16"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "4c1633c81e6feefd754d5501656e5c1d83f7ca486290f28fc75b825661c199f2"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "b6ff38e1fa5e55984c976b74efd2bfa7007fa6bce841efc2234661d441f593cb"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "c477783ee37ee54cc7fafc7eb086c4d4da3e31b875cf1e285a3556277f470844"
         ),
         .binaryTarget(
            name: "DaonDeviceSignals",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonDeviceSignals.xcframework.zip",
            checksum: "d1d38caf8897e3733a3c97703b02f8cefa695c2e1b6337826aea26634932a22a"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceCapture.xcframework.zip",
            checksum: "686cf208bf85e721808fde4075f85442795ba707a104323892244a15004dd54d"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceDetector.xcframework.zip",
            checksum: "9bd0284febe078740b6f28f661ec61a10627c8942d8941cbf2d1d079f4d2d07c"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "17f7f30f4f94ba5487161a44c63a355a7d574c12a1c9eaadf3e93db25e34d00a"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceMaskDetector.xcframework.zip",
            checksum: "141fa7f69b497abd22d9ac3d27e4d2c2f95b0f41f3e96409ade3cdf01f2b0af9"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceMatcher.xcframework.zip",
            checksum: "d1c2eb55701c2bb949f5d13e9485e87ef21fbb5f123166abd272d194419decd1"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "2edb9d63f0ed6fc6f7aaac2ce8f5eb8652d3661270bca7f7c8d7a92b21410c45"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceQuality.xcframework.zip",
            checksum: "a07c709a0b8239e217302f89b08e2ae083b62354c61f8337a36dac7f25c1eb53"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFaceSDK.xcframework.zip",
            checksum: "b861d9b3fc947eeb866bbf627f7b1c2c18bba56de62e93f033000348f62963fc"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonFIDOSDK.xcframework.zip",
            checksum: "f368eb31e0b22180d7d26dc0acc2ea31fe9481751a95463b1a87c076cd2b0c74"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/DaonService.xcframework.zip",
            checksum: "9f9ec60d71196cf794a3371e99771034bca771863f533a16c5414714643223ee"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/IDLiveFaceCamera.xcframework.zip",
            checksum: "86494a826496927be157dd4139b99e0bb0e9cc694870b98829e65840ccb7a4db"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.11.4/IDLiveFaceIAD.xcframework.zip",
            checksum: "07958cf4d760aca9a36451bca2d01b248be6f820d1b66184e160bb30c73a38ac"
         ),
    ]
)
