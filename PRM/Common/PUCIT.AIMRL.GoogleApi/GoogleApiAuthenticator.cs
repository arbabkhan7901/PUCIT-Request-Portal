using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace PUCIT.AIMRL.GoogleApi
{
    public class GoogleApiAuthenticator
    {
        public static GoogleAccessToken GetAccessToken(String queryStringFromGoogle, String pClientID,String pClientSecret,String pRedirectUrl)
        {
            GoogleAccessToken gAccessToken = null;
            try
            {
                if (queryStringFromGoogle != "")
                {
                    string queryString = queryStringFromGoogle.ToString();
                    char[] delimiterChars = { '=' };
                    string[] words = queryString.Split(delimiterChars);
                    string code = words[1];

                    if (code != null)
                    {
                        //get the access token

                        HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create("https://accounts.google.com/o/oauth2/token");

                        webRequest.Method = "POST";

                        //String Parameters = "code=" + code + "&client_id=" + client_id + "&client_secret=" + client_sceret + "&redirect_uri=" + redirect_url + "&grant_type=authorization_code";
                        String Parameters = String.Format("code={0}&client_id={1}&client_secret={2}&redirect_uri={3}&grant_type=authorization_code",
                            code,
                            pClientID,
                            pClientSecret,
                            pRedirectUrl);

                        byte[] byteArray = Encoding.UTF8.GetBytes(Parameters);

                        webRequest.ContentType = "application/x-www-form-urlencoded";

                        webRequest.ContentLength = byteArray.Length;

                        Stream postStream = webRequest.GetRequestStream();

                        // Add the post data to the web request

                        postStream.Write(byteArray, 0, byteArray.Length);

                        postStream.Close();

                        WebResponse response = webRequest.GetResponse(); // return a response from an internet source

                        postStream = response.GetResponseStream();

                        StreamReader reader = new StreamReader(postStream);

                        string responseFromServer = reader.ReadToEnd();
                        JavaScriptSerializer js = new JavaScriptSerializer();
                        gAccessToken = js.Deserialize<GoogleAccessToken>(responseFromServer);// Deserialize Json
                        //GoogleAccessToken serStatus = JsonConvert.DeserializeObject<GoogleAccessToken>(responseFromServer);

                        //if (gAccessToken != null)
                        //{
                        //    string accessToken = string.Empty;

                        //    accessToken = gAccessToken.access_token;

                        //}//unknown response from google
                    }//unknown code from google
                }//invalid querystring from google
            }
            catch (Exception ex)
            {
                return null;
            }

            return gAccessToken;
        }
        public static GoogleUserOutputData GetUserProfileData(String accessToken)
        {
            GoogleUserOutputData gUserProfile = null;
            try
            {
                if (!string.IsNullOrEmpty(accessToken))
                {
                    HttpClient client = new HttpClient();

                    var urlProfile = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=" + accessToken;
                    client.CancelPendingRequests();
                    HttpResponseMessage output = client.GetAsync(urlProfile).Result;
                    if (output.IsSuccessStatusCode)
                    {
                        string outputData = output.Content.ReadAsStringAsync().Result;
                        //gUserProfile = JsonConvert.DeserializeObject<GoogleUserOutputData>(outputData);
                        JavaScriptSerializer js = new JavaScriptSerializer();
                        gUserProfile = js.Deserialize<GoogleUserOutputData>(outputData);// Deserialize Json

                    }
                }//end of access token if

                return gUserProfile;
            }
            catch (Exception ex)
            {
                return null;
            }

        }
    }

    public class GoogleAccessToken
    {

        public string access_token { get; set; }

        public string token_type { get; set; }

        public int expires_in { get; set; }

        public string id_token { get; set; }

        public string refresh_token { get; set; }

    }
    public class GoogleUserOutputData
    {

        public string id { get; set; }

        public string name { get; set; }

        public string given_name { get; set; }

        public string email { get; set; }

        public string picture { get; set; }

    }
}
