using OnBarcode.Barcode.BarcodeScanner;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Net.Mime;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using ZXing;
using QRCoder;

namespace PUCIT.AIMRL.Common
{
    public static class WinUtility
    {
        public static String WinBasepath = System.IO.Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath);

        public static String GetPhysicalPathByRelativePath(String pRelativePath)
        {
            return Path.Combine(WinBasepath, pRelativePath);
        }
    }

    public static class WebUtility
    {
        public static String GetPhysicalPathByVirtualPath(String pVirtualPath)
        {
            return System.Web.HttpContext.Current.Server.MapPath(VirtualPathUtility.ToAbsolute(pVirtualPath));
        }
    }

    public static class HelperMethods
    {
        public static String ConvertDTToStr(DateTime dt)
        {
            return dt.ToString("dd-MM-yy h:mm:ss tt");
        }

        public static String ConvertOnlyDateToStr(DateTime dt)
        {
            return dt.Date.ToString("dd-MM-yy");
        }

        public static String ChangeDTFormat(DateTime dt)
        {
            return dt.ToString("dd-MM-yy hh:mm tt");
        }

        public static string ChangeDTFormat2(DateTime dt) {
            return dt.ToString("MM-dd-yy hh:mm:ss tt");
        }

        public static String ConvertOnlyTimeToStr(DateTime dt)
        {
            return dt.ToString("hh:mm tt");
        }
    }

    public static class MyDateTimeExtension
    {


        public static String YYYYMMDD(this DateTime dt)
        {
            return dt.ToString("yyyy-MM-dd HH:mm:ss.fff");
        }

        public static DateTime ToTimeZoneTime(this DateTime time, string timeZoneId = "Pakistan Standard Time")
        {
            TimeZoneInfo tzi = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            return time.ToTimeZoneTime(tzi);
        }
        public static DateTime ToTimeZoneTime(this DateTime time, TimeZoneInfo tzi)
        {
            return TimeZoneInfo.ConvertTimeFromUtc(time, tzi);
        }
    }
    public static class PasswordSaltedHashingUtility
    {
        private static byte[] salt = {23,128,56,98,45,76,34,98,114,203,118,23,10,71,178,215};
       
        public static String HashPassword(String Password)
        {
            var pbkdf2 = new Rfc2898DeriveBytes(Password, salt, 10000);
            byte[] hash = pbkdf2.GetBytes(20);
            byte[] hashBytes = new byte[36];
            Array.Copy(salt, 0, hashBytes, 0, 16);
            Array.Copy(hash, 0, hashBytes, 16, 20);
            return Convert.ToBase64String(hashBytes);
        }

    }
    public static class EmailTemplateManager
    {
        public static AlternateView GetLogoAlternateView(String pBodyHtml, List<LinkedResource> linkedResources)
        {
            try
            {
                AlternateView av1 = AlternateView.CreateAlternateViewFromString(pBodyHtml, null, MediaTypeNames.Text.Html);
                foreach (var rsrc in linkedResources)
                {
                    av1.LinkedResources.Add(rsrc);
                }

                return av1;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public static LinkedResource GetLinkedResource(ref String pBodyHtml, String imgPath, String tagName)
        {
            var uniqueId = Guid.NewGuid().ToString();
            LinkedResource logo = new LinkedResource(imgPath);
            logo.ContentId = uniqueId;

            pBodyHtml = pBodyHtml.Replace(tagName, "cid:" + uniqueId);

            return logo;
        }
    }

    public static class BarCodeManager
    {

        public static Bitmap GenerateBarCode(String barcode)
        {

            Bitmap objBitmap = new Bitmap(barcode.Length * 100, 100);
            using (Graphics graphic = Graphics.FromImage(objBitmap))
            {
                Font newFont = new Font("IDAutomationHC39M Free Version", 18, FontStyle.Regular);
                PointF point = new PointF(2, 2);
                SolidBrush balck = new SolidBrush(Color.Black);
                SolidBrush white = new SolidBrush(Color.White);
                graphic.FillRectangle(white, 0, 0, objBitmap.Width, objBitmap.Height);
                graphic.DrawString("*" + barcode + "*", newFont, balck, point);
            }
            using (MemoryStream Mmst = new MemoryStream())
            {
                objBitmap.Save(Mmst, ImageFormat.Png);

            }
            return objBitmap;

        }

        public static String ReadBarCode(String barCodeUpload)
        {
            string strBarCode = string.Empty;
            if (barCodeUpload != null)
            {
                Bitmap bitmap = null;
                try
                {
                    bitmap = new Bitmap(barCodeUpload);
                }
                catch (Exception ex)
                {
                    ex.ToString();
                }
                if (bitmap == null)
                {
                    return "Your file is not an image";
                }
                else
                {
                    String[] barcodes = BarcodeScanner.Scan(barCodeUpload, BarcodeType.Code39);
                    strBarCode = barcodes[0];
                }
            }
            else
            {
                return "Please upload the bar code Image.";
            }
            return strBarCode;
        }

    }


    public static class QRCodeManager
    {

        public static Bitmap GenerateQRCode(String qrcode)
        {
            try
            {
                var barcodeWriter = new BarcodeWriter();
                barcodeWriter.Format = BarcodeFormat.QR_CODE;
                var result = barcodeWriter.Write(qrcode);
                var qrcodeBitmap = new Bitmap(result);

                return qrcodeBitmap;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        public static String ReadQRCode(String qrUpload)
        {
            try
            {
                string strBarCode = string.Empty;
                if (qrUpload != null)
                {
                    Bitmap bitmap = null;

                    try
                    {
                        bitmap = new Bitmap(qrUpload);
                    }
                    catch (Exception ex)
                    {
                        ex.ToString();
                    }
                    if (bitmap == null)
                    {
                        return "Your file is not an image";
                    }
                    else
                    {
                        var barcodeReader = new BarcodeReader();

                        var qrcode = barcodeReader.Decode(bitmap);
                        return qrcode.Text;
                    }
                }
                return "Your file is not an image";
            }
            catch (Exception ex)
            {
                return "";
            }
        }

    }
}
