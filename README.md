# Wacom Ink SDK for signature - iOS

## Introduction

---

The *Wacom Ink SDK for signature* is an iOS framework that allows an iPad app to capture detailed signature data when used in combination with a Wacom Creative Stylus.
As well as providing the mechanisms for signature capture, the SDK includes:

* Integrity verification of saved signature data since capture
* Binding of signature data to a specific document hash implicitly linking the signature to the document data
* Signature data export in binary, base-64 encoded text and steganographic encoded PNG images
* High quality PNG, JPG and UIImage export of captured signature data


The Wacom Ink SDK for signature supports iOS 10 or newer using Xcode 8.0 or above.
The framework is compiled for x86_64, arm7 and arm64 architectures.

## Overview

The simplest way to capture a signature using the SDK is as follows:

~~~Objective-C
 @try {
     NSError *licenseError;
     [[LicenseValidator sharedInstance] initLicense:license error&err]; //Load license, where 'license' is your license string
     
     if(err == NULL) {
        SignatureCapture *sc = [[SignatureCapture alloc] initWithDelegate:self];
        [sc openCaptureWindowWithSignatory:@"Who" andReason:@"Why" boundToData:nil];    
     } else {
         //display license error
     }
 } @catch (NSException *e) {
     //Process generic licensing error
 }
~~~

This code will produce a signature capture window with the signatory defined as 'Who' and a reason string of 'Why'.
Once the signature capture is complete, the SDK calls the relevant delegate method on the view controller.

Licensing
---------

The Wacom Ink SDK for signature uses the standard Wacom License System provided by the WacomLicensing framework.
License keys (both evaluation and production) can be obtained from the Wacom Developer site at http://developer.wacom.com or from your Wacom account manager.


Basic Usage
-----------

The Wacom Ink SDK for signature for iOS has three main classes: SignatureCapture, SigningView and SignatureObject.

Before you call any of the SDK classes, you will need to load your license into the Wacom License System using the `LicenseValidator` class (see 'Licensing' above).
If there are any issues with the license, the validator will return the error state to the NSError object, or throw an exception.
If you try to use the SDK without loading a license into the validator, or with an invalid license loaded into the validator, then an exception will be thrown.

The SignatureCapture class presents the end user with the signature capture window.
It allows you to define various options related to signature data (e.g. signatory, signature hash type etc.) as well as presentation options such as the ink colour to use when rendering the signature.
The SignatureCapture header contains the SignatureCaptureDelegate protocol definition that needs to be implemented by the delegate view controller.
This protocol communicates the final status of a signature capture session, along with any captured signature data to the presenting view controller.

The SignatureObject encapsulates the captured signature data, either from a SignatureCapture object or data loaded from a saved signature file.
The SignatureObject contains the signature integrity, validation and export methods.
This allows the app to check that a signature remains unmodified since capture, and allows the facility to verify the signature against a specific document using the 'checkSignatureData:withData' method against an NSData object containing the document source.

The basic steps required to implement signature capture within an app are:

* Load license into the LicenseValidator singleton 
* Implement the 'SignatureCapatureDelegate' within your presenting view controller
* Instantiate a 'SignatureCapture' object with the appropriate delegate
* Call 'openCaptureWindowWithSignatory:andReason:boundToData:' to start the capture session

Once the session has completed, the SDK will call one of the following delegate methods:

~~~Objective-C
- (void)signatureCapture:(SignatureCapture *)captureView completedWithSignature:(SignatureObject *)signature;
- (void)signatureCapture:(SignatureCapture *)captureView cancelledWithReason:(SIGNATURE_CANCEL_REASON)reason;
~~~

If the capture session was successful, then the 'signatureCapture:completedWithSignature' method is called with a newly created SignatureObject that contains the captured data.
If the session was unsuccessful, then the 'signatureCapture:cancelledWithReason' method is called with one of the following reasons:

~~~Objective-C
typedef NS_ENUM(NSUInteger, SIGNATURE_CANCEL_REASON)  {
    USER_CANCELLED, // The user tapped the close button on the capture window
    NO_SIGNATURE_DATA_CAPTURED, // No signature data was captured.
    CAPTURE_ABORTED,  // An error occurred caused the capture window to be closed
};
~~~

Below is an example of a basic implementation of the SDK.
This code assumes a 'license.lic' file exists in the application bundle.
The code between the ellipses would form part of an open capture session action of the calling view controller:

~~~Objective-C
...

NSString *licPath = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"lic"];
NSString *license = [NSString stringWithContentsOfFile:licPath encoding:NSUTF8StringEncoding error:NULL];

//Load license
@try {
    NSError *licenseError;
    [[LicenseValidator sharedInstance] initLicense:license error&err]; //Load license, where 'license' is your license string
    if(LicenseError != NULL) {
        //Process license error
    }
} @catch(NSException *e) {
    //Process generic license exception
}


//Create Signature Capture Screen
SignatureCapture *sc = [[SignatureCapture alloc] initWithDelegate:self];
[sc openCaptureWindowWithSignatory:@"Who" andReason:@"Why" boundToData:nil];

...

- (void)signatureCapture:(SignatureCapture *)captureView 
  completedWithSignature:(SignatureObject *)signature {
    //TODO: Handle signature data within signature
}

- (void)signatureCapture:(SignatureCapture *)captureView 
     cancelledWithReason:(SIGNATURE_CANCEL_REASON)reason {
    //TODO: Handle error situation based on reason
}
~~~


Block Support
-------------

In addition to the delegate style callback, the Wacom Ink SDK for signature now has support for blocks to allow in-line processing of signature data.
To capture a signature using blocks, you will need to create a signature capture object, then call the 'openCaptureWindowWithSignatory:andReason:boundToData:fromController:successfulCaptureHandler:cancelHandler:' to capture a signature:

~~~Objective-C
... (this sample assumes it is being called from within a UIViewController, and that the license has been loaded)

//Create Signature Capture Screen
SignatureCapture *sc = [[SignatureCapture alloc] init];

//Open the capture window with blocks
[sc openCaptureWindowWithSignatory:@"Who"
	 				     andReason:@"Why"
					   boundToData:nil 
					fromController:self 
					successfulCaptureHandler:^(SignatureObject *signatureData) {
                        //Process signature data object
                    } cancelHandler:^(SIGNATURE_CANCEL_REASON cancelReason) {
						//Handle error condition
       			    }];
~~~

In Place Signing
----------------

If you wish to customise the capture window, the SDK has support for 'in place signing'.
This supplies a transparent UIView derived SigningView class that allows signature data to be collected.
The current signature data rendered within the SigningView class can be retrieved by calling the 'currentSignatureData' method on the SigningView, e.g.:

~~~Objective-C
@property (strong, nonatomic) IBOutlet SigningView *signingView;

...

SignatureObject *signatureData = [self.signingView currentSignatureData];
~~~

A working example of this can be found in the Objective C samples directory named 'InPlaceSigning'.

API Documentation
-----------------

Full class documentation in HTML format is in the 'Documentation' directory of the SDK distribution package.


    
## GitHub Samples

Sample code is included to help get started with the SDK.

---

# Additional resources 

## Sample Code
For further samples check Wacom's Developer additional samples, see [https://github.com/Wacom-Developer](https://github.com/Wacom-Developer)

## Documentation
For further details on using the SDK see [Wacom Ink SDK for signature documentation](http://developer-docs.wacom.com/sdk-for-signature/) 

The API Reference is available directly in the downloaded SDK.

## Support
If you experience issues with the technology components, please see the related [FAQs](https://developer-support.wacom.com/hc/en-us)

For further support file a ticket in our **Developer Support Portal** described here: [Request Support](https://developer-support.wacom.com/hc/en-us/requests/new)

## Developer Community 
Join our developer community:

- [LinkedIn - Wacom for Developers](https://www.linkedin.com/company/wacom-for-developers/)
- [Twitter - Wacom for Developers](https://twitter.com/Wacomdevelopers)

## License 
This sample code is licensed under the [MIT License](https://choosealicense.com/licenses/mit/)

---
