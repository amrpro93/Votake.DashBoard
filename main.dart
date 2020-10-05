import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_auth/progress_hud.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  bool isLoading = false;
  bool isStart = true;
  var profileData;
  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      isLoading = false;
      isStart=false;
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: const Color(0xFF02BB9F),
        primaryColorDark: const Color(0xFF167F67),
        accentColor: const Color(0xFF02BB9F),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Facebook Login",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () => facebookLogin.isLoggedIn
                  .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
            ),
          ],
        ),
        body: Container(
          child: Center(
            child: isLoggedIn
                ? _displayUserData(profileData)
                : ProgressHUD(
                    child:isStart ? _displayLoginButton(): _displayotherLoginButton(), inAsyncCall: isLoading),
          ),
        ),
      ),
    );
  }

  void initiateFacebookLogin() async {
    setState(() {
      isLoading = true;
    });
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);

        switch (facebookLoginResult.status) {
          case FacebookLoginStatus.error:
            onLoginStatusChanged(false);
            break;
          case FacebookLoginStatus.cancelledByUser:
            onLoginStatusChanged(false);
            break;
          case FacebookLoginStatus.loggedIn:
            var graphResponse = await http.get(
                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');
            var profile = json.decode(graphResponse.body);
            print(profile.toString());
               getToken(profiledata:profile);
       
     
        break;
    }
  }
void getToken( {profiledata}) async{
 
HttpClient client = new HttpClient();
client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

String url ='https://192.168.1.130:5001/api/login/StartLogin?Deviceid=10000000000&pass=db5e8a42-946c-4469-b937-21ab993fbe35';

//Map map = { 
//     "Deviceid" : "10000000000" , 
 //    "pass" : "db5e8a42-946c-4469-b937-21ab993fbe35"
//};
HttpClientRequest request = await client.postUrl(Uri.parse(url));

request.headers.set('content-type', 'application/json');
request.headers.set('pass', 'db5e8a42-946c-4469-b937-21ab993fbe35');
//request.add(utf8.encode(json.encode(map)));

HttpClientResponse response = await request.close();

String token = await response.transform(utf8.decoder).join();

print(token);
print(profiledata['email']);
//String urlcheckEmail ='https://192.168.1.130:5001/api/login/checkEmail?email=${profiledata['email']}';
String urlcheckEmail ='https://192.168.1.130:5001/api/login/checkEmail?email=amrnabih2005@gmail.com';
HttpClientRequest request2 = await client.postUrl(Uri.parse(urlcheckEmail));

request2.headers.set('content-type', 'application/json');
request2.headers.set('Authorization', 'Bearer $token');
request2.headers.set('pass', 'db5e8a42-946c-4469-b937-21ab993fbe35');

//request.add(utf8.encode(json.encode(map)));

HttpClientResponse response2 = await request2.close();

String reReslt = await response2.transform(utf8.decoder).join();
bool result=reReslt== 'true';
print(result);

 onLoginStatusChanged(result, profileData: profiledata);
//final Dio dio=new Dio();
//https://127.0.0.1:5001/
//https://localhost:5001/
//https://192.168.1.130:5001/
//var oDataToken = await http.get('https://192.168.1.130:5001/api/login/StartLogin?Deviceid=10000000000&pass=db5e8a42-946c-4469-b937-21ab993fbe35');
//print(oDataToken.statusCode);
//print(oDataToken.body);
//var datatoken=json.decode(oDataToken.body);
//print(datatoken.toString());
//if (datatoken.statusCode == 200) 
//{
//print(datatoken.toString());
//} 
//else
//{
//print('A network error occurred');
//}

}

  _displayUserData(profileData) {
    return

       Column(
        children: <Widget>[
           Center(
            child:  Container(
              margin: EdgeInsets.only(top: 80.0,bottom: 70.0),
              height: 160.0,
              width: 160.0,
              decoration:  BoxDecoration(
                image:  DecorationImage(
                  image:  NetworkImage(
                    profileData['picture']['data']['url'],),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                    color: Colors.blue, width: 5.0),
                borderRadius:  BorderRadius.all(
                    const Radius.circular(80.0)),
              ),
            ),
          ),
          Text(
            "Wellcome In Votake : ${profileData['name']}",
            style:  TextStyle(
                color: Colors.blue, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          RaisedButton(
      child: Text(
        "Login To Desktop",
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.blue,
      onPressed: () => initiateFacebookLogin(),
    ),

        ],
      );
  }
_displayotherLoginButton(){
 return
        Column(
        children: <Widget>[
           RaisedButton(
      child: Text(
        "Login with Facebook",
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.blue,
      onPressed: () => initiateFacebookLogin(),
    ),
          Text(
            "his is user ${profileData['name']} not Register in Votake Company",
            style:  TextStyle(
                color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),

        ],
      );
}
  _displayLoginButton() {
    return RaisedButton(
      child: Text(
        "Login with Facebook",
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.blue,
      onPressed: () => initiateFacebookLogin(),
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    print("Logged out");
  }
}
