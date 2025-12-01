  
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
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorFace.xcframework.zip",
            checksum: "f79d5c20731bce6196ff9efd5f035c210f0852546dd3d8c38266a6212b18fb3e"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceIFP",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorFaceIFP.xcframework.zip",
            checksum: "f66a0ea24534f2559fb6a2d8f1461d7fc7430716f08c8bbd338d88cf032dec68"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorFaceV3Support",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorFaceV3Support.xcframework.zip",
            checksum: "3219c0e62437e11a0634bb8a1a12b720e7ecf16dae3d39d7513f4b6f3e97ef15"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorPasscode",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorPasscode.xcframework.zip",
            checksum: "a81af57beb535c4a54dd1846dda6925031a3a5330b0387f8628b26f386c09c63"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorSDK.xcframework.zip",
            checksum: "9ccb996eaa7f5786f60878d317cf47607c2b19de08e326e3dbff444793da356e"
         ),
         .binaryTarget(
            name: "DaonAuthenticatorVoice",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonAuthenticatorVoice.xcframework.zip",
            checksum: "7f1102e2a6191bf1a513811cff0ca2c154a6b5149bdeca47d402290653bf4bde"
         ),
         .binaryTarget(
            name: "DaonCryptoSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonCryptoSDK.xcframework.zip",
            checksum: "4e6e69ec4e7ebfcfcbc2089484d34dd438cbb563cca3fe69d6b221e90760d479"
         ),
         .binaryTarget(
            name: "DaonFaceCapture",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceCapture.xcframework.zip",
            checksum: "26ae0ad6e756cc4c93c277be513a6d6a515363b648e93c8866b30c94df821a79"
         ),
         .binaryTarget(
            name: "DaonFaceDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceDetector.xcframework.zip",
            checksum: "adf6a41169c52d191181cfe6c817d768f77b562c0916657e12593d32df2ca396"
         ),
         .binaryTarget(
            name: "DaonFaceLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceLiveness.xcframework.zip",
            checksum: "ca138a7befed163822cd4cd5988e3f492510e8dd811158a789e4f6929ce10663"
         ),
         .binaryTarget(
            name: "DaonFaceLivenessBlink",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceLivenessBlink.xcframework.zip",
            checksum: "9360b7bcce7667543a76a504dcd92866587f528c8d176ef2ad708be318f3558e"
         ),
         .binaryTarget(
            name: "DaonFaceMaskDetector",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceMaskDetector.xcframework.zip",
            checksum: "157f2a564301eb48c26659383329fd6934b560d07837ee3dcb196ba10a5103b0"
         ),
         .binaryTarget(
            name: "DaonFaceMatcher",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceMatcher.xcframework.zip",
            checksum: "21d2d5c80125457b607e6ea6e9b05dea02ffac7e9aa8b93a0bffe4ca655720d4"
         ),
         .binaryTarget(
            name: "DaonFacePassiveLiveness",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFacePassiveLiveness.xcframework.zip",
            checksum: "cd8016ff333fd93e01b5ac901d7273f1bccd24aa111499ddb5af908a266e3601"
         ),
         .binaryTarget(
            name: "DaonFaceQuality",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceQuality.xcframework.zip",
            checksum: "ec94a31c74d8c6917e29fde9bdbe90204e8b26bdc623e8bc8521136b1a309f87"
         ),
         .binaryTarget(
            name: "DaonFaceSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFaceSDK.xcframework.zip",
            checksum: "4e7911f007f3aaacfb060e1633dc8de43aee34e512e19457d621241f6dd7f98e"
         ),
         .binaryTarget(
            name: "DaonFIDOSDK",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonFIDOSDK.xcframework.zip",
            checksum: "744c4cd7877cf5d9464d97ff06b5899534285ec0e099651b8f769f3c51843a85"
         ),
         .binaryTarget(
            name: "DaonService",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/DaonService.xcframework.zip",
            checksum: "dbf86b6299c7f08ce0ca715c2955cf9438a18f4bb24a0a7f0dfa10455f8801f1"
         ),
         .binaryTarget(
            name: "IDLiveFaceCamera",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/IDLiveFaceCamera.xcframework.zip",
            checksum: "1f3c1dce7a2896dc9208c3d5c3684646dc806068bc42e0370367f0c99c148cb3"
         ),
         .binaryTarget(
            name: "IDLiveFaceIAD",
            url: "https://github.com/daoninc/fido-sdk-ios/releases/download/4.9.244/IDLiveFaceIAD.xcframework.zip",
            checksum: "58ca912b2d6f441496fd9397f9430852edf67d4bc3adfc165e8e427f0c74c798"
         ),
    ]
)
