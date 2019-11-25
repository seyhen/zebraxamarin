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
            SbtSdkApi = (SbtSdkApiWrapper)Zebra.SbtSdkFactory.CreateInstance();
            SbtSdkApi.SbtSetDelegate(new MyDelegate());
            SbtSdkApi.SetOperationalMode(OperationalMode.Mfi);
            
            var bob = SbtSdkApi.EnableAvailableScannersDetection(true);
            
            var availableReaders = new NSMutableArray();
            var availableHandle = availableReaders.Handle;
            
            var n = SbtSdkApi.GetAvailableScannersList(ref availableHandle);

            var scanners = NSArray.ArrayFromHandle<ScannerInfo>(availableHandle);


            var availableReaders2 = new NSMutableArray();
            var availableHandle2 = availableReaders2.Handle;

            var m = SbtSdkApi.GetActiveScannersList(ref availableHandle2);


            var scanners2 = NSArray.ArrayFromHandle<ScannerInfo>(availableHandle2);

            List<string> result = new List<string>();


            SbtSdkApi.EstablishCommunicationSession(0);

            return result;
        }


    }

    public class MyDelegate : SbtSdkApiDelegate
    {
        public override void EventBarcode(string barcodeData, BarcodeType barcodeType, int scannerID)
        {
            throw new NotImplementedException();
        }

        public override void EventBarcodeData(NSData barcodeData, BarcodeType barcodeType, int scannerID)
        {
            Console.WriteLine("Scanned a biiii: ");
        }

        public override void EventCommunicationSessionEstablished(ScannerInfo activeScanner)
        {
            Console.WriteLine("Connected");
        }

        public override void EventCommunicationSessionTerminated(int scannerID)
        {
            Console.WriteLine("Lost connection");
        }

        public override void EventFirmwareUpdate(FirmwareUpdateEvent fwUpdateEventObj)
        {
            throw new NotImplementedException();
        }

        public override void EventImage(NSData imageData, int scannerID)
        {
            throw new NotImplementedException();
        }

        public override void EventScannerAppeared(ScannerInfo availableScanner)
        {
            Console.WriteLine("Found mofo scanner");
        }

        public override void EventScannerDisappeared(int scannerID)
        {
            Console.WriteLine("Lost mofo scanner");
        }

        public override void EventVideo(NSData videoFrame, int scannerID)
        {
            throw new NotImplementedException();
        }
    }
}