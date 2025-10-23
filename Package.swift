  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorFace.xcframework.zip",
            checksum: "14750d0e0970b6660a5976d672be742a942bb40ae40e1949381d8c5a59855a8b"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "1a1f24af102f544b53ab3517da55cb4442ce52ccd6a55ec80d72498adb3c2259"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "c37545e5dbe23ce85fae7da26ca82a871ed12d1eaf0d32a64b5e29141b590cec"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "4a491c47fc3e02197c6f890290424e952eed85d54c9865872f3098a35aa562b6"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "4124b2751b4efb16fa2b7467c5cd59438148f4226940f23edf48d085f87cffa1"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "540f3580217069672f8362c4ecbd5b3254fba71bb3df2063c12a24502131f179"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonCryptoSDK.xcframework.zip",
            checksum: "f61c16161eddcc177752e87a7ca2d57d3ecf8a69000335440315eb5132bff95a"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceCapture.xcframework.zip",
            checksum: "2a6d6470e9d52b515f7bd2a6e192d94cbbd3037f2ddd2e372906a308edc766a0"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceDetector.xcframework.zip",
            checksum: "dad4dbd63e0b9b57a584922a2855f32dc2c836f9df994188abb3d5df51e237a5"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceLiveness.xcframework.zip",
            checksum: "b9a59bd5c3a110d6d5fec663d561931507d1ed2a554a1a1c5f951a59ca23d09b"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "22f4309ca8465523502a31b07f7dd8f5a11d14f559e49d00cc28a1a8bcca4d0c"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceMaskDetector.xcframework.zip",
            checksum: "58f331423f5ae85fcb77bb239946224b558f4a514a5fc0ca21e88fdaf89f1887"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceMatcher.xcframework.zip",
            checksum: "a129cb9ec677ad818cf014060efffafb12c0ddd508ac07272a2cc83ff8d42da0"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "82e1e857b6d235a430e8895cbc99d213b48ee19d5391579004cbfb2889c8bd78"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceQuality.xcframework.zip",
            checksum: "14602ade3dec124c4e45325096cc306976310936a96f349cb9731f63ef1f3b84"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFaceSDK.xcframework.zip",
            checksum: "e74b6f7bfdfa0335fbc4f7a0c12525f3fdba776eda4a7191fec7a74d7984d2a9"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonFIDOSDK.xcframework.zip",
            checksum: "97de1ad0b6c0279d28695d4bded40a77bee3574650f1821d2b4e5767b81a88d4"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/DaonService.xcframework.zip",
            checksum: "d2a0bad0c79a2df6ff14e349f5ee397577eaff95552063e30b0101d31d815389"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/IDLiveFaceCamera.xcframework.zip",
            checksum: "e913c55cf6696dc133ee0bc466153aa52f6785ca5ef05e1b42f63ae37e5d2b0b"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.235/IDLiveFaceIAD.xcframework.zip",
            checksum: "193cfdf0feade3d72918d3fffc8d24c7974a872ea5dd7f195331f2eafa1c5b7c"
         ),
    ]
)
