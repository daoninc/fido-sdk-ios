  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorFace.xcframework.zip",
            checksum: "efd431446bfb273a3ea562462e616eaa644a62e40deb206da35cabd71a7eece5"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "d0cd2fe53a1dce4e1d98f18c7fef356c162c7c43f8bf96061154df2d18b459e9"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "9a0c1f77585117143aa9d0595658b59d6dcc1ceaddb00bc8ec6c176ed196ebc3"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "bc9ba4a8af0c11b76de02a0c780c6443beebc8ba543bd909dcce1459b06f0d03"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "444b8d3298d71d78f216c1fa4299d20e889fba8b783ab9fba1e6d8e5d9a07b9f"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "3859ca6c2d78485f86e8966b8f1bc875bd35a75f32c724e560eee77e9fe2779a"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonCryptoSDK.xcframework.zip",
            checksum: "cf2dbd5e97b9361cc70229c5c36226420d3e3ecdadaae826e8cc2044d04e3bb9"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceCapture.xcframework.zip",
            checksum: "6a90ca6f1504eb34f22f8e64678e74d037d560ec087ce0c8453c5ab323973818"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceDetector.xcframework.zip",
            checksum: "17a1005ba20ef4a32ee2d5d673035cdf5d2624ccb48ad60f0209f7e99fbfe966"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceLiveness.xcframework.zip",
            checksum: "dfb5351801389e2ea85dea50f0bba4cb1f731080b196290f3496e13d890c84c3"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "edee940fac67623fffac9ee1b7db39a76963a9f128ed484a897f116760827bfb"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceMaskDetector.xcframework.zip",
            checksum: "951042088bfeaa9067667e029f874d0f46a2bbb255534ea114694f398448f528"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceMatcher.xcframework.zip",
            checksum: "aedf309d8096adee0d5fbc9a51822e855f83947ab9c1b1882ec4515d5229f61b"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "47c03190d118eb47d43cbb8650dcf07f73aea9431acf16181797855244780288"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceQuality.xcframework.zip",
            checksum: "b3678f961e7a8dce130905a377d7d83c63cd01c0f389eb346b725ea3f403e78d"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFaceSDK.xcframework.zip",
            checksum: "61db4b5972e47d92fd1c9b4fe8aacd8fd7b3a2033dceb14ae374a346e1e3cdcb"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonFIDOSDK.xcframework.zip",
            checksum: "0a654c68909cb05a2720d208829431fc44ca42c614f171822c7d48cdf1e02690"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/DaonService.xcframework.zip",
            checksum: "a150eb7c307ec9c847ebccc708c4287986e25a35fb3572f8e84f7ca801357740"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/IDLiveFaceCamera.xcframework.zip",
            checksum: "18206035d3d7d91a12d0e3d15893345bc96755d6dfc6c99b7e231774a6d30e04"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.266/IDLiveFaceIAD.xcframework.zip",
            checksum: "6a9984aa931032f05038ccdb4e5b25e1f2f089b85720ebdaa46253d6a0843e20"
         ),
    ]
)
