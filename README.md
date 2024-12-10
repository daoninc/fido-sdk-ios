# xAuth FIDO SDK

The FIDO (Fast Identity Online) API is a set of protocols and standards developed to provide a secure and easy-to-use method for user authentication.

## FIDO UAF
FIDO UAF (Universal Authentication Framework) is a set of specifications developed by the FIDO Alliance that provides a secure and easy-to-use authentication framework for online services. It is designed to replace traditional password-based authentication methods with more secure and user-friendly alternatives.

FIDO UAF works by using public key cryptography to authenticate users. When a user wants to authenticate themselves to an online service, their device generates a public-private key pair. The private key is stored securely on the device, while the public key is registered with the online service. When the user wants to authenticate themselves, they simply need to provide a signature using their private key, which can be verified by the online service using the registered public key.

One of the key benefits of FIDO UAF is that it is resistant to phishing attacks, since the user's private key is never transmitted over the network. This means that even if an attacker is able to intercept the authentication request, they will not be able to use the user's private key to authenticate themselves to the service.

FIDO UAF also supports a wide range of authentication methods, including biometrics, PINs, and Passkeys. This allows users to choose the authentication method that works best for them, while still maintaining a high level of security.

## License
The SDK requires a license that is bound to an application identifier. This license may in turn embed licenses that are required for specific authenticators. Contact Daon Support or Sales to request a license.

## Samples

The demo sample includes the following:

- **RelyingParty**: A reference sample Relying Party application.

- **AuthBasicFaceInjectionDetection**: Basic sample application with face authentication using IFP.

- **AuthBasic**: Basic sample application for use with the tutorial.



## API



### Initialize

Initialize a new IXUAF instance using the RPSA server.

```swift


```

See included samples and [xAuth FIDO SDK Documentation](https://developer.identityx-cloud.com/client/fido/ios/) for details and additional information.

### Register 

Register a new authenticator with the FIDO server.

```swift

```

See included samples and [xAuth FIDO SDK Documentation](https://developer.identityx-cloud.com/client/fido/ios/) for details and additional information.

### Authenticate

Authenticate the user with the FIDO server. If a username is provided, a step-up authentication is performed.

```swift

```

See included samples and [xAuth FIDO SDK Documentation](https://developer.identityx-cloud.com/client/fido/ios/) for details and additional information.



