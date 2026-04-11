import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/images/Logo.png'),
            ),

            Text(
              "Heathos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: 
        SingleChildScrollView(
        child: Row(
        children: [
          // LOGIN FORM
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //WELCOME TEXT
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 1, 211, 193),
                    ),
                  ),
                  //SizedBox(height: 2),

                  //DISPLAY TEXT
                  Text(
                    'Seamless hospital management for smarter, safer and better\n healthcare',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),

                  SizedBox(height: 25),

                  //LOGIN TEXT
                  Text(
                    'Login',
                    style: TextStyle(fontSize: 24, fontFamily: 'Poppins'),
                  ),

                  SizedBox(height: 20),

                  //USERS SELECTION FIELD
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select User Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    items: ['Admin', 'Doctor', 'Staff'].map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 20),

                  //USER ID FIELD
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      //   labelText: 'Password',
                      //   suffixIcon: Icon(Icons.visibility_off),
                      // )
                    ),
                  ),
                  SizedBox(height: 20),

                  //PASSWORD FIELD
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelText: 'Password',
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),
                  SizedBox(height: 20),

                  //LOGIN BUTTON
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 45,
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            1,
                            211,
                            193,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  //HELP ME?
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Divider(thickness: 5.0),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Help Me?',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 1, 211, 193),
                            ),
                          ),
                        ),
                        Divider(thickness: 5.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side: Image

          //PAGE IMAGE ON THE RIGHT SIDE
          Expanded(
            flex: 1,
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                'assets/images/login_image.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ));

    // return Scaffold(
    // appBar: AppBar(
    //   leading: IconButton(
    //     onPressed: () {},
    //     icon: Icon(Icons.arrow_back_outlined, color: Colors.black),
    //   ),
    //   title: Row(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: [
    //       Align(
    //         alignment: Alignment.topLeft,
    //         child: Image.asset('assets/images/Logo.png'),
    //       ),

    //       Text(
    //         "Heathos",
    //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //       ),
    //     ],
    //   ),
    // ),

    //   body: SingleChildScrollView(
    //     child: Padding(
    //       padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
    //       child: Column(
    //         children: [
    //           // SizedBox(height: ),
    //           Row(
    //             children: [
    //               Align(alignment: Alignment.topLeft,
    //               child:
    // Text(
    //   'Welcome',
    //   style: TextStyle(
    //     fontFamily: 'Poppins',
    //     fontSize: 60,
    //     fontWeight: FontWeight.bold,
    //     color: const Color.fromARGB(255, 1, 211, 193),
    //   ),
    //               )),
    //               SizedBox(width: 450),

    //               // BACKGROUND IMAGE
    //               Expanded(
    //         flex: 1,
    //         child: Image.asset('assets/images/login_image.png', fit: BoxFit.cover),
    //       ),
    //               // Container(
    //               //   width: 600,
    //               //   height: 650,
    //               //   child: Image.asset(
    //               //     'assets/images/login_image.png',
    //               //     fit: BoxFit.cover,
    //               //    // color: Colors.black.withOpacity(0.3)
    //               //     //height: double.maxFinite,
    //               //   ),
    //               // ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
