using System;
using System.Collections.Generic;
using System.Linq;

using Foundation;
using UIKit;
using Zebra;

namespace App2.iOS
{
    // The UIApplicationDelegate for the application. This class is responsible for launching the 
    // User Interface of the application, as well as listening (and optionally responding) to 
    // application events from iOS.
    [Register("AppDelegate")]
    public partial class AppDelegate : global::Xamarin.Forms.Platform.iOS.FormsApplicationDelegate
    {
        //
        // This method is invoked when the application has loaded and is ready to run. In this 
        // method you should instantiate the window, load the UI into it and then make the window
        // visible.
        //
        // You have 17 seconds to return from this method, or iOS will terminate your application.
        //
        private (SbtResult, ScannerInfo[]) getScanners(Func<IntPtr, (SbtResult, IntPtr)> action)
        {
            var availableReaders = new NSMutableArray();
            var availableHandle = availableReaders.Handle;

            (SbtResult result, IntPtr handle) = action(availableHandle);

            var scanners = NSArray.ArrayFromHandle<ScannerInfo>(handle);

            return (result, scanners);
        }

        public override bool FinishedLaunching(UIApplication app, NSDictionary options)
        {
            global::Xamarin.Forms.Forms.Init();
            LoadApplication(new App());

            System.IntPtr test = default(System.IntPtr);

            SbtSdkApiWrapper t = (SbtSdkApiWrapper)Zebra.SbtSdkFactory.CreateInstance();
            var i = t.EnableAvailableScannersDetection(true);
            var m = getScanners(() => t.GetAvailableScannersList);
            var p = t.GetActiveScannersList(ref test);


            return base.FinishedLaunching(app, options);
        }
    }
}
