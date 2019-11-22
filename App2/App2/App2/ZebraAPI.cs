using System;
using System.Collections.Generic;
using System.Text;

namespace App2
{
    public interface IZebraAPI
    {
        void Init();
        List<string> GetScannerList();
    }
    public class ZebraAPI
    {
        public static IZebraAPI Current;
    }
}
