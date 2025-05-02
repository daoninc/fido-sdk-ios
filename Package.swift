  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorFace.xcframework.zip",
            checksum: "39f4b643d90de0df127ea069f6c46fa6fb655cde22ed64d745d126f50be340d4"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "740a9691b8c77a5219dc89fe022a3bd24a36953577e76fd71122058254fd3aa7"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "068773d58b5840ecc09a0b89e7afb04ceac0ee4794f0a55663e6a5862a6c974a"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "364b73a80722c1b8b287281e96307c7d03edf9e607d1f1576e1f5f3fdd32365f"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "8d9bf341b04ef0c1b4e7113e0a83336df660bd7bdc0dde868a22081405665767"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "cb00ac4938f542bc886f3c9319d7899772fd4dc75af85c3ab7724bf94aaae223"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonCryptoSDK.xcframework.zip",
            checksum: "dc2e908c078d9337213423833c63f813c5dc27d0b794fa3a423a3d5bb33999a9"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceCapture.xcframework.zip",
            checksum: "f812c7b3e9594953b82cd6609a40b8b3c994272ec124d92cdb1072aac3d39d26"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceDetector.xcframework.zip",
            checksum: "8e3bb51c1f0d5b2b8df387c97bfbb35be06b17883d8e70ad91401c86c255247c"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceLiveness.xcframework.zip",
            checksum: "be4b22ad03046ddcb36891ab4278f2c8351a68d68dbe07c0ba1173babe226037"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "66e3cb2669deac42c598743b7966e7165795d0705fe54035e7b564a7492eb1fe"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceMaskDetector.xcframework.zip",
            checksum: "295e15cc3063d8e8c0c231635fe01d671cca342ccf72a7967f4eb971cbbb88be"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceMatcher.xcframework.zip",
            checksum: "8f43b1e12543de31af4db25dbd026355dba6478b8494bab34b3eb15ff738880d"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "18960e26067b57d830b054704f2115d020add351c059005cf5a6b8348fcd10a7"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceQuality.xcframework.zip",
            checksum: "c095ba8304ec7850b455fb9c7fa683b3cfcb36c60fe5c03945a9e2e6d96138dd"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFaceSDK.xcframework.zip",
            checksum: "fc76589b33330bd645826bce1ec4f2c73c33e4a85bb0613d8f01c284d3164353"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonFIDOSDK.xcframework.zip",
            checksum: "41cd699d9aaed19afbadc391d86718e9e79b3149509be859a47effebd84e5803"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/DaonService.xcframework.zip",
            checksum: "ff26e8601d8b61cf5b55d36ad7326b102ec6031a3cda5b0e37ee4f8fde7d1921"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/IDLiveFaceCamera.xcframework.zip",
            checksum: "fe84d483dad6e65a3e9e15417a55f5779ed7c9347dad12c93ebf50f8add4036a"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.209/IDLiveFaceIAD.xcframework.zip",
            checksum: "c3343ad1a0494c5599592016484e20b006279a2d3670f621a42aa9a230ea9495"
         ),
    ]
)
