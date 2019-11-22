using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Foundation;
using UIKit;
using Zebra;

namespace App2.iOS.ZebraScanner
{
    public class ZebraScannerConnect : IZebraAPI
    {
        SbtSdkApiWrapper SbtSdkApi;
        public void Init()
        {
            SbtSdkApi = (SbtSdkApiWrapper)Zebra.SbtSdkFactory.CreateInstance();

        }
        public List<string> GetScannerList()
        {
            var m = ScannerExtensions.GetAvailableScanners(SbtSdkApi);
         
            List<string> result = new List<string>();

            return result;
        }


    }
}