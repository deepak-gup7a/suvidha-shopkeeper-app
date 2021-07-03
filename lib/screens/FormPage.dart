import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suvidha_shopkeeper/database/shopkeeper_database.dart';
import 'package:suvidha_shopkeeper/models/constants.dart';
import 'package:suvidha_shopkeeper/models/shopkeeper.dart';

class FormPage extends StatefulWidget {
  Shopkeeper shopkeeper = Shopkeeper();
  FormPage({this.shopkeeper});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  Shopkeeper tempShopkeeper = Shopkeeper();

  final _formKey = GlobalKey<FormState>();

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;



  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
  String shopAddress;
  String shoplang;
  String shoplat;
  bool addThisLocation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    tempShopkeeper = widget.shopkeeper;
    shopAddress = tempShopkeeper.address.split('~')[0];
    shoplang = tempShopkeeper.address.split('~')[1];
    shoplat = tempShopkeeper.address.split('~')[2];

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(children: [
                Text(
                  'Update Shop Info:',
                  style: TextStyle(
                      fontFamily: "ReggaeOne",
                      fontWeight: FontWeight.w900,
                      fontSize: 25.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Divider(
                    color: Colors.teal[500],
                    height: 10,
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (val) {
                    if (val.isEmpty) return "please enter a valid shop name";
                    return null;
                  },
                  initialValue: widget.shopkeeper.shopName != null
                      ? widget.shopkeeper.shopName
                      : 'Shop Name',
                  decoration: textInputDecoration.copyWith(
                    // hintText: 'Shop Name',
                    labelText: 'Shop Name',
                  ),
                  onChanged: (val) {
                    setState(() {
                      tempShopkeeper.shopName = val;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (val) {
                    if (val.isEmpty) return "please enter your valid Name";
                    return null;
                  },
                  initialValue: widget.shopkeeper.shopkeeperName != null
                      ? widget.shopkeeper.shopkeeperName
                      : 'Your Name',
                  decoration: textInputDecoration.copyWith(
                    // hintText: 'Shop Name',
                    labelText: 'Your Name',
                  ),
                  onChanged: (val) {
                    setState(() {
                      tempShopkeeper.shopkeeperName = val;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (val) {
                    if (val.isEmpty) return "please enter a valid shop address";
                    return null;
                  },
                  //enabled: false,
                  initialValue: shopAddress != null
                      ? shopAddress
                      : 'Address',
                  decoration: textInputDecoration.copyWith(
                    // hintText: 'Shop Name',
                    labelText: 'Shop Address',
                  ),
                  onChanged: (val) {
                    setState(() {
                       shopAddress = val;
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Card(
                    color: Colors.white54,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.teal[400], width: 2.0),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Align(

                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [

                              Text("Mobile No. : ${tempShopkeeper.phoneNumber.toString()}",maxLines: 2, style: TextStyle(fontSize: 20,letterSpacing: 1.2), ),
                              Spacer(flex: 2),
                              Icon(Icons.edit_off),
                              Spacer(flex: 1,),
                            ],
                          )),
                    )),
                SizedBox(
                  height: 5,
                ),
                MaterialButton(
                  onPressed: (){
                    setState(() {
                      addThisLocation = !addThisLocation;
                    });
                  },
                  child: Container(
                    color: addThisLocation ? Colors.green[100]: Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.add_location),
                        SizedBox(width: 10,),
                        Text('Add current location as shop location  '),
                        addThisLocation ? Icon(Icons.done, color: Colors.green,) : Container(),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      if(_currentPosition != null){
                        if(addThisLocation)
                          tempShopkeeper.address = shopAddress + '~' + _currentPosition.latitude.toString() + '~' + _currentPosition.longitude.toString();
                        else
                          tempShopkeeper.address = shopAddress + '~' + shoplang + '~' + shoplat;
                        print(_currentPosition.toString());
                      }
                      ShopkeeperDatabase(uid: tempShopkeeper.uid)
                          .updateShopkeeperDatabase(tempShopkeeper);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ]),
            ),
          ),
        ),
      ),
    ));
  }
}
