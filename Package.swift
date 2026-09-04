
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonAuthenticatorFace.xcframework.zip",
            checksum: "29cf3b80dfe8bf0f9096ab0adf2cedcc140c37a02710ad7224a738f138c40dfa"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "0e7451fbf3930eb57e315173673765153bc59c4096e66ee2ad283fa0027247d4"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "8cd9bbe5d5197de357d0e437c900a0f98a53bb6826aa767228f0adc0674b83af"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "b84f660a78b4a5aa3ebd86d8d1ba6f9735162e3b47ea6920c98abbd444c5f52e"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "0911fce61a22faea9b280b11a44e8bd3b9c2138ea6bcd3aa5faf7a20a2e9e20e"
         ),
         .binaryTarget(
            name: "DaonDeviceSignals",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonDeviceSignals.xcframework.zip",
            checksum: "1f6ad798f066d9f4c820608d1b6b79445d99df25c88735ee4117946323a5bffe"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceCapture.xcframework.zip",
            checksum: "b2850b35f8ad1171538b39238f133a5024091273943ffa51fd5d372d8e65b1d4"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceDetector.xcframework.zip",
            checksum: "40d88251144b281f4046adf766d92a17d655f9434306c32865e10b943b782009"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceLiveness.xcframework.zip",
            checksum: "11bca328966fae37d6c4d439f72e4949f6cdc0ebdf9d07646899c92e479d7402"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "2bbb750c6953733dbe2be90060fe693b0492187d911b88e88ddf7600d867fa2f"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceMaskDetector.xcframework.zip",
            checksum: "7bf165eb554bd26b3288ec9d75f6a541f49dc0cf218ee0b803d7645d6a613f4c"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceMatcher.xcframework.zip",
            checksum: "a5061fd321f640c32a9d41bbbb07f1de8540336aa00a817a3993bef7ef487d16"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "849ee527715fa48599910ee7b0e018038e4b43ffdf77b343c3c41452eadc8ff9"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceQuality.xcframework.zip",
            checksum: "b65cf1d80c92b8951d68aa195492253156ef4d581ee72585e75f1b1c72271219"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFaceSDK.xcframework.zip",
            checksum: "417422816d37e8081ed73880931f19e80d981a947b0547ad4dcd2dd987ddb4dd"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonFIDOSDK.xcframework.zip",
            checksum: "58a9c4d21e0766bf9e77384e949dd6c33ae86e0bf8e46299aae369d106dc1a75"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/DaonService.xcframework.zip",
            checksum: "991c0203013b8f3e4c74b7887821c9e937ac4d0dc3e161855295d0a1a5c3df3e"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/IDLiveFaceCamera.xcframework.zip",
            checksum: "427d3e7b762eef54e88527c801a3dc82c92a1d31d321b8414c09cc25408f8af5"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.10.46/IDLiveFaceIAD.xcframework.zip",
            checksum: "ebebdf5f510473c9f66c2b36b28abca210840ab2d5fb4eca8802f353920f91fb"
         ),
    ]
)
