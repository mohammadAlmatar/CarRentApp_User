import 'package:animate_do/animate_do.dart';
import 'package:carent/models/cart_model/car_model.dart';
import 'package:carent/models/siginup_model/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../layout/cubit/cubit.dart';
import '../../layout/cubit/states.dart';
import '../../models/process_model.dart';
import '../../shared/componants/componants.dart';
import '../../shared/componants/constants.dart';
import '../more_paying/more_paying_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _refresh() async {
      await MainCubit.get(context).refresh();
      return Future.delayed(const Duration(seconds: 1));
    }

    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        // ignore: unused_local_variable
        var cubit = MainCubit.get(context);
        UsersModel userModel = Constants.usersModel!;
        return WillPopScope(
          onWillPop: () => _onBackButtonPressed(context),
          child: FadeInDown(
            delay: const Duration(milliseconds: 50),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: Colors.blue,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi ${userModel.name!} !",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Search your favourite car here...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      FanCarouselImageSlider(
                        sliderWidth: double.infinity,
                        imagesLink: Constants.images,
                        initalPageIndex: 0,
                        isAssets: false,
                        sliderHeight: 300,
                        indicatorActiveColor: Colors.amber,
                        indicatorDeactiveColor: Colors.black,
                        imageFitMode: BoxFit.cover,
                        expandImageHeight: 450,
                        turns: 75,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(top: 13.5),
                                child: Text(
                                  'Latest cars added',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('cars')
                                .limit(6)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Something is Wrong',
                                  style: Constants
                                      .arabicTheme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.black),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                );
                              }

                              return snapshot.data!.docs.isEmpty
                                  ? SizedBox(
                                      height: 250,
                                      child: Center(
                                          child: Text(
                                        "No Newly Added Cars",
                                        style: Constants
                                            .arabicTheme.textTheme.bodyLarge!
                                            .copyWith(color: Colors.black),
                                      )),
                                    )
                                  : SizedBox(
                                      height: 220.0,
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                              Map<String, dynamic> data =
                                                  document.data()!
                                                      as Map<String, dynamic>;
                                              CarModel carModel =
                                                  CarModel.fromJson(data);
                                              // ignore: unused_local_variable
                                              bool isFavorited = false;
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(
                                                      Constants.usersModel!.uId)
                                                  .collection('favorites')
                                                  .doc(carModel.carId)
                                                  .get()
                                                  .then((value) {
                                                isFavorited = value.exists;
                                              });
                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: 350.0,
                                                    child: CarCard(
                                                      carModel: carModel,
                                                      used: carModel.isUsed!,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              );
                                            })
                                            .toList()
                                            .cast(),
                                      ),
                                    );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Cars for buy',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'jannah',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('cars')
                                .where("isUsed", isEqualTo: false)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Something is Wrong',
                                  style: Constants
                                      .arabicTheme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.black),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                );
                              }

                              return snapshot.data!.docs.isEmpty
                                  ? SizedBox(
                                      height: 250,
                                      child: Center(
                                          child: Text(
                                        "No New Cars",
                                        style: Constants
                                            .arabicTheme.textTheme.bodyLarge!
                                            .copyWith(color: Colors.black),
                                      )),
                                    )
                                  : SizedBox(
                                      height: 220.0,
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                              Map<String, dynamic> data =
                                                  document.data()!
                                                      as Map<String, dynamic>;
                                              CarModel carModel =
                                                  CarModel.fromJson(data);
                                              // ignore: unused_local_variable
                                              bool isFavorited = false;
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(
                                                      Constants.usersModel!.uId)
                                                  .collection('favorites')
                                                  .doc(carModel.carId)
                                                  .get()
                                                  .then((value) {
                                                isFavorited = value.exists;
                                              });
                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: 350.0,
                                                    child: CarCard(
                                                      carModel: carModel,
                                                      used: false,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              );
                                            })
                                            .toList()
                                            .cast(),
                                      ),
                                    );
                            },
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Cars for rent',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'jannah',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('cars')
                                .where("isUsed", isEqualTo: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Something is Wrong',
                                  style: Constants
                                      .arabicTheme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.black),
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                );
                              }

                              return snapshot.data!.docs.isEmpty
                                  ? SizedBox(
                                      height: 250,
                                      child: Center(
                                          child: Text(
                                        "No Used Cars",
                                        style: Constants
                                            .arabicTheme.textTheme.bodyLarge!
                                            .copyWith(color: Colors.black),
                                      )),
                                    )
                                  : SizedBox(
                                      height: 220.0,
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        children: snapshot.data!.docs
                                            .map((DocumentSnapshot document) {
                                              Map<String, dynamic> data =
                                                  document.data()!
                                                      as Map<String, dynamic>;
                                              CarModel carModel =
                                                  CarModel.fromJson(data);

                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: 350.0,
                                                    child: CarCard(
                                                      carModel: carModel,
                                                      used: true,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              );
                                            })
                                            .toList()
                                            .cast(),
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Really !'),
        content: const Text('Do you want to close app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
    return exitApp;
  }
}

// ignore: must_be_immutable
class CarCard extends StatefulWidget {
  CarCard({
    super.key,
    required this.used,
    required this.carModel,
  });

  final CarModel carModel;
  bool used = false;

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool isFavorite = false;
  late ProcessModel processModel;
  Future<void> toggleFavorite() async {
    if (isFavorite == true) {
      MainCubit.get(context).deleteFromFavorites(widget.carModel);
    } else {
      MainCubit.get(context).addToFavorites(widget.carModel);
    }
    await MainCubit.get(context).checkRents(carModel: widget.carModel);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  String? rentEnd;
  @override
  void initState() {
    super.initState();
    fetchFavoriteStatus();
  }

  Future<void> fetchFavoriteStatus() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.usersModel!.uId)
        .collection('favorites')
        .doc(widget.carModel.carId)
        .get();
    setState(() {
      isFavorite = snapshot.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 17),
      child: InkWell(
        onTap: () {
          navigateTo(
              context,
              MorePayingScreen(
                carModel: widget.carModel,
                used: widget.used,
              ));
        },
        child: Stack(
          children: [
            Container(
              height: 190,
              width: 340,
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: HexColor('#d28a7c'),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CarName : ${widget.carModel.branch!}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    widget.carModel.isOffered! == true
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Price: ${widget.carModel.price!} \$",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    decoration: TextDecoration
                                        .lineThrough, // Add line-through decoration
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Offer: ${widget.carModel.priceAfterOffer!} \$ \n until ${widget.carModel.offerExpirationDate!}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            "Price: ${widget.carModel.price!} \$",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Container(
              height: 150,
              width: 340,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  width: 0.7,
                  color: Colors.black,
                ),
              ),
              child: Image.network(
                widget.carModel.imageFiles![0],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 10,
              left: 270,
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                onPressed: () async {
                  if (isFavorite) {
                    MainCubit.get(context).deleteFromFavorites(widget.carModel);
                  } else {
                    MainCubit.get(context).addToFavorites(widget.carModel);
                  }
                },
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    size: 25,
                    color: isFavorite ? Colors.red : Colors.black38,
                  ),
                ),
              ),
            ),
            if (widget.carModel.carStatus == 'CarStatus.RENTED')
              const Positioned(
                top: 5,
                left: 10,
                child: CircleAvatar(
                  radius: 40,
                  child: Center(
                    child: Text(
                      'RENTED',
                      style: TextStyle(color: Colors.black54, fontSize: 19),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
